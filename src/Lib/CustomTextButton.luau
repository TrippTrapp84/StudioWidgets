----------------------------------------
--
-- CustomTextButton.lua
--
-- Creates text button with custom look & feel, hover/click effects.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Types = require(script.Parent.Parent.Types)

local BUTTON_DEFAULT_IMAGE = "rbxasset://textures/TerrainTools/button_default.png"

local Class = {}
Class.__index = Class

type CustomTextButton = Types.CustomTextButton

type Config = {
	Title: string
}

function Class.new(Data: Config): CustomTextButton
	local self = (setmetatable({}, Class) :: never) :: CustomTextButton

	self.LabelText = Data.Title

	local Button = Instance.new('ImageButton')
	Button.Image = BUTTON_DEFAULT_IMAGE
	Button.ImageColor3 = Color3.new(0.243137, 0.243137, 0.243137)
	Button.BackgroundTransparency = 1
	Button.ScaleType = Enum.ScaleType.Slice
	Button.SliceCenter = Rect.new(7, 7, 156, 36)
	Button.AutoButtonColor = false

	local Label = Instance.new('TextLabel')
	Label.Text = self.LabelText
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 1, GuiUtilities.ButtonVerticalFudge)
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 15
	Label.TextColor3 = Color3.new(0.886275, 0.886275, 0.886275)
	Label.Parent = Button

	self.Label = Label
	self.Button = Button

	self.Clicked = false
	self.Hovered = false

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
	local self = self :: CustomTextButton

	if (self.Clicked) then
		self.Button.ImageColor3 = Color3.new(0.184314, 0.184314, 0.184314)
	elseif (self.Hovered) then
		self.Button.ImageColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	else
		self.Button.ImageColor3 = Color3.new(0.243137, 0.243137, 0.243137)
	end
end

function Class:GetFrame()
	local self = self :: CustomTextButton

	return self.Button
end

return Class
