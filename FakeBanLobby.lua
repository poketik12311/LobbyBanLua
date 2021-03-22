local ui_get = ui.get
local console_cmd = client.exec

local auto_buy_awp = ui.new_checkbox("MISC", "Miscellaneous", "Auto buy awp")
local auto_buy_scar = ui.new_checkbox("MISC", "Miscellaneous", "Auto buy scar-20/g3sg1")
local auto_buy_scout = ui.new_checkbox("MISC", "Miscellaneous", "Auto buy ssg-08")
local auto_buy_nades = ui.new_checkbox("MISC", "Miscellaneous", "Auto buy nades/defuser/kevlar")

local function on_round_prestart(e)
    if ui_get(auto_buy_nades) then
        console_cmd("buy hegrenade")
        console_cmd("buy smokegrenade")
        console_cmd("buy molotov")
        console_cmd("buy incgrenade")
        console_cmd("buy vesthelm")
        console_cmd("buy defuser")
        console_cmd("say bought nades and armor!")
    end

    if ui_get(auto_buy_awp) then
        console_cmd("buy awp")
        console_cmd("say bought awp!")
        
    elseif ui_get(auto_buy_scar) then
        console_cmd("buy g3sg1")
        console_cmd("buy scar20")
        console_cmd("say bought auto!")
    elseif ui_get(auto_buy_scout) then
        console_cmd("buy ssg08")
        console_cmd("say bought scout!")
  end

end

client.set_event_callback("round_prestart", on_round_prestart)
