----------------------------------------
--
-- DropdownMenu.lua
--
-- Creates dropdown-style selection menu.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local NULL = {}

local DEFAULT_LENGTH = 189
local DEFAULT_EXPAND_TIME = 0.15

local Class = {}
Class.__index = Class

local function DefaultValues()
	return {
		Suffix = NULL,
		LabelText = NULL,
		ButtonInset = 0,
		SelectionTable = {}
	}
end

type DropdownOption = {
	Name: string,
	Value: unknown,

	--[=[
		Generally not necessary, but if you need support for multiple dropdown options with the same display name it is required.

		The internal Id used to uniquely identify this option. If `Identifier == nil`, `Name` is used as the identifier instead
	]=]
	Identifier: string?
}

type Config = {
	Title: string,
	Inset: number?,
	Options: {DropdownOption}?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.Inset = Data.Inset or 0
	self.Options = Data.Options or {}

	self._dropdownButtonHeight = GuiUtilities.kTitleBarHeight -- should be 27
	self._expandedSize = 0
	
	self._SelectionChangedFunction = nil

	local section = GuiUtilities.MakeStandardFixedHeightFrame('DMSection')
	self._sectionFrame = section

	local label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	label.Parent = section


	local button = Instance.new("TextButton")
	button.Text = "Select an option"
	button.Size = UDim2.new(0, 100, 0.6, 0)
	button.AnchorPoint = Vector2.new(0,0.5)
	button.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, 0.5, 0)
	button.Parent = section
	GuiUtilities.syncGuiElementBorderColor(button)
	GuiUtilities.syncGuiElementInputFieldColor(button)
	GuiUtilities.syncGuiElementFontColor(button)

	local invisFrame = Instance.new("Frame")
	invisFrame.Size = UDim2.new(1,0,0,0)
	invisFrame.AnchorPoint = Vector2.new(0.5,0)
	invisFrame.Position = UDim2.new(0.5,0,1,0)
	invisFrame.BackgroundTransparency = 1
	invisFrame.ClipsDescendants = true
	invisFrame.Parent = button 


	local contentsFrame = Instance.new("ScrollingFrame")
	contentsFrame.CanvasSize = UDim2.new(1,0,0,0)
	contentsFrame.ScrollBarThickness = 0
	contentsFrame.Size = UDim2.new(1,-2,0,self._expandedSize)
	contentsFrame.AnchorPoint = Vector2.new(0.5,0)
	contentsFrame.Position = UDim2.new(0.5,0,0,0)
	contentsFrame.BorderSizePixel = 1
	contentsFrame.ZIndex = 9
	contentsFrame.Parent = invisFrame
	GuiUtilities.syncGuiElementInputFieldColor(contentsFrame)
	GuiUtilities.syncGuiElementBorderColor(contentsFrame)

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Parent = contentsFrame


	self._titleLabel = label
	self._dropButton = button
	self._contentsFrame = contentsFrame
	self._invisFrame = invisFrame
	self._buttonArray = {}
	self._selected = ""
	self._expanded = false

	self._dropdownDB = false

	self._dropButton.MouseButton1Click:Connect(function()
		if self._dropdownDB then return end
		self._dropdownDB = true
		self:_toggleExpand()
	end)

	self._dropButton.MouseButton2Click:Connect(function()
		if self._dropdownDB then return end
		self._dropdownDB = true
		self:_retract()
		self:ResetChoice()
	end)

	self:AddSelectionsFromTable(self.Options)

	return self
end

function Class:SetSelectionChangedFunction(scf)
	self._SelectionChangedFunction = scf
end

function Class:_toggleExpand()
	-- get the widget
	local widget = self._invisFrame:FindFirstAncestorOfClass("DockWidgetPluginGui")
	if widget then
		-- now test if the bottom of the frame is below the absolute size of the widget
		local absAdded = self._contentsFrame.AbsolutePosition.Y + self._contentsFrame.AbsoluteSize.Y

		local BoundingPos,BoundingSize = GuiUtilities.GetAncestralBoundingBox(self._invisFrame)

		if not self._expanded then
			print(absAdded,BoundingPos.Y + BoundingSize.Y)
			if absAdded >= BoundingPos.Y + BoundingSize.Y then
				self._contentsFrame.AnchorPoint = Vector2.new(0.5,1)
				self._contentsFrame.Position = UDim2.new(0.5,0,1,0)
				self._invisFrame.AnchorPoint = Vector2.new(0.5,1)
				self._invisFrame.Position = UDim2.new(0.5,0,0,0)
			else
				self._contentsFrame.AnchorPoint = Vector2.new(0.5,0)
				self._contentsFrame.Position = UDim2.new(0.5,0,0,0)
				self._invisFrame.AnchorPoint = Vector2.new(0.5,0)
				self._invisFrame.Position = UDim2.new(0.5,0,1,0)
			end
		end
	end

	if self._expanded then
		self:_retract()
		self._expanded = false
	else
		self:_expand()
		self._expanded = true
	end
