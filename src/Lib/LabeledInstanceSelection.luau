----------------------------------------
--
-- LabeledInstanceSelection.lua
--
-- Creates an instance selection box complete with icon change
--
----------------------------------------
local Selection = game:GetService("Selection")
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local TEXTBOX_INTERNAL_PADDING = 4

local Class = {}
Class.__index = Class

type Config = {
    Title: string,
    Inset: number?,
    Width: number?,
    InitialValue: Instance?
}

function Class.new(Data: Config)
    local self = setmetatable({}, Class)

    self.Title = Data.Title
    self.Inset = Data.Inset or 0
    self.Width = Data.Width or 75
    self.InitialValue = Data.InitialValue

    self._SelectionChangedFunction = nil

    local frame, frameThemeConnection = GuiUtilities.MakeStandardFixedHeightFrame('TextInput ')
	self._frame = frame

	local label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	label.Parent = frame
	self._label = label

	self._value = self.InitialValue

	-- Dumb hack to add padding to text box,
	local textBoxWrapperFrame = Instance.new("Frame")
	textBoxWrapperFrame.Name = "Wrapper"
	textBoxWrapperFrame.Size = UDim2.new(0, self.Width, 0.6, 0)
	textBoxWrapperFrame.Position = UDim2.new(0,self.Inset + GuiUtilities.StandardLineElementLeftMargin, .5, 0)
	textBoxWrapperFrame.AnchorPoint = Vector2.new(0, .5)
	textBoxWrapperFrame.Parent = frame
	GuiUtilities.syncGuiElementInputFieldColor(textBoxWrapperFrame)
	GuiUtilities.syncGuiElementBorderColor(textBoxWrapperFrame)

	local textBox = Instance.new("TextButton")
	textBox.Parent = textBoxWrapperFrame
	textBox.Name = "TextButton"
	textBox.Text = if self.InitialValue then self.InitialValue:GetFullName() else ""
	textBox.Font = Enum.Font.SourceSans
	textBox.TextSize = 15
	textBox.BackgroundTransparency = 1
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Size = UDim2.new(1, -TEXTBOX_INTERNAL_PADDING, 1, GuiUtilities.kTextVerticalFudge)
	textBox.Position = UDim2.new(0, TEXTBOX_INTERNAL_PADDING, 0, 0)
	textBox.ClipsDescendants = true
    self._textBox = textBox

    local CurrentTextBoxColor = textBox.BackgroundColor3

	GuiUtilities.syncGuiElementFontColor(textBox)

    local SelectionActive = false
    local SelectionConnection
    textBox.Activated:Connect(function()
        if SelectionActive then
            SelectionConnection:Disconnect()
            frameThemeConnection = GuiUtilities.syncGuiElementBackgroundColor(frame)
            textBoxWrapperFrame.BackgroundTransparency = 0
            SelectionActive = false
        else
            SelectionActive = true
            frameThemeConnection:Disconnect()
            frame.BackgroundColor3 = GuiUtilities.FrameSelectionColor
            textBoxWrapperFrame.BackgroundTransparency = 0.75
            SelectionConnection = Selection.SelectionChanged:Connect(function()
                if #Selection:Get() ~= 1 then
                    self:SetSelection(false)
                else
                    self:SetSelection(Selection:Get()[1])
                end
                frameThemeConnection = GuiUtilities.syncGuiElementBackgroundColor(frame)
                textBoxWrapperFrame.BackgroundTransparency = 0
                SelectionConnection:Disconnect()
                SelectionActive = false
            end)
        end
    end)

    return self
end

function Class:SetSelection(Selected,ExternalTrigger)
    self._value = Selected
    self._textBox.Text = Selected and Selected:GetFullName() or ""
    if self._SelectionChangedFunction then
        self._SelectionChangedFunction(Selected, not ExternalTrigger)
    end
end

function Class:GetFrame()
    return self._frame
end

function Class:SetSelectionChangedFunction(scf)
    self._SelectionChangedFunction = scf
end

return Class