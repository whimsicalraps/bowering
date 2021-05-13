--- draw
-- functional display of UI elements
-- no global data access here
-- the only stateful actions allowed are to 'screen'

local draw = {}


function draw.script_selection( scripts, selected, current, is_freeze )
  screen.move(128,8)
  screen.font_face(1)
  screen.font_size(8)
  screen.level( (selected==current) and 15 or 5 )
  
  local name = "none"
  if selected > 0 then -- not none
    name = string.sub( scripts[selected],1,-5 )
    if is_freeze and selected == current then
      name = "FREEZE " .. name
    end
  end
  screen.text_right(name)
end


function draw.script_describe( script )
  local scriptpath = norns.state.path .. 'crow/' .. script
  if util.file_exists(scriptpath) then
    
    screen.move(0,8)
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


-- draw all the params
function draw.public_params( pub, sel )
  -- draw any kind of param
  local function dparam(p, sel, yoff)

    -- draw a slider
    local function dslider(p, sel, xoff, yoff, width)
      -- range strikethrough
      screen.line_width(1)
      screen.level(1)
      screen.move(xoff+1, yoff-2)
      screen.line_rel(width,0)
      screen.stroke()
      -- location
      local loc = width*(p.val - p.min)/p.range
      screen.move(xoff+1+loc, yoff)
      screen.level( sel and 15 or 5 )
      screen.line_rel(0,-5)
      screen.stroke()
    end
    
    -- draw a table (with selection)
    local function dtable(p, sel, xoff, yoff)
      local spacing = 10
      -- draw step-select if index is non-zero
      if p.val.index then
      -- fill style
        screen.level(1)
        screen.rect(xoff-2 + (p.val.index-1)*spacing, yoff+1, 8, -7)
        screen.fill()
      -- underline style
        -- screen.move(xoff + (p.val.index-1)*spacing, yoff + 3)
        -- screen.level(15)
        -- screen.line_rel(4,0)
        -- screen.stroke()
      end
      -- draw table elements
      for k,v in ipairs(p.val) do
        screen.level( (sel and k==p.listix) and 15 or 5)
        screen.move(xoff+2 + (k-1)*spacing, yoff)
        screen.text_center(v)
      end
    end
    
  -- draw param name
    screen.level( sel and 15 or 5 )
    screen.move(36, yoff)
    screen.text_right(p.name)
    local xoff = 45
  -- draw param value
    if p.type == 'slider' then
      dslider(p, sel, xoff, yoff, 64)
    elseif p.list then -- draw a list type
      dtable(p, sel, xoff, yoff)
    else -- draw number/string value
      screen.move(xoff, yoff)
      if type(p.val) == 'number' then
        screen.text(string.format('%.4g',p.val))
      else
        screen.text(p.val)
      end
    end
  end
  
  local len = pub.get_count()
  if len > 0 then
    if len > 6 then len = 6 end -- limit length to viewable count
    screen.font_face(1)
    screen.font_size(8)
    for i=1,len do
      dparam(pub.get_index(i), i==sel, (i+1)*9 - 1)
    end
  end
end


-- draw viewable i/o
function draw.public_views( vs )
  local function vslide(x, val)
    val = -val*3.6
    if math.floor(val+0.5) == 0 then
      screen.level(1)
      screen.pixel(x-1, 43) -- pixel prints 1px to the right of line_rel
      screen.fill()
    else
      screen.level(5)
      screen.move(x, 44)
      screen.line_rel(0, val)
      screen.stroke()
    end
  end
  screen.line_width(1)
  for i=1,2 do if vs.input[i] ~= nil then vslide(1 + (i-1) * 4, vs.input[i]) end end
  for i=1,4 do if vs.output[i] ~= nil then vslide(115 + (i-1) * 4, vs.output[i]) end end
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