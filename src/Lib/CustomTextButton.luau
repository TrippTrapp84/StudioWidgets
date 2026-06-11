----------------------------------------
--
-- CustomTextButton.lua
--
-- Creates text button with custom look & feel, hover/click effects.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local BUTTON_DEFAULT_IMAGE = "rbxasset://textures/TerrainTools/button_default.png"

local Class = {}
Class.__index = Class

type Config = {
	Title: string
}

function Class.new(Data: Config)

	local self = setmetatable({}, Class)

	self.LabelText = Data.Title

	local button = Instance.new('ImageButton')
	button.Image = BUTTON_DEFAULT_IMAGE
	button.ImageColor3 = Color3.new(0.243137, 0.243137, 0.243137)
	button.BackgroundTransparency = 1
	button.ScaleType = Enum.ScaleType.Slice
	button.SliceCenter = Rect.new(7, 7, 156, 36)
	button.AutoButtonColor = false

	local label = Instance.new('TextLabel')
	label.Text = self.LabelText
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, GuiUtilities.kButtonVerticalFudge)
	label.Font = Enum.Font.SourceSans                  
	label.TextSize = 15         
	label.TextColor3 = Color3.new(0.886275, 0.886275, 0.886275)
	label.Parent = button

	self._label = label
	self._button = button

	self._clicked = false
	self._hovered = false

	button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then               
			self._hovered = true
			self:_updateButtonVisual()
		end
	end)


	button.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then               
			self._hovered = false
			self._clicked = false
			self:_updateButtonVisual()
		end
	end)    

	button.MouseButton1Down:Connect(function()
		self._clicked = true
		self:_updateButtonVisual()
	end)

	button.MouseButton1Up:Connect(function()
		self._clicked = false
		self:_updateButtonVisual()
	end)
	
	self:_updateButtonVisual()

	return self
end

function Class:_updateButtonVisual()
	if (self._clicked) then 
		self._button.ImageColor3 = Color3.new(0.184314, 0.184314, 0.184314)
		--self._label.TextColor3 = GuiUtilities.kPressedButtonTextColor
	elseif (self._hovered) then 
		self._button.ImageColor3 = Color3.new(0.27451, 0.27451, 0.27451)
		--self._label.TextColor3 = GuiUtilities.kStandardButtonTextColor
	else
		self._button.ImageColor3 = Color3.new(0.243137, 0.243137, 0.243137)
		--self._label.TextColor3 = GuiUtilities.kStandardButtonTextColor
	end
end

-- Backwards compatibility (should be removed in the future)
-- CustomTextButtonClass.getButton = CustomTextButtonClass.GetButton

function Class:GetFrame()
	return self._button
end

return Class
