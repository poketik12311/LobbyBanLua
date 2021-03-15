local client_eye_position, client_set_event_callback, client_userid_to_entindex, entity_get_local_player, globals_curtime, globals_tickcount, renderer_line, renderer_world_to_screen, pairs, ui_get, ui_new_checkbox, ui_new_color_picker, ui_new_slider, ui_set_callback, ui_set_visible = client.eye_position, client.set_event_callback, client.userid_to_entindex, entity.get_local_player, globals.curtime, globals.tickcount, renderer.line, renderer.world_to_screen, pairs, ui.get, ui.new_checkbox, ui.new_color_picker, ui.new_slider, ui.set_callback, ui.set_visible

-- Vectory library
local vector = require('vector')

-- Constants and variables
local shot_data = {}

-- Menu handling
local bullet_tracer     = ui_new_checkbox("LUA", "A", "Local bullet tracers")
local show_points       = ui_new_checkbox("LUA", "A", "Show points")
local tracer_color      = ui_new_color_picker("LUA", "A", "Tracer color", 255, 255, 255, 255)
local tracer_duration   = ui_new_slider("LUA", "A", "\n", 1, 10000, 3000, true, "s", 0.001)
local performance_scale = ui_new_slider("LUA", "A", "Performance scale", 1, 10, 4, true, "p/s", 1)

local function handle_menu()
    local state = ui_get(bullet_tracer)
    ui_set_visible(tracer_duration, state)
end

handle_menu()
ui_set_callback(bullet_tracer, handle_menu)

-- Game event handling
local function paint()
    if not ui_get(bullet_tracer) then
        return
    end
    local r, g, b = ui_get(tracer_color)
    for tick, data in pairs(shot_data) do
        -- UI variables
        local performance_value, show_points = ui_get(performance_scale), ui_get(show_points)

        -- Positions
        local origin_position, shot_position = vector(0, 0, 0), vector(0, 0, 0)

        -- Position comparisons
        local direction, distance = data.origin:to(data.destination), data.origin:dist(data.destination)
        for length = 0, distance, performance_value do
            local position = data.origin + direction * length
            local x, y = renderer_world_to_screen(position:unpack())

            if show_points then
                renderer.circle(x, y, 255, 255, 255, 255, 3, 0, 1)
            end

            if client.visible(position:unpack()) and x ~= nil and y ~= nil then
                if origin_position:length() == 0 then
                    origin_position = position
                else
                    shot_position = position
                end
            end
        end

        -- Screen positions
        local sx1, sy1 = renderer_world_to_screen(origin_position:unpack())
        local sx2, sy2 = renderer_world_to_screen(shot_position:unpack())

        -- Drawing
        if data.draw then
            if globals_curtime() >= data.duration then
                data.alpha = data.alpha - 1
            end
            if data.alpha <= 0 then
                data.draw = false
            end

            renderer_line(sx1, sy1, sx2, sy2, r, g, b, data.alpha)
        end
    end
end 

local function bullet_impact(e)
    if not ui_get(bullet_tracer) then
        return
    end
    if client_userid_to_entindex(e.userid) ~= entity_get_local_player() then
        return
    end
    local l = vector(client_eye_position())
    shot_data[globals_tickcount()] = {
        destination = vector(e.x, e.y, e.z),
        origin      = l,
        draw        = true,
        alpha       = 255,
        duration    = globals_curtime() + ui_get(tracer_duration) * 0.001
    }
end

local function round_start()
    if not ui_get(bullet_tracer) then
        return
    end
    shot_data = {}
end

client_set_event_callback("paint", paint)
client_set_event_callback("round_start", round_start)
client_set_event_callback("bullet_impact", bullet_impact)
