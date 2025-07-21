-- Create UI for ESP mode, drawing method, and font selection
local esp_mode = ui.new_combo("ESP Mode", {"Off", "Username + Dot", "Dot", "Username"})
local draw_method = ui.new_combo("Draw Method", {"Through HullNode", "Through Turret", "Through Driver"})
local esp_color = ui.colorpicker("ESP Color", 1.0, 0.0, 0.0, 1.0) -- Default red
local font_type = ui.new_combo("Font Type", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})

-- Callback for rendering ESP
cheat.set_callback("paint", function()
    local mode = esp_mode:get()
    if mode == 0 then return end -- ESP is off

    local method = draw_method:get() -- 0: Through HullNode, 1: Through Turret, 2: Through Driver
    local selected_font = font_type:get() -- Maps to 0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased

    local workspace = globals.workspace()
    local vehicles = workspace:FindChild("Vehicles")
    if not vehicles then return end

    local actors = vehicles:Children()
    for _, actor in ipairs(actors) do
        local position = nil
        if method == 0 then -- Through HullNode
            local hull = actor:FindChild("Hull")
            if hull then
                local hull_model = hull:FindChildByClass("Model")
                if hull_model then
                    local hull_node = hull_model:FindChild("HullNode")
                    if hull_node then
                        local primitive = hull_node:Primitive()
                        if primitive then
                            position = primitive:GetPartPosition()
                        end
                    end
                end
            end
        elseif method == 1 then -- Through Turret
            local turret = actor:FindChild("Turret")
            if turret then
                local gyro_part = turret:FindChild("GyroPartHz")
                if gyro_part then
                    local primitive = gyro_part:Primitive()
                    if primitive then
                        position = primitive:GetPartPosition()
                    end
                end
            end
        elseif method == 2 then -- Through Driver
            local hull = actor:FindChild("Hull")
            if hull then
                local hull_model = hull:FindChildByClass("Model")
                if hull_model then
                    local inner_hull = hull_model:FindChild("Hull")
                    if inner_hull then
                        local driver1 = inner_hull:FindChild("Driver1")
                        local driver2 = inner_hull:FindChild("Driver2")
                        if driver1 and driver2 then
                            local primitive1 = driver1:Primitive()
                            local primitive2 = driver2:Primitive()
                            if primitive1 and primitive2 then
                                local pos1 = primitive1:GetPartPosition()
                                local pos2 = primitive2:GetPartPosition()
                                -- Calculate midpoint
                                position = Vector3((pos1.x + pos2.x) / 2, (pos1.y + pos2.y) / 2, (pos1.z + pos2.z) / 2)
                            end
                        elseif driver1 then
                            local primitive1 = driver1:Primitive()
                            if primitive1 then
                                position = primitive1:GetPartPosition()
                            end
                        elseif driver2 then
                            local primitive2 = driver2:Primitive()
                            if primitive2 then
                                position = primitive2:GetPartPosition()
                            end
                        end
                    end
                end
            end
        end

        if position then
            local screen_pos = utils.world_to_screen(position)
            -- Only render if the tank is on screen
            if screen_pos then
                local color = esp_color:get()
                local r, g, b, a = math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255), math.floor(color.a * 255)
                
                -- Render based on mode
                if mode == 1 then -- Username + Dot
                    render.circle(screen_pos.x, screen_pos.y, 5, r, g, b, a, 16)
                    
                    -- Get and render tank name
                    local actor_name = actor:Name()
                    local tank_name = actor_name:gsub("Chassis", "")
                    local text_size = render.measure_text(tank_name, selected_font)
                    local text_x = screen_pos.x - (text_size.x / 2)
                    local text_y = screen_pos.y - 15 -- Above the dot
                    render.text(text_x, text_y, tank_name, r, g, b, a, "o", selected_font)
                elseif mode == 2 then -- Dot
                    render.circle(screen_pos.x, screen_pos.y, 5, r, g, b, a, 16)
                elseif mode == 3 then -- Username
                    local actor_name = actor:Name()
                    local tank_name = actor_name:gsub("Chassis", "")
                    local text_size = render.measure_text(tank_name, selected_font)
                    local text_x = screen_pos.x - (text_size.x / 2)
                    local text_y = screen_pos.y - 15
                    render.text(text_x, text_y, tank_name, r, g, b, a, "o", selected_font)
                end
            end
        end
    end
end)