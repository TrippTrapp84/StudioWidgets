local Signal = require(script.Parent.Util.Signal)

type Signal<T...> = Signal.Signal<T...>

local Types = {}

export type WidgetBase<T = {}> = T & {
	AddChild: (<I>(self: WidgetBase<T>, I) -> I)?,
	GetFrame: ((self: WidgetBase<T>) -> GuiObject)?
}

export type DropdownOption = {
	Name: string,
	Value: unknown,
	Identifier: string?
}

export type MultiChoiceOption = {
	Name: string,
	Value: unknown
}

type ButtonEntry = {
	Button: TextButton,
	Connection: RBXScriptConnection,
	Activate: (InternalTrigger: boolean?) -> (),
}

export type CustomTextButton = WidgetBase<{
	LabelText: string,
	Label: TextLabel,
	Button: ImageButton,
	Clicked: boolean,
	Hovered: boolean,

	UpdateButtonVisual: (self: CustomTextButton) -> (),
	GetFrame: (self: CustomTextButton) -> ImageButton,
}>

export type ImageButtonWithText = WidgetBase<{
	Title: string,
	ButtonSize: UDim2,
	Icon: string,
	ImageSize: UDim2,
	ImagePosition: UDim2,
	TextSize: UDim2,
	TextPosition: UDim2,
	LayoutOrder: number,
	Button: ImageButton,
	Clicked: boolean,
	Hovered: boolean,
	Selected: boolean,

	UpdateButtonVisual: (self: ImageButtonWithText) -> (),
	GetFrame: (self: ImageButtonWithText) -> ImageButton,
	SetSelected: (self: ImageButtonWithText, Selected: boolean) -> (),
	GetSelected: (self: ImageButtonWithText) -> boolean,
}>

export type StatefulImageButton = WidgetBase<{
	Icon: string,
	Size: UDim2,
	Button: ImageButton,
	Hovered: boolean,
	Clicked: boolean,
	Selected: boolean,

	UpdateButtonVisual: (self: StatefulImageButton) -> (),
	SetSelected: (self: StatefulImageButton, Selected: boolean) -> (),
	GetSelected: (self: StatefulImageButton) -> boolean,
	GetFrame: (self: StatefulImageButton) -> ImageButton,
}>

export type LabeledCheckbox = WidgetBase<{
	Title: string,
	InitialValue: boolean,
	Disabled: boolean,
	Inset: number,
	Frame: Frame,
	Button: ImageButton,
	Label: TextLabel,
	CheckImage: ImageLabel,
	FullBackgroundButton: TextButton,
	UseDisabledOverride: boolean,
	DisabledOverride: boolean,
	Value: boolean,
	ValueChanged: Signal<boolean, boolean>,
	DisabledChanged: Signal<boolean>,

	MaybeToggleState: (self: LabeledCheckbox, Internal: boolean?) -> (),
	SetupMouseClickHandling: (self: LabeledCheckbox) -> (),
	HandleUpdatedValue: (self: LabeledCheckbox, InternalTrigger: boolean?) -> (),
	UseSmallSize: (self: LabeledCheckbox) -> (),
	GetFrame: (self: LabeledCheckbox) -> Frame,
	GetValue: (self: LabeledCheckbox) -> boolean,
	GetLabel: (self: LabeledCheckbox) -> TextLabel,
	GetButton: (self: LabeledCheckbox) -> ImageButton,
	SetDisabled: (self: LabeledCheckbox, NewDisabled: boolean) -> (),
	UpdateFontColors: (self: LabeledCheckbox) -> (),
	DisableWithOverrideValue: (self: LabeledCheckbox, OverrideValue: boolean) -> (),
	GetDisabled: (self: LabeledCheckbox) -> boolean,
	SetValue: (self: LabeledCheckbox, NewValue: boolean, Internal: boolean?) -> (),
}>

export type LabeledRadioButton = LabeledCheckbox

