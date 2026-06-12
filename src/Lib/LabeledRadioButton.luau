----------------------------------------
--
-- LabeledRadioButton.lua
--
-- Creates a frame containing a label and a radio button.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local LabeledCheckbox = require(script.Parent.LabeledCheckbox)
local Types = require(script.Parent.Parent.Types)

local BUTTON_IMAGE = "rbxasset://textures/TerrainTools/radio_button_frame.png"
local BULLET_IMAGE = "rbxasset://textures/TerrainTools/radio_button_bullet.png"

local BUTTON_IMAGE_DARK = "rbxasset://textures/TerrainTools/radio_button_frame_dark.png"
local BULLET_IMAGE_DARK = "rbxasset://textures/TerrainTools/radio_button_bullet_dark.png"

local FRAME_SIZE = 12
local BULLET_SIZE = 14

local Class = {}
Class.__index = Class
setmetatable(Class, LabeledCheckbox)

type LabeledRadioButton = Types.LabeledRadioButton

type Config = {
	Title: string
}

function Class.new(Data: Config): LabeledRadioButton
	local self = (setmetatable(LabeledCheckbox.new({
		Title = Data.Title
	}), Class) :: never) :: LabeledRadioButton

	self:UseSmallSize()
	self.CheckImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.CheckImage.Image = BULLET_IMAGE
	self.CheckImage.Size = UDim2.new(0, BULLET_SIZE, 0, BULLET_SIZE)

	self.Button.Image = BUTTON_IMAGE
	self.Button.Size = UDim2.new(0, FRAME_SIZE, 0, FRAME_SIZE)
	self.Button.BackgroundTransparency = 1

	local function UpdateImages()
		if (GuiUtilities:ShouldUseIconsForDarkerBackgrounds()) then
			self.CheckImage.Image = BULLET_IMAGE_DARK
			self.Button.Image = BUTTON_IMAGE_DARK
		else
			self.CheckImage.Image = BULLET_IMAGE
			self.Button.Image = BUTTON_IMAGE
		end
	end
	settings().Studio.ThemeChanged:Connect(UpdateImages)
	UpdateImages()

	return self
end

function Class:MaybeToggleState()
	local self = self :: LabeledRadioButton

	-- A radio button can never be toggled off.
	-- Only turns off because another one turns on.
	if (not self.Disabled and not self.Value) then
		self:SetValue(not self.Value)
	end
end

--// RETURN
return Class
