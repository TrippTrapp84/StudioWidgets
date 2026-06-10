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

local RunService = game:GetService("RunService")

local kRightButtonAsset = "rbxasset://textures/TerrainTools/button_arrow.png"
local kDownButtonAsset = "rbxasset://textures/TerrainTools/button_arrow_down.png"

local ARROW_SIZE = 9
local DOUBLE_CLICK_DELAY = 0.25

local Class = {}
Class.__index = Class

type Config = {
    Suffix: string,
    LabelText: string,
    AutoScalingEnabled: boolean?,
    Minimizable: boolean?,
    Minimized: boolean?,
    TitleBarInset: number?,
    ChildInset: number?,
    Renamable: boolean?,
    TitleBarHeight: number?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

    self.Suffix = Data.Suffix
    self.LabelText = Data.LabelText
    self.AutoScalingEnabled = Data.AutoScalingEnabled or true
    self.Minimizable = Data.Minimizable or true
    self.Minimized = Data.Minimized or false
    self.TitleBarInset = Data.TitleBarInset or 0
    self.ChildInset = Data.ChildInset or 0
    self.Renamable = Data.Renamable or false
    self.TitleBarHeight = Data.TitleBarHeight or GuiUtilities.kTitleBarHeight

	local frame = Instance.new('Frame')
	frame.Name = 'CTSection' .. self.Suffix
	frame.BackgroundTransparency = 1
	self._frame = frame

	local uiListLayout = Instance.new('UIListLayout')
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame
	self._uiListLayout = uiListLayout

	local contentsFrame = Instance.new('Frame')
	contentsFrame.Name = 'Contents'
	contentsFrame.BackgroundTransparency = 1
	contentsFrame.Size = UDim2.new(1, 0, 0, 1)
	contentsFrame.Position = UDim2.new(0, ARROW_SIZE, 0, 0)
	contentsFrame.Parent = frame
	contentsFrame.LayoutOrder = 2
	GuiUtilities.syncGuiElementBackgroundColor(contentsFrame)

	self._contentsFrame = contentsFrame

	uiListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		self:_UpdateSize()
	end)
	self:_UpdateSize()

	self:_CreateTitleBar(self.LabelText,self.TitleBarInset or 0,self.Renamable)
	self:SetCollapsedState(self.Minimized)

	if (self.AutoScalingEnabled) then
		GuiUtilities.MakeFrameAutoScalingList(self:GetContentsFrame())
	end
	
	self._contentsFrame.ChildAdded:Connect(function(ChildFrame)
		if ChildFrame.Name:find("CTContentsChildSizingFrame_") or not ChildFrame:IsA("GuiBase2d") then return end
		local SizerFrame = Instance.new("Frame")
		SizerFrame.Size = UDim2.new(1,0,0,ChildFrame.Size.Y.Offset)
		SizerFrame.BorderSizePixel = 0
		SizerFrame.BackgroundTransparency = 1
		SizerFrame.LayoutOrder = ChildFrame.LayoutOrder
		SizerFrame.Name = "CTContentsChildSizingFrame_" .. ChildFrame.Name
		ChildFrame.Position += UDim2.fromOffset(self.ChildInset,0)
		local Sizerconnection = ChildFrame:GetPropertyChangedSignal("Size"):Connect(function()
			SizerFrame.Size = UDim2.new(1,0,0,ChildFrame.Size.Y.Offset)
		end)
		local LayoutorderConnection = ChildFrame:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
			SizerFrame.LayoutOrder = ChildFrame.LayoutOrder
		end)
		local ParentingConnection
		RunService.RenderStepped:Wait()
		self._contentsFrame:WaitForChild(ChildFrame.Name).Parent = SizerFrame
		ParentingConnection = ChildFrame:GetPropertyChangedSignal("Parent"):Connect(function()
			Sizerconnection:Disconnect()
			ParentingConnection:Disconnect()
			LayoutorderConnection:Disconnect()
			SizerFrame:Destroy()
		end)
		SizerFrame.Parent = self._contentsFrame
	end)

	return self
end


function Class:GetSectionFrame()
	return self._frame
end

function Class:GetContentsFrame()
	return self._contentsFrame
end

function Class:_UpdateSize()
	local totalSize = self._uiListLayout.AbsoluteContentSize.Y
	self._frame.Size = UDim2.new(1, 0, 0, totalSize)
end

function Class:SetTitlePressedFunction(tpf)
	self._TitlePressedFunction = tpf
end

function Class:SetTitleDoublePressedFunction(tdpf)
	self._TitleDoublePressedFunction = tdpf
end

