local ui_get = ui.get
local console_cmd = client.exec
local local_bullet_tracer = ui.new_checkbox("VISUALS", "Effects", "Local bullet tracer")

local function lbt_callback(val)
	if (ui_get(val)) then
		console_cmd("cl_predictweapons 0")
	else
		console_cmd("cl_predictweapons 1")
	end
end
