--[[ It's been such a long time that I don't know if
    there's anything still useful here, so I'm just
    going to keep it until I can go over it when
    I have more time
]]--

PanicOutlinesMod = PanicOutlinesMod or {}
PanicOutlinesMod.panicking = {}

function PanicOutlinesMod._begin_outline()
  Hooks:PostHook(CopMovement, "on_suppressed", "showpanicoutlines_begin_outline_id",
    function (self, state)
      local spo = PanicOutlinesMod
      if state == "panic" then -- and not spo.panicking[self] then
        -- spo.panicking = self
        if self._suppression.transition then
          local duration = self._suppression.transition.duration
          local start_t = self._suppression.transition.start_t
          local next_upd_t = self._suppression.transition.next_upd_t
          local msg = tostring(duration) .. " | " .. tostring(start_t) .. " | " .. tostring(next_upd_t)
          spo.chat(msg)
        end
        spo.set_contour(self._unit, true)
      else
        spo.set_contour(self._unit)
      end
    end
  )
end

local time = 0
function PanicOutlinesMod.begin_outline()
  if not Network:is_server() then
    return
  end

  Hooks:PostHook(CopBrain, "on_suppressed", "panicoutlines_host_id",
    function (self, state)
      local pom = PanicOutlinesMod
      -- local id = self._unit:id()
      -- local is_in_db = pom.panicking[id]
      -- if tostring(state) ~= "true" then
      --   -- spo.chat(tostring(self._unit:id()))
      --   -- spo.chat(type(self._unit:id()))
      --   -- local key = self._unit.key and self._unit:key() or "no key found"
      --   -- for k, v in pairs(key) do          
      --     -- spo.chat(tostring(k) .. " | " .. tostring(v))
      --   -- end
      -- end
      -- PanicOutlinesMod.chat("inside on_suppressed")
      -- if not is_in_db and state == "panic" then
      --   PanicOutlinesMod.chat("inside state == \"panic\"")
      --   pom.panicking[id] = true
      --   time = os.time()
      --   pom.set_contour(self._unit, true)
      -- elseif is_in_db and state == false then
      --   local end_time = os.time() - time
      --   pom.chat(end_time)
      --   pom.set_contour(self._unit)
      --   pom.panicking[id] = nil
      -- end
      pom.check_panic(self._unit, state)
    end
  )
end


function PanicOutlinesMod.new_begin_outline()
  if Network:is_server() then
    PanicOutlinesMod.chat("is server")
    return
  end

  Hooks:PostHook(ClientNetworkSession, "send_to_host", "panicoutlines_client_id",
    function (_, func, unit, sync_amount)
      if func == "suppression" then
        local state = sync_amount == 16 and "panic" or sync_amount == 1 and false
        -- PanicOutlinesMod.chat(tostring(sync_amount))
        PanicOutlinesMod.check_panic(unit, state)
      end
    end
  )
end

function PanicOutlinesMod.enemy_died()
  Hooks:PreHook(EnemyManager, "on_enemy_died", "panicoutlines_enemy_died_id",
    function (_, dead_unit)
      local pom = PanicOutlinesMod

      pom.add_to_db(dead_unit)
    end
  )
end

function PanicOutlinesMod.chat(msg)
  msg = tostring(msg)
  local chat = managers.chat
  if chat then
    managers.chat:_receive_message(1,"DEBUG", msg, Color.yellow)
  else
    log(msg)
  end
end


function PanicOutlinesMod.set_contour(unit, add)
  local sync = PanicOutlinesMod._settings.sync
  local contour_color = "hostage_trade"
  if add then
    unit:contour():add(contour_color, sync)
  else
    unit:contour():remove(contour_color, sync)
  end
end

local count = 0
function PanicOutlinesMod.on_suppressed()
  Hooks:PostHook(CopMovement, "on_suppressed", "blahblah3x",
    function (self, state)
      -- PanicOutlinesMod.chat("inside on_suppressed")
      if not state and self._ext_anim.act and self._ext_anim.fumble then
        -- PanicOutlinesMod.chat("inside on_suppressed 1")
        -- self:action_request({type = 'idle', body_part = 1})
      end
      -- count = count + 1
      -- PanicOutlinesMod.chat(tostring(count))
      -- if action_desc.type == "act" then
      --   for k, v in pairs(action_desc.blocks) do
          -- ShowPanicOutlineMod.chat(tostring(k))
    --     end
        
    --   end
    end
  )
end

function PanicOutlinesMod.check_action_forbidden()
  if true then
    return
  end
  Hooks:PostHook(CopMovement,"chk_action_forbidden", "asfasfwerewr1",
    function (self,action_type)
      local t = TimerManager:game():time()
    
      for i_action, action in ipairs(self._active_actions) do
        if action and action.chk_block and action:chk_block(action_type, t) then
          -- ShowPanicOutlineMod.chat("INSIDE ACTION BLOCK" .. tostring(action_type))
          return true
        end
      end
    end
  )
end

function PanicOutlinesMod.add_to_db(unit, add)
  local id = unit:id()
  local pom = PanicOutlinesMod
  local is_change = false

  if add and not pom.panicking[id] then
    pom.panicking[id] = true
    is_change = true
  elseif not add and pom.panicking[id] then
    pom.panicking[id] = nil
    is_change = true
  end

  if is_change then
    pom.set_contour(unit, add)
  end

end

count = 0
function PanicOutlinesMod.action_request()
  Hooks:PostHook(CopMovement, "action_request", "panicoutlinesmod_action_request_id",
    function (self, action_desc)
      if action_desc.variant and type(action_desc.variant) == "string" and action_desc.variant:find("e_so_sup_fumble_inplace") == 1 then
        -- count = count + 1
        -- PanicOutlinesMod.chat("INSIDE ALEX: " .. tostring(count))
        PanicOutlinesMod.add_to_db(self._unit, true)
      else
        PanicOutlinesMod.add_to_db(self._unit, false)
      end
    end
  )
end

if RequiredScript == "lib/units/enemies/cop/copmovement" then
  -- PanicOutlinesMod.on_suppressed()
  -- PanicOutlinesMod.check_action_forbidden()
  PanicOutlinesMod.action_request()
elseif RequiredScript == "lib/units/enemies/cop/copbrain" then
  -- PanicOutlinesMod.begin_outline()
elseif RequiredScript == "lib/managers/enemymanager" then
  PanicOutlinesMod.enemy_died()
elseif RequiredScript == "lib/network/base/clientnetworksession" then
  -- PanicOutlinesMod.new_begin_outline()
end

--[[
  226: lib/units/beings/player/playerinventory

  
	if blueprint then
		setup_data.panic_suppression_skill = not managers.weapon_factory:has_perk("silencer", factory_name, blueprint) and managers.player:has_category_upgrade("player", "panic_suppression") or false
	end
]]