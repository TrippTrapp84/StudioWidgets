local module = {}

module.TitleBarHeight = 27
module.InlineTitleBarHeight = 24

module.StandardContentAreaWidth = 180

module.StandardPropertyHeight = 30
module.SubSectionLabelHeight = 30

module.StandardVMargin = 7
module.StandardHMargin = 16

module.CheckboxMinLabelWidth = 52
module.CheckboxMinMargin = 12
module.CheckboxWidth = 12

module.RadioButtonsHPadding = 24

module.StandardLineLabelLeftMargin = module.TitleBarHeight
module.StandardLineElementLeftMargin = (
	module.StandardLineLabelLeftMargin
	+ module.CheckboxMinLabelWidth
	+ module.CheckboxMinMargin
	+ module.CheckboxWidth
	+ module.RadioButtonsHPadding
)
module.StandardLineLabelWidth = (module.StandardLineElementLeftMargin - module.StandardLineLabelLeftMargin - 10)

module.DropDownHeight = 55

module.BottomButtonsFrameHeight = 50
module.BottomButtonsHeight = 28

module.ShapeButtonSize = 32
module.TextVerticalFudge = -3
module.ButtonVerticalFudge = -5

module.BottomButtonsWidth = 100

module.DisabledTextColor = Color3.new(0.4, 0.4, 0.4) --todo: input spec disabled text color
module.StandardButtonTextColor = Color3.new(0, 0, 0) --todo: input spec disabled text color
module.PressedButtonTextColor = Color3.new(1, 1, 1) --todo: input spec disabled text color

module.ButtonStandardBackgroundColor = Color3.new(1, 1, 1) --todo: sync with spec
module.ButtonStandardBorderColor = Color3.new(0.4, 0.4, 0.4) --todo: sync with spec
module.ButtonDisabledBackgroundColor = Color3.new(0.7, 0.7, 0.7) --todo: sync with spec
module.ButtonDisabledBorderColor = Color3.new(0.6, 0.6, 0.6) --todo: sync with spec

module.ButtonBackgroundTransparency = 0.5
module.ButtonBackgroundIntenseTransparency = 0.4

module.MainFrame = nil

function module.ShouldUseIconsForDarkerBackgrounds()
	local MainColor = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	return (MainColor.R + MainColor.G + MainColor.B) / 3 < 0.5
end

function module.SetMainFrame(Frame)
	module.MainFrame = Frame
end

function module.SyncGuiElementTitleColor(GuiElement)
	local function SetColors()
		GuiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Titlebar)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementInputFieldColor(GuiElement)
	local function SetColors()
		GuiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementBackgroundColor(GuiElement)
	local function SetColors()
		GuiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementStripeColor(GuiElement: GuiObject)
	local function SetColors()
		if (GuiElement.LayoutOrder + 1) % 2 == 0 then
			GuiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		else
			GuiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CategoryItem)
		end
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementBorderColor(GuiElement)
	local function SetColors()
		GuiElement.BorderColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Border)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementFontColor(GuiElement)
	local function SetColors()
		GuiElement.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

function module.SyncGuiElementScrollColor(GuiElement)
	local function SetColors()
		GuiElement.ScrollBarImageColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar)
	end
	settings().Studio.ThemeChanged:Connect(SetColors)
	SetColors()
end

-- A frame with standard styling.
function module.MakeFrame(Name)
	local Frame = Instance.new("Frame")
	Frame.Name = Name
	Frame.BackgroundTransparency = 0
	Frame.BorderSizePixel = 0

	module.SyncGuiElementBackgroundColor(Frame)

	return Frame
end

-- A frame that is a whole line, containing some arbitrary sized widget.
function module.MakeFixedHeightFrame(Name, Height)
	local Frame = module.MakeFrame(Name)
	Frame.Size = UDim2.new(1, 0, 0, Height)

	return Frame
end

-- A frame that is one standard-sized line, containing some standard-sized widget (label, edit box, dropdown,
-- checkbox)
function module.MakeStandardFixedHeightFrame(Name)
	return module.MakeFixedHeightFrame(Name, module.StandardPropertyHeight)
end

function module.AdjustHeightDynamicallyToLayout(Frame, UiLayout: UIListLayout, OptPadding: number?)
	local OptPadding = OptPadding or 0

	local function UpdateSizes()
		Frame.Size = UDim2.new(1, 0, 0, UiLayout.AbsoluteContentSize.Y + OptPadding)
	end
	UiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSizes)
	UpdateSizes()
end

-- Assumes input frame has a List layout with sort order layout order.
-- Add frames in order as siblings of list layout, they will be laid out in order.
-- Color frame background accordingly.
function module.AddStripedChildrenToListFrame(ListFrame, Frames)
	for Index, Frame in ipairs(Frames) do
		Frame.Parent = ListFrame
		Frame.LayoutOrder = Index
		Frame.BackgroundTransparency = 0
		Frame.BorderSizePixel = 1
		module.SyncGuiElementStripeColor(Frame)
		module.SyncGuiElementBorderColor(Frame)
	end
end

