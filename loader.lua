local executed = false

cheat.set_callback("paint", function()
    if executed then
        return
    end

    local place_id = globals.place_id()
    if not place_id then
        print("ur not in a game")
        return
    end

    local mapping_url = "https://raw.githubusercontent.com/deanoncc/skibididopdop/refs/heads/main/ids.json"
    http.get(mapping_url, nil, function(response)
        if not response then
            print("Error: Failed to fetch script mapping.")
            return
        end

        local mapping = json.parse(response)
        if not mapping then
            print("Error: Failed to parse script mapping.")
            return
        end

        local script_url = mapping[tostring(place_id)]
        if not script_url then
            print("Error: Game with Place ID " .. place_id .. " is not supported.")
            return
        end

        http.get(script_url, nil, function(script)
            if not script then
                print("Error: Failed to fetch script for Place ID " .. place_id .. ".")
                return
            end

            local func, err = utils.loadstring(script)
            if not func then
                print("Error: Failed to load script - " .. (err or "Unknown error"))
                return
            end

            local success, result = pcall(func)
            if success then
                print("Success: Script for Place ID " .. place_id .. " loaded and executed.")
            else
                print("Error: Script execution failed - " .. (result or "Unknown error"))
            end
        end)
    end)

    executed = true
end)
