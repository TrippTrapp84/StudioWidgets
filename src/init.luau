local PluginUtil = require(script.Util.Plugin)
local Types = require(script.Types)

local StudioWidgets = {}

StudioWidgets.Widgets = require(script.Lib)

export type WidgetBase<T = {}> = Types.WidgetBase<T>
export type DockWidget = Types.DockWidget
export type CustomTextButton = Types.CustomTextButton
export type ImageButtonWithText = Types.ImageButtonWithText
export type StatefulImageButton = Types.StatefulImageButton
export type LabeledCheckbox = Types.LabeledCheckbox
export type LabeledRadioButton = Types.LabeledRadioButton
export type LabeledTextInput = Types.LabeledTextInput
export type TransparentTextInput = Types.TransparentTextInput
export type LabeledDropdownMenu<T = unknown> = Types.LabeledDropdownMenu<T>
export type LabeledInstanceSelection = Types.LabeledInstanceSelection
export type LabeledSlider = Types.LabeledSlider
export type VerticalScrollingFrame = Types.VerticalScrollingFrame
export type VerticallyScalingListFrame = Types.VerticallyScalingListFrame
export type VerticallyResizableListFrame = Types.VerticallyResizableListFrame
export type LabeledMultiChoice = Types.LabeledMultiChoice
export type CollapsibleTitledSection = Types.CollapsibleTitledSection

function StudioWidgets.Load(plugin: Plugin)
    PluginUtil.SetPluginDistributorObject(plugin)
end

return StudioWidgets