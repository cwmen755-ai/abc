-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Variables
local unitRunning = false
local bankRunning = false
local spamAllRunning = false
local selectedSlot = "Slot3"
local spawnDelay = 0.5
local spamAllDelay = 0.3

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Game Auto Farm GUI",
    LoadingTitle = "Loading GUI...",
    LoadingSubtitle = "by ScriptUser",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GameAutoFarm",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "https://discord.gg/eXK23ckFqW",
        RememberJoins = true
    },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Auto Spawn Section
local AutoSpawnSection = MainTab:CreateSection("Auto Spawn")

-- Slot Selection Dropdown
local SlotDropdown = MainTab:CreateDropdown({
    Name = "Select Unit Slot",
    Options = {"Slot1", "Slot2", "Slot3", "Slot4", "Slot5", "Slot6", "Slot7", "Slot8"},
    CurrentOption = {"Slot3"},
    MultipleOptions = false,
    Flag = "SlotSelection",
    Callback = function(Option)
        selectedSlot = Option[1] or Option
        Rayfield:Notify({
            Title = "Slot Changed",
            Content = "Now using: " .. selectedSlot,
            Duration = 0.5,
            Image = 4483362458
        })
    end
})

local UnitToggle = MainTab:CreateToggle({
    Name = "Auto Spawn Unit",
    CurrentValue = false,
    Flag = "UnitToggle",
    Callback = function(Value)
        unitRunning = Value
        if Value then
            -- Disable spam all if enabled
            if spamAllRunning then
                spamAllRunning = false
                Rayfield:Notify({
                    Title = "Spam All Disabled",
                    Content = "Auto disabled to prevent conflicts",
                    Duration = 2,
                    Image = 4483362458
                })
            end
            Rayfield:Notify({
                Title = "Unit Auto-Spawn",
                Content = "Enabled - Spawning on " .. selectedSlot,
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Unit Auto-Spawn",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

local SpamAllToggle = MainTab:CreateToggle({
    Name = "Spam All Slots",
    CurrentValue = false,
    Flag = "SpamAllToggle",
    Callback = function(Value)
        spamAllRunning = Value
        if Value then
            -- Disable single unit spawn if enabled
            if unitRunning then
                unitRunning = false
                Rayfield:Notify({
                    Title = "Single Unit Disabled",
                    Content = "Auto disabled to prevent conflicts",
                    Duration = 2,
                    Image = 4483362458
                })
            end
            Rayfield:Notify({
                Title = "Spam All Slots",
                Content = "Enabled - Spawning all slots!",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Spam All Slots",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

local BankToggle = MainTab:CreateToggle({
    Name = "Auto Spawn Bank",
    CurrentValue = false,
    Flag = "BankToggle",
    Callback = function(Value)
        bankRunning = Value
        if Value then
            Rayfield:Notify({
                Title = "Bank Auto-Spawn",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Bank Auto-Spawn",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Actions Section
local ActionsSection = MainTab:CreateSection("Quick Actions")

local GiveUpButton = MainTab:CreateButton({
    Name = "Give Up Match",
    Callback = function()
        local success, err = pcall(function()
            ReplicatedStorage.Events.RemoteEvents.GiveUp:FireServer()
        end)
        
        if success then
            Rayfield:Notify({
                Title = "Give Up",
                Content = "Successfully surrendered match",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to give up: " .. tostring(err),
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local SettingsSection = SettingsTab:CreateSection("Configuration")

local SpawnDelaySlider = SettingsTab:CreateSlider({
    Name = "Single Spawn Delay (seconds)",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "SpawnDelay",
    Callback = function(Value)
        spawnDelay = Value
    end
})

local SpamAllDelaySlider = SettingsTab:CreateSlider({
    Name = "Spam All Delay (seconds)",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.3,
    Flag = "SpamAllDelay",
    Callback = function(Value)
        spamAllDelay = Value
    end
})

-- Info Section
local InfoSection = SettingsTab:CreateSection("Information")

local InfoLabel1 = SettingsTab:CreateLabel("Lower delay = faster spawning but may cause issues")
local InfoLabel2 = SettingsTab:CreateLabel("Spam All cycles through all 8 slots automatically")

-- Helper function to spawn unit
local function spawnUnit(slot)
    local success, err = pcall(function()
        local Events = ReplicatedStorage:WaitForChild("Events", 5)
        if Events then
            local RemoteFunction = Events:WaitForChild("RemoteFunction", 5)
            if RemoteFunction then
                local PlayerSpawn = RemoteFunction:WaitForChild("PlayerSpawn", 5)
                if PlayerSpawn then
                    PlayerSpawn:InvokeServer(slot)
                end
            end
        end
    end)
    
    if not success then
        warn("Spawn error for " .. slot .. ": " .. tostring(err))
    end
    
    return success
end

-- Main Loop for Single Unit and Bank
task.spawn(function()
    while true do
        local success, err = pcall(function()
            -- Check if player is still in game
            if not player or not player.Parent then
                return
            end
            
            -- Auto Spawn Unit on Selected Slot
            if unitRunning and not spamAllRunning then
                spawnUnit(selectedSlot)
            end
            
            -- Auto Spawn Bank
            if bankRunning then
                spawnUnit("Bank")
            end
        end)
        
        if not success then
            warn("Main loop error: " .. tostring(err))
        end
        
        task.wait(spawnDelay)
    end
end)

-- Spam All Slots Loop
task.spawn(function()
    local allSlots = {"Slot1", "Slot2", "Slot3", "Slot4", "Slot5", "Slot6", "Slot7", "Slot8"}
    
    while true do
        if spamAllRunning then
            local success, err = pcall(function()
                -- Check if player is still in game
                if not player or not player.Parent then
                    return
                end
                
                -- Cycle through all slots
                for _, slot in ipairs(allSlots) do
                    if not spamAllRunning then break end -- Check if still running
                    spawnUnit(slot)
                    task.wait(0.05) -- Small delay between each slot
                end
            end)
            
            if not success then
                warn("Spam all loop error: " .. tostring(err))
            end
            
            task.wait(spamAllDelay)
        else
            task.wait(0.5) -- Wait longer when not running
        end
    end
end)

-- Notification on load
Rayfield:Notify({
    Title = "GUI Loaded",
    Content = "Script loaded successfully!",
    Duration = 5,
    Image = 4483362458
})
