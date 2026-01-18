-- === ABA AUTO-- Carrega a biblioteca LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis Globais
_G.HeadSize = 10
_G.Disabled = false
_G.HitboxColor = Color3.fromRGB(255, 140, 0) -- Laranja

-- Variáveis do Auto Farm
local autoFarmEnabled = false
local currentTarget = nil
local hasPickedCharacter = false
local clickConnection = nil
local antiAFKEnabled = true
local personagemSelecionado = "Muteno Evil"
local autoPegarAtivado = false
local personagemAutoPegar = "Muteno Evil"

-- Coordenadas dos personagens
local PersonagensCoords = {
    -- HERÓIS PRINCIPAIS
    ["Estelar"] = Vector3.new(5.99, 339.20, -0.58),
    ["Robin"] = Vector3.new(6.45, 342.46, 22.14),
    ["Ciborgue"] = Vector3.new(7.05, 338.49, 12.33),
    ["Ravena"] = Vector3.new(6.71, 338.44, 35.39),
    ["Mutano"] = Vector3.new(6.87, 338.39, 48.06),
    
    -- VILÕES PRINCIPAIS
    ["Muteno Evil"] = Vector3.new(168.34, 338.49, 33.62),
    ["Estelar Evil"] = Vector3.new(164.23, 338.49, 23.42),
    ["Ciborgue Evil"] = Vector3.new(168.84, 338.49, 14.69),
    ["Morte Vermelha"] = Vector3.new(31.01, 338.49, 14.78),
    ["Slayer"] = Vector3.new(30.92, 338.48, 23.78),
    ["Goliath"] = Vector3.new(50.72, 338.49, 13.16),
    
    -- HERÓIS ADICIONAIS
    ["Apprentice (Aprendiz)"] = Vector3.new(-323.00, 189.36, -318.02),
    ["Gadget (Gadget)"] = Vector3.new(50.01, 338.28, 31.40),
    ["Lynx (Lince)"] = Vector3.new(50.67, 338.46, 23.16),
    ["Vision (Visão)"] = Vector3.new(50.79, 338.20, 7.94),
    ["Blacklight (Luz Negra)"] = Vector3.new(51.49, 338.39, -19.72),
    ["Maya (Maya)"] = Vector3.new(-322.77, 189.64, -317.63),
    ["Golem (Golem)"] = Vector3.new(88.11, 338.30, 22.66),
    ["Sentinel (Sentinela)"] = Vector3.new(127.89, 338.39, 22.62),
    ["Aquaman (Aquaman)"] = Vector3.new(146.99, 340.89, 5.38),
    ["Arrow (Flecha)"] = Vector3.new(146.33, 340.17, 14.45),
    ["Honeybee (Abelha)"] = Vector3.new(145.47, 340.36, 22.88),
    ["Plus Minus (Mais Menos)"] = Vector3.new(145.71, 340.89, 33.44),
    ["Lightspeed (Velocidade Luz)"] = Vector3.new(146.40, 338.28, 43.83),
    ["Wicked Tempest (Tempestade)"] = Vector3.new(51.08, 338.31, 69.07),
    ["Duke Splitter (Duque)"] = Vector3.new(50.54, 338.58, 41.21),
    ["Overlord (Overlord)"] = Vector3.new(182.64, 338.44, 23.58)
}

