-- Randomized property-based stress test for tail.lua.
-- Applies a random sequence of ops to a live tailed buffer and, after each,
-- asserts invariants that must hold no matter the sequence. Maintains a MODEL
-- of expected disk/buffer/tail state so it can check "buffer == disk when
-- observable" without false positives. Seeded + op-logged => reproducible.
local SP   = os.getenv("TAILTEST_TMP")
local SEED = tonumber(os.getenv("SEED") or "1")
local NOPS = tonumber(os.getenv("NOPS") or "400")
math.randomseed(SEED)

local tail = require("utils.tail")
tail.poll_ms  = 250              -- fast backstop so recovery paths get exercised
tail.max_bytes = 10*1024*1024    -- high; the fuzzer keeps files tiny (cap tested elsewhere)
vim.opt.autoread = true

local P = SP .. "/fuzz_target.log"
local model = { disk = {}, exists = false, modified = false, tailing = false }
local counter, oplog, failed = 0, {}, nil
local hist = {}

local function uid() counter = counter + 1; return counter end
local function rndlines(n) local t = {}; for _ = 1, n do t[#t+1] = "L" .. uid() end; return t end
local function write_disk(lines) local f = io.open(P, "w"); f:write(table.concat(lines, "\n") .. "\n"); f:close(); model.disk = lines; model.exists = true end
local function append_disk(lines) local f = io.open(P, "a"); f:write(table.concat(lines, "\n") .. "\n"); f:close(); for _, l in ipairs(lines) do model.disk[#model.disk+1] = l end end

write_disk(rndlines(3))
vim.cmd("edit! " .. P)
local B = vim.api.nvim_get_current_buf()
local function buf_lines() return vim.api.nvim_buf_get_lines(B, 0, -1, false) end
local function eq(a, b) if #a ~= #b then return false end for i = 1, #a do if a[i] ~= b[i] then return false end end return true end

-- invariants that hold after EVERY op regardless of sequence
local function check_invariants()
  local has = tail.watchers[B] ~= nil
  if has ~= model.tailing then
    return ("watcher/tailing mismatch (watcher=%s, model.tailing=%s)"):format(tostring(has), tostring(model.tailing))
  end
  if not vim.api.nvim_buf_is_valid(B) then return "buffer became invalid" end
  local ok = pcall(function() return vim.api.nvim_buf_line_count(B) end)
  if not ok then return "editor unresponsive" end
  return nil
end
-- content is only observable-correct when tailing an existing file with no unsaved edits
local function content_checkable() return model.tailing and model.exists and (not model.modified) end

local ops = {}
ops.append        = function() if not model.exists then return false end append_disk(rndlines(math.random(1,4))); return true end
ops.truncate      = function() if not model.exists then return false end write_disk(rndlines(math.random(1,5))); return true end
ops.rename_replace= function()
  if not model.exists then return false end
  local nl = rndlines(math.random(1,5)); local tmp = P .. ".tmp"
  local f = io.open(tmp, "w"); f:write(table.concat(nl, "\n") .. "\n"); f:close()
  os.rename(tmp, P); model.disk = nl; model.exists = true; return true
end
ops.delete        = function() if not model.exists then return false end os.remove(P); model.exists = false; return false end
ops.recreate      = function() if model.exists then return false end write_disk(rndlines(math.random(1,4))); return true end
ops.buf_edit      = function() vim.api.nvim_buf_set_lines(B, -1, -1, false, { "edit" .. uid() }); model.modified = true; vim.bo[B].modified = true; return false end
ops.buf_save      = function()
  local ok = pcall(function() vim.api.nvim_buf_call(B, function() vim.cmd("silent write! " .. P) end) end)
  if ok then model.disk = buf_lines(); model.exists = true; model.modified = false end
  return false
end
ops.buf_discard   = function() if not model.exists then return false end pcall(function() vim.api.nvim_buf_call(B, function() vim.cmd("edit!") end) end); model.modified = false; return true end
ops.cursor_move   = function() local lc = vim.api.nvim_buf_line_count(B); pcall(vim.api.nvim_win_set_cursor, 0, { math.random(1, lc), 0 }); return false end
ops.tail_off      = function() tail.stop(B); model.tailing = false; return false end
ops.tail_on       = function() local ok = tail.start(B); model.tailing = (ok == true); return (ok == true) and model.exists end

local names = { "append","truncate","rename_replace","delete","recreate","buf_edit","buf_save","buf_discard","cursor_move","tail_off","tail_on" }

tail.start(B); model.tailing = true
local i = 0
local finished = false

local function finish()
  if finished then return end; finished = true
  local msgs = vim.fn.execute("messages")
  local e5560 = (msgs:match("E5560") ~= nil) or (msgs:match("fast event context") ~= nil)
  local out = {}
  out[#out+1] = ("SEED=%d  ops_run=%d/%d"):format(SEED, i, NOPS)
  local histstr = {}
  for _, n in ipairs(names) do histstr[#histstr+1] = n .. "=" .. (hist[n] or 0) end
  out[#out+1] = "  ops: " .. table.concat(histstr, " ")
  if e5560 then out[#out+1] = "  ** E5560 FAST-CONTEXT ERROR in :messages **" end
  if failed then
    out[#out+1] = ("> FAILED at op #%d [%s]: %s"):format(i, failed.op, failed.inv)
    if failed.buf then out[#out+1] = "    buffer: " .. failed.buf end
    if failed.disk then out[#out+1] = "    disk:   " .. failed.disk end
    local tail_ops = {}
    for k = math.max(1, #oplog-25), #oplog do tail_ops[#tail_ops+1] = oplog[k] end
    out[#out+1] = "    last ops: " .. table.concat(tail_ops, ",")
  else
    out[#out+1] = "  SURVIVED all " .. i .. " ops; invariants held" .. (e5560 and " EXCEPT E5560" or "")
  end
  -- distinguish an ACTIVE watcher (buffer still tailing = correct) from a LEAK
  local at_end = vim.tbl_count(tail.watchers)
  local was_tailing = model.tailing
  local h = tail.watchers[B] and tail.watchers[B].handle
  tail.stop(B)
  local after_teardown = vim.tbl_count(tail.watchers)
  out[#out+1] = ("  end: tailing=%s, watchers=%d (expected %d from tailing state)")
    :format(tostring(was_tailing), at_end, was_tailing and 1 or 0)
  out[#out+1] = ("  after explicit teardown: watchers=%d (expect 0), handle_active=%s (expect false)")
    :format(after_teardown, tostring(h and h:is_active() or false))
  io.stdout:write(table.concat(out, "\n") .. "\n"); vim.cmd("qa!")
end

local function step()
  if failed or i >= NOPS then return finish() end
  i = i + 1
  local name = names[math.random(#names)]
  oplog[#oplog+1] = name; hist[name] = (hist[name] or 0) + 1
  local ok, needs_wait = pcall(ops[name])
  if not ok then failed = { op = name, inv = "op threw: " .. tostring(needs_wait) }; return finish() end
  local inv = check_invariants()
  if inv then failed = { op = name, inv = inv }; return finish() end
  if needs_wait and content_checkable() then
    local t0 = vim.uv.now()
    local function poll()
      if eq(buf_lines(), model.disk) then vim.defer_fn(step, 0)
      elseif vim.uv.now() - t0 > 2000 then
        failed = { op = name,
          inv = ("content mismatch after 2s (buf=%d lines, disk=%d lines)"):format(#buf_lines(), #model.disk),
          buf = table.concat(buf_lines(), ","):sub(1, 90),
          disk = table.concat(model.disk, ","):sub(1, 90) }
        finish()
      else vim.defer_fn(poll, 20) end
    end
    poll()
  else
    vim.defer_fn(step, 3)
  end
end

vim.defer_fn(function() if not finished then failed = failed or { op = "?", inv = "WATCHDOG: hung" }; finish() end end, 600000)
step()
