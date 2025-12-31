local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/AccountBurner/Utility/refs/heads/main/Maid.lua"))();
local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/AccountBurner/Utility/refs/heads/main/Signal"))();

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local ProtectGui, GetHUI = protectgui or (syn and syn.protect_gui) or function() end,
    gethui or function() return CoreGui end;

local ActiveNotifications = {};
local NotificationSystem = {};
local Notification = {};
NotificationSystem.__index = NotificationSystem;
Notification.__index = Notification;

local Theme, Icons, Container;

do
    Theme = {
        Background = Color3.fromRGB(23, 23, 23),
        BackgroundSecondary = Color3.fromRGB(15, 15, 15),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(203, 203, 212),
        Border = Color3.fromRGB(15, 15, 15),

        Info = Color3.fromRGB(224, 0, 17),
        Success = Color3.fromRGB(85, 255, 127),
        Warning = Color3.fromRGB(255, 255, 127),
        Error = Color3.fromRGB(255, 87, 87)
    };

    Icons = {
        Info = "R",
        Success = "✓",
        Warning = "!",
        Error = "X"
    };
end;

do
    local chars = {};
    for i = 1, math.random(14, 22) do
        chars[i] = string.char(math.random(97, 122));
    end;

    Container = Instance.new("ScreenGui");
    Container.Name = table.concat(chars);
    Container.ResetOnSpawn = false;
    Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    Container.DisplayOrder = 999999;
    ProtectGui(Container);
    Container.Parent = GetHUI();
end;

