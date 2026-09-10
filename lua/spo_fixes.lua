PanicOutlinesMod = PanicOutlinesMod or {}

local count = 0
--#region Testing TdlQ's Panic Fix
function PanicOutlinesMod.action_complete_clbk_override()
  local is_client = Network and not Network:is_server()
  local is_FSS    = false -- need to check for FSS

  if is_client then
    return
  end

  if (count < 5) and action_expired then
    -- IF action_expired, then action_expired() returns false
    -- if not, then look higher up for what causes failure
    count = count + 1
    PanicOutlinesMod.chat("we're inside")
  end
  function CopBrain:action_complete_clbk(action)
    -- if not action.itr_fake_complete then
      local pom = PanicOutlinesMod
      local add = false
      local is_change = true

      local action_desc = action._action_desc
      
      if action_desc and action_desc.variant and action_desc.variant:find('e_so_sup_fumble_inplace') == 1 then
        local u_mov = self._unit:movement()
        count = count + 1
        
        is_change = false
        if u_mov._action_common_data.is_suppressed and action.expired and action:expired() then
          
          local allowed_fumbles = {'e_so_sup_fumble_inplace_3'}

          if u_mov._suppression.transition then
            local mvec3_set = mvector3.set
            local mvec3_mul = mvector3.multiply
            local mvec3_add = mvector3.add
            local temp_vec1 = Vector3()
            local temp_vec2 = Vector3()
            ----
            local vec_from = temp_vec1
            local vec_to = temp_vec2
            local ray_params = {
              allow_entry = false,
              trace = true,
              tracker_from = u_mov:nav_tracker(),
              pos_from = vec_from,
              pos_to = vec_to
            }

            local m_pos = u_mov:m_pos()
            local m_rot = u_mov:m_rot()

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:y())
            mvec3_mul(vec_to, -100)
            mvec3_add(vec_to, m_pos)
            local allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_1')
            end

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:x())
            mvec3_mul(vec_to, 200)
            mvec3_add(vec_to, m_pos)
            allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_2')
            end

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:x())
            mvec3_mul(vec_to, -200)
            mvec3_add(vec_to, m_pos)
            allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_4')
            end
          end
  
          local action_desc = {
            body_part = 1,
            type = 'act',
            variant = allowed_fumbles[math.random(#allowed_fumbles)],
            blocks = {
              action = -1,
              walk = -1
            }
          }
          u_mov:action_request(action_desc)
        end
        -- add = true
      end
      if is_change then
        pom.add_to_db(self._unit, add)
      end
    -- end
  
    self._current_logic.action_complete_clbk(self._logic_data, action)
  end
end

function PanicOutlinesMod.husk_action_complete_clbk_override()
  local is_allowed  = PanicOutlinesMod._settings.panic_fix_client
  local is_host     = Network:is_server()
  local is_invalid  = not is_allowed or is_host

  if is_invalid then
    return
  end

  function HuskCopBrain:action_complete_clbk(action)
    -- if not action.itr_fake_complete then
      local pom = PanicOutlinesMod
      local add = false
      local is_change = true

      local action_desc = action._action_desc
      local is_not_number = action_desc and type(action_desc.variant) ~= "number"

      if action_desc and action_desc.variant and is_not_number and action_desc.variant:find('e_so_sup_fumble_inplace') == 1 then
        local u_mov = self._unit:movement()
        count = count + 1
        
        is_change = false
        if u_mov._action_common_data.is_suppressed and action.expired and action:expired() then
          
          local allowed_fumbles = {'e_so_sup_fumble_inplace_3'}

          if u_mov._suppression.transition then
            local mvec3_set = mvector3.set
            local mvec3_mul = mvector3.multiply
            local mvec3_add = mvector3.add
            local temp_vec1 = Vector3()
            local temp_vec2 = Vector3()
            ----
            local vec_from = temp_vec1
            local vec_to = temp_vec2
            local ray_params = {
              allow_entry = false,
              trace = true,
              tracker_from = u_mov:nav_tracker(),
              pos_from = vec_from,
              pos_to = vec_to
            }

            local m_pos = u_mov:m_pos()
            local m_rot = u_mov:m_rot()

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:y())
            mvec3_mul(vec_to, -100)
            mvec3_add(vec_to, m_pos)
            local allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_1')
            end

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:x())
            mvec3_mul(vec_to, 200)
            mvec3_add(vec_to, m_pos)
            allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_2')
            end

            mvec3_set(vec_from, m_pos)
            mvec3_set(vec_to, m_rot:x())
            mvec3_mul(vec_to, -200)
            mvec3_add(vec_to, m_pos)
            allow = not managers.navigation:raycast(ray_params)
            if allow then
              table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_4')
            end
          end
  
          local action_desc = {
            body_part = 1,
            type = 'act',
            variant = allowed_fumbles[math.random(#allowed_fumbles)],
            blocks = {
              action = -1,
              walk = -1
            }
          }
          u_mov:action_request(action_desc)
        end
        -- add = true
      end
      if is_change then
        pom.add_to_db(self._unit, add)
      end
    -- end
  
    if self._unit and self._unit.brain and self._unit:brain() then
      local ext_brain = self._unit:brain()
      -- self._current_logic.action_complete_clbk(self._logic_data, action)
      if ext_brain._current_logic then
        pom.chat("inside current_logic")
        ext_brain._current_logic.action_complete_clbk(self._logic_data, action)
      end
    end
  end
end

local idle_1 = {type = 'idle', body_part = 1}
local idle_2 = {type = 'idle', body_part = 2}
function PanicOutlinesMod._upd_actions_override()
  -- if true then
  --   return
  -- end
  function CopMovement:_upd_actions(t)

    local a_actions = self._active_actions
    local has_no_action = true
    for i_action = 1, 4 do
      local action = a_actions[i_action]
      if action then
        local action_update = action.update
        if action_update then
          action_update(action, t)
        end
        if not self._need_upd then
          local action_need_upd = action.need_upd
          if action_need_upd then
            self._need_upd = action_need_upd(action)
          end
        end
        local action_expired = action.expired
        if action_expired and action_expired(action) then
          a_actions[i_action] = false
          local action_on_exit = action.on_exit
          if action_on_exit then
            action_on_exit(action)
          end
          self._ext_brain:action_complete_clbk(action)
          self._ext_base:chk_freeze_anims()
          for i = 1, 4 do
            has_no_action = has_no_action and a_actions[i]
          end
        else
          has_no_action = nil
        end
      end
    end
    if has_no_action then
      self:action_request(idle_1)
    elseif not a_actions[1] and not a_actions[2] and not self:chk_action_forbidden('action') then
      self:action_request(a_actions[3] and idle_2 or idle_1)
    end
    self:_upd_stance(t)
    if not self._need_upd then
      local ext_anim = self._ext_anim
      if ext_anim.base_need_upd or ext_anim.upper_need_upd or self._stance.transition or self._action_common_data.is_suppressed or self._suppression.transition then
        self._need_upd = true
      end
    end
    -- managers.chat:_receive_message(1,"POMod", "inside", Color.yellow)
  end
end

function PanicOutlinesMod.on_suppressed()
  Hooks:PostHook(CopMovement, "on_suppressed", "panicoutlines_on_suppressed_id",
    function(self, state)
      if not state and self._ext_anim.act and self._ext_anim.fumble then
        self:action_request({type = 'idle', body_part = 1})
      end
    end
  )
end
--#endregion


if RequiredScript == "lib/units/enemies/cop/copbrain" then
  -- PanicOutlinesMod.fix_anim()
  PanicOutlinesMod.action_complete_clbk_override()
elseif RequiredScript == "lib/units/enemies/cop/copmovement" then
  PanicOutlinesMod._upd_actions_override()
  PanicOutlinesMod.on_suppressed()
elseif RequiredScript == "lib/units/enemies/cop/huskcopbrain" then
  PanicOutlinesMod.husk_action_complete_clbk_override()
end