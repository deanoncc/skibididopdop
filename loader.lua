local executed = false

cheat.set_callback("paint", function()
    if executed then
        return
    end

    local place_id = globals.place_id()
    local place_id_str = tostring(place_id)
    if not place_id then
        print("Error: Not in a game. Please join a game to load the script.")
        executed = true
        return
    end

    local mapping_url = "https://raw.githubusercontent.com/deanoncc/skibididopdop/refs/heads/main/ids.json"
    http.get(mapping_url, function(response)
        if not response or response == "" then
            print("Error: Failed to fetch script mapping or empty response.")
            executed = true
            return
        end

        local mapping, parse_err = json.parse(response)
        if not mapping then
            print("Error: Failed to parse script mapping - " .. (parse_err or "Unknown error"))
            executed = true
            return
        end

        local script_url = mapping[place_id_str]
        if not script_url then
            print("Error: No script URL found for Place ID " .. place_id_str .. " in mapping.")
            executed = true
            return
        end

        http.get(script_url, function(script)
            if not script or script == "" then
                print("Error: Failed to fetch script or empty response for Place ID " .. place_id_str .. ".")
                executed = true
                return
            end

            local func, load_err = utils.loadstring(script)
            if not func then
                print("Error: Failed to load script - " .. (load_err or "Unknown error"))
                executed = true
                return
            end

            local success, result = pcall(func)
            if success then
                print("Success: Script for Place ID " .. place_id_str .. " loaded and executed.")
            else
            end
            executed = true
        end)
    end)

    executed = true
    print("Debug: Executed flag set to true")
end)
