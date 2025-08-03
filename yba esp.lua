-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white

-- Main paint callback to render item labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Navigate to Workspace > Item_Spawns > Items
    local workspace = globals.workspace()
    
    local item_spawns = workspace:FindChild("Item_Spawns")
    
    local item_folder = item_spawns:FindChild("Items")
    
    -- Get all items (Models and Parts) in the Item folder
    local items = item_folder:Children()
    
    -- Get selected font and color
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each item
    for _, item in ipairs(items) do
        local item_pos = nil
        -- Check if the item is a Model
        if item:ClassName() == "Model" then
            -- Find the first MeshPart in the Model
            local mesh_part = item:FindChildByClass("MeshPart")
            if mesh_part then
                item_pos = mesh_part:Primitive():GetPartPosition()
            end
        -- Check if the item is a Part
        elseif item:ClassName() == "Part" then
            item_pos = item:Primitive():GetPartPosition()
        end
        
        if item_pos then
            -- Calculate distance from player to item
            local distance = math.sqrt(
                (player_pos.x - item_pos.x)^2 +
                (player_pos.y - item_pos.y)^2 +
                (player_pos.z - item_pos.z)^2
            )
            
            -- Convert 3D position to 2D screen coordinates
            local screen_pos = utils.world_to_screen(item_pos)
            if screen_pos then
                -- Text to display
                local item_text = "Item"
                local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                
                -- Measure text sizes for centering workaround
                local item_text_size = render.measure_text(item_text, font_index)
                local distance_text_size = render.measure_text(distance_text, font_index)
                
                -- Calculate offsets for centering
                local item_offset_x = item_text_size.x / 2
                local distance_offset_x = distance_text_size.x / 2
                local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                
                -- Draw "Item" text
                render.text(
                    screen_pos.x - item_offset_x, -- Centered x
                    screen_pos.y - item_text_size.y, -- Above item position
                    item_text,
                    r, g, b, a, -- Use selected color
                    "os", -- Outline and shadow
                    font_index -- Use selected font
                )
                
                -- Draw distance text below "Item"
                render.text(
                    screen_pos.x - distance_offset_x, -- Centered x
                    screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Item"
                    distance_text,
                    r, g, b, a, -- Use selected color
                    "os", -- Outline and shadow
                    font_index -- Use selected font
                )
            end
        end
    end

end)
