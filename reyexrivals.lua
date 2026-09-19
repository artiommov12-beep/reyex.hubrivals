--[[
    Reyex Hub - Obsidian UI Edition
    Menu toggle: Q (Windows & Mac)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv and getgenv().ReyexHubUnload then
    pcall(getgenv().ReyexHubUnload)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local isRunning = true
local activeConnections = {}
local cleanUpInstances = {}
local originalNamecall = nil
local originalUtilityRaycast = nil

local function hideFromStack(fn)
    if typeof(fn) == "function" and setstackhidden then
        pcall(setstackhidden, fn, true)
    end
end

local autoReinjectScript = [[
    task.spawn(function()
        repeat task.wait(0.5) until game:IsLoaded()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        repeat task.wait(0.5) until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        task.wait(1.5)
        local success, err = pcall(function()
            if loadfile then
                local f = loadfile("rivals.luau") or loadfile("Rivals.luau")
                if f then f() end
            end
        end)
    end)
]]

if queue_on_teleport then
    pcall(function() queue_on_teleport(autoReinjectScript) end)
elseif syn and syn.queue_on_teleport then
    pcall(function() syn.queue_on_teleport(autoReinjectScript) end)
end

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
        if queue_on_teleport then
            pcall(function() queue_on_teleport(autoReinjectScript) end)
        elseif syn and syn.queue_on_teleport then
            pcall(function() syn.queue_on_teleport(autoReinjectScript) end)
        end
    end
end)

local Config = {
    Aimbot = false,
    TeamCheck = true,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotKeyMode = "Hold",
    AimbotPart = "Closest",
    AimbotSmoothing = 0.28,
    AimbotFOV = 120,
    AimbotVisibleOnly = true,
    AimbotScopeOnly = false,
    AimbotDisableReloading = true,
    ContinuousTargeting = true,
    InstantCameraLock = false,
    TrackThroughWalls = true,
    CorrectLockedShots = true,

    SilentAim = true,
    SilentKey = Enum.KeyCode.C,
    SilentKeyMode = "Always",
    SilentTargetPart = "Head",
    SilentFOV = 242,
    SilentHitChance = 78,
    SilentHeadChance = 59,
    SilentVisibleOnly = true,
    SilentVulnerableOnly = true,
    SilentIgnoreDeflecting = true,
    SilentIgnoreShielded = true,

    Ragebot = false,
    RagebotAutoShoot = false,
    RagebotTargetStrafe = false,
    TargetStrafeRadius = 14,
    TargetStrafeSpeed = 6,
    Autoplay = false,
    AutoplayDistance = 18,
    RagebotTargetPriority = "Distance",
    RagebotWallbang = true,
    AutoRespawn = false,
    AutoQueue = false,
    QueueMode = "1v1",
    AutoVoteMaps = false,
    MapPriority = "Arena, Onyx, Crossroads",
    AutoBanWeapons = false,
    WeaponBanPriority = "Grenade Launcher, Minigun, RPG",
    SecondBanPriority = "Grenade Launcher, Minigun, RPG",
    AutoLoadout = true,
    LoadoutOnlySelected = false,
    EnabledMaps = "Arena, Crossroads",
    AntiAim = false,
    AntiAimMode = "Jitter",
    AntiAimSpeed = 10,
    HackerDetector = true,
    NotifyHackers = true,
    HackerAutoLoad = true,
    HackerProfile = "rage",
    SpeedThreshold = 180,
    SpeedDuration = 0.75,
    ModDetector = true,
    NotifyMods = true,
    MinGroupRank = 200,
    ModUsernames = "name1, name2",
    ModFriendList = "name1, name2",
    AutoPickup = false,
    PickupRadius = 25,

    ESP_Master = true,
    ESP_EnemyOnly = true,
    ESP_Lobby = true,
    ESP_MaxDistance = 500,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_HealthBar = true,
    ESP_Weapon = true,
    ESP_Tracers = false,
    ESP_Chams = false,
    ESP_Skeleton = true,
    ESP_HeadDot = true,
    ESP_Tripmines = true,
    ESP_FOV = true,
    TargetVisualizer = true,
    TargetVisualizerHUD = true,
    TargetVisualizerPath = true,
    VisualizerArrowSpacing = 10,
    VisualizerArrowSpeed = 14,

    SpeedHack = false,
    SpeedValue = 49,
    FlyHack = false,
    FlySpeed = 50,
    InfiniteJump = false,
    BunnyHop = false,
    Noclip = false,

    NoRecoil = true,
    NoSpread = true,
    FastReload = false,
    RapidFire = false,
    InstantEquip = false,
    AutomaticGuns = false,
    InfiniteAmmo = false,

    UnlockAllSkins = false,
    SelectedCategory = "Primary",
    SelectedWeapon = "Assault Rifle",
    SelectedWrap = "Liquid Gold",
    SelectedCharm = "Dice",
    SelectedFinisher = "Gingerbreadify",
    RainbowGunSkin = false,
    WeaponChams = false,
    CustomViewModelFOV = false,
    ViewModelFOVValue = 70,
    ViewModelXOffset = 0,
    ViewModelYOffset = 0,
    ViewModelZOffset = 0,
    HideViewModel = false,

    Fullbright = false,
    NoFog = true,
    CustomFOV = false,
    FOVValue = 90,
    BulletTracers = false,
    HitSound = "Skeet",

    ThirdPerson = false,
    ThirdPersonDist = 12,
    Freecam = false,
    FreecamSpeed = 40,

    MenuKey = Enum.KeyCode.Q,
    MobileToggle = false
}

-- ============================================================
-- OBSIDIAN UI LIBRARY
-- ============================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Reyex Hub",
    Footer = "rivals | change menu bind in Config",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Center = true,
    AutoShow = true,
    Resizable = true,
})

local Tabs = {
    Home = Window:AddTab("Home", "home"),
    Aim = Window:AddTab("Aim", "crosshair"),
    Auto = Window:AddTab("Auto", "bot"),
    ESP = Window:AddTab("ESP", "eye"),
    Move = Window:AddTab("Move", "move"),
    Guns = Window:AddTab("Guns", "gun"),
    Skins = Window:AddTab("Skins", "palette"),
    World = Window:AddTab("World", "globe"),
    View = Window:AddTab("View", "camera"),
    Config = Window:AddTab("Config", "settings"),
}

-- ============================================================
-- HELPERS (lobby / team / enemies)
-- ============================================================
local LOBBY_CENTER = Vector3.new(109, -680, 1184)
local function isInLobby()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - LOBBY_CENTER).Magnitude < 450
end

local function isTeammate(p)
    if not p then return false end
    if p == LocalPlayer then return true end
    if Config.TeamCheck == false then return false end

    local pl = nil
    if typeof(p) == "Instance" then
        if p:IsA("Player") then
            pl = p
        elseif LocalPlayer.Character and (p == LocalPlayer.Character or p:IsDescendantOf(LocalPlayer.Character)) then
            return true
        else
            pl = Players:GetPlayerFromCharacter(p:IsA("Model") and p or p:FindFirstAncestorOfClass("Model"))
        end
    end

    if pl and LocalPlayer.Team and pl.Team and LocalPlayer.Team == pl.Team then
        return true
    end

    if pl then
        local myT = LocalPlayer:GetAttribute("TeamID") or LocalPlayer:GetAttribute("Team")
        local theirT = pl:GetAttribute("TeamID") or pl:GetAttribute("Team")
        if myT ~= nil and theirT ~= nil and myT == theirT then
            return true
        end
    end

    local pChar = pl and pl.Character or (typeof(p) == "Instance" and (p:IsA("Model") and p or p:FindFirstAncestorOfClass("Model")))
    local myChar = LocalPlayer.Character
    if pChar and myChar then
        local myCT = myChar:GetAttribute("TeamID") or myChar:GetAttribute("Team")
        local theirCT = pChar:GetAttribute("TeamID") or pChar:GetAttribute("Team")
        if myCT ~= nil and theirCT ~= nil and myCT == theirCT then
            return true
        end
        if pChar:FindFirstChild("TeammateLabel", true) or pChar:FindFirstChild("AllyLabel", true) then
            return true
        end
    end

    return false
end
hideFromStack(isTeammate)

local function isEnemyPlayer(p)
    if not p or p == LocalPlayer then return false end
    if isInLobby() then
        return Config.ESP_Lobby == true
    end
    if isTeammate(p) then return false end
    if Config.ESP_EnemyOnly and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
        return false
    end
    return true
end
hideFromStack(isEnemyPlayer)

