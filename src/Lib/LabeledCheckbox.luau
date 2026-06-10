----------------------------------------
--
-- LabeledCheckbox.lua
--
-- Creates a frame containing a label and a checkbox.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local CHECKBOX_WIDTH = GuiUtilities.kCheckboxWidth

local MIN_TEXT_SIZE = 14
local MIN_HEIGHT = 24
local MIN_LABEL_WIDTH = GuiUtilities.kCheckboxMinLabelWidth
local MIN_MARGIN = GuiUtilities.kCheckboxMinMargin
local MIN_BUTTON_WIDTH = CHECKBOX_WIDTH;

local MIN_LABEL_SIZE = UDim2.new(0, MIN_LABEL_WIDTH, 0, MIN_HEIGHT)
local MIN_LABEL_POS = UDim2.new(0, MIN_BUTTON_WIDTH + MIN_MARGIN, 0, MIN_HEIGHT/2)

local MIN_BUTTON_SIZE = UDim2.new(0, MIN_BUTTON_WIDTH, 0, MIN_BUTTON_WIDTH)
local MIN_BUTTON_POSITION = UDim2.new(0, 0, 0, MIN_HEIGHT/2)

local CHECK_IMAGE_WIDTH = 8
local MIN_CHECK_IMAGE_WIDTH = CHECK_IMAGE_WIDTH

local CHECK_IMAGE_SIZE = UDim2.new(0, CHECK_IMAGE_WIDTH, 0, CHECK_IMAGE_WIDTH)
local MIN_CHECK_IMAGE_SIZE = UDim2.new(0, MIN_CHECK_IMAGE_WIDTH, 0, MIN_CHECK_IMAGE_WIDTH)
local MIN_FRAME_SIZE = UDim2.new(0, MIN_LABEL_WIDTH + MIN_MARGIN + MIN_BUTTON_WIDTH, 0, MIN_HEIGHT)

local ENABLED_CHECK_IMAGE = "rbxasset://textures/TerrainTools/icon_tick.png"
local DISABLED_CHECK_IMAGE = "rbxasset://textures/TerrainTools/icon_tick_grey.png"
local CHECKBOX_FRAME_IMAGE = "rbxasset://textures/TerrainTools/checkbox_square.png"

local Class = {}
Class.__index = Class

Class.MIN_FRAME_SIZE = UDim2.new(0, MIN_LABEL_WIDTH + MIN_MARGIN + MIN_BUTTON_WIDTH, 0, MIN_HEIGHT)

type Config = {
	Title: string,
	InitialValue: boolean?,
	Disabled: boolean?,
	Inset: number?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.InitialValue = Data.InitialValue or false
	self.Disabled = Data.Disabled or false
	self.Inset = Data.Inset or 0

	local frame = GuiUtilities.MakeStandardFixedHeightFrame("CBF")

	local fullBackgroundButton = Instance.new("TextButton")
	fullBackgroundButton.Name = "FullBackground"
	fullBackgroundButton.Parent = frame
	fullBackgroundButton.BackgroundTransparency = 1
	fullBackgroundButton.Size = UDim2.new(1, 0, 1, 0)
	fullBackgroundButton.Position = UDim2.new(0, 0, 0, 0)
	fullBackgroundButton.Text = ""

	local label = GuiUtilities.MakeStandardPropertyLabel(self.Title, true)
	label.Parent = fullBackgroundButton

	local button = Instance.new('ImageButton')
	button.Name = 'Button'
	button.Size = UDim2.new(0, CHECKBOX_WIDTH, 0, CHECKBOX_WIDTH)
	button.AnchorPoint = Vector2.new(0, .5)
	button.BackgroundTransparency = 0
	button.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, .5, 0)
	button.Parent = fullBackgroundButton
	button.Image = CHECKBOX_FRAME_IMAGE
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	
	local checkImage = Instance.new("ImageLabel")
	checkImage.Name = "CheckImage"
	checkImage.Parent = button
	checkImage.Image = ENABLED_CHECK_IMAGE
	checkImage.Visible = false
	checkImage.Size = CHECK_IMAGE_SIZE
	checkImage.AnchorPoint = Vector2.new(0.5, 0.5)
	checkImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	checkImage.BackgroundTransparency = 1
	checkImage.BorderSizePixel = 0

	self._frame = frame
	self._button = button
	self._label = label
	self._checkImage = checkImage
	self._fullBackgroundButton = fullBackgroundButton
	self._useDisabledOverride = false
	self._disabledOverride = false
	self:SetDisabled(self.Disabled)

	self._value = not self.InitialValue
	self:SetValue(self.InitialValue)

	self:_SetupMouseClickHandling()

	local function updateFontColors()
		self:UpdateFontColors()
	end
	settings().Studio.ThemeChanged:Connect(updateFontColors)
	updateFontColors()

	return self
end


function Class:_MaybeToggleState(Internal)
	if not self._disabled then
		self:SetValue(not self._value,Internal)
	end
end

function Class:_SetupMouseClickHandling()
	self._button.MouseButton1Down:Connect(function()
		self:_MaybeToggleState(true)
	end)

	self._fullBackgroundButton.MouseButton1Down:Connect(function()
		self:_MaybeToggleState(true)
	end)
end

function Class:_HandleUpdatedValue(InternalTrigger)
	self._checkImage.Visible = self:GetValue()

	if (self._valueChangedFunction) then 
		self._valueChangedFunction(self:GetValue(),InternalTrigger)
	end
end

-- Small checkboxes are a different entity.
-- All the bits are smaller.
-- Fixed width instead of flood-fill.
-- Box comes first, then label.
function Class:UseSmallSize()
	self._label.TextSize = MIN_TEXT_SIZE
	self._label.Size = MIN_LABEL_SIZE
	self._label.Position = MIN_LABEL_POS
	self._label.TextXAlignment = Enum.TextXAlignment.Left

	self._button.Size = MIN_BUTTON_SIZE    
	self._button.Position = MIN_BUTTON_POSITION

	self._checkImage.Size = MIN_CHECK_IMAGE_SIZE

	self._frame.Size = Class.MIN_FRAME_SIZE
	self._frame.BackgroundTransparency = 1
end

function Class:GetFrame()
	return self._frame
end

function Class:GetValue()
	-- If button is disabled, and we should be using a disabled override, 
	-- use the disabled override.
	if (self._disabled and self._useDisabledOverride) then 
		return self._disabledOverride
	else
		return self._value
	end
end

function Class:GetLabel()
	return self._label
end

function Class:GetButton()
	return self._button
end

function Class:SetValueChangedFunction(vcFunction) 
	self._valueChangedFunction = vcFunction
end

function Class:SetDisabled(newDisabled)
	newDisabled = not not newDisabled

	local originalValue = self:GetValue()

	if newDisabled ~= self._disabled then
		self._disabled = newDisabled

		-- if we are no longer disabled, then we don't need or want 
		-- the override any more.  Forget it.
		if (not self._disabled) then 
			self._useDisabledOverride = false
		end

		if (newDisabled) then 
			self._checkImage.Image = DISABLED_CHECK_IMAGE
		else
			self._checkImage.Image = ENABLED_CHECK_IMAGE
		end

		self:UpdateFontColors()
		self._button.BackgroundColor3 = self._disabled and GuiUtilities.kButtonDisabledBackgroundColor or GuiUtilities.kButtonStandardBackgroundColor
		self._button.BorderColor3 = self._disabled and GuiUtilities.kButtonDisabledBorderColor or GuiUtilities.kButtonStandardBorderColor
		if self._disabledChangedFunction then
			self._disabledChangedFunction(self._disabled)
		end
	end

	local newValue = self:GetValue()
	if (newValue ~= originalValue) then 
		self:_HandleUpdatedValue()
	end
end

function Class:UpdateFontColors()
	if self._disabled then 
		self._label.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.DimmedText)
	else
		self._label.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	end
end

function Class:DisableWithOverrideValue(overrideValue)
	-- Disable this checkbox.  While disabled, force value to override
	-- value.
	local oldValue = self:GetValue()
	self._useDisabledOverride = true
	self._disabledOverride = overrideValue
	self:SetDisabled(true)
	local newValue = self:GetValue()
	if (oldValue ~= newValue) then 
		self:_HandleUpdatedValue()
	end		
end

function Class:GetDisabled()
	return self._disabled
end

function Class:SetValue(newValue,Internal)
	newValue = not not newValue
	
	if newValue ~= self._value then
		self._value = newValue

		self:_HandleUpdatedValue(not Internal)
	end
end

--// RETURN
return Class