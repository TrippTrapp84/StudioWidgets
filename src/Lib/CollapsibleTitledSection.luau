----------------------------------------
--
-- CollapsibleTitledSectionClass
--
-- Creates a section with a title label:
--
-- "SectionXXX"
--     "TitleBarVisual"
--     "Contents"
--
-- Requires "parent" and "sectionName" parameters and returns the section and its contentsFrame
-- The entire frame will resize dynamically as contents frame changes size.
--
-- "autoScalingList" is a boolean that defines wheter or not the content frame automatically resizes when children are added.
-- This is important for cases when you want minimize button to push or contract what is below it.
--
-- Both "minimizeable" and "minimizedByDefault" are false by default
-- These parameters define if the section will have an arrow button infront of the title label,
-- which the user may use to hide the section's contents
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local TransparentTextInput = require(script.Parent.TransparentTextInput)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)
local CommonUtil = require(script.Parent.Parent.Util.Common)

local RunService = game:GetService("RunService")

local RightButtonAsset = "rbxasset://textures/TerrainTools/button_arrow.png"
local DownButtonAsset = "rbxasset://textures/TerrainTools/button_arrow_down.png"

local ARROW_SIZE = 9
local DOUBLE_CLICK_DELAY = 0.25

type CollapsibleTitledSection = Types.CollapsibleTitledSection

local Class = {}
Class.__index = Class

type Config = {
	Suffix: string,
	Title: string,
	AutoScalingEnabled: boolean?,
	Minimizable: boolean?,
	Minimized: boolean?,
	TitleBarInset: number?,
	ChildInset: number?,
	Renamable: boolean?,
	TitleBarHeight: number?,
}

function Class.new<T>(Config: Config, Children: {T}?): CollapsibleTitledSection
	local self = (setmetatable({}, Class) :: never) :: CollapsibleTitledSection

	local Minimizable = if Config.Minimizable == nil then true else Config.Minimizable
	self.Minimized = Config.Minimized or false

	self.Pressed = Signal.new()
	self.DoublePressed = Signal.new()

	local Frame = Instance.new("Frame")
	Frame.Name = "CTSection"
	Frame.BackgroundTransparency = 1
	self.Frame = Frame :: never

	local UiListLayout = Instance.new("UIListLayout")
	UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UiListLayout.Parent = Frame
	self.ListLayout = UiListLayout

	local ContentsFrame = Instance.new("Frame")
	ContentsFrame.Name = "Contents"
	ContentsFrame.BackgroundTransparency = 1
	ContentsFrame.Size = UDim2.new(1, 0, 0, 1)
	ContentsFrame.Position = UDim2.new(0, ARROW_SIZE, 0, 0)
	ContentsFrame.Parent = Frame
	ContentsFrame.LayoutOrder = 2
	GuiUtilities.SyncGuiElementBackgroundColor(ContentsFrame)

	self.ContentsFrame = ContentsFrame

	UiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:UpdateSize()
	end)
	self:UpdateSize()

	self:CreateTitleBar(
		Config.Title,
		Config.TitleBarInset or 0,
		Config.TitleBarHeight or GuiUtilities.TitleBarHeight,
		Config.Renamable or false,
		Minimizable
	)
	self:SetCollapsed(self.Minimized)

	if Config.AutoScalingEnabled ~= false then
		GuiUtilities.MakeFrameAutoScalingList(self.ContentsFrame)
	end

	self.ContentsFrame.ChildAdded:Connect(function(ChildFrame: Instance)
		if not ChildFrame:IsA("GuiObject") then
			return
		end
		if ChildFrame.Name:find("CTContentsChildSizingFrame_") then
			return
		end

		local SizerFrame = Instance.new("Frame")
		SizerFrame.Size = UDim2.new(1, 0, 0, ChildFrame.Size.Y.Offset)
		SizerFrame.BorderSizePixel = 0
		SizerFrame.BackgroundTransparency = 1
		SizerFrame.LayoutOrder = ChildFrame.LayoutOrder
		SizerFrame.Name = "CTContentsChildSizingFrame_" .. ChildFrame.Name
		ChildFrame.Position += UDim2.fromOffset(Config.ChildInset or 0, 0)
		local SizerConnection = ChildFrame:GetPropertyChangedSignal("Size"):Connect(function()
			SizerFrame.Size = UDim2.new(1, 0, 0, ChildFrame.Size.Y.Offset)
		end)
		local LayoutOrderConnection = ChildFrame:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
			SizerFrame.LayoutOrder = ChildFrame.LayoutOrder
		end)
		local ParentingConnection
		RunService.RenderStepped:Wait()
		self.ContentsFrame:WaitForChild(ChildFrame.Name).Parent = SizerFrame
		ParentingConnection = ChildFrame:GetPropertyChangedSignal("Parent"):Connect(function()
			SizerConnection:Disconnect()
			ParentingConnection:Disconnect()
			LayoutOrderConnection:Disconnect()
			SizerFrame:Destroy()
		end)
		SizerFrame.Parent = self.ContentsFrame
	end)

	CommonUtil.AddChildren(self, Children or {})

	return self
end

function Class:GetFrame()
	local self = self :: CollapsibleTitledSection

	return self.Frame
