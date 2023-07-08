local mod = get_mod("blitzbar")

mod:io_dofile("/blitzbar/scripts/utils")

local UIViewHandler = mod:original_require("scripts/managers/ui/ui_view_handler")

local class_name = "HudElementblitzbar"
local filename = "blitzbar/scripts/mods/blitzbar/UI/UI_elements"

local function ui_hud_init_hook(func, self, elements, visibility_groups, params)
  if not table.find_by_key(elements, "class_name", class_name) then
    table.insert(elements, {
      class_name = class_name,
      filename = filename,
      use_hud_scale = true,
      visibility_groups = {
        "alive"
      }
    })
  end
  return func(self, elements, visibility_groups, params)
end

mod:add_require_path(filename)
mod:hook("UIHud", "init", ui_hud_init_hook)

local function recreate_hud()
  local ui_manager = Managers.ui
  if ui_manager then
    local hud = ui_manager._hud
    if hud then
      local player = Managers.player:local_player(1)
      local peer_id = player:peer_id()
      local local_player_id = player:local_player_id()
      local elements = hud._element_definitions
      local visibility_groups = hud._visibility_groups

      hud:destroy()
      ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
    end
  end
end

function mod.on_all_mods_loaded()
  recreate_hud()
end

function mod.on_unload(exit_game)
end

mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
  if view_name == "dmf_options_view" or view_name == "inventory_view" then
    recreate_hud()
  end
end)

mod:command("debug_scenegraph", "", function()
  mod.debugging = not mod.debugging
end)

local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")

mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
  if mod.debugging then
      UIRenderer.debug_render_scenegraph(self, ui_scenegraph)
  end
end)
