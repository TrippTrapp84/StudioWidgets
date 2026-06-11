----------------------------------------
--
-- LabeledRadioButton.lua
--
-- Creates a frame containing a label and a radio button.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local LabeledCheckbox = require(script.Parent.LabeledCheckbox)

local BUTTON_IMAGE = "rbxasset://textures/TerrainTools/radio_button_frame.png"
local BULLET_IMAGE = "rbxasset://textures/TerrainTools/radio_button_bullet.png"

local BUTTON_IMAGE_DARK = "rbxasset://textures/TerrainTools/radio_button_frame_dark.png"
local BULLET_IMAGE_DARK = "rbxasset://textures/TerrainTools/radio_button_bullet_dark.png"

local FRAME_SIZE = 12
local BULLET_SIZE = 14

local Class = {}
Class.__index = Class
setmetatable(Class, LabeledCheckbox)

type Config = {
	Title: string
}

function Class.new(Data: Config)
	local self = setmetatable(LabeledCheckbox.new({
		Title = Data.Title
	}), Class)

	self:UseSmallSize()
	self._checkImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	self._checkImage.Image = BULLET_IMAGE
	self._checkImage.Size = UDim2.new(0, BULLET_SIZE, 0, BULLET_SIZE)

	self._button.Image = BUTTON_IMAGE
	self._button.Size = UDim2.new(0, FRAME_SIZE, 0, FRAME_SIZE)
	self._button.BackgroundTransparency = 1

	local function updateImages()
		if (GuiUtilities:ShouldUseIconsForDarkerBackgrounds()) then
			self._checkImage.Image = BULLET_IMAGE_DARK
			self._button.Image = BUTTON_IMAGE_DARK
		else
			self._checkImage.Image = BULLET_IMAGE
			self._button.Image = BUTTON_IMAGE
		end
	end
	settings().Studio.ThemeChanged:Connect(updateImages)
	updateImages()

	return self
end

function Class:_MaybeToggleState()
	-- A checkbox can never be toggled off. 
	-- Only turns off because another one turns on.
	if (not self._disabled and not self._value) then 
		self:SetValue(not self._value)
	end
end

--// RETURN
return Class