-- server.lua
-- This script runs on the server and handles the communication from the Discord bot.

-- CONFIGURATION --
-- This is a secret key to ensure that only your Discord bot can change the status.
-- MAKE THIS A LONG, RANDOM STRING and put the same one in your Discord bot's config.
local secretKey = "change-this-to-a-very-secret-key"

-- This is the port the server will listen on for requests from the bot.
-- Make sure this port is open on your server's firewall.
local listenPort = 30125 
-- END CONFIGURATION --


-- This variable will hold the current status server-side.
-- We'll default to "Inactive" when the server starts.
local currentStatus = "Dispatch : Inactive"

-- This is the core of the server-side logic. It creates an HTTP endpoint.
-- The Discord bot will send a POST request to http://YourServerIP:30125/updateStatus
RegisterNetEvent('http_request')
AddEventHandler('http_request', function(ip, method, path, headers, body, cb) {
    -- We only care about POST requests to our specific path
    if method == 'POST' and path == '/updateStatus' then
        -- Security check: Does the request have our secret key?
        if headers.authorization ~= secretKey then
            print('^1[DispatchStatus] Received request with invalid secret key from IP: ' .. ip)
            cb({ status = 'error', message = 'Invalid secret key' }, 401, {}) -- 401 Unauthorized
            return
        end

        -- Decode the JSON body sent by the bot
        local data = json.decode(body)

        if data and data.status then
            -- Update the status based on the bot's message
            if data.status == 'active' then
                currentStatus = "Dispatch : Active"
            elseif data.status == 'inactive' then
                currentStatus = "Dispatch : Inactive"
            end

            print('^2[DispatchStatus] Status updated to: ' .. currentStatus)

            -- Tell all clients to update their display. -1 means send to all players.
            TriggerClientEvent('dispatchStatus:update', -1, currentStatus)
            
            -- Respond to the bot that the request was successful
            cb({ status = 'ok', message = 'Status updated successfully' }, 200, {})
        else
            -- Respond with an error if the request was malformed
            cb({ status = 'error', message = 'Invalid request body' }, 400, {}) -- 400 Bad Request
        end
    end
})

-- When a new player joins, send them the current status so their display is correct.
AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    -- We wait a moment to ensure the player is fully loaded in.
    Citizen.Wait(1000)
    TriggerClientEvent('dispatchStatus:update', source, currentStatus)
end)

-- Start listening for HTTP requests on the specified port
if GetConvar('sv_lan', 'false') == 'false' then
    print('^2[DispatchStatus] Started listening for dispatch updates on port ' .. listenPort)
    SetHttpHandler(function(req, res)
        TriggerEvent('http_request', req.address, req.method, req.path, req.headers, req.body, function(responseBody, responseCode, responseHeaders)
            res.send(json.encode(responseBody), responseCode or 200, responseHeaders or {})
        end)
    end, listenPort)
else
    print('^3[DispatchStatus] Server is in LAN mode, HTTP listener not started.')
end
