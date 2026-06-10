----------------------------------------
--
-- LabeledMultiChoice.lua
--
-- Creates a frame containing a label and list of choices, of which exactly one 
-- is always selected.
--
----------------------------------------
local GuiUtilities = require(script.Parent.Parent.Util.GuiUtilities)
local LabeledRadioButton = require(script.Parent.LabeledRadioButton)
local LabeledCheckbox = require(script.Parent.LabeledCheckbox)
local VerticallyScalingListFrame = require(script.Parent.VerticallyScalingListFrame)

local RADIO_BUTTONS_HP_PADDING = GuiUtilities.kRadioButtonsHPadding

local Class = {}
Class.__index = Class

type MultiChoiceOption = {
	Name: string,
	Value: unknown
}

type Config = {
	Title: string,
	Choices: {MultiChoiceOption}?,
	InitialChoice: number?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)

	self.Title = Data.Title
	self.Choices = Data.Choices or {}

	self._buttonObjsByIndex = {}

	local vsl = VerticallyScalingListFrame.new()
	vsl:AddBottomPadding()

	local titleLabel = GuiUtilities.MakeFrameWithSubSectionLabel("Title", self.Title)
	vsl:AddChild(titleLabel)

	-- Container for cells.
	local cellFrame = self:_MakeRadioButtons(self.Choices)
	vsl:AddChild(cellFrame)

	self._vsl = vsl

	self:SetSelectedIndex(Data.InitialChoice or 0)

	return self
end

function Class:SetSelectedIndex(selectedIndex) 
	self._selectedIndex = selectedIndex
	for i = 1, #self._buttonObjsByIndex do 
		self._buttonObjsByIndex[i]:SetValue(i == selectedIndex)
	end

	if self._valueChangedFunction then 
		self._valueChangedFunction(self._selectedIndex)
	end
end

function Class:GetSelectedIndex()
	return self._selectedIndex
end

function Class:OnChanged<T>(vcf: ((Value: T?) -> ())?)
	self._valueChangedFunction = if vcf then function(Index)
		local Option = self.Options[Index]
		if not Option then
			vcf(nil)
			return
		end

		vcf(Option.Value)
	end else nil
end

function Class:GetFrame()
	return self._vsl:GetFrame()
end


-- Small checkboxes are a different entity.
-- All the bits are smaller.
-- Fixed width instead of flood-fill.
-- Box comes first, then label.
function Class:_MakeRadioButtons(choices: {MultiChoiceOption})
	local frame = GuiUtilities.MakeFrame("RadioButtons")
	frame.BackgroundTransparency = 1

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, GuiUtilities.StandardLineLabelLeftMargin)
	padding.PaddingRight = UDim.new(0, GuiUtilities.StandardLineLabelLeftMargin)
	padding.Parent = frame
	
	-- Make a grid to put checkboxes in.
	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = LabeledCheckbox.MIN_FRAME_SIZE
	uiGridLayout.CellPadding = UDim2.new(
		0,
		RADIO_BUTTONS_HP_PADDING,
		0,
		GuiUtilities.kStandardVMargin
	)
	uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uiGridLayout.Parent = frame
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	for Order, Choice in pairs(choices) do 
		self:_AddRadioButton(frame, Order, Choice)
	end

		-- Sync size with content size.
	GuiUtilities.AdjustHeightDynamicallyToLayout(frame, uiGridLayout)

	return frame
end

function Class:_AddRadioButton(parentFrame, index, choiceData)
	local radioButtonObj = LabeledRadioButton.new{
		Title = choiceData.Name
	}
	self._buttonObjsByIndex[index] = radioButtonObj

	radioButtonObj:SetValueChangedFunction(function(value)
		-- If we notice the button going from off to on, and it disagrees with 
		-- our current notion of selection, update selection.
		if (value and self._selectedIndex ~= index) then 
			self:SetSelectedIndex(index)
		end
	end)
	
	radioButtonObj:GetFrame().LayoutOrder = index
	radioButtonObj:GetFrame().Parent = parentFrame
end

--// RETURN
return Class