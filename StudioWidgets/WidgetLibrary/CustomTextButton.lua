----------------------------------------
--
-- CustomTextButton.lua
--
-- Creates text button with custom look & feel, hover/click effects.
--
----------------------------------------
local plugin = _G.StudioWidgetsPluginGlobalDistributorObject

local GuiUtilities = require(script.Parent.GuiUtilities)

local kButtonImageIdDefault = "rbxasset://textures/TerrainTools/button_default.png"

local CustomTextButtonClass = {}
CustomTextButtonClass.__index = CustomTextButtonClass

function CustomTextButtonClass.new(buttonName, labelText)
	local self = {}
	setmetatable(self, CustomTextButtonClass)

	local button = Instance.new('ImageButton')
	button.Name = buttonName
	button.Image = kButtonImageIdDefault
	button.ImageColor3 = Color3.new(0.243137, 0.243137, 0.243137)
	button.BackgroundTransparency = 1
	button.ScaleType = Enum.ScaleType.Slice
	button.SliceCenter = Rect.new(7, 7, 156, 36)
	button.AutoButtonColor = false

	local label = Instance.new('TextLabel')
	label.Text = labelText
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

function CustomTextButtonClass:_updateButtonVisual()
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

function CustomTextButtonClass:GetButton()
	return self._button
end

return CustomTextButtonClass
