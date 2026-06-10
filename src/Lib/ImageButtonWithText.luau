----------------------------------------
--
-- ImageButtonWithText.lua
--
-- An image button with text underneath.  Standardized hover, clicked, and 
-- selected states.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)

local SELECTED_TRANSPARENCY = 0.2
local ADDITIONAL_TRANSPARENCY = 0.1

local Class = {}
Class.__index = Class

type Config = {
	Title: string,
	ButtonSize: UDim2,
	Icon: string,

	ImageSize: UDim2?,
	ImagePosition: UDim2?,

	TextSize: UDim2?,
	TextPosition: UDim2?,

	LayoutOrder: number?,
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.ButtonSize = Data.ButtonSize
	self.Icon = Data.Icon
	self.ImageSize = Data.ImageSize or UDim2.fromScale(1, 1)
	self.ImagePosition = Data.ImagePosition or UDim2.fromScale(.5, .5)
	self.TextSize = Data.TextSize or UDim2.fromScale(1, .1)
	self.TextPosition = Data.TextPosition or UDim2.fromScale(.5, 1)
	self.LayoutOrder = Data.LayoutOrder or 1

	local button = Instance.new("ImageButton")
	button.AutoButtonColor = false
	button.Size = self.ButtonSize
	button.BorderSizePixel = 1
	button.BackgroundTransparency = 1 

	button.LayoutOrder = self.LayoutOrder

	local buttonIcon = Instance.new("ImageLabel")
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Image = self.Icon
	buttonIcon.AnchorPoint = Vector2.new(.5, .5)
	buttonIcon.Size = self.ImageSize
	buttonIcon.Position = self.ImagePosition
	buttonIcon.Parent = button

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Text = self.Title
	textLabel.Size = self.TextSize
	textLabel.AnchorPoint = Vector2.new(.5, .5)
	textLabel.Position = self.TextPosition
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSans
	textLabel.Parent = button

	GuiUtilities.syncGuiElementFontColor(textLabel)

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	-- Spec asks for fontsize of 12 pixels, but in Roblox the text font sizes look smaller than the mock
	--Note: For this font the Roblox text size is 25.7% larger than the design spec. 
	uiTextSizeConstraint.MaxTextSize = 15		                                          
	uiTextSizeConstraint.Parent = textLabel

	self._button = button
	self._clicked = false
	self._hovered = false
	self._selected = false

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
	
	function updateButtonVisual()
		self:_updateButtonVisual()
	end
	settings().Studio.ThemeChanged:Connect(updateButtonVisual)

	self:_updateButtonVisual()

	return self
end

function Class:_updateButtonVisual()
	-- Possibilties:
	if (self._clicked) then 
		-- This covers 'clicked and selected' or 'clicked'
		self._button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button, 
			Enum.StudioStyleGuideModifier.Selected)
		self._button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border, 
			Enum.StudioStyleGuideModifier.Selected)
		if (self._selected) then 
			self._button.BackgroundTransparency = GuiUtilities.kButtonBackgroundIntenseTransparency
		else
			self._button.BackgroundTransparency = GuiUtilities.kButtonBackgroundTransparency
		end
	elseif (self._hovered) then 
		-- This covers 'hovered and selected' or 'hovered'
		self._button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button, 
			Enum.StudioStyleGuideModifier.Hover)
		self._button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border, 
			Enum.StudioStyleGuideModifier.Hover)
		if (self._selected) then 
			self._button.BackgroundTransparency = GuiUtilities.kButtonBackgroundIntenseTransparency
		else
			self._button.BackgroundTransparency = GuiUtilities.kButtonBackgroundTransparency
		end
	elseif (self._selected) then 
		-- This covers 'selected'
		self._button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button, 
			Enum.StudioStyleGuideModifier.Selected)
		self._button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border, 
			Enum.StudioStyleGuideModifier.Selected)
		self._button.BackgroundTransparency = GuiUtilities.kButtonBackgroundTransparency
	else
		-- This covers 'no special state'
		self._button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button)
		self._button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border)
		self._button.BackgroundTransparency = 1
	end
end

function Class:GetButton()
	return self._button
end

function Class:SetSelected(selected)
	self._selected = selected
	self:_updateButtonVisual()
end
 
function Class:GetSelected()
	return self._selected
end

--// RETURN
return Class