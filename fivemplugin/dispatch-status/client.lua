-- client.lua
-- This script runs on every player's computer to draw the text on the screen.

-- CONFIGURATION --
-- You can change the position of the text on the screen here.
-- Values are percentages (0.0 to 1.0).
local position = {
    x = 0.96, -- 0.96 is far right
    y = 0.98  -- 0.98 is very bottom
}
-- END CONFIGURATION --

local dispatchStatus = "Dispatch : Inactive" -- Default status
local showText = true -- We'll always show it

-- Listen for the update event from the server
RegisterNetEvent('dispatchStatus:update')
AddEventHandler('dispatchStatus:update', function(newStatus)
    dispatchStatus = newStatus
end)

-- This function is a helper to draw text easily
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

-- This is the main loop that runs forever to draw the text
Citizen.CreateThread(function()
    while true do
        -- We wait 0ms, which means this runs every frame.
        Citizen.Wait(0)

        if showText then
            -- Set up the text properties
            SetTextFont(4) -- Chalet London font
            SetTextProportional(1)
            SetTextScale(0.0, 0.4) -- Size
            
            -- Set the color based on the status
            if dispatchStatus == "Dispatch : Active" then
                SetTextColour(115, 255, 115, 255) -- Green
            else
                SetTextColour(255, 115, 115, 255) -- Red
            end
            
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(dispatchStatus)
            
            -- Draw the text at the configured position
            DrawText(position.x - 0.1, position.y - 0.02)
        end
    end
end)