export type LabeledTextInput = WidgetBase<{
	Title: string,
	InitialValue: string,
	Width: number,
	Inset: number,
	MaxGraphemes: number,
	Value: string,
	Frame: Frame,
	Label: TextLabel,
	TextBox: TextBox,
	ValueChanged: Signal<string>,
	FocusLost: Signal<string>,

	GetFrame: (self: LabeledTextInput) -> Frame,
	GetValue: (self: LabeledTextInput) -> string,
	GetMaxGraphemes: (self: LabeledTextInput) -> number,
	SetMaxGraphemes: (self: LabeledTextInput, NewValue: number) -> (),
	SetValue: (self: LabeledTextInput, NewValue: string) -> (),
}>

export type TransparentTextInput = WidgetBase<{
	InitialValue: string,
	Inset: number,
	Width: number,
	ClearOnFocus: boolean,
	MaxGraphemes: number,
	Value: string,
	Frame: Frame,
	TextBox: TextBox,
	ValueChanged: Signal<string>,
	FocusLost: Signal<string>,

	GetFrame: (self: TransparentTextInput) -> Frame,
	GetValue: (self: TransparentTextInput) -> string,
	GetMaxGraphemes: (self: TransparentTextInput) -> number,
	SetMaxGraphemes: (self: TransparentTextInput, NewValue: number) -> (),
	SetValue: (self: TransparentTextInput, NewValue: string) -> (),
}>

export type LabeledDropdownMenu = WidgetBase<{
	Title: string,
	Inset: number,
	Options: {DropdownOption},
	DropdownButtonHeight: number,
	ExpandedSize: number,
	CanvasSize: number?,
	SectionFrame: Frame,
	TitleLabel: TextLabel,
	DropButton: TextButton,
	ContentsFrame: ScrollingFrame,
	InvisFrame: Frame,
	ButtonArray: {[string]: ButtonEntry},
	Selected: unknown,
	Expanded: boolean,
	DropdownDB: boolean,
	SelectionChanged: Signal<unknown, boolean>,

	SetChoice: (self: LabeledDropdownMenu, Id: string) -> (),
	GetChoice: (self: LabeledDropdownMenu) -> unknown,
	GetFrame: (self: LabeledDropdownMenu) -> Frame,
	ChangeLabel: (self: LabeledDropdownMenu, LabelText: string) -> (),
	AddSelection: (self: LabeledDropdownMenu, Selection: DropdownOption) -> (),
	RemoveSelection: (self: LabeledDropdownMenu, Identifier: string) -> (),
	AddSelectionsFromTable: (self: LabeledDropdownMenu, SelectionTable: {DropdownOption}) -> (),
	ResetChoice: (self: LabeledDropdownMenu) -> (),
	ToggleExpand: (self: LabeledDropdownMenu) -> (),
	Retract: (self: LabeledDropdownMenu) -> (),
	Expand: (self: LabeledDropdownMenu) -> (),
	UpdateSize: (self: LabeledDropdownMenu) -> (),
}>

export type LabeledInstanceSelection = WidgetBase<{
	Title: string,
	Inset: number,
	Width: number,
	InitialValue: Instance?,
	Value: Instance?,
	Frame: Frame,
	Label: TextLabel,
	TextBox: TextButton,
	SelectionChanged: Signal<Instance?, boolean>,

	SetSelection: (self: LabeledInstanceSelection, Selected: Instance | false, ExternalTrigger: boolean?) -> (),
	GetFrame: (self: LabeledInstanceSelection) -> Frame,
}>

export type LabeledSlider = WidgetBase<{
	Title: string,
	Steps: number,
	Inset: number,
	InitialValue: number,
	Value: number,
	Frame: Frame,
	Label: TextLabel,
	Slider: GuiObject,
	SliderValue: IntValue,
	Thumb: ImageButton,
	PreThumbImage: ImageLabel,
	PostThumbImage: ImageLabel,
	ValueChanged: Signal<number>,

	GetFrame: (self: LabeledSlider) -> Frame,
	SetValue: (self: LabeledSlider, NewValue: number) -> (),
	GetValue: (self: LabeledSlider) -> number,
}>