local function UnloadScript()
    isRunning = false
    for _, conn in ipairs(activeConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(activeConnections)
    for _, inst in ipairs(cleanUpInstances) do pcall(function() inst:Destroy() end) end
    table.clear(cleanUpInstances)
    if originalUtilityRaycast then
        pcall(function()
            local util = require(ReplicatedStorage.Modules.Utility)
            util.Raycast = originalUtilityRaycast
        end)
    end
    pcall(function() ContextActionService:UnbindAction("ReyexMenuFreeze") end)
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if pm then
            local controls = require(pm):GetControls()
            if controls then controls:Enable() end
        end
    end)
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end)
    if getgenv then getgenv().ReyexHubUnload = nil end
    pcall(function() Library:Unload() end)
end

if getgenv then getgenv().ReyexHubUnload = UnloadScript end

-- ============================================================
-- WEAPON MODS / COSMETICS
-- ============================================================
local originalWeaponStats = {}
local function ApplyWeaponModifications()
    if not isRunning then return end
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local itemModule = rep:FindFirstChild("Modules") and rep.Modules:FindFirstChild("ItemLibrary")
        if not itemModule then return end
        local itemLib = require(itemModule)
        if itemLib and itemLib.Items then
            for name, item in pairs(itemLib.Items) do
                if type(item) == "table" and item.ShootRecoil ~= nil then
                    if not originalWeaponStats[name] then
                        originalWeaponStats[name] = {
                            ShootRecoil = item.ShootRecoil,
                            ShootSpread = item.ShootSpread,
                            AimSpreadMultiplier = item.AimSpreadMultiplier,
                            ShootSpreadPerVelocityUnit = item.ShootSpreadPerVelocityUnit,
                            ShootSpreadPerVelocityLimit = item.ShootSpreadPerVelocityLimit,
                            EquipCooldown = item.EquipCooldown,
                            ReloadLength = item.ReloadLength,
                            EmptyReloadLength = item.EmptyReloadLength,
                            ReloadActionTimestamp = item.ReloadActionTimestamp,
                            EmptyReloadActionTimestamp = item.EmptyReloadActionTimestamp,
                            ShootCooldown = item.ShootCooldown,
                            MaxAmmo = item.MaxAmmo,
                            MaxAmmoReserve = item.MaxAmmoReserve
                        }
                    end
                    local orig = originalWeaponStats[name]
                    item.ShootRecoil = Config.NoRecoil and 0 or orig.ShootRecoil
                    item.ShootSpread = Config.NoSpread and 0 or orig.ShootSpread
                    item.AimSpreadMultiplier = Config.NoSpread and 0 or orig.AimSpreadMultiplier
                    item.ShootSpreadPerVelocityUnit = Config.NoSpread and 0 or orig.ShootSpreadPerVelocityUnit
                    item.ShootSpreadPerVelocityLimit = Config.NoSpread and 0 or orig.ShootSpreadPerVelocityLimit
                    item.EquipCooldown = Config.InstantEquip and 0.01 or orig.EquipCooldown
                    item.ReloadLength = Config.FastReload and 0.05 or orig.ReloadLength
                    item.EmptyReloadLength = Config.FastReload and 0.05 or orig.EmptyReloadLength
                    item.ReloadActionTimestamp = Config.FastReload and 0.01 or orig.ReloadActionTimestamp
                    item.EmptyReloadActionTimestamp = Config.FastReload and 0.01 or orig.EmptyReloadActionTimestamp
                    item.ShootCooldown = Config.RapidFire and (orig.ShootCooldown * 0.4) or orig.ShootCooldown
                    if orig.MaxAmmo then
                        item.MaxAmmo = Config.InfiniteAmmo and 9999 or orig.MaxAmmo
                    end
                    if orig.MaxAmmoReserve then
                        item.MaxAmmoReserve = Config.InfiniteAmmo and 9999 or orig.MaxAmmoReserve
                    end
                end
            end
        end
    end)
end

local function UnlockAllCosmeticsClientSide()
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local pdCtrl = require(LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
        local cosmeticLib = require(rep.Modules.CosmeticLibrary)
        local itemLib = require(rep.Modules.ItemLibrary)

        if pdCtrl and pdCtrl.CurrentData and pdCtrl.CurrentData.Data then
            local cosmInv = pdCtrl.CurrentData.Data.CosmeticInventory or {}
            local rawWeapInv = pdCtrl.CurrentData.Data.WeaponInventory or {}

            if cosmeticLib and cosmeticLib.Cosmetics then
                for name, _ in pairs(cosmeticLib.Cosmetics) do
                    cosmInv[name] = true
                end
            end

            local weapInv = {}
            local existing = {}
            if typeof(rawWeapInv) == "table" then
                for _, item in pairs(rawWeapInv) do
                    if typeof(item) == "table" and item.Name then
                        table.insert(weapInv, item)
                        existing[item.Name] = true
                    end
                end
            end

            if itemLib and itemLib.Items then
                for name, _ in pairs(itemLib.Items) do
                    if not existing[name] then
                        table.insert(weapInv, {
                            Name = name,
                            Level = 100,
                            Prestige = 5,
                            XP = 99999,
                            IsFavorited = false
                        })
                        existing[name] = true
                    end
                end
            end

            pdCtrl.CurrentData.Data.CosmeticInventory = cosmInv
            pdCtrl.CurrentData.Data.WeaponInventory = weapInv
        end
    end)
end

local function ApplySelectedCosmeticsClientSide(weaponName, wrapName, charmName, finisherName)
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local pdCtrl = require(LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
        if pdCtrl and pdCtrl.CurrentData and pdCtrl.CurrentData.Data then
            local weapInv = pdCtrl.CurrentData.Data.WeaponInventory
            if typeof(weapInv) == "table" then
                for _, weapon in ipairs(weapInv) do
                    if typeof(weapon) == "table" and (weapon.Name == weaponName or weaponName == "All") then
                        if wrapName and wrapName ~= "Default" and wrapName ~= "None" then
                            weapon.Wrap = { Name = wrapName, Inverted = false }
                        elseif wrapName == "Default" or wrapName == "None" then
                            weapon.Wrap = nil
                        end
                        if charmName and charmName ~= "None" then
                            weapon.Charm = { Name = charmName }
                        elseif charmName == "None" then
                            weapon.Charm = nil
                        end
                        if finisherName and finisherName ~= "None" then
                            weapon.Finisher = { Name = finisherName }
                        elseif finisherName == "None" then
                            weapon.Finisher = nil
                        end
                    end
                end
            end
        end

        local rem = rep:FindFirstChild("Remotes")
        local dataRem = rem and rem:FindFirstChild("Data")
        local equipCosm = dataRem and dataRem:FindFirstChild("EquipCosmetic")
        if equipCosm and weaponName ~= "All" then
            if wrapName and wrapName ~= "Default" and wrapName ~= "None" then
                equipCosm:FireServer(weaponName, "Wrap", wrapName)
            end
            if charmName and charmName ~= "None" then
                equipCosm:FireServer(weaponName, "Charm", charmName)
            end
            if finisherName and finisherName ~= "None" then
                equipCosm:FireServer(weaponName, "Finisher", finisherName)
            end
        end
    end)
end

local function ShowNotification(title, message, notifType, duration)
    Library:Notify({
        Title = title or "Reyex Hub",
        Description = message or "",
        Time = duration or 3.5,
    })
end

-- ============================================================
-- HOME TAB
-- ============================================================
do
    local left = Tabs.Home:AddLeftGroupbox("Account")
    left:AddLabel("User: " .. LocalPlayer.Name)
    left:AddLabel("Display: @" .. LocalPlayer.DisplayName)
    left:AddLabel("Build: Reyex Hub (Obsidian)")

    local right = Tabs.Home:AddRightGroupbox("Session")
    right:AddLabel("Player: " .. LocalPlayer.Name)
    right:AddButton({
        Text = "Rejoin server",
        Func = function()
            ShowNotification("Reyex Hub", "Reconnecting...", "INFO", 3)
            task.spawn(function()
                task.wait(0.5)
                pcall(function() TeleportService:Teleport(17625359962, LocalPlayer) end)
            end)
        end,
    })
    right:AddButton({
        Text = "Join lowest-ping server",
        Func = function()
            ShowNotification("Reyex Hub", "Searching for lowest-ping server...", "INFO", 3)
            task.spawn(function()
                local placeId = 17625359962
                local url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=2&excludeFullGames=true&limit=25", placeId)
                local success, res = pcall(function() return game:HttpGet(url) end)
                local targetServer = nil
                if success and res then
                    local sDec, data = pcall(function() return HttpService:JSONDecode(res) end)
                    if sDec and data and data.data then
                        for _, s in ipairs(data.data) do
                            if s.id ~= game.JobId and s.playing and s.maxPlayers and (s.playing < s.maxPlayers) then
                                if not targetServer or (s.ping and targetServer.ping and s.ping < targetServer.ping) or (s.ping and not targetServer.ping) then
                                    targetServer = s
                                end
                            end
                        end
                    end
                end
                if targetServer then
                    ShowNotification("Reyex Hub", string.format("Joining (%d ms)...", targetServer.ping or 0), "SUCCESS", 3)
                    task.wait(0.5)
                    pcall(function() TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, LocalPlayer) end)
                else
                    pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
                end
            end)
        end,
    })
