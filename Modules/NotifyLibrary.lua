local TweenService, Core do
	TweenService = cloneref(game:GetService("TweenService")); 
	Core = cloneref(game:GetService("CoreGui"));
end

local protectGui = (syn and syn["protect_gui"]) or (gethui);

local New = function(Class, Properties)
	local Obj, Properties = Instance.new(Class), Properties or {}
	if Obj:IsA("GuiObject") then 
		Obj["AnchorPoint"] = Vector2.new(0.5, 0.5); 
		Obj["BorderSizePixel"] = 0 
	end;
	for I, V in pairs(Properties) do 
		if rawequal(I, "Parent") then 
			continue 
		end; 
		Obj[I] = V 
	end
	if Properties["Parent"] then 
		Obj["Parent"] = Properties["Parent"] 
	end; 
	return Obj;
end

local Tween = function(I, T, S, D, G, RT)
	local ObjTween = TweenService:Create(I, TweenInfo.new(T, Enum["EasingStyle"][S], Enum["EasingDirection"][D]), G);
	if RT then return ObjTween
	else 
		coroutine.wrap(function()
			ObjTween:Play()
		end)()
	end
end

if Core:FindFirstChild("Notifications") then 
	Core:FindFirstChild("Notifications"):Destroy() 
end;

local UI = New("ScreenGui", {
	["IgnoreGuiInset"] = true; 
	["Name"] = "Notifications"; 
	["ResetOnSpawn"] = false; 
	["ZIndexBehavior"] = "Global"
}); 

protectGui(UI); 
UI["Parent"] = Core;

local NotificationHolder = New("Frame", {
	Parent = UI, 
	BackgroundTransparency = 1, 
	Position = UDim2.new(0.924, 0, 0.5, 0), 
	Size = UDim2.new(0.151, 0, 1, 0)
}); 

New("UIListLayout", {
	Parent = NotificationHolder, 
	Padding = UDim.new(0, 15), 
	HorizontalAlignment = "Center", 
	VerticalAlignment = "Bottom"
});

New("UIPadding", {
	Parent = NotificationHolder, 
	PaddingBottom = UDim.new(0, 20), 
	PaddingTop = UDim.new(0, 20)
});

local NotifyLib = {};

function NotifyLib:TextConstraint(Item)
	New("UITextSizeConstraint", {
		Parent = Item, 
		MaxTextSize = Item["TextSize"]
	}); 
	Item["TextScaled"] = true
end

function NotifyLib:Notify(Title, Message, Type, Duration)
	local Type2Color = {
		['error'] = Color3.fromRGB(255, 87, 87), 
		['warn'] = Color3.fromRGB(255, 255, 127), 
		['success'] = Color3.fromRGB(85, 255, 127), 
		['normal'] = Color3.fromRGB(255, 255, 255)
	};

	local Frame = New("Frame", {
		Name = "MainFrame", 
		Parent = NotificationHolder, 
		BackgroundColor3 = Color3.fromRGB(28, 28, 29),
		Size = UDim2.new(0.9, 0, 0.097, 0), 
		ZIndex = 2, 
		BackgroundTransparency = 1
	});

	local DropShadow = New("ImageLabel", {
		Parent = Frame, 
		BackgroundTransparency = 1, 
		Position = UDim2.new(0.5, 0, 0.512, 0), 
		Size = UDim2.new(1.053, 0, 1.135, 0), 
		Image = "rbxassetid://7912134082",
		ImageColor3 = Type2Color[Type:lower()], 
		ImageTransparency = 1, 
		ScaleType = "Slice",
		SliceCenter = Rect.new(95, 95, 205, 205)
	});

	New("UICorner", {
		Parent = Frame, 
		CornerRadius = UDim.new(0, 5)
	}); 

	New("UICorner", {
		Parent = DropShadow, 
		CornerRadius = UDim.new(0, 5)
	});

	local Header = New("TextLabel", {
		Parent = Frame, 
		BackgroundTransparency = 1, 
		Position = UDim2.new(0.237, 0, 0.172, 0),
		Size = UDim2.new(0.4, 0, 0.358, 0), 
		ZIndex = 2, 
		Font = "GothamMedium",
		Text = Title or " ", 
		TextSize = 14, 
		TextXAlignment = "Left", 
		TextScaled = true, 
		TextColor3 = Color3.new(1, 1, 1)
	}); 

	NotifyLib:TextConstraint(Header);

	local Msg = New("TextLabel", {
		Parent = Frame, 
		BackgroundTransparency = 1, 
		Position = UDim2.new(0.5, 0, 0.563, 0), 
		Size = UDim2.new(0.927, 0, 0.5, 0), 
		ZIndex = 2, Font = "Gotham",
		Text = Message, 
		TextSize = 12, 
		TextXAlignment = "Left", 
		TextScaled = true, 
		TextColor3 = Color3.new(1, 1, 1)
	}); 

	NotifyLib:TextConstraint(Msg);

	local LineHolder = New("Frame", {
		Parent = Frame, 
		BackgroundTransparency = 1, 
		Position = UDim2.new(0.5, 0, 0.93, 0), 
		Size = UDim2.new(0.9278, 0, 0, 1), 
		ZIndex = 2
	});

	New("UIListLayout", {
		Parent = LineHolder,
		HorizontalAlignment = "Left", 
		VerticalAlignment = "Center"
	});

	local Line = New("Frame", {
		Name = "Line", Parent = LineHolder, 
		BackgroundColor3 = Type2Color[Type:lower()], 
		Size = UDim2.new(0, 0, 2, 0), 
		ZIndex = 2
	});

	local Hover = New("TextButton", {
		Parent = Frame, 
		BackgroundTransparency = 1, 
		Text = "", 
		Size = UDim2.new(1, 0, 1, 0), 
		Position = UDim2.new(0.5, 0, 0.5, 0), 
		ZIndex = 3
	});

	coroutine.wrap(function()
		Tween(Frame, 0.25, "Quad", "In", {BackgroundTransparency = 0});
		Tween(DropShadow, 0.25, "Quad", "In", {ImageTransparency = 0.5}); wait(0.5);
		Tween(Header, 0.5, "Quad", "Out", {TextTransparency = 0}); wait(0.25);
		Tween(Msg, 0.5, "Quad", "Out", {TextTransparency = 0}); wait(0.25);

		local MainTween = Tween(Line, Duration, "Sine", "InOut", {Size = UDim2.new(1, 0, 2, 0)}, "true"); MainTween:Play();
		Hover["MouseEnter"]:Connect(function()
			if MainTween["PlaybackState"] == Enum["PlaybackState"]["Playing"] then
				MainTween:Pause()
			end
		end)

		Hover["MouseLeave"]:Connect(function()
			if MainTween["PlaybackState"] == Enum["PlaybackState"]["Paused"] then
				MainTween:Play()
			end
		end)

		repeat wait() until MainTween["PlaybackState"] == Enum["PlaybackState"]["Completed"]

		Tween(Line, 0.25, "Quad", "Out", {Size = UDim2.new(0, 0, 2, 0)});
		Tween(Msg, 0.25, "Quad", "Out", {TextTransparency = 1}); 
		Tween(Header, 0.25, "Quint", "Out", {TextTransparency = 1}); wait(0.4);
		Tween(DropShadow, 0.25, "Quint", "Out", {ImageTransparency = 1});
		Tween(Frame, 0.25, "Quint", "Out", {BackgroundTransparency = 1}); wait(0.25); Frame:Destroy();
	end)()
end

return NotifyLib