do
    local Padding = {
        Frame = 16,
        Icon = 14,
        IconGap = 12,
        TitleTop = 25,
        MessageGap = 4,
        Right = 16,
        Bottom = 25
    };

    function Notification.new(options)
        local self = setmetatable({
            Type = options.Type or "Info",
            Title = options.Title or "Notification",
            Text = options.Text or "",
            Duration = options.Duration or 5,
            Callback = options.Callback,
            Destroying = Signal.new(),
            _maid = Maid.new(),
            _destroyed = false
        }, Notification);

        self:_build();
        return self;
    end;

    function Notification:_calculateSize()
        local viewport = workspace.CurrentCamera.ViewportSize;
        local screenW = viewport.X;

        local scale = math.clamp(screenW / 1920, 0.75, 1);
        local width = math.floor(380 * scale);
        local iconSize = math.floor(36 * scale);

        local contentX = Padding.Frame + iconSize + Padding.IconGap;
        local contentWidth = width - contentX - Padding.Right;

        local titleSize = math.floor(15 * scale);
        local messageSize = math.floor(13 * scale);

        local titleBounds = TextService:GetTextSize(self.Title, titleSize, Enum.Font.GothamBold,
            Vector2.new(contentWidth - 30, 50));
        local messageBounds = TextService:GetTextSize(self.Text, messageSize, Enum.Font.Gotham,
            Vector2.new(contentWidth, 500));

        local height = Padding.TitleTop + titleBounds.Y + Padding.MessageGap + messageBounds.Y + Padding.Bottom + 3;
        height = math.clamp(math.floor(height), math.floor(70 * scale), math.floor(180 * scale));

        return width, height, scale, iconSize, contentX, titleSize, messageSize, titleBounds.Y;
    end;

    function Notification:_build()
        local color = Theme[self.Type] or Theme.Info;
        local width, height, scale, iconSize, contentX, titleSize, messageSize, titleHeight = self:_calculateSize();

        self.Frame = Instance.new("Frame");
        self.Frame.Size = UDim2.fromOffset(width, height);
        self.Frame.Position = UDim2.new(0, 20, 1, height + 30);
        self.Frame.BackgroundColor3 = Theme.Background;
        self.Frame.BorderSizePixel = 0;
        self.Frame.AnchorPoint = Vector2.new(0, 1);
        self.Frame.ClipsDescendants = true;
        self.Frame.Parent = Container;

        local corner = Instance.new("UICorner");
        corner.CornerRadius = UDim.new(0, 4);
        corner.Parent = self.Frame;

        local stroke = Instance.new("UIStroke");
        stroke.Color = color;
        stroke.Thickness = 1.4;
        stroke.Transparency = 0;
        stroke.Parent = self.Frame;

        local strokeGradient = Instance.new("UIGradient");
        strokeGradient.Rotation = -90;
        strokeGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(0.5,
            color), ColorSequenceKeypoint.new(1, Color3.fromRGB(23, 23, 23)) })
        strokeGradient.Parent = stroke;

        local iconContainer = Instance.new("Frame");
        iconContainer.Size = UDim2.fromOffset(iconSize, iconSize);
        iconContainer.Position = UDim2.new(0, Padding.Frame, 0.5, 0);
        iconContainer.AnchorPoint = Vector2.new(0, 0.5);
        iconContainer.BackgroundColor3 = color;
        iconContainer.BackgroundTransparency = 0.88;
        iconContainer.BorderSizePixel = 0;
        iconContainer.Parent = self.Frame;

        local iconContainerCorner = Instance.new("UICorner");
        iconContainerCorner.CornerRadius = UDim.new(0.5, 0);
        iconContainerCorner.Parent = iconContainer;

        local iconStroke = Instance.new("UIStroke");
        iconStroke.Color = color;
        iconStroke.Thickness = 1;
        iconStroke.Transparency = 0.7;
        iconStroke.Parent = iconContainer;

        local icon = Instance.new("TextLabel");
        icon.Size = UDim2.fromScale(1, 1);
        icon.BackgroundTransparency = 1;
        icon.Text = Icons[self.Type] or Icons.Info;
        icon.Font = Enum.Font.GothamBold;
        icon.TextSize = math.floor(14 * scale);
        icon.TextColor3 = color;
        icon.Parent = iconContainer;

        local title = Instance.new("TextLabel");
        title.Size = UDim2.new(1, -contentX - Padding.Right - 25, 0, titleHeight);
        title.Position = UDim2.new(0, contentX, 0, Padding.TitleTop);
        title.BackgroundTransparency = 1;
        title.Text = self.Title;
        title.Font = Enum.Font.GothamBold;
        title.TextSize = titleSize;
        title.TextColor3 = Theme.Text;
        title.TextXAlignment = Enum.TextXAlignment.Left;
        title.TextYAlignment = Enum.TextYAlignment.Top;
        title.TextTruncate = Enum.TextTruncate.AtEnd;
        title.Parent = self.Frame;

        local messageY = Padding.TitleTop + titleHeight + Padding.MessageGap;
        local messageHeight = height - messageY - Padding.Bottom - 3;

        local message = Instance.new("TextLabel");
        message.Size = UDim2.new(1, -contentX - Padding.Right, 0, messageHeight);
        message.Position = UDim2.new(0, contentX, 0, messageY);
        message.BackgroundTransparency = 1;
        message.Text = self.Text;
        message.Font = Enum.Font.Gotham;
        message.TextSize = messageSize;
        message.TextColor3 = Theme.SubText;
        message.TextXAlignment = Enum.TextXAlignment.Left;
        message.TextYAlignment = Enum.TextYAlignment.Top;
        message.TextWrapped = true;
        message.Parent = self.Frame;

        local progressBg = Instance.new("Frame");
        progressBg.Size = UDim2.new(1, 0, 0, 3);
        progressBg.Position = UDim2.new(0, 0, 1, -3);
        progressBg.BackgroundColor3 = Theme.BackgroundSecondary;
        progressBg.BorderSizePixel = 0;
        progressBg.Parent = self.Frame;

        local progress = Instance.new("Frame");
        progress.Size = UDim2.fromScale(1, 1);
        progress.BackgroundColor3 = color;
        progress.BorderSizePixel = 0;
        progress.Parent = progressBg;

        local progressCorner = Instance.new("UICorner");
        progressCorner.CornerRadius = UDim.new(0, 2);
        progressCorner.Parent = progress;

        if self.Callback then
            local clickArea = Instance.new("TextButton");
            clickArea.Size = UDim2.new(1, -30, 1, -3);
            clickArea.BackgroundTransparency = 1;
            clickArea.Text = "";
            clickArea.ZIndex = 0;
            clickArea.Parent = self.Frame;
            self._maid:AddTask(clickArea.MouseButton1Click:Connect(function()
                self.Callback(); self:Destroy()
            end));
        end;

        table.insert(ActiveNotifications, self);
        self:_updatePositions();

        TweenService:Create(self.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 20, 1, -20)
        }):Play();

        local progressTween = TweenService:Create(progress, TweenInfo.new(self.Duration, Enum.EasingStyle.Linear), {
            Size = UDim2.fromScale(0, 1)
        });
        progressTween:Play();

        self._maid:AddTask(progressTween.Completed:Connect(function()
            if not self._destroyed then self:Destroy() end;
        end));
    end;

    function Notification:_updatePositions()
        local totalHeight = 20;

        for i = #ActiveNotifications, 1, -1 do
            local notif = ActiveNotifications[i];
            if notif._destroyed then continue end;

            local _, height = notif:_calculateSize();

            TweenService:Create(notif.Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 20, 1, -totalHeight)
            }):Play();

            totalHeight = totalHeight + height + 8;
        end;
    end;

    function Notification:Destroy()
        if self._destroyed then return end;
        self._destroyed = true;
        self.Destroying:Fire();

        local idx = table.find(ActiveNotifications, self);
        if idx then table.remove(ActiveNotifications, idx) end;

        local tween = TweenService:Create(self.Frame,
            TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 20, 1, self.Frame.AbsoluteSize.Y + 40),
                BackgroundTransparency = 1
            });

        for _, child in self.Frame:GetDescendants() do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.25), { TextTransparency = 1 }):Play();
            elseif child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play();
            elseif child:IsA("UIStroke") then
                TweenService:Create(child, TweenInfo.new(0.25), { Transparency = 1 }):Play();
            end;
        end;

        tween:Play();

        if #ActiveNotifications > 0 then
            task.delay(0.05, function()
                if #ActiveNotifications > 0 then
                    ActiveNotifications[#ActiveNotifications]:_updatePositions();
                end;
            end);
        end;

        self._maid:AddTask(tween.Completed:Connect(function()
            self.Frame:Destroy();
            self._maid:Clean();
        end));
    end;
end;

do -- system
    function NotificationSystem.new()
        return setmetatable({ _maid = Maid.new() }, NotificationSystem);
    end;

    function NotificationSystem:Create(options)
        return Notification.new(options);
    end;

    function NotificationSystem:Notify(title, message, notificationType, duration, callback)
        return self:Create({
            Title = title,
            Text = message,
            Type = notificationType or "Info",
            Duration = duration,
            Callback =
                callback
        });
    end;

    function NotificationSystem:Info(title, message, duration, callback)
        return self:Notify(title, message, "Info", duration, callback);
    end;

    function NotificationSystem:Success(title, message, duration, callback)
        return self:Notify(title, message, "Success", duration, callback);
    end;

    function NotificationSystem:Warning(title, message, duration, callback)
        return self:Notify(title, message, "Warning", duration, callback);
    end;

    function NotificationSystem:Error(title, message, duration, callback)
        return self:Notify(title, message, "Error", duration, callback);
    end;

    function NotificationSystem:ClearAll()
        for _, notif in ActiveNotifications do notif:Destroy() end;
    end;

    function NotificationSystem:Destroy()
        self:ClearAll();
        self._maid:Clean();
    end;
end;

return NotificationSystem.new();
