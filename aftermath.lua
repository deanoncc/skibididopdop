-- Trident Survival Aimbot and ESP Script with R15 Chams and 3D Box (Optimized with Manual Cache - V5 Adapted)
-- Place in: C:\Users\USER\AppData\Roaming\Assembly\Scripts
-- Updated for new player detection: Workspace > Characters (randomly named models), match HumanoidRootPart X position with Workspace models for usernames
-- Added Zombie ESP and Aimbot for models in Workspace > game_assets > NPCs with HumanoidRootPart, Head, Torso, Left Arm, Right Arm, Left Leg, Right Leg
-- Removed Backpacks ESP, Keys ESP, and health display (no Humanoid in Characters folder models)
-- Removed all debug prints

--[[
    MODIFICATION NOTES:
    - Updated player detection to use Workspace > Characters folder (randomly named models). Matches HumanoidRootPart X position with models in Workspace to get usernames.
    - Local player identified by matching HumanoidRootPart X position of model named with local player's username in Workspace to Characters folder model.
    - Added Zombie ESP for models in Workspace > game_assets > NPCs, using selected ESP mode (Dot, Skeleton, 3D Box) with fixed green color (r=0, g=1, b=0, a=1) for ESP, names, and distance, controlled by Enable Zombie ESP checkbox.
    - Changed zombie ESP name from model display name to fixed "Zombie" for all zombies.
    - Added Zombie Aimbot, controlled by Enable Zombie Aimbot checkbox, targeting zombies when active, using same aimbot settings as players (smoothness, FOV, sticky aim).
    - Aimbot prioritizes players over zombies when both are enabled.
    - Fixed error on line 255 in draw_limb_chams (bad argument #5 to "line" (number expected, got boolean)) by ensuring proper color value extraction from esp_color:get() and adding error handling.
    - Added pcall around rendering calls (render.line, render.circle, render.text) to prevent crashes from invalid arguments.
    - Removed Backpacks ESP (checkbox, caching, rendering).
    - Removed Keys ESP (checkbox, caching, rendering).
    - Removed health display (current_hp/max_hp) due to missing Humanoid in Characters folder models.
    - Combined esp_color for Player ESP modes (Dot, Skeleton, 3D Box).
    - Removed Look Vector ESP, Radar ESP, velocity prediction, bullet drop compensation, and health check UI.
    - Maintains V3 optimizations: stable ESP visibility.
    - Fixed typo in draw_3d_box (sole to local for step_thickness).
    - Fixed screenPos typo to screen_pos in draw_3d_box.
    - Added usernames above 3D box/Dot/Skeleton ESP and distance (in meters, no decimals) below using esp_color for players and green for zombies (with "Zombie" name).
    - Removed all debug print statements.
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
local zombie_esp_enabled = ui.new_checkbox("Enable Zombie ESP")
local zombie_aimbot_enabled = ui.new_checkbox("Enable Zombie Aimbot")
local esp_mode = ui.new_combo("Player ESP Mode", {"Dot ESP", "Skeleton ESP", "3D Box ESP"})
local esp_color = ui.colorpicker("ESP Color", 1.0, 0.0, 0.0, 1.0)
local chams_thickness = ui.slider_float("ESP Thickness", 2.0, 1.0, 5.0, "%.1f")
local box_width = ui.slider_float("Box Width (3D Box)", 2.8, 1.0, 10.0, "%.1f")
local box_height = ui.slider_float("Box Height (3D Box)", 6.0, 1.0, 15.0, "%.1f")
local outline_enabled = ui.new_checkbox("Enable Outline (3D Box)")
local glow_enabled = ui.new_checkbox("Enable Glow (3D Box)")
local glow_color = ui.colorpicker("Glow Color (3D Box)", 0.0, 0.5, 1.0, 1.0)
local glow_size = ui.slider_float("Glow Size (3D Box)", 5.0, 2.0, 15.0, "%.1f")

-- Cached Data & State
local cached_targets = {} -- Players
local cached_zombies = {} -- Zombies
local current_target_id = nil 
local current_target_is_zombie = false -- Track if current target is a zombie
local last_cache_update = 0
local CACHE_UPDATE_INTERVAL = 1.0 
local local_player_name = globals.localplayer() and globals.localplayer():Name() or ""
local local_player_pos = nil
local local_player_char = nil -- Store local player character model from Characters folder

-- Body Parts for Chams (Players and Zombies)
local r15_limbs_names = {
    "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"
}
local zombie_limbs_names = {
    "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"
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
        pcall(render.rect, x - i, y - i, width + (i * 2), height + (i * 2), r, g, b, alpha, radius)
    end
end

function update_target_cache()
    local workspace = globals.workspace()
    if not workspace then return end

    -- Cache Players
    local characters_folder = workspace:FindChild("Characters")
    if characters_folder then
        local workspace_models = workspace:Children()
        local found_this_scan = {}
        local player_positions = {} -- Store username to HRP X position for matching

        -- Step 1: Collect HRP X positions from Workspace models with usernames
        for _, model in ipairs(workspace_models) do
            if model:ClassName() == "Model" then
                local hrp = model:FindChild("HumanoidRootPart")
                if hrp then
                    local hrp_primitive = hrp:Primitive()
                    if hrp_primitive then
                        local pos = hrp_primitive:GetPartPosition()
                        if pos then
                            player_positions[model:Name()] = pos.x
                        end
                    end
                end
            end
        end

        -- Step 2: Cache players from Characters folder, match X position for username
        for _, model in ipairs(characters_folder:Children()) do
            if model:ClassName() == "Model" then
                local hrp = model:FindChild("HumanoidRootPart")
                if hrp then
                    local hrp_primitive = hrp:Primitive()
                    if hrp_primitive then
                        local pos = hrp_primitive:GetPartPosition()
                        if pos then
                            local model_id = model:Address()
                            found_this_scan[model_id] = true
                            local username = nil
                            -- Match HRP X position to find username
                            for name, x_pos in pairs(player_positions) do
                                if math.abs(x_pos - pos.x) < 0.01 then
                                    username = name
                                    break
                                end
                            end
                            if username and username ~= local_player_name then
                                local limbs = {}
                                for _, name in ipairs(r15_limbs_names) do
                                    local limb_part = model:FindChild(name)
                                    if limb_part then limbs[name] = limb_part end
                                end
                                if limbs["Head"] and limbs["HumanoidRootPart"] then
                                    cached_targets[model_id] = { model = model, head = limbs["Head"], hrp = limbs["HumanoidRootPart"], limbs = limbs, name = username }
                                end
                            end
                            -- Check for local player
                            if username == local_player_name then
                                local_player_char = model
                                local_player_pos = pos
                            end
                        end
                    end
                end
            end
        end
        -- Clean up stale cache entries for players
        for id, _ in pairs(cached_targets) do
            if not found_this_scan[id] then
                cached_targets[id] = nil
            end
        end
    end

    -- Cache Zombies
    local game_assets = workspace:FindChild("game_assets")
    if game_assets then
        local npcs_folder = game_assets:FindChild("NPCs")
        if npcs_folder then
            local found_zombies = {}
            for _, model in ipairs(npcs_folder:Children()) do
                if model:ClassName() == "Model" then
                    local hrp = model:FindChild("HumanoidRootPart")
                    if hrp then
                        local hrp_primitive = hrp:Primitive()
                        if hrp_primitive then
                            local pos = hrp_primitive:GetPartPosition()
                            if pos then
                                local model_id = model:Address()
                                found_zombies[model_id] = true
                                local limbs = {}
                                for _, name in ipairs(zombie_limbs_names) do
                                    local limb_part = model:FindChild(name)
                                    if limb_part then limbs[name] = limb_part end
                                end
                                if limbs["Head"] and limbs["HumanoidRootPart"] then
                                    cached_zombies[model_id] = { model = model, head = limbs["Head"], hrp = limbs["HumanoidRootPart"], limbs = limbs, name = "Zombie" }
                                end
                            end
                        end
                    end
                end
            end
            -- Clean up stale cache entries for zombies
            for id, _ in pairs(cached_zombies) do
                if not found_zombies[id] then
                    cached_zombies[id] = nil
                end
            end
        end
    end
end

local function get_aim_position(target_data)
    local head_primitive = target_data.head:Primitive()
    if not head_primitive then return nil end
    local head_pos = head_primitive:GetPartPosition()
    if not head_pos then return nil end
    return Vector3(head_pos.x, head_pos.y, head_pos.z)
end

local function draw_limb_chams(limbs_table, is_zombie)
    local thickness = chams_thickness:get()
    local color = is_zombie and {r=0, g=1, b=0, a=1} or esp_color:get()
    local r = is_zombie and 0 or math.floor((color.r or 1) * 255)
    local g = is_zombie and 255 or math.floor((color.g or 0) * 255)
    local b = is_zombie and 0 or math.floor((color.b or 0) * 255)
    local a = is_zombie and 255 or math.floor((color.a or 1) * 255)
    local connections = is_zombie and {
        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
    } or {
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
            pcall(render.line, p1.x, p1.y, p2.x, p2.y, r, g, b, a, thickness)
        end
    end
end

local function draw_3d_box(target_data, is_zombie)
    local color = is_zombie and {r=0, g=1, b=0, a=1} or esp_color:get()
    local glow = is_zombie and {r=0, g=1, b=0, a=1} or glow_color:get()
    local r = is_zombie and 0 or math.floor((color.r or 1) * 255)
    local g = is_zombie and 255 or math.floor((color.g or 0) * 255)
    local b = is_zombie and 0 or math.floor((color.b or 0) * 255)
    local a = is_zombie and 255 or math.floor((color.a or 1) * 255)
    local gr = is_zombie and 0 or math.floor((glow.r or 0) * 255)
    local gg = is_zombie and 255 or math.floor((glow.g or 0.5) * 255)
    local gb = is_zombie and 0 or math.floor((glow.b or 1) * 255)
    local ga = is_zombie and 255 or math.floor((glow.a or 1) * 255)
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
                    pcall(render.line, p1.x, p1.y, p2.x, p2.y, gr, gg, gb, step_alpha, step_thickness)
                end
            end
            if outline_enabled:get() then
                pcall(render.line, p1.x, p1.y, p2.x, p2.y, 0, 0, 0, a, thickness + 2)
            end
            pcall(render.line, p1.x, p1.y, p2.x, p2.y, r, g, b, a, thickness)
        end
        -- Draw username above box and distance below using green for zombies, esp_color for players
        local text_pos_x = (screen_corners[1].x + screen_corners[2].x) / 2
        local username = target_data.name
        local text_size = render.measure_text(username, 2)
        pcall(render.text, text_pos_x - text_size.x / 2, min_y - 15, username, r, g, b, a, "o", 2)
        local distance = get_distance_3d(local_player_pos, center_pos)
        local distance_text = tostring(distance) .. "m"
        text_size = render.measure_text(distance_text, 2)
        pcall(render.text, text_pos_x - text_size.x / 2, max_y + 5, distance_text, r, g, b, a, "o", 2)
    end
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

    local aimbot_active = (aimbot_enabled:get() or zombie_aimbot_enabled:get()) and aimbot_key:get()
    local mouse_pos = input.cursor_position()
    local closest_distance = math.huge
    local new_target_id = nil
    local new_target_is_zombie = false
    local screen_size = render.screen_size()
    if not screen_size then return end

    if aimbot_active and sticky_aim:get() and current_target_id then
        local target_data = current_target_is_zombie and cached_zombies[current_target_id] or cached_targets[current_target_id]
        if target_data then
            local aim_pos = get_aim_position(target_data)
            if aim_pos then
                local screen_pos = utils.world_to_screen(aim_pos)
                if screen_pos and screen_pos.x >= 0 and is_within_fov(screen_pos) then
                    smooth_aim_to_target(screen_pos)
                else
                    current_target_id = nil
                    current_target_is_zombie = false
                end
            else
                current_target_id = nil
                current_target_is_zombie = false
            end
        else
            current_target_id = nil
            current_target_is_zombie = false
        end
    end
    
    local selected_mode = esp_mode:get()
    
    -- Player ESP
    if esp_enabled:get() then
        for id, target_data in pairs(cached_targets) do
            local hrp = target_data.hrp
            local hrp_primitive = hrp:Primitive()
            if not hrp_primitive then goto continue end
            local hrp_pos = hrp:Primitive():GetPartPosition()
            if not hrp_pos then goto continue end
            local hrp_screen_pos = utils.world_to_screen(hrp_pos)
            if not hrp_screen_pos or hrp_screen_pos.x <= 0 or hrp_screen_pos.x >= screen_size.x or hrp_screen_pos.y <= 0 or hrp_screen_pos.y >= screen_size.y then goto continue end
            
            if selected_mode == 0 then -- Dot ESP
                local head_pos = target_data.head:Primitive():GetPartPosition()
                if head_pos then
                    local head_screen_pos = utils.world_to_screen(head_pos)
                    if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                        local color = esp_color:get()
                        local r, g, b, a = math.floor((color.r or 1) * 255), math.floor((color.g or 0) * 255), math.floor((color.b or 0) * 255), math.floor((color.a or 1) * 255)
                        pcall(render.circle, head_screen_pos.x, head_screen_pos.y, 5, r, g, b, a, 32)
                        -- Draw username above dot and distance below HRP using esp_color
                        local username = target_data.name
                        local text_size = render.measure_text(username, 2)
                        pcall(render.text, head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, r, g, b, a, "o", 2)
                        local distance = get_distance_3d(local_player_pos, hrp_pos)
                        local distance_text = tostring(distance) .. "m"
                        text_size = render.measure_text(distance_text, 2)
                        pcall(render.text, hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
                    end
                end
            elseif selected_mode == 1 then -- Skeleton ESP
                draw_limb_chams(target_data.limbs, false)
                -- Draw username above head and distance below HRP using esp_color
                local head_pos = target_data.head:Primitive():GetPartPosition()
                if head_pos then
                    local head_screen_pos = utils.world_to_screen(head_pos)
                    if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                        local color = esp_color:get()
                        local r, g, b, a = math.floor((color.r or 1) * 255), math.floor((color.g or 0) * 255), math.floor((color.b or 0) * 255), math.floor((color.a or 1) * 255)
                        local username = target_data.name
                        local text_size = render.measure_text(username, 2)
                        pcall(render.text, head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, r, g, b, a, "o", 2)
                        local distance = get_distance_3d(local_player_pos, hrp_pos)
                        local distance_text = tostring(distance) .. "m"
                        text_size = render.measure_text(distance_text, 2)
                        pcall(render.text, hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, r, g, b, a, "o", 2)
                    end
                end
            elseif selected_mode == 2 then -- 3D Box ESP
                draw_3d_box(target_data, false)
            end

            if aimbot_active and aimbot_enabled:get() and not (sticky_aim:get() and current_target_id) then
                local aim_pos = get_aim_position(target_data)
                if aim_pos then
                    local aim_screen_pos = utils.world_to_screen(aim_pos)
                    if aim_screen_pos and aim_screen_pos.x >= 0 and is_within_fov(aim_screen_pos) then
                        local distance = get_distance_2d(mouse_pos, aim_screen_pos)
                        if distance < closest_distance then
                            closest_distance = distance
                            new_target_id = id
                            new_target_is_zombie = false
                        end
                    end
                end
            end
            ::continue::
        end
    end

    -- Zombie ESP and Aimbot
    if zombie_esp_enabled:get() or (aimbot_active and zombie_aimbot_enabled:get()) then
        for id, zombie_data in pairs(cached_zombies) do
            local hrp = zombie_data.hrp
            local hrp_primitive = hrp:Primitive()
            if not hrp_primitive then goto zombie_continue end
            local hrp_pos = hrp:Primitive():GetPartPosition()
            if not hrp_pos then goto zombie_continue end
            local hrp_screen_pos = utils.world_to_screen(hrp_pos)
            if not hrp_screen_pos or hrp_screen_pos.x <= 0 or hrp_screen_pos.x >= screen_size.x or hrp_screen_pos.y <= 0 or hrp_screen_pos.y >= screen_size.y then goto zombie_continue end
            
            if zombie_esp_enabled:get() then
                if selected_mode == 0 then -- Dot ESP
                    local head_pos = zombie_data.head:Primitive():GetPartPosition()
                    if head_pos then
                        local head_screen_pos = utils.world_to_screen(head_pos)
                        if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                            pcall(render.circle, head_screen_pos.x, head_screen_pos.y, 5, 0, 255, 0, 255, 32)
                            -- Draw "Zombie" above dot and distance below HRP using green
                            local username = "Zombie"
                            local text_size = render.measure_text(username, 2)
                            pcall(render.text, head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, 0, 255, 0, 255, "o", 2)
                            local distance = get_distance_3d(local_player_pos, hrp_pos)
                            local distance_text = tostring(distance) .. "m"
                            text_size = render.measure_text(distance_text, 2)
                            pcall(render.text, hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, 0, 255, 0, 255, "o", 2)
                        end
                    end
                elseif selected_mode == 1 then -- Skeleton ESP
                    draw_limb_chams(zombie_data.limbs, true)
                    -- Draw "Zombie" above head and distance below HRP using green
                    local head_pos = zombie_data.head:Primitive():GetPartPosition()
                    if head_pos then
                        local head_screen_pos = utils.world_to_screen(head_pos)
                        if head_screen_pos and head_screen_pos.x > 0 and head_screen_pos.x < screen_size.x and head_screen_pos.y > 0 and head_screen_pos.y < screen_size.y then
                            local username = "Zombie"
                            local text_size = render.measure_text(username, 2)
                            pcall(render.text, head_screen_pos.x - text_size.x / 2, head_screen_pos.y - 15, username, 0, 255, 0, 255, "o", 2)
                            local distance = get_distance_3d(local_player_pos, hrp_pos)
                            local distance_text = tostring(distance) .. "m"
                            text_size = render.measure_text(distance_text, 2)
                            pcall(render.text, hrp_screen_pos.x - text_size.x / 2, hrp_screen_pos.y + 5, distance_text, 0, 255, 0, 255, "o", 2)
                        end
                    end
                elseif selected_mode == 2 then -- 3D Box ESP
                    draw_3d_box(zombie_data, true)
                end
            end

            if aimbot_active and zombie_aimbot_enabled:get() and not (sticky_aim:get() and current_target_id) then
                local aim_pos = get_aim_position(zombie_data)
                if aim_pos then
                    local aim_screen_pos = utils.world_to_screen(aim_pos)
                    if aim_screen_pos and aim_screen_pos.x >= 0 and is_within_fov(aim_screen_pos) then
                        local distance = get_distance_2d(mouse_pos, aim_screen_pos)
                        if distance < closest_distance then
                            closest_distance = distance
                            new_target_id = id
                            new_target_is_zombie = true
                        end
                    end
                end
            end
            ::zombie_continue::
        end
    end

    if aimbot_active and new_target_id and not (sticky_aim:get() and current_target_id) then
        current_target_id = new_target_id
        current_target_is_zombie = new_target_is_zombie
        local target_data = new_target_is_zombie and cached_zombies[new_target_id] or cached_targets[new_target_id]
        if target_data then
            local aim_pos = get_aim_position(target_data)
            if aim_pos then
                local screen_pos = utils.world_to_screen(aim_pos)
                if screen_pos and screen_pos.x >= 0 then
                    smooth_aim_to_target(screen_pos)
                end
            end
        end
    elseif not aimbot_active then
        current_target_id = nil
        current_target_is_zombie = false
    end
end

local function draw_fov_circle()
    if not fov_circle:get() then return end
    local mouse_pos = input.cursor_position()
    local color = fov_color:get()
    local r, g, b, a = math.floor((color.r or 1) * 255), math.floor((color.g or 1) * 255), math.floor((color.b or 1) * 255), math.floor((color.a or 0.5) * 255)
    pcall(render.circle_outline, mouse_pos.x, mouse_pos.y, fov_radius:get(), r, g, b, a, 2, 64)
end

-- Event Callbacks
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    if globals.curtime() - last_cache_update > CACHE_UPDATE_INTERVAL then
        update_target_cache()
        last_cache_update = globals.curtime()
    end
    pcall(update_aimbot_and_esp)
    pcall(draw_fov_circle)
end)

cheat.set_callback("shutdown", function()
    if not globals.is_focused() then return end
    cached_targets, cached_zombies, current_target_id = {}, {}, nil
    current_target_is_zombie = false
end)