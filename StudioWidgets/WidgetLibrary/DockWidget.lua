--// SERVICES
local RunServ = game:GetService("RunService")
local plugin = _G.StudioWidgetsPluginGlobalDistributorObject

--// REQUIRES

--// CONSTANTS
local NULL = {}

--// CONSTRUCTOR
local Handler = {}
Handler.__index = Handler

local function DefaultValues()
	return {
		Name = "Widget",
		WidgetInfo = DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
			true,   -- Widget will be initially enabled
			false,  -- Don't override the previous enabled state
			200,    -- Default width of the floating window
			300,    -- Default height of the floating window
			150,    -- Minimum width of the floating window
			150  	-- Minimum height of the floating window
		)
	}
end

function Handler.new(Data)
	Data = Data or {}
	local Obj = {}
	
	setmetatable(Obj,Handler)
	
	for i,v in pairs(DefaultValues()) do
		Obj[i] = Data[i] or v
		if v == NULL then error("Missing data for widget constructor:",i) end
	end
	
	Obj.Widget = plugin:CreateDockWidgetPluginGui(Obj.Name, Obj.WidgetInfo)
	Obj.Widget.Title = Obj.Name
	
	Obj.WidgetBackground = Instance.new("Frame")
	Obj.WidgetBackground.Name = "Background"
	Obj.WidgetBackground.Size = UDim2.fromScale(1,1)
	Obj.WidgetBackground.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	Obj.WidgetBackground.Parent = Obj.Widget
	Obj.WidgetBackground.ClipsDescendants = false
	Obj.WidgetBackground.ZIndex = -1000000
	
	Obj.Connections = {}
	
	Obj.Connections[1] = settings().Studio.ThemeChanged:Connect(function()
		Obj.WidgetBackground.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	end)
	
	return Obj,Obj.Widget
end

--// MEMBER FUNCTIONS
function Handler:SetEnabled(Enabled)
	self.Widget.Enabled = Enabled or not self.Widget.Enabled
end

function Handler:AddChild(Child)
	Child.Parent = self.WidgetBackground
end

function Handler:BindToClose(Func)
	self.Widget:BindToClose(Func)
end

--// RETURN
return Handler