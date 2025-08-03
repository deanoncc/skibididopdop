-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white

-- Main paint callback to render labels and distances on BasePart
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    if not humanoid_root then return end
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    if not player_pos then return end
    
    -- Navigate to Workspace
    local workspace = globals.workspace()
    
    -- Find the dynamic map model containing ComputerTable models
    local map_model = nil
    for _, child in ipairs(workspace:Children()) do
        if child:ClassName() == "Model" then
            for _, sub_child in ipairs(child:Children()) do
                if sub_child:ClassName() == "Model" and sub_child:Name() == "ComputerTable" then
                    map_model = child
                    break
                end
            end
        end
        if map_model then break end
    end
    if not map_model then return end
    
    -- Find all ComputerTable models in the map model
    local computer_tables = {}
    for _, child in ipairs(map_model:Children()) do
        if child:ClassName() == "Model" and child:Name() == "ComputerTable" then
            table.insert(computer_tables, child)
        end
    end
    
    -- Get selected font and color
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each ComputerTable model
    for _, computer_table in ipairs(computer_tables) do
        -- Find the specific Part named "BasePart" in the ComputerTable model
        local base_part = computer_table:FindChild("BasePart")
        if base_part and base_part:ClassName() == "Part" then
            local part_pos = base_part:Primitive():GetPartPosition()
            if part_pos then
                -- Calculate distance from player to BasePart
                local distance = math.sqrt(
                    (player_pos.x - part_pos.x)^2 +
                    (player_pos.y - part_pos.y)^2 +
                    (player_pos.z - part_pos.z)^2
                )
                
                -- Convert 3D position to 2D screen coordinates
                local screen_pos = utils.world_to_screen(part_pos)
                if screen_pos then
                    -- Text to display
                    local item_text = "Computer"
                    local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                    
                    -- Measure text sizes for centering workaround
                    local item_text_size = render.measure_text(item_text, font_index)
                    local distance_text_size = render.measure_text(distance_text, font_index)
                    
                    -- Calculate offsets for centering
                    local item_offset_x = item_text_size.x / 2
                    local distance_offset_x = distance_text_size.x / 2
                    local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                    
                    -- Draw "Computer" text on the BasePart
                    render.text(
                        screen_pos.x - item_offset_x, -- Centered x
                        screen_pos.y - item_text_size.y, -- Above part position
                        item_text,
                        r, g, b, a, -- Use selected color
                        "os", -- Outline and shadow
                        font_index -- Use selected font
                    )
                    
                    -- Draw distance text below "Computer"
                    render.text(
                        screen_pos.x - distance_offset_x, -- Centered x
                        screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Computer"
                        distance_text,
                        r, g, b, a, -- Use selected color
                        "os", -- Outline and shadow
                        font_index -- Use selected font
                    )
                end
            end
        end
    end

end)
