local ui_get,ui_set,cl_log,delay_call,g_realtime,table_remove = ui.get,ui.set,client.log,client.delay_call,globals.realtime,table.remove
local ui_set_visible = ui.set_visible

local ref_target_hitbox = ui.reference("rage", "aimbot", "target hitbox") 
local ref_preferbaim = ui.reference("rage", "other", "prefer body aim")
local ref_enabled = ui.new_checkbox("rage", "other", "Remove head hitbox after X misses")
local ref_maxmisses = ui.new_slider("rage", "other", "Maximum misses", 1, 10)

local hitboxes = ui_get(ref_target_hitbox) 
local baimset = ui_get(ref_preferbaim)   	
local head_misses = 0  	

local function on_paint(ctx)

	ui_set_visible(ref_maxmisses, false)
		if ui_get(ref_enabled) then
		ui_set_visible(ref_maxmisses, true)
	return
	end
end

local function array_copy(tbl)
	local copy = {}
	for i=1,#tbl do copy[i] = tbl[i] end
	return copy
end

local function disable_head_hitboxes()

local hitboxes = ui_get(ref_target_hitbox) 
local baimset = ui_get(ref_preferbaim)   	
local old_hitboxes = array_copy(hitboxes) 
local old_baimset = baimset
	
	for i=1, #hitboxes do
		if hitboxes[i] == "Head" then
			table_remove(hitboxes, i) 
			break
		end
	end
	
	
	cl_log("Missed ".. ui_get(ref_maxmisses) .." head shots, removing head from target hitbox list") 

	ui_set(ref_target_hitbox, hitboxes) 
	ui_set(ref_preferbaim, baimset)

	delay_call(5, function()
		ui_set(ref_target_hitbox, old_hitboxes)
		ui_set(ref_preferbaim, old_baimset)
		head_misses = 0
	end)

end

local function aim_hit(e)
	head_misses = 0
end

local function aim_miss(e)
	if not ui_get(ref_enabled) then
		return
	end
	local group = e.hitgroup
	if group == 1 then
		head_misses = head_misses + 1

		if head_misses >= ui_get(ref_maxmisses) then
			disable_head_hitboxes()
			head_misses = 0
		end
	else
		head_misses = 0
	end
end

client.set_event_callback("paint", on_paint)
client.set_event_callback("aim_hit", aim_hit)
client.set_event_callback("aim_miss", aim_miss)
