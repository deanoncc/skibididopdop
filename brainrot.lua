-- Load the required data
local DBrainrots = {
    ["Noobini Pizzanini"] = { Rarity = "Common", Income = "1", Price = "25" },
    ["Lirilì Larilà"] = { Rarity = "Common", Income = "3", Price = "250" },
    ["Tim Cheese"] = { Rarity = "Common", Income = "5", Price = "500" },
    ["Fluriflura"] = { Rarity = "Common", Income = "7", Price = "750" },
    ["Talpa Di Fero"] = { Rarity = "Common", Income = "9", Price = "1K" },
    ["Svinina Bombardino"] = { Rarity = "Common", Income = "10", Price = "1.2K" },
    ["Pipi Kiwi"] = { Rarity = "Common", Income = "13", Price = "1.5K" },
    ["Trippi Troppi"] = { Rarity = "Rare", Income = "15", Price = "2K" },
    ["Tung Tung Tung Sahur"] = { Rarity = "Rare", Income = "25", Price = "3K" },
    ["Gangster Footera"] = { Rarity = "Rare", Income = "30", Price = "4K" },
    ["Bandito Bobritto"] = { Rarity = "Rare", Income = "35", Price = "4.5K" },
    ["Boneca Ambalabu"] = { Rarity = "Rare", Income = "40", Price = "5K" },
    ["Cacto Hipopotamo"] = { Rarity = "Rare", Income = "50", Price = "6.5K" },
    ["Ta Ta Ta Ta Sahur"] = { Rarity = "Rare", Income = "55", Price = "7.5K" },
    ["Tric Trac Baraboom"] = { Rarity = "Rare", Income = "65", Price = "9K" },
    ["Cappuccino Assassino"] = { Rarity = "Epic", Income = "75", Price = "10K" },
    ["Brr Brr Patapim"] = { Rarity = "Epic", Income = "100", Price = "15K" },
    ["Trulimero Trulicina"] = { Rarity = "Epic", Income = "125", Price = "20K" },
    ["Bambini Crostini"] = { Rarity = "Epic", Income = "130", Price = "22.5K" },
    ["Bananita Dolphinita"] = { Rarity = "Epic", Income = "150", Price = "25K" },
    ["Perochello Lemonchello"] = { Rarity = "Epic", Income = "160", Price = "27.5K" },
    ["Brri Brri Bicus Dicus Bombicus"] = { Rarity = "Epic", Income = "175", Price = "30K" },
    ["Avocadini Guffo"] = { Rarity = "Epic", Income = "225", Price = "35K" },
    ["Salamino Penguini"] = { Rarity = "Epic", Income = "250", Price = "40K" },
    ["Burbaloni Loliloli"] = { Rarity = "Legendary", Income = "200", Price = "35K" },
    ["Chimpanzini Bananini"] = { Rarity = "Legendary", Income = "300", Price = "50K" },
    ["Ballerina Cappuccina"] = { Rarity = "Legendary", Income = "500", Price = "100K" },
    ["Chef Crabracadabra"] = { Rarity = "Legendary", Income = "600", Price = "150K" },
    ["Lionel Cactuseli"] = { Rarity = "Legendary", Income = "650", Price = "175K" },
    ["Glorbo Fruttodrillo"] = { Rarity = "Legendary", Income = "750", Price = "200K" },
    ["Blueberrinni Octopusini"] = { Rarity = "Legendary", Income = "1K", Price = "250K" },
    ["Strawberelli Flamingelli"] = { Rarity = "Legendary", Income = "1.1K", Price = "275K" },
    ["Pandaccini Bananini"] = { Rarity = "Legendary", Income = "1.2K", Price = "300K" },
    ["Frigo Camelo"] = { Rarity = "Mythic", Income = "1.4K", Price = "300K" },
    ["Orangutini Ananassini"] = { Rarity = "Mythic", Income = "1.7K", Price = "400K" },
    ["Rhino Toasterino"] = { Rarity = "Mythic", Income = "2.1K", Price = "450K" },
    ["Bombardiro Crocodilo"] = { Rarity = "Mythic", Income = "2.5K", Price = "500K" },
    ["Bombombini Gusini"] = { Rarity = "Mythic", Income = "5K", Price = "1M" },
    ["Cavallo Virtuoso"] = { Rarity = "Mythic", Income = "7.5K", Price = "2.5M" },
    ["Gorillo Watermelondrillo"] = { Rarity = "Mythic", Income = "8K", Price = "3M" },
    ["Spioniro Golubiro"] = { Rarity = "Mythic", Income = "3.5K", Price = "750K" },
    ["Zibra Zubra Zibralini"] = { Rarity = "Mythic", Income = "6K", Price = "1M" },
    ["Tigrilini Watermelini"] = { Rarity = "Mythic", Income = "6.5K", Price = "1M" },
    ["Cocofanto Elefanto"] = { Rarity = "Brainrot God", Income = "10K", Price = "5M" },
    ["Girafa Celestre"] = { Rarity = "Brainrot God", Income = "20K", Price = "7.5M" },
    ["Gattatino Neonino"] = { Rarity = "Brainrot God", Income = "35K", Price = "7.5M" },
    ["Matteo"] = { Rarity = "Brainrot God", Income = "50K", Price = "10M" },
    ["Tralalero Tralala"] = { Rarity = "Brainrot God", Income = "50K", Price = "10M" },
    ["Los Crocodillitos"] = { Rarity = "Brainrot God", Income = "55K", Price = "12.5M" },
    ["Espresso Signora"] = { Rarity = "Brainrot God", Income = "70K", Price = "25M" },
    ["Odin Din Din Dun"] = { Rarity = "Brainrot God", Income = "75K", Price = "15M" },
    ["Statutino Libertino"] = { Rarity = "Brainrot God", Income = "75K", Price = "20M" },
    ["Trenostruzzo Turbo 3000"] = { Rarity = "Brainrot God", Income = "150K", Price = "25M" },
    ["Ballerino Lololo"] = { Rarity = "Brainrot God", Income = "200K", Price = "35M" },
    ["Piccione Macchina"] = { Rarity = "Brainrot God", Income = "225K", Price = "40M" },
    ["Tigroligre Frutonni"] = { Rarity = "Brainrot God", Income = "60K", Price = "15M" },
    ["Orcalero Orcala"] = { Rarity = "Brainrot God", Income = "100K", Price = "15M" },
    ["La Vacca Saturno Saturnita"] = { Rarity = "Secret", Income = "250K", Price = "50M" },
    ["Chimpanzini Spiderini"] = { Rarity = "Secret", Income = "325K", Price = "100M" },
    ["Los Tralaleritos"] = { Rarity = "Secret", Income = "500K", Price = "150M" },
    ["Las Tralaleritas"] = { Rarity = "Secret", Income = "650K", Price = "150M" },
    ["Las Vaquitas Saturnitas"] = { Rarity = "Secret", Income = "750K", Price = "200M" },
    ["Graipuss Medussi"] = { Rarity = "Secret", Income = "1M", Price = "250M" },
    ["Chicleteira Bicicletera"] = { Rarity = "Secret", Income = "3.5M", Price = "750M" },
    ["La Grande Combinasion"] = { Rarity = "Secret", Income = "10M", Price = "1B" },
    ["Nuclearo Dinossauro"] = { Rarity = "Secret", Income = "15M", Price = "2.5B" },
    ["Garama and Madundung"] = { Rarity = "Secret", Income = "50M", Price = "10B" },
    ["Torrtuginni Dragonfrutini"] = { Rarity = "Secret", Income = "350K", Price = "500M" },
    ["Pot Hotspot"] = { Rarity = "Secret", Income = "2.5M", Price = "500M" }
}

