----------------------------------------
--
-- LabeledSlider.lua
--
-- Creates a frame containing a label and a slider control.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local rbxGuiLibrary = require(script.Parent.Parent.Util.RbxGui)

local SLIDER_WIDTH = 100

local SLIDER_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_button.png"
local PRE_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_blue.png"
local POST_THUMB_IMAGE = "rbxasset://textures/TerrainTools/sliderbar_grey.png"

local THUMB_SIZE = 13

local STEPS = 100

local Class = {}
Class.__index = Class

local function DefaultValues()
	return {
		Suffix = NULL,
		LabelText = NULL,
		StepCount = 100,
		SliderInset = 0,
		InitialValue = 1
	}
end

type Config = {
	Title: string,
	Steps: number?,
	Inset: number?,
	InitialValue: number?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.Steps = Data.Steps or 100
	self.Inset = Data.Inset or 0
	self.InitialValue = Data.InitialValue or 1

	self._valueChangedFunction = nil

	local frame = GuiUtilities.MakeStandardFixedHeightFrame('Slider')
	self._frame = frame

	local label = GuiUtilities.MakeStandardPropertyLabel(self.Title)
	label.Parent = frame
	self._label = label

	self._value = self.InitialValue

	--steps, width, position
	local slider, sliderValue = rbxGuiLibrary.CreateSlider(
		self.Steps,
		STEPS, 
		UDim2.new(0, self.Inset, .5, -3)
	)
	self._slider = slider
	self._sliderValue = sliderValue
	-- Some tweaks to make slider look nice.
	-- Hide the existing bar.
	slider.Bar.BackgroundTransparency = 1
	-- Replace slider thumb image.
	self._thumb = slider.Bar.Slider
	self._thumb.Image = SLIDER_THUMB_IMAGE
	self._thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	self._thumb.Size = UDim2.new(0, THUMB_SIZE, 0, THUMB_SIZE)
	
	-- Add images on bar.
	self._preThumbImage = Instance.new("ImageLabel")
	self._preThumbImage.Name = "PreThumb"
	self._preThumbImage.Parent = slider.Bar
	self._preThumbImage.Size = UDim2.new(1, 0, 1, 0)
	self._preThumbImage.Position = UDim2.new(0, 0, 0, 0)
	self._preThumbImage.Image = PRE_THUMB_IMAGE
	self._preThumbImage.BorderSizePixel = 0

	self._postThumbImage = Instance.new("ImageLabel")
	self._postThumbImage.Name = "PostThumb"
	self._postThumbImage.Parent = slider.Bar
	self._postThumbImage.Size = UDim2.new(1, 0, 1, 0)
	self._postThumbImage.Position = UDim2.new(0, 0, 0, 0)
	self._postThumbImage.Image = POST_THUMB_IMAGE
	self._postThumbImage.BorderSizePixel = 0

	sliderValue.Changed:Connect(function()
		self._value = sliderValue.Value

		-- Min value is 1.
		-- Max value is sliderIntervals.
		-- So scale is...
		local scale = (self._value - 1)/(self.Steps-1)

		self._preThumbImage.Size = UDim2.new(scale, 0, 1, 0)
		self._postThumbImage.Size = UDim2.new(1 - scale, 0, 1, 0)
		self._postThumbImage.Position = UDim2.new(scale, 0, 0, 0)
		
		self._thumb.Position = UDim2.new(scale, 0, 
			0.5, 0)

		if self._valueChangedFunction then 
			self._valueChangedFunction(self._value)
		end
	end)
	
	self:SetValue(self.InitialValue)
	slider.AnchorPoint = Vector2.new(0, 0.5)
	slider.Size = UDim2.new(0, SLIDER_WIDTH, 1, 0)
	slider.Position = UDim2.new(0, GuiUtilities.StandardLineElementLeftMargin, 0, GuiUtilities.kStandardPropertyHeight/2)
	slider.Parent = frame
	
	return self
end

function Class:SetValueChangedFunction(vcf)
	self._valueChangedFunction = vcf
end

function Class:GetFrame()
	return self._frame
end

function Class:SetValue(newValue)
	if self._sliderValue.Value ~= newValue then
		self._sliderValue.Value = newValue
	end
end

function Class:GetValue()
	return self._sliderValue.Value
end

return Class