local executed = false

cheat.set_callback("paint", function()
    print("Debug: Paint callback triggered")
    if executed then
        print("Debug: Script already executed, skipping")
        return
    end

    local place_id = globals.place_id()
    print("Debug: Place ID = " .. (place_id or "nil"))
    if not place_id then
        print("Error: Not in a game. Please join a game to load the script.")
        return
    end

    local mapping_url = "https://raw.githubusercontent.com/deanoncc/skibididopdop/refs/heads/main/ids.json"

    print("Debug: Fetching mapping from " .. mapping_url)
    http.get(mapping_url, function(response)
        print("Debug: Mapping response received, length = " .. (#response or 0))
        if not response or response == "" then
            print("Error: Failed to fetch script mapping or empty response.")
            return
        end

        local mapping = json.parse(response)
        print("Debug: JSON parsing result = " .. (mapping and "success" or "failed"))
        if not mapping then
            print("Error: Failed to parse script mapping.")
            return
        end

        local script_url = mapping[tostring(place_id)]
        print("Debug: Script URL for Place ID " .. place_id .. " = " .. (script_url or "nil"))
        if not script_url then
            print("Error: Game with Place ID " .. place_id .. " is not supported.")
            return
        end

        print("Debug: Fetching script from " .. script_url)
        http.get(script_url, function(script)
            print("Debug: Script response received, length = " .. (#script or 0))
            if not script or script == "" then
                print("Error: Failed to fetch script for Place ID " .. place_id .. ".")
                return
            end

            local func, err = utils.loadstring(script)
            print("Debug: Loadstring result = " .. (func and "success" or "failed"))
            if not func then
                print("Error: Failed to load script - " .. (err or "Unknown error"))
                return
            end

            local success, result = pcall(func)
            print("Debug: Script execution result = " .. (success and "success" or "failed"))
            if success then
                print("Success: Script for Place ID " .. place_id .. " loaded and executed.")
            else
                print("Error: Script execution failed - " .. (result or "Unknown error"))
            end
        end)
    end)

    executed = true
    print("Debug: Executed flag set to true")
end)
