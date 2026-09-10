PanicOutlinesMod            = PanicOutlinesMod or {}
PanicOutlinesMod._save_path = SavePath .. "panicoutlines.txt"
PanicOutlinesMod._loc_path  = ModPath .. "loc/"
PanicOutlinesMod._menu_path = ModPath .. "menu/menu.txt"
PanicOutlinesMod._settings  = {
  sync              = true, -- sync outlines to other players
  panic_fix_client  = false -- fix animations as client
}

--#region Localization
function PanicOutlinesMod.get_loc_file()
  local lang = BLT.Localization:get_language().language
  local loc_file = PanicOutlinesMod._loc_path .. lang .. ".txt"

  if io.file_is_readable(loc_file) then
    return loc_file
  end

  return PanicOutlinesMod._loc_path .. "en.txt"
end

function PanicOutlinesMod.loc_init()
  Hooks:AddHook("LocalizationManagerPostInit", "panicoutlines_loc_post_init_id",
    function (self)
      local loc_file = PanicOutlinesMod.get_loc_file()

      self:load_localization_file(loc_file, true)
    end
  )
end
--#endregion

--#region Load / Save
function PanicOutlinesMod.load()
  local file = io.open(PanicOutlinesMod._save_path, "r")

  if file then
    local settings = json.decode(file:read())

    for k, v in pairs(settings) do
      PanicOutlinesMod._settings[k] = v
    end

    file:close()
  end
end

function PanicOutlinesMod.save()
  local file = io.open(PanicOutlinesMod._save_path, "w")

  if file then
    local settings = json.encode(PanicOutlinesMod._settings)

    file:write(settings)
    file:close()
  end
end
--#endregion

--#region Callback Handlers
function PanicOutlinesMod.toggle_clbk_handlers()
  local clbk = {
    sync              = "panicoutlines_sync_toggle_clbk",
    panic_fix_client  = "panicoutlines_panic_fix_client_toggle_clbk"
  }

  for k, v in pairs(clbk) do
    MenuCallbackHandler[v] = function(self, item)
      local value = item:value() == "on" and true or false

      PanicOutlinesMod._settings[k] = value
      PanicOutlinesMod.save()
    end
  end
end
--#endregion

--#region MenuManager
function PanicOutlinesMod.menu_init()
  Hooks:Add("MenuManagerInitialize", 'panicoutlines_menu_manager_init_id',
    function(menu_manager)
      local path = PanicOutlinesMod._menu_path
      local settings = PanicOutlinesMod._settings
  
      MenuHelper:LoadFromJsonFile(path, PanicOutlinesMod, settings)
    end
  )
end
--#endregion

function PanicOutlinesMod.init()
  PanicOutlinesMod.load()
  PanicOutlinesMod.loc_init()
  PanicOutlinesMod.toggle_clbk_handlers()
  PanicOutlinesMod.menu_init()
end

PanicOutlinesMod.init()
