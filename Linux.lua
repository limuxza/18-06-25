local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Linux = {}

function Linux.Instance(class, props)
local inst = Instance.new(class)
for k, v in pairs(props or {}) do
    inst[k] = v
end
return inst
end

function Linux:SafeCallback(Function, ...)
if not Function then
    return
end
local Success, Error = pcall(Function, ...)
if not Success then
    self:Notify({
        Title = "Callback Error",
        Content = "" .. tostring(Error),
        Duration = 5
    })
end
end

function Linux:Notify(config)
local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
local notificationWidth = isMobile and 200 or 300
local notificationHeight = config.SubContent and 80 or 60
local startPosX = isMobile and 10 or 20
local parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")

for _, v in pairs(parent:GetChildren()) do
    if v:IsA("ScreenGui") and v.Name == "NotificationHolder" then
        v:Destroy()
    end
end

local NotificationHolder = Linux.Instance("ScreenGui", {
    Name = "NotificationHolder",
    Parent = parent,
    ResetOnSpawn = false,
    Enabled = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local Notification = Linux.Instance("Frame", {
    Parent = NotificationHolder,
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderColor3 = Color3.fromRGB(39, 39, 42),
    BorderSizePixel = 0,
    Size = UDim2.new(0, notificationWidth, 0, notificationHeight),
    Position = UDim2.new(1, 10, 1, -notificationHeight - 10),
    ZIndex = 100
})

Linux.Instance("UICorner", {
    Parent = Notification,
    CornerRadius = UDim.new(0, 4)
})

Linux.Instance("UIStroke", {
    Parent = Notification,
    Color = Color3.fromRGB(60, 60, 70),
    Thickness = 1
})

Linux.Instance("TextLabel", {
    Parent = Notification,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -10, 0, 20),
    Position = UDim2.new(0, 5, 0, 5),
    Font = Enum.Font.GothamSemibold,
    Text = config.Title or "Notification",
    TextColor3 = Color3.fromRGB(230, 230, 240),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 101
})

Linux.Instance("TextLabel", {
    Parent = Notification,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -10, 0, 20),
    Position = UDim2.new(0, 5, 0, 25),
    Font = Enum.Font.GothamSemibold,
    Text = config.Content or "Content",
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextSize = 14,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 101
})

if config.SubContent then
    Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 45),
        Font = Enum.Font.GothamSemibold,
        Text = config.SubContent,
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })
end

local ProgressBar = Linux.Instance("Frame", {
    Parent = Notification,
    BackgroundColor3 = Color3.fromRGB(20, 20, 21),
    Size = UDim2.new(1, -10, 0, 4),
    Position = UDim2.new(0, 5, 1, -9),
    ZIndex = 101,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(39, 39, 42)
})

Linux.Instance("UICorner", {
    Parent = ProgressBar,
    CornerRadius = UDim.new(1, 0)
})

local ProgressFill = Linux.Instance("Frame", {
    Parent = ProgressBar,
    BackgroundColor3 = Color3.fromRGB(255, 105, 180),
    Size = UDim2.new(0, 0, 1, 0),
    ZIndex = 101,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(39, 39, 42)
})

Linux.Instance("UICorner", {
    Parent = ProgressFill,
    CornerRadius = UDim.new(1, 0)
})

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(0, startPosX, 1, -notificationHeight - 10)}):Play()

if config.Duration then
    local progressTweenInfo = TweenInfo.new(config.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    TweenService:Create(ProgressFill, progressTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.delay(config.Duration, function()
        TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(1, 10, 1, -notificationHeight - 10)}):Play()
        task.wait(0.5)
        NotificationHolder:Destroy()
    end)
end
end

Linux.SavedConfigs = {}
Linux.CurrentConfig = ""
Linux.ConfigFolder = "LinuxUI_Configs"

function Linux.SaveConfig(name)
if not name or name == "" then
    return false, "Invalid configuration name"
end

local configData = {
    Elements = {},
    ConfigName = name,
    SaveTime = os.time()
}

for _, elementData in pairs(Linux.SavedElements or {}) do
    local element = elementData.Element
    local value = elementData.GetValue and elementData.GetValue() or nil
    
    if value ~= nil then
        local elementInfo = {
            Type = element.Type,
            Name = element.Name,
            TabName = elementData.TabName,
            Value = nil
        }
        
        if element.Type == "Toggle" then
            elementInfo.Value = value
        elseif element.Type == "Slider" then
            elementInfo.Value = value
        elseif element.Type == "Dropdown" then
            elementInfo.Value = value
        elseif element.Type == "Input" then
            elementInfo.Value = value
        elseif element.Type == "Colorpicker" then
            local r, g, b = value.R, value.G, value.B
            elementInfo.Value = {r, g, b}
        elseif element.Type == "Keybind" then
            elementInfo.Value = value.Name
        end
        
        if elementInfo.Value ~= nil then
            table.insert(configData.Elements, elementInfo)
        end
    end
end

local success, result = pcall(function()
    local json = HttpService:JSONEncode(configData)
    if writefile then
        if not isfolder(Linux.ConfigFolder) then
            makefolder(Linux.ConfigFolder)
        end
        writefile(Linux.ConfigFolder .. "/" .. name .. ".json", json)
        return true
    else
        return false, "writefile function not available"
    end
end)

if success and result == true then
    Linux.LoadConfigList()
    return true
else
    return false, result or "Error saving configuration"
end
end

function Linux.LoadConfig(name)
if not name or name == "" then
    return false, "Invalid configuration name"
end

local success, result = pcall(function()
    if readfile and isfile(Linux.ConfigFolder .. "/" .. name .. ".json") then
        local json = readfile(Linux.ConfigFolder .. "/" .. name .. ".json")
        local configData = HttpService:JSONDecode(json)
        
        for _, elementInfo in pairs(configData.Elements) do
            for _, elementData in pairs(Linux.SavedElements or {}) do
                local element = elementData.Element
                
                if element.Type == elementInfo.Type and element.Name == elementInfo.Name and elementData.TabName == elementInfo.TabName then
                    if element.Type == "Toggle" then
                        elementData.SetValue(elementInfo.Value)
                    elseif element.Type == "Slider" then
                        elementData.SetValue(elementInfo.Value)
                    elseif element.Type == "Input" then
                        elementData.SetValue(elementInfo.Value)
                    elseif element.Type == "Colorpicker" then
                        local r, g, b = elementInfo.Value[1], elementInfo.Value[2], elementInfo.Value[3]
                        elementData.SetValue(Color3.new(r, g, b))
                    elseif element.Type == "Keybind" then
                        for _, enumItem in pairs(Enum.KeyCode:GetEnumItems()) do
                            if enumItem.Name == elementInfo.Value then
                                elementData.SetValue(enumItem)
                                break
                            end
                        end
                    end
                end
            end
        end
        
        Linux.CurrentConfig = name
        return true
    else
        return false, "Configuration file not found"
    end
end)