function Class:_UpdateMinimizeButton()
	-- We can't rotate it because rotated images don't get clipped by parents.
	-- This is all in a scroll widget.
	-- :(
	if (self.Minimized) then 
		self._minimizeButton.Image = kRightButtonAsset
	else
		self._minimizeButton.Image = kDownButtonAsset
	end
end

function Class:SetCollapsedState(bool)
	self.Minimized = bool
	self._contentsFrame.Visible = not bool
	self:_UpdateMinimizeButton()
	self:_UpdateSize()
end

function Class:GetTitleInput(Func)
	return self.TitleTextInput
end

function Class:_ToggleCollapsedState()
	self:SetCollapsedState(not self.Minimized)
end

function Class:SetTitle(title)
	if self.TitleTextInput then
		self.TitleTextInput:SetTitle(title)
	else
		self._frame.TitleBarVisual.TitleLabel.Text = title
	end
end

function Class:SetTitleBarColor(Color)
	self._titleBarColor = Color
	if self._colorOverrides then
		self._titleBarButton.BackgroundColor3 = self._titleBarColor
	end
end

function Class:SetTitleBarColorOverrides(Overrides)
	if Overrides == self._colorOverrides then return end
	self._colorOverrides = Overrides
	if Overrides then
		self._titleBarButtonColorConnection:Disconnect()
		if self._titleBarColor then
			self._titleBarButton.BackgroundColor3 = self._titleBarColor
		end
	else
		self._titleBarButtonColorConnection = GuiUtilities.syncGuiElementTitleColor(self._titleBarButton)
	end
end

function Class:_CreateTitleBar(titleText,Inset,Renamable)
	local titleTextOffset = self.TitleBarHeight

	local titleBar = Instance.new('ImageButton')
	titleBar.AutoButtonColor = false
	titleBar.Name = 'TitleBarVisual'
	titleBar.BorderSizePixel = 0
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.Size = UDim2.new(1, 0, 0, self.TitleBarHeight)
	titleBar.Parent = self._frame
	titleBar.LayoutOrder = 1
	self._titleBarButton = titleBar
	self._titleBarButtonColorConnection = GuiUtilities.syncGuiElementTitleColor(titleBar)
	self._colorOverrides = false

	if Renamable then
		local titleLabel = TransparentTextInput.new{
			InitialValue = titleText,
			Inset = -75,
			ClearOnFocus = false,
		}
		self.TitleTextInput = titleLabel
		titleLabel:GetFrame().Parent = titleBar
		titleLabel:GetFrame().BackgroundTransparency = 1
	else
		local titleLabel = Instance.new('TextLabel')
		titleLabel.Name = 'TitleLabel'
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = Enum.Font.SourceSansBold                --todo: input spec font
		titleLabel.TextSize = 15                                  --todo: input spec font size
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Text = titleText
		titleLabel.Position = UDim2.new(0, titleTextOffset + Inset, 0, 0)
		titleLabel.Size = UDim2.new(1, -titleTextOffset, 1, GuiUtilities.kTextVerticalFudge)
		titleLabel.Parent = titleBar
		GuiUtilities.syncGuiElementFontColor(titleLabel)
	end

	self._minimizeButton = Instance.new('ImageButton')
	self._minimizeButton.Name = 'MinimizeSectionButton'
	self._minimizeButton.Image = kRightButtonAsset              --todo: input arrow image from spec
	self._minimizeButton.Size = UDim2.new(0, ARROW_SIZE, 0, ARROW_SIZE)
	self._minimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
	self._minimizeButton.Position = UDim2.new(0, self.TitleBarHeight*.5 + Inset,
		0, self.TitleBarHeight*.5)
	self._minimizeButton.BackgroundTransparency = 1
	self._minimizeButton.Visible = self.Minimizable -- only show when minimizable

	self._minimizeButton.MouseButton1Down:Connect(function()
		self:_ToggleCollapsedState()
	end)
	self:_UpdateMinimizeButton()
	self._minimizeButton.Parent = titleBar

	self._latestClickTime = 0
	titleBar.MouseButton1Down:Connect(function()
		local now = tick()	
		if (now - self._latestClickTime < DOUBLE_CLICK_DELAY) then 
			self:_ToggleCollapsedState()
			self._latestClickTime = 0
			if self._TitleDoublePressedFunction then
				self._TitleDoublePressedFunction(self.Minimized)
			end
		else
			self._latestClickTime = now
			task.wait(DOUBLE_CLICK_DELAY+0.05)
			if self._latestClickTime ~= 0 and self._TitlePressedFunction then
				self._TitlePressedFunction(self.Minimized)
			end
		end
	end)
end

--// RETURN
return Class