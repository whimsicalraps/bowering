--- boughs
-- extensions to keep the core script clear

local b = {}


-- return true for files with ".lua" extension
function b.is_luafile( filename )
  local dot = string.find( string.reverse(filename), '%.')
  if not dot then return false end -- subfolders are ignored
  local ext = string.sub( filename, 1-dot )
  return ext == 'lua'
end


-- filter out elements of 't' that don't satisfy 'predicate'
-- NOTE: modifies the table in place
function b.filter( predicate, t )
  for k,v in pairs(t) do
    if not predicate(v) then table.remove(t,k) end
  end
  return t
end


return b