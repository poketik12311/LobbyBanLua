local js = require("access_panorama")
local slider = ui.new_slider("LUA", "A", "Who to ban? Player:", 0, 9,0)
local function ban()
       js.eval([[PartyListAPI.SessionCommand("Game::ChatReportError", `run all xuid ${PartyListAPI.GetXuidByIndex(]].. ui.get(slider) .. [[)} error #SFUI_QMM_ERROR_X_VacBanned`);]])
end
ui.new_button("LUA", "A", "Ban Selected Player", ban)
