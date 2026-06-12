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
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local BOTTOM_PADDING = 10
local RESIZE_LINE_THICKNESS = 5
local SCALING_MOUSE_ICON = "rbxasset://SystemCursors/SizeNS"

local Class = {}
Class.__index = Class

type VerticallyResizableListFrame = Types.VerticallyResizableListFrame

type Config = {
	InitialHeight: number?,
	MinimumHeight: number?,
	MaximumHeight: number?,
	HeightLocked: boolean?
}

function Class.new(Data: Config, Children: {Types.WidgetBase}?): VerticallyResizableListFrame
	local self = (setmetatable({}, Class) :: never) :: VerticallyResizableListFrame

	self.MaximumHeight = Data.MaximumHeight or 300
	self.MinimumHeight = Data.MinimumHeight or 100

	self.Resized = Signal.new()
	self.WidgetParent = nil
	self.SizeLocked = Data.HeightLocked or false

	local Frame = Instance.new('Frame')
	Frame.Name = 'VRLFrame'
	Frame.Size = UDim2.new(1, 0, 0, 0)
	Frame.BackgroundTransparency = 0
	Frame.BorderSizePixel = 0
	GuiUtilities.SyncGuiElementBackgroundColor(Frame)

	self.Frame = Frame

	local UiListLayout = Instance.new('UIListLayout')
	UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UiListLayout.Parent = Frame
	self.UiListLayout = UiListLayout

	local ResizeLine = Instance.new("ImageButton")
	ResizeLine.Name = "VRLFrameResizeLine"
	ResizeLine.Size = UDim2.new(1, 0, 0, RESIZE_LINE_THICKNESS)
	ResizeLine.Position = UDim2.new(0, 0, 1, -RESIZE_LINE_THICKNESS)
	ResizeLine.Image = ""
	ResizeLine.AutoButtonColor = false
	ResizeLine.BorderSizePixel = 0
	ResizeLine.LayoutOrder = 9000
	ResizeLine.Parent = Frame
	GuiUtilities.SyncGuiElementStripeColor(ResizeLine)

	local function UpdateSizes(NewSize: number)
		NewSize = math.max(math.min(NewSize, self.MaximumHeight), self.MinimumHeight)
		self.Frame.Size = UDim2.new(1, 0, 0, NewSize - RESIZE_LINE_THICKNESS)
		self.Resized:Fire(NewSize)
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

	ResizeLine.InputBegan:Connect(function(Input)
		if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if self.SizeLocked or not self.WidgetParent then return end
		local EndCon
		local Ended = false
		EndCon = ResizeLine.InputEnded:Connect(function(EndInput)
			if EndInput.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			Ended = true
			EndCon:Disconnect()
		end)
		MouseIsDragging = true
		local MPos = self.WidgetParent:GetRelativeMousePosition()
		local Offset = MPos.Y - ResizeLine.AbsolutePosition.Y
		while not Ended do
			MPos = self.WidgetParent:GetRelativeMousePosition()
			local NewPos = MPos.Y - Frame.AbsolutePosition.Y - Offset
			UpdateSizes(NewPos)
			RunService.RenderStepped:Wait()
		end
		MouseIsDragging = false
	end)
	UpdateSizes(Data.InitialHeight or self.MaximumHeight)

	Frame.AncestryChanged:Connect(function()
		self.WidgetParent = Frame:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
	end)

	self.ChildCount = 0

	local Children: {Types.WidgetBase} = Children or {}

	for _, Child in pairs(Children) do
		if not Child.GetFrame then continue end
		self:AddChild(Child.GetFrame(Child))
	end

	return self
end

function Class:AddBottomPadding()
	local self = self :: VerticallyResizableListFrame

	local Frame = Instance.new("Frame")
	Frame.Name = "BottomPadding"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 0, BOTTOM_PADDING)
	Frame.LayoutOrder = 1000
	Frame.Parent = self.Frame
end

function Class:GetFrame()
	local self = self :: VerticallyResizableListFrame

	return self.Frame
end

function Class:AddChild(Child: Instance)
	local self = self :: VerticallyResizableListFrame

	if Child:IsA("GuiObject") then
		Child.LayoutOrder = self.ChildCount
		self.ChildCount = self.ChildCount + 1
	end

	Child.Parent = self:GetFrame()
	return Child
end

function Class:SetLocked(Locked: boolean)
	local self = self :: VerticallyResizableListFrame

	self.SizeLocked = Locked
end

return Class
