----------------------------------------
--
-- LabeledTextInput.lua
--
-- Creates a frame containing a label and a text input control.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local TEXTBOX_INTERNAL_PADDING = 4

local Class = {}
Class.__index = Class

type Config = {
	Title: string,
	InitialValue: string?,
	Width: number?,
	Inset: number?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.InitialValue = Data.InitialValue or ""
	self.Width = Data.Width or 100
	self.Inset = Data.Inset or 0

	self._MaxGraphemes = 10
	
	self._valueChangedFunction = nil
	self._focusLostFunction = nil

	local frame = GuiUtilities.MakeStandardFixedHeightFrame('TextInput ')
	self._frame = frame

	local label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	label.Parent = frame
	self._label = label

	self._value = self.InitialValue

	-- Dumb hack to add padding to text box,
	local textBoxWrapperFrame = Instance.new("Frame")
	textBoxWrapperFrame.Name = "Wrapper"
	textBoxWrapperFrame.Size = UDim2.new(0, self.Width, 0.6, 0)
	textBoxWrapperFrame.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, .5, 0)
	textBoxWrapperFrame.AnchorPoint = Vector2.new(0, .5)
	textBoxWrapperFrame.Parent = frame
	GuiUtilities.syncGuiElementInputFieldColor(textBoxWrapperFrame)
	GuiUtilities.syncGuiElementBorderColor(textBoxWrapperFrame)

	local textBox = Instance.new("TextBox")
	textBox.Parent = textBoxWrapperFrame
	textBox.Name = "TextBox"
	textBox.Text = self.InitialValue
	textBox.Font = Enum.Font.SourceSans
	textBox.TextSize = 15
	textBox.BackgroundTransparency = 1
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Size = UDim2.new(1, -TEXTBOX_INTERNAL_PADDING, 1, GuiUtilities.kTextVerticalFudge)
	textBox.Position = UDim2.new(0, TEXTBOX_INTERNAL_PADDING, 0, 0)
	textBox.ClipsDescendants = true

	GuiUtilities.syncGuiElementFontColor(textBox)
	
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		-- Never let the text be too long.
		-- Careful here: we want to measure number of graphemes, not characters, 
		-- in the text, and we want to clamp on graphemes as well.
		if (utf8.len(self._textBox.Text) > self._MaxGraphemes) then 
			local count = 0
			for start, stop in utf8.graphemes(self._textBox.Text) do
				count = count + 1
				if (count > self._MaxGraphemes) then 
					-- We have gone one too far.
					-- clamp just before the beginning of this grapheme.
					self._textBox.Text = string.sub(self._textBox.Text, 1, start-1)
					break
				end
			end
			-- Don't continue with rest of function: the resetting of "Text" field
			-- above will trigger re-entry.  We don't need to trigger value
			-- changed function twice.
			return
		end

		self._value = self._textBox.Text
		if (self._valueChangedFunction) then 
			self._valueChangedFunction(self._value)
		end
	end)

	textBox.FocusLost:Connect(function()
		if self._focusLostFunction then
			self._focusLostFunction(self._value)
		end
	end)
	
	self._textBox = textBox

	return self
end

function Class:SetValueChangedFunction(vcf)
	self._valueChangedFunction = vcf
end

function Class:SetFocusLostFunction(flf)
	self._focusLostFunction = flf
end

function Class:GetFrame()
	return self._frame
end

function Class:GetValue()
	return self._value
end

function Class:GetMaxGraphemes()
	return self._MaxGraphemes
end

function Class:SetMaxGraphemes(newValue)
	self._MaxGraphemes = newValue
end

function Class:SetValue(newValue)
	if self._value ~= newValue then
		self._textBox.Text = newValue
	end
end

return Class