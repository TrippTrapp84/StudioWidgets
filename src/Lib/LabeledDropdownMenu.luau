----------------------------------------
--
-- DropdownMenu.lua
--
-- Creates dropdown-style selection menu.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local DEFAULT_LENGTH = 189
local DEFAULT_EXPAND_TIME = 0.15

local Class = {}
Class.__index = Class

type DropdownOption = Types.DropdownOption
type LabeledDropdownMenu = Types.LabeledDropdownMenu

type Config = {
	Title: string,
	Inset: number?,
	Options: {DropdownOption}?
}

function Class.new(Data: Config): LabeledDropdownMenu
	local self = (setmetatable({}, Class) :: never) :: LabeledDropdownMenu

	self.Title = Data.Title
	self.Inset = Data.Inset or 0
	self.Options = Data.Options or {}

	self.DropdownButtonHeight = GuiUtilities.TitleBarHeight -- should be 27
	self.ExpandedSize = 0

	self.SelectionChanged = Signal.new()

	local Section = GuiUtilities.MakeStandardFixedHeightFrame('DMSection')
	self.SectionFrame = Section

	local Label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	Label.Parent = Section

	local Button = Instance.new("TextButton")
	Button.Text = "Select an option"
	Button.Size = UDim2.new(0, 100, 0.6, 0)
	Button.AnchorPoint = Vector2.new(0, 0.5)
	Button.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, 0.5, 0)
	Button.Parent = Section
	GuiUtilities.SyncGuiElementBorderColor(Button)
	GuiUtilities.SyncGuiElementInputFieldColor(Button)
	GuiUtilities.SyncGuiElementFontColor(Button)

	local InvisFrame = Instance.new("Frame")
	InvisFrame.Size = UDim2.new(1, 0, 0, 0)
	InvisFrame.AnchorPoint = Vector2.new(0.5, 0)
	InvisFrame.Position = UDim2.new(0.5, 0, 1, 0)
	InvisFrame.BackgroundTransparency = 1
	InvisFrame.ClipsDescendants = true
	InvisFrame.Parent = Button

	local ContentsFrame = Instance.new("ScrollingFrame")
	ContentsFrame.CanvasSize = UDim2.new(1, 0, 0, 0)
	ContentsFrame.ScrollBarThickness = 0
	ContentsFrame.Size = UDim2.new(1, -2, 0, self.ExpandedSize)
	ContentsFrame.AnchorPoint = Vector2.new(0.5, 0)
	ContentsFrame.Position = UDim2.new(0.5, 0, 0, 0)
	ContentsFrame.BorderSizePixel = 1
	ContentsFrame.ZIndex = 9
	ContentsFrame.Parent = InvisFrame
	GuiUtilities.SyncGuiElementInputFieldColor(ContentsFrame)
	GuiUtilities.SyncGuiElementBorderColor(ContentsFrame)

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.FillDirection = Enum.FillDirection.Vertical
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	ListLayout.SortOrder = Enum.SortOrder.Name
	ListLayout.Parent = ContentsFrame

	self.TitleLabel = Label
	self.DropButton = Button
	self.ContentsFrame = ContentsFrame
	self.InvisFrame = InvisFrame
	self.ButtonArray = {}
	self.Selected = ""
	self.Expanded = false
	self.DropdownDB = false

	self.DropButton.MouseButton1Click:Connect(function()
		if self.DropdownDB then return end
		self.DropdownDB = true
		self:ToggleExpand()
	end)

	self.DropButton.MouseButton2Click:Connect(function()
		if self.DropdownDB then return end
		self.DropdownDB = true
		self:Retract()
		self:ResetChoice()
	end)

	self:AddSelectionsFromTable(self.Options)

	return self
end

function Class:ToggleExpand()
	local self = self :: LabeledDropdownMenu

	-- get the widget
	local Widget = self.InvisFrame:FindFirstAncestorOfClass("DockWidgetPluginGui")
	if Widget then
		-- now test if the bottom of the frame is below the absolute size of the widget
		local AbsAdded = self.ContentsFrame.AbsolutePosition.Y + self.ContentsFrame.AbsoluteSize.Y

		local BoundingPos, BoundingSize = GuiUtilities.GetAncestralBoundingBox(self.InvisFrame)

		if not self.Expanded then
			print(AbsAdded, BoundingPos.Y + BoundingSize.Y)
			if AbsAdded >= BoundingPos.Y + BoundingSize.Y then
				self.ContentsFrame.AnchorPoint = Vector2.new(0.5, 1)
				self.ContentsFrame.Position = UDim2.new(0.5, 0, 1, 0)
				self.InvisFrame.AnchorPoint = Vector2.new(0.5, 1)
				self.InvisFrame.Position = UDim2.new(0.5, 0, 0, 0)
			else
				self.ContentsFrame.AnchorPoint = Vector2.new(0.5, 0)
				self.ContentsFrame.Position = UDim2.new(0.5, 0, 0, 0)
				self.InvisFrame.AnchorPoint = Vector2.new(0.5, 0)
				self.InvisFrame.Position = UDim2.new(0.5, 0, 1, 0)
			end
		end
	end

	if self.Expanded then
		self:Retract()
		self.Expanded = false
	else
		self:Expand()
		self.Expanded = true
	end
