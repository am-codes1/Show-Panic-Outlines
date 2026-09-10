PanicOutlinesMod = PanicOutlinesMod or {}
PanicOutlinesMod.panicking = {}

function PanicOutlinesMod._begin_outline()
  Hooks:PostHook(CopMovement, "on_suppressed", "showpanicoutlines_begin_outline_id",
    function (self, state)
      local spo = PanicOutlinesMod
      if state == "panic" then
        if self._suppression.transition then
          local duration = self._suppression.transition.duration
          local start_t = self._suppression.transition.start_t
          local next_upd_t = self._suppression.transition.next_upd_t
          -- local msg = tostring(duration) .. " | " .. tostring(start_t) .. " | " .. tostring(next_upd_t)
          -- spo.chat(msg)
        end
        spo.set_contour(self._unit, true)
      else
        spo.set_contour(self._unit)
      end
    end
  )
end

function PanicOutlinesMod.begin_outline()
  if not Network:is_server() then
    return
  end

  Hooks:PostHook(CopBrain, "on_suppressed", "panicoutlines_host_id",
    function (self, state)
      local pom = PanicOutlinesMod
      pom.check_panic(self._unit, state)
    end
  )
end


function PanicOutlinesMod.new_begin_outline()
  if Network:is_server() then
    -- PanicOutlinesMod.chat("is server")
    return
  end

  Hooks:PostHook(ClientNetworkSession, "send_to_host", "panicoutlines_client_id",
    function (_, func, unit, sync_amount)
      if func == "suppression" then
        local state = sync_amount == 16 and "panic" or sync_amount == 1 and false
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
    managers.chat:_receive_message(1,"SPO DEBUG", msg, Color.yellow)
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

function PanicOutlinesMod.action_request()
  Hooks:PostHook(CopMovement, "action_request", "panicoutlinesmod_action_request_id",
    function (self, action_desc)
      local action = "suppressed_fumble_still"

      if action_desc.variant and type(action_desc.variant) == "string" and action_desc.variant == 1 then
        PanicOutlinesMod.add_to_db(self._unit, true)
      else
        PanicOutlinesMod.add_to_db(self._unit, false)
      end
    end
  )
end

if RequiredScript == "lib/units/enemies/cop/copmovement" then
  PanicOutlinesMod.action_request()
elseif RequiredScript == "lib/managers/enemymanager" then
  PanicOutlinesMod.enemy_died()
end