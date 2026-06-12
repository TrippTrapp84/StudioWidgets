----------------------------------------
--
-- LabeledInstanceSelection.lua
--
-- Creates an instance selection box complete with icon change
--
----------------------------------------
local Selection = game:GetService("Selection")
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local TEXTBOX_INTERNAL_PADDING = 4

local Class = {}
Class.__index = Class

type LabeledInstanceSelection = Types.LabeledInstanceSelection

type Config = {
    Title: string,
    Inset: number?,
    Width: number?,
    InitialValue: Instance?
}

function Class.new(Data: Config): LabeledInstanceSelection
    local self = (setmetatable({}, Class) :: never) :: LabeledInstanceSelection

    self.Title = Data.Title
    self.Inset = Data.Inset or 0
    self.Width = Data.Width or 75
    self.InitialValue = Data.InitialValue

    self.SelectionChanged = Signal.new()

    local Frame, FrameThemeConnection = GuiUtilities.MakeStandardFixedHeightFrame('TextInput ')
	self.Frame = Frame

	local Label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	Label.Parent = Frame
	self.Label = Label

	self.Value = self.InitialValue

	-- Dumb hack to add padding to text box,
	local TextBoxWrapperFrame = Instance.new("Frame")
	TextBoxWrapperFrame.Name = "Wrapper"
	TextBoxWrapperFrame.Size = UDim2.new(0, self.Width, 0.6, 0)
	TextBoxWrapperFrame.Position = UDim2.new(0, self.Inset + GuiUtilities.StandardLineElementLeftMargin, .5, 0)
	TextBoxWrapperFrame.AnchorPoint = Vector2.new(0, .5)
	TextBoxWrapperFrame.Parent = Frame
	GuiUtilities.SyncGuiElementInputFieldColor(TextBoxWrapperFrame)
	GuiUtilities.SyncGuiElementBorderColor(TextBoxWrapperFrame)

	local TextBox = Instance.new("TextButton")
	TextBox.Parent = TextBoxWrapperFrame
	TextBox.Name = "TextButton"
	TextBox.Text = if self.InitialValue then self.InitialValue:GetFullName() else ""
	TextBox.Font = Enum.Font.SourceSans
	TextBox.TextSize = 15
	TextBox.BackgroundTransparency = 1
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.Size = UDim2.new(1, -TEXTBOX_INTERNAL_PADDING, 1, GuiUtilities.TextVerticalFudge)
	TextBox.Position = UDim2.new(0, TEXTBOX_INTERNAL_PADDING, 0, 0)
	TextBox.ClipsDescendants = true
    self.TextBox = TextBox

	GuiUtilities.SyncGuiElementFontColor(TextBox)

    local SelectionActive = false
    local SelectionConnection
    TextBox.Activated:Connect(function()
        if SelectionActive then
            SelectionConnection:Disconnect()
            FrameThemeConnection = GuiUtilities.SyncGuiElementBackgroundColor(Frame)
            TextBoxWrapperFrame.BackgroundTransparency = 0
            SelectionActive = false
        else
            SelectionActive = true
            FrameThemeConnection:Disconnect()
            Frame.BackgroundColor3 = GuiUtilities.FrameSelectionColor
            TextBoxWrapperFrame.BackgroundTransparency = 0.75
            SelectionConnection = Selection.SelectionChanged:Connect(function()
                if #Selection:Get() ~= 1 then
                    self:SetSelection(false)
                else
                    self:SetSelection(Selection:Get()[1])
                end
                FrameThemeConnection = GuiUtilities.SyncGuiElementBackgroundColor(Frame)
                TextBoxWrapperFrame.BackgroundTransparency = 0
                SelectionConnection:Disconnect()
                SelectionActive = false
            end)
        end
    end)

    return self
end

function Class:SetSelection(Selected: Instance | false, ExternalTrigger: boolean?)
    local self = self :: LabeledInstanceSelection

    self.Value = Selected or nil
    self.TextBox.Text = Selected and (Selected :: Instance):GetFullName() or ""
    self.SelectionChanged:Fire(self.Value, not (ExternalTrigger or false))
end

function Class:GetFrame()
    local self = self :: LabeledInstanceSelection

    return self.Frame
end

return Class
