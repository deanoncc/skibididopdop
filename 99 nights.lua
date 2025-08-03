-- Create UI elements
local items_esp_toggle = ui.new_checkbox("Items ESP")
local food_esp_toggle = ui.new_checkbox("Food ESP (Berry/Carrot)")
local chests_esp_toggle = ui.new_checkbox("Item Chests ESP")
local npc_esp_toggle = ui.new_checkbox("NPC ESP")
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white
local distance_combo = ui.new_combo("Max Distance (m)", {"100", "250", "500", "1000"})

-- Ensure UI elements are visible
items_esp_toggle:set_visible(true)
food_esp_toggle:set_visible(true)
chests_esp_toggle:set_visible(true)
npc_esp_toggle:set_visible(true)
font_combo:set_visible(true)
color_picker:set_visible(true)
distance_combo:set_visible(true)

-- Main paint callback to render ESP
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    if not local_player then return end -- Exit if no local player
    
    local player_model = local_player:ModelInstance()
    if not player_model then return end -- Exit if no player model
    
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    if not humanoid_root then return end -- Exit if no HumanoidRootPart
    
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    if not player_pos then return end -- Exit if no position
    
    -- Get selected font, color, and max distance
    local font_index = font_combo:get() -- 0-based index
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    local max_distance = tonumber(distance_combo:get() + 1) * 100 -- Maps 0-3 to 100, 250, 500, 1000
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    local workspace = globals.workspace()
    if not workspace then return end -- Exit if no workspace

    -- Items, Food, and Chests ESP
    if items_esp_toggle:get() or food_esp_toggle:get() or chests_esp_toggle:get() then
        local items_folder = workspace:FindChild("Items")
        if items_folder then
            local items = items_folder:Children()
            for _, item in ipairs(items) do
                if item:ClassName() == "Model" then
                    -- Check if item is food (Berry or Carrot), chest, or other
                    local is_food = (item:Name() == "Berry" or item:Name() == "Carrot")
                    local is_chest = (item:Name() == "Item Chest" or string.match(item:Name(), "^Item Chest2%[1-5%]$"))
                    -- Render if (non-food/non-chest and Items ESP enabled) or (food and Food ESP enabled) or (chest and Chests ESP enabled)
                    if (not is_food and not is_chest and items_esp_toggle:get()) or 
                       (is_food and food_esp_toggle:get()) or 
                       (is_chest and chests_esp_toggle:get()) then
                        -- Use primary part or first MeshPart/Part for position
                        local primary_part = item:FindChild("Handle") or item:Children()[1]
                        if primary_part and (primary_part:ClassName() == "MeshPart" or primary_part:ClassName() == "Part") then
                            local item_pos = primary_part:Primitive():GetPartPosition()
                            if item_pos then
                                local distance = math.sqrt(
                                    (player_pos.x - item_pos.x)^2 +
                                    (player_pos.y - item_pos.y)^2 +
                                    (player_pos.z - item_pos.z)^2
                                )
                                
                                if distance <= max_distance then
                                    local screen_pos = utils.world_to_screen(item_pos)
                                    if screen_pos then
                                        local item_name = item:Name()
                                        local distance_text = string.format("%dm", math.floor(distance))
                                        
                                        local item_text_size = render.measure_text(item_name, font_index)
                                        local distance_text_size = render.measure_text(distance_text, font_index)
                                        
                                        local item_offset_x = item_text_size.x / 2
                                        local distance_offset_x = distance_text_size.x / 2
                                        local vertical_spacing = item_text_size.y + 2
                                        
                                        -- Draw item name
                                        render.text(
                                            screen_pos.x - item_offset_x,
                                            screen_pos.y - item_text_size.y,
                                            item_name,
                                            r, g, b, a,
                                            "os",
                                            font_index
                                        )
                                        
                                        -- Draw distance
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
                        
                        -- 3D ESP for chests (single box for entire chest)
                        if is_chest and chests_esp_toggle:get() then
                            local chest_model = item:FindChild("Model")
                            if chest_model and chest_model:ClassName() == "Model" then
                                local chest_parts = chest_model:Children()
                                local min_pos = nil
                                local max_pos = nil
                                for _, part in ipairs(chest_parts) do
                                    if part:ClassName() == "Part" or part:ClassName() == "MeshPart" then
                                        local part_pos = part:Primitive():GetPartPosition()
                                        local part_size = part:Primitive():GetPartSize()
                                        if part_pos and part_size then
                                            local part_min = Vector3(part_pos.x - part_size.x / 2, part_pos.y - part_size.y / 2, part_pos.z - part_size.z / 2)
                                            local part_max = Vector3(part_pos.x + part_size.x / 2, part_pos.y + part_size.y / 2, part_pos.z + part_size.z / 2)
                                            if not min_pos then
                                                min_pos = Vector3(part_min.x, part_min.y, part_min.z)
                                                max_pos = Vector3(part_max.x, part_max.y, part_max.z)
                                            else
                                                min_pos.x = math.min(min_pos.x, part_min.x)
                                                min_pos.y = math.min(min_pos.y, part_min.y)
                                                min_pos.z = math.min(min_pos.z, part_min.z)
                                                max_pos.x = math.max(max_pos.x, part_max.x)
                                                max_pos.y = math.max(max_pos.y, part_max.y)
                                                max_pos.z = math.max(max_pos.z, part_max.z)
                                            end
                                        end
                                    end
                                end
                                if min_pos and max_pos then
                                    local distance = math.sqrt(
                                        (player_pos.x - (min_pos.x + max_pos.x) / 2)^2 +
                                        (player_pos.y - (min_pos.y + max_pos.y) / 2)^2 +
                                        (player_pos.z - (min_pos.z + max_pos.z) / 2)^2
                                    )
                                    if distance <= max_distance then
                                        local center_pos = Vector3((min_pos.x + max_pos.x) / 2, (min_pos.y + max_pos.y) / 2, (min_pos.z + max_pos.z) / 2)
                                        local screen_pos = utils.world_to_screen(center_pos)
                                        if screen_pos then
                                            local corners = {
                                                utils.world_to_screen(Vector3(min_pos.x, min_pos.y, min_pos.z)),
                                                utils.world_to_screen(Vector3(max_pos.x, min_pos.y, min_pos.z)),
                                                utils.world_to_screen(Vector3(max_pos.x, max_pos.y, min_pos.z)),
                                                utils.world_to_screen(Vector3(min_pos.x, max_pos.y, min_pos.z)),
                                                utils.world_to_screen(Vector3(min_pos.x, min_pos.y, max_pos.z)),
                                                utils.world_to_screen(Vector3(max_pos.x, min_pos.y, max_pos.z)),
                                                utils.world_to_screen(Vector3(max_pos.x, max_pos.y, max_pos.z)),
                                                utils.world_to_screen(Vector3(min_pos.x, max_pos.y, max_pos.z))
                                            }
                                            local all_corners_valid = true
                                            for _, corner in ipairs(corners) do
                                                if not corner then
                                                    all_corners_valid = false
                                                    break
                                                end
                                            end
                                            if all_corners_valid then
                                                -- Draw 3D box
                                                render.line(corners[1].x, corners[1].y, corners[2].x, corners[2].y, r, g, b, a, 1)
                                                render.line(corners[2].x, corners[2].y, corners[3].x, corners[3].y, r, g, b, a, 1)
                                                render.line(corners[3].x, corners[3].y, corners[4].x, corners[4].y, r, g, b, a, 1)
                                                render.line(corners[4].x, corners[4].y, corners[1].x, corners[1].y, r, g, b, a, 1)
                                                render.line(corners[5].x, corners[5].y, corners[6].x, corners[6].y, r, g, b, a, 1)
                                                render.line(corners[6].x, corners[6].y, corners[7].x, corners[7].y, r, g, b, a, 1)
                                                render.line(corners[7].x, corners[7].y, corners[8].x, corners[8].y, r, g, b, a, 1)
                                                render.line(corners[8].x, corners[8].y, corners[5].x, corners[5].y, r, g, b, a, 1)
                                                render.line(corners[1].x, corners[1].y, corners[5].x, corners[5].y, r, g, b, a, 1)
                                                render.line(corners[2].x, corners[2].y, corners[6].x, corners[6].y, r, g, b, a, 1)
                                                render.line(corners[3].x, corners[3].y, corners[7].x, corners[7].y, r, g, b, a, 1)
                                                render.line(corners[4].x, corners[4].y, corners[8].x, corners[8].y, r, g, b, a, 1)
                                                
                                                -- Draw chest name and distance
                                                local chest_name = item:Name()
                                                local distance_text = string.format("%dm", math.floor(distance))
                                                
                                                local name_text_size = render.measure_text(chest_name, font_index)
                                                local distance_text_size = render.measure_text(distance_text, font_index)
                                                
                                                local name_offset_x = name_text_size.x / 2
                                                local distance_offset_x = distance_text_size.x / 2
                                                local vertical_spacing = name_text_size.y + 2
                                                
                                                render.text(
                                                    screen_pos.x - name_offset_x,
                                                    screen_pos.y - name_text_size.y - vertical_spacing,
                                                    chest_name,
                                                    r, g, b, a,
                                                    "os",
                                                    font_index
                                                )
                                                
                                                render.text(
                                                    screen_pos.x - distance_offset_x,
                                                    screen_pos.y - name_text_size.y + vertical_spacing,
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
            end
        end
    end

    -- NPC ESP
    if npc_esp_toggle:get() then
        local characters_folder = workspace:FindChild("Characters")
        if characters_folder then
            local characters = characters_folder:Children()
            for _, character in ipairs(characters) do
                if character:ClassName() == "Model" then
                    local humanoid = character:FindChildByClass("Humanoid")
                    if humanoid and humanoid:Name() == "NPC" then
                        local root_part = character:FindChild("HumanoidRootPart")
                        if root_part then
                            local root_pos = root_part:Primitive():GetPartPosition()
                            if root_pos then
                                local distance = math.sqrt(
                                    (player_pos.x - root_pos.x)^2 +
                                    (player_pos.y - root_pos.y)^2 +
                                    (player_pos.z - root_pos.z)^2
                                )
                                
                                if distance <= max_distance then
                                    -- Check if NPC is on-screen
                                    local screen_pos = utils.world_to_screen(root_pos)
                                    if not screen_pos then
                                        return -- Skip all rendering if NPC is off-screen
                                    end
                                    
                                    -- Calculate 3D box based on character parts
                                    local min_pos = Vector3(root_pos.x, root_pos.y, root_pos.z)
                                    local max_pos = Vector3(root_pos.x, root_pos.y, root_pos.z)
                                    local parts = character:Children()
                                    for _, part in ipairs(parts) do
                                        if part:ClassName() == "Part" or part:ClassName() == "UnionOperation" or part:ClassName() == "MeshPart" then
                                            local part_pos = part:Primitive():GetPartPosition()
                                            local part_size = part:Primitive():GetPartSize()
                                            if part_pos and part_size then
                                                min_pos.x = math.min(min_pos.x, part_pos.x - part_size.x / 2)
                                                min_pos.y = math.min(min_pos.y, part_pos.y - part_size.y / 2)
                                                min_pos.z = math.min(min_pos.z, part_pos.z - part_size.z / 2)
                                                max_pos.x = math.max(max_pos.x, part_pos.x + part_size.x / 2)
                                                max_pos.y = math.max(max_pos.y, part_pos.y + part_size.y / 2)
                                                max_pos.z = math.max(max_pos.z, part_pos.z + part_size.z / 2)
                                            end
                                        end
                                    end
                                    
                                    -- Project corners to screen
                                    local corners = {
                                        utils.world_to_screen(Vector3(min_pos.x, min_pos.y, min_pos.z)),
                                        utils.world_to_screen(Vector3(max_pos.x, min_pos.y, min_pos.z)),
                                        utils.world_to_screen(Vector3(max_pos.x, max_pos.y, min_pos.z)),
                                        utils.world_to_screen(Vector3(min_pos.x, max_pos.y, min_pos.z)),
                                        utils.world_to_screen(Vector3(min_pos.x, min_pos.y, max_pos.z)),
                                        utils.world_to_screen(Vector3(max_pos.x, min_pos.y, max_pos.z)),
                                        utils.world_to_screen(Vector3(max_pos.x, max_pos.y, max_pos.z)),
                                        utils.world_to_screen(Vector3(min_pos.x, max_pos.y, max_pos.z))
                                    }
                                    
                                    -- Only proceed if all corners are valid
                                    local all_corners_valid = true
                                    for _, corner in ipairs(corners) do
                                        if not corner then
                                            all_corners_valid = false
                                            break
                                        end
                                    end
                                    
                                    if all_corners_valid then
                                        -- Draw 3D box
                                        render.line(corners[1].x, corners[1].y, corners[2].x, corners[2].y, r, g, b, a, 1)
                                        render.line(corners[2].x, corners[2].y, corners[3].x, corners[3].y, r, g, b, a, 1)
                                        render.line(corners[3].x, corners[3].y, corners[4].x, corners[4].y, r, g, b, a, 1)
                                        render.line(corners[4].x, corners[4].y, corners[1].x, corners[1].y, r, g, b, a, 1)
                                        render.line(corners[5].x, corners[5].y, corners[6].x, corners[6].y, r, g, b, a, 1)
                                        render.line(corners[6].x, corners[6].y, corners[7].x, corners[7].y, r, g, b, a, 1)
                                        render.line(corners[7].x, corners[7].y, corners[8].x, corners[8].y, r, g, b, a, 1)
                                        render.line(corners[8].x, corners[8].y, corners[5].x, corners[5].y, r, g, b, a, 1)
                                        render.line(corners[1].x, corners[1].y, corners[5].x, corners[5].y, r, g, b, a, 1)
                                        render.line(corners[2].x, corners[2].y, corners[6].x, corners[6].y, r, g, b, a, 1)
                                        render.line(corners[3].x, corners[3].y, corners[7].x, corners[7].y, r, g, b, a, 1)
                                        render.line(corners[4].x, corners[4].y, corners[8].x, corners[8].y, r, g, b, a, 1)
                                    end
                                    
                                    -- Draw name and health
                                    local npc_name = character:Name()
                                    local health_text = string.format("HP: %d/%d", humanoid:Health(), humanoid:MaxHealth())
                                    
                                    local name_text_size = render.measure_text(npc_name, font_index)
                                    local health_text_size = render.measure_text(health_text, font_index)
                                    
                                    local name_offset_x = name_text_size.x / 2
                                    local health_offset_x = health_text_size.x
                                    local vertical_spacing = name_text_size.y + 2
                                    
                                    -- Draw NPC name above
                                    render.text(
                                        screen_pos.x - name_offset_x,
                                        screen_pos.y - name_text_size.y - vertical_spacing,
                                        npc_name,
                                        r, g, b, a,
                                        "os",
                                        font_index
                                    )
                                    
                                    -- Draw health to the left
                                    render.text(
                                        screen_pos.x - health_offset_x - 10,
                                        screen_pos.y,
                                        health_text,
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
