----------------------------------------
--
-- LabeledCheckbox.lua
--
-- Creates a frame containing a label and a checkbox.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)

local CHECKBOX_WIDTH = GuiUtilities.CheckboxWidth

local MIN_TEXT_SIZE = 14
local MIN_HEIGHT = 24
local MIN_LABEL_WIDTH = GuiUtilities.CheckboxMinLabelWidth
local MIN_MARGIN = GuiUtilities.CheckboxMinMargin
local MIN_BUTTON_WIDTH = CHECKBOX_WIDTH;

local MIN_LABEL_SIZE = UDim2.new(0, MIN_LABEL_WIDTH, 0, MIN_HEIGHT)
local MIN_LABEL_POS = UDim2.new(0, MIN_BUTTON_WIDTH + MIN_MARGIN, 0, MIN_HEIGHT/2)

local MIN_BUTTON_SIZE = UDim2.new(0, MIN_BUTTON_WIDTH, 0, MIN_BUTTON_WIDTH)
local MIN_BUTTON_POSITION = UDim2.new(0, 0, 0, MIN_HEIGHT/2)

local CHECK_IMAGE_WIDTH = 8
local MIN_CHECK_IMAGE_WIDTH = CHECK_IMAGE_WIDTH

local CHECK_IMAGE_SIZE = UDim2.new(0, CHECK_IMAGE_WIDTH, 0, CHECK_IMAGE_WIDTH)
local MIN_CHECK_IMAGE_SIZE = UDim2.new(0, MIN_CHECK_IMAGE_WIDTH, 0, MIN_CHECK_IMAGE_WIDTH)

local ENABLED_CHECK_IMAGE = "rbxasset://textures/TerrainTools/icon_tick.png"
local DISABLED_CHECK_IMAGE = "rbxasset://textures/TerrainTools/icon_tick_grey.png"
local CHECKBOX_FRAME_IMAGE = "rbxasset://textures/TerrainTools/checkbox_square.png"

local Class = {}
Class.__index = Class

Class.MIN_FRAME_SIZE = UDim2.new(0, MIN_LABEL_WIDTH + MIN_MARGIN + MIN_BUTTON_WIDTH, 0, MIN_HEIGHT)

type LabeledCheckbox = Types.LabeledCheckbox

type Config = {
	Title: string,
	InitialValue: boolean?,
	Disabled: boolean?,
	Inset: number?
}


function Class.new(Data: Config): LabeledCheckbox
	local self = (setmetatable({}, Class) :: never) :: LabeledCheckbox

	self.Title = Data.Title
	self.InitialValue = Data.InitialValue or false
	self.Disabled = Data.Disabled or false
	self.Inset = Data.Inset or 0

	self.ValueChanged = Signal.new()
	self.DisabledChanged = Signal.new()

	local Frame = GuiUtilities.MakeStandardFixedHeightFrame("CBF")

	local FullBackgroundButton = Instance.new("TextButton")
	FullBackgroundButton.Name = "FullBackground"
	FullBackgroundButton.Parent = Frame
	FullBackgroundButton.BackgroundTransparency = 1
	FullBackgroundButton.Size = UDim2.new(1, 0, 1, 0)
	FullBackgroundButton.Position = UDim2.new(0, 0, 0, 0)
	FullBackgroundButton.Text = ""

	local Label = GuiUtilities.MakeStandardPropertyLabel(self.Title, true)
	Label.Parent = FullBackgroundButton

	local Button = Instance.new('ImageButton')
	Button.Name = 'Button'
	Button.Size = UDim2.new(0, CHECKBOX_WIDTH, 0, CHECKBOX_WIDTH)
	Button.AnchorPoint = Vector2.new(0, .5)
	Button.BackgroundTransparency = 0
	Button.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin + self.Inset, .5, 0)
	Button.Parent = FullBackgroundButton
	Button.Image = CHECKBOX_FRAME_IMAGE
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false

	local CheckImage = Instance.new("ImageLabel")
	CheckImage.Name = "CheckImage"
	CheckImage.Parent = Button
	CheckImage.Image = ENABLED_CHECK_IMAGE
	CheckImage.Visible = false
	CheckImage.Size = CHECK_IMAGE_SIZE
	CheckImage.AnchorPoint = Vector2.new(0.5, 0.5)
	CheckImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	CheckImage.BackgroundTransparency = 1
	CheckImage.BorderSizePixel = 0

	self.Frame = Frame
	self.Button = Button
	self.Label = Label
	self.CheckImage = CheckImage
	self.FullBackgroundButton = FullBackgroundButton
	self.UseDisabledOverride = false
	self.DisabledOverride = false
	self:SetDisabled(self.Disabled)

	self.Value = not self.InitialValue
	self:SetValue(self.InitialValue)

	self:SetupMouseClickHandling()

	local function UpdateFontColors()
		self:UpdateFontColors()
	end
	settings().Studio.ThemeChanged:Connect(UpdateFontColors)
	UpdateFontColors()

	return self