local RColors = {
    ["Default"] = {r = 1.0, g = 1.0, b = 1.0}, -- White
    ["Common"] = {r = 85/255, g = 255/255, b = 85/255}, -- Green
    ["Rare"] = {r = 85/255, g = 170/255, b = 255/255}, -- Light Blue
    ["Epic"] = {r = 170/255, g = 85/255, b = 255/255}, -- Purple
    ["Legendary"] = {r = 255/255, g = 215/255, b = 0/255}, -- Gold
    ["Mythic"] = {r = 255/255, g = 85/255, b = 85/255}, -- Red
    ["Secret"] = {r = 200/255, g = 200/255, b = 200/255}, -- Gray
    ["Brainrot God"] = {r = 255/255, g = 0/255, b = 255/255} -- Magenta
}

-- Create UI elements for font selection and toggles
local font_combo = ui.new_combo("Font", {"Default", "Pixel", "Normal", "Bold", "Normal Anti-aliased"})
local esp_toggle = ui.new_checkbox("Enable ESP")
local name_toggle = ui.new_checkbox("Show NPC Name")
local value_toggle = ui.new_checkbox("Show Value")
local income_toggle = ui.new_checkbox("Show Income")
local distance_toggle = ui.new_checkbox("Show Distance")
local valuable_toggle = ui.new_checkbox("Draw only valuable")

