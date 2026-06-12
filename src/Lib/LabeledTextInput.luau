----------------------------------------
--
-- LabeledTextInput.lua
--
-- Creates a frame containing a label and a text input control.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local TEXTBOX_INTERNAL_PADDING = 4

local Class = {}
Class.__index = Class

type LabeledTextInput = Types.LabeledTextInput

type Config = {
	Title: string,
	InitialValue: string?,
	Width: number?,
	Inset: number?
}

function Class.new(Data: Config): LabeledTextInput
	local self = (setmetatable({}, Class) :: never) :: LabeledTextInput

	self.Title = Data.Title
	self.InitialValue = Data.InitialValue or ""
	self.Width = Data.Width or 100
	self.Inset = Data.Inset or 0

	self.MaxGraphemes = 10

	self.ValueChanged = Signal.new()
	self.FocusLost = Signal.new()

	local Frame = GuiUtilities.MakeStandardFixedHeightFrame('TextInput ')
	self.Frame = Frame

	local Label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	Label.Parent = Frame
	self.Label = Label

	self.Value = self.InitialValue

	-- Dumb hack to add padding to text box,
	local TextBoxWrapperFrame = Instance.new("Frame")
	TextBoxWrapperFrame.Name = "Wrapper"
	TextBoxWrapperFrame.Size = UDim2.new(0, self.Width, 0.6, 0)
	TextBoxWrapperFrame.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, .5, 0)
	TextBoxWrapperFrame.AnchorPoint = Vector2.new(0, .5)
	TextBoxWrapperFrame.Parent = Frame
	GuiUtilities.SyncGuiElementInputFieldColor(TextBoxWrapperFrame)
	GuiUtilities.SyncGuiElementBorderColor(TextBoxWrapperFrame)

	local TextBox = Instance.new("TextBox")
	TextBox.Parent = TextBoxWrapperFrame
	TextBox.Name = "TextBox"
	TextBox.Text = self.InitialValue
	TextBox.Font = Enum.Font.SourceSans
	TextBox.TextSize = 15
	TextBox.BackgroundTransparency = 1
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.Size = UDim2.new(1, -TEXTBOX_INTERNAL_PADDING, 1, GuiUtilities.TextVerticalFudge)
	TextBox.Position = UDim2.new(0, TEXTBOX_INTERNAL_PADDING, 0, 0)
	TextBox.ClipsDescendants = true

	GuiUtilities.SyncGuiElementFontColor(TextBox)

	TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		-- Never let the text be too long.
		-- Careful here: we want to measure number of graphemes, not characters,
		-- in the text, and we want to clamp on graphemes as well.
		if (utf8.len(self.TextBox.Text) > self.MaxGraphemes) then
			local Count = 0
			for Start, Stop in utf8.graphemes(self.TextBox.Text) do
				Count = Count + 1
				if (Count > self.MaxGraphemes) then
					-- We have gone one too far.
					-- clamp just before the beginning of this grapheme.
					self.TextBox.Text = string.sub(self.TextBox.Text, 1, Start-1)
					break
				end
			end
			-- Don't continue with rest of function: the resetting of "Text" field
			-- above will trigger re-entry.  We don't need to trigger value
			-- changed function twice.
			return
		end

		self.Value = self.TextBox.Text
		self.ValueChanged:Fire(self.Value)
	end)

	TextBox.FocusLost:Connect(function()
		self.FocusLost:Fire(self.Value)
	end)

	self.TextBox = TextBox

	return self
end

function Class:GetFrame()
	local self = self :: LabeledTextInput

	return self.Frame
end

function Class:GetValue()
	local self = self :: LabeledTextInput

	return self.Value
end

function Class:GetMaxGraphemes()
	local self = self :: LabeledTextInput

	return self.MaxGraphemes
end

function Class:SetMaxGraphemes(NewValue: number)
	local self = self :: LabeledTextInput

	self.MaxGraphemes = NewValue
end

function Class:SetValue(NewValue: string)
	local self = self :: LabeledTextInput

	if self.Value ~= NewValue then
		self.TextBox.Text = NewValue
	end
end

return Class
