local PluginUtil = require(script.Parent.Parent.Util.Plugin)
local Types = require(script.Parent.Parent.Types)

local Class = {}
Class.__index = Class

type DockWidget = Types.DockWidget

type Config = {
	Name: string?,
	WidgetInfo: DockWidgetPluginGuiInfo?
}

function Class.new(Data: Config, Children: {Types.WidgetBase}?): DockWidget
	local self = (setmetatable({}, Class) :: never) :: DockWidget
	local Name = Data.Name or "Widget"
	
	self.Widget = PluginUtil.GetPluginDistributorObject():CreateDockWidgetPluginGuiAsync(Name, Data.WidgetInfo or DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		true,   -- Widget will be initially enabled
		false,  -- Don't override the previous enabled state
		200,    -- Default width of the floating window
		300,    -- Default height of the floating window
		150,    -- Minimum width of the floating window
		150  	-- Minimum height of the floating window
	))
	self.Widget.Title = Name
	
	self.WidgetBackground = Instance.new("Frame")
	self.WidgetBackground.Name = "Background"
	self.WidgetBackground.Size = UDim2.fromScale(1,1)
	self.WidgetBackground.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	self.WidgetBackground.Parent = self.Widget
	self.WidgetBackground.ClipsDescendants = false
	self.WidgetBackground.ZIndex = -1000000
	
	self.Connections = {}
	
	self.Connections[1] = settings().Studio.ThemeChanged:Connect(function()
		self.WidgetBackground.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	end)

	local Children: {Types.WidgetBase} = Children or {}

	for _, Child in pairs(Children) do
		if not Child.GetFrame then continue end
		self:AddChild(Child.GetFrame(Child))
	end

	return self
end

function Class:SetEnabled(Enabled: boolean)
	local self = self :: DockWidget

	self.Widget.Enabled = Enabled or not self.Widget.Enabled
end

function Class:AddChild(Child: Instance)
	local self = self :: DockWidget
	
	Child.Parent = self.WidgetBackground

	return Child
end

function Class:BindToClose(Func: () -> ())
	local self = self :: DockWidget
	
	self.Widget:BindToClose(Func)
end

return Class