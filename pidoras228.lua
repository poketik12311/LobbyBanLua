local client_register_esp_flag, client_set_event_callback, client_update_player_list, entity_get_local_player, entity_get_players, entity_get_prop, entity_is_alive, math_sqrt, plist_get, plist_set, require, string_format, table_insert, ui_get, ui_new_checkbox, ui_new_hotkey, print, tostring = client.register_esp_flag, client.set_event_callback, client.update_player_list, entity.get_local_player, entity.get_players, entity.get_prop, entity.is_alive, math.sqrt, plist.get, plist.set, require, string.format, table.insert, ui.get, ui.new_checkbox, ui.new_hotkey, print, tostring

local hitgroup_names = { "generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
local player_memory = {}
local bit = require("bit")
local function getspeed(player_index)
    if not entity_is_alive(player_index) then return -2 end
    local velocity_x = entity_get_prop(player_index, "m_vecVelocity[0]")
    if not velocity_x then return -1 end
    local velocity_y = entity_get_prop(player_index, "m_vecVelocity[1]")
    local velocity_z = entity_get_prop(player_index, "m_vecVelocity[2]")
    return math_sqrt(velocity_x * velocity_x + velocity_y * velocity_y + velocity_z * velocity_z)
end

local fixing_delta = ui_new_checkbox("MISC", "Settings", "Prefer Lowdelta fix on Slowwalk")
local fixing_delta_key = ui_new_hotkey("MISC", "Settings", "Prefer Lowdelta fix on Slowwalk_key", true)

client_set_event_callback("aim_hit", function(e)

    if player_memory[e.target] and player_memory[e.target].lowdelta then
        print("[memory lowdelta] Hit with enabled lowdelta fix")
    end

end)

client_set_event_callback("aim_miss", function(e)
    if e.reason == "?" then
        local speed = getspeed(e.target)

        print(tostring("[memory lowdelta] Shot missed due to Resolver"))
        if not player_memory[e.target] then
            table_insert(player_memory, e.target, {
                misses = 1,
                lowdelta = false
        })

        if player_memory[e.target].lowdelta or ((ui_get(fixing_delta) and ui_get(fixing_delta_key) == true) and player_memory[i].misses == 0 and speed > 5 and speed < 110) then
            print("[memory lowdelta] Shot missed with lowdelta fix")
        end

        if hitgroup_names[e.hitgroup + 1] ~= "head" then return end

        elseif player_memory[e.target] then

            if player_memory[e.target].lowdelta == true then
                player_memory[e.target].lowdelta = false
                player_memory[e.target].misses = 0
                return
            end

            player_memory[e.target].misses = player_memory[e.target].misses + 1
            print(string_format("[memory lowdelta] Shot missed counter: %s", player_memory[e.target].misses))
            if player_memory[e.target].misses > 1 and not player_memory[e.target].lowdelta then
                player_memory[e.target].lowdelta = true
                print("[memory lowdelta] Enabled fix after 2x misses")
            end

        end
    end
end)



client_set_event_callback("setup_command", function()
    client_update_player_list()
    local local_index = entity_get_local_player()
    local enemies = entity_get_players(true)
    for itter = 1, #enemies do
        local i = enemies[itter]
        local skip = false
        if entity_is_alive(i) and not player_memory[i] then
            table_insert(player_memory, i, {
                misses = 0,
                lowdelta = false
            })
        end
        if player_memory[i] or (ui_get(fixing_delta) and ui_get(fixing_delta_key) == true)  and entity_is_alive(i) and not i == local_index then
            local flags = entity_get_prop(i, "m_fFlags")
            flags = bit.band(flags, bit.lshift(1, 0)) == 1 and bit.band(flags, bit.lshift(1, 1)) == 0
            local speed = getspeed(i)
            if (ui_get(fixing_delta) and ui_get(fixing_delta_key) == true)  then
                plist_set(i, "Force body yaw", (ui_get(fixing_delta) and ui_get(fixing_delta_key) == true)  and player_memory[i].misses == 0 and speed > 5 and speed < 110 and flags)
                plist_set(i, "Force body yaw value", 22)
                if (ui_get(fixing_delta) and ui_get(fixing_delta_key) == true)  and player_memory[i].misses == 0 and speed > 5 and speed < 110 then skip = true end
            end

            if player_memory[i].lowdelta ~= nil and not skip then
                plist_set(i, "Force body yaw", player_memory[i].lowdelta and speed < 110 and flags)
                plist_set(i, "Force body yaw value", 22)
            end
        end
    end
end)

client_register_esp_flag("is_elle_cute", 255, 255, 255, function(entity_index)
    if player_memory[entity_index] and plist_get(entity_index, "Force body yaw") then
        return true, "LOWDELTA"
    end
end)