export type VerticalScrollingFrame = WidgetBase<{
	Section: Frame,
	ScrollFrame: ScrollingFrame,
	ScrollBackground: Frame,
	UiListLayout: UIListLayout,
    ChildCount: number,

    AddChild: <T>(self: VerticalScrollingFrame, Child: T) -> T,
	UpdateScrollbarBackingVisibility: (self: VerticalScrollingFrame) -> (),
	UpdateScrollingFrameCanvas: (self: VerticalScrollingFrame) -> (),
	GetFrame: (self: VerticalScrollingFrame) -> Frame,
}>

export type VerticallyScalingListFrame = WidgetBase<{
	ChildCount: number,
	Frame: Frame,
	UiListLayout: UIListLayout,
	Resized: Signal<>,

	AddBottomPadding: (self: VerticallyScalingListFrame) -> (),
	GetFrame: (self: VerticallyScalingListFrame) -> Frame,
	AddChild: <T>(self: VerticallyScalingListFrame, Child: T) -> T,
}>

export type VerticallyResizableListFrame = WidgetBase<{
	MaximumHeight: number,
	MinimumHeight: number,
	WidgetParent: DockWidgetPluginGui?,
	SizeLocked: boolean,
	ChildCount: number,
	Frame: Frame,
	UiListLayout: UIListLayout,
	Resized: Signal<number>,

	AddBottomPadding: (self: VerticallyResizableListFrame) -> (),
	GetFrame: (self: VerticallyResizableListFrame) -> Frame,
	AddChild: <T>(self: VerticallyResizableListFrame, Child: T) -> T,
	SetLocked: (self: VerticallyResizableListFrame, Locked: boolean) -> (),
}>

export type LabeledMultiChoice = WidgetBase<{
	Title: string,
	Choices: {MultiChoiceOption},
	SelectedIndex: number,
	ButtonObjsByIndex: {[number]: LabeledRadioButton},
	Vsl: VerticallyScalingListFrame,
	ValueChanged: Signal<number>,

	SetSelectedIndex: (self: LabeledMultiChoice, SelectedIndex: number) -> (),
	GetSelectedIndex: (self: LabeledMultiChoice) -> number,
	GetFrame: (self: LabeledMultiChoice) -> Frame,
	MakeRadioButtons: (self: LabeledMultiChoice, Choices: {MultiChoiceOption}) -> Frame,
	AddRadioButton: (self: LabeledMultiChoice, ParentFrame: Frame, Index: number, ChoiceData: MultiChoiceOption) -> (),
}>

export type CollapsibleTitledSection = WidgetBase<{
	Minimized: boolean,
	ColorOverrides: boolean,
	LatestClickTime: number,
	TitleBarColor: Color3?,

	Frame: Frame & {
		TitleBarVisual: ImageButton & {
			TitleLabel: TextLabel
		}
	},
	ListLayout: UIListLayout,
	ContentsFrame: Frame,
	TitleBarButton: ImageButton,
	TitleBarButtonColorConnection: RBXScriptConnection,
	MinimizeButton: ImageButton,
	TitleTextInput: TransparentTextInput?,

	Pressed: Signal<>,
	DoublePressed: Signal<>,

    AddChild: <T>(self: CollapsibleTitledSection, Child: T) -> T,
	GetFrame: (self: CollapsibleTitledSection) -> Frame,
	UpdateSize: (self: CollapsibleTitledSection) -> (),
	UpdateMinimizeButton: (self: CollapsibleTitledSection) -> (),
	SetCollapsed: (self: CollapsibleTitledSection, Collapsed: boolean) -> (),
	ToggleCollapsed: (self: CollapsibleTitledSection) -> (),
	GetTitleInput: (self: CollapsibleTitledSection) -> TransparentTextInput?,
	SetTitle: (self: CollapsibleTitledSection, Title: string) -> (),
	SetTitleBarColor: (self: CollapsibleTitledSection, Color: Color3) -> (),
	SetTitleBarColorOverrides: (self: CollapsibleTitledSection, Overrides: boolean) -> (),
	CreateTitleBar: (self: CollapsibleTitledSection, Title: string, Inset: number, Height: number, Renamable: boolean, Minimizable: boolean) -> (),
}>

return Types
