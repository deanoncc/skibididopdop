-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white

-- Main paint callback to render Hidden Metal labels and distances
cheat.set_callback("paint", function()
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Navigate to Workspace
    local workspace = globals.workspace()
    
    -- Get all Models in Workspace
    local models = workspace:Children()
    
    -- Get selected font and color
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each model in Workspace
    for _, model in ipairs(models) do
        if model:ClassName() == "Model" then
            -- Find the Part in the Model
            local part = model:FindChildByClass("Part")
            -- Check for ProximityPrompt named "hidden-metal-prompt"
            local prompt = model:FindChild("hidden-metal-prompt")
            if part and prompt and prompt:ClassName() == "ProximityPrompt" then
                local item_pos = part:Primitive():GetPartPosition()
                if item_pos then
                    -- Calculate distance from player to part
                    local distance = math.sqrt(
                        (player_pos.x - item_pos.x)^2 +
                        (player_pos.y - item_pos.y)^2 +
                        (player_pos.z - item_pos.z)^2
                    )
                    
                    -- Convert 3D position to 2D screen coordinates
                    local screen_pos = utils.world_to_screen(item_pos)
                    if screen_pos then
                        -- Text to display
                        local item_text = "Hidden Metal"
                        local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                        
                        -- Measure text sizes for centering workaround
                        local item_text_size = render.measure_text(item_text, font_index)
                        local distance_text_size = render.measure_text(distance_text, font_index)
                        
                        -- Calculate offsets for centering
                        local item_offset_x = item_text_size.x / 2
                        local distance_offset_x = distance_text_size.x / 2
                        local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                        
                        -- Draw "Hidden Metal" text
                        render.text(
                            screen_pos.x - item_offset_x, -- Centered x
                            screen_pos.y - item_text_size.y, -- Above item position
                            item_text,
                            r, g, b, a, -- Use selected color
                            "os", -- Outline and shadow
                            font_index -- Use selected font
                        )
                        
                        -- Draw distance text below "Hidden Metal"
                        render.text(
                            screen_pos.x - distance_offset_x, -- Centered x
                            screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Hidden Metal"
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
end)