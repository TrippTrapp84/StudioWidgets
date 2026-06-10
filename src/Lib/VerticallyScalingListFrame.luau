----------------------------------------
--
-- VerticallyScalingListFrame
--
-- Creates a frame that organizes children into a list layout.
-- Will scale dynamically as children grow.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local BOTTOM_PADDING = 10

local Class = {}
Class.__index = Class

function Class.new()
	local self = setmetatable({}, Class)

	self._resizeCallback = nil
	
	local frame = Instance.new('Frame')
	frame.Name = 'VSLFrame'
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	GuiUtilities.syncGuiElementBackgroundColor(frame)

	self._frame = frame
	
	local uiListLayout = Instance.new('UIListLayout')
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame
	self._uiListLayout = uiListLayout

	local function updateSizes()
		self._frame.Size = UDim2.new(1, 0, 0, uiListLayout.AbsoluteContentSize.Y)
		if (self._resizeCallback) then 
			self._resizeCallback()
		end
	end
	self._uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)
	updateSizes()

	self._childCount = 0

	return self
end

function Class:AddBottomPadding()
	local frame = Instance.new("Frame")
	frame.Name = "BottomPadding"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, BOTTOM_PADDING)
	frame.LayoutOrder = 1000
	frame.Parent = self._frame
end

function Class:GetFrame()
	return self._frame
end

function Class:AddChild(childFrame)
	childFrame.LayoutOrder = self._childCount
	self._childCount = self._childCount + 1
	childFrame.Parent = self._frame
end

function Class:SetCallbackOnResize(callback)
	self._resizeCallback = callback
end

return Class