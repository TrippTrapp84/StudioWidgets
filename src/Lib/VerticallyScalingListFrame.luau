----------------------------------------
--
-- VerticallyScalingListFrame
--
-- Creates a frame that organizes children into a list layout.
-- Will scale dynamically as children grow.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local BOTTOM_PADDING = 10

local Class = {}
Class.__index = Class

type VerticallyScalingListFrame = Types.VerticallyScalingListFrame

function Class.new(Children: {Types.WidgetBase}?): VerticallyScalingListFrame
	local self = (setmetatable({}, Class) :: never) :: VerticallyScalingListFrame

	self.Resized = Signal.new()

	local Frame = Instance.new('Frame')
	Frame.Name = 'VSLFrame'
	Frame.Size = UDim2.new(1, 0, 0, 0)
	Frame.BackgroundTransparency = 0
	Frame.BorderSizePixel = 0
	GuiUtilities.SyncGuiElementBackgroundColor(Frame)

	self.Frame = Frame

	local UiListLayout = Instance.new('UIListLayout')
	UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UiListLayout.Parent = Frame
	self.UiListLayout = UiListLayout

	local function UpdateSizes()
		self.Frame.Size = UDim2.new(1, 0, 0, UiListLayout.AbsoluteContentSize.Y)
		self.Resized:Fire()
	end
	self.UiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSizes)
	UpdateSizes()

	self.ChildCount = 0

	local Children: {Types.WidgetBase} = Children or {}

	for _, Child in pairs(Children) do
		if not Child.GetFrame then continue end
		self:AddChild(Child.GetFrame(Child))
	end

	return self
end

function Class:AddBottomPadding()
	local self = self :: VerticallyScalingListFrame

	local Frame = Instance.new("Frame")
	Frame.Name = "BottomPadding"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 0, BOTTOM_PADDING)
	Frame.LayoutOrder = 1000
	Frame.Parent = self.Frame
end

function Class:GetFrame()
	local self = self :: VerticallyScalingListFrame

	return self.Frame
end

function Class:AddChild(Child: Instance)
	local self = self :: VerticallyScalingListFrame

	if Child:IsA("GuiObject") then
		Child.LayoutOrder = self.ChildCount
		self.ChildCount = self.ChildCount + 1
	end

	Child.Parent = self:GetFrame()
	return Child
end

return Class
