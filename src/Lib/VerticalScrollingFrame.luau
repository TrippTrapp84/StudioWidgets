----------------------------------------
--
-- VerticalScrollingFrame.lua
--
-- Creates a scrolling frame that automatically updates canvas size
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Types = require(script.Parent.Parent.Types)

local Class = {}
Class.__index = Class

type VerticalScrollingFrame = Types.VerticalScrollingFrame

function Class.new(Children: {Types.WidgetBase}?): VerticalScrollingFrame
	local self = (setmetatable({}, Class) :: never) :: VerticalScrollingFrame

	local Section = Instance.new("Frame")
	Section.BorderSizePixel = 0
	Section.Size = UDim2.new(1, 0, 1, 0)
	Section.Position = UDim2.new(0, 0, 0, 0)
	Section.BackgroundTransparency = 1
	Section.Name = "VerticalScrollFrame"

	local ScrollBackground = Instance.new("Frame")
	ScrollBackground.Name = "ScrollbarBackground"
	ScrollBackground.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
	ScrollBackground.BorderColor3 = Color3.fromRGB(182, 182, 182)
	ScrollBackground.Size = UDim2.new(0, 15, 1, -2)
	ScrollBackground.Position = UDim2.new(1, -16, 0, 1)
	ScrollBackground.Parent = Section
	ScrollBackground.ZIndex = 2

	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Never
	ScrollFrame.ScrollBarThickness = 17
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.ZIndex = 2
	ScrollFrame.TopImage = "http://www.roblox.com/asset/?id=1533255544"
	ScrollFrame.MidImage = "http://www.roblox.com/asset/?id=1535685612"
	ScrollFrame.BottomImage = "http://www.roblox.com/asset/?id=1533256504"
	ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
	ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
	ScrollFrame.Parent = Section

	self.ChildCount = 0

	local UiListLayout = Instance.new("UIListLayout")
	UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UiListLayout.Parent = ScrollFrame

	self.Section = Section
	self.ScrollFrame = ScrollFrame
	self.ScrollBackground = ScrollBackground
	self.UiListLayout = UiListLayout

	ScrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:UpdateScrollingFrameCanvas() end)
	UiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() self:UpdateScrollingFrameCanvas() end)
	self:UpdateScrollingFrameCanvas()

	GuiUtilities.SyncGuiElementScrollColor(ScrollFrame)
	GuiUtilities.SyncGuiElementBorderColor(ScrollBackground)
	GuiUtilities.SyncGuiElementTitleColor(ScrollBackground)

	local Children: {Types.WidgetBase} = Children or {}

	for _, Child in pairs(Children) do
		if not Child.GetFrame then continue end
		self:AddChild(Child.GetFrame(Child))
	end

	return self
end

function Class:AddChild(Child: Instance)
	local self = self :: VerticalScrollingFrame

	if Child:IsA("GuiObject") then
		Child.LayoutOrder = self.ChildCount
		self.ChildCount = self.ChildCount + 1
	end

	Child.Parent = self:GetFrame()
	return Child
end

function Class:UpdateScrollbarBackingVisibility()
	local self = self :: VerticalScrollingFrame

	self.ScrollBackground.Visible = self.ScrollFrame.AbsoluteSize.Y < self.UiListLayout.AbsoluteContentSize.Y
end

function Class:UpdateScrollingFrameCanvas()
	local self = self :: VerticalScrollingFrame

	self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.UiListLayout.AbsoluteContentSize.Y)
	self:UpdateScrollbarBackingVisibility()
end

function Class:GetFrame()
	local self = self :: VerticalScrollingFrame

	return self.Section
end

--// RETURN
return Class
