local LoadingSystem = {}

local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CoreGui end

local UI = {}
local Active = false

local function Tween(obj, props, time)
    return TweenService:Create(
        obj,
        TweenInfo.new(time or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
end

function LoadingSystem:ShowUI(initialText)
    if Active then return end
    Active = true

    initialText = initialText or "Attempting to load.."

    local Container = Instance.new("ScreenGui")
    Container.Name = "ResolveLoader"
    Container.ResetOnSpawn = false
    Container.DisplayOrder = 999999
    ProtectGui(Container)
    Container.Parent = GetHUI()

    local Background = Instance.new("Frame")
    Background.Parent = Container
    Background.AnchorPoint = Vector2.new(0.5, 0.5)
    Background.Position = UDim2.new(0.5, 0, 0.5, 0)
    Background.Size = UDim2.new(0, 360, 0, 200)
    Background.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Background.BackgroundTransparency = 1
    Background.BorderSizePixel = 0
    Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Parent = Background
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1.15, 0, 1.2, 0)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://119131500058545"
    Shadow.ImageColor3 = Color3.fromRGB(2, 2, 2)
    Shadow.ImageTransparency = 1
    Shadow.ZIndex = 0

    local Logo = Instance.new("ImageLabel")
    Logo.Parent = Background
    Logo.AnchorPoint = Vector2.new(0.5, 0)
    Logo.Position = UDim2.new(0.5, 0, 0, 20)
    Logo.Size = UDim2.new(0, 98, 0, 98)
    Logo.BackgroundTransparency = 1
    Logo.ImageTransparency = 1
    Logo.Image = "rbxassetid://112939492797247"
    Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Background
    TextLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
    TextLabel.Size = UDim2.new(0, 320, 0, 30)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextTransparency = 1
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 18
    TextLabel.TextColor3 = Color3.fromRGB(61, 61, 61)
    TextLabel.Text = initialText

    UI = {
        Container = Container,
        Background = Background,
        Shadow = Shadow,
        Logo = Logo,
        Text = TextLabel
    }
    
    Tween(Background, {
        Size = UDim2.new(0, 400, 0, 219),
        BackgroundTransparency = 0
    }, 0.45):Play()

    Tween(Shadow, { ImageTransparency = 0.62 }, 0.45):Play()
    Tween(Logo, { ImageTransparency = 0 }, 0.45):Play()
    Tween(TextLabel, { TextTransparency = 0 }, 0.45):Play()
end

function LoadingSystem:SetText(text)
    if not Active or not UI.Text then return end

    Tween(UI.Text, { TextTransparency = 1 }, 0.2):Play()
    task.wait(0.2)

    if not Active then return end
    UI.Text.Text = text

    Tween(UI.Text, { TextTransparency = 0 }, 0.2):Play()
end

function LoadingSystem:HideUI()
    if not Active or not UI.Container then return end
    Active = false

    Tween(UI.Background, {
        Size = UDim2.new(0, 360, 0, 200),
        BackgroundTransparency = 1
    }, 0.4):Play()

    Tween(UI.Shadow, { ImageTransparency = 1 }, 0.4):Play()
    Tween(UI.Logo, { ImageTransparency = 1 }, 0.4):Play()
    Tween(UI.Text, { TextTransparency = 1 }, 0.4):Play()

    task.wait(0.45)

    if UI.Container then
        UI.Container:Destroy()
    end

    UI = {}
end

return LoadingSystem
