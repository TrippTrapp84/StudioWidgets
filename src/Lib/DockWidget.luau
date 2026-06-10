local PluginUtil = require(script.Parent.Parent.Util.Plugin)

local Class = {}
Class.__index = Class

type Config = {
	Name: string?,
	WidgetInfo: DockWidgetPluginGuiInfo?
}

function Class.new(Data: Config)
	local self = setmetatable({}, Class)
	self.Name = Data.Name or "Widget"
	self.WidgetInfo = Data.WidgetInfo or DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		true,   -- Widget will be initially enabled
		false,  -- Don't override the previous enabled state
		200,    -- Default width of the floating window
		300,    -- Default height of the floating window
		150,    -- Minimum width of the floating window
		150  	-- Minimum height of the floating window
	)
	
	self.Widget = PluginUtil.GetPluginDistributorObject():CreateDockWidgetPluginGuiAsync(self.Name, self.WidgetInfo)
	self.Widget.Title = self.Name
	
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
	
	return self
end

function Class:SetEnabled(Enabled)
	self.Widget.Enabled = Enabled or not self.Widget.Enabled
end

function Class:AddChild(Child)
	Child.Parent = self.WidgetBackground
end

function Class:BindToClose(Func)
	self.Widget:BindToClose(Func)
end

return Class