end

function Class:AddChild(Child: Instance)
	local self = self :: CollapsibleTitledSection

	Child.Parent = self.ContentsFrame

	return Child
end

function Class:UpdateSize()
	local self = self :: CollapsibleTitledSection

	local TotalSize = self.ListLayout.AbsoluteContentSize.Y
	self.Frame.Size = UDim2.new(1, 0, 0, TotalSize)
end

function Class:UpdateMinimizeButton()
	local self = self :: CollapsibleTitledSection

	if self.Minimized then
		self.MinimizeButton.Image = RightButtonAsset
	else
		self.MinimizeButton.Image = DownButtonAsset
	end
end

function Class:SetCollapsed(Bool: boolean)
	local self = self :: CollapsibleTitledSection

	self.Minimized = Bool
	self.ContentsFrame.Visible = not Bool
	self:UpdateMinimizeButton()
	self:UpdateSize()
end

function Class:GetTitleInput(Func)
	local self = self :: CollapsibleTitledSection

	return self.TitleTextInput
end

function Class:ToggleCollapsed()
	local self = self :: CollapsibleTitledSection

	self:SetCollapsed(not self.Minimized)
end

function Class:SetTitle(Title)
	local self = self :: CollapsibleTitledSection

	if self.TitleTextInput then
		(self.TitleTextInput :: any):SetTitle(Title)
	else
		self.Frame.TitleBarVisual.TitleLabel.Text = Title
	end
end

function Class:SetTitleBarColor(Color: Color3)
	local self = self :: CollapsibleTitledSection

	self.TitleBarColor = Color
	if self.ColorOverrides then
		self.TitleBarButton.BackgroundColor3 = Color
	end
end

function Class:SetTitleBarColorOverrides(Overrides)
	local self = self :: CollapsibleTitledSection

	if Overrides == self.ColorOverrides then
		return
	end
	self.ColorOverrides = Overrides
	if Overrides then
		self.TitleBarButtonColorConnection:Disconnect()
		if self.TitleBarColor then
			self.TitleBarButton.BackgroundColor3 = self.TitleBarColor
		end
	else
		self.TitleBarButtonColorConnection = GuiUtilities.SyncGuiElementTitleColor(self.TitleBarButton)
	end
end

function Class:CreateTitleBar(Title: string, Inset: number, Height: number, Renamable: boolean, Minimizable: boolean)
	local self = self :: CollapsibleTitledSection

	local TitleBar = Instance.new("ImageButton")
	TitleBar.AutoButtonColor = false
	TitleBar.Name = "TitleBarVisual"
	TitleBar.BorderSizePixel = 0
	TitleBar.Position = UDim2.new(0, 0, 0, 0)
	TitleBar.Size = UDim2.new(1, 0, 0, Height)
	TitleBar.Parent = self.Frame
	TitleBar.LayoutOrder = 1
	self.TitleBarButton = TitleBar
	self.TitleBarButtonColorConnection = GuiUtilities.SyncGuiElementTitleColor(TitleBar)
	self.ColorOverrides = false

	if Renamable then
		local TitleLabel = TransparentTextInput.new({
			InitialValue = Title,
			Inset = -75,
			ClearOnFocus = false,
		})
		self.TitleTextInput = TitleLabel
		TitleLabel:GetFrame().Parent = TitleBar
		TitleLabel:GetFrame().BackgroundTransparency = 1
	else
		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "TitleLabel"
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.SourceSansBold --todo: input spec font
		TitleLabel.TextSize = 15 --todo: input spec font size
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Text = Title
		TitleLabel.Position = UDim2.new(0, Height + Inset, 0, 0)
		TitleLabel.Size = UDim2.new(1, -Height, 1, GuiUtilities.TextVerticalFudge)
		TitleLabel.Parent = TitleBar
		GuiUtilities.SyncGuiElementFontColor(TitleLabel)
	end

	self.MinimizeButton = Instance.new("ImageButton")
	self.MinimizeButton.Name = "MinimizeSectionButton"
	self.MinimizeButton.Image = RightButtonAsset --todo: input arrow image from spec
	self.MinimizeButton.Size = UDim2.new(0, ARROW_SIZE, 0, ARROW_SIZE)
	self.MinimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
	self.MinimizeButton.Position = UDim2.new(0, Height * 0.5 + Inset, 0, Height * 0.5)
	self.MinimizeButton.BackgroundTransparency = 1
	self.MinimizeButton.Visible = Minimizable

	self.MinimizeButton.MouseButton1Down:Connect(function()
		self:ToggleCollapsed()
	end)
	self:UpdateMinimizeButton()
	self.MinimizeButton.Parent = TitleBar

	self.LatestClickTime = 0
	TitleBar.MouseButton1Down:Connect(function()
		local Now = tick()
		if Now - self.LatestClickTime < DOUBLE_CLICK_DELAY then
			self:ToggleCollapsed()
			self.LatestClickTime = 0
			self.DoublePressed:Fire()
		else
			self.LatestClickTime = Now
			task.wait(DOUBLE_CLICK_DELAY + 0.05)
			if self.LatestClickTime ~= 0 then
				self.Pressed:Fire()
			end
		end
	end)
end

return Class
