----------------------------------------
--
-- LabeledTextInput.lua
--
-- Creates a frame containing a label and a text input control.
--
----------------------------------------
local plugin = _G.StudioWidgetsPluginGlobalDistributorObject

local GuiUtilities = require(script.Parent.GuiUtilities)

local kTextInputWidth = 100
local kTextBoxInternalPadding = 4

local LabeledTextInputClass = {}
LabeledTextInputClass.__index = LabeledTextInputClass

function LabeledTextInputClass.new(nameSuffix, defaultValue,XInset,ClearOnFocus)
	local Obj = {}
	setmetatable(Obj, LabeledTextInputClass)

	-- Note: we are using "graphemes" instead of characters.
	-- In modern text-manipulation-fu, what with internationalization, 
	-- emojis, etc, it's not enough to count characters, particularly when 
	-- concerned with "how many <things> am I rendering?".
	-- We are using the 
	Obj._MaxGraphemes = 10
	
	Obj._valueChangedFunction = nil
	Obj._focusLostFunction = nil

	local defaultValue = defaultValue or ""

	local frame = GuiUtilities.MakeStandardFixedHeightFrame('TextInput ' .. nameSuffix)
	Obj._frame = frame

	--local label = GuiUtilities.MakeStandardPropertyLabel(labelText)
	--label.Parent = frame
	--self._label = label

	Obj._value = defaultValue

	-- Dumb hack to add padding to text box,
	local textBoxWrapperFrame = Instance.new("Frame")
	textBoxWrapperFrame.Name = "Wrapper"
	textBoxWrapperFrame.Size = UDim2.new(0, kTextInputWidth, 0.6, 0)
	textBoxWrapperFrame.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + (XInset or 0), .5, 0)
	textBoxWrapperFrame.AnchorPoint = Vector2.new(0, .5)
	textBoxWrapperFrame.Parent = frame
	textBoxWrapperFrame.BorderSizePixel = 0
	textBoxWrapperFrame.BackgroundTransparency = 0.9
	GuiUtilities.syncGuiElementInputFieldColor(textBoxWrapperFrame)

	local textBox = Instance.new("TextBox")
	textBox.Parent = textBoxWrapperFrame
	textBox.Name = "TextBox"
	textBox.Text = defaultValue
	textBox.Font = Enum.Font.SourceSans
	textBox.ClearTextOnFocus = ClearOnFocus and true or false
	textBox.TextSize = 15
	textBox.BackgroundTransparency = 1
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Size = UDim2.new(1, -kTextBoxInternalPadding, 1, GuiUtilities.kTextVerticalFudge)
	textBox.Position = UDim2.new(0, 0, 0, 0)
	textBox.ClipsDescendants = true
	Obj._textBox = textBox

	GuiUtilities.syncGuiElementFontColor(textBox)
	
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		-- Never let the text be too long.
		-- Careful here: we want to measure number of graphemes, not characters, 
		-- in the text, and we want to clamp on graphemes as well.
		if (utf8.len(Obj._textBox.Text) > Obj._MaxGraphemes) then 
			local count = 0
			for start, stop in utf8.graphemes(Obj._textBox.Text) do
				count = count + 1
				if (count > Obj._MaxGraphemes) then 
					-- We have gone one too far.
					-- clamp just before the beginning of this grapheme.
					Obj._textBox.Text = string.sub(Obj._textBox.Text, 1, start-1)
					break
				end
			end
			-- Don't continue with rest of function: the resetting of "Text" field
			-- above will trigger re-entry.  We don't need to trigger value
			-- changed function twice.
			return
		end

		Obj._value = Obj._textBox.Text
		if (Obj._valueChangedFunction) then 
			Obj._valueChangedFunction(Obj._value)
		end
	end)
	
	textBox.FocusLost:Connect(function()
		if Obj._focusLostFunction then
			Obj._focusLostFunction(Obj._value)
		end
	end)
	

	return Obj
end

function LabeledTextInputClass:SetValueChangedFunction(vcf)
	self._valueChangedFunction = vcf
end

function LabeledTextInputClass:SetFocusLostFunction(flf)
	self._focusLostFunction = flf
end

function LabeledTextInputClass:GetFrame()
	return self._frame
end

function LabeledTextInputClass:GetValue()
	return self._value
end

function LabeledTextInputClass:GetMaxGraphemes()
	return self._MaxGraphemes
end

function LabeledTextInputClass:SetMaxGraphemes(newValue)
	local Diff = newValue - self._MaxGraphemes
	self._MaxGraphemes = newValue
	self._frame.Wrapper.TextBox.Size += UDim2.fromOffset(Diff * 15,0)
end

function LabeledTextInputClass:SetValue(newValue)
	if self._value ~= newValue then
		self._textBox.Text = newValue
	end
end

--// RETURN
return LabeledTextInputClass