-- Cria a janela principal
local Window = Library:CreateWindow({
    Title = 'Titans Background PVP',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Cria as abas
local Tabs = {
    Main = Window:AddTab('Main'),
    AutoFarm = Window:AddTab('Auto Farm'),
    Characters = Window:AddTab('Personagens'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- === ANTI-AFK SYSTEM ===
player.Idled:Connect(function()
    if antiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while task.wait(300) do
        if antiAFKEnabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end
    end
end)

-- === ABA MAIN - HITBOX ===
local HitboxGroup = Tabs.Main:AddLeftGroupbox('Hitbox')

HitboxGroup:AddToggle('HitboxToggle', {
    Text = 'HITBOX',
    Default = false,
    Tooltip = 'Ativa ou desativa a hitbox expandida',
    Callback = function(Value)
        _G.Disabled = Value
        
        if not Value then
            for i, v in next, Players:GetPlayers() do
                if v.Name ~= player.Name then
                    pcall(function()
                        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                            v.Character.HumanoidRootPart.Transparency = 1
                            v.Character.HumanoidRootPart.CanCollide = false
                        end
                    end)
                end
            end
        end
    end
})

HitboxGroup:AddSlider('HitboxSize', {
    Text = 'Tamanho da Hitbox',
    Default = 10,
    Min = 10,
    Max = 80,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.HeadSize = Value
    end
})

HitboxGroup:AddLabel('Cor da Hitbox'):AddColorPicker('HitboxColor', {
    Default = Color3.fromRGB(255, 140, 0),
    Title = 'Cor da Hitbox',
    Transparency = 0,
    Callback = function(Value)
        _G.HitboxColor = Value
    end
})

HitboxGroup:AddDivider()
HitboxGroup:AddLabel('Informações:')
HitboxGroup:AddLabel('• Ative o HITBOX para expandir')
HitboxGroup:AddLabel('• Ajuste o tamanho conforme necessário')
HitboxGroup:AddLabel('• Personalize a cor da hitbox')

-- Sistema de Hitbox
RunService.RenderStepped:Connect(function()
    if _G.Disabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character then
                pcall(function()
                    local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        hrp.Transparency = 0.7
                        hrp.Color = _G.HitboxColor
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end)
            end
        end
    end
end)

-- === ABA PERSONAGENS (AUTO-PEGAR AO MORRER) ===
local CharacterGroup = Tabs.Characters:AddLeftGroupbox('Auto-Pegar Personagem')

CharacterGroup:AddLabel('Esta função pega o personagem')
CharacterGroup:AddLabel('automaticamente quando você morrer!')

CharacterGroup:AddDivider()

CharacterGroup:AddDropdown('AutoPickCharacterSelect', {
    Values = { 
        'Muteno Evil', 
        'Mutano', 
        'Robin',
        'Estelar', 
        'Ciborgue', 
        'Ravena', 
        'Estelar Evil',
        'Ciborgue Evil',
        'Morte Vermelha',
        'Slayer',
        'Goliath',
        'Apprentice (Aprendiz)',
        'Gadget (Gadget)',
        'Lynx (Lince)',
        'Vision (Visão)',
        'Blacklight (Luz Negra)',
        'Maya (Maya)',
        'Golem (Golem)',
        'Sentinel (Sentinela)',
        'Aquaman (Aquaman)',
        'Arrow (Flecha)',
        'Honeybee (Abelha)',
        'Plus Minus (Mais Menos)',
        'Lightspeed (Velocidade Luz)',
        'Wicked Tempest (Tempestade)',
        'Duke Splitter (Duque)',
        'Overlord (Overlord)'
    },
    Default = 1,
    Multi = false,
    Text = 'Personagem para Auto-Pegar',
    Tooltip = 'Personagem que será pego ao morrer',
    Callback = function(Value)
        personagemAutoPegar = Value
        Library:Notify('Auto-Pegar: ' .. Value, 3)
    end
})

CharacterGroup:AddButton({
    Text = '🚀 Teleportar Agora',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local coords = PersonagensCoords[personagemAutoPegar]
            if coords then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(coords)
                Library:Notify('Teleportado para ' .. personagemAutoPegar .. '!', 3)
            end
        end
    end,
    Tooltip = 'Teleporta manualmente para o personagem selecionado'
})

CharacterGroup:AddDivider()

CharacterGroup:AddToggle('AutoPegarToggle', {
    Text = '🔄 Auto-Pegar ao Morrer',
    Default = false,
    Tooltip = 'Pega automaticamente o personagem selecionado quando você respawnar',
    Callback = function(Value)
        autoPegarAtivado = Value
        if Value then
            Library:Notify('Auto-Pegar ativado para ' .. personagemAutoPegar, 3)
        else
            Library:Notify('Auto-Pegar desativado', 3)
        end
    end
})

CharacterGroup:AddDivider()

CharacterGroup:AddLabel('Como funciona:')
CharacterGroup:AddLabel('1. Selecione o personagem')
CharacterGroup:AddLabel('2. Clique em Teleportar Agora OU')
CharacterGroup:AddLabel('3. Ative o Auto-Pegar')
CharacterGroup:AddLabel('4. Toda vez que morrer, você')
CharacterGroup:AddLabel('   será teleportado para pegar')
CharacterGroup:AddLabel('   o personagem automaticamente!')

-- Botões rápidos individuais
local QuickTeleportGroup = Tabs.Characters:AddRightGroupbox('Teleporte Rápido')

QuickTeleportGroup:AddLabel('🌟 HERÓIS:')

QuickTeleportGroup:AddButton({
    Text = '⭐ Estelar',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Estelar)
            Library:Notify('Teleportado para Estelar!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🦇 Robin ⭐',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Robin)
            Library:Notify('Teleportado para Robin!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🤖 Ciborgue',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Ciborgue)
            Library:Notify('Teleportado para Ciborgue!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🌑 Ravena',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Ravena)
            Library:Notify('Teleportado para Ravena!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🐾 Mutano ⭐',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Mutano)
            Library:Notify('Teleportado para Mutano!', 2)
        end
    end,
})

QuickTeleportGroup:AddDivider()
QuickTeleportGroup:AddLabel('😈 VILÕES:')

QuickTeleportGroup:AddButton({
    Text = '🐾 Muteno Evil ⭐⭐',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Muteno Evil"])
            Library:Notify('Teleportado para Muteno Evil!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '⭐ Estelar EVIL',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Estelar EVIL"])
            Library:Notify('Teleportado para Estelar EVIL!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🤖 Ciborgue EVIL',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Ciborgue EVIL"])
            Library:Notify('Teleportado para Ciborgue EVIL!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '💀 Morte Vermelha',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Morte Vermelha"])
            Library:Notify('Teleportado para Morte Vermelha!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '⚔️ Slayer',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Slayer)
            Library:Notify('Teleportado para Slayer!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '👹 Goliath',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords.Goliath)
            Library:Notify('Teleportado para Goliath!', 2)
        end
    end,
})

QuickTeleportGroup:AddDivider()
QuickTeleportGroup:AddLabel('🦸 HERÓIS ADICIONAIS:')

QuickTeleportGroup:AddButton({
    Text = '🎓 Apprentice',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Apprentice (Aprendiz)"])
            Library:Notify('Teleportado para Apprentice!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🔧 Gadget',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Gadget (Gadget)"])
            Library:Notify('Teleportado para Gadget!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🐆 Lynx',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Lynx (Lince)"])
            Library:Notify('Teleportado para Lynx!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '👁️ Vision',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Vision (Visão)"])
            Library:Notify('Teleportado para Vision!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🌑 Blacklight',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Blacklight (Luz Negra)"])
            Library:Notify('Teleportado para Blacklight!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '💃 Maya',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Maya (Maya)"])
            Library:Notify('Teleportado para Maya!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🗿 Golem',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Golem (Golem)"])
            Library:Notify('Teleportado para Golem!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🛡️ Sentinel',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Sentinel (Sentinela)"])
            Library:Notify('Teleportado para Sentinel!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🌊 Aquaman',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Aquaman (Aquaman)"])
            Library:Notify('Teleportado para Aquaman!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🏹 Arrow',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Arrow (Flecha)"])
            Library:Notify('Teleportado para Arrow!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🐝 Honeybee',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Honeybee (Abelha)"])
            Library:Notify('Teleportado para Honeybee!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '➕➖ Plus Minus',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Plus Minus (Mais Menos)"])
            Library:Notify('Teleportado para Plus Minus!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '⚡ Lightspeed',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Lightspeed (Velocidade Luz)"])
            Library:Notify('Teleportado para Lightspeed!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '🌪️ Wicked Tempest',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Wicked Tempest (Tempestade)"])
            Library:Notify('Teleportado para Wicked Tempest!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '👑 Duke Splitter',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Duke Splitter (Duque)"])
            Library:Notify('Teleportado para Duke Splitter!', 2)
        end
    end,
})

QuickTeleportGroup:AddButton({
    Text = '👿 Overlord',
    Func = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords["Overlord (Overlord)"])
            Library:Notify('Teleportado para Overlord!', 2)
        end
    end,
})

-- === FUNÇÕES DO AUTO FARM ===
local function isInSafeZone(targetPlayer)
    if not targetPlayer.Character then return true end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    if math.abs(hrp.Position.Y - 338) < 5 then return true end
    for _, child in pairs(targetPlayer.Character:GetDescendants()) do
        if child:IsA("ForceField") then return true end
        if child.Name:lower():find("safe") or child.Name:lower():find("zone") then return true end
    end
    return false
end

local function isPlayerAlive(targetPlayer)
    if not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function findNextTarget()
    local nearestTarget = nil
    local shortestDistance = math.huge
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and isPlayerAlive(targetPlayer) and not isInSafeZone(targetPlayer) then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and humanoidRootPart then
                local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestTarget = targetPlayer
                end
            end
        end
    end
    return nearestTarget
end

local function equipSlot1()
    local backpack = player:WaitForChild("Backpack")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then tool.Parent = backpack end
    end
    task.wait(0.05) -- Reduzido de 0.1 para 0.05
    
    local tools = {}
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(tools, item) end
    end
    if #tools == 0 then return false end
    
    humanoid:EquipTool(tools[1])
    task.wait(0.05) -- Reduzido de 0.1 para 0.05
    return true
end

local function startClicking()
    if clickConnection then clickConnection:Disconnect() end
    clickConnection = RunService.RenderStepped:Connect(function()
        if autoFarmEnabled then
            -- Clica no centro da tela ao invés do mouse
            local vpSize = workspace.CurrentCamera.ViewportSize
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(vpSize.X / 2, vpSize.Y / 2))
            task.wait()
            VirtualUser:Button1Up(Vector2.new(vpSize.X / 2, vpSize.Y / 2))
        end
    end)
end

local function stopClicking()
    if clickConnection then
        clickConnection:Disconnect()
        clickConnection = nil
    end
end

local function startAutoFarm()
    task.spawn(function()
        if not hasPickedCharacter then
            local coords = PersonagensCoords[personagemSelecionado]
            if coords and character and humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(coords)
                task.wait(1) -- Reduzido de 2 para 1 segundo
                hasPickedCharacter = true
            end
        end
        
        equipSlot1()
        task.wait(0.3) -- Reduzido de 0.5 para 0.3
        startClicking()
        
        while autoFarmEnabled do
            character = player.Character
            if not character then
                task.wait(0.5)
                continue
            end
            
            humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if not humanoid or humanoid.Health <= 0 then
                stopClicking()
                local newChar = player.CharacterAdded:Wait()
                character = newChar
                humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                humanoid = character:WaitForChild("Humanoid")
                task.wait(1) -- Reduzido de 2 para 1
                
                local coords = PersonagensCoords[personagemSelecionado]
                if coords then humanoidRootPart.CFrame = CFrame.new(coords) end
                task.wait(1) -- Reduzido de 2 para 1
                
                local equipped = false
                for i = 1, 5 do
                    equipped = equipSlot1()
                    if equipped then break end
                    task.wait(0.3) -- Reduzido de 0.5 para 0.3
                end
                
                task.wait(0.3) -- Reduzido de 0.5 para 0.3
                startClicking()
                continue
            end
            
            local equippedTool = character:FindFirstChildOfClass("Tool")
            if not equippedTool then
                equipSlot1()
                task.wait(0.2) -- Reduzido de 0.3 para 0.2
            end
            
            if currentTarget then
                if not isPlayerAlive(currentTarget) then
                    currentTarget = nil
                elseif isInSafeZone(currentTarget) then
                    currentTarget = nil
                end
            end
            
            if not currentTarget then
                currentTarget = findNextTarget()
            end
            
            if currentTarget and currentTarget.Character then
                local targetHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = currentTarget.Character:FindFirstChild("Humanoid")
                
                if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                    local offsetPosition = targetHRP.CFrame * CFrame.new(0, 0, 3)
                    humanoidRootPart.CFrame = offsetPosition
                else
                    currentTarget = nil
                end
            end
            
            RunService.Heartbeat:Wait()
        end
        
        stopClicking()
    end)
end

-- === ABA AUTO FARM ===
local FarmGroup = Tabs.AutoFarm:AddLeftGroupbox('Auto Farm')

FarmGroup:AddLabel('⭐ MELHORES PARA FARM:')
FarmGroup:AddLabel('• Muteno Evil (Recomendado)')
FarmGroup:AddLabel('• Mutano')
FarmGroup:AddLabel('• Robin')

FarmGroup:AddDivider()

-- Seleção de personagem para o Auto Farm
FarmGroup:AddDropdown('AutoFarmCharacterSelect', {
    Values = { 
        'Muteno Evil', 
        'Mutano', 
        'Robin',
        '--- HERÓIS PRINCIPAIS ---',
        'Estelar', 
        'Ciborgue', 
        'Ravena',
        '--- VILÕES PRINCIPAIS ---',
        'Estelar Evil',
        'Ciborgue Evil',
        'Morte Vermelha',
        'Slayer',
        'Goliath',
        '--- HERÓIS ADICIONAIS ---',
        'Apprentice (Aprendiz)',
        'Gadget (Gadget)',
        'Lynx (Lince)',
        'Vision (Visão)',
        'Blacklight (Luz Negra)',
        'Maya (Maya)',
        'Golem (Golem)',
        'Sentinel (Sentinela)',
        'Aquaman (Aquaman)',
        'Arrow (Flecha)',
        'Honeybee (Abelha)',
        'Plus Minus (Mais Menos)',
        'Lightspeed (Velocidade Luz)',
        'Wicked Tempest (Tempestade)',
        'Duke Splitter (Duque)',
        'Overlord (Overlord)'
    },
    Default = 1,
    Multi = false,
    Text = 'Personagem do Auto Farm',
    Tooltip = 'Personagem que o Auto Farm vai usar',
    Callback = function(Value)
        if not string.find(Value, '---') then
            personagemSelecionado = Value
            Library:Notify('Auto Farm usará: ' .. Value, 3)
        end
    end
})

FarmGroup:AddDivider()

FarmGroup:AddToggle('AutoFarmToggle', {
    Text = 'Ativar Auto Farm',
    Default = false,
    Tooltip = 'Ativa o farm automático com o personagem selecionado',
    Callback = function(Value)
        autoFarmEnabled = Value
        
        if Value then
            -- Ativar hitbox automaticamente
            _G.Disabled = true
            _G.HeadSize = 30
            
            -- Atualizar o toggle e slider da hitbox visualmente
            Toggles.HitboxToggle:SetValue(true)
            Options.HitboxSize:SetValue(30)
            
            Library:Notify('Auto Farm Ativado - Personagem: ' .. personagemSelecionado, 3)
            Library:Notify('Hitbox ativada (Tamanho: 30)', 2)
            hasPickedCharacter = false
            startAutoFarm()
        else
            Library:Notify('Auto Farm Desativado', 3)
            hasPickedCharacter = false
            stopClicking()
        end
    end
})

FarmGroup:AddDivider()

FarmGroup:AddToggle('AntiAFKToggle', {
    Text = 'Anti-AFK',
    Default = true,
    Tooltip = 'Previne ser kickado por inatividade',
    Callback = function(Value)
        antiAFKEnabled = Value
        if Value then
            Library:Notify('Anti-AFK Ativado', 2)
        else
            Library:Notify('Anti-AFK Desativado', 2)
        end
    end
})

FarmGroup:AddDivider()

FarmGroup:AddLabel('Como funciona:')
FarmGroup:AddLabel('1. Selecione o personagem acima')
FarmGroup:AddLabel('2. Ative o Auto Farm')
FarmGroup:AddLabel('3. O script vai:')
FarmGroup:AddLabel('   • Teleportar para o personagem')
FarmGroup:AddLabel('   • Equipar o Slot 1')
FarmGroup:AddLabel('   • Atacar inimigos automaticamente')
FarmGroup:AddLabel('   • Quando morrer, volta e continua')

-- Informações do Auto Farm
local InfoGroup = Tabs.AutoFarm:AddRightGroupbox('Informações')

InfoGroup:AddLabel('Auto Farm Ativo:')
InfoGroup:AddLabel('• Pega personagem selecionado')
InfoGroup:AddLabel('• Equipa Slot 1 automaticamente')
InfoGroup:AddLabel('• Clica continuamente')
InfoGroup:AddLabel('• Gruda nos alvos')
InfoGroup:AddLabel('• Evita safe zones')
InfoGroup:AddLabel('• Respawn automático')

InfoGroup:AddDivider()

InfoGroup:AddLabel('Anti-AFK:')
InfoGroup:AddLabel('• Previne kick por inatividade')
InfoGroup:AddLabel('• Movimento a cada 5 minutos')
InfoGroup:AddLabel('• Sempre ativo por padrão')

-- Detectar respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Auto-Pegar ao morrer (independente do auto farm)
    if autoPegarAtivado then
        task.wait(0.5)
        local coords = PersonagensCoords[personagemAutoPegar]
        if coords then
            humanoidRootPart.CFrame = CFrame.new(coords)
            Library:Notify('Pegando ' .. personagemAutoPegar, 2)
        end
    end
end)

-- === CONFIGURAÇÕES DA UI ===
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

ThemeManager:SetFolder('TitansBGPVP')
SaveManager:SetFolder('TitansBGPVP/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

ThemeManager:SetTheme('Light')

Library:Notify('Titans Background PVP carregado!', 5)
SaveManager:LoadAutoloadConfig()
