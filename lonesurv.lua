-- lone surv Aimbot and ESP Script with R15 Chams, 3D Box, Keys, and Backpacks (Optimized with Manual Cache - V5 Adapted)
-- Place in: C:\Users\USER\AppData\Roaming\Assembly\Scripts

--[[
    MODIFICATION NOTES:
    - Uses Workspace > Players folder for players, ignores local player by username.
    - Combined esp_color for all ESP modes (players, keys, backpacks).
    - Removed Look Vector ESP entirely (checkbox and functionality).
    - Removed Radar ESP entirely (checkboxes, buttons, and functionality).
    - Removed velocity prediction and bullet drop compensation (UI and functionality).
    - Removed health check (UI only, re-added health display for ESP).
    - Maintains V3 optimizations: stable ESP visibility.
    - Fixed typo in draw_3d_box (sole to local for step_thickness).
    - Fixed screenPos typo to screen_pos in draw_3d_box.
    - Added usernames above 3D box/Dot/Skeleton ESP and distance (in meters, no decimals) below using esp_color.
    - Added Items ESP (Workspace > Loot folder, parts), Keys ESP (Workspace > KeyDrops folder, parts), and Backpacks ESP (Workspace > DroppedPacks folder, models with MeshPart).
    - Fixed syntax error in update_aimbot_and_esp (removed erroneous "традиции" string, ensured correct text_size usage).
    - Removed Items ESP (checkbox, caching, rendering).
    - Removed Dot ESP for Keys and Backpacks (rendering logic, checkboxes kept but non-functional).
    - Added health display to the left of Player ESP (Dot, Skeleton, 3D Box) from Humanoid:Health().
    - Fixed folder name from DroppedRacks to DroppedPacks in update_target_cache.
    - Changed health display format to "current_hp/max_hp" (e.g., "100/100") using Humanoid:Health() and Humanoid:MaxHealth().
    - Restored Keys and Backpacks ESP to draw only name above and distance below (in meters, no decimals) using esp_color, no Dot ESP.
]]

-- UI Elements
local aimbot_enabled = ui.new_checkbox("Enable Aimbot")
local aimbot_key = ui.keybind("Aimbot Key")
local smoothness = ui.slider_float("Aimbot Smoothness", 5.0, 0.1, 20.0, "%.1f")
local fov_circle = ui.new_checkbox("Show FOV Circle")
local fov_radius = ui.slider_float("FOV Radius", 100.0, 50.0, 300.0, "%.0f")
local fov_color = ui.colorpicker("FOV Circle Color", 1.0, 1.0, 1.0, 0.5)
local sticky_aim = ui.new_checkbox("Enable Sticky Aim")
local esp_enabled = ui.new_checkbox("Enable Player ESP")
local esp_mode = ui.new_combo("Player ESP Mode", {"Dot ESP", "Skeleton ESP", "3D Box ESP"})
local esp_color = ui.colorpicker("ESP Color", 1.0, 0.0, 0.0, 1.0)
local chams_thickness = ui.slider_float("ESP Thickness", 2.0, 1.0, 5.0, "%.1f")
local box_width = ui.slider_float("Box Width (3D Box)", 2.8, 1.0, 10.0, "%.1f")
local box_height = ui.slider_float("Box Height (3D Box)", 6.0, 1.0, 15.0, "%.1f")
local outline_enabled = ui.new_checkbox("Enable Outline (3D Box)")
local glow_enabled = ui.new_checkbox("Enable Glow (3D Box)")
local glow_color = ui.colorpicker("Glow Color (3D Box)", 0.0, 0.5, 1.0, 1.0)
local glow_size = ui.slider_float("Glow Size (3D Box)", 5.0, 2.0, 15.0, "%.1f")
local keys_esp_enabled = ui.new_checkbox("Enable Keys ESP")
local backpacks_esp_enabled = ui.new_checkbox("Enable Backpacks ESP")

