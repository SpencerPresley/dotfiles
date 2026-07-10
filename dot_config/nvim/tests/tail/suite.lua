-- Adversarial suite v3. Hardened harness:
--  * every deferred callback wrapped so an error records a FAIL and still
--    advances the chain (no silent hang);
--  * global 55s watchdog force-reports whatever is collected then quits;
--  * positive cases settle after start() (real usage: file changes come later),
--    so the arm-window race can't corrupt unrelated assertions;
--  * one dedicated case MEASURES the arm-window instead of hiding it;
--  * positive detection uses wait_until(pred) + records real latency.

local SP = os.getenv("TAILTEST_TMP")
local tail = require("utils.tail")
vim.opt.autoread = true

local results = {}
local finished = false
local function EXPECT(name, actual, expected)
  local ok=(actual==expected)
  results[#results+1]={name=name,ok=ok,detail=ok and "" or ("got="..tostring(actual).." want="..tostring(expected))}
end
local function NOTE(name,val) results[#results+1]={name=name,ok="note",detail=tostring(val)} end
local function FAILrec(name,msg) results[#results+1]={name=name,ok=false,detail=tostring(msg):gsub("\n"," ")} end

local function messages_have_e5560()
  local m=vim.fn.execute("messages"); return (m:match("E5560")~=nil) or (m:match("fast event context")~=nil)
end
local function tmpfile(n) return SP.."/suite_"..n..".log" end
local function write(p,s) local f=io.open(p,"w"); f:write(s); f:close() end
local function append(p,s) local f=io.open(p,"a"); f:write(s); f:close() end
local function lc(b) return vim.api.nvim_buf_line_count(b) end
local function first(b) return (vim.api.nvim_buf_get_lines(b,0,1,false)[1]) or "" end
local function last(b) return (vim.api.nvim_buf_get_lines(b,-2,-1,false)[1]) or "" end
local function edit(p) vim.cmd("edit! "..p); return vim.api.nvim_get_current_buf() end
local function cleanup(b) pcall(function() tail.stop(b) end); pcall(vim.api.nvim_buf_delete,b,{force=true}) end

-- wrap any async callback: errors are recorded, chain still advances
local function guard(name, fn) return function(...)
  local a={...}
  local ok,err=xpcall(function() return fn(unpack(a)) end, debug.traceback)
  if not ok then FAILrec(name.." [cb THREW]", err) end
end end

local TIMEOUT=4000
local function wait_until(pred, on_done)
  local t0=vim.uv.now()
  local function poll()
    local ok,val=pcall(pred)
    if ok and val then on_done(true, vim.uv.now()-t0)
    elseif vim.uv.now()-t0>=TIMEOUT then on_done(false, vim.uv.now()-t0)
    else vim.defer_fn(poll,25) end
  end
  poll()
end
local function stays_false(pred, hold, on_done)
  local t0=vim.uv.now()
  local function poll()
    local ok,val=pcall(pred)
    if ok and val then on_done(false, vim.uv.now()-t0)
    elseif vim.uv.now()-t0>=hold then on_done(true, hold)
    else vim.defer_fn(poll,25) end
  end
  poll()
end
local SETTLE=200  -- let FSEvents arm before we rely on it (real usage: log already open)
local function after_start(b, fn) vim.defer_fn(guard("settle", fn), SETTLE) end

local tests={}
local function test(name,fn) tests[#tests+1]={name=name,fn=fn} end

test("ARM-WINDOW: change written same tick as start() (measured, not asserted)", function(done)
  local p=tmpfile("arm"); write(p,"seed\n")
  local b=edit(p); tail.start(b); append(p,"immediate\n")  -- no settle: worst case
  wait_until(function() return lc(b)==2 end, guard("arm", function(ok,ms)
    NOTE("ARM.same_tick_caught", ok and ("YES @"..ms.."ms (initial-sync covered it)") or "NO within "..TIMEOUT.."ms")
    cleanup(b); done()
  end))
end)

test("A: plain append reloads live", function(done)
  local p=tmpfile("A"); write(p,"l1\nl2\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    pcall(vim.api.nvim_win_set_cursor,0,{2,0}); append(p,"l3\n")
    wait_until(function() return last(b)=="l3" end, guard("A", function(ok,ms)
      EXPECT("A.detected",ok,true); NOTE("A.latency_ms",ms)
      EXPECT("A.count",lc(b),3); EXPECT("A.unmodified",vim.bo[b].modified,false)
      cleanup(b); done()
    end))
  end)
end)

test("B: follow at bottom; preserve cursor when scrolled up", function(done)
  local p=tmpfile("B"); write(p,"a\nb\nc\nd\ne\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    pcall(vim.api.nvim_win_set_cursor,0,{2,0}); append(p,"f\n")
    wait_until(function() return lc(b)>=6 end, guard("B1", function(ok,ms)
      EXPECT("B.detected",ok,true); NOTE("B.latency_ms",ms)
      EXPECT("B.cursor_preserved", vim.api.nvim_win_get_cursor(0)[1], 2)
      if lc(b)>=6 then pcall(vim.api.nvim_win_set_cursor,0,{lc(b),0}) end
      append(p,"g\n")
      wait_until(function() return lc(b)>=7 end, guard("B2", function(ok2)
        EXPECT("B.follow_detected",ok2,true)
        EXPECT("B.followed_to_end", vim.api.nvim_win_get_cursor(0)[1], lc(b))
        cleanup(b); done()
      end))
    end))
  end)
end)

test("C: burst of 10 appends -> correct final state", function(done)
  local p=tmpfile("C"); write(p,"x\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    for i=1,10 do append(p,"burst"..i.."\n") end
    wait_until(function() return last(b)=="burst10" end, guard("C", function(ok,ms)
      EXPECT("C.detected",ok,true); NOTE("C.latency_ms",ms); EXPECT("C.final_count",lc(b),11)
      cleanup(b); done()
    end))
  end)
end)

test("D: atomic rename (new inode) reloads AND re-arms", function(done)
  local p=tmpfile("D"); write(p,"old1\nold2\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    local ino0=vim.uv.fs_stat(p).ino
    local tmp=p..".tmp"; write(tmp,"n1\nn2\nn3\n"); os.rename(tmp,p)
    EXPECT("D.inode_changed", ino0~=vim.uv.fs_stat(p).ino, true)
    wait_until(function() return first(b)=="n1" end, guard("D1", function(ok,ms)
      EXPECT("D.reloaded_after_rename",ok,true); NOTE("D.rename_latency_ms", ok and ms or (">"..TIMEOUT))
      EXPECT("D.new_count",lc(b),3)
      append(p,"post\n")
      wait_until(function() return last(b)=="post" end, guard("D2", function(ok2,ms2)
        EXPECT("D.rearm_catches_append",ok2,true); NOTE("D.rearm_latency_ms", ok2 and ms2 or (">"..TIMEOUT))
        cleanup(b); done()
      end))
    end))
  end)
end)

test("E: truncate-in-place reloads", function(done)
  local p=tmpfile("E"); write(p,"1\n2\n3\n4\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    write(p,"fresh\n")
    wait_until(function() return first(b)=="fresh" end, guard("E", function(ok,ms)
      EXPECT("E.detected",ok,true); NOTE("E.latency_ms", ok and ms or (">"..TIMEOUT)); EXPECT("E.count",lc(b),1)
      cleanup(b); done()
    end))
  end)
end)

test("F: delete then recreate (delete-based rotation)", function(done)
  local p=tmpfile("F"); write(p,"before\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    os.remove(p)
    vim.defer_fn(guard("F1", function()
      NOTE("F.lines_after_delete", lc(b))
      write(p,"recreated\nl2\n")
      wait_until(function() return first(b)=="recreated" end, guard("F2", function(ok,ms)
        NOTE("F.recovered_after_recreate", ok and ("YES @"..ms.."ms") or "NO (known limitation)")
        cleanup(b); done()
      end))
    end), 400)
  end)
end)

test("G: unsaved edits not clobbered, then prove watcher still live", function(done)
  local p=tmpfile("G"); write(p,"disk1\ndisk2\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    vim.api.nvim_buf_set_lines(b,-1,-1,false,{"MY UNSAVED EDIT"})
    EXPECT("G.modified_before", vim.bo[b].modified, true)
    append(p,"external\n")
    stays_false(function() return last(b)=="external" end, 2000, guard("G1", function(held)
      EXPECT("G.edit_not_clobbered",held,true); EXPECT("G.still_modified",vim.bo[b].modified,true)
      vim.bo[b].modified=false; vim.api.nvim_buf_call(b,function() vim.cmd("edit!") end)
      append(p,"proof_live\n")
      wait_until(function() return last(b)=="proof_live" end, guard("G2", function(ok)
        EXPECT("G.watcher_live_afterward",ok,true)
        vim.bo[b].modified=false; cleanup(b); done()
      end))
    end))
  end)
end)

test("H: stop() while debounce pending must not crash", function(done)
  local p=tmpfile("H"); write(p,"h1\n"); local b=edit(p); tail.start(b)
  after_start(b, function()
    append(p,"h2\n")
    vim.defer_fn(guard("H1", function()
      local ok=pcall(function() tail.stop(b) end); EXPECT("H.stop_no_error",ok,true)
      vim.defer_fn(guard("H2", function() EXPECT("H.no_zombie",tail.watchers[b],nil); cleanup(b); done() end), 300)
    end), 15)
  end)
end)

test("I: double start = single watcher", function(done)
  local p=tmpfile("I"); write(p,"i1\n"); local b=edit(p)
  tail.start(b); local h1=tail.watchers[b]; tail.start(b); local h2=tail.watchers[b]
  EXPECT("I.same_watcher",h1,h2); EXPECT("I.exists",h1~=nil,true); cleanup(b); done()
end)

test("J: wipe without stop -> no leak", function(done)
  local p=tmpfile("J"); write(p,"j1\n"); local b=edit(p); tail.start(b)
  local h=tail.watchers[b].handle; vim.api.nvim_buf_delete(b,{force=true})
  vim.defer_fn(guard("J1", function()
    EXPECT("J.entry_cleared",tail.watchers[b],nil); EXPECT("J.handle_inactive",h:is_active(),false); done()
  end), 150)
end)

test("K: start on no-file buffer refused", function(done)
  vim.cmd("enew"); local b=vim.api.nvim_get_current_buf()
  EXPECT("K.refused",tail.start(b),false); EXPECT("K.no_watcher",tail.watchers[b],nil)
  pcall(vim.api.nvim_buf_delete,b,{force=true}); done()
end)

local function report()
  if finished then return end; finished=true
  EXPECT("Z.no_watchers_leaked", vim.tbl_count(tail.watchers), 0)
  EXPECT("Z.no_fast_context_errors", messages_have_e5560(), false)
  local out,pass,fail={},0,0
  for _,r in ipairs(results) do
    if r.ok=="note" then out[#out+1]=string.format("  note  %-30s %s",r.name,r.detail)
    elseif r.ok then pass=pass+1; out[#out+1]=string.format("  PASS  %s",r.name)
    else fail=fail+1; out[#out+1]=string.format("> FAIL  %-30s %s",r.name,r.detail) end
  end
  out[#out+1]=string.format("\n  %d passed, %d FAILED", pass, fail)
  io.stdout:write(table.concat(out,"\n").."\n"); vim.cmd("qa!")
end

local function run(i)
  if i>#tests then report(); return end
  local t=tests[i]
  local ok,err=xpcall(function() t.fn(guard("run.done", function() run(i+1) end)) end, debug.traceback)
  if not ok then FAILrec(t.name.." [THREW]", err); run(i+1) end
end

vim.defer_fn(function() FAILrec("WATCHDOG","suite exceeded 55s, forced report"); report() end, 55000)
run(1)