return success, result
end

function Linux.DeleteConfig(name)
if not name or name == "" then
    return false, "Invalid configuration name"
end

local success, result = pcall(function()
    if delfile and isfile(Linux.ConfigFolder .. "/" .. name .. ".json") then
        delfile(Linux.ConfigFolder .. "/" .. name .. ".json")
        return true
    else
        return false, "Configuration file not found or delfile function not available"
    end
end)

if success and result == true then
    Linux.LoadConfigList()
    return true
else
    return false, result or "Error deleting configuration"
end
end

function Linux.LoadConfigList()
Linux.SavedConfigs = {}

local success, result = pcall(function()
    if listfiles and isfolder(Linux.ConfigFolder) then
        local files = listfiles(Linux.ConfigFolder)
        
        for _, file in pairs(files) do
            local fileName = string.match(file, "[^/\\]+$")
            local configName = string.match(fileName, "(.+)%.json$")
            
            if configName then
                table.insert(Linux.SavedConfigs, configName)
            end
        end
        
        return true
    else
        return false, "listfiles function not available or folder not found"
    end
end)

return success, Linux.SavedConfigs
end

function Linux.Create(config)
local randomName = "UI_" .. tostring(math.random(100000, 999999))

for _, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and v.Name:match("^UI_%d+$") then
        v:Destroy()
    end
end

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local LinuxUI = Linux.Instance("ScreenGui", {
    Name = randomName,
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
    ResetOnSpawn = false,
    Enabled = true
})

ProtectGui(LinuxUI)

local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
local uiSize = isMobile and (config.SizeMobile or UDim2.fromOffset(300, 500)) or (config.SizePC or UDim2.fromOffset(550, 355))

local Main = Linux.Instance("Frame", {
    Parent = LinuxUI,
    BackgroundColor3 = Color3.fromRGB(37, 37, 37),
    BorderSizePixel = 0,
    Size = uiSize,
    Position = UDim2.new(0.5, -uiSize.X.Offset / 2, 0.5, -uiSize.Y.Offset / 2),
    Active = true,
    Draggable = true,
    ZIndex = 1
})

Linux.Instance("UICorner", {
    Parent = Main,
    CornerRadius = UDim.new(0, 4)
})

-- ÚNICA borda Rainbow
local RainbowStroke = Linux.Instance("UIStroke", {
    Parent = Main,
    Color = Color3.fromRGB(255, 0, 0),
    Thickness = 2
})

-- Animação rainbow
local rainbowConnection
local hue = 0
rainbowConnection = RunService.Heartbeat:Connect(function()
    if not Main or not Main.Parent then
        if rainbowConnection then
            rainbowConnection:Disconnect()
        end
        return
    end
    
    hue = hue + 0.01
    if hue >= 1 then
        hue = 0
    end
    
    local color = Color3.fromHSV(hue, 1, 1)
    RainbowStroke.Color = color
end)

local TopBar = Linux.Instance("Frame", {
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(37, 37, 37),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 30),
    ZIndex = 2
})

Linux.Instance("UICorner", {
    Parent = TopBar,
    CornerRadius = UDim.new(0, 4)
})

local TitleLabel = Linux.Instance("TextLabel", {
    Parent = TopBar,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    Font = Enum.Font.GothamBold,
    Text = config.Name or "Linux UI",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 2
})

local TabsBar = Linux.Instance("Frame", {
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(37, 37, 37),
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(0, config.TabWidth or 130, 1, -30),
    ZIndex = 2,
    BorderSizePixel = 0
})

Linux.Instance("UICorner", {
    Parent = TabsBar,
    CornerRadius = UDim.new(0, 4)
})

Linux.Instance("UIStroke", {
    Parent = TabsBar,
    Color = Color3.fromRGB(39, 39, 42),
    Thickness = 1
})

local ProfileFrame = Linux.Instance("Frame", {
    Parent = TabsBar,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 1, -50),
    ZIndex = 3
})

local ProfileSeparatorLine = Linux.Instance("Frame", {
    Parent = ProfileFrame,
    BackgroundColor3 = Color3.fromRGB(39, 39, 42),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 5),
    ZIndex = 3
})

local ProfileImage = Linux.Instance("ImageLabel", {
    Parent = ProfileFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(0, 10, 0, 13),
    Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
    ZIndex = 3
})

Linux.Instance("UICorner", {
    Parent = ProfileImage,
    CornerRadius = UDim.new(1, 0)
})

local PlayerName = Linux.Instance("TextLabel", {
    Parent = ProfileFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -52, 0, 32),
    Position = UDim2.new(0, 50, 0, 13),
    Font = Enum.Font.GothamSemibold,
    Text = LocalPlayer.DisplayName,
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 3
})

local TabHolder = Linux.Instance("ScrollingFrame", {
    Parent = TabsBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 8),
    Size = UDim2.new(1, 0, 1, -58),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 0,
    ZIndex = 2,
    ScrollingEnabled = true
})

Linux.Instance("UIListLayout", {
    Parent = TabHolder,
    Padding = UDim.new(0, 1),
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder
})

Linux.Instance("UIPadding", {
    Parent = TabHolder,
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingTop = UDim.new(0, 8)
})

local Content = Linux.Instance("Frame", {
    Parent = Main,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, config.TabWidth or 130, 0, 30),
    Size = UDim2.new(1, -(config.TabWidth or 130), 1, -30),
    ZIndex = 1
})

InputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        Main.Visible = not Main.Visible
    end
end)

local LinuxLib = {}
local Tabs = {}
local AllElements = {}
local CurrentTab = nil
local tabOrder = 0

Linux.SavedElements = {}