-- Cached Data & State
local cached_targets = {} -- Players
local cached_keys = {} -- Keys in KeyDrops folder
local cached_backpacks = {} -- Backpacks in DroppedPacks folder
local current_target_id = nil 
local last_cache_update = 0
local CACHE_UPDATE_INTERVAL = 1.0 
local local_player_name = globals.localplayer() and globals.localplayer():Name() or ""
local local_player_pos = nil

-- R15 Body Parts for Chams
local r15_limbs_names = {
    "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"
}

-- Helper Functions
local function get_distance_2d(pos1, pos2)
    local dx = pos1.x - pos2.x; local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

local function get_distance_3d(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    local dx = pos1.x - pos2.x; local dy = pos1.y - pos2.y; local dz = pos1.z - pos2.z
    return math.floor(math.sqrt(dx * dx + dy * dy + dz * dz) / 3) -- Convert to meters, no decimals
end

local function is_within_fov(screen_pos)
    if not screen_pos then return false end
    local mouse_pos = input.cursor_position()
    return get_distance_2d(mouse_pos, screen_pos) <= fov_radius:get()
end

local function multiply_matrix_vector(m, v)
    if not m or not v then return Vector3(0, 0, 0) end
    local x = m.m[1][1] * v.x + m.m[1][2] * v.y + m.m[1][3] * v.z
    local y = m.m[2][1] * v.x + m.m[2][2] * v.y + m.m[2][3] * v.z
    local z = m.m[3][1] * v.x + m.m[3][2] * v.y + m.m[3][3] * v.z
    return Vector3(x, y, z)
end

local function render_glow(x, y, width, height, r, g, b, radius)
    local glow_size = 10
    local glow_intensity = 10
    for i = 1, glow_size do
        local alpha = glow_intensity - (i * (glow_intensity / glow_size))
        render.rect(x - i, y - i, width + (i * 2), height + (i * 2), r, g, b, alpha, radius)
    end
end

function update_target_cache()
    local workspace = globals.workspace()
    if not workspace then return end
    
    -- Cache Players
    local players_folder = workspace:FindChild("Players")
    if players_folder then
        local found_this_scan = {}
        for _, model in ipairs(players_folder:Children()) do
            if model:ClassName() == "Model" and model:Name() ~= local_player_name then
                local hrp = model:FindChild("HumanoidRootPart")
                local humanoid = model:FindChild("Humanoid")
                if hrp and humanoid then
                    local model_id = model:Address()
                    found_this_scan[model_id] = true
                    if not cached_targets[model_id] then
                        local limbs = {}
                        for _, name in ipairs(r15_limbs_names) do
                            local limb_part = model:FindChild(name)
                            if limb_part then limbs[name] = limb_part end
                        end
                        if limbs["Head"] and limbs["HumanoidRootPart"] then
                            cached_targets[model_id] = { model = model, head = limbs["Head"], hrp = limbs["HumanoidRootPart"], limbs = limbs, name = model:Name(), humanoid = humanoid }
                        end
                    end
                end
            end
        end
        for id, _ in pairs(cached_targets) do
            if not found_this_scan[id] then
                cached_targets[id] = nil
            end
        end
    end
    
    -- Cache Keys (KeyDrops folder, parts)
    local keydrops_folder = workspace:FindChild("KeyDrops")
    if keydrops_folder then
        local found_keys = {}
        for _, part in ipairs(keydrops_folder:Children()) do
            if part:ClassName() == "Part" then
                local part_id = part:Address()
                found_keys[part_id] = true
                if not cached_keys[part_id] then
                    cached_keys[part_id] = { part = part, name = part:Name() }
                end
            end
        end
        for id, _ in pairs(cached_keys) do
            if not found_keys[id] then
                cached_keys[id] = nil
            end
        end
    end
    
    -- Cache Backpacks (DroppedPacks folder, models with MeshPart)
    local droppedpacks_folder = workspace:FindChild("DroppedPacks")
    if droppedpacks_folder then
        local found_backpacks = {}
        for _, model in ipairs(droppedpacks_folder:Children()) do
            if model:ClassName() == "Model" then
                local mesh_part = model:FindChildByClass("MeshPart")
                if mesh_part then
                    local model_id = model:Address()
                    found_backpacks[model_id] = true
                    if not cached_backpacks[model_id] then
                        cached_backpacks[model_id] = { model = model, mesh_part = mesh_part, name = model:Name() }
                    end
                end
            end
        end
        for id, _ in pairs(cached_backpacks) do
            if not found_backpacks[id] then
                cached_backpacks[id] = nil
            end
        end
    end
    
    -- Update local player position
    local local_player = globals.localplayer()
    if local_player then
        local local_hrp = local_player:ModelInstance():FindChild("HumanoidRootPart")
        if local_hrp then
            local local_hrp_primitive = local_hrp:Primitive()
            if local_hrp_primitive then
                local_player_pos = local_hrp_primitive:GetPartPosition()
            else
                local_player_pos = nil
            end
        else
            local_player_pos = nil
        end
    else
        local_player_pos = nil
    end
end

local function get_aim_position(target_data)
    local head_primitive = target_data.head:Primitive()
    if not head_primitive then return nil end
    local head_pos = head_primitive:GetPartPosition()
    if not head_pos then return nil end
    return Vector3(head_pos.x, head_pos.y, head_pos.z)
end

local function draw_limb_chams(limbs_table)
    local color = esp_color:get()
    local thickness = chams_thickness:get()
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    local screen_positions = {}
    for name, part in pairs(limbs_table) do
        local primitive = part:Primitive()
        if primitive then
            local pos3d = primitive:GetPartPosition()
            if pos3d then
                local pos2d = utils.world_to_screen(pos3d)
                if pos2d and pos2d.x >= 0 then
                    screen_positions[name] = pos2d
                end
            end
        end
    end
    for _, pair in ipairs(connections) do
        local p1, p2 = screen_positions[pair[1]], screen_positions[pair[2]]
        if p1 and p2 then
            render.line(p1.x, p1.y, p2.x, p2.y, color.r*255, color.g*255, color.b*255, color.a*255, thickness)
        end
    end
end

local function draw_3d_box(target_data)
    local color_val = esp_color:get()
    local r, g, b, a = math.floor(color_val.r * 255), math.floor(color_val.g * 255), math.floor(color_val.b * 255), math.floor(color_val.a * 255)
    local glow_color_val = glow_color:get()
    local gr, gg, gb, ga = math.floor(glow_color_val.r * 255), math.floor(glow_color_val.g * 255), math.floor(glow_color_val.b * 255), math.floor(glow_color_val.a * 255)
    local width = box_width:get()
    local height = box_height:get()
    local thickness = chams_thickness:get()
    local current_glow_size = glow_size:get()
    
    local cam_pos = camera.GetPosition()
    local cam_rot = camera.GetRotation()
    local screen_size = render.screen_size()
    if not cam_pos or not cam_rot or not screen_size then return end
    
    local cam_forward = Vector3(-cam_rot.m[1][3], -cam_rot.m[2][3], -cam_rot.m[3][3])
    
    local hrp = target_data.hrp
    if not hrp then return end

    local hrp_primitive = hrp:Primitive()
    if not hrp_primitive then return end
    local center_pos = hrp_primitive:GetPartPosition()
    
    local vec_to_player = Vector3(center_pos.x - cam_pos.x, center_pos.y - cam_pos.y, center_pos.z - cam_pos.z)
    local dot_product = cam_forward.x * vec_to_player.x + cam_forward.y * vec_to_player.y + cam_forward.z * vec_to_player.z
    if dot_product <= 0 then return end

    local success, hrp_rot = pcall(function() return hrp:GetRotation() end)
    if not success or not hrp_rot then hrp_rot = Matrix3({{1,0,0},{0,1,0},{0,0,1}}) end

    local half_w = width / 2
    local half_h = height / 2
    local corners_local = {
        Vector3(-half_w, -half_h, -half_w), Vector3(half_w, -half_h, -half_w),
        Vector3(half_w, -half_h, half_w), Vector3(-half_w, -half_h, half_w),
        Vector3(-half_w, half_h, -half_w), Vector3(half_w, half_h, -half_w),
        Vector3(half_w, half_h, half_w), Vector3(-half_w, half_h, half_w)
    }

    local screen_corners = {}
    local min_y, max_y, min_x = math.huge, -math.huge, math.huge
    local all_corners_valid = true
    for i = 1, 8 do
        local rotated_corner = multiply_matrix_vector(hrp_rot, corners_local[i])
        local world_corner = Vector3(center_pos.x + rotated_corner.x, center_pos.y + rotated_corner.y, center_pos.z + rotated_corner.z)
        local screen_pos = utils.world_to_screen(world_corner)
        if screen_pos and math.abs(screen_pos.x) < screen_size.x * 5 and math.abs(screen_pos.y) < screen_size.y * 5 then
            screen_corners[i] = screen_pos
            min_y = math.min(min_y, screen_pos.y)
            max_y = math.max(max_y, screen_pos.y)
            min_x = math.min(min_x, screen_pos.x)
        else
            all_corners_valid = false
            break
        end
    end

    if all_corners_valid then
        local edges = {{0, 1}, {1, 2}, {2, 3}, {3, 0}, {4, 5}, {5, 6}, {6, 7}, {7, 4}, {0, 4}, {1, 5}, {2, 6}, {3, 7}}
        for _, edge in ipairs(edges) do
            local p1 = screen_corners[edge[1] + 1]
            local p2 = screen_corners[edge[2] + 1]
            if glow_enabled:get() then
                local glow_steps = 5
                for i = glow_steps, 1, -1 do
                    local step_alpha = (ga * 0.6) / glow_steps * (i / glow_steps)
                    local step_thickness = thickness + (current_glow_size / glow_steps) * i
                    render.line(p1.x, p1.y, p2.x, p2.y, gr, gg, gb, step_alpha, step_thickness)
                end
            end
            if outline_enabled:get() then
                render.line(p1.x, p1.y, p2.x, p2.y, 0, 0, 0, a, thickness + 2)
            end
            render.line(p1.x, p1.y, p2.x, p2.y, r, g, b, a, thickness)
        end
        -- Draw username above box and distance below using ESP color
        local text_pos_x = (screen_corners[1].x + screen_corners[2].x) / 2
        local username = target_data.name
        local text_size = render.measure_text(username, 2)
        render.text(text_pos_x - text_size.x / 2, min_y - 15, username, r, g, b, a, "o", 2)
        local distance = get_distance_3d(local_player_pos, center_pos)
        local distance_text = tostring(distance) .. "m"
        text_size = render.measure_text(distance_text, 2)
        render.text(text_pos_x - text_size.x / 2, max_y + 5, distance_text, r, g, b, a, "o", 2)
        -- Draw health to the left of the box using ESP color in format "current_hp/max_hp"
        local current_hp = math.floor(target_data.humanoid:Health())
        local max_hp = math.floor(target_data.humanoid:MaxHealth())
        local health_text = current_hp .. "/" .. max_hp
        text_size = render.measure_text(health_text, 2)
        render.text(min_x - text_size.x - 5, (min_y + max_y) / 2, health_text, r, g, b, a, "o", 2)
    end
end

local function draw_key_esp(key_data, screen_size, r, g, b, a)
    local part = key_data.part
    local part_primitive = part:Primitive()
    if not part_primitive then return end
    local pos = part_primitive:GetPartPosition()
    if not pos then return end
    local screen_pos = utils.world_to_screen(pos)
    if not screen_pos or screen_pos.x <= 0 or screen_pos.x >= screen_size.x or screen_pos.y <= 0 or screen_pos.y >= screen_size.y then return end
    -- Draw key name above and distance below using ESP color
    local name = key_data.name
    local text_size = render.measure_text(name, 2)
    render.text(screen_pos.x - text_size.x / 2, screen_pos.y - 15, name, r, g, b, a, "o", 2)
    local distance = get_distance_3d(local_player_pos, pos)
    local distance_text = tostring(distance) .. "m"
    text_size = render.measure_text(distance_text, 2)
    render.text(screen_pos.x - text_size.x / 2, screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
end

local function draw_backpack_esp(backpack_data, screen_size, r, g, b, a)
    local mesh_part = backpack_data.mesh_part
    local part_primitive = mesh_part:Primitive()
    if not part_primitive then return end
    local pos = part_primitive:GetPartPosition()
    if not pos then return end
    local screen_pos = utils.world_to_screen(pos)
    if not screen_pos or screen_pos.x <= 0 or screen_pos.x >= screen_size.x or screen_pos.y <= 0 or screen_pos.y >= screen_size.y then return end
    -- Draw backpack name above and distance below using ESP color
    local name = backpack_data.name
    local text_size = render.measure_text(name, 2)
    render.text(screen_pos.x - text_size.x / 2, screen_pos.y - 15, name, r, g, b, a, "o", 2)
    local distance = get_distance_3d(local_player_pos, pos)
    local distance_text = tostring(distance) .. "m"
    text_size = render.measure_text(distance_text, 2)
    render.text(screen_pos.x - text_size.x / 2, screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
end

local function smooth_aim_to_target(target_pos_2d)
    local mouse_pos = input.cursor_position()
    local dx = target_pos_2d.x - mouse_pos.x
    local dy = target_pos_2d.y - mouse_pos.y
    input.move(dx / smoothness:get(), dy / smoothness:get())
end

-- Core Logic
local function update_aimbot_and_esp()
    if not globals.is_focused() then return end

    local aimbot_active = aimbot_enabled:get() and aimbot_key:get()
    local mouse_pos = input.cursor_position()
    local closest_distance = math.huge
    local new_target_id = nil
    local screen_size = render.screen_size()
    if not screen_size then return end

    if aimbot_active and sticky_aim:get() and current_target_id and cached_targets[current_target_id] then
        local aim_pos = get_aim_position(cached_targets[current_target_id])
        if aim_pos then
            local screen_pos = utils.world_to_screen(aim_pos)
            if screen_pos and screen_pos.x >= 0 and is_within_fov(screen_pos) then
                smooth_aim_to_target(screen_pos)
            else
                current_target_id = nil
            end
        else
            current_target_id = nil
        end
    end
    
    local selected_mode = esp_mode:get()
    local esp_color_val = esp_color:get()
    local r, g, b, a = math.floor(esp_color_val.r * 255), math.floor(esp_color_val.g * 255), math.floor(esp_color_val.b * 255), math.floor(esp_color_val.a * 255)
    
    -- Player ESP
    for id, target_data in pairs(cached_targets) do
        local hrp = target_data.hrp
        local hrp_primitive = hrp:Primitive()
        if not hrp_primitive then goto continue end
        local hrp_pos = hrp:Primitive():GetPartPosition()
        if not hrp_pos then goto continue end
        local hrp_screen_pos = utils.world_to_screen(hrp_pos)
        if not hrp_screen_pos or hrp_screen_pos.x <= 0 or hrp_screen_pos.x >= screen_size.x or hrp_screen_pos.y <= 0 or hrp_screen_pos.y >= screen_size.y then goto continue end
        
        if esp_enabled:get() then
            if selected_mode == 0 then -- Dot ESP
                local head_pos = target_data.head:Primitive():GetPartPosition()
                if head_pos then
                    local head_screen_pos = utils.world_to_screen(head_pos)
                    if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                        render.circle(head_screen_pos.x, head_screen_pos.y, 5, r, g, b, a, 32)
                        -- Draw username above dot and distance below HRP using ESP color
                        local username = target_data.name
                        local text_size = render.measure_text(username, 2)
                        render.text(head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, r, g, b, a, "o", 2)
                        local distance = get_distance_3d(local_player_pos, hrp_pos)
                        local distance_text = tostring(distance) .. "m"
                        text_size = render.measure_text(distance_text, 2)
                        render.text(hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
                        -- Draw health to the left of the dot using ESP color in format "current_hp/max_hp"
                        local current_hp = math.floor(target_data.humanoid:Health())
                        local max_hp = math.floor(target_data.humanoid:MaxHealth())
                        local health_text = current_hp .. "/" .. max_hp
                        text_size = render.measure_text(health_text, 2)
                        render.text(head_screen_pos.x - text_size.x - 5, head_screen_pos.y, health_text, r, g, b, a, "o", 2)
                    end
                end
            elseif selected_mode == 1 then -- Skeleton ESP
                draw_limb_chams(target_data.limbs)
                -- Draw username above head and distance below HRP using ESP color
                local head_pos = target_data.head:Primitive():GetPartPosition()
                if head_pos then
                    local head_screen_pos = utils.world_to_screen(head_pos)
                    if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                        local username = target_data.name
                        local text_size = render.measure_text(username, 2)
                        render.text(head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, r, g, b, a, "o", 2)
                        local distance = get_distance_3d(local_player_pos, hrp_pos)
                        local distance_text = tostring(distance) .. "m"
                        text_size = render.measure_text(distance_text, 2)
                        render.text(hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
                        -- Draw health to the left of the head using ESP color in format "current_hp/max_hp"
                        local current_hp = math.floor(target_data.humanoid:Health())
                        local max_hp = math.floor(target_data.humanoid:MaxHealth())
                        local health_text = current_hp .. "/" .. max_hp
                        text_size = render.measure_text(health_text, 2)
                        render.text(head_screen_pos.x - text_size.x - 5, head_screen_pos.y, health_text, r, g, b, a, "o", 2)
                    end
                end
            elseif selected_mode == 2 then -- 3D Box ESP
                draw_3d_box(target_data)
            end
        end

        if aimbot_active and not (sticky_aim:get() and current_target_id) then
            local aim_pos = get_aim_position(target_data)
            if aim_pos then
                local aim_screen_pos = utils.world_to_screen(aim_pos)
                if aim_screen_pos and aim_screen_pos.x >= 0 and is_within_fov(aim_screen_pos) then
                    local distance = get_distance_2d(mouse_pos, aim_screen_pos)
                    if distance < closest_distance then
                        closest_distance = distance
                        new_target_id = id
                    end
                end
            end
        end
        ::continue::
    end

    -- Keys ESP
    if keys_esp_enabled:get() then
        for _, key_data in pairs(cached_keys) do
            draw_key_esp(key_data, screen_size, r, g, b, a)
        end
    end

    -- Backpacks ESP
    if backpacks_esp_enabled:get() then
        for _, backpack_data in pairs(cached_backpacks) do
            draw_backpack_esp(backpack_data, screen_size, r, g, b, a)
        end
    end

    if aimbot_active and new_target_id and not (sticky_aim:get() and current_target_id) then
        current_target_id = new_target_id
        local aim_pos = get_aim_position(cached_targets[current_target_id])
        if aim_pos then
            local screen_pos = utils.world_to_screen(aim_pos)
            if screen_pos and screen_pos.x >= 0 then
                smooth_aim_to_target(screen_pos)
            end
        end
    elseif not aimbot_active then
        current_target_id = nil
    end
end

local function draw_fov_circle()
    if not fov_circle:get() then return end
    local mouse_pos = input.cursor_position()
    local color = fov_color:get()
    render.circle_outline(mouse_pos.x, mouse_pos.y, fov_radius:get(), color.r*255, color.g*255, color.b*255, color.a*255, 2, 64)
end

-- Event Callbacks
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    if globals.curtime() - last_cache_update > CACHE_UPDATE_INTERVAL then
        update_target_cache()
        last_cache_update = globals.curtime()
    end
    update_aimbot_and_esp()
    draw_fov_circle()
end)

cheat.set_callback("shutdown", function()
    if not globals.is_focused() then return end
    cached_targets, cached_keys, cached_backpacks, current_target_id = {}, {}, {}, nil
    print("lone surv(Players Folder, V5) script unloaded cleanly.")
end)


print("lone survAimbot and ESP (Players Folder, V5) loaded successfully!")

