local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local color_picker = ui.colorpicker("ESP Color", 1.0, 1.0, 1.0, 1.0)

cheat.set_callback("paint", function()
    local local_player = globals.localplayer()
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    local workspace = globals.workspace()
    local font_index = font_combo:get()
    local color = color_picker:get()
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    local a = math.floor(color.a * 255)
    
    local function process_objects(folder, label)
        local objects = folder:Children()
        for _, obj in ipairs(objects) do
            local obj_pos = nil
            if obj:ClassName() == "Model" then
                local part = obj:FindChildByClass("MeshPart") or obj:FindChildByClass("Part")
                if part then
                    obj_pos = part:Primitive():GetPartPosition()
                end
            elseif obj:ClassName() == "Part" then
                obj_pos = obj:Primitive():GetPartPosition()
            end
            if obj_pos then
                local distance = math.sqrt(
                    (player_pos.x - obj_pos.x)^2 +
                    (player_pos.y - obj_pos.y)^2 +
                    (player_pos.z - obj_pos.z)^2
                )
                local screen_pos = utils.world_to_screen(obj_pos)
                if screen_pos then
                    local obj_text = label
                    local distance_text = string.format("%dm", math.floor(distance))
                    local obj_text_size = render.measure_text(obj_text, font_index)
                    local distance_text_size = render.measure_text(distance_text, font_index)
                    local obj_offset_x = obj_text_size.x / 2
                    local distance_offset_x = distance_text_size.x / 2
                    local vertical_spacing = obj_text_size.y + 2
                    render.text(
                        screen_pos.x - obj_offset_x,
                        screen_pos.y - obj_text_size.y,
                        obj_text,
                        r, g, b, a,
                        "os",
                        font_index
                    )
                    render.text(
                        screen_pos.x - distance_offset_x,
                        screen_pos.y - obj_text_size.y + vertical_spacing,
                        distance_text,
                        r, g, b, a,
                        "os",
                        font_index
                    )
                end
            end
        end
    end
    
    local chest_models = workspace:FindChild("ChestModels")
    if chest_models then
        process_objects(chest_models, "Chest")
    end
    local spawned_items = workspace:FindChild("SpawnedItems")
    if spawned_items then
        process_objects(spawned_items, "Item")
    end
end)