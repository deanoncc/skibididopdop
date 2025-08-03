-- Create UI elements for font, color, and max distance selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white
local max_distance_combo = ui.new_combo("Max Distance", {"100m", "250m", "500m", "1000m"}) -- New combo for max distance

-- Main paint callback to render chest labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position from HumanoidRootPart
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Get the workspace
    local workspace = globals.workspace()
    
    -- Get selected font, color, and max distance
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    local max_distance_index = max_distance_combo:get() -- 0-based index (0: 100m, 1: 250m, 2: 500m, 3: 1000m)
    
    -- Map combo index to actual distance values
    local max_distances = {100, 250, 500, 1000}
    local max_distance = max_distances[max_distance_index + 1] -- Adjust for 0-based index
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through chest numbers 1 to 53
    for i = 1, 53 do
        local chest_name = tostring(i) -- Chest names are numbers as strings
        local chest = workspace:FindChild(chest_name)
        
        if chest and chest:ClassName() == "Model" then
            -- Find the Base part in the chest model
            local base_part = chest:FindChild("Base")
            if base_part and base_part:ClassName() == "Part" then
                local chest_pos = base_part:Primitive():GetPartPosition()
                
                if chest_pos then
                    -- Calculate distance from player to chest
                    local distance = math.sqrt(
                        (player_pos.x - chest_pos.x)^2 +
                        (player_pos.y - chest_pos.y)^2 +
                        (player_pos.z - chest_pos.z)^2
                    )
                    
                    -- Only render if chest is within max distance
                    if distance <= max_distance then
                        -- Convert 3D position to 2D screen coordinates
                        local screen_pos = utils.world_to_screen(chest_pos)
                        if screen_pos then
                            -- Text to display
                            local chest_text = "Chest " .. chest_name
                            local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                            
                            -- Measure text sizes for centering workaround
                            local chest_text_size = render.measure_text(chest_text, font_index)
                            local distance_text_size = render.measure_text(distance_text, font_index)
                            
                            -- Calculate offsets for centering
                            local chest_offset_x = chest_text_size.x / 2
                            local distance_offset_x = distance_text_size.x / 2
                            local vertical_spacing = chest_text_size.y + 2 -- Small gap between texts
                            
                            -- Draw "Chest" text
                            render.text(
                                screen_pos.x - chest_offset_x, -- Centered x
                                screen_pos.y - chest_text_size.y, -- Above chest position
                                chest_text,
                                r, g, b, a, -- Use selected color
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                            
                            -- Draw distance text below "Chest"
                            render.text(
                                screen_pos.x - distance_offset_x, -- Centered x
                                screen_pos.y - chest_text_size.y + vertical_spacing, -- Below "Chest"
                                distance_text,
                                r, g, b, a, -- Use selected color
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                        end
                    end
                end
            end
        end
    end

end)
