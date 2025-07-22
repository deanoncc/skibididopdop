local executed = false

cheat.set_callback("paint", function()
    if executed then
        return
    end

    local place_id = globals.place_id()
    if not place_id then
        print("not in game")
        return
    end

    local mapping_url = "https://raw.githubusercontent.com/deanoncc/skibididopdop/refs/heads/main/ids.json"
    http.get(mapping_url, function(response)
        if not response then
            print("failed to fetch script mapping.")
            return
        end

        local mapping = json.parse(response)
        if not mapping then
            print("failed to parse script mapping.")
            return
        end

        local script_url = mapping[tostring(place_id)]
        if not script_url then
            print("game with " .. place_id .. " is not supported.")
            return
        end

        http.get(script_url, function(script)
            if not script then
                print("failed to fetch script for Place ID " .. place_id .. ".")
                return
            end

            local func, err = utils.loadstring(script)
            if not func then
                print("failed to load script - " .. (err or "unknown error"))
                return
            end

            local success, result = pcall(func)
            if success then
                print("script for " .. place_id .. " loaded and executed.")
            else
                print("script execution failed - " .. (result or "unknown error"))
            end
        end)
    end)

    executed = true
end)
