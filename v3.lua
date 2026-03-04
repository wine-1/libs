--[[
	User Interface Library - main2.lua (overlap fix)
	Made by Laeee
	UPDATE: Title in content area - NO overlap with window controls
]]
---@diagnostic disable: undefined-global, need-check-nil, deprecated, inject-field, undefined-field

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = function(obj)
	if obj and obj.Clone then
		return obj:Clone()
	end
	return nil
end

local Destroy = function(obj)
	if obj and obj.Destroy then
		obj:Destroy()
	end
end 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// (Dark Theme)
	--// Frames:
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),

	--// Text:
	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240,240,240),
	Description = Color3.fromRGB(200,200,200),

	--// Outlines:
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),

	--// Image:
	Icon = Color3.fromRGB(220, 220, 220),
}

--// Services & Functions
local Type, Blur = nil, nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object, Speed, Properties, Info)
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object, Properties)
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

--// HSV to RGB for rainbow effect
local function HSVtoRGB(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	else r, g, b = v, p, q
	end
	return Color3.new(r, g, b)
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end,

			On.Value == Value)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end)
end
end
Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
else
	Screen = (script.Parent);
	Blur = require(script.Blur)
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Animations [Window]
function Animations:Open(Window, Transparency, UseCurrentSize)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	if Shadow then
		SetProperty(Shadow, { Transparency = 1 })
		Tween(Shadow, .32, { Transparency = 0.5 })
	end
	
	Tween(Window, .32, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Original,
	})

	if Shadow then
		Tween(Shadow, .28, { Transparency = 1 })
	end
	
	Tween(Window, .28, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	task.wait(.28)
	Window.Size = Original
	Window.Visible = false
end


function Animations:Component(Component, Custom)	
	-- Hover effect (mouse enter/leave) - normal vs highlighted
	if Component.MouseEnter and Component.MouseLeave then
		Connect(Component.MouseEnter, function()
			if Custom then
				Tween(Component, .15, { Transparency = .85 });
			else
				Tween(Component, .15, { BackgroundColor3 = Color(Theme.Component, 8, Setup.ThemeMode) });
			end
		end)
		Connect(Component.MouseLeave, function()
			if Custom then
				Tween(Component, .15, { Transparency = 1 });
			else
				Tween(Component, .15, { BackgroundColor3 = Theme.Component });
			end
		end)
	end
	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .2, { Transparency = .85 });
		else
			Tween(Component, .2, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .2, { Transparency = 1 });
		else
			Tween(Component, .2, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]

