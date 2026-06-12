----------------------------------------
--
-- LabeledSlider.lua
--
-- Creates a frame containing a label and a slider control.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)
local CreateSlider = require(script.Slider)

local SLIDER_WIDTH = 100

local SLIDER_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_button.png"
local PRE_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_blue.png"
local POST_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_grey.png"

local THUMB_SIZE = 13

local STEPS = 100

local Class = {}
Class.__index = Class

type LabeledSlider = Types.LabeledSlider

type Config = {
	Title: string,
	Steps: number?,
	Inset: number?,
	InitialValue: number?
}

function Class.new(Data: Config): LabeledSlider
	local self = (setmetatable({}, Class) :: never) :: LabeledSlider

	self.Title = Data.Title
	self.Steps = Data.Steps or 100
	self.Inset = Data.Inset or 0
	self.InitialValue = Data.InitialValue or 1

	self.ValueChanged = Signal.new()

	local Frame = GuiUtilities.MakeStandardFixedHeightFrame('Slider')
	self.Frame = Frame

	local Label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	Label.Parent = Frame
	self.Label = Label

	self.Value = self.InitialValue

	--steps, width, position
	local Slider, SliderValue = CreateSlider(
		self.Steps,
		STEPS,
		UDim2.new(0, self.Inset, .5, -3)
	)
	self.Slider = Slider
	self.SliderValue = SliderValue
	-- Some tweaks to make slider look nice.
	-- Hide the existing bar.
	Slider.Bar.BackgroundTransparency = 1
	-- Replace slider thumb image.
	self.Thumb = Slider.Bar.Slider
	self.Thumb.Image = SLIDER_THUMB_IMAGE
	self.Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Thumb.Size = UDim2.new(0, THUMB_SIZE, 0, THUMB_SIZE)

	-- Add images on bar.
	self.PreThumbImage = Instance.new("ImageLabel")
	self.PreThumbImage.Name = "PreThumb"
	self.PreThumbImage.Parent = Slider.Bar
	self.PreThumbImage.Size = UDim2.new(1, 0, 1, 0)
	self.PreThumbImage.Position = UDim2.new(0, 0, 0, 0)
	self.PreThumbImage.Image = PRE_THUMB_IMAGE
	self.PreThumbImage.BorderSizePixel = 0

	self.PostThumbImage = Instance.new("ImageLabel")
	self.PostThumbImage.Name = "PostThumb"
	self.PostThumbImage.Parent = Slider.Bar
	self.PostThumbImage.Size = UDim2.new(1, 0, 1, 0)
	self.PostThumbImage.Position = UDim2.new(0, 0, 0, 0)
	self.PostThumbImage.Image = POST_THUMB_IMAGE
	self.PostThumbImage.BorderSizePixel = 0

	SliderValue.Changed:Connect(function()
		self.Value = SliderValue.Value

		-- Min value is 1.
		-- Max value is sliderIntervals.
		-- So scale is...
		local Scale = (self.Value - 1) / (self.Steps - 1)

		self.PreThumbImage.Size = UDim2.new(Scale, 0, 1, 0)
		self.PostThumbImage.Size = UDim2.new(1 - Scale, 0, 1, 0)
		self.PostThumbImage.Position = UDim2.new(Scale, 0, 0, 0)

		self.Thumb.Position = UDim2.new(Scale, 0, 0.5, 0)

		self.ValueChanged:Fire(self.Value)
	end)

	self:SetValue(self.InitialValue)
	Slider.AnchorPoint = Vector2.new(0, 0.5)
	Slider.Size = UDim2.new(0, SLIDER_WIDTH, 1, 0)
	Slider.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin, 0, GuiUtilities.StandardPropertyHeight / 2)
	Slider.Parent = Frame

	return self
end

function Class:GetFrame()
	local self = self :: LabeledSlider

	return self.Frame
end

function Class:SetValue(NewValue: number)
	local self = self :: LabeledSlider

	if self.SliderValue.Value ~= NewValue then
		self.SliderValue.Value = NewValue
	end
end

function Class:GetValue()
	local self = self :: LabeledSlider

	return self.SliderValue.Value
end

return Class
