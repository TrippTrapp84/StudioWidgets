----------------------------------------
--
-- StatefulImageButton.lua
--
-- Image button.
-- Has custom image for when "selected"
-- Uses shading to indicate hover and click states.
--
----------------------------------------
local Types = require(script.Parent.Parent.Types)

local Class = {}
Class.__index = Class

type StatefulImageButton = Types.StatefulImageButton

type Config = {
	Icon: string,
	Size: UDim2
}

function Class.new(Data: Config): StatefulImageButton
	local self = (setmetatable({}, Class) :: never) :: StatefulImageButton

	self.Icon = Data.Icon
	self.Size = Data.Size

	local Button = Instance.new("ImageButton")
	Button.Image = self.Icon
	Button.BackgroundTransparency = 1
	Button.BorderSizePixel = 0
	Button.Size = self.Size

	self.Button = Button
	self.Hovered = false
	self.Clicked = false
	self.Selected = false

	Button.InputBegan:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
			self.Hovered = true
			self:UpdateButtonVisual()
		end
	end)

	Button.InputEnded:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
			self.Hovered = false
			self.Clicked = false
			self:UpdateButtonVisual()
		end
	end)

	Button.MouseButton1Down:Connect(function()
		self.Clicked = true
		self:UpdateButtonVisual()
	end)

	Button.MouseButton1Up:Connect(function()
		self.Clicked = false
		self:UpdateButtonVisual()
	end)

	self:UpdateButtonVisual()

	return self
end

function Class:UpdateButtonVisual()
	local self = self :: StatefulImageButton

	if (self.Selected) then
		self.Button.ImageTransparency = 0
		self.Button.ImageColor3 = Color3.new(1, 1, 1)
	else
		self.Button.ImageTransparency = 0.5
		self.Button.ImageColor3 = Color3.new(.5, .5, .5)
	end

	if (self.Clicked) then
		self.Button.BackgroundTransparency = 0.8
	elseif (self.Hovered) then
		self.Button.BackgroundTransparency = 0.9
	else
		self.Button.BackgroundTransparency = 1
	end
end

function Class:SetSelected(Selected: boolean)
	local self = self :: StatefulImageButton

	self.Selected = Selected
	self:UpdateButtonVisual()
end

function Class:GetSelected()
	local self = self :: StatefulImageButton

	return self.Selected
end

function Class:GetFrame()
	local self = self :: StatefulImageButton

	return self.Button
end

--// RETURN
return Class
