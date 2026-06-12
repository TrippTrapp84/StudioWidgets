----------------------------------------
--
-- ImageButtonWithText.lua
--
-- An image button with text underneath.  Standardized hover, clicked, and
-- selected states.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Types = require(script.Parent.Parent.Types)

local Class = {}
Class.__index = Class

type ImageButtonWithText = Types.ImageButtonWithText

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

function Class.new(Data: Config): ImageButtonWithText
	local self = (setmetatable({}, Class) :: never) :: ImageButtonWithText

	self.Title = Data.Title
	self.ButtonSize = Data.ButtonSize
	self.Icon = Data.Icon
	self.ImageSize = Data.ImageSize or UDim2.fromScale(1, 1)
	self.ImagePosition = Data.ImagePosition or UDim2.fromScale(.5, .5)
	self.TextSize = Data.TextSize or UDim2.fromScale(1, .1)
	self.TextPosition = Data.TextPosition or UDim2.fromScale(.5, 1)
	self.LayoutOrder = Data.LayoutOrder or 1

	local Button = Instance.new("ImageButton")
	Button.AutoButtonColor = false
	Button.Size = self.ButtonSize
	Button.BorderSizePixel = 1
	Button.BackgroundTransparency = 1
	Button.LayoutOrder = self.LayoutOrder

	local ButtonIcon = Instance.new("ImageLabel")
	ButtonIcon.BackgroundTransparency = 1
	ButtonIcon.Image = self.Icon
	ButtonIcon.AnchorPoint = Vector2.new(.5, .5)
	ButtonIcon.Size = self.ImageSize
	ButtonIcon.Position = self.ImagePosition
	ButtonIcon.Parent = Button

	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = self.Title
	TextLabel.Size = self.TextSize
	TextLabel.AnchorPoint = Vector2.new(.5, .5)
	TextLabel.Position = self.TextPosition
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.Parent = Button

	GuiUtilities.SyncGuiElementFontColor(TextLabel)

	local UiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	-- Spec asks for fontsize of 12 pixels, but in Roblox the text font sizes look smaller than the mock
	--Note: For this font the Roblox text size is 25.7% larger than the design spec.
	UiTextSizeConstraint.MaxTextSize = 15
	UiTextSizeConstraint.Parent = TextLabel

	self.Button = Button
	self.Clicked = false
	self.Hovered = false
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

	local function UpdateButtonVisual()
		self:UpdateButtonVisual()
	end
	settings().Studio.ThemeChanged:Connect(UpdateButtonVisual)

	self:UpdateButtonVisual()

	return self
end

function Class:UpdateButtonVisual()
	local self = self :: ImageButtonWithText

	if (self.Clicked) then
		self.Button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Selected)
		self.Button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border,
			Enum.StudioStyleGuideModifier.Selected)
		if (self.Selected) then
			self.Button.BackgroundTransparency = GuiUtilities.ButtonBackgroundIntenseTransparency
		else
			self.Button.BackgroundTransparency = GuiUtilities.ButtonBackgroundTransparency
		end
	elseif (self.Hovered) then
		self.Button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Hover)
		self.Button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border,
			Enum.StudioStyleGuideModifier.Hover)
		if (self.Selected) then
			self.Button.BackgroundTransparency = GuiUtilities.ButtonBackgroundIntenseTransparency
		else
			self.Button.BackgroundTransparency = GuiUtilities.ButtonBackgroundTransparency
		end
	elseif (self.Selected) then
		self.Button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Selected)
		self.Button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border,
			Enum.StudioStyleGuideModifier.Selected)
		self.Button.BackgroundTransparency = GuiUtilities.ButtonBackgroundTransparency
	else
		self.Button.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Button)
		self.Button.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border)
		self.Button.BackgroundTransparency = 1
	end
end

function Class:GetFrame()
	local self = self :: ImageButtonWithText

	return self.Button
end

function Class:SetSelected(Selected: boolean)
	local self = self :: ImageButtonWithText

	self.Selected = Selected
	self:UpdateButtonVisual()
end

function Class:GetSelected()
	local self = self :: ImageButtonWithText

	return self.Selected
end

--// RETURN
return Class
