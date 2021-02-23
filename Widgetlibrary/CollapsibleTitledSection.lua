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
local plugin = _G.StudioWidgetsPluginGlobalDistributorObject

local GuiUtilities = require(script.Parent.GuiUtilities)
local TransparentTextInput = require(script.Parent.TransparentTextInput)

local RunServ = game:GetService("RunService")

local kRightButtonAsset = "rbxasset://textures/TerrainTools/button_arrow.png"
local kDownButtonAsset = "rbxasset://textures/TerrainTools/button_arrow_down.png"

local kArrowSize = 9
local kDoubleClickTimeSec = 0.25

local CollapsibleTitledSectionClass = {}
CollapsibleTitledSectionClass.__index = CollapsibleTitledSectionClass


function CollapsibleTitledSectionClass.new(nameSuffix, titleText, autoScalingList, minimizable, minimizedByDefault, XInset, XChildInset, Renamable)
	local self = {}
	setmetatable(self, CollapsibleTitledSectionClass)

	self._minimized = minimizedByDefault
	self._minimizable = minimizable

	self._titleBarHeight = GuiUtilities.kTitleBarHeight

	local frame = Instance.new('Frame')
	frame.Name = 'CTSection' .. nameSuffix
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
	contentsFrame.Position = UDim2.new(0, kArrowSize, 0, 0)
	contentsFrame.Parent = frame
	contentsFrame.LayoutOrder = 2
	GuiUtilities.syncGuiElementBackgroundColor(contentsFrame)

	self._contentsFrame = contentsFrame

	uiListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		self:_UpdateSize()
	end)
	self:_UpdateSize()

	self:_CreateTitleBar(titleText,XInset or 0,Renamable)
	self:SetCollapsedState(self._minimized)

	if (autoScalingList) then
		GuiUtilities.MakeFrameAutoScalingList(self:GetContentsFrame())
	end
	
	if XChildInset then
		self._contentsFrame.ChildAdded:Connect(function(ChildFrame)
			if ChildFrame.Name:find("CTContentsChildSizingFrame_") then return end
			local SizerFrame = Instance.new("Frame")
			SizerFrame.Size = UDim2.new(1,0,0,ChildFrame.Size.Y.Offset)
			SizerFrame.BorderSizePixel = 0
			SizerFrame.BackgroundTransparency = 1
			SizerFrame.Name = "CTContentsChildSizingFrame_" .. ChildFrame.Name
			ChildFrame.Position += UDim2.fromOffset(XChildInset,0)
			local Sizerconnection = ChildFrame:GetPropertyChangedSignal("Size"):Connect(function()
				SizerFrame.Size = UDim2.new(1,0,0,ChildFrame.Size.Y.Offset)
			end)
			local ParentingConnection
			RunServ.RenderStepped:Wait()
			self._contentsFrame:WaitForChild(ChildFrame.Name).Parent = SizerFrame
			ParentingConnection = ChildFrame:GetPropertyChangedSignal("Parent"):Connect(function()
				Sizerconnection:Disconnect()
				ParentingConnection:Disconnect()
				SizerFrame:Destroy()
			end)
			SizerFrame.Parent = self._contentsFrame
		end)
	end

	return self
end


function CollapsibleTitledSectionClass:GetSectionFrame()
	return self._frame
end

function CollapsibleTitledSectionClass:GetContentsFrame()
	return self._contentsFrame
end

function CollapsibleTitledSectionClass:_UpdateSize()
	local totalSize = self._uiListLayout.AbsoluteContentSize.Y
	self._frame.Size = UDim2.new(1, 0, 0, totalSize)
end

function CollapsibleTitledSectionClass:SetTitlePressedFunction(tpf)
	self._TitlePressedFunction = tpf
end

function CollapsibleTitledSectionClass:_UpdateMinimizeButton()
	-- We can't rotate it because rotated images don't get clipped by parents.
	-- This is all in a scroll widget.
	-- :(
	if (self._minimized) then 
		self._minimizeButton.Image = kRightButtonAsset
	else
		self._minimizeButton.Image = kDownButtonAsset
	end
end

function CollapsibleTitledSectionClass:SetCollapsedState(bool)
	self._minimized = bool
	self._contentsFrame.Visible = not bool
	self:_UpdateMinimizeButton()
	self:_UpdateSize()
end

function CollapsibleTitledSectionClass:GetTitleInput(Func)
	return self.TitleTextInput
end

function CollapsibleTitledSectionClass:_ToggleCollapsedState()
	self:SetCollapsedState(not self._minimized)
end

function CollapsibleTitledSectionClass:SetTitle(title)
	if self.TitleTextInput then
		self.TitleTextInput:SetTitle(title)
	else
		self._frame.TitleBarVisual.TitleLabel.Text = title
	end
end

function CollapsibleTitledSectionClass:_CreateTitleBar(titleText,Inset,Renamable)
	local titleTextOffset = self._titleBarHeight

	local titleBar = Instance.new('ImageButton')
	titleBar.AutoButtonColor = false
	titleBar.Name = 'TitleBarVisual'
	titleBar.BorderSizePixel = 0
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.Size = UDim2.new(1, 0, 0, self._titleBarHeight)
	titleBar.Parent = self._frame
	titleBar.LayoutOrder = 1
	GuiUtilities.syncGuiElementTitleColor(titleBar)

	if Renamable then
		local titleLabel = TransparentTextInput.new(
			"RenamableTitleBox",
			titleText,
			-75,
			false
		)
		self.TitleTextInput = titleLabel
		titleLabel:GetFrame().Parent = titleBar
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
	self._minimizeButton.Size = UDim2.new(0, kArrowSize, 0, kArrowSize)
	self._minimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
	self._minimizeButton.Position = UDim2.new(0, self._titleBarHeight*.5 + Inset,
		0, self._titleBarHeight*.5)
	self._minimizeButton.BackgroundTransparency = 1
	self._minimizeButton.Visible = self._minimizable -- only show when minimizable

	self._minimizeButton.MouseButton1Down:Connect(function()
		self:_ToggleCollapsedState()
	end)
	self:_UpdateMinimizeButton()
	self._minimizeButton.Parent = titleBar

	self._latestClickTime = 0
	titleBar.MouseButton1Down:Connect(function()
		local now = tick()	
		if (now - self._latestClickTime < kDoubleClickTimeSec) then 
			self:_ToggleCollapsedState()
			self._latestClickTime = 0
		else
			self._latestClickTime = now
			wait(kDoubleClickTimeSec+0.05)
			if self._latestClickTime ~= 0 and self._TitlePressedFunction then
				self._TitlePressedFunction()
			end
		end
	end)
end

--// RETURN
return CollapsibleTitledSectionClass