end

-- ============================================================
-- AIM TAB
-- ============================================================
do
    local aimLeft = Tabs.Aim:AddLeftGroupbox("Aimbot")
    aimLeft:AddToggle("Aimbot", { Text = "Enable aimbot", Default = Config.Aimbot, Callback = function(v) Config.Aimbot = v end })
    aimLeft:AddToggle("AimbotTeamCheck", { Text = "Team check", Default = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
    aimLeft:AddToggle("ContinuousTargeting", { Text = "Continuous targeting", Default = Config.ContinuousTargeting, Callback = function(v) Config.ContinuousTargeting = v end })
    aimLeft:AddDropdown("AimbotKeyMode", { Text = "Key mode", Values = {"Hold", "Toggle", "Always"}, Default = 1, Callback = function(v) Config.AimbotKeyMode = v end })
    aimLeft:AddToggle("AimbotScopeOnly", { Text = "Scope only", Default = Config.AimbotScopeOnly, Callback = function(v) Config.AimbotScopeOnly = v end })
    aimLeft:AddToggle("AimbotDisableReloading", { Text = "Disable while reloading", Default = Config.AimbotDisableReloading, Callback = function(v) Config.AimbotDisableReloading = v end })
    aimLeft:AddSlider("AimbotSmoothing", { Text = "Smoothing", Default = Config.AimbotSmoothing, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) Config.AimbotSmoothing = v end })
    aimLeft:AddToggle("InstantCameraLock", { Text = "Instant camera lock", Default = Config.InstantCameraLock, Callback = function(v) Config.InstantCameraLock = v end })
    aimLeft:AddToggle("TrackThroughWalls", { Text = "Track through walls", Default = Config.TrackThroughWalls, Callback = function(v) Config.TrackThroughWalls = v end })
    aimLeft:AddDropdown("AimbotPart", { Text = "Lock part", Values = {"Head", "Body", "Closest"}, Default = 3, Callback = function(v) Config.AimbotPart = v end })
    aimLeft:AddToggle("CorrectLockedShots", { Text = "Correct locked shots", Default = Config.CorrectLockedShots, Callback = function(v) Config.CorrectLockedShots = v end })

    local silent = Tabs.Aim:AddRightGroupbox("Silent Aim")
    silent:AddToggle("SilentAim", { Text = "Enable silent aim", Default = Config.SilentAim, Callback = function(v) Config.SilentAim = v end })
    silent:AddToggle("SilentTeamCheck", { Text = "Team check", Default = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
    silent:AddDropdown("SilentKeyMode", { Text = "Key mode", Values = {"Always", "Hold", "Toggle"}, Default = 1, Callback = function(v) Config.SilentKeyMode = v end })
    silent:AddToggle("SilentVisibleOnly", { Text = "Visible only", Default = Config.SilentVisibleOnly, Callback = function(v) Config.SilentVisibleOnly = v end })
    silent:AddToggle("SilentVulnerableOnly", { Text = "Vulnerable only", Default = Config.SilentVulnerableOnly, Callback = function(v) Config.SilentVulnerableOnly = v end })
    silent:AddToggle("SilentIgnoreDeflecting", { Text = "Ignore deflecting", Default = Config.SilentIgnoreDeflecting, Callback = function(v) Config.SilentIgnoreDeflecting = v end })
    silent:AddToggle("SilentIgnoreShielded", { Text = "Ignore shielded", Default = Config.SilentIgnoreShielded, Callback = function(v) Config.SilentIgnoreShielded = v end })
    silent:AddDropdown("SilentTargetPart", { Text = "Target part", Values = {"Head", "Body", "Closest"}, Default = 1, Callback = function(v) Config.SilentTargetPart = v end })
    silent:AddSlider("SilentHeadChance", { Text = "Head %", Default = Config.SilentHeadChance, Min = 0, Max = 100, Rounding = 0, Suffix = "%", Callback = function(v) Config.SilentHeadChance = v end })
    silent:AddSlider("SilentHitChance", { Text = "Hit chance", Default = Config.SilentHitChance, Min = 0, Max = 100, Rounding = 0, Suffix = "%", Callback = function(v) Config.SilentHitChance = v end })
    silent:AddSlider("SilentFOV", { Text = "FOV Radius", Default = Config.SilentFOV, Min = 30, Max = 400, Rounding = 0, Suffix = " px", Callback = function(v) Config.SilentFOV = v end })
end

-- ============================================================
-- AUTO TAB
-- ============================================================
do
    local rage = Tabs.Auto:AddLeftGroupbox("Ragebot")
    rage:AddToggle("Ragebot", { Text = "Enable ragebot", Default = Config.Ragebot, Callback = function(v) Config.Ragebot = v end })
    rage:AddToggle("RagebotTeamCheck", { Text = "Team check", Default = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
    rage:AddToggle("RagebotAutoShoot", { Text = "Auto shoot", Default = Config.RagebotAutoShoot, Callback = function(v) Config.RagebotAutoShoot = v end })
    rage:AddToggle("RagebotTargetStrafe", { Text = "Target strafe", Default = Config.RagebotTargetStrafe, Callback = function(v) Config.RagebotTargetStrafe = v end })
    rage:AddSlider("TargetStrafeRadius", { Text = "Strafe radius", Default = Config.TargetStrafeRadius, Min = 6, Max = 30, Rounding = 0, Suffix = " studs", Callback = function(v) Config.TargetStrafeRadius = v end })
    rage:AddSlider("TargetStrafeSpeed", { Text = "Strafe speed", Default = Config.TargetStrafeSpeed, Min = 2, Max = 15, Rounding = 0, Callback = function(v) Config.TargetStrafeSpeed = v end })
    rage:AddToggle("Autoplay", { Text = "Autoplay", Default = Config.Autoplay, Callback = function(v) Config.Autoplay = v end })
    rage:AddSlider("AutoplayDistance", { Text = "Stop distance", Default = Config.AutoplayDistance, Min = 8, Max = 40, Rounding = 0, Suffix = " studs", Callback = function(v) Config.AutoplayDistance = v end })

    local match = Tabs.Auto:AddLeftGroupbox("Match Automation")
    match:AddToggle("AutoRespawn", { Text = "Auto respawn", Default = Config.AutoRespawn, Callback = function(v) Config.AutoRespawn = v end })
    match:AddToggle("AutoQueue", { Text = "Auto queue", Default = Config.AutoQueue, Callback = function(v) Config.AutoQueue = v end })
    match:AddDropdown("QueueMode", { Text = "Queue", Values = {"1v1", "2v2", "3v3", "4v4", "5v5"}, Default = 1, Callback = function(v) Config.QueueMode = v end })

    local vote = Tabs.Auto:AddLeftGroupbox("Voting")
    vote:AddToggle("AutoVoteMaps", { Text = "Auto vote maps", Default = Config.AutoVoteMaps, Callback = function(v) Config.AutoVoteMaps = v end })
    vote:AddDropdown("MapPriority", { Text = "Map priority", Values = {"Arena, Onyx, Crossroads", "Onyx, Arena, Crossroads", "Crossroads, Arena, Onyx"}, Default = 1, Callback = function(v) Config.MapPriority = v end })
    vote:AddToggle("AutoBanWeapons", { Text = "Auto ban weapons", Default = Config.AutoBanWeapons, Callback = function(v) Config.AutoBanWeapons = v end })
    vote:AddDropdown("WeaponBanPriority", { Text = "Ban priority", Values = {"Grenade Launcher, Minigun, RPG", "RPG, Grenade Launcher, Sniper", "Minigun, RPG, Shotgun"}, Default = 1, Callback = function(v) Config.WeaponBanPriority = v end })

    local loadout = Tabs.Auto:AddLeftGroupbox("Loadout")
    loadout:AddToggle("AutoLoadout", { Text = "Auto loadout", Default = Config.AutoLoadout, Callback = function(v) Config.AutoLoadout = v end })
    loadout:AddToggle("LoadoutOnlySelected", { Text = "Only selected maps", Default = Config.LoadoutOnlySelected, Callback = function(v) Config.LoadoutOnlySelected = v end })
    loadout:AddDropdown("EnabledMaps", { Text = "Enabled maps", Values = {"Arena, Crossroads", "Onyx, Crossroads", "All Maps"}, Default = 1, Callback = function(v) Config.EnabledMaps = v end })

    local aa = Tabs.Auto:AddRightGroupbox("Anti-Aim")
    aa:AddToggle("AntiAim", { Text = "Enable anti-aim", Default = Config.AntiAim, Callback = function(v) Config.AntiAim = v end })
    aa:AddDropdown("AntiAimMode", { Text = "Mode", Values = {"Spin", "Jitter", "Backwards"}, Default = 2, Callback = function(v) Config.AntiAimMode = v end })
    aa:AddSlider("AntiAimSpeed", { Text = "Spin speed", Default = Config.AntiAimSpeed, Min = 10, Max = 100, Rounding = 0, Callback = function(v) Config.AntiAimSpeed = v end })

    local det = Tabs.Auto:AddRightGroupbox("Detectors")
    det:AddToggle("HackerDetector", { Text = "Hacker detector", Default = Config.HackerDetector, Callback = function(v) Config.HackerDetector = v end })
    det:AddToggle("NotifyHackers", { Text = "Notify hackers", Default = Config.NotifyHackers, Callback = function(v) Config.NotifyHackers = v end })
    det:AddToggle("HackerAutoLoad", { Text = "Auto load config on detect", Default = Config.HackerAutoLoad, Callback = function(v) Config.HackerAutoLoad = v end })
    det:AddInput("HackerProfile", { Text = "Profile to load", Default = Config.HackerProfile, Callback = function(v) Config.HackerProfile = v end })
    det:AddSlider("SpeedThreshold", { Text = "Speed threshold", Default = Config.SpeedThreshold, Min = 50, Max = 400, Rounding = 0, Suffix = " studs/s", Callback = function(v) Config.SpeedThreshold = v end })
    det:AddSlider("SpeedDuration", { Text = "Required duration", Default = Config.SpeedDuration, Min = 0.1, Max = 3, Rounding = 2, Suffix = " s", Callback = function(v) Config.SpeedDuration = v end })
    det:AddToggle("ModDetector", { Text = "Moderator detector", Default = Config.ModDetector, Callback = function(v) Config.ModDetector = v end })
    det:AddToggle("NotifyMods", { Text = "Notify mods", Default = Config.NotifyMods, Callback = function(v) Config.NotifyMods = v end })
    det:AddSlider("MinGroupRank", { Text = "Min group rank", Default = Config.MinGroupRank, Min = 1, Max = 255, Rounding = 0, Callback = function(v) Config.MinGroupRank = v end })
    det:AddInput("ModUsernames", { Text = "Mod usernames", Default = Config.ModUsernames, Callback = function(v) Config.ModUsernames = v end })

    local pick = Tabs.Auto:AddRightGroupbox("Pickups")
    pick:AddToggle("AutoPickup", { Text = "Auto pickup", Default = Config.AutoPickup, Callback = function(v) Config.AutoPickup = v end })
    pick:AddSlider("PickupRadius", { Text = "Pickup radius", Default = Config.PickupRadius, Min = 10, Max = 60, Rounding = 0, Suffix = " studs", Callback = function(v) Config.PickupRadius = v end })
end

-- ============================================================
-- ESP TAB
-- ============================================================
do
    local espMain = Tabs.ESP:AddLeftGroupbox("Player ESP")
    espMain:AddToggle("ESP_Master", { Text = "Enable ESP", Default = Config.ESP_Master, Callback = function(v) Config.ESP_Master = v end })
    espMain:AddToggle("ESP_EnemyOnly", { Text = "Enemy only", Default = Config.ESP_EnemyOnly, Callback = function(v) Config.ESP_EnemyOnly = v end })
    espMain:AddToggle("ESP_Lobby", { Text = "Show in lobby", Default = Config.ESP_Lobby, Callback = function(v) Config.ESP_Lobby = v end })
    espMain:AddSlider("ESP_MaxDistance", { Text = "Max distance", Default = Config.ESP_MaxDistance, Min = 100, Max = 1000, Rounding = 0, Suffix = " studs", Callback = function(v) Config.ESP_MaxDistance = v end })
    espMain:AddToggle("ESP_Boxes", { Text = "Box ESP", Default = Config.ESP_Boxes, Callback = function(v) Config.ESP_Boxes = v end })
    espMain:AddToggle("ESP_Names", { Text = "Name ESP", Default = Config.ESP_Names, Callback = function(v) Config.ESP_Names = v end })
    espMain:AddToggle("ESP_HealthBar", { Text = "Health bar", Default = Config.ESP_HealthBar, Callback = function(v) Config.ESP_HealthBar = v end })
    espMain:AddToggle("ESP_Distance", { Text = "Distance ESP", Default = Config.ESP_Distance, Callback = function(v) Config.ESP_Distance = v end })
    espMain:AddToggle("ESP_Weapon", { Text = "Weapon ESP", Default = Config.ESP_Weapon, Callback = function(v) Config.ESP_Weapon = v end })

    local espExtra = Tabs.ESP:AddRightGroupbox("Render & Chams")
    espExtra:AddToggle("ESP_Chams", { Text = "Chams / Highlight", Default = Config.ESP_Chams, Callback = function(v) Config.ESP_Chams = v end })
    espExtra:AddToggle("ESP_HeadDot", { Text = "Head dot", Default = Config.ESP_HeadDot, Callback = function(v) Config.ESP_HeadDot = v end })
    espExtra:AddToggle("ESP_Tracers", { Text = "Tracers", Default = Config.ESP_Tracers, Callback = function(v) Config.ESP_Tracers = v end })
    espExtra:AddToggle("ESP_Skeleton", { Text = "Skeleton ESP", Default = Config.ESP_Skeleton, Callback = function(v) Config.ESP_Skeleton = v end })
    espExtra:AddToggle("ESP_Tripmines", { Text = "Tripmines ESP", Default = Config.ESP_Tripmines, Callback = function(v) Config.ESP_Tripmines = v end })
    espExtra:AddToggle("ESP_FOV", { Text = "Draw FOV Circle", Default = Config.ESP_FOV, Callback = function(v) Config.ESP_FOV = v end })

    local tvis = Tabs.ESP:AddRightGroupbox("Target Visualizer")
    tvis:AddToggle("TargetVisualizer", { Text = "Enable visualizer", Default = Config.TargetVisualizer, Callback = function(v) Config.TargetVisualizer = v end })
    tvis:AddToggle("TargetVisualizerHUD", { Text = "Target HUD card", Default = Config.TargetVisualizerHUD, Callback = function(v) Config.TargetVisualizerHUD = v end })
    tvis:AddToggle("TargetVisualizerPath", { Text = "Ground path & arrows", Default = Config.TargetVisualizerPath, Callback = function(v) Config.TargetVisualizerPath = v end })
    tvis:AddSlider("VisualizerArrowSpacing", { Text = "Arrow spacing", Default = Config.VisualizerArrowSpacing, Min = 5, Max = 25, Rounding = 0, Suffix = " studs", Callback = function(v) Config.VisualizerArrowSpacing = v end })
    tvis:AddSlider("VisualizerArrowSpeed", { Text = "Arrow speed", Default = Config.VisualizerArrowSpeed, Min = 5, Max = 30, Rounding = 0, Callback = function(v) Config.VisualizerArrowSpeed = v end })
end

-- ============================================================
-- MOVE TAB
-- ============================================================
do
    local ground = Tabs.Move:AddLeftGroupbox("Ground Movement")
    ground:AddToggle("SpeedHack", { Text = "Speed hack", Default = Config.SpeedHack, Callback = function(v) Config.SpeedHack = v end })
    ground:AddSlider("SpeedValue", { Text = "WalkSpeed", Default = Config.SpeedValue, Min = 16, Max = 120, Rounding = 0, Callback = function(v) Config.SpeedValue = v end })
    ground:AddToggle("InfiniteJump", { Text = "Infinite jump", Default = Config.InfiniteJump, Callback = function(v) Config.InfiniteJump = v end })
    ground:AddToggle("BunnyHop", { Text = "Bunny hop", Default = Config.BunnyHop, Callback = function(v) Config.BunnyHop = v end })

    local air = Tabs.Move:AddRightGroupbox("Flight & Collision")
    air:AddToggle("FlyHack", { Text = "Fly hack", Default = Config.FlyHack, Callback = function(v) Config.FlyHack = v end })
    air:AddSlider("FlySpeed", { Text = "Fly speed", Default = Config.FlySpeed, Min = 20, Max = 150, Rounding = 0, Callback = function(v) Config.FlySpeed = v end })
    air:AddToggle("Noclip", { Text = "Noclip", Default = Config.Noclip, Callback = function(v) Config.Noclip = v end })
end

-- ============================================================
-- GUNS TAB
-- ============================================================
do
    local mech = Tabs.Guns:AddLeftGroupbox("Weapon Mechanics")
    mech:AddToggle("NoRecoil", { Text = "No recoil", Default = Config.NoRecoil, Callback = function(v) Config.NoRecoil = v ApplyWeaponModifications() end })
    mech:AddToggle("NoSpread", { Text = "No spread", Default = Config.NoSpread, Callback = function(v) Config.NoSpread = v ApplyWeaponModifications() end })
    mech:AddToggle("FastReload", { Text = "Fast reload", Default = Config.FastReload, Callback = function(v) Config.FastReload = v ApplyWeaponModifications() end })
    mech:AddToggle("RapidFire", { Text = "Rapid fire", Default = Config.RapidFire, Callback = function(v) Config.RapidFire = v ApplyWeaponModifications() end })
    mech:AddToggle("InstantEquip", { Text = "Instant equip", Default = Config.InstantEquip, Callback = function(v) Config.InstantEquip = v ApplyWeaponModifications() end })

    local extras = Tabs.Guns:AddRightGroupbox("Weapon Features")
    extras:AddToggle("AutomaticGuns", { Text = "Automatic mode", Default = Config.AutomaticGuns, Callback = function(v) Config.AutomaticGuns = v end })
    extras:AddToggle("InfiniteAmmo", { Text = "Infinite ammo", Default = Config.InfiniteAmmo, Callback = function(v) Config.InfiniteAmmo = v ApplyWeaponModifications() end })
    extras:AddLabel("Note: Fast reload / infinite ammo are client-sided and may be clamped by the server.", true)
end

-- ============================================================
-- SKINS TAB
-- ============================================================
do
    local skins = Tabs.Skins:AddLeftGroupbox("Weapon Customizer")
    skins:AddToggle("UnlockAllSkins", {
        Text = "Unlock all skins (Client)",
        Default = Config.UnlockAllSkins,
        Callback = function(v)
            Config.UnlockAllSkins = v
            if v then
                UnlockAllCosmeticsClientSide()
                ShowNotification("Reyex Hub", "All skins unlocked client-side.", "SUCCESS", 3)
            end
        end,
    })
    skins:AddDropdown("SelectedCategory", { Text = "Category", Values = {"Primary", "Secondary", "Melee", "Utility"}, Default = 1, Callback = function(v) Config.SelectedCategory = v end })
    skins:AddDropdown("SelectedWeapon", {
        Text = "Weapon",
        Values = {"Assault Rifle", "Sniper", "Shotgun", "Katana", "Revolver", "RPG", "Submachine Gun", "Hand Gun", "Minigun", "Grenade Launcher", "Energy Rifle", "Bow"},
        Default = 1,
        Callback = function(v) Config.SelectedWeapon = v end,
    })
    skins:AddDropdown("SelectedWrap", {
        Text = "Wrap",
        Values = {"Liquid Gold", "Mainframe", "Obsidian", "Scribble", "Vexed", "Igneous", "Candy Apple", "Red Rubber", "Tidal", "Purple", "Popsicle", "Lighthouse", "Celtic", "Empress", "PixelBlight", "Sunset", "Money", "Portal", "Venom", "Default"},
        Default = 1,
        Callback = function(v) Config.SelectedWrap = v end,
    })
    skins:AddDropdown("SelectedCharm", {
        Text = "Charm",
        Values = {"Dice", "Kashy", "Jolly Hat", "Devious Pumpkin", "Chibi Grenade", "Lucky Horseshoe", "Bat Daggers", "Pirate Hook", "Mini Present", "None"},
        Default = 1,
        Callback = function(v) Config.SelectedCharm = v end,
    })
    skins:AddDropdown("SelectedFinisher", {
        Text = "Finisher",
        Values = {"Flop", "Rising Star", "Gingerbreadify", "Warp Sickness", "Freeze", "Batsplosion", "Northern Light Show", "Supernova", "Orbital Strike", "Disintegrate", "None"},
        Default = 3,
        Callback = function(v) Config.SelectedFinisher = v end,
    })
    skins:AddButton({
        Text = "Apply Skin to Weapon",
        Func = function()
            UnlockAllCosmeticsClientSide()
            ApplySelectedCosmeticsClientSide(Config.SelectedWeapon, Config.SelectedWrap, Config.SelectedCharm, Config.SelectedFinisher)
            ShowNotification("Reyex Hub", "Equipped " .. tostring(Config.SelectedWrap) .. " on " .. tostring(Config.SelectedWeapon), "SUCCESS", 2.5)
        end,
    })
    skins:AddButton({
        Text = "Apply Skin to ALL Weapons",
        Func = function()
            UnlockAllCosmeticsClientSide()
            ApplySelectedCosmeticsClientSide("All", Config.SelectedWrap, Config.SelectedCharm, Config.SelectedFinisher)
            ShowNotification("Reyex Hub", "Equipped " .. tostring(Config.SelectedWrap) .. " on ALL weapons!", "SUCCESS", 2.5)
        end,
    })

    local vm = Tabs.Skins:AddRightGroupbox("Viewmodel & Render")
    vm:AddToggle("RainbowGunSkin", { Text = "Rainbow gun skin", Default = Config.RainbowGunSkin, Callback = function(v) Config.RainbowGunSkin = v end })
    vm:AddToggle("WeaponChams", { Text = "Weapon chams & glow", Default = Config.WeaponChams, Callback = function(v) Config.WeaponChams = v end })
    vm:AddToggle("CustomViewModelFOV", { Text = "Custom Viewmodel FOV", Default = Config.CustomViewModelFOV, Callback = function(v) Config.CustomViewModelFOV = v end })
    vm:AddSlider("ViewModelFOVValue", { Text = "Viewmodel FOV", Default = Config.ViewModelFOVValue, Min = 50, Max = 110, Rounding = 0, Suffix = "°", Callback = function(v) Config.ViewModelFOVValue = v end })
    vm:AddSlider("ViewModelXOffset", { Text = "X offset", Default = Config.ViewModelXOffset, Min = -30, Max = 30, Rounding = 0, Callback = function(v) Config.ViewModelXOffset = v end })
    vm:AddSlider("ViewModelYOffset", { Text = "Y offset", Default = Config.ViewModelYOffset, Min = -30, Max = 30, Rounding = 0, Callback = function(v) Config.ViewModelYOffset = v end })
    vm:AddSlider("ViewModelZOffset", { Text = "Z offset", Default = Config.ViewModelZOffset, Min = -30, Max = 30, Rounding = 0, Callback = function(v) Config.ViewModelZOffset = v end })
    vm:AddToggle("HideViewModel", { Text = "Hide viewmodel", Default = Config.HideViewModel, Callback = function(v) Config.HideViewModel = v end })
end

-- ============================================================
-- WORLD TAB
-- ============================================================
do
    local world = Tabs.World:AddLeftGroupbox("World & Visuals")
    world:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = Config.Fullbright,
        Callback = function(v)
            Config.Fullbright = v
            if v then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
            end
        end,
    })
    world:AddToggle("NoFog", {
        Text = "No fog",
        Default = Config.NoFog,
        Callback = function(v)
            Config.NoFog = v
            Lighting.FogEnd = v and 1000000 or 1000
        end,
    })
    world:AddToggle("CustomFOV", {
        Text = "Custom FOV",
        Default = Config.CustomFOV,
        Callback = function(v)
            Config.CustomFOV = v
            if v then Camera.FieldOfView = Config.FOVValue end
        end,
    })
    world:AddSlider("FOVValue", {
        Text = "FOV Angle",
        Default = Config.FOVValue,
        Min = 70,
        Max = 120,
        Rounding = 0,
        Suffix = "°",
        Callback = function(v)
            Config.FOVValue = v
            if Config.CustomFOV then Camera.FieldOfView = v end
        end,
    })

    local audio = Tabs.World:AddRightGroupbox("Effects & Sounds")
    audio:AddToggle("BulletTracers", { Text = "Bullet tracers", Default = Config.BulletTracers, Callback = function(v) Config.BulletTracers = v end })
    audio:AddDropdown("HitSound", { Text = "Hit sound", Values = {"Skeet", "Rust", "Ding"}, Default = 1, Callback = function(v) Config.HitSound = v end })
end

-- ============================================================
-- VIEW TAB
-- ============================================================
do
    local tp = Tabs.View:AddLeftGroupbox("Third-Person")
    tp:AddToggle("ThirdPerson", { Text = "Third-person mode", Default = Config.ThirdPerson, Callback = function(v) Config.ThirdPerson = v end })
    tp:AddSlider("ThirdPersonDist", { Text = "Distance", Default = Config.ThirdPersonDist, Min = 5, Max = 30, Rounding = 0, Suffix = " studs", Callback = function(v) Config.ThirdPersonDist = v end })

    local fc = Tabs.View:AddRightGroupbox("Freecam")
    fc:AddToggle("Freecam", { Text = "Freecam mode", Default = Config.Freecam, Callback = function(v) Config.Freecam = v end })
    fc:AddSlider("FreecamSpeed", { Text = "Freecam speed", Default = Config.FreecamSpeed, Min = 10, Max = 100, Rounding = 0, Callback = function(v) Config.FreecamSpeed = v end })
end

-- ============================================================
-- CONFIG TAB
-- ============================================================
do
    local menu = Tabs.Config:AddLeftGroupbox("Menu")
    -- Changeable menu toggle keybind (Obsidian built-in)
    menu:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "Q",
        NoUI = true,
        Text = "Menu keybind",
    })
    -- Wire Obsidian's menu toggle to this keypicker so user can change it freely
    Library.ToggleKeybind = Options.MenuKeybind

    menu:AddButton({
        Text = "Unload script",
        Func = UnloadScript,
        Risky = true,
    })

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("ReyexHub")
    SaveManager:SetFolder("ReyexHub/Rivals")
    SaveManager:BuildConfigSection(Tabs.Config)
    ThemeManager:ApplyToTab(Tabs.Config)
end

-- ============================================================
-- TARGET / ESP RUNTIME (kept from original, simplified bindings)
-- ============================================================
local TargetVis = {
    cachedEnemies = {},
    lastEnemyUpdateTime = 0,
    targetCache = {},
    staticRayParams = nil,
    activeRoot = nil,
    activeChar = nil,
    activeHum = nil,
    activePlayer = nil,
    lastTargetUserId = nil,
    cachedWaypoints = {},
    autoplayWpIndex = 1,
    lastAutoplayStuckTime = 0,
    lastAutoplayPos = nil,
    lastPathMyPos = nil,
    lastPathActPos = nil,
    lastFullbrightCheck = 0,
    lastNoFogCheck = 0,
    poolLines = {},
    poolChevrons = {},
    visualizerFolder = nil,
    hudFrame = nil,
}

local function getEnemyPlayers()
    local now = tick()
    if (now - TargetVis.lastEnemyUpdateTime < 0.15) and (#TargetVis.cachedEnemies > 0) then
        return TargetVis.cachedEnemies
    end
    table.clear(TargetVis.cachedEnemies)
    local inLobby = isInLobby()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if inLobby then
                if Config.ESP_Lobby or Config.TargetVisualizer then
                    table.insert(TargetVis.cachedEnemies, p)
                end
            else
                if isEnemyPlayer(p) then
                    table.insert(TargetVis.cachedEnemies, p)
                end
            end
        end
    end
    TargetVis.lastEnemyUpdateTime = now
    return TargetVis.cachedEnemies
end

local function getClosestTarget(maxFOV, checkVisible, partMode, targetPriority)
    local now = tick()
    local cacheKey = tostring(maxFOV) .. "_" .. tostring(checkVisible) .. "_" .. tostring(partMode) .. "_" .. tostring(targetPriority)
    local cached = TargetVis.targetCache[cacheKey]
    if cached and (now - cached.time < 0.06) and cached.target and cached.target.Parent then
        return cached.target
    end

    if not TargetVis.staticRayParams then
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.IgnoreWater = true
        TargetVis.staticRayParams = p
    end

    local closest, closestScore = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camPos = Camera.CFrame.Position
    local camLook = Camera.CFrame.LookVector
    local is360 = (maxFOV == nil) or (maxFOV >= 999)

    TargetVis.staticRayParams.FilterDescendantsInstances = {myChar, Camera}

    for _, p in ipairs(getEnemyPlayers()) do
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hum.Health > 0 and rootPart then
            local toRoot = rootPart.Position - camPos
            if is360 or toRoot:Dot(camLook) > -5 then
                local isDeflecting = char:GetAttribute("Deflecting") or char:FindFirstChild("Deflect") or char:FindFirstChild("KatanaDeflect")
                local isShielded = char:GetAttribute("Shielded") or char:FindFirstChild("Shield") or char:FindFirstChild("EnergyShield")
                local isProtected = char:GetAttribute("SpawnImmunity") or char:FindFirstChildOfClass("ForceField")

                local skip = false
                if isTeammate(p) or isTeammate(char) then skip = true end
                if Config.SilentIgnoreDeflecting and isDeflecting then skip = true end
                if Config.SilentIgnoreShielded and isShielded then skip = true end
                if Config.SilentVulnerableOnly and isProtected then skip = true end

                if not skip then
                    local headCandidate = char:FindFirstChild("Head") or char:FindFirstChild("HitboxHead")
                    local bodyCandidate = char:FindFirstChild("UpperTorso") or rootPart
                    local hitPart = nil

                    if partMode == "Head" then
                        hitPart = headCandidate or bodyCandidate
                    elseif partMode == "Body" then
                        hitPart = bodyCandidate or headCandidate
                    elseif partMode == "Closest" then
                        if headCandidate and bodyCandidate then
                            local hScr, hOn = Camera:WorldToViewportPoint(headCandidate.Position)
                            local bScr, bOn = Camera:WorldToViewportPoint(bodyCandidate.Position)
                            if hOn and bOn then
                                local hDist = (Vector2.new(hScr.X, hScr.Y) - mousePos).Magnitude
                                local bDist = (Vector2.new(bScr.X, bScr.Y) - mousePos).Magnitude
                                hitPart = (hDist <= bDist) and headCandidate or bodyCandidate
                            elseif hOn then
                                hitPart = headCandidate
                            elseif bOn then
                                hitPart = bodyCandidate
                            else
                                hitPart = headCandidate
                            end
                        else
                            hitPart = headCandidate or bodyCandidate
                        end
                    else
                        hitPart = headCandidate or bodyCandidate
                    end

                    if hitPart then
                        local inRange = false
                        local score = math.huge
                        if is360 then
                            local worldDist = myRoot and (hitPart.Position - myRoot.Position).Magnitude or (hitPart.Position - camPos).Magnitude
                            if worldDist <= (maxFOV or math.huge) then
                                inRange = true
                                score = (targetPriority == "Health") and hum.Health or worldDist
                            end
                        else
                            local scrPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                            if onScreen and scrPos.Z > 0 then
                                local fovDist = (Vector2.new(scrPos.X, scrPos.Y) - mousePos).Magnitude
                                if fovDist <= (maxFOV or math.huge) then
                                    inRange = true
                                    if targetPriority == "Health" then
                                        score = hum.Health
                                    elseif targetPriority == "Distance" and myRoot then
                                        score = (hitPart.Position - myRoot.Position).Magnitude
                                    else
                                        score = fovDist
                                    end
                                end
                            end
                        end

                        if inRange and score < closestScore then
                            if checkVisible then
                                local dir = hitPart.Position - camPos
                                local res = Workspace:Raycast(camPos, dir, TargetVis.staticRayParams)
                                if not res or res.Instance:IsDescendantOf(char) then
                                    closest = hitPart
                                    closestScore = score
                                end
                            else
                                closest = hitPart
                                closestScore = score
                            end
                        end
                    end
                end
            end
        end
    end

    TargetVis.targetCache[cacheKey] = { target = closest, time = now }
    return closest
end

local function hasWeaponEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return true end
    end
    local vm = Workspace:FindFirstChild("ViewModels")
    local fp = vm and vm:FindFirstChild("FirstPerson")
    if fp and #fp:GetChildren() > 0 then
        for _, c in ipairs(fp:GetChildren()) do
            if c:IsA("Model") or c:IsA("BasePart") then return true end
        end
    end
    return false
end

local function clickWeapon()
    if mouse1click then pcall(mouse1click) return end
    if mouse1press and mouse1release then
        pcall(function()
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end)
        return
    end
    local vim = game:GetService("VirtualInputManager")
    if vim then
        local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        local cx, cy = math.floor(vp.X * 0.5), math.floor(vp.Y * 0.5)
        if vim.SendMouseButtonEvent then
            pcall(function()
                vim:SendMouseButtonEvent(cx, cy, 0, true, Workspace, 0)
                task.wait(0.01)
                vim:SendMouseButtonEvent(cx, cy, 0, false, Workspace, 0)
            end)
        end
    end
end
hideFromStack(clickWeapon)

-- Silent aim hooks (same as original)
local isSilentKeyDown = false
local isAimbotKeyDown = false

local function performSilentAimRedirect(origin, defaultTargetPos, maxDist)
    if not isRunning or not Config.SilentAim then return defaultTargetPos end
    if Config.SilentKeyMode == "Hold" and not isSilentKeyDown then return defaultTargetPos end
    local target = getClosestTarget(Config.SilentFOV, Config.SilentVisibleOnly, Config.SilentTargetPart)
    if target then
        if isTeammate(target) then return defaultTargetPos end
        local hitRoll = math.random(1, 100)
        if hitRoll <= Config.SilentHitChance then
            local aimPos = target.Position
            if math.random(1, 100) <= Config.SilentHeadChance then
                local tChar = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
                local head = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HitboxHead"))
                if head then aimPos = head.Position end
            end
            return aimPos
        end
    end
    return defaultTargetPos
end

pcall(function()
    local utilModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Utility")
    if utilModule then
        local util = require(utilModule)
        if util and type(util.Raycast) == "function" then
            originalUtilityRaycast = util.Raycast
            util.Raycast = function(...)
                local n = select("#", ...)
                local args = {...}
                local offset = 0
                if typeof(args[1]) == "table" or typeof(args[1]) == "Instance" then offset = 1 end
                local originVec = args[offset + 1]
                local targetPos = args[offset + 2]
                local maxDist = args[offset + 3]
                if isRunning and Config.SilentAim then
                    pcall(function()
                        if typeof(originVec) == "Vector3" and typeof(targetPos) == "Vector3" then
                            local redirectedPos = performSilentAimRedirect(originVec, targetPos, maxDist)
                            if redirectedPos and typeof(redirectedPos) == "Vector3" and redirectedPos ~= targetPos then
                                local diff = redirectedPos - originVec
                                if diff.Magnitude > 0.05 then
                                    local dir = diff.Unit * (maxDist or 1000)
                                    args[offset + 2] = originVec + dir
                                end
                            end
                        end
                    end)
                end
                return originalUtilityRaycast(unpack(args, 1, n))
            end
        end
    end
end)

if hookmetamethod and newcclosure and checkcaller then
    originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not isRunning or checkcaller() or not method then
            if setnamecallmethod then setnamecallmethod(method) end
            return originalNamecall(self, ...)
        end
        local m = method:lower()
        if m ~= "fireserver" and m ~= "invokeserver" then
            if setnamecallmethod then setnamecallmethod(method) end
            return originalNamecall(self, ...)
        end
        local args = {...}
        if Config.SilentAim and typeof(self) == "Instance" and (self.Name == "UseItem" or self.Name == "UseItemFeedback" or self.Name == "SnowballThrow") then
            local target = getClosestTarget(Config.SilentFOV, Config.SilentVisibleOnly, Config.SilentTargetPart)
            if target and not isTeammate(target) then
                local hitRoll = math.random(1, 100)
                if hitRoll <= Config.SilentHitChance then
                    local aimPos = target.Position
                    if math.random(1, 100) <= Config.SilentHeadChance then
                        local tChar = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
                        local head = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HitboxHead"))
                        if head then aimPos = head.Position end
                    end
                    if #args >= 2 and typeof(args[2]) == "Vector3" then
                        args[2] = aimPos
                    elseif #args >= 1 and typeof(args[1]) == "Vector3" then
                        args[1] = aimPos
                    end
                    if setnamecallmethod then setnamecallmethod(method) end
                    return originalNamecall(self, unpack(args))
                end
            end
        end
        if m == "invokeserver" and typeof(self) == "Instance" and self.ClassName == "RemoteFunction" then
            return self.InvokeServer(self, ...)
        end
        if setnamecallmethod then setnamecallmethod(method) end
        return originalNamecall(self, ...)
    end))