-- Main paint callback to render NPC labels with rarity-based colors
cheat.set_callback("paint", function()
    if not globals.is_focused() then return end
    -- Check if ESP is enabled
    if not esp_toggle:get() then
        return
    end

    -- Get the local player
    local local_player = globals.localplayer()
    
    -- Get the local player's position
    local player_model = local_player:ModelInstance()
    local humanoid_root = player_model:FindChild("HumanoidRootPart")
    local player_pos = humanoid_root:Primitive():GetPartPosition()
    
    -- Navigate to Workspace
    local workspace = globals.workspace()
    
    -- Get all models in Workspace
    local models = workspace:Children()
    
    -- Get selected font
    local font_index = font_combo:get() -- 0-based index (0: Default, 1: Pixel, 2: Normal, 3: Bold, 4: Normal Anti-aliased)
    
    -- Iterate through each model
    for _, model in ipairs(models) do
        -- Check if the model is a valid NPC in DBrainrots
        local npc_data = DBrainrots[model:Name()]
        if npc_data and model:ClassName() == "Model" then
            -- Check if only valuable NPCs should be drawn
            if valuable_toggle:get() and not (npc_data.Rarity == "Secret" or npc_data.Rarity == "Brainrot God") then
                goto continue
            end
            
            -- Find the first MeshPart or Part in the Model
            local part = model:FindChildByClass("MeshPart") or model:FindChildByClass("Part")
            if part then
                local item_pos = part:Primitive():GetPartPosition()
                
                -- Calculate distance from player to NPC
                local distance = math.sqrt(
                    (player_pos.x - item_pos.x)^2 +
                    (player_pos.y - item_pos.y)^2 +
                    (player_pos.z - item_pos.z)^2
                )
                
                -- Convert 3D position to 2D screen coordinates
                local screen_pos = utils.world_to_screen(item_pos)
                if screen_pos then
                    -- Get rarity and corresponding color
                    local rarity = npc_data.Rarity
                    local color = RColors[rarity] or RColors["Default"]
                    
                    -- Convert color to 0-255 range for render.text
                    local r = math.floor(color.r * 255)
                    local g = math.floor(color.g * 255)
                    local b = math.floor(color.b * 255)
                    local a = 255 -- Full opacity
                    
                    -- Prepare text lines based on toggles
                    local texts = {}
                    if name_toggle:get() then
                        table.insert(texts, model:Name()) -- NPC name
                    end
                    if value_toggle:get() then
                        table.insert(texts, "Value: " .. npc_data.Price)
                    end
                    if income_toggle:get() then
                        table.insert(texts, "Income: " .. npc_data.Income .. "/sec")
                    end
                    if distance_toggle:get() then
                        table.insert(texts, string.format("%dm", math.floor(distance))) -- Distance rounded to integer
                    end
                    
                    -- Measure text sizes and calculate positions
                    local max_width = 0
                    local text_sizes = {}
                    local total_height = 0
                    for i, text in ipairs(texts) do
                        local size = render.measure_text(text, font_index)
                        text_sizes[i] = size
                        max_width = math.max(max_width, size.x)
                        total_height = total_height + size.y + (i > 1 and 2 or 0) -- 2px gap between lines (except first)
                    end
                    
                    -- Calculate starting Y position to center vertically
                    local start_y = screen_pos.y - total_height / 2
                    
                    -- Draw each text line
                    for i, text in ipairs(texts) do
                        local offset_x = text_sizes[i].x / 2
                        render.text(
                            screen_pos.x - offset_x, -- Centered x
                            start_y, -- Adjust y for each line
                            text,
                            r, g, b, a, -- Rarity-based color
                            "os", -- Outline and shadow
                            font_index -- Selected font
                        )
                        start_y = start_y + text_sizes[i].y + 2 -- Move to next line with gap
                    end
                end
            end
        end
        ::continue::
    end

end)
