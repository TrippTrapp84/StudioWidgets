----------------------------------------
--
-- VerticallyScalingListFrame
--
-- Creates a frame that organizes children into a list layout.
-- Will scale dynamically as children grow.
--
----------------------------------------
local plugin = _G.StudioWidgetsPluginGlobalDistributorObject

local RunServ = game:GetService("RunService")

local GuiUtilities = require(script.Parent.GuiUtilities)

local Handler = {}
Handler.__index = Handler

local kBottomPadding = 10
local kResizeLineThickness = 5
local ScalingIcon = "rbxasset://SystemCursors/SizeNS"

function Handler.new(nameSuffix,StartingSize,MinimumSize,MaximumSize,SizeLocked)
	local self = {}
	setmetatable(self, Handler)

	self._resizeCallback = nil
	self._widgetParent = nil
	self._sizeLocked = SizeLocked
	
	local frame = Instance.new('Frame')
	frame.Name = 'VRLFrame' .. nameSuffix
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
	ResizeLine.Size = UDim2.new(1,0,0,kResizeLineThickness)
	ResizeLine.Position = UDim2.new(0,0,1,-kResizeLineThickness)
	ResizeLine.Image = ""
	ResizeLine.AutoButtonColor = false
	ResizeLine.BorderSizePixel = 0
	ResizeLine.LayoutOrder = 9000
	ResizeLine.Parent = frame
	GuiUtilities.syncGuiElementStripeColor(ResizeLine)

	local function updateSizes(NewSize)
		NewSize = math.max(math.min(NewSize,MaximumSize),MinimumSize)
		self._frame.Size = UDim2.new(1, 0, 0, NewSize)
		if (self._resizeCallback) then 
			self._resizeCallback()
		end
	end
	
	local Mouse = plugin:GetMouse()
	local MouseIsDragging = false
	
	ResizeLine.MouseEnter:Connect(function()
		Mouse.Icon = ScalingIcon
	end)
	
	local PastLeave = tick()
	ResizeLine.MouseLeave:Connect(function()
		PastLeave = tick()
		local MyPastLeave = PastLeave
		while MouseIsDragging do
			wait()
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
			RunServ.RenderStepped:Wait()
		end
		MouseIsDragging = false
	end)
	updateSizes(StartingSize)
	
	frame.AncestryChanged:Connect(function()
		self._widgetParent = frame:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
	end)
	
	self._childCount = 0

	return self
end

function Handler:AddBottomPadding()
	local frame = Instance.new("Frame")
	frame.Name = "BottomPadding"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, kBottomPadding)
	frame.LayoutOrder = 1000
	frame.Parent = self._frame
end

function Handler:GetFrame()
	return self._frame
end

function Handler:AddChild(childFrame)
	childFrame.LayoutOrder = self._childCount
	self._childCount = self._childCount + 1
	childFrame.Parent = self._frame
end

function Handler:SetCallbackOnResize(callback)
	self._resizeCallback = callback
end

function Handler:SetLocked(locked)
	self._sizeLocked = locked
end

--// RETURN
return Handler