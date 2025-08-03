-- Create UI elements for toggles, font, color, and max distance selection
local vehicle_esp_toggle = ui.new_checkbox("Enable Vehicle ESP")
local corpse_esp_toggle = ui.new_checkbox("Enable Corpse ESP")
local zombie_esp_toggle = ui.new_checkbox("Enable Zombie ESP (Laggy)")
local zombie_corpse_esp_toggle = ui.new_checkbox("Enable Zombie Corpse ESP")
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white
local max_distance_combo = ui.new_combo("Max ESP Distance", {"1000m", "2000m", "5000m", "10000m"})

-- Main paint callback to render ESP labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    if not local_player then return end

    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    if not player_model then return end

    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    if not humanoid_root then return end

    local player_pos = humanoid_root:Primitive():GetPartPosition()
    if not player_pos then return end

    -- Get selected font, color, and max distance
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    local max_distance_index = max_distance_combo:get() -- 0-based index
    local max_distances = {1000, 2000, 5000, 10000} -- Corresponding distances in meters
    local max_distance = max_distances[max_distance_index + 1] -- Convert to 1-based for table

    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)

    -- Get workspace
    local workspace = globals.workspace()
    if not workspace then return end

    -- Vehicle ESP
    if vehicle_esp_toggle:get() then
        local vehicles_folder = workspace:FindChild("Vehicles")
        if vehicles_folder then
            local vehicles = vehicles_folder:Children()
            for _, vehicle in ipairs(vehicles) do
                if vehicle:ClassName() == "Model" then
                    local base_part = vehicle:FindChild("Base")
                    if base_part and base_part:ClassName() == "Part" then
                        local vehicle_pos = base_part:Primitive():GetPartPosition()
                        if vehicle_pos then
                            -- Calculate distance from player to vehicle
                            local distance = math.sqrt(
                                (player_pos.x - vehicle_pos.x)^2 +
                                (player_pos.y - vehicle_pos.y)^2 +
                                (player_pos.z - vehicle_pos.z)^2
                            )

                            -- Check if vehicle is within max distance
                            if distance <= max_distance then
                                -- Convert 3D position to 2D screen coordinates
                                local screen_pos = utils.world_to_screen(vehicle_pos)
                                if screen_pos then
                                    -- Text to display (vehicle name)
                                    local vehicle_name = vehicle:Name()
                                    local distance_text = string.format("%dm", math.floor(distance))

                                    -- Measure text sizes for centering workaround
                                    local vehicle_text_size = render.measure_text(vehicle_name, font_index)
                                    local distance_text_size = render.measure_text(distance_text, font_index)

                                    -- Calculate offsets for centering
                                    local vehicle_offset_x = vehicle_text_size.x / 2
                                    local distance_offset_x = distance_text_size.x / 2
                                    local vertical_spacing = vehicle_text_size.y + 2

                                    -- Draw vehicle name text
                                    render.text(
                                        screen_pos.x - vehicle_offset_x,
                                        screen_pos.y - vehicle_text_size.y,
                                        vehicle_name,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )

                                    -- Draw distance text below vehicle name
                                    render.text(
                                        screen_pos.x - distance_offset_x,
                                        screen_pos.y - vehicle_text_size.y + vertical_spacing,
                                        distance_text,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Corpse ESP (Player Corpses)
    if corpse_esp_toggle:get() then
        local corpses_folder = workspace:FindChild("Corpses")
        if corpses_folder then
            local corpses = corpses_folder:Children()
            for _, corpse in ipairs(corpses) do
                if corpse:ClassName() == "Model" and not string.match(corpse:Name(), "^Infected") then
                    local humanoid_root_part = corpse:FindChild("HumanoidRootPart")
                    if humanoid_root_part and humanoid_root_part:ClassName() == "Part" then
                        local corpse_pos = humanoid_root_part:Primitive():GetPartPosition()
                        if corpse_pos then
                            -- Calculate distance from player to corpse
                            local distance = math.sqrt(
                                (player_pos.x - corpse_pos.x)^2 +
                                (player_pos.y - corpse_pos.y)^2 +
                                (player_pos.z - corpse_pos.z)^2
                            )

                            -- Check if corpse is within max distance
                            if distance <= max_distance then
                                -- Convert 3D position to 2D screen coordinates
                                local screen_pos = utils.world_to_screen(corpse_pos)
                                if screen_pos then
                                    -- Text to display (corpse name)
                                    local corpse_name = corpse:Name()
                                    local distance_text = string.format("%dm", math.floor(distance))

                                    -- Measure text sizes for centering workaround
                                    local corpse_text_size = render.measure_text(corpse_name, font_index)
                                    local distance_text_size = render.measure_text(distance_text, font_index)

                                    -- Calculate offsets for centering
                                    local corpse_offset_x = corpse_text_size.x / 2
                                    local distance_offset_x = distance_text_size.x / 2
                                    local vertical_spacing = corpse_text_size.y + 2

                                    -- Draw corpse name text
                                    render.text(
                                        screen_pos.x - corpse_offset_x,
                                        screen_pos.y - corpse_text_size.y,
                                        corpse_name,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )

                                    -- Draw distance text below corpse name
                                    render.text(
                                        screen_pos.x - distance_offset_x,
                                        screen_pos.y - corpse_text_size.y + vertical_spacing,
                                        distance_text,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Zombie ESP
    if zombie_esp_toggle:get() then
        local zombies_folder = workspace:FindChild("Zombies")
        if zombies_folder then
            local zombies = zombies_folder:Children()
            for _, zombie in ipairs(zombies) do
                if zombie:ClassName() == "Model" then
                    local humanoid_root_part = zombie:FindChild("HumanoidRootPart")
                    if humanoid_root_part and humanoid_root_part:ClassName() == "Part" then
                        local zombie_pos = humanoid_root_part:Primitive():GetPartPosition()
                        if zombie_pos then
                            -- Calculate distance from player to zombie
                            local distance = math.sqrt(
                                (player_pos.x - zombie_pos.x)^2 +
                                (player_pos.y - zombie_pos.y)^2 +
                                (player_pos.z - zombie_pos.z)^2
                            )

                            -- Check if zombie is within max distance
                            if distance <= max_distance then
                                -- Convert 3D position to 2D screen coordinates
                                local screen_pos = utils.world_to_screen(zombie_pos)
                                if screen_pos then
                                    -- Text to display (zombie name)
                                    local zombie_name = zombie:Name()
                                    local distance_text = string.format("%dm", math.floor(distance))

                                    -- Measure text sizes for centering workaround
                                    local zombie_text_size = render.measure_text(zombie_name, font_index)
                                    local distance_text_size = render.measure_text(distance_text, font_index)

                                    -- Calculate offsets for centering
                                    local zombie_offset_x = zombie_text_size.x / 2
                                    local distance_offset_x = distance_text_size.x / 2
                                    local vertical_spacing = zombie_text_size.y + 2

                                    -- Draw zombie name text
                                    render.text(
                                        screen_pos.x - zombie_offset_x,
                                        screen_pos.y - zombie_text_size.y,
                                        zombie_name,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )

                                    -- Draw distance text below zombie name
                                    render.text(
                                        screen_pos.x - distance_offset_x,
                                        screen_pos.y - zombie_text_size.y + vertical_spacing,
                                        distance_text,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Zombie Corpse ESP
    if zombie_corpse_esp_toggle:get() then
        local corpses_folder = workspace:FindChild("Corpses")
        if corpses_folder then
            local corpses = corpses_folder:Children()
            for _, corpse in ipairs(corpses) do
                if corpse:ClassName() == "Model" and string.match(corpse:Name(), "^Infected") then
                    local humanoid_root_part = corpse:FindChild("HumanoidRootPart")
                    if humanoid_root_part and humanoid_root_part:ClassName() == "Part" then
                        local corpse_pos = humanoid_root_part:Primitive():GetPartPosition()
                        if corpse_pos then
                            -- Calculate distance from player to corpse
                            local distance = math.sqrt(
                                (player_pos.x - corpse_pos.x)^2 +
                                (player_pos.y - corpse_pos.y)^2 +
                                (player_pos.z - corpse_pos.z)^2
                            )

                            -- Check if corpse is within max distance
                            if distance <= max_distance then
                                -- Convert 3D position to 2D screen coordinates
                                local screen_pos = utils.world_to_screen(corpse_pos)
                                if screen_pos then
                                    -- Text to display (corpse name)
                                    local corpse_name = corpse:Name()
                                    local distance_text = string.format("%dm", math.floor(distance))

                                    -- Measure text sizes for centering workaround
                                    local corpse_text_size = render.measure_text(corpse_name, font_index)
                                    local distance_text_size = render.measure_text(distance_text, font_index)

                                    -- Calculate offsets for centering
                                    local corpse_offset_x = corpse_text_size.x / 2
                                    local distance_offset_x = distance_text_size.x / 2
                                    local vertical_spacing = corpse_text_size.y + 2

                                    -- Draw corpse name text
                                    render.text(
                                        screen_pos.x - corpse_offset_x,
                                        screen_pos.y - corpse_text_size.y,
                                        corpse_name,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )

                                    -- Draw distance text below corpse name
                                    render.text(
                                        screen_pos.x - distance_offset_x,
                                        screen_pos.y - corpse_text_size.y + vertical_spacing,
                                        distance_text,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end)
