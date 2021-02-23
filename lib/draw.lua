--- draw
-- functional display of UI elements
-- PLEASE no global data access here
-- the only stateful actions allowed are to 'screen'

local draw = {}


function draw.script_selection( scripts, selected, current )
  screen.move(0,8)
  screen.font_face(1)
  screen.font_size(8)
  screen.level( (selected==current) and 15 or 5 )
  
  local name = "none"
  if selected > 0 then -- not none
    name = string.sub( scripts[selected],1,-5 )
  end
  screen.text(name)
end


function draw.script_describe( script )
  local scriptpath = norns.state.path .. 'crow/' .. script
  if util.file_exists(scriptpath) then
    
    screen.move(4,16)
    screen.font_face(1)
    screen.font_size(8)
    screen.level(3)
    
    -- read first line of crow script
    local file = io.open(scriptpath,"r")
    local desc = file:read() -- grab first line
    file:close()
    
    -- trim comment markers and whitespace
    local start = string.find(desc,"[^%-%s]") -- find first non-comment, non-whitespace char
    desc = string.sub(desc,start)
    
    screen.text(desc)
  end
end



function draw.public_params( pub, sel )
  local len = pub.get_count()
  if len > 0 then
    if len > 8 then len = 8 end -- limit length to viewable count
    screen.font_face(1)
    screen.font_size(8)
    for i=1,len do
      screen.level( (i==sel) and 15 or 5 ) -- selected is bright
      local p = pub.get_index(i)
      screen.move(48,(i+2)*8)
      screen.text_right(p.name) -- text_right?
      screen.move(64,(i+2)*8)
      screen.text(p.val)
    end
  end
end


function draw.console(s)
  screen.move(0,62)
  screen.font_face(1)
  screen.font_size(8)
  screen.level(3)
  
  -- strip leading control chars
  local start = string.find(s,"%C")
  s = string.sub(s,start or 0)
  
  -- replace any control chars with spaces
  s = string.gsub(s,"%c"," ")
  
  -- only draw if there is a message to show
  if string.len(s) > 0 then screen.text("> "..s) end
end

return draw