function LinuxLib.Tab(config)
    tabOrder = tabOrder + 1
    local tabIndex = tabOrder
    
    local TabBtn = Linux.Instance("TextButton", {
        Parent = TabHolder,
        BackgroundColor3 = Color3.fromRGB(31, 31, 31),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(39, 39, 42),
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextSize = 14,
        ZIndex = 2,
        AutoButtonColor = false,
        LayoutOrder = tabIndex
    })
    
    Linux.Instance("UICorner", {
        Parent = TabBtn,
        CornerRadius = UDim.new(0, 4)
    })
    
    local TabIcon
    if config.Icon and config.Enabled then
        TabIcon = Linux.Instance("ImageLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            Image = config.Icon,
            ImageColor3 = Color3.fromRGB(150, 150, 150),
            ZIndex = 2
        })
    end
    
    local textOffset = config.Icon and config.Enabled and 33 or 16
    local TabText = Linux.Instance("TextLabel", {
        Parent = TabBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(textOffset + 20), 1, 0),
        Position = UDim2.new(0, textOffset, 0, 0),
        Font = Enum.Font.GothamSemibold,
        Text = config.Name,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    
    local TabContent = Linux.Instance("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 1
    })
    
    local TitleFrame = Linux.Instance("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 3
    })
    
    local TitleLabel = Linux.Instance("TextLabel", {
        Parent = TitleFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = config.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4
    })
    
    local Container = Linux.Instance("ScrollingFrame", {
        Parent = TabContent,
        BackgroundColor3 = Color3.fromRGB(37, 37, 37),
        Size = UDim2.new(1, -16, 1, -70),
        Position = UDim2.new(0, 12, 0, 55),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 1,
        BorderSizePixel = 0,
        ScrollingEnabled = true,
        CanvasPosition = Vector2.new(0, 0)
    })
    
    Linux.Instance("UICorner", {
        Parent = Container,
        CornerRadius = UDim.new(0, 4)
    })
    
    local ContainerListLayout = Linux.Instance("UIListLayout", {
        Parent = Container,
        Padding = UDim.new(0, 1),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Linux.Instance("UIPadding", {
        Parent = Container,
        PaddingLeft = UDim.new(0, 2),
        PaddingTop = UDim.new(0, 0)
    })
    
    local function SelectTab()
        if CurrentTab == tabIndex then
            return
        end
        
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.TitleFrame.Visible = false
            tab.Text.TextColor3 = Color3.fromRGB(150, 150, 150)
            tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            
            if tab.Icon then
                tab.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        
        TabContent.Visible = true
        TitleFrame.Visible = true
        TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        
        if TabIcon then
            TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        CurrentTab = tabIndex
        Container.CanvasPosition = Vector2.new(0, 0)
    end
    
    TabBtn.MouseButton1Click:Connect(SelectTab)
    
    Tabs[tabIndex] = {
        Name = config.Name,
        Button = TabBtn,
        Text = TabText,
        Icon = TabIcon,
        Content = TabContent,
        TitleFrame = TitleFrame,
        Elements = {}
    }
    
    if tabOrder == 1 then
        CurrentTab = tabIndex
        TabContent.Visible = true
        TitleFrame.Visible = true
        TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        
        if TabIcon then
            TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    local TabElements = {}
    local elementOrder = 0
    local lastWasDropdown = false
    
    function TabElements.Button(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local BtnFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        local Btn = Linux.Instance("TextButton", {
            Parent = BtnFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            AutoButtonColor = false
        })
        
        Linux.Instance("UIPadding", {
            Parent = Btn,
            PaddingLeft = UDim.new(0, 10)
        })
        
        local BtnIcon = Linux.Instance("ImageLabel", {
            Parent = BtnFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            Image = "https://www.roblox.com/asset/?id=10734929723",
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            ZIndex = 2
        })
        
        local buttonClicked = false
        Btn.MouseButton1Click:Connect(function()
            if not buttonClicked then
                buttonClicked = true
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
                task.wait(0.3)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                buttonClicked = false
            end
            spawn(function() Linux:SafeCallback(config.Callback) end)
        end)
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Button",
            Name = config.Name,
            Instance = BtnFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        return Btn
    end
    
    function TabElements.Toggle(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local Toggle = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })

        local ToggleText = Linux.Instance("TextLabel", {
            Parent = Toggle,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Name = "ToggleText"
        })
        
        local CheckBox = Linux.Instance("Frame", {
            Parent = Toggle,
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -28, 0.5, -9),
            ZIndex = 2,
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(39, 39, 42),
            Name = "CheckBox"
        })
        
        Linux.Instance("UICorner", {
            Parent = CheckBox,
            CornerRadius = UDim.new(0, 2)
        })
        
        Linux.Instance("UIStroke", {
            Parent = CheckBox,
            Color = Color3.fromRGB(60, 60, 70),
            Thickness = 1
        })
        
        local CheckIcon = Linux.Instance("ImageLabel", {
            Parent = CheckBox,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, -6, 0.5, -6),
            Image = "rbxassetid://10709790644",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 1,
            ZIndex = 4
        })
        
        local State = config.Default or false
        Toggle:SetAttribute("State", State)
        
        local isToggling = false
        local function UpdateToggle(thisToggle)
            if isToggling then return end
            isToggling = true
            
            local currentState = thisToggle:GetAttribute("State")
            local thisCheckBox = thisToggle:FindFirstChild("CheckBox")
            local thisCheckIcon = thisCheckBox and thisCheckBox:FindFirstChild("ImageLabel")
            
            if thisCheckBox and thisCheckIcon then
                local tween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if currentState then
                    TweenService:Create(thisCheckBox, tween, {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
                    TweenService:Create(thisCheckIcon, tween, {ImageTransparency = 0}):Play()
                else
                    TweenService:Create(thisCheckBox, tween, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
                    TweenService:Create(thisCheckIcon, tween, {ImageTransparency = 1}):Play()
                end
            end
            
            task.wait(0.25)
            isToggling = false
        end
        
        local function SetValue(newState)
            Toggle:SetAttribute("State", newState)
            UpdateToggle(Toggle)
            spawn(function() Linux:SafeCallback(config.Callback, newState) end)
        end
        
        UpdateToggle(Toggle)
        spawn(function() Linux:SafeCallback(config.Callback, State) end)
        
        local function toggleSwitch()
            if not isToggling then
                local newState = not Toggle:GetAttribute("State")
                SetValue(newState)
            end
        end
        
        CheckBox.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                toggleSwitch()
            end
        end)
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Toggle",
            Name = config.Name,
            Instance = Toggle,
            State = State
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() return Toggle:GetAttribute("State") end,
            SetValue = SetValue
        })
        
        return Toggle
    end
    
    function TabElements.Dropdown(config)
        elementOrder = elementOrder + 1
        lastWasDropdown = true
        
        local Dropdown = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        local DropdownButton = Linux.Instance("TextButton", {
            Parent = Dropdown,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            ZIndex = 2,
            AutoButtonColor = false
        })
        
        Linux.Instance("TextLabel", {
            Parent = DropdownButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local Options = config.Options or {}
        local SelectedValue = config.Default or (Options[1] or "None")
        local IsMulti = config.Multi or false
        local SelectedValues = {}
        
        if IsMulti then
            if typeof(config.Default) == "table" then
                for _, value in pairs(config.Default) do
                    if table.find(Options, value) then
                        table.insert(SelectedValues, value)
                    end
                end
            elseif config.Default and table.find(Options, config.Default) then
                table.insert(SelectedValues, config.Default)
            end
        end
        
        local function FormatDisplayText(value)
            if typeof(value) == "table" then
                if #value > 0 then
                    local displayText = table.concat(value, ", ")
                    return displayText:sub(1, 20) .. (#displayText > 20 and "..." or "")
                else
                    return "None"
                end
            else
                return value and tostring(value) or "None"
            end
        end
        
        local Selected = Linux.Instance("TextLabel", {
            Parent = DropdownButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.3, -21, 1, 0),
            Position = UDim2.new(0.65, 5, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = IsMulti and FormatDisplayText(SelectedValues) or FormatDisplayText(SelectedValue),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 2
        })
        
        local Arrow = Linux.Instance("ImageLabel", {
            Parent = DropdownButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            Image = "https://www.roblox.com/asset/?id=10709791437",
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            Rotation = 0,
            ZIndex = 2
        })
        
        local DropFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 0),
            ZIndex = 3,
            LayoutOrder = elementOrder + 1,
            ClipsDescendants = true,
            Visible = false
        })
        
        local OptionsHolder = Linux.Instance("ScrollingFrame", {
            Parent = DropFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ZIndex = 3,
            ScrollingEnabled = true
        })
        
        Linux.Instance("UIListLayout", {
            Parent = OptionsHolder,
            Padding = UDim.new(0, 1),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Linux.Instance("UIPadding", {
            Parent = OptionsHolder,
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })
        
        local IsOpen = false
        
        local function UpdateDropSize()
            local optionHeight = 28
            local paddingBetween = 1
            local paddingTopBottom = 10
            local maxHeight = 150
            local numOptions = #Options
            local calculatedHeight = numOptions * optionHeight + (numOptions > 0 and (numOptions - 1) * paddingBetween + paddingTopBottom or 0)
            local finalHeight = math.min(calculatedHeight, maxHeight)
            
            local tween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if IsOpen then
                DropFrame.Visible = true
                DropFrame.Size = UDim2.new(1, -8, 0, 0)
                TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -8, 0, finalHeight)}):Play()
                TweenService:Create(Arrow, tween, {Rotation = 85}):Play()
            else
                TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -8, 0, 0)}):Play()
                TweenService:Create(Arrow, tween, {Rotation = 0}):Play()
                task.delay(0.25, function()
                    if not IsOpen then
                        DropFrame.Visible = false
                    end
                end)
            end
        end
        
        local function UpdateSelectedText()
            if IsMulti then
                Selected.Text = FormatDisplayText(SelectedValues)
            else
                Selected.Text = FormatDisplayText(SelectedValue)
            end
        end
        
        local function PopulateOptions()
            for _, child in pairs(OptionsHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            if IsOpen then
                for i, opt in pairs(Options) do
                    local isSelected = IsMulti and table.find(SelectedValues, opt) or opt == SelectedValue
                    
                    local OptBtn = Linux.Instance("TextButton", {
                        Parent = OptionsHolder,
                        BackgroundColor3 = Color3.fromRGB(31, 31, 31),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(39, 39, 42),
                        Size = UDim2.new(1, -4, 0, 28),
                        Font = Enum.Font.GothamSemibold,
                        Text = tostring(opt),
                        TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210),
                        TextSize = 14,
                        ZIndex = 3,
                        AutoButtonColor = false,
                        LayoutOrder = i
                    })
                    
                    Linux.Instance("UICorner", {
                        Parent = OptBtn,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if IsMulti then
                            local index = table.find(SelectedValues, opt)
                            
                            if index then
                                table.remove(SelectedValues, index)
                                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
                            else
                                table.insert(SelectedValues, opt)
                                OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end
                            UpdateSelectedText()
                            spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
                        else
                            if opt ~= SelectedValue then
                                SelectedValue = opt
                                Selected.Text = FormatDisplayText(opt)
                                Selected.TextColor3 = Color3.fromRGB(255, 255, 255)
                                
                                for _, btn in pairs(OptionsHolder:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        if btn.Text == tostring(opt) then
                                            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        else
                                            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
                                        end
                                    end
                                end
                                
                                spawn(function() Linux:SafeCallback(config.Callback, opt) end)
                            end
                        end
                    end)
                end
            end
            
            UpdateDropSize()
        end
        
        if #Options > 0 then
            PopulateOptions()
            if IsMulti then
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
            else
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValue) end)
            end
        end
        
        Arrow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                IsOpen = not IsOpen
                PopulateOptions()
            end
        end)
        
        local function SetOptions(newOptions)
            Options = newOptions or {}
            if IsMulti then
                SelectedValues = {}
            else
                SelectedValue = Options[1] or "None"
            end
            UpdateSelectedText()
            
            IsOpen = false
            UpdateDropSize()
            PopulateOptions()
            
            if IsMulti then
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
            else
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValue) end)
            end
        end
        
        local function SetValue(value)
            if IsMulti then
                if typeof(value) == "table" then
                    SelectedValues = {}
                    for _, v in pairs(value) do
                        if table.find(Options, v) then
                            table.insert(SelectedValues, v)
                        end
                    end
                elseif table.find(Options, value) then
                    SelectedValues = {value}
                end
                UpdateSelectedText()
            else
                if table.find(Options, value) then
                    SelectedValue = value
                    Selected.Text = FormatDisplayText(value)
                    Selected.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
            
            IsOpen = false
            UpdateDropSize()
            PopulateOptions()
            
            if IsMulti then
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
            else
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValue) end)
            end
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Dropdown",
            Name = config.Name,
            Instance = Dropdown,
            Value = IsMulti and SelectedValues or SelectedValue
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() return IsMulti and SelectedValues or SelectedValue end,
            SetValue = SetValue
        })
        
        return {
            Instance = Dropdown,
            SetOptions = SetOptions,
            SetValue = SetValue,
            GetValue = function() return IsMulti and SelectedValues or SelectedValue end
        }
    end
    
    function TabElements.Slider(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local Slider = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 42),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        local TitleLabel = Linux.Instance("TextLabel", {
            Parent = Slider,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 0, 16),
            Position = UDim2.new(0, 10, 0, 4),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local SliderBar = Linux.Instance("Frame", {
            Parent = Slider,
            BackgroundColor3 = Color3.fromRGB(23, 23, 23),
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0, 26),
            ZIndex = 2,
            BorderSizePixel = 0,
            Name = "Bar"
        })
        
        Linux.Instance("UICorner", {
            Parent = SliderBar,
            CornerRadius = UDim.new(0, 3)
        })
        
        Linux.Instance("UIStroke", {
            Parent = SliderBar,
            Color = Color3.fromRGB(39, 39, 42),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        local ValueLabel = Linux.Instance("TextLabel", {
            Parent = Slider,
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Size = UDim2.new(0, 50, 0, 16),
            Position = UDim2.new(1, -60, 0, 4),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 2,
            BorderSizePixel = 0,
            Name = "Value"
        })
        
        Linux.Instance("UICorner", {
            Parent = ValueLabel,
            CornerRadius = UDim.new(0, 4)
        })
        
        Linux.Instance("UIStroke", {
            Parent = ValueLabel,
            Color = Color3.fromRGB(39, 39, 42),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        local FillBar = Linux.Instance("Frame", {
            Parent = SliderBar,
            BackgroundColor3 = Color3.fromRGB(255, 105, 180),
            Size =  UDim2.new(0, 0, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(39, 39, 42),
            Name = "Fill"
        })
        
        Linux.Instance("UICorner", {
            Parent = FillBar,
            CornerRadius = UDim.new(1, 0)
        })
        
        local SliderButton = Linux.Instance("TextButton", {
            Parent = SliderBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 3
        })
        
        local Min = config.Min or 0
        local Max = config.Max or 100
        local Rounding = config.Rounding or 0
        
        Slider:SetAttribute("Min", Min)
        Slider:SetAttribute("Max", Max)
        Slider:SetAttribute("Rounding", Rounding)
        
        local Value = config.Default or Min
        
        Slider:SetAttribute("Value", Value)
        
        local function AnimateValueLabel()
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(ValueLabel, tweenInfo, {TextSize = 16}):Play()
            task.wait(0.2)
            TweenService:Create(ValueLabel, tweenInfo, {TextSize = 14}):Play()
        end
        
        local function FormatValue(value)
            if Rounding <= 0 then
                return tostring(math.floor(value))
            else
                local mult = 10 ^ Rounding
                return tostring(math.floor(value * mult) / mult)
            end
        end
        
        local function UpdateSlider(pos)
            local barSize = SliderBar.AbsoluteSize.X
            local relativePos = math.clamp((pos - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
            
            local min = Slider:GetAttribute("Min")
            local max = Slider:GetAttribute("Max")
            local rounding = Slider:GetAttribute("Rounding")
            
            local value = min + (max - min) * relativePos
            
            if rounding <= 0 then
                value = math.floor(value + 0.5)
            else
                local mult = 10 ^ rounding
                value = math.floor(value * mult + 0.5) / mult
            end
            
            Slider:SetAttribute("Value", value)
            
            FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
            
            ValueLabel.Text = FormatValue(value)
            
            AnimateValueLabel()
            spawn(function() Linux:SafeCallback(config.Callback, value) end)
        end
        
        local draggingSlider = false
        
        SliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                UpdateSlider(input.Position.X)
            end
        end)
        
        SliderButton.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and draggingSlider then
                UpdateSlider(input.Position.X)
            end
        end)
        
        SliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        
        local function SetValue(newValue)
            local min = Slider:GetAttribute("Min")
            local max = Slider:GetAttribute("Max")
            local rounding = Slider:GetAttribute("Rounding")
            
            newValue = math.clamp(newValue, min, max)
            
            if rounding <= 0 then
                newValue = math.floor(newValue + 0.5)
            else
                local mult = 10 ^ rounding
                newValue = math.floor(newValue * mult + 0.5) / mult
            end
            
            Slider:SetAttribute("Value", newValue)
            
            local relativePos = (newValue - min) / (max - min)
            
            FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
            
            ValueLabel.Text = FormatValue(newValue)
            
            AnimateValueLabel()
            spawn(function() Linux:SafeCallback(config.Callback, newValue) end)
        end
        
        SetValue(Value)
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Slider",
            Name = config.Name,
            Instance = Slider,
            Value = Value
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() return Slider:GetAttribute("Value") end,
            SetValue = SetValue
        })
        
        return {
            Instance = Slider,
            SetValue = SetValue,
            GetValue = function() return Slider:GetAttribute("Value") end,
            SetMin = function(min)
                Slider:SetAttribute("Min", min)
                SetValue(Slider:GetAttribute("Value"))
            end,
            SetMax = function(max)
                Slider:SetAttribute("Max", max)
                SetValue(Slider:GetAttribute("Value"))
            end,
            SetRounding = function(rounding)
                Slider:SetAttribute("Rounding", rounding)
                SetValue(Slider:GetAttribute("Value"))
            end
        }
    end
    
    function TabElements.Input(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local Input = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        Linux.Instance("TextLabel", {
            Parent = Input,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local InputIcon = Linux.Instance("ImageLabel", {
            Parent = Input,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -42, 0.5, -8),
            Image = "rbxassetid://10710001408",
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            ZIndex = 2
        })
        
        local IsNumeric = config.Numeric or false
        
        local TextBox = Linux.Instance("TextBox", {
            Parent = Input,
            BackgroundColor3 = Color3.fromRGB(19, 19, 19),
            BorderSizePixel = 0,
            Size = UDim2.new(0.3, -16, 0, 24),
            Position = UDim2.new(0.7, -20, 0.5, -12),
            Font = Enum.Font.GothamSemibold,
            Text = config.Default or "",
            PlaceholderText = config.Placeholder or (IsNumeric and "Number here" or "Text here"),
            PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = false,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false,
            ClipsDescendants = true,
            ZIndex = 3
        })
        
        Linux.Instance("UICorner", {
            Parent = TextBox,
            CornerRadius = UDim.new(0, 4)
        })
        
        Linux.Instance("UIStroke", {
            Parent = TextBox,
            Color = Color3.fromRGB(39, 39, 42),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        Linux.Instance("UIPadding", {
            Parent = TextBox,
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6)
        })
        
        local MaxLength = 100
        
        local function FilterNumericInput(text)
            if not IsNumeric then
                return text
            end
            
            local filtered = string.gsub(text, "[^%d%.%-]", "")
            
            local _, decimalCount = string.gsub(filtered, "%.", "")
            if decimalCount > 1 then
                local firstDecimal = string.find(filtered, "%.")
                filtered = string.sub(filtered, 1, firstDecimal) .. string.gsub(string.sub(filtered, firstDecimal + 1), "%.", "")
            end
            
            if string.find(filtered, "%-") then
                local hasNegative = string.sub(filtered, 1, 1) == "-"
                filtered = string.gsub(filtered, "%-", "")
                if hasNegative then
                    filtered = "-" .. filtered
                end
            end
            
            return filtered
        end
        
        local function CheckTextBounds()
            local currentText = TextBox.Text
            
            if IsNumeric then
                currentText = FilterNumericInput(currentText)
            end
            
            if #currentText > MaxLength then
                currentText = string.sub(currentText, 1, MaxLength)
            end
            
            if currentText ~= TextBox.Text then
                TextBox.Text = currentText
            end
        end
        
        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            CheckTextBounds()
        end)
        
        local function UpdateInput()
            CheckTextBounds()
            local value = TextBox.Text
            
            if IsNumeric and value ~= "" then
                local numValue = tonumber(value)
                if numValue then
                    spawn(function() Linux:SafeCallback(config.Callback, numValue) end)
                else
                    spawn(function() Linux:SafeCallback(config.Callback, 0) end)
                end
            else
                spawn(function() Linux:SafeCallback(config.Callback, value) end)
            end
        end
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                UpdateInput()
            end
        end)
        
        TextBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                TextBox:CaptureFocus()
            end
        end)
        
        spawn(function() 
            local value = TextBox.Text
            if IsNumeric and value ~= "" then
                local numValue = tonumber(value)
                Linux:SafeCallback(config.Callback, numValue or 0)
            else
                Linux:SafeCallback(config.Callback, value)
            end
        end)
        
        local function SetValue(newValue)
            local text = tostring(newValue)
            
            if IsNumeric then
                text = FilterNumericInput(text)
            end
            
            if #text > MaxLength then
                text = string.sub(text, 1, MaxLength)
            end
            
            TextBox.Text = text
            UpdateInput()
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Input",
            Name = config.Name,
            Instance = Input,
            Value = TextBox.Text
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() 
                if IsNumeric and TextBox.Text ~= "" then
                    return tonumber(TextBox.Text) or 0
                else
                    return TextBox.Text
                end
            end,
            SetValue = SetValue
        })
        
        return {
            Instance = Input,
            SetValue = SetValue,
            GetValue = function() 
                if IsNumeric and TextBox.Text ~= "" then
                    return tonumber(TextBox.Text) or 0
                else
                    return TextBox.Text
                end
            end
        }
    end
    
    function TabElements.Label(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local LabelFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        local LabelText = Linux.Instance("TextLabel", {
            Parent = LabelFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Text or "Label",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 2
        })
        
        local UpdateConnection = nil
        local lastUpdate = 0
        local updateInterval = 0.1
        
        local function StartUpdateLoop()
            if UpdateConnection then
                UpdateConnection:Disconnect()
                UpdateConnection = nil
            end
            if config.UpdateCallback then
                UpdateConnection = RunService.Heartbeat:Connect(function()
                    if not LabelFrame:IsDescendantOf(game) then
                        UpdateConnection:Disconnect()
                        UpdateConnection = nil
                        return
                    end
                    local currentTime = tick()
                    if currentTime - lastUpdate >= updateInterval then
                        local success, newText = pcall(config.UpdateCallback)
                        if success and newText ~= nil then
                            LabelText.Text = tostring(newText)
                        end
                        lastUpdate = currentTime
                    end
                end)
            end
        end
        
        local function SetText(newText)
            if config.UpdateCallback then
                config.Text = tostring(newText)
            else
                LabelText.Text = tostring(newText)
            end
        end
        
        if config.UpdateCallback then
            StartUpdateLoop()
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Label",
            Name = config.Text or "Label",
            Instance = LabelFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        return {
            Instance = LabelFrame,
            SetText = SetText,
            GetText = function() return LabelText.Text end
        }
    end
    
    function TabElements.Section(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local Section = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            LayoutOrder = elementOrder,
            BorderSizePixel = 0,
            Name = "Section"
        })
        
        local SectionLabel = Linux.Instance("TextLabel", {
            Parent = Section,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            Font = Enum.Font.GothamBold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Section",
            Name = config.Name,
            Instance = Section
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        return Section
    end
    
    function TabElements.Paragraph(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local ParagraphFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        Linux.Instance("TextLabel", {
            Parent = ParagraphFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 26),
            Position = UDim2.new(0, 10, 0, 5),
            Font = Enum.Font.GothamBold,
            Text = config.Title or "Paragraph",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local Content = Linux.Instance("TextLabel", {
            Parent = ParagraphFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 30),
            Font = Enum.Font.GothamSemibold,
            Text = config.Content or "Content",
            TextColor3 = Color3.fromRGB(150, 150, 155),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2
        })
        
        Linux.Instance("UIPadding", {
            Parent = ParagraphFrame,
            PaddingBottom = UDim.new(0, 10)
        })
        
        local function SetTitle(newTitle)
            ParagraphFrame:GetChildren()[3].Text = tostring(newTitle)
        end
        
        local function SetContent(newContent)
            Content.Text = tostring(newContent)
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Paragraph",
            Name = config.Title or "Paragraph",
            Instance = ParagraphFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        return {
            Instance = ParagraphFrame,
            SetTitle = SetTitle,
            SetContent = SetContent
        }
    end
    
    function TabElements.Notification(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local NotificationFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(39, 39, 42),
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        Linux.Instance("UICorner", {
            Parent = NotificationFrame,
            CornerRadius = UDim.new(0, 4)
        })
        
        Linux.Instance("UIStroke", {
            Parent = NotificationFrame,
            Color = Color3.fromRGB(20, 20, 21),
            Thickness = 1
        })
        
        Linux.Instance("TextLabel", {
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local NotificationText = Linux.Instance("TextLabel", {
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -20, 1, 0),
            Position = UDim2.new(0.5, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Default or "Notification",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 2
        })
        
        local function SetText(newText)
            NotificationText.Text = tostring(newText)
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Notification",
            Name = config.Name,
            Instance = NotificationFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        return {
            Instance = NotificationFrame,
            SetText = SetText,
            GetText = function() return NotificationText.Text end
        }
    end
    
    function TabElements.Keybind(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local KeybindFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        Linux.Instance("TextLabel", {
            Parent = KeybindFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local currentKey = config.Default or Enum.KeyCode.None
        local isCapturing = false
        
        local KeybindButton = Linux.Instance("TextButton", {
            Parent = KeybindFrame,
            BackgroundColor3 = Color3.fromRGB(19, 19, 19),
            BorderSizePixel = 0,
            Size = UDim2.new(0.3, -16, 0, 24),
            Position = UDim2.new(0.7, 0, 0.5, -12),
            Font = Enum.Font.GothamSemibold,
            Text = tostring(currentKey.Name),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            ZIndex = 3,
            AutoButtonColor = false
        })
        
        Linux.Instance("UICorner", {
            Parent = KeybindButton,
            CornerRadius = UDim.new(0, 4)
        })
        
        Linux.Instance("UIStroke", {
            Parent = KeybindButton,
            Color = Color3.fromRGB(39, 39, 42),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        local inputConnection = nil
        
        local function StopCapture()
            if inputConnection then
                inputConnection:Disconnect()
                inputConnection = nil
            end
            isCapturing = false
            KeybindButton.Text = tostring(currentKey.Name)
            KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        KeybindButton.MouseButton1Click:Connect(function()
            if isCapturing then
                StopCapture()
                return
            end
            isCapturing = true
            KeybindButton.Text = "..."
            KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 210)
            
            inputConnection = InputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        StopCapture()
                    else
                        currentKey = input.KeyCode
                        StopCapture()
                        spawn(function() Linux:SafeCallback(config.Callback, currentKey) end)
                    end
                end
            end)
        end)
        
        spawn(function() Linux:SafeCallback(config.Callback, currentKey) end)
        
        local function SetValue(newKey)
            if typeof(newKey) == "EnumItem" and newKey.EnumType == Enum.KeyCode then
                currentKey = newKey
                KeybindButton.Text = tostring(currentKey.Name)
                spawn(function() Linux:SafeCallback(config.Callback, currentKey) end)
            end
        end
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Keybind",
            Name = config.Name,
            Instance = KeybindFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() return currentKey end,
            SetValue = SetValue
        })
        
        return {
            Instance = KeybindFrame,
            SetValue = SetValue,
            GetValue = function() return currentKey end
        }
    end
    
    function TabElements.Colorpicker(config)
        elementOrder = elementOrder + 1
        if lastWasDropdown then
            ContainerListLayout.Padding = UDim.new(0, 5)
        else
            ContainerListLayout.Padding = UDim.new(0, 1)
        end
        lastWasDropdown = false
        
        local ColorpickerFrame = Linux.Instance("Frame", {
            Parent = Container,
            BackgroundColor3 = Color3.fromRGB(31, 31, 31),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 36),
            ZIndex = 1,
            LayoutOrder = elementOrder
        })
        
        Linux.Instance("TextLabel", {
            Parent = ColorpickerFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        local currentColor = config.Default or Color3.fromRGB(255, 255, 255)
        local isPicking = false
        
        local ColorPreview = Linux.Instance("Frame", {
            Parent = ColorpickerFrame,
            BackgroundColor3 = currentColor,
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(39, 39, 42),
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -34, 0.5, -12),
            ZIndex = 3
        })
        
        Linux.Instance("UICorner", {
            Parent = ColorPreview,
            CornerRadius = UDim.new(0, 4)
        })
        
        Linux.Instance("UIStroke", {
            Parent = ColorPreview,
            Color = Color3.fromRGB(60, 60, 70),
            Thickness = 1
        })
        
        local ColorpickerPopup = nil
        local paletteMarker = nil
        local hueMarker = nil
        local currentHue = 0
        local currentSaturation = 0
        local currentValue = 1
        
        local function UpdateColorFromHSV(updateCallback)
            currentColor = Color3.fromHSV(currentHue, currentSaturation, currentValue)
            ColorPreview.BackgroundColor3 = currentColor
            
            if ColorpickerPopup then
                local palette = ColorpickerPopup:FindFirstChild("Palette")
                if palette then
                    palette.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                end
                
                local preview = ColorpickerPopup:FindFirstChild("ColorPreview")
                if preview then
                    preview.BackgroundColor3 = currentColor
                end
            end
            
            if updateCallback then
                spawn(function() Linux:SafeCallback(config.Callback, currentColor) end)
            end
        end
        
        local function CreateColorpickerPopup()
            if ColorpickerPopup then
                ColorpickerPopup:Destroy()
            end
            
            ColorpickerPopup = Linux.Instance("Frame", {
                Parent = Main,
                BackgroundColor3 = Color3.fromRGB(12, 12, 15),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(39, 39, 42),
                Size = UDim2.new(0, 200, 0, 180),
                Position = UDim2.new(0.5, -100, 0.5, -90),
                ZIndex = 10,
                Visible = false
            })
            
            Linux.Instance("UICorner", {
                Parent = ColorpickerPopup,
                CornerRadius = UDim.new(0, 6)
            })
            
            Linux.Instance("UIStroke", {
                Parent = ColorpickerPopup,
                Color = Color3.fromRGB(25, 25, 30),
                Thickness = 1
            })
            
            local Palette = Linux.Instance("Frame", {
                Parent = ColorpickerPopup,
                BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1),
                Size = UDim2.new(0, 150, 0, 120),
                Position = UDim2.new(0, 10, 0, 10),
                ZIndex = 11,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(39, 39, 42),
                Name = "Palette"
            })
            
            Linux.Instance("UICorner", {
                Parent = Palette,
                CornerRadius = UDim.new(0, 4)
            })
            
            local SaturationGradient = Linux.Instance("UIGradient", {
                Parent = Palette,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(currentHue, 1, 1))
                }),
                Transparency = NumberSequence.new(0),
                Rotation = 0
            })
            
            local ValueOverlay = Linux.Instance("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 11,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(39, 39, 42)
            })
            
            Linux.Instance("UICorner", {
                Parent = ValueOverlay,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ValueGradient = Linux.Instance("UIGradient", {
                Parent = ValueOverlay,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }),
                Rotation = 90
            })
            
            paletteMarker = Linux.Instance("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 8, 0, 8),
                ZIndex = 12,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5)
            })
            
            Linux.Instance("UICorner", {
                Parent = paletteMarker,
                CornerRadius = UDim.new(1, 0)
            })
            
            local HueBar = Linux.Instance("Frame", {
                Parent = ColorpickerPopup,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 20, 0, 120),
                Position = UDim2.new(0, 170, 0, 10),
                ZIndex = 11,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(39, 39, 42)
            })
            
            Linux.Instance("UICorner", {
                Parent = HueBar,
                CornerRadius = UDim.new(0, 4)
            })
            
            local HueGradient = Linux.Instance("UIGradient", {
                Parent = HueBar,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Rotation = 90
            })
            
            hueMarker = Linux.Instance("Frame", {
                Parent = HueBar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 4, 0, 6),
                ZIndex = 12,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0, 0)
            })
            
            Linux.Instance("UICorner", {
                Parent = hueMarker,
                CornerRadius = UDim.new(0, 2)
            })
            
            local ColorPreview = Linux.Instance("Frame", {
                Parent = ColorpickerPopup,
                BackgroundColor3 = currentColor,
                Size = UDim2.new(0, 180, 0, 30),
                Position = UDim2.new(0, 10, 0, 140),
                ZIndex = 11,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(39, 39, 42),
                Name = "ColorPreview"
            })
            
            Linux.Instance("UICorner", {
                Parent = ColorPreview,
                CornerRadius = UDim.new(0, 4)
            })
            
            local paletteDragging = false
            local hueDragging = false
            
            Palette.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    paletteDragging = true
                    local pos = input.Position
                    local palettePos = Palette.AbsolutePosition
                    local paletteSize = Palette.AbsoluteSize
                    local x = math.clamp((pos.X - palettePos.X) / paletteSize.X, 0, 1)
                    local y = math.clamp((pos.Y - palettePos.Y) / paletteSize.Y, 0, 1)
                    currentSaturation = x
                    currentValue = 1 - y
                    paletteMarker.Position = UDim2.new(x, 0, y, 0)
                    UpdateColorFromHSV(true)
                end
            end)
            
            Palette.InputChanged:Connect(function(input)
                if paletteDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position
                    local palettePos = Palette.AbsolutePosition
                    local paletteSize = Palette.AbsoluteSize
                    local x = math.clamp((pos.X - palettePos.X) / paletteSize.X, 0, 1)
                    local y = math.clamp((pos.Y - palettePos.Y) / paletteSize.Y, 0, 1)
                    currentSaturation = x
                    currentValue = 1 - y
                    paletteMarker.Position = UDim2.new(x, 0, y, 0)
                    UpdateColorFromHSV(true)
                end
            end)
            
            Palette.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    paletteDragging = false
                end
            end)
            
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    local pos = input.Position
                    local huePos = HueBar.AbsolutePosition
                    local hueSize = HueBar.AbsoluteSize
                    local y = math.clamp((pos.Y - huePos.Y) / hueSize.Y, 0, 1)
                    currentHue = 1 - y
                    hueMarker.Position = UDim2.new(0.5, 0, y, 0)
                    UpdateColorFromHSV(true)
                end
            end)
            
            HueBar.InputChanged:Connect(function(input)
                if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position
                    local huePos = HueBar.AbsolutePosition
                    local hueSize = HueBar.AbsoluteSize
                    local y = math.clamp((pos.Y - huePos.Y) / hueSize.Y, 0, 1)
                    currentHue = 1 - y
                    hueMarker.Position = UDim2.new(0.5, 0, y, 0)
                    UpdateColorFromHSV(true)
                end
            end)
            
            HueBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)
            
            local h, s, v = currentColor:ToHSV()
            currentHue = h
            currentSaturation = s
            currentValue = v
            paletteMarker.Position = UDim2.new(s, 0, 1 - v, 0)
            hueMarker.Position = UDim2.new(0.5, 0, 1 - h, 0)
            Palette.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        end
        
        ColorPreview.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPicking = not isPicking
                if isPicking then
                    CreateColorpickerPopup()
                    ColorpickerPopup.Visible = true
                else
                    if ColorpickerPopup then
                        ColorpickerPopup.Visible = false
                    end
                end
            end
        end)
        
        InputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorpickerPopup and ColorpickerPopup.Visible then
                local mousePos = InputService:GetMouseLocation()
                local popupPos = ColorpickerPopup.AbsolutePosition
                local popupSize = ColorpickerPopup.AbsoluteSize
                
                if mousePos.X < popupPos.X or mousePos.X > popupPos.X + popupSize.X or
                   mousePos.Y < popupPos.Y or mousePos.Y > popupPos.Y + popupSize.Y then
                    isPicking = false
                    ColorpickerPopup.Visible = false
                end
            end
        end)
        
        local function SetValue(newColor)
            if typeof(newColor) == "Color3" then
                currentColor = newColor
                ColorPreview.BackgroundColor3 = currentColor
                local h, s, v = newColor:ToHSV()
                currentHue = h
                currentSaturation = s
                currentValue = v
                if ColorpickerPopup then
                    paletteMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueMarker.Position = UDim2.new(0.5, 0, 1 - h, 0)
                    local palette = ColorpickerPopup:FindFirstChild("Palette")
                    if palette then
                        palette.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    end
                    local preview = ColorpickerPopup:FindFirstChild("ColorPreview")
                    if preview then
                        preview.BackgroundColor3 = currentColor
                    end
                end
                spawn(function() Linux:SafeCallback(config.Callback, currentColor) end)
            end
        end
        
        spawn(function() Linux:SafeCallback(config.Callback, currentColor) end)
        
        Container.CanvasPosition = Vector2.new(0, 0)
        
        local element = {
            Type = "Colorpicker",
            Name = config.Name,
            Instance = ColorpickerFrame
        }
        table.insert(Tabs[tabIndex].Elements, element)
        table.insert(AllElements, {Tab = tabIndex, Element = element})
        
        table.insert(Linux.SavedElements, {
            Element = element,
            TabName = Tabs[tabIndex].Name,
            GetValue = function() return currentColor end,
            SetValue = SetValue
        })
        
        return {
            Instance = ColorpickerFrame,
            SetValue = SetValue,
            GetValue = function() return currentColor end
        }
    end
    
    return TabElements
end

if config.ConfigSave ~= false then
    local SettingsTab = LinuxLib.Tab({
        Name = "Settings",
        Icon = "rbxassetid://10734950309",
        Enabled = true
    })
    
    SettingsTab.Section({Name = "Configuration"})
    
    local configNameInput = SettingsTab.Input({
        Name = "Config Name",
        Placeholder = "Config",
        Default = Linux.CurrentConfig,
        Callback = function(text)
            Linux.CurrentConfig = text
        end
    })
    
    Linux.LoadConfigList()
    
    local configListDropdown = SettingsTab.Dropdown({
        Name = "Config List",
        Options = Linux.SavedConfigs,
        Default = Linux.SavedConfigs[1] or "--",
        Callback = function(selected)
            configNameInput.SetValue(selected)
            Linux.CurrentConfig = selected
        end
    })
    
    SettingsTab.Button({
        Name = "Create Config",
        Callback = function()
            Linux.SaveConfig(Linux.CurrentConfig)
            Linux.LoadConfigList()
            configListDropdown.SetOptions(Linux.SavedConfigs)
        end
    })
    
    SettingsTab.Button({
        Name = "Load Config",
        Callback = function()
            Linux.LoadConfig(Linux.CurrentConfig)
        end
    })
    
    SettingsTab.Button({
        Name = "Delete Config",
        Callback = function()
            Linux.DeleteConfig(Linux.CurrentConfig)
            Linux.LoadConfigList()
            configListDropdown.SetOptions(Linux.SavedConfigs)
            if #Linux.SavedConfigs > 0 then
                configNameInput.SetValue(Linux.SavedConfigs[1])
                Linux.CurrentConfig = Linux.SavedConfigs[1]
            else
                configNameInput.SetValue("")
                Linux.CurrentConfig = ""
            end
        end
    })
end

function LinuxLib.Destroy()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:match("^UI_%d+$") then
            v:Destroy()
        end
    end
end

return LinuxLib
end

return Linux
