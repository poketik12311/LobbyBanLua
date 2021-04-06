local nextAttack = 0
local nextShotSecondary = 0
local nextShot = 0
local ref_doubletap = ui.reference("RAGE", "Other", "Double Tap")
local ref_baim = ui.reference("RAGE", "Other", "Prefer body aim")
local function DTbaim(ctx)
	local local_player = entity.get_local_player()
	if local_player == nil then
		return
	end
	if not entity.is_alive(local_player) then
		return
	end
	local active_weapon = entity.get_prop(local_player, "m_hActiveWeapon")		
	if active_weapon == nil then
		return
	end	
    nextAttack = entity.get_prop(local_player,"m_flNextAttack") 
	nextShot = entity.get_prop(active_weapon,"m_flNextPrimaryAttack")
	nextShotSecondary = entity.get_prop(active_weapon,"m_flNextSecondaryAttack")	
	if nextAttack == nil or nextShot == nil or nextShotSecondary == nil then
		return
	end
	nextAttack = nextAttack + 0.5
	nextShot = nextShot + 0.5
	nextShotSecondary = nextShotSecondary + 0.5
	if ui.get(ref_doubletap) then
		if math.max(nextShot,nextShotSecondary) < nextAttack then -- swapping
			if nextAttack - globals.curtime() > 0.00 then
				ui.set(ref_baim, false)
			else
				ui.set(ref_baim, true)
			end
		else -- shooting or just shot	
			if math.max(nextShot,nextShotSecondary) - globals.curtime() > 0.00  then
				ui.set(ref_baim, false)
			else
				if math.max(nextShot,nextShotSecondary) - globals.curtime() < 0.00  then
					ui.set(ref_baim, true)
				end
			end
		end
	end
end