end

-- Input
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        isAimbotKeyDown = true
    elseif input.KeyCode == Config.SilentKey then
        if Config.SilentKeyMode == "Toggle" then
            Config.SilentAim = not Config.SilentAim
            ShowNotification("Reyex Hub", "Silent Aim: " .. (Config.SilentAim and "ON" or "OFF"), "INFO", 1.5)
        elseif Config.SilentKeyMode == "Hold" then
            isSilentKeyDown = true
        end
    end
end))

table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        isAimbotKeyDown = false
    elseif input.KeyCode == Config.SilentKey then
        if Config.SilentKeyMode == "Hold" then
            isSilentKeyDown = false
        end
    end
end))

local lastInfJumpTime = 0
table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
    if isRunning and Config.InfiniteJump then
        local now = tick()
        if now - lastInfJumpTime >= 0.25 then
            lastInfJumpTime = now
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end))

-- Main render loop (aimbot / rage / movement / FOV)
local flyBV, flyBG
local lastBhopJumpTime = 0
local lastRageAutoShootTime = 0
local lastAutoShootTime = 0
local isTargetStrafing = false
local FreecamState = { enabled = false, rotX = 0, rotY = 0, pos = Vector3.zero }

table.insert(activeConnections, RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = Workspace.CurrentCamera

    if Config.SpeedHack and root and hum then
        hum.WalkSpeed = tonumber(Config.SpeedValue) or 32
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local baseSpeed = 16
            local targetSpeed = tonumber(Config.SpeedValue) or 32
            local extraSpeed = math.max(0, targetSpeed - baseSpeed)
            if extraSpeed > 0 then
                root.CFrame = root.CFrame + (moveDir.Unit * (extraSpeed * dt))
            end
        end
    end

    if Config.FlyHack and root and hum and cam then
        if not flyBV or flyBV.Parent ~= root then
            if flyBV then flyBV:Destroy() end
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.zero
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Parent = root
            table.insert(cleanUpInstances, flyBV)
        end
        if not flyBG or flyBG.Parent ~= root then
            if flyBG then flyBG:Destroy() end
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.Parent = root
            table.insert(cleanUpInstances, flyBG)
        end
        local camCF = cam.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        flyBG.CFrame = camCF
        flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * Config.FlySpeed) or Vector3.zero
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end

    if Config.Fullbright and (tick() - (TargetVis.lastFullbrightCheck or 0) >= 1) then
        TargetVis.lastFullbrightCheck = tick()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    if Config.NoFog and (tick() - (TargetVis.lastNoFogCheck or 0) >= 1) then
        TargetVis.lastNoFogCheck = tick()
        pcall(function() Lighting.FogEnd = 100000 end)
    end

    if Config.CustomFOV and cam then
        cam.FieldOfView = tonumber(Config.FOVValue) or 90
    end

    if Config.BunnyHop and hum and root then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                local now = tick()
                if now - lastBhopJumpTime > 0.08 then
                    lastBhopJumpTime = now
                    hum.Jump = true
                end
            end
        end
    end

    if Config.ThirdPerson and root and hum and not Config.Freecam and cam then
        local head = char:FindFirstChild("Head") or root
        local headPos = head.Position + Vector3.new(0, 0.5, 0)
        local targetDist = tonumber(Config.ThirdPersonDist) or 12
        local backDir = -cam.CFrame.LookVector * targetDist
        local hitParams = RaycastParams.new()
        hitParams.FilterDescendantsInstances = {char, cam}
        hitParams.FilterType = Enum.RaycastFilterType.Exclude
        local rayRes = Workspace:Raycast(headPos, backDir, hitParams)
        local camPos = rayRes and (rayRes.Position + rayRes.Normal * 0.4) or (headPos + backDir)
        cam.CFrame = CFrame.lookAt(camPos, headPos + cam.CFrame.LookVector * 100)
    end

    if Config.Freecam and cam then
        if not FreecamState.enabled then
            FreecamState.enabled = true
            local rx, ry = cam.CFrame:ToOrientation()
            FreecamState.rotX = rx
            FreecamState.rotY = ry
            FreecamState.pos = cam.CFrame.Position
        end
        if root then
            root.Anchored = true
            root.AssemblyLinearVelocity = Vector3.zero
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        local delta = UserInputService:GetMouseDelta()
        if delta.Magnitude > 0 then
            FreecamState.rotY = FreecamState.rotY - math.rad(delta.X * 0.25)
            FreecamState.rotX = math.clamp(FreecamState.rotX - math.rad(delta.Y * 0.25), math.rad(-89), math.rad(89))
        end
        local camRot = CFrame.Angles(0, FreecamState.rotY, 0) * CFrame.Angles(FreecamState.rotX, 0, 0)
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            FreecamState.pos = FreecamState.pos + (moveDir.Unit * (Config.FreecamSpeed or 40) * dt)
        end
        cam.CFrame = CFrame.new(FreecamState.pos) * camRot
    else
        if FreecamState.enabled then
            FreecamState.enabled = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            if root then root.Anchored = false end
        end
    end

    if Config.AntiAim and root then
        if Config.AntiAimMode == "Spin" then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.min(Config.AntiAimSpeed, 35) * dt * 60), 0)
        elseif Config.AntiAimMode == "Jitter" then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-45, 45)), 0)
        elseif Config.AntiAimMode == "Backwards" then
            root.CFrame = CFrame.lookAt(root.Position, root.Position - cam.CFrame.LookVector)
        end
    end

    if Config.Aimbot and (Config.AimbotKeyMode == "Always" or isAimbotKeyDown) then
        local isScoped = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or (cam and cam.FieldOfView < 70)
        local isReloading = char and char:GetAttribute("Reloading")
        if (not Config.AimbotScopeOnly or isScoped) and (not Config.AimbotDisableReloading or not isReloading) then
            local checkVis = Config.AimbotVisibleOnly and not Config.TrackThroughWalls
            local target = getClosestTarget(Config.AimbotFOV, checkVis, Config.AimbotPart)
            if target and cam then
                local targetPos = target.Position
                if Config.InstantCameraLock then
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPos)
                else
                    local curCF = cam.CFrame
                    local goalCF = CFrame.lookAt(curCF.Position, targetPos)
                    local smooth = math.clamp(tonumber(Config.AimbotSmoothing) or 0.28, 0.02, 1)
                    cam.CFrame = curCF:Lerp(goalCF, math.clamp(smooth * 45 * dt, 0.05, 1))
                end
            end
        end
    end

    local rageTarget = nil
    if Config.Ragebot and root and hasWeaponEquipped() then
        rageTarget = getClosestTarget(1000, true, "Head", Config.RagebotTargetPriority)
    end
    local candidateTarget = rageTarget
    if not candidateTarget then
        if Config.TargetVisualizer or (not isInLobby() and hasWeaponEquipped()) then
            candidateTarget = getClosestTarget(1000, false, "Head", "Distance")
        end
    end
    if candidateTarget and candidateTarget.Parent then
        local tChar = candidateTarget.Parent
        local tHum = tChar:FindFirstChildOfClass("Humanoid")
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if tHum and tHum.Health > 0 and tRoot then
            TargetVis.activeChar = tChar
            TargetVis.activeHum = tHum
            TargetVis.activeRoot = tRoot
            TargetVis.activePlayer = Players:GetPlayerFromCharacter(tChar)
        else
            TargetVis.activeChar, TargetVis.activeHum, TargetVis.activeRoot, TargetVis.activePlayer = nil, nil, nil, nil
        end
    else
        TargetVis.activeChar, TargetVis.activeHum, TargetVis.activeRoot, TargetVis.activePlayer = nil, nil, nil, nil
    end

    if Config.Ragebot and root and hasWeaponEquipped() then
        local target = rageTarget
        if target and target.Parent and cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
            if Config.RagebotTargetStrafe and hum and root then
                isTargetStrafing = true
                local tPos = target.Position
                local currentAngle = tick() * (tonumber(Config.TargetStrafeSpeed) or 6)
                local rad = tonumber(Config.TargetStrafeRadius) or 14
                local goalWorldPos = Vector3.new(tPos.X + math.cos(currentAngle) * rad, root.Position.Y, tPos.Z + math.sin(currentAngle) * rad)
                local moveOffset = goalWorldPos - root.Position
                local moveDir = Vector3.new(moveOffset.X, 0, moveOffset.Z)
                if moveDir.Magnitude > 0.5 then
                    hum:Move(moveDir.Unit, false)
                else
                    hum:Move(Vector3.zero, false)
                end
            elseif isTargetStrafing and hum and not Config.Autoplay then
                isTargetStrafing = false
                hum:Move(Vector3.zero, false)
            end
            if Config.RagebotAutoShoot then
                local now = tick()
                if now - lastRageAutoShootTime >= 0.12 then
                    lastRageAutoShootTime = now
                    clickWeapon()
                end
            end
        else
            if isTargetStrafing and hum and not Config.Autoplay then
                isTargetStrafing = false
                hum:Move(Vector3.zero, false)
            end
        end
    else
        if isTargetStrafing and hum and not Config.Autoplay then
            isTargetStrafing = false
            hum:Move(Vector3.zero, false)
        end
    end

    if Config.AutomaticGuns and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and hasWeaponEquipped() then
        local now = tick()
        if now - lastAutoShootTime >= 0.08 then
            lastAutoShootTime = now
            clickWeapon()
        end
    end
