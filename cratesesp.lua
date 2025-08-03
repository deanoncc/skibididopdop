-- Create UI elements for font and color selection
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0) -- Default white

-- Main paint callback to render crate labels and distances
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Navigate to Workspace > Crates
    local workspace = globals.workspace()
    local crate_folder = workspace:FindChild("Crates")
    
    -- Get all crates (Models) in the Crates folder
    local crates = crate_folder:Children()
    
    -- Get selected font and color
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    local color = color_picker:get() -- Returns table with r, g, b, a (0.0 to 1.0)
    
    -- Convert color to 0-255 range for render.text
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    -- Iterate through each crate
    for _, crate in ipairs(crates) do
        -- Check if the crate is a Model
        if crate:ClassName() == "Model" then
            -- Find the MeshPart in the Model
            local mesh_part = crate:FindChildByClass("MeshPart")
            if mesh_part then
                local crate_pos = mesh_part:Primitive():GetPartPosition()
                
                -- Calculate distance from player to crate
                local distance = math.sqrt(
                    (player_pos.x - crate_pos.x)^2 +
                    (player_pos.y - crate_pos.y)^2 +
                    (player_pos.z - crate_pos.z)^2
                )
                
                -- Convert 3D position to 2D screen coordinates
                local screen_pos = utils.world_to_screen(crate_pos)
                if screen_pos then
                    -- Text to display (use actual crate name)
                    local crate_text = crate:Name()
                    local distance_text = string.format("%dm", math.floor(distance)) -- Round to integer
                    
                    -- Measure text sizes for centering workaround
                    local crate_text_size = render.measure_text(crate_text, font_index)
                    local distance_text_size = render.measure_text(distance_text, font_index)
                    
                    -- Calculate offsets for centering
                    local crate_offset_x = crate_text_size.x / 2
                    local distance_offset_x = distance_text_size.x / 2
                    local vertical_spacing = crate_text_size.y + 2 -- Small gap between texts
                    
                    -- Draw crate name text
                    render.text(
                        screen_pos.x - crate_offset_x, -- Centered x
                        screen_pos.y - crate_text_size.y, -- Above crate position
                        crate_text,
                        r, g, b, a, -- Use selected color
                        "os", -- Outline and shadow
                        font_index -- Use selected font
                    )
                    
                    -- Draw distance text below crate name
                    render.text(
                        screen_pos.x - distance_offset_x, -- Centered x
                        screen_pos.y - crate_text_size.y + vertical_spacing, -- Below crate name
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