function Library:CreateWindow(Settings)
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false;
	local MainTabName = nil; -- First tab = main page (shows title)
	local CurrentTabName = nil;

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end
	
	--// Enhanced Window Title Bar with Subtitle and Small Title
	local TitleContainer = nil
	local TitleLabel = nil
	local SubtitleLabel = nil
	local SmallTitleBadge = nil
	
	if Settings.Title then
		-- FIX: Put title in Holder (content area) so it NEVER overlaps window controls
		-- Window controls stay in Sidebar.Top.Buttons; title goes in Holder
		do
			-- Ensure Holder has vertical layout for title + content
			local HolderLayout = Holder:FindFirstChildOfClass("UIListLayout")
			if not HolderLayout then
				HolderLayout = Instance.new("UIListLayout")
				HolderLayout.FillDirection = Enum.FillDirection.Vertical
				HolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				HolderLayout.VerticalAlignment = Enum.VerticalAlignment.Top
				HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
				HolderLayout.Padding = UDim.new(0, 0)
				HolderLayout.Parent = Holder
			end
			-- Content container (MainExample.Parent) must be below title
			local MainExample = Examples["MainExample"]
			if MainExample and MainExample.Parent then
				MainExample.Parent.LayoutOrder = 1
			end
		end

		-- Create title container in Holder (content area - right side, no overlap)
		TitleContainer = Instance.new("Frame")
		local TitleLayout = Instance.new("UIListLayout")
		local TitlePadding = Instance.new("UIPadding")
		
		SetProperty(TitleContainer, {
			Name = "TitleContainer",
			Parent = Holder,
			Size = UDim2.new(1, -24, 0, Settings.Subtitle and 48 or 36),
			ClipsDescendants = false,
			LayoutOrder = 0,
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			ZIndex = 50,
			Visible = true,
		})
		
		SetProperty(TitleLayout, {
			Parent = TitleContainer,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		})
		
		SetProperty(TitlePadding, {
			Parent = TitleContainer,
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 4),
		})
			
			-- Small Title Badge (beside main title)
			if Settings.SmallTitle then
				SmallTitleBadge = Instance.new("TextLabel")
				local BadgeCorner = Instance.new("UICorner")
				local BadgeStroke = Instance.new("UIStroke")
				
				SetProperty(SmallTitleBadge, {
					Name = "SmallTitle",
					Parent = TitleContainer,
					Size = UDim2.new(0, 0, 0, 18),
					AutomaticSize = Enum.AutomaticSize.X,
					AnchorPoint = Vector2.new(0, 0), -- Ensure left alignment
					BackgroundColor3 = Color3.fromRGB(100, 150, 255),
					BackgroundTransparency = 0.2,
					Text = Settings.SmallTitle,
					TextColor3 = Color3.fromRGB(200, 220, 255),
					TextSize = 11,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					LayoutOrder = 1,
					ZIndex = 11,
				})
				
				SetProperty(BadgeCorner, {
					Parent = SmallTitleBadge,
					CornerRadius = UDim.new(0, 4),
				})
				
				SetProperty(BadgeStroke, {
					Parent = SmallTitleBadge,
					Color = Color3.fromRGB(120, 170, 255),
					Thickness = 1,
					Transparency = 0.5,
				})
				
				-- Add padding to badge text
				local BadgeTextPadding = Instance.new("UIPadding")
				SetProperty(BadgeTextPadding, {
					Parent = SmallTitleBadge,
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				})
			end
			
			-- Main Title Label (better font)
			TitleLabel = Instance.new("TextLabel")
			SetProperty(TitleLabel, {
				Name = "Title",
				Parent = Settings.Subtitle and nil or TitleContainer, -- Will be parented to VerticalContainer if subtitle exists
				Size = UDim2.new(0, 0, 0, Settings.Subtitle and 20 or 22),
				AutomaticSize = Enum.AutomaticSize.X,
				AnchorPoint = Vector2.new(0, 0), -- Ensure left alignment
				BackgroundTransparency = 1,
				Text = Settings.Title,
				TextColor3 = Theme.Title or Color3.fromRGB(240, 240, 240),
				TextSize = Settings.Subtitle and 18 or 20,
				Font = Enum.Font.SourceSansBold, -- Better font
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				LayoutOrder = Settings.Subtitle and 1 or 2,
				ZIndex = 11,
			})
			
			if not Settings.Subtitle then
				TitleLabel.Parent = TitleContainer
			end
			
			-- Subtitle Label (below main title)
			if Settings.Subtitle then
				-- Create vertical container for title and subtitle
				local VerticalContainer = Instance.new("Frame")
				local VerticalLayout = Instance.new("UIListLayout")
				
				SetProperty(VerticalContainer, {
					Name = "VerticalContainer",
					Parent = TitleContainer,
					Size = UDim2.new(0, 0, 0, 35),
					AutomaticSize = Enum.AutomaticSize.X,
					AnchorPoint = Vector2.new(0, 0), -- Ensure left alignment
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					ZIndex = 11,
				})
				
				SetProperty(VerticalLayout, {
					Parent = VerticalContainer,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
				})
				
				-- Move title into vertical container
				TitleLabel.Parent = VerticalContainer
				TitleLabel.LayoutOrder = 1
				TitleLabel.Size = UDim2.new(0, 0, 0, 18)
				TitleLabel.AutomaticSize = Enum.AutomaticSize.X
				TitleLabel.AnchorPoint = Vector2.new(0, 0) -- Ensure left alignment
				
				-- Create subtitle
				SubtitleLabel = Instance.new("TextLabel")
				SetProperty(SubtitleLabel, {
					Name = "Subtitle",
					Parent = VerticalContainer,
					Size = UDim2.new(0, 0, 0, 14),
					AutomaticSize = Enum.AutomaticSize.X,
					AnchorPoint = Vector2.new(0, 0), -- Ensure left alignment
					BackgroundTransparency = 1,
					Text = Settings.Subtitle,
					TextColor3 = Theme.Description or Color3.fromRGB(180, 180, 180),
					TextSize = 12,
					Font = Enum.Font.Gotham, -- Elegant font for subtitle
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextTransparency = 0.2,
					LayoutOrder = 2,
					ZIndex = 11,
				})
			end
			
		-- Store references for later updates
		Options._TitleLabel = TitleLabel
		Options._SubtitleLabel = SubtitleLabel
		Options._SmallTitleBadge = SmallTitleBadge
		Options._TitleContainer = TitleContainer
	end
	
	-- Helper: show title only on main tab
	local function UpdateTitleVisibility(tabName)
		if Options._TitleContainer and Options._TitleContainer.Parent then
			Options._TitleContainer.Visible = (MainTabName and tabName == MainTabName)
		end
	end
	
	--// Rainbow effect for title, subtitle, small title
	local RainbowConn = nil
	local function StartRainbow()
		if RainbowConn then return end
		RainbowConn = Services.Run.Heartbeat:Connect(function()
			local t = tick() * 0.5
			local hue = (t % 1)
			local c = HSVtoRGB(hue, 0.85, 1)
			if Options._TitleLabel and Options._TitleLabel.Parent and Settings.RainbowTitle then
				Options._TitleLabel.TextColor3 = c
			end
			if Options._SubtitleLabel and Options._SubtitleLabel.Parent and Settings.RainbowSubtitle then
				Options._SubtitleLabel.TextColor3 = c
			end
			if Options._SmallTitleBadge and Options._SmallTitleBadge.Parent and Settings.RainbowSmallTitle then
				Options._SmallTitleBadge.TextColor3 = c
			end
		end)
	end
	local function StopRainbow()
		if RainbowConn then
			RainbowConn:Disconnect()
			RainbowConn = nil
		end
		if Options._TitleLabel and not Settings.RainbowTitle then
			Options._TitleLabel.TextColor3 = Theme.Title or Color3.fromRGB(240, 240, 240)
		end
		if Options._SubtitleLabel and not Settings.RainbowSubtitle then
			Options._SubtitleLabel.TextColor3 = Theme.Description or Color3.fromRGB(180, 180, 180)
		end
		if Options._SmallTitleBadge and not Settings.RainbowSmallTitle then
			Options._SmallTitleBadge.TextColor3 = Color3.fromRGB(200, 220, 255)
		end
	end
	if Settings.RainbowTitle or Settings.RainbowSubtitle or Settings.RainbowSmallTitle then
		StartRainbow()
	end
	
	function Options:SetRainbow(Which, Enabled)
		if Which == "Title" then Settings.RainbowTitle = Enabled
		elseif Which == "Subtitle" then Settings.RainbowSubtitle = Enabled
		elseif Which == "SmallTitle" then Settings.RainbowSmallTitle = Enabled
		end
		if Settings.RainbowTitle or Settings.RainbowSubtitle or Settings.RainbowSmallTitle then
			StartRainbow()
		else
			StopRainbow()
		end
	end

	--// Sidebar spacing - fix clipping at top
	local TopBar = Sidebar:FindFirstChild("Top")
	local TopButtons = TopBar and TopBar:FindFirstChild("Buttons")
	
	-- Ensure TopBar has enough height and padding (fix clipping)
	if TopBar then
		local TopBarPadding = TopBar:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
		SetProperty(TopBarPadding, {
			Parent = TopBar,
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 8),
		})
		-- Force minimum height for title bar
		local minTopHeight = 52
		if TopBar.Size.Y.Scale == 0 and TopBar.Size.Y.Offset < minTopHeight then
			TopBar.Size = UDim2.new(TopBar.Size.X.Scale, TopBar.Size.X.Offset, 0, minTopHeight)
		end
	end
	
	-- Add top padding to Holder so content doesn't overlap title bar
	do
		local hp = Holder:FindFirstChildOfClass("UIPadding")
		if hp then
			hp.PaddingTop = UDim.new(0, math.max(hp.PaddingTop.Offset, 12))
		else
			hp = Instance.new("UIPadding")
			hp.Parent = Holder
			hp.PaddingTop = UDim.new(0, 12)
			hp.PaddingBottom = UDim.new(0, 8)
			hp.PaddingLeft = UDim.new(0, 8)
			hp.PaddingRight = UDim.new(0, 8)
		end
	end
	
	-- Add padding to ScrollingFrames so section content doesn't overlap
	for _, child in next, Holder:GetDescendants() do
		if child:IsA("ScrollingFrame") then
			local pad = child:FindFirstChildOfClass("UIPadding")
			if not pad then
				pad = Instance.new("UIPadding")
				pad.Parent = child
			end
			pad.PaddingTop = UDim.new(0, math.max(pad.PaddingTop.Offset, 16))
			pad.PaddingBottom = UDim.new(0, math.max(pad.PaddingBottom.Offset, 12))
			pad.PaddingLeft = UDim.new(0, math.max(pad.PaddingLeft.Offset, 12))
			pad.PaddingRight = UDim.new(0, math.max(pad.PaddingRight.Offset, 12))
		end
	end
	
	-- Tab padding - extra top space so Main/Settings sections aren't clipped
	local TabPadding = Tab:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	SetProperty(TabPadding, {
		Parent = Tab,
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 12),
	})
	
	if TopButtons then
		local ButtonsPadding = TopButtons:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
		SetProperty(ButtonsPadding, {
			Parent = TopButtons,
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		})
	end

	--// Responsive Sizing for PC/Mobile
	local function GetResponsiveSize()
		local IsMobile = Services.Input.TouchEnabled and not Services.Input.KeyboardEnabled
		
		if IsMobile then
			-- Mobile: Use larger percentage of screen
			return UDim2.new(0.9, 0, 0.85, 0)
		else
			-- PC: Use fixed larger size or scale based on viewport
			if Settings.Size then
				-- Multiply the provided size by 1.3 for bigger UI
				local BaseSize = Settings.Size
				return UDim2.new(
					BaseSize.X.Scale,
					math.floor(BaseSize.X.Offset * 1.3),
					BaseSize.Y.Scale,
					math.floor(BaseSize.Y.Offset * 1.3)
				)
			else
				-- Default larger size for PC
				return UDim2.fromOffset(750, 500)
			end
		end
	end
	
	local ResponsiveSize = GetResponsiveSize()

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = ResponsiveSize
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// Floating Toggle Button
	local FloatingButton = Instance.new("TextButton")
	local ButtonStroke = Instance.new("UIStroke")
	local ButtonCorner = Instance.new("UICorner")
	local ButtonIcon = Instance.new("ImageLabel")
	
	-- Store references in Options for SetTheme access and cleanup
	Options._FloatingButton = FloatingButton
	Options._ButtonStroke = ButtonStroke
	Options._ButtonIcon = ButtonIcon
	
	-- Function to change floating button image (accepts rbxassetid:// format)
	function Options:SetFloatingButtonImage(ImageId)
		if Options._ButtonIcon then
			-- Support both rbxassetid:// format and direct asset IDs
			if ImageId:match("^rbxassetid://") then
				Options._ButtonIcon.Image = ImageId
			elseif tonumber(ImageId) then
				Options._ButtonIcon.Image = "rbxassetid://" .. ImageId
			else
				Options._ButtonIcon.Image = ImageId
			end
		end
	end
	
	SetProperty(FloatingButton, {
		Name = "FloatingToggle",
		Parent = Screen,
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -70, 1, -70),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Primary,
		Text = "",
		Visible = true,
		ZIndex = 100,
		Active = true,
		Draggable = false,
	})
	
	SetProperty(ButtonStroke, {
		Parent = FloatingButton,
		Color = Theme.Outline,
		Thickness = 2,
		Transparency = 0,
	})
	
	SetProperty(ButtonCorner, {
		Parent = FloatingButton,
		CornerRadius = UDim.new(0, 12),
	})
	
	SetProperty(ButtonIcon, {
		Parent = FloatingButton,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://11963373994", -- Default icon, can be changed
		ImageColor3 = Theme.Icon,
	})
	
	Animations:Component(FloatingButton)
	
	--// Make floating button draggable
	Drag(FloatingButton)
	
	--// Animate
	local Close = function()
		if Opened then
			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = nil
			end

			Opened = false
			Animations:Close(Window)
			Window.Visible = false
			-- Update button icon when closed
			if ButtonIcon then
				ButtonIcon.Image = "rbxassetid://11293977610" -- Show icon
			end
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true

			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
			end
			-- Update button icon when opened
			if ButtonIcon then
				ButtonIcon.Image = "rbxassetid://11963373994" -- Hide icon
			end
		end
	end
	
	--// Function to destroy floating button
	local DestroyFloatingButton = function()
		if Options._FloatingButton and Options._FloatingButton.Parent then
			Options._FloatingButton:Destroy()
			Options._FloatingButton = nil
			Options._ButtonStroke = nil
			Options._ButtonIcon = nil
		end
	end
	
	--// Connect floating button to toggle
	Connect(FloatingButton.MouseButton1Click, function()
		Close()
	end)
	
	--// Cleanup: Destroy floating button when window is destroyed
	Window.AncestryChanged:Connect(function()
		if not Window.Parent then
			DestroyFloatingButton()
		end
	end)

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)
			
			-- Make buttons bigger
			local OriginalSize = Button.Size
			Button.Size = UDim2.new(OriginalSize.X.Scale, OriginalSize.X.Offset * 1.5, OriginalSize.Y.Scale, OriginalSize.Y.Offset * 1.5)

			Connect(Button.MouseButton1Click, function() 
				if Name == "Close" then
					-- Destroy floating button when UI is destroyed
					if Options._FloatingButton and Options._FloatingButton.Parent then
						Options._FloatingButton:Destroy()
					end
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					if BlurEnabled and Blurs[Settings.Title] then
						Blurs[Settings.Title].root.Parent = nil
					end
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	--// Tab Functions

	function Options:SetTab(Name)
		CurrentTabName = Name;
		-- Show title only on main tab, hide on others
		UpdateTitleVisibility(Name);
		
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") and Button:FindFirstChild("Value") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings)
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings)
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end
		
		-- Count tabs before adding this one to check if it's the first
		local TabCount = 0
		for _ in pairs(StoredInfo["Tabs"]) do
			TabCount = TabCount + 1
		end
		local IsFirstTab = TabCount == 0

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title,
			LayoutOrder = 1,
		});

		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)
		
		-- First tab = main page (shows title when selected)
		if IsFirstTab then
			MainTabName = Settings.Title;
			task.spawn(function()
				task.wait(0.1) -- Small delay to ensure everything is set up
				Options:SetTab(Settings.Title)
			end)
		end

		return Main.ScrollingFrame
	end
	
	-- Set which tab is the "main" page (shows title). Default = first tab.
	function Options:SetMainTab(TabName)
		MainTabName = TabName;
		if CurrentTabName then
			UpdateTitleVisibility(CurrentTabName);
		end
	end
	
	--// Notifications
	
	function Options:Notify(Settings) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end
	
	--// Dialog Function
	function Options:Dialog(Settings)
		local Dialog = Instance.new("CanvasGroup")
		local DialogFrame = Instance.new("Frame")
		local DialogStroke = Instance.new("UIStroke")
		local DialogCorner = Instance.new("UICorner")
		local DialogTitle = Instance.new("TextLabel")
		local DialogDescription = Instance.new("TextLabel")
		local DialogButtons = Instance.new("Frame")
		local DialogLayout = Instance.new("UIListLayout")
		local DialogPadding = Instance.new("UIPadding")
		
		-- Create dialog structure
		SetProperty(Dialog, {
			Name = "Dialog",
			Parent = Screen,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Visible = true,
			ZIndex = 200,
		})
		
		-- Background overlay
		local Overlay = Instance.new("Frame")
		SetProperty(Overlay, {
			Name = "Overlay",
			Parent = Dialog,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			ZIndex = 199,
		})
		
		-- Dialog frame
		SetProperty(DialogFrame, {
			Name = "Frame",
			Parent = Dialog,
			Size = UDim2.new(0, 400, 0, 200),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.Primary,
			ZIndex = 201,
		})
		
		SetProperty(DialogStroke, {
			Parent = DialogFrame,
			Color = Theme.Outline,
			Thickness = 2,
		})
		
		SetProperty(DialogCorner, {
			Parent = DialogFrame,
			CornerRadius = UDim.new(0, 8),
		})
		
		-- Title
		SetProperty(DialogTitle, {
			Name = "Title",
			Parent = DialogFrame,
			Size = UDim2.new(1, -30, 0, 40),
			Position = UDim2.new(0, 15, 0, 10),
			BackgroundTransparency = 1,
			Text = Settings.Title or "Dialog",
			TextColor3 = Theme.Title,
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 202,
		})
		
		-- Description
		SetProperty(DialogDescription, {
			Name = "Description",
			Parent = DialogFrame,
			Size = UDim2.new(1, -30, 0, 80),
			Position = UDim2.new(0, 15, 0, 50),
			BackgroundTransparency = 1,
			Text = Settings.Description or "",
			TextColor3 = Theme.Description,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			ZIndex = 202,
		})
		
		-- Buttons container
		SetProperty(DialogButtons, {
			Name = "Buttons",
			Parent = DialogFrame,
			Size = UDim2.new(1, -30, 0, 40),
			Position = UDim2.new(0, 15, 1, -50),
			BackgroundTransparency = 1,
			ZIndex = 202,
		})
		
		SetProperty(DialogLayout, {
			Parent = DialogButtons,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		})
		
		-- Create buttons
		local ButtonCount = 0
		for ButtonName, Callback in next, Settings.Buttons or {} do
			ButtonCount = ButtonCount + 1
			local Button = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local ButtonStroke = Instance.new("UIStroke")
			
			SetProperty(Button, {
				Name = ButtonName,
				Parent = DialogButtons,
				Size = UDim2.new(0, 100, 0, 35),
				BackgroundColor3 = Theme.Component,
				Text = ButtonName,
				TextColor3 = Theme.Title,
				TextSize = 14,
				Font = Enum.Font.Gotham,
				LayoutOrder = ButtonCount,
				ZIndex = 203,
			})
			
			SetProperty(ButtonCorner, {
				Parent = Button,
				CornerRadius = UDim.new(0, 6),
			})
			
			SetProperty(ButtonStroke, {
				Parent = Button,
				Color = Theme.Outline,
				Thickness = 1,
			})
			
			Animations:Component(Button)
			
			Connect(Button.MouseButton1Click, function()
				if Callback then
					Callback()
				end
				Animations:Close(Dialog)
				task.wait(0.3)
				Dialog:Destroy()
			end)
		end
		
		-- Adjust dialog size based on content
		local NewHeight = 50 + 80 + 50 + 10
		DialogFrame.Size = UDim2.new(0, 400, 0, NewHeight)
		
		-- Animate in
		Animations:Open(Dialog, 0, true)
		
		-- Close on overlay click (use MouseButton1Down for Frame)
		Connect(Overlay.MouseButton1Down, function()
			Animations:Close(Dialog)
			task.wait(0.3)
			Dialog:Destroy()
		end)
	end


	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				
				if not Finished and not Focused then
					Finished = (true)
					
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, "")
						})
					end
				end 
			end)
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.floor(Number + 0.5)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow
		
		-- Update window title elements if they exist
		if Options._TitleLabel then
			Options._TitleLabel.TextColor3 = Theme.Title or Color3.fromRGB(240, 240, 240)
		end
		
		if Options._SubtitleLabel then
			Options._SubtitleLabel.TextColor3 = Theme.Description or Color3.fromRGB(180, 180, 180)
		end
		
		-- Update floating button theme
		if Options._FloatingButton then
			Options._FloatingButton.BackgroundColor3 = Theme.Primary
			Options._ButtonStroke.Color = Theme.Outline
			Options._ButtonIcon.ImageColor3 = Theme.Icon
		end

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end
	
	--// Function to update title
	function Options:SetTitle(NewTitle)
		if Options._TitleLabel then
			Options._TitleLabel.Text = NewTitle
		end
	end
	
	--// Function to update subtitle
	function Options:SetSubtitle(NewSubtitle)
		if Options._SubtitleLabel then
			Options._SubtitleLabel.Text = NewSubtitle
			Options._SubtitleLabel.Visible = true
		elseif NewSubtitle and Options._TitleContainer then
			-- Create subtitle if it doesn't exist (TitleContainer is in Holder)
			local TitleContainer = Options._TitleContainer
			if TitleContainer then
				local VerticalContainer = TitleContainer:FindFirstChild("VerticalContainer")
				if VerticalContainer then
					SubtitleLabel = Instance.new("TextLabel")
					SetProperty(SubtitleLabel, {
						Name = "Subtitle",
						Parent = VerticalContainer,
						Size = UDim2.new(0, 0, 0, 14),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Text = NewSubtitle,
						TextColor3 = Theme.Description or Color3.fromRGB(180, 180, 180),
						TextSize = 12,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextTransparency = 0.2,
						LayoutOrder = 2,
						ZIndex = 11,
					})
					Options._SubtitleLabel = SubtitleLabel
				end
			end
		end
	end
	
	--// Function to update small title badge
	function Options:SetSmallTitle(NewSmallTitle)
		if Options._SmallTitleBadge then
			Options._SmallTitleBadge.Text = NewSmallTitle
			Options._SmallTitleBadge.Visible = true
		elseif NewSmallTitle and Options._TitleContainer then
			-- Create small title badge if it doesn't exist (TitleContainer is in Holder)
			local TitleContainer = Options._TitleContainer
			if TitleContainer then
				SmallTitleBadge = Instance.new("TextLabel")
				local BadgeCorner = Instance.new("UICorner")
				local BadgeStroke = Instance.new("UIStroke")
				local BadgeTextPadding = Instance.new("UIPadding")
				
				SetProperty(SmallTitleBadge, {
					Name = "SmallTitle",
					Parent = TitleContainer,
					Size = UDim2.new(0, 0, 0, 18),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(100, 150, 255),
					BackgroundTransparency = 0.2,
					Text = NewSmallTitle,
					TextColor3 = Color3.fromRGB(200, 220, 255),
					TextSize = 11,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					LayoutOrder = 1,
					ZIndex = 11,
				})
				
				SetProperty(BadgeCorner, {
					Parent = SmallTitleBadge,
					CornerRadius = UDim.new(0, 4),
				})
				
				SetProperty(BadgeStroke, {
					Parent = SmallTitleBadge,
					Color = Color3.fromRGB(120, 170, 255),
					Thickness = 1,
					Transparency = 0.5,
				})
				
				SetProperty(BadgeTextPadding, {
					Parent = SmallTitleBadge,
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				})
				
				Options._SmallTitleBadge = SmallTitleBadge
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
			
		elseif Setting == "Blur" then
			
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			
			if Value then
				BlurEnabled = true

				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end
	
	--// Destroy function to clean up window and floating button
	function Options:Destroy()
		StopRainbow()
		-- Destroy floating button
		if Options._FloatingButton and Options._FloatingButton.Parent then
			Options._FloatingButton:Destroy()
		end
		
		-- Clean up blur if enabled
		if BlurEnabled and Blurs[Settings.Title] then
			Blurs[Settings.Title].root.Parent = nil
		end
		
		-- Destroy window
		if Window and Window.Parent then
			Window:Destroy()
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