end

function Class:_retract()
	self._invisFrame:TweenSize(UDim2.new(1,2,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, DEFAULT_EXPAND_TIME, true,function()
		wait(DEFAULT_EXPAND_TIME)
		self._dropdownDB = false
		self._contentsFrame.AnchorPoint = Vector2.new(0.5,0)
		self._contentsFrame.Position = UDim2.new(0.5,0,0,0)
		self._invisFrame.AnchorPoint = Vector2.new(0.5,0)
		self._invisFrame.Position = UDim2.new(0.5,0,1,0)
	end)
	self._expanded = false
end

function Class:_expand()
	self._invisFrame:TweenSize(UDim2.new(1,2,0,self._expandedSize+2), Enum.EasingDirection.In, Enum.EasingStyle.Quad, DEFAULT_EXPAND_TIME, true,function()
		wait(DEFAULT_EXPAND_TIME)
		self._dropdownDB = false
	end)
	self._expanded = true
end

function Class:AddSelection(Selection: DropdownOption)
	local Id = Selection.Identifier or Selection.Name
	if self._buttonArray[Id] then -- if the selection already exists
		return warn("There is already a selection with identifier: ".. Id)
	end

	local button = Instance.new("TextButton")
	button.Name = Id
	button.Text = Selection.Name
	button.Size = UDim2.new(1,0,0,self._dropdownButtonHeight)
	button.BackgroundTransparency = 1
	button.ZIndex = 10
	button.Parent = self._contentsFrame
	GuiUtilities.syncGuiElementFontColor(button)
	
	local function ActivateButton(InternalTrigger)
		self._selected = Selection.Value
		self._dropButton.Text = Selection.Name
		self:_retract()
		if self._SelectionChangedFunction then
			self._SelectionChangedFunction(self._selected,InternalTrigger)
		end
	end

	local connection = button.MouseButton1Click:Connect(ActivateButton)

	self._buttonArray[Id] = {button = button, connection = connection,activate = ActivateButton}

	-- change contentsFrame size. Remember to do this at the end next time.
	self:_updateSize()
end

function Class:RemoveSelection(identifier)
	if self._buttonArray[identifier] then
		self._buttonArray[identifier].connection:Disconnect()
		self._buttonArray[identifier].button:Destroy()
		self._buttonArray[identifier] = nil
		self:_updateSize() -- resize frame
	end
end

function Class:AddSelectionsFromTable(selectionTable)
	assert(type(selectionTable) == "table", "Expected table. Got "..type(selectionTable))

	for i,v in pairs(selectionTable) do
		if type(v) == "table" then
			self:AddSelection(v)
		end
	end
end

function Class:ResetChoice()
	self._selected = ""
	self._dropButton.Text = "Select an option"
end

function Class:SetChoice(id)
	if self._buttonArray[id] then
		self._buttonArray[id].activate(true)
	end
end

function Class:GetChoice()
	return self._selected
end

function Class:GetSectionFrame()
	return self._sectionFrame
end

function Class:GetContentsFrame()
	return self._contentsFrame
end

function Class:ChangeLabel(labelText)
	assert(type(labelText) == "string", "Expected string. Got "..type(labelText))
	self._titleLabel.Text = labelText
end

function Class:_updateSize()
	local count = 0
	for _,v in pairs(self._buttonArray) do
		count += 1
	end
	if count >= 7 then
		self._canvasSize = count*self._dropdownButtonHeight
		self._expandedSize = DEFAULT_LENGTH
		self._contentsFrame.CanvasSize = UDim2.new(1,-2,0,self._canvasSize)
		self._contentsFrame.Size = UDim2.new(1,-2,0,self._expandedSize)
		if self._expanded then
			self._invisFrame:TweenSize(UDim2.new(1,2,0,self._expandedSize), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
		end
	else
		self._canvasSize = count*self._dropdownButtonHeight
		self._expandedSize = count*self._dropdownButtonHeight

		self._contentsFrame.CanvasSize = UDim2.new(1,-2,0,self._canvasSize)
		self._contentsFrame.Size = UDim2.new(1,-2,0,self._expandedSize)
		if self._expanded then
			self._invisFrame:TweenSize(UDim2.new(1,2,0,self._expandedSize), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
		end
	end

end

--// RETURN
return Class