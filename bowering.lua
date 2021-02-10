--- crow script upload utility
-- takes a lua file as argument and sends it to crow 
-- can save to crow's internal flash with the optional 'flash' arg

-- UI settings
local show_console = true -- displays messages from crow on-screen


-- global state
b = include('lib/boughs')
draw = include('lib/draw')
local bowerypath = norns.state.path .. "crow/"
local scripts = {}
local script_count = 0
local selected_script = 0 -- none
local current_script = 0 -- none
local show_description = false
local console = ""


function init()
  scripts = util.scandir(bowerypath)
  if #scripts == 0 then
    print 'bowery not found. git submodule update?'
    --os.execute "git submodule update --init --recursive"
  else
    scripts = b.filter( b.is_luafile, scripts ) -- remove README etc
    script_count = #scripts -- optimization
  end
  crow.receive = function(s) console = s; redraw() end -- capture plain crow responses to console
  redraw()
end


function key(n,z)
  if n==1 and z==1 then
    console = "" -- clear console
    crow.loadscript(scripts[selected_script]) -- searches crow/ subfolder, then dust/code/
    current_script = selected_script
    redraw()
  end
end


function enc(n,z)
  if n==1 then
    selected_script = util.clamp(selected_script + z, 1, script_count)
    show_description = true
    redraw()
  end
end


function redraw()
  screen.clear()
  screen.line_width(1)

  draw.script_selection( scripts, selected_script, current_script )
  if show_description then
    draw.script_describe( scripts[selected_script] )
    show_description = false -- only display once
  end
  if show_console then
    draw.console( console )
  end
  screen.update()
end