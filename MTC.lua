-- Set up library path
package.path = package.path .. ";C:\\assembly\\libs\\?.lua"

-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white

-- Main paint callback to render vehicle labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Get selected font and color
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Navigate to Workspace > SpawnedVehicles
    local workspace = globals.workspace()
    local item_folder = workspace:FindChild("SpawnedVehicles")
    
    if item_folder then
        -- Get all vehicle models in SpawnedVehicles
        local vehicles = item_folder:Children()
        
        -- Iterate through each vehicle model
        for _, vehicle in ipairs(vehicles) do
            if vehicle:ClassName() == "Model" then
                -- Find the Hull model within the vehicle
                local hull = vehicle:FindChild("Hull")
                if hull then
                    -- Find the first Part or MeshPart in the Hull model
                    local hull_part = hull:FindChildByClass("Part") or hull:FindChildByClass("MeshPart")
                    if hull_part then
                        local vehicle_pos = hull_part:Primitive():GetPartPosition()
                        if vehicle_pos then
                            -- Calculate distance from player to vehicle
                            local distance = math.sqrt(
                                (player_pos.x - vehicle_pos.x)^2 +
                                (player_pos.y - vehicle_pos.y)^2 +
                                (player_pos.z - vehicle_pos.z)^2
                            )
                            
                            -- Convert 3D position to 2D screen coordinates
                            local screen_pos = utils.world_to_screen(vehicle_pos)
                            if screen_pos then
                                -- Text to display (use vehicle model name)
                                local vehicle_text = vehicle:Name()
                                local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                                
                                -- Measure text sizes for centering workaround
                                local vehicle_text_size = render.measure_text(vehicle_text, font_index)
                                local distance_text_size = render.measure_text(distance_text, font_index)
                                
                                -- Calculate offsets for centering
                                local vehicle_offset_x = vehicle_text_size.x / 2
                                local distance_offset_x = distance_text_size.x / 2
                                local vertical_spacing = vehicle_text_size.y + 2 -- Small gap between texts
                                
                                -- Draw vehicle name text
                                render.text(
                                    screen_pos.x - vehicle_offset_x, -- Centered x
                                    screen_pos.y - vehicle_text_size.y, -- Above vehicle position
                                    vehicle_text,
                                    r, g, b, a, -- Use selected color
                                    "os", -- Outline and shadow
                                    font_index -- Use selected font
                                )
                                
                                -- Draw distance text below vehicle name
                                render.text(
                                    screen_pos.x - distance_offset_x, -- Centered x
                                    screen_pos.y - vehicle_text_size.y + vertical_spacing, -- Below vehicle name
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
    end

end)