end

function Class:Retract()
	local self = self :: LabeledDropdownMenu

	self.InvisFrame:TweenSize(UDim2.new(1, 2, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, DEFAULT_EXPAND_TIME, true, function()
		wait(DEFAULT_EXPAND_TIME)
		self.DropdownDB = false
		self.ContentsFrame.AnchorPoint = Vector2.new(0.5, 0)
		self.ContentsFrame.Position = UDim2.new(0.5, 0, 0, 0)
		self.InvisFrame.AnchorPoint = Vector2.new(0.5, 0)
		self.InvisFrame.Position = UDim2.new(0.5, 0, 1, 0)
	end)
	self.Expanded = false
end

function Class:Expand()
	local self = self :: LabeledDropdownMenu

	self.InvisFrame:TweenSize(UDim2.new(1, 2, 0, self.ExpandedSize + 2), Enum.EasingDirection.In, Enum.EasingStyle.Quad, DEFAULT_EXPAND_TIME, true, function()
		wait(DEFAULT_EXPAND_TIME)
		self.DropdownDB = false
	end)
	self.Expanded = true
end

function Class:AddSelection(Selection: DropdownOption)
	local self = self :: LabeledDropdownMenu

	local Id = Selection.Identifier or Selection.Name
	if self.ButtonArray[Id] then -- if the selection already exists
		return warn("There is already a selection with identifier: " .. Id)
	end

	local Button = Instance.new("TextButton")
	Button.Name = Id
	Button.Text = Selection.Name
	Button.Size = UDim2.new(1, 0, 0, self.DropdownButtonHeight)
	Button.BackgroundTransparency = 1
	Button.ZIndex = 10
	Button.Parent = self.ContentsFrame
	GuiUtilities.SyncGuiElementFontColor(Button)

	local function ActivateButton(InternalTrigger: boolean?)
		self.Selected = Selection.Value
		self.DropButton.Text = Selection.Name
		self:Retract()
		self.SelectionChanged:Fire(self.Selected, InternalTrigger or false)
	end

	local Connection = Button.MouseButton1Click:Connect(ActivateButton)

	self.ButtonArray[Id] = {Button = Button, Connection = Connection, Activate = ActivateButton}

	-- change ContentsFrame size. Remember to do this at the end next time.
	self:UpdateSize()
end

function Class:RemoveSelection(Identifier: string)
	local self = self :: LabeledDropdownMenu

	if self.ButtonArray[Identifier] then
		self.ButtonArray[Identifier].Connection:Disconnect()
		self.ButtonArray[Identifier].Button:Destroy()
		self.ButtonArray[Identifier] = nil
		self:UpdateSize() -- resize frame
	end
end

function Class:AddSelectionsFromTable(SelectionTable: {DropdownOption})
	local self = self :: LabeledDropdownMenu

	assert(type(SelectionTable) == "table", "Expected table. Got " .. type(SelectionTable))

	for I, V in pairs(SelectionTable) do
		if type(V) == "table" then
			self:AddSelection(V)
		end
	end
end

function Class:ResetChoice()
	local self = self :: LabeledDropdownMenu

	self.Selected = ""
	self.DropButton.Text = "Select an option"
end

function Class:SetChoice(Id: string)
	local self = self :: LabeledDropdownMenu

	if self.ButtonArray[Id] then
		self.ButtonArray[Id].Activate(true)
	end
end

function Class:GetChoice()
	local self = self :: LabeledDropdownMenu

	return self.Selected
end

function Class:GetFrame()
	local self = self :: LabeledDropdownMenu

	return self.SectionFrame
end

function Class:ChangeLabel(LabelText: string)
	local self = self :: LabeledDropdownMenu

	assert(type(LabelText) == "string", "Expected string. Got " .. type(LabelText))
	self.TitleLabel.Text = LabelText
end

function Class:UpdateSize()
	local self = self :: LabeledDropdownMenu

	local Count = 0
	for _, V in pairs(self.ButtonArray) do
		Count += 1
	end
	if Count >= 7 then
		self.CanvasSize = Count * self.DropdownButtonHeight
		self.ExpandedSize = DEFAULT_LENGTH
		self.ContentsFrame.CanvasSize = UDim2.new(1, -2, 0, self.CanvasSize)
		self.ContentsFrame.Size = UDim2.new(1, -2, 0, self.ExpandedSize)
		if self.Expanded then
			self.InvisFrame:TweenSize(UDim2.new(1, 2, 0, self.ExpandedSize), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
		end
	else
		self.CanvasSize = Count * self.DropdownButtonHeight
		self.ExpandedSize = Count * self.DropdownButtonHeight
		self.ContentsFrame.CanvasSize = UDim2.new(1, -2, 0, self.CanvasSize)
		self.ContentsFrame.Size = UDim2.new(1, -2, 0, self.ExpandedSize)
		if self.Expanded then
			self.InvisFrame:TweenSize(UDim2.new(1, 2, 0, self.ExpandedSize), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
		end
	end
end

--// RETURN
return Class