end))

table.insert(activeConnections, RunService.Stepped:Connect(function()
    if not isRunning then return end
    local char = LocalPlayer.Character
    if Config.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- Background automation loop
task.spawn(function()
    local hackerDetectionTimestamps = {}
    local hackerNotifiedTimestamps = {}
    local modNotifiedCache = {}
    ApplyWeaponModifications()
    while isRunning do
        pcall(function()
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            local duels = rem and rem:FindFirstChild("Duels")
            local matchmaking = rem and rem:FindFirstChild("Matchmaking")

            if Config.AutoRespawn and duels and duels:FindFirstChild("RespawnNow") then
                duels.RespawnNow:FireServer()
            end
            if Config.AutoQueue and matchmaking and matchmaking:FindFirstChild("JoinQueue") then
                local targetQueue = Config.QueueMode or "1v1"
                task.spawn(function()
                    pcall(function() matchmaking.JoinQueue:InvokeServer(targetQueue) end)
                end)
            end
            if Config.AutoLoadout and duels and duels:FindFirstChild("PickWeaponsAheadOfTime") then
                duels.PickWeaponsAheadOfTime:FireServer()
            end

            if Config.HackerDetector then
                local threshold = tonumber(Config.SpeedThreshold) or 180
                local duration = tonumber(Config.SpeedDuration) or 0.75
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local vel = pRoot.AssemblyLinearVelocity.Magnitude
                            if vel > threshold then
                                if not hackerDetectionTimestamps[p] then
                                    hackerDetectionTimestamps[p] = tick()
                                elseif tick() - hackerDetectionTimestamps[p] >= duration then
                                    if not hackerNotifiedTimestamps[p] or tick() - hackerNotifiedTimestamps[p] > 12 then
                                        hackerNotifiedTimestamps[p] = tick()
                                        if Config.NotifyHackers then
                                            ShowNotification("Reyex Hub", "Hacker Flag: " .. p.DisplayName .. " (" .. math.floor(vel) .. " studs/s)", "WARN", 3.5)
                                        end
                                    end
                                end
                            else
                                hackerDetectionTimestamps[p] = nil
                            end
                        end
                    end
                end
            end

            if Config.ModDetector then
                local minRank = tonumber(Config.MinGroupRank) or 200
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and not modNotifiedCache[p] then
                        local isMod = false
                        local rank = p:GetAttribute("GroupRank")
                        if not rank then
                            pcall(function() rank = p:GetRankInGroup(game.CreatorId > 0 and game.CreatorId or 16124806) end)
                        end
                        if rank and rank >= minRank then isMod = true end
                        if not isMod and Config.ModUsernames and Config.ModUsernames ~= "" then
                            for uName in Config.ModUsernames:gmatch("[^,%s]+") do
                                if p.Name:lower() == uName:lower() or p.DisplayName:lower() == uName:lower() then
                                    isMod = true
                                    break
                                end
                            end
                        end
                        if isMod then
                            modNotifiedCache[p] = true
                            if Config.NotifyMods then
                                ShowNotification("Reyex Hub", "STAFF / MOD: " .. p.DisplayName, "ERROR", 5)
                            end
                        end
                    end
                end
            end

            if Config.AutoPickup then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name:find("Drop") or obj.Name:find("Tripmine") or obj.Name:find("Ammo") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - root.Position).Magnitude <= Config.PickupRadius then
                                if firetouchinterest then
                                    firetouchinterest(root, part, false)
                                    firetouchinterest(root, part, true)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

ShowNotification("Reyex Hub", "Loaded with Obsidian UI. Menu bind defaults to Q (change in Config).", "SUCCESS", 4)
