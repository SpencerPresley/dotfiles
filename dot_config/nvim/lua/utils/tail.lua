-- Live-follow a buffer via OS file-watch (libuv fs_event) with a polling
-- backstop and a hard size ceiling. Think `tail -f`, but inside a real buffer
-- (search, syntax, your keymaps all work). Opt-in per buffer via :Tail.
--
--   * fs_event  -> instant (~100ms) response to external changes
--   * poll      -> re-reads every poll_ms as a safety net; also RE-ARMS the
--                  watcher after delete-recreate (which kills a naive watch)
--   * size cap  -> refuses / auto-disables past max_bytes so a huge or
--                  fast-growing file can never make us re-read it to death
--
-- Failure containment: the worst case is ONE buffer that stops live-updating.
-- Buffer content is never corrupted; the rest of the session is untouched.
--
-- Validated by tests/tail/ (adversarial suite + property fuzzer): tests/tail/run.sh
local M = {}
M.watchers = {}
M.debounce_ms = 80
M.poll_ms = 2000
M.max_bytes = 10 * 1024 * 1024  -- 10 MB

local function fsize(path) local st = vim.uv.fs_stat(path); return st and st.size or nil end

local function view_at_bottom(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_cursor(win)[1] >= vim.api.nvim_buf_line_count(buf) then return true end
  end
  return false
end

-- Sync buffer from disk. Returns false if it auto-disabled (size), else true.
-- No-ops silently if the file is currently missing (no E211 spam while a
-- delete-recreate rotation is mid-flight).
local function reload(buf)
  if not vim.api.nvim_buf_is_valid(buf) then M.stop(buf); return end
  local name = vim.api.nvim_buf_get_name(buf)
  local sz = fsize(name)
  if sz == nil then return true end            -- file gone right now: nothing to read
  if sz > M.max_bytes then
    M.stop(buf)
    vim.notify(("[tail] %s is %.1fMB (> %dMB cap) — live-follow disabled, use `tail -f`")
      :format(vim.fn.fnamemodify(name, ":t"), sz/1048576, math.floor(M.max_bytes/1048576)),
      vim.log.levels.WARN)
    return false
  end
  local follow = view_at_bottom(buf)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  vim.api.nvim_buf_call(buf, function() vim.cmd("checktime") end)
  -- Only follow to the new bottom if the buffer ACTUALLY reloaded. Without this
  -- guard the 2s poll would yank the cursor to col 0 (and fire CursorMoved) on
  -- every idle tick when you're sitting on the last line.
  if follow and vim.api.nvim_buf_get_changedtick(buf) ~= tick then
    local lastl = vim.api.nvim_buf_line_count(buf)
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do pcall(vim.api.nvim_win_set_cursor, win, { lastl, 0 }) end
  end
  return true
end

local function try_arm(buf)
  local w = M.watchers[buf]; if not w then return end
  local name = vim.api.nvim_buf_get_name(buf)
  pcall(function() w.handle:stop() end)
  local ok = pcall(function()
    w.handle:start(name, {}, function(err)
      if err then return end
      w.timer:stop()
      w.timer:start(M.debounce_ms, 0, vim.schedule_wrap(function()
        if not M.watchers[buf] then return end
        if reload(buf) == false then return end
        try_arm(buf)  -- re-arm: an atomic-rename swaps the inode out from under us
      end))
    end)
  end)
  w.armed = ok and (fsize(name) ~= nil)
end

function M.start(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if M.watchers[buf] then return true end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.fn.filereadable(name) == 0 then return false, "buffer has no readable file" end
  local sz = fsize(name)
  if sz and sz > M.max_bytes then
    return false, ("file is %.1fMB (> %dMB cap)"):format(sz/1048576, math.floor(M.max_bytes/1048576))
  end
  local w = {
    handle = vim.uv.new_fs_event(),
    timer  = vim.uv.new_timer(),
    poll   = vim.uv.new_timer(),
    armed  = false,
  }
  M.watchers[buf] = w
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    buffer = buf, once = true, callback = function() M.stop(buf) end,
  })
  try_arm(buf)
  vim.schedule(function() if vim.api.nvim_buf_is_valid(buf) then reload(buf) end end)  -- initial sync
  -- backstop poll: missed-event safety net + delete-recreate recovery + size check
  w.poll:start(M.poll_ms, M.poll_ms, vim.schedule_wrap(function()
    if not M.watchers[buf] or not vim.api.nvim_buf_is_valid(buf) then return end
    if reload(buf) == false then return end
    if not w.armed then try_arm(buf) end   -- restore instant response after recreate
  end))
  return true
end

function M.stop(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local w = M.watchers[buf]; if not w then return end
  M.watchers[buf] = nil
  pcall(function() w.handle:stop(); w.handle:close() end)
  pcall(function() w.timer:stop();  w.timer:close()  end)
  pcall(function() w.poll:stop();   w.poll:close()   end)
end

function M.toggle(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if M.watchers[buf] then M.stop(buf); return false end
  return (M.start(buf))
end

-- User commands. Call once at startup (see config/keymaps.lua).
function M.setup()
  local function name() return vim.fn.expand("%:t") end
  vim.api.nvim_create_user_command("Tail", function()
    local ok, why = M.start()
    vim.notify(ok and ("[tail] following " .. name()) or ("[tail] " .. (why or "cannot follow")),
      ok and vim.log.levels.INFO or vim.log.levels.WARN)
  end, { desc = "Live-follow this file (tail -f in the buffer)" })

  vim.api.nvim_create_user_command("TailStop", function()
    M.stop(); vim.notify("[tail] stopped " .. name(), vim.log.levels.INFO)
  end, { desc = "Stop live-follow on this file" })

  vim.api.nvim_create_user_command("TailToggle", function()
    local buf = vim.api.nvim_get_current_buf()
    if M.watchers[buf] then
      M.stop(buf); vim.notify("[tail] off (" .. name() .. ")", vim.log.levels.INFO)
    else
      local ok, why = M.start(buf)
      vim.notify(ok and ("[tail] following " .. name()) or ("[tail] " .. (why or "cannot follow")),
        ok and vim.log.levels.INFO or vim.log.levels.WARN)
    end
  end, { desc = "Toggle live tail on this file" })
end

return M
