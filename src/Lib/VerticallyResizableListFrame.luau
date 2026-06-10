----------------------------------------
--
-- VerticallyResizableListFrame
--
-- Creates a frame that can be resized dynamically by users, with added cursor indicators
-- Will correctly clip descendants and preserve pixel size when widgets are scaled.
--
----------------------------------------
local RunService = game:GetService("RunService")

local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local PluginUtil = require(script.Parent.Parent.Util.Plugin)

local BOTTOM_PADDING = 10
local RESIZE_LINE_THICKNESS = 5
local SCALING_MOUSE_ICON = "rbxasset://SystemCursors/SizeNS"

local Class = {}
Class.__index = Class

type Config = {
	InitialHeight: number?,
	MinimumHeight: number?,
	MaximumHeight: number?,
	HeightLocked: boolean?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.MaximumHeight = Data.MaximumHeight or 300
	self.MinimumHeight = Data.MinimumHeight or 100

	self._resizeCallback = nil
	self._widgetParent = nil
	self._sizeLocked = Data.HeightLocked or false
	
	local frame = Instance.new('Frame')
	frame.Name = 'VRLFrame'
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	GuiUtilities.syncGuiElementBackgroundColor(frame)

	self._frame = frame
	
	local uiListLayout = Instance.new('UIListLayout')
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame
	self._uiListLayout = uiListLayout
	
	local ResizeLine = Instance.new("ImageButton")
	ResizeLine.Name = "VRLFrameResizeLine"
	ResizeLine.Size = UDim2.new(1,0,0,RESIZE_LINE_THICKNESS)
	ResizeLine.Position = UDim2.new(0,0,1,-RESIZE_LINE_THICKNESS)
	ResizeLine.Image = ""
	ResizeLine.AutoButtonColor = false
	ResizeLine.BorderSizePixel = 0
	ResizeLine.LayoutOrder = 9000
	ResizeLine.Parent = frame
	GuiUtilities.syncGuiElementStripeColor(ResizeLine)

	local function updateSizes(NewSize)
		NewSize = math.max(math.min(NewSize,self.MaximumHeight),self.MinimumHeight)
		self._frame.Size = UDim2.new(1, 0, 0, NewSize-RESIZE_LINE_THICKNESS)
		if (self._resizeCallback) then 
			self._resizeCallback(NewSize)
		end
	end
	
	local Mouse = PluginUtil.GetPluginDistributorObject():GetMouse()
	local MouseIsDragging = false
	
	ResizeLine.MouseEnter:Connect(function()
		Mouse.Icon = SCALING_MOUSE_ICON
	end)
	
	local PastLeave = tick()
	ResizeLine.MouseLeave:Connect(function()
		PastLeave = tick()
		local MyPastLeave = PastLeave
		while MouseIsDragging do
			task.wait()
			if MyPastLeave ~= PastLeave then return end
		end
		Mouse.Icon = ""
	end)
	
	ResizeLine.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if self._sizeLocked or not self._widgetParent then return end
		local EndCon
		local Ended = false
		EndCon = ResizeLine.InputEnded:Connect(function(EndInput)
			if EndInput.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			Ended = true
			EndCon:Disconnect()
		end)
		MouseIsDragging = true
		local MPos = self._widgetParent:GetRelativeMousePosition()
		local Offset = MPos.Y - ResizeLine.AbsolutePosition.Y
		while not Ended do
			MPos = self._widgetParent:GetRelativeMousePosition()
			local NewPos = MPos.Y - frame.AbsolutePosition.Y - Offset
			updateSizes(NewPos)
			RunService.RenderStepped:Wait()
		end
		MouseIsDragging = false
	end)
	updateSizes(Data.InitialHeight or self.MaximumHeight)
	
	frame.AncestryChanged:Connect(function()
		self._widgetParent = frame:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
	end)
	
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

function Class:SetLocked(locked)
	self._sizeLocked = locked
end

return Class