end


function Class:MaybeToggleState(Internal: boolean?)
	local self = self :: LabeledCheckbox

	if not self.Disabled then
		self:SetValue(not self.Value, Internal)
	end
end

function Class:SetupMouseClickHandling()
	local self = self :: LabeledCheckbox

	self.Button.MouseButton1Down:Connect(function()
		self:MaybeToggleState(true)
	end)

	self.FullBackgroundButton.MouseButton1Down:Connect(function()
		self:MaybeToggleState(true)
	end)
end

function Class:HandleUpdatedValue(InternalTrigger: boolean?)
	local self = self :: LabeledCheckbox

	self.CheckImage.Visible = self:GetValue()
	self.ValueChanged:Fire(self:GetValue(), InternalTrigger or false)
end

-- Small checkboxes are a different entity.
-- All the bits are smaller.
-- Fixed width instead of flood-fill.
-- Box comes first, then label.
function Class:UseSmallSize()
	local self = self :: LabeledCheckbox

	self.Label.TextSize = MIN_TEXT_SIZE
	self.Label.Size = MIN_LABEL_SIZE
	self.Label.Position = MIN_LABEL_POS
	self.Label.TextXAlignment = Enum.TextXAlignment.Left

	self.Button.Size = MIN_BUTTON_SIZE
	self.Button.Position = MIN_BUTTON_POSITION

	self.CheckImage.Size = MIN_CHECK_IMAGE_SIZE

	self.Frame.Size = Class.MIN_FRAME_SIZE
	self.Frame.BackgroundTransparency = 1
end

function Class:GetFrame()
	local self = self :: LabeledCheckbox

	return self.Frame
end

function Class:GetValue()
	local self = self :: LabeledCheckbox

	-- If button is disabled, and we should be using a disabled override,
	-- use the disabled override.
	if (self.Disabled and self.UseDisabledOverride) then
		return self.DisabledOverride
	else
		return self.Value
	end
end

function Class:GetLabel()
	local self = self :: LabeledCheckbox

	return self.Label
end

function Class:GetButton()
	local self = self :: LabeledCheckbox

	return self.Button
end

function Class:SetDisabled(NewDisabled: boolean)
	local self = self :: LabeledCheckbox

	NewDisabled = not not NewDisabled

	local OriginalValue = self:GetValue()

	if NewDisabled ~= self.Disabled then
		self.Disabled = NewDisabled

		-- if we are no longer disabled, then we don't need or want
		-- the override any more.  Forget it.
		if (not self.Disabled) then
			self.UseDisabledOverride = false
		end

		if (NewDisabled) then
			self.CheckImage.Image = DISABLED_CHECK_IMAGE
		else
			self.CheckImage.Image = ENABLED_CHECK_IMAGE
		end

		self:UpdateFontColors()
		self.Button.BackgroundColor3 = self.Disabled and GuiUtilities.ButtonDisabledBackgroundColor or GuiUtilities.ButtonStandardBackgroundColor
		self.Button.BorderColor3 = self.Disabled and GuiUtilities.ButtonDisabledBorderColor or GuiUtilities.ButtonStandardBorderColor
		self.DisabledChanged:Fire(self.Disabled)
	end

	local NewValue = self:GetValue()
	if (NewValue ~= OriginalValue) then
		self:HandleUpdatedValue()
	end
end

function Class:UpdateFontColors()
	local self = self :: LabeledCheckbox

	if self.Disabled then
		self.Label.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.DimmedText)
	else
		self.Label.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	end
end

function Class:DisableWithOverrideValue(OverrideValue: boolean)
	local self = self :: LabeledCheckbox

	-- Disable this checkbox.  While disabled, force value to override value.
	local OldValue = self:GetValue()
	self.UseDisabledOverride = true
	self.DisabledOverride = OverrideValue
	self:SetDisabled(true)
	local NewValue = self:GetValue()
	if (OldValue ~= NewValue) then
		self:HandleUpdatedValue()
	end
end

function Class:GetDisabled()
	local self = self :: LabeledCheckbox

	return self.Disabled
end

function Class:SetValue(NewValue: boolean, Internal: boolean?)
	local self = self :: LabeledCheckbox

	NewValue = not not NewValue

	if NewValue ~= self.Value then
		self.Value = NewValue
		self:HandleUpdatedValue(not Internal)
	end
end

--// RETURN
return Class
