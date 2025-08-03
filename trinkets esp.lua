-- Create UI elements for font, color, and distance selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white
local distance_combo = ui.new_combo("Max Distance (m)", {"100", "250", "500", "1000"})

-- Ensure UI elements are visible
font_combo:set_visible(true)
color_picker:set_visible(true)
distance_combo:set_visible(true)

-- Main paint callback to render trinket labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    if not local_player then return end -- Exit if no local player
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    if not player_model then return end -- Exit if no player model
    
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    if not humanoid_root then return end -- Exit if no HumanoidRootPart
    
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    if not player_pos then return end -- Exit if no position
    
    -- Navigate to Workspace > Debris > SpawnedItems
    local workspace = globals.workspace()
    if not workspace then return end -- Exit if no workspace
    
    local debris = workspace:FindChild("Debris")
    if not debris then return end -- Exit if no Debris folder
    
    local spawned_items = debris:FindChild("SpawnedItems")
    if not spawned_items then return end -- Exit if no SpawnedItems folder
    
    -- Get all MeshParts in the SpawnedItems folder
    local items = spawned_items:Children()
    if not items then return end -- Exit if no items
    
    -- Get selected font, color, and max distance
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    local max_distance = tonumber(distance_combo:get() + 1) * 100 -- Maps 0-3 to 100, 250, 500, 1000
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each item
    for _, item in ipairs(items) do
        if item:ClassName() == "MeshPart" then
            local item_pos = item:Primitive():GetPartPosition()
            if item_pos then
                -- Calculate distance from player to item
                local distance = math.sqrt(
                    (player_pos.x - item_pos.x)^2 +
                    (player_pos.y - item_pos.y)^2 +
                    (player_pos.z - item_pos.z)^2
                )
                
                -- Only render if within max distance
                if distance <= max_distance then
                    local screen_pos = utils.world_to_screen(item_pos)
                    if screen_pos then
                        -- Get MeshPart name
                        local item_name = item:Name()
                        local distance_text = string.format("%dm", math.floor(distance))
                        
                        -- Measure text sizes for centering workaround
                        local item_text_size = render.measure_text(item_name, font_index)
                        local distance_text_size = render.measure_text(distance_text, font_index)
                        
                        -- Calculate offsets for centering
                        local item_offset_x = item_text_size.x / 2
                        local distance_offset_x = distance_text_size.x / 2
                        local vertical_spacing = item_text_size.y + 2
                        
                        -- Draw MeshPart name text
                        render.text(
                            screen_pos.x - item_offset_x,
                            screen_pos.y - item_text_size.y,
                            item_name,
                            r, g, b, a,
                            "os",
                            font_index
                        )
                        
                        -- Draw distance text below item name
                        render.text(
                            screen_pos.x - distance_offset_x,
                            screen_pos.y - item_text_size.y + vertical_spacing,
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

end)
