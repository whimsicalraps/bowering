--- bowering
-- run crow scripts from the
-- bowery collection.
--
-- E1: select script
-- K1: (hold) load script
--
-- more soon ^^

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
local selected_param = 0 -- none
local console = ""


function init()
  scripts = util.scandir(bowerypath)
  if #scripts == 0 then
    print 'bowery not found. git submodule update?'
    
  else
    scripts = b.filter( b.is_luafile, scripts ) -- remove README etc
    script_count = #scripts -- optimization
  end
  -- crow.receive = function(s) console = s; redraw() end -- capture plain crow responses to console
  function crow.public.ready() redraw() end
  function crow.public.change() redraw() end
  redraw()
end


function key(n,z)
  if n==1 and z==1 then
    console = "" -- clear console
    -- overloaded loadscript that discovers public params after load
    crow.public.loadscript(scripts[selected_script]) -- searches crow/ subfolder, then dust/code/
    current_script = selected_script
    redraw()
  end
end


function enc(n,z)
  if n==1 then -- select script
    selected_script = util.clamp(selected_script + z, 1, script_count)
    show_description = true
  elseif n==2 then -- select param
    selected_param = util.wrap( selected_param + z, 1, crow.public.get_count() )
  elseif n==3 then -- set param
    crow.public.delta(selected_param, z)
  end
  redraw()
end


function redraw()
  screen.clear()
  screen.line_width(1)

  draw.script_selection( scripts, selected_script, current_script )
  if show_description then
    draw.script_describe( scripts[selected_script] )
    show_description = false -- only display once
  end
  draw.public_params( crow.public, selected_param )
  if show_console then
    draw.console( console )
  end
  screen.update()
end
