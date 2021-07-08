--- bowering
-- v1 @trentgill
--
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
boughs = include('lib/boughs')
draw = include('lib/draw')

local BOWERYPATH = norns.state.path .. "crow/"
local scripts = {}
local script_count = 0
local selected_script = 0 -- none
local current_script = 0 -- none
-- local show_description = false
local selected_param = 0 -- none
local console = ""
local alt_param = false
local is_freeze = false
local viewall = false

local P = norns.crow.public


function init()
  scripts = util.scandir(BOWERYPATH)
  if #scripts == 0 then
    print 'bowery not found. check install. git submodule init?'
  else
    scripts = boughs.filter( boughs.is_luafile, scripts ) -- remove README etc
    script_count = #scripts -- optimization
  end
  -- crow.receive = function(s) console = s; redraw() end -- capture plain crow responses to console
  function P.change() redraw() end
  function P.discovered()
    print'discovered!'
    if viewall then crow.public.view.all() end -- enable viewing of all CV levels
    redraw()
  end
  redraw()
end


function key(n,z)
  if n==1 and z==1 then
    if selected_script > 0 then
      console = "" -- clear console
      if is_freeze and selected_script == current_script then
        P.freezescript(scripts[selected_script])
      else
        norns.crow.loadscript(scripts[selected_script])
      end
      current_script = selected_script
      redraw()
    end
  end
  if n==2 then
    is_freeze = (z==1) and true or false
    redraw()
  end
  if n==3 then alt_param = (z==1) and true or false end
  if is_freeze and alt_param and z==1 then crow.public.view.all() end
end


function enc(n,z)
  if n==1 then -- select script
    selected_script = util.clamp(selected_script + z, 1, script_count)
    -- show_description = true
  elseif n==2 then -- select param
    if selected_script > 0 then
      selected_param = util.wrap( selected_param + z, 1, P.get_count() )
    end
  elseif n==3 then -- set param
    if selected_param > 0 then
      P.delta(selected_param, z, alt_param)
    end
  end
  redraw()
end


function redraw()
  screen.clear()
  screen.line_width(1)

  draw.script_selection( scripts, selected_script, current_script, is_freeze )
  -- FIXME disabled script preview as it's unhelpful without a big overhaul
  -- see: https://github.com/monome/norns/pull/1362#issuecomment-842592147
  -- if show_description then
  --   draw.script_describe( scripts[selected_script] )
  --   show_description = false -- only display once
  -- end
  draw.public_params( P, selected_param )
  draw.public_views( P.viewing )
  if show_console then
    draw.console( console )
  end
  screen.update()
end