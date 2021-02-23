--- temporary lib file
-- extends norns.crow table with public discovery system


local Public = {}
Public._names = {}
Public._params = {}


function Public.loadscript(file, is_persistent)
  -- start upload
  co = crow.loadscript(file, is_persistent)
  
  clock.run( function(co, p)
      -- wait for loadscript to complete
      clock.sleep(0.5) -- minimum time for upload to complete
      if coroutine.status(co) ~= 'dead' then clock.sleep(0.1) end -- sleep until completion
      if p then clock.sleep(0.2) end -- extra time for flash write
      clock.sleep(1.0) -- wait for lua env to be ready (this time can be shorter for simpler scripts)
      
      -- reset the public storage
      Public._names = {}
      Public._params = {}
      -- request params from crow
      crow.send "public.discover()"
    end, clock.threads[co], p) -- we grab the coroutine itself, not clock index
end


-- from crow: ^^pub(name,val,{type})
function Public.add(name, val, typ)
  if name == '_end' then
    Public.ready()
  else
    -- add name to dictionary with linked index
    local ix = Public._names[name] -- look for existing declaration
    if not ix then -- new addition
      ix = #(Public._params) + 1
      Public._names[name] = ix
    end
    
    Public._params[ix] = { name = name, val = val }
    print("adding: " .. name .. "=" .. val)
    if typ then print "TODO handle public type restrictions" end
  end
end


function Public.get_count()
  return #Public._params
end

function Public.get_index(ix)
  return Public._params[ix]
end

function Public.delta(ix, z)
  local p = Public._params[ix]
  local tmp = p.val + z
  -- TODO scale z per range, and apply clamp
  Public[p.name] = tmp -- use metamethod to cause remote update
end

--- METAMETHODS
-- get/set the values
-- setters
Public.__newindex = function(self, ix, val)
  local kix = Public._names[ix]
  if kix then
    -- TODO apply type limits (but not scaling)
    local p = Public._params[kix]
    p.val = val
    crow.send("public."..p.name.."="..p.val)
    -- TODO suppress update if change comes from remote
    end
end

-- getters
Public.__index = function(self, ix)
  local kix = Public._names.ix
  if kix then
    return Params._params[kix].val
  end
end


-- user event callback to be redefined
function Public.ready()
  print 'crow.public synchronized.'
end

setmetatable(Public,Public)

-- FIXME extends main crow module (captures `^^pub(...)` messages)
crow.public = Public -- FIXME require() this module
function norns.crow.pub(...)
  crow.public.add(...)
end


return Public