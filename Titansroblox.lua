-- Titans Background PVP - Fluent UI Version
-- Carrega a biblioteca Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
_G.HitboxColor = Color3.fromRGB(255, 140, 0)

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
    ["Estelar"] = Vector3.new(5.99, 339.20, -0.58),
    ["Robin"] = Vector3.new(6.45, 342.46, 22.14),
    ["Ciborgue"] = Vector3.new(7.05, 338.49, 12.33),
    ["Ravena"] = Vector3.new(6.71, 338.44, 35.39),
    ["Mutano"] = Vector3.new(6.87, 338.39, 48.06),
    ["Muteno Evil"] = Vector3.new(168.34, 338.49, 33.62),
    ["Estelar Evil"] = Vector3.new(164.23, 338.49, 23.42),
    ["Ciborgue Evil"] = Vector3.new(168.84, 338.49, 14.69),
    ["Morte Vermelha"] = Vector3.new(31.01, 338.49, 14.78),
    ["Slayer"] = Vector3.new(30.92, 338.48, 23.78),
    ["Goliath"] = Vector3.new(50.72, 338.49, 13.16),
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

-- Cria a janela Fluent
local Window = Fluent:CreateWindow({
    Title = "Titans Background PVP",
    SubTitle = "by Você",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.End
})

-- Cria as abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shield" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "zap" }),
    Characters = Window:AddTab({ Title = "Personagens", Icon = "users" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
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
local HitboxToggle = Tabs.Main:AddToggle("HitboxToggle", {
    Title = "HITBOX",
    Description = "Ativa ou desativa a hitbox expandida",
    Default = false,
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

local HitboxSlider = Tabs.Main:AddSlider("HitboxSize", {
    Title = "Tamanho da Hitbox",
    Description = "Ajuste o tamanho (10-80)",
    Default = 10,
    Min = 10,
    Max = 80,
    Rounding = 0,
    Callback = function(Value)
        _G.HeadSize = Value
    end
})

local HitboxColorPicker = Tabs.Main:AddColorpicker("HitboxColor", {
    Title = "Cor da Hitbox",
    Default = Color3.fromRGB(255, 140, 0),
    Callback = function(Value)
        _G.HitboxColor = Value
    end
})

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
    task.wait(0.05)
    
    local tools = {}
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(tools, item) end
    end
    if #tools == 0 then return false end
    
    humanoid:EquipTool(tools[1])
    task.wait(0.05)
    return true
end

local function startClicking()
    if clickConnection then clickConnection:Disconnect() end
    clickConnection = RunService.RenderStepped:Connect(function()
        if autoFarmEnabled then
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
                task.wait(1)
                hasPickedCharacter = true
            end
        end
        
        equipSlot1()
        task.wait(0.3)
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
                task.wait(1)
                
                local coords = PersonagensCoords[personagemSelecionado]
                if coords then humanoidRootPart.CFrame = CFrame.new(coords) end
                task.wait(1)
                
                local equipped = false
                for i = 1, 5 do
                    equipped = equipSlot1()
                    if equipped then break end
                    task.wait(0.3)
                end
                
                task.wait(0.3)
                startClicking()
                continue
            end
            
            local equippedTool = character:FindFirstChildOfClass("Tool")
            if not equippedTool then
                equipSlot1()
                task.wait(0.2)
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
Tabs.AutoFarm:AddParagraph({
    Title = "⭐ Melhores para Farm",
    Content = "• Muteno Evil (Recomendado)\n• Mutano\n• Robin"
})

local CharacterDropdown = Tabs.AutoFarm:AddDropdown("CharacterSelect", {
    Title = "Personagem do Auto Farm",
    Description = "Selecione qual personagem usar",
    Values = {
        "Muteno Evil", "Mutano", "Robin",
        "Estelar", "Ciborgue", "Ravena",
        "Estelar Evil", "Ciborgue Evil", "Morte Vermelha",
        "Slayer", "Goliath",
        "Apprentice (Aprendiz)", "Gadget (Gadget)", "Lynx (Lince)",
        "Vision (Visão)", "Blacklight (Luz Negra)", "Maya (Maya)",
        "Golem (Golem)", "Sentinel (Sentinela)", "Aquaman (Aquaman)",
        "Arrow (Flecha)", "Honeybee (Abelha)", "Plus Minus (Mais Menos)",
        "Lightspeed (Velocidade Luz)", "Wicked Tempest (Tempestade)",
        "Duke Splitter (Duque)", "Overlord (Overlord)"
    },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        personagemSelecionado = Value
        Fluent:Notify({
            Title = "Personagem Selecionado",
            Content = "Auto Farm usará: " .. Value,
            Duration = 3
        })
    end
})

local AutoFarmToggle = Tabs.AutoFarm:AddToggle("AutoFarm", {
    Title = "Ativar Auto Farm",
    Description = "Inicia o farm automático",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        
        if Value then
            _G.Disabled = true
            _G.HeadSize = 30
            HitboxToggle:SetValue(true)
            HitboxSlider:SetValue(30)
            
            Fluent:Notify({
                Title = "Auto Farm Ativado",
                Content = "Personagem: " .. personagemSelecionado .. "\nHitbox: 30",
                Duration = 3
            })
            hasPickedCharacter = false
            startAutoFarm()
        else
            Fluent:Notify({
                Title = "Auto Farm Desativado",
                Content = "Farm parado",
                Duration = 3
            })
            hasPickedCharacter = false
            stopClicking()
        end
    end
})

local AntiAFKToggle = Tabs.AutoFarm:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Description = "Previne kick por inatividade",
    Default = true,
    Callback = function(Value)
        antiAFKEnabled = Value
    end
})

Tabs.AutoFarm:AddParagraph({
    Title = "Como Funciona",
    Content = "1. Selecione o personagem\n2. Ative o Auto Farm\n3. O script vai:\n   • Teleportar para o personagem\n   • Equipar Slot 1\n   • Atacar automaticamente\n   • Respawnar e continuar"
})

-- === ABA PERSONAGENS ===
Tabs.Characters:AddParagraph({
    Title = "Auto-Pegar Personagem",
    Content = "Pega automaticamente um personagem quando você morrer"
})

local AutoPickDropdown = Tabs.Characters:AddDropdown("AutoPickCharacter", {
    Title = "Personagem para Auto-Pegar",
    Description = "Será pego ao respawnar",
    Values = {
        "Muteno Evil", "Mutano", "Robin",
        "Estelar", "Ciborgue", "Ravena",
        "Estelar Evil", "Ciborgue Evil", "Morte Vermelha",
        "Slayer", "Goliath",
        "Apprentice (Aprendiz)", "Gadget (Gadget)", "Lynx (Lince)",
        "Vision (Visão)", "Blacklight (Luz Negra)", "Maya (Maya)",
        "Golem (Golem)", "Sentinel (Sentinela)", "Aquaman (Aquaman)",
        "Arrow (Flecha)", "Honeybee (Abelha)", "Plus Minus (Mais Menos)",
        "Lightspeed (Velocidade Luz)", "Wicked Tempest (Tempestade)",
        "Duke Splitter (Duque)", "Overlord (Overlord)"
    },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        personagemAutoPegar = Value
    end
})

Tabs.Characters:AddButton({
    Title = "🚀 Teleportar Agora",
    Description = "Teleporta para o personagem selecionado",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local coords = PersonagensCoords[personagemAutoPegar]
            if coords then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(coords)
                Fluent:Notify({
                    Title = "Teleportado",
                    Content = "Para: " .. personagemAutoPegar,
                    Duration = 2
                })
            end
        end
    end
})

local AutoPegarToggle = Tabs.Characters:AddToggle("AutoPegar", {
    Title = "Auto-Pegar ao Morrer",
    Description = "Ativa teleporte automático",
    Default = false,
    Callback = function(Value)
        autoPegarAtivado = Value
    end
})

Tabs.Characters:AddParagraph({
    Title = "Teleportes Rápidos",
    Content = "Clique para teleportar instantaneamente"
})

-- Botões de teleporte rápido (principais)
local mainChars = {
    {name = "⭐ Estelar", key = "Estelar"},
    {name = "🦇 Robin ⭐", key = "Robin"},
    {name = "🤖 Ciborgue", key = "Ciborgue"},
    {name = "🌑 Ravena", key = "Ravena"},
    {name = "🐾 Mutano ⭐", key = "Mutano"},
    {name = "🐾 Muteno Evil ⭐⭐", key = "Muteno Evil"},
    {name = "⭐ Estelar Evil", key = "Estelar Evil"},
    {name = "🤖 Ciborgue Evil", key = "Ciborgue Evil"},
    {name = "💀 Morte Vermelha", key = "Morte Vermelha"},
    {name = "⚔️ Slayer", key = "Slayer"},
    {name = "👹 Goliath", key = "Goliath"}
}

for _, char in ipairs(mainChars) do
    Tabs.Characters:AddButton({
        Title = char.name,
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(PersonagensCoords[char.key])
            end
        end
    })
end

-- Detectar respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if autoPegarAtivado then
        task.wait(0.5)
        local coords = PersonagensCoords[personagemAutoPegar]
        if coords then
            humanoidRootPart.CFrame = CFrame.new(coords)
        end
    end
end)

-- === ABA SETTINGS ===
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("TitansBGPVP")
SaveManager:SetFolder("TitansBGPVP/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Titans Background PVP",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
