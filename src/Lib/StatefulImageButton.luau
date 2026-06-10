----------------------------------------
--
-- StatefulImageButton.lua
--
-- Image button.
-- Has custom image for when "selected"
-- Uses shading to indicate hover and click states.
--
----------------------------------------
local Class = {}
Class.__index = Class

type Config = {
	Icon: string,
	Size: UDim2
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Icon = Data.Icon
	self.Size = Data.Size

	local button = Instance.new("ImageButton")
	button.Image = self.Icon
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Size = self.Size

	self._button = button

	self._hovered = false
	self._clicked = false
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
	
	self:_updateButtonVisual()

	return self
end

function Class:_updateButtonVisual()
	if (self._selected) then 
		self._button.ImageTransparency = 0
		self._button.ImageColor3 = Color3.new(1,1,1) 
	else 
		self._button.ImageTransparency = 0.5
		self._button.ImageColor3 = Color3.new(.5,.5,.5)
	end

	if (self._clicked) then 
		self._button.BackgroundTransparency = 0.8
	elseif (self._hovered) then 
		self._button.BackgroundTransparency = 0.9
	else
		self._button.BackgroundTransparency = 1
	end
end

function Class:SetSelected(selected)
	self._selected = selected
	self:_updateButtonVisual()
end

function Class:GetSelected()
	return self._selected
end

function Class:GetButton()
	return self._button
end

--// RETURN
return Class