-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("Metal/Tree ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white for Metal and Tree Orb
local metal_esp_toggle = ui.new_checkbox("Enable Metal ESP")
local tree_orb_esp_toggle = ui.new_checkbox("Enable Tree Orb ESP")
local crit_star_esp_toggle = ui.new_checkbox("Enable Crit Star ESP (not colorable)")
local vitality_star_esp_toggle = ui.new_checkbox("Enable Vitality Star ESP (not colorable)")

-- Define fixed colors for Crit Star (Yellow) and Vitality Star (Green)
local crit_star_color = { r = 255, g = 255, b = 0, a = 255 } -- Yellow (#FFFF00FF)
local vitality_star_color = { r = 0, g = 255, b = 0, a = 255 } -- Green (#00FF00FF)

-- Main paint callback to render ESP labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
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
    
    -- Get selected font and color for Metal/Tree ESP
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0) for Metal/Tree ESP
    
    -- Convert color to 0-255 range for render.text (Metal/Tree ESP)
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each model in Workspace
    for _, model in ipairs(models) do
        if model:ClassName() == "Model" then
            -- Metal ESP
            if metal_esp_toggle:get() then
                local part = model:FindChildByClass("Part")
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
            
            -- Tree Orb ESP
            if tree_orb_esp_toggle:get() and model:Name() == "TreeOrb" then
                local spirit_part = model:FindChild("Spirit")
                if spirit_part and spirit_part:ClassName() == "Part" then
                    local item_pos = spirit_part:Primitive():GetPartPosition()
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
                            local item_text = "Tree Orb"
                            local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                            
                            -- Measure text sizes for centering workaround
                            local item_text_size = render.measure_text(item_text, font_index)
                            local distance_text_size = render.measure_text(distance_text, font_index)
                            
                            -- Calculate offsets for centering
                            local item_offset_x = item_text_size.x / 2
                            local distance_offset_x = distance_text_size.x / 2
                            local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                            
                            -- Draw "Tree Orb" text
                            render.text(
                                screen_pos.x - item_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y, -- Above item position
                                item_text,
                                r, g, b, a, -- Use selected color
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                            
                            -- Draw distance text below "Tree Orb"
                            render.text(
                                screen_pos.x - distance_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Tree Orb"
                                distance_text,
                                r, g, b, a, -- Use selected color
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                        end
                    end
                end
            end
            
            -- Crit Star ESP (Fixed Yellow Color)
            if crit_star_esp_toggle:get() and model:Name() == "CritStar" then
                local root_part = model:FindChild("RootPart")
                if root_part and root_part:ClassName() == "Part" then
                    local item_pos = root_part:Primitive():GetPartPosition()
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
                            local item_text = "Crit Star"
                            local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                            
                            -- Measure text sizes for centering workaround
                            local item_text_size = render.measure_text(item_text, font_index)
                            local distance_text_size = render.measure_text(distance_text, font_index)
                            
                            -- Calculate offsets for centering
                            local item_offset_x = item_text_size.x / 2
                            local distance_offset_x = distance_text_size.x / 2
                            local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                            
                            -- Draw "Crit Star" text
                            render.text(
                                screen_pos.x - item_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y, -- Above item position
                                item_text,
                                crit_star_color.r, crit_star_color.g, crit_star_color.b, crit_star_color.a, -- Fixed yellow
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                            
                            -- Draw distance text below "Crit Star"
                            render.text(
                                screen_pos.x - distance_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Crit Star"
                                distance_text,
                                crit_star_color.r, crit_star_color.g, crit_star_color.b, crit_star_color.a, -- Fixed yellow
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                        end
                    end
                end
            end
            
            -- Vitality Star ESP (Fixed Green Color)
            if vitality_star_esp_toggle:get() and model:Name() == "VitalityStar" then
                local root_part = model:FindChild("RootPart")
                if root_part and root_part:ClassName() == "Part" then
                    local item_pos = root_part:Primitive():GetPartPosition()
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
                            local item_text = "Vitality Star"
                            local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                            
                            -- Measure text sizes for centering workaround
                            local item_text_size = render.measure_text(item_text, font_index)
                            local distance_text_size = render.measure_text(distance_text, font_index)
                            
                            -- Calculate offsets for centering
                            local item_offset_x = item_text_size.x / 2
                            local distance_offset_x = distance_text_size.x / 2
                            local vertical_spacing = item_text_size.y + 2 -- Small gap between texts
                            
                            -- Draw "Vitality Star" text
                            render.text(
                                screen_pos.x - item_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y, -- Above item position
                                item_text,
                                vitality_star_color.r, vitality_star_color.g, vitality_star_color.b, vitality_star_color.a, -- Fixed green
                                "os", -- Outline and shadow
                                font_index -- Use selected font
                            )
                            
                            -- Draw distance text below "Vitality Star"
                            render.text(
                                screen_pos.x - distance_offset_x, -- Centered x
                                screen_pos.y - item_text_size.y + vertical_spacing, -- Below "Vitality Star"
                                distance_text,
                                vitality_star_color.r, vitality_star_color.g, vitality_star_color.b, vitality_star_color.a, -- Fixed green
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

