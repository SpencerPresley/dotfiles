-- Tests the two failure modes Spencer asked about:
--   (1) delete-recreate: blast radius + automatic recovery
--   (2) huge/fast-growing file: size ceiling protection
local SP = os.getenv("TAILTEST_TMP")
local tail = require("utils.tail")
vim.opt.autoread = true
tail.poll_ms = 300   -- speed up the backstop for the test (prod default 2000)

local results = {}
local function EXPECT(n,a,e) results[#results+1]={n=n,ok=(a==e),d=(a==e) and "" or ("got="..tostring(a).." want="..tostring(e))} end
local function NOTE(n,v) results[#results+1]={n=n,ok="note",d=tostring(v)} end
local function FAILrec(n,m) results[#results+1]={n=n,ok=false,d=tostring(m):gsub("\n"," ")} end
local notes = {}
local orig_notify = vim.notify
vim.notify = function(msg,...) notes[#notes+1]=tostring(msg); return orig_notify(msg,...) end

local function tmp(n) return SP.."/rec_"..n..".log" end
local function write(p,s) local f=io.open(p,"w"); f:write(s); f:close() end
local function append(p,s) local f=io.open(p,"a"); f:write(s); f:close() end
local function lc(b) return vim.api.nvim_buf_line_count(b) end
local function first(b) return (vim.api.nvim_buf_get_lines(b,0,1,false)[1]) or "" end
local function last(b) return (vim.api.nvim_buf_get_lines(b,-2,-1,false)[1]) or "" end
local function edit(p) vim.cmd("edit! "..p); return vim.api.nvim_get_current_buf() end
local function guard(n,fn) return function(...) local a={...}; local ok,e=xpcall(function() return fn(unpack(a)) end,debug.traceback); if not ok then FAILrec(n.." [THREW]",e) end end end
local TIMEOUT=3500
local function wait_until(pred,cb) local t0=vim.uv.now(); local function poll() local ok,v=pcall(pred); if ok and v then cb(true,vim.uv.now()-t0) elseif vim.uv.now()-t0>=TIMEOUT then cb(false,vim.uv.now()-t0) else vim.defer_fn(poll,25) end end poll() end
local SETTLE=250
local tests={}; local function test(n,f) tests[#tests+1]={n=n,f=f} end

test("delete-recreate: no corruption + auto-recovery", function(done)
  local p=tmp("dr"); write(p,"before1\nbefore2\n")
  local b=edit(p); tail.start(b)
  vim.defer_fn(guard("dr.settle", function()
    pcall(vim.api.nvim_win_set_cursor,0,{lc(b),0})
    append(p,"live1\n")
    wait_until(function() return last(b)=="live1" end, guard("dr.live", function(ok)
      EXPECT("dr.live_before_delete", ok, true)
      -- DELETE the file out from under the watcher
      os.remove(p)
      vim.defer_fn(guard("dr.afterdel", function()
        -- blast radius checks: buffer intact, valid, session healthy
        EXPECT("dr.buffer_still_valid", vim.api.nvim_buf_is_valid(b), true)
        EXPECT("dr.content_not_corrupted", (lc(b)>=1 and first(b)=="before1"), true)
        local ok2=pcall(function() vim.cmd("enew"); vim.cmd("b "..b) end)  -- can still navigate
        EXPECT("dr.session_healthy_nav", ok2, true)
        -- RECREATE at same path (delete-based rotation)
        write(p,"recreated1\nrecreated2\n")
        wait_until(function() return first(b)=="recreated1" end, guard("dr.recover", function(rok,ms)
          EXPECT("dr.content_recovered", rok, true)
          NOTE("dr.recover_latency_ms", rok and ms or (">"..TIMEOUT))
          -- prove instant response is restored (watcher re-armed): a new append
          -- should be caught fast, well under the poll interval
          local t0=vim.uv.now()
          append(p,"post_recover\n")
          wait_until(function() return last(b)=="post_recover" end, guard("dr.rearm", function(aok,ams)
            EXPECT("dr.rearmed_catches_append", aok, true)
            NOTE("dr.rearm_latency_ms", aok and ams or (">"..TIMEOUT))
            EXPECT("dr.rearm_was_instant_not_poll", (aok and ams < tail.poll_ms), true)
            tail.stop(b); pcall(vim.api.nvim_buf_delete,b,{force=true}); done()
          end))
        end))
      end), 500)
    end))
  end), SETTLE)
end)

test("size ceiling: refuse to attach to an already-huge file", function(done)
  tail.max_bytes = 500  -- tiny cap for the test
  local p=tmp("big1"); write(p, string.rep("x\n", 600))  -- ~1200 bytes > cap
  local b=edit(p)
  local ok, why = tail.start(b)
  EXPECT("big.refused_at_start", ok, false)
  NOTE("big.refuse_reason", why)
  EXPECT("big.no_watcher", tail.watchers[b], nil)
  pcall(vim.api.nvim_buf_delete,b,{force=true})
  tail.max_bytes = 10*1024*1024
  done()
end)

test("size ceiling: auto-disable when a followed file grows past cap", function(done)
  tail.max_bytes = 400
  local p=tmp("big2"); write(p,"small\n")
  local b=edit(p)
  local ok=tail.start(b)
  EXPECT("grow.started_small", ok, true)
  vim.defer_fn(guard("grow.settle", function()
    write(p, string.rep("BIGLINE\n", 100))  -- ~800 bytes, over the 400 cap
    wait_until(function() return tail.watchers[b]==nil end, guard("grow.disabled", function(dok,ms)
      EXPECT("grow.auto_disabled", dok, true)
      NOTE("grow.disable_latency_ms", dok and ms or (">"..TIMEOUT))
      local warned=false; for _,m in ipairs(notes) do if m:match("live%-follow disabled") then warned=true end end
      EXPECT("grow.user_was_warned", warned, true)
      EXPECT("grow.buffer_still_valid", vim.api.nvim_buf_is_valid(b), true)
      tail.max_bytes = 10*1024*1024
      pcall(vim.api.nvim_buf_delete,b,{force=true}); done()
    end))
  end), SETTLE)
end)

local function run(i)
  if i>#tests then
    EXPECT("Z.no_watchers_leaked", vim.tbl_count(tail.watchers), 0)
    local out,pass,fail={},0,0
    for _,r in ipairs(results) do
      if r.ok=="note" then out[#out+1]=string.format("  note  %-32s %s",r.n,r.d)
      elseif r.ok then pass=pass+1; out[#out+1]=string.format("  PASS  %s",r.n)
      else fail=fail+1; out[#out+1]=string.format("> FAIL  %-32s %s",r.n,r.d) end
    end
    out[#out+1]=string.format("\n  %d passed, %d FAILED",pass,fail)
    io.stdout:write(table.concat(out,"\n").."\n"); vim.cmd("qa!"); return
  end
  local t=tests[i]
  local ok,err=xpcall(function() t.f(guard("done", function() run(i+1) end)) end, debug.traceback)
  if not ok then FAILrec(t.n.." [THREW]",err); run(i+1) end
end
vim.defer_fn(function() FAILrec("WATCHDOG","exceeded 40s"); run(#tests+1) end, 40000)
run(1)