local function MakeSectionInternal(ParentGui, Name, Title, ContentHeight)
	local Frame = Instance.new("Frame")
	Frame.Name = Name
	Frame.BackgroundTransparency = 1
	Frame.Parent = ParentGui
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0

	-- If title is "nil', no title bar.
	local ContentYOffset = 0
	local TitleBar = nil
	if Title ~= nil then
		local TitleBarFrame = Instance.new("Frame")
		TitleBarFrame.Name = "TitleBarFrame"
		TitleBarFrame.Parent = Frame
		TitleBarFrame.Position = UDim2.new(0, 0, 0, 0)
		TitleBarFrame.LayoutOrder = 0

		local TitleBarLabel = Instance.new("TextLabel")
		TitleBarLabel.Name = "TitleBarLabel"
		TitleBarLabel.Text = Title
		TitleBarLabel.Parent = TitleBarFrame
		TitleBarLabel.BackgroundTransparency = 1
		TitleBarLabel.Position = UDim2.new(0, module.StandardHMargin, 0, 0)

		module.SyncGuiElementFontColor(TitleBarLabel)

		ContentYOffset = ContentYOffset + module.TitleBarHeight
	end

	Frame.Size = UDim2.new(1, 0, 0, ContentYOffset + ContentHeight)

	return Frame
end

function module.MakeFrameAutoPushEnd(Frame: GuiObject, ScalePercent)
	local ParentWidget = Frame:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
	local CurrentParentSizeCon
	local function SetSize()
		if not ParentWidget then
			return
		end
		local FrameSize = ParentWidget.AbsoluteSize
		local RightInset = FrameSize.X * (1 - ScalePercent)
		Frame.Size =
			UDim2.new(0, FrameSize.X - Frame.Position.X.Offset - RightInset, Frame.Size.Y.Scale, Frame.Size.Y.Offset)
	end
	Frame.AncestryChanged:Connect(function()
		ParentWidget = Frame:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
		if not ParentWidget then
			if CurrentParentSizeCon then
				CurrentParentSizeCon:Disconnect()
			end
		else
			SetSize()
			if CurrentParentSizeCon then
				CurrentParentSizeCon:Disconnect()
			end
			CurrentParentSizeCon = ParentWidget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				SetSize()
			end)
		end
	end)

	if ParentWidget then
		SetSize()
		CurrentParentSizeCon = ParentWidget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			SetSize()
		end)
	end
end

function module.MakeStandardPropertyLabel(Text, OptIgnoreThemeUpdates: boolean?)
	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSans --todo: input spec font
	Label.TextSize = 15 --todo: input spec font size
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Text = Text
	Label.AnchorPoint = Vector2.new(0, 0.5)
	Label.Position = UDim2.new(0, module.StandardLineLabelLeftMargin, 0.5, module.TextVerticalFudge)
	Label.Size = UDim2.new(0, module.StandardLineLabelWidth, 1, 0)

	if not OptIgnoreThemeUpdates then
		module.SyncGuiElementFontColor(Label)
	end

	return Label
end

function module.MakeFrameWithSubSectionLabel(Name, Text)
	local Row = module.MakeFixedHeightFrame(Name, module.SubSectionLabelHeight)
	Row.BackgroundTransparency = 1

	local Label = module.MakeStandardPropertyLabel(Text)
	Label.BackgroundTransparency = 1
	Label.Parent = Row

	return Row
end

function module.MakeFrameAutoScalingList(Frame: GuiObject, UiListLayout: UIListLayout?)
	local UiListLayout = UiListLayout or Instance.new("UIListLayout")
	UiListLayout.Parent = Frame
	UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	module.AdjustHeightDynamicallyToLayout(Frame, UiListLayout)
end

function module.GetAncestralBoundingBox(Frame): (Vector2, Vector2)
	local BoundingCorner1, BoundingCorner2
	local CurrentFrame = Frame
	while CurrentFrame.Parent do
		CurrentFrame = CurrentFrame.Parent
		if not CurrentFrame:IsA("GuiBase2d") then
			continue
		end
		local IsWidget = CurrentFrame:IsA("DockWidgetPluginGui")
		if IsWidget or CurrentFrame.ClipsDescendants then
			if BoundingCorner1 then
				local CurrentPosCorner1 = (IsWidget and Vector2.new() or CurrentFrame.AbsolutePosition)
				local CurrentPosCorner2 = CurrentPosCorner1 + CurrentFrame.AbsoluteSize
				BoundingCorner1 = Vector2.new(
					math.max(BoundingCorner1.X, CurrentPosCorner1.X),
					math.max(BoundingCorner1.Y, CurrentPosCorner1.Y)
				)
				BoundingCorner2 = Vector2.new(
					math.min(BoundingCorner2.X, CurrentPosCorner2.X),
					math.min(BoundingCorner2.Y, CurrentPosCorner2.Y)
				)
			else
				BoundingCorner1 = (IsWidget and Vector2.new() or CurrentFrame.AbsolutePosition)
				BoundingCorner2 = BoundingCorner1 + CurrentFrame.AbsoluteSize
			end
		end
	end
	if BoundingCorner1 then
		return BoundingCorner1, BoundingCorner2 - BoundingCorner1
	end

	return Frame.AbsolutePosition, Frame.AbsolutePosition + Frame.AbsoluteSize
end

return module
