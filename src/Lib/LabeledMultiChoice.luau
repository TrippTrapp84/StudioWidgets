----------------------------------------
--
-- LabeledMultiChoice.lua
--
-- Creates a frame containing a label and list of choices, of which exactly one
-- is always selected.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local Signal = require(script.Parent.Parent.Util.Signal)
local Types = require(script.Parent.Parent.Types)
local LabeledRadioButton = require(script.Parent.LabeledRadioButton)
local LabeledCheckbox = require(script.Parent.LabeledCheckbox)
local VerticallyScalingListFrame = require(script.Parent.VerticallyScalingListFrame)

local RADIO_BUTTONS_HP_PADDING = GuiUtilities.RadioButtonsHPadding

local Class = {}
Class.__index = Class

type LabeledRadioButton = Types.LabeledRadioButton
type LabeledMultiChoice = Types.LabeledMultiChoice
type MultiChoiceOption = Types.MultiChoiceOption

type Config = {
	Title: string,
	Choices: {MultiChoiceOption}?,
	InitialChoice: number?
}

function Class.new(Data: Config): LabeledMultiChoice
	local self = (setmetatable({}, Class) :: never) :: LabeledMultiChoice

	self.Title = Data.Title
	self.Choices = Data.Choices or {}

	self.ButtonObjsByIndex = {}
	self.ValueChanged = Signal.new()

	local Vsl = VerticallyScalingListFrame.new()
	Vsl:AddBottomPadding()

	local TitleLabel = GuiUtilities.MakeFrameWithSubSectionLabel("Title", self.Title)
	Vsl:AddChild(TitleLabel)

	-- Container for cells.
	local CellFrame = self:MakeRadioButtons(self.Choices)
	Vsl:AddChild(CellFrame)

	self.Vsl = Vsl

	self:SetSelectedIndex(Data.InitialChoice or 0)

	return self
end

function Class:SetSelectedIndex(SelectedIndex: number)
	local self = self :: LabeledMultiChoice

	self.SelectedIndex = SelectedIndex
	for I = 1, #self.ButtonObjsByIndex do
		self.ButtonObjsByIndex[I]:SetValue(I == SelectedIndex)
	end

	self.ValueChanged:Fire(self.SelectedIndex)
end

function Class:GetSelectedIndex()
	local self = self :: LabeledMultiChoice

	return self.SelectedIndex
end

function Class:GetFrame()
	local self = self :: LabeledMultiChoice

	return self.Vsl:GetFrame()
end

-- Small checkboxes are a different entity.
-- All the bits are smaller.
-- Fixed width instead of flood-fill.
-- Box comes first, then label.
function Class:MakeRadioButtons(Choices: {MultiChoiceOption})
	local self = self :: LabeledMultiChoice

	local Frame = GuiUtilities.MakeFrame("RadioButtons")
	Frame.BackgroundTransparency = 1

	local Padding = Instance.new("UIPadding")
	Padding.PaddingLeft = UDim.new(0, GuiUtilities.StandardLineLabelLeftMargin)
	Padding.PaddingRight = UDim.new(0, GuiUtilities.StandardLineLabelLeftMargin)
	Padding.Parent = Frame

	-- Make a grid to put checkboxes in.
	local UiGridLayout = Instance.new("UIGridLayout")
	UiGridLayout.CellSize = LabeledCheckbox.MIN_FRAME_SIZE
	UiGridLayout.CellPadding = UDim2.new(
		0,
		RADIO_BUTTONS_HP_PADDING,
		0,
		GuiUtilities.StandardVMargin
	)
	UiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	UiGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	UiGridLayout.Parent = Frame
	UiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	for Order, Choice in pairs(Choices) do
		self:AddRadioButton(Frame, Order, Choice)
	end

	-- Sync size with content size.
	GuiUtilities.AdjustHeightDynamicallyToLayout(Frame, UiGridLayout)

	return Frame
end

function Class:AddRadioButton(ParentFrame: Frame, Index: number, ChoiceData: MultiChoiceOption)
	local self = self :: LabeledMultiChoice

	local RadioButtonObj = LabeledRadioButton.new{
		Title = ChoiceData.Name
	}
	self.ButtonObjsByIndex[Index] = RadioButtonObj

	RadioButtonObj.ValueChanged:Connect(function(Value)
		-- If we notice the button going from off to on, and it disagrees with
		-- our current notion of selection, update selection.
		if (Value and self.SelectedIndex ~= Index) then
			self:SetSelectedIndex(Index)
		end
	end)

	RadioButtonObj:GetFrame().LayoutOrder = Index
	RadioButtonObj:GetFrame().Parent = ParentFrame
end

--// RETURN
return Class
