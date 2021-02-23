local WidgetLibrary = script.Parent.WidgetLibrary:GetChildren()

local Initialized = false

local function Return(plugin)
    if not Initialized then
        Initialized = true
        local TempLib = WidgetLibrary
        WidgetLibrary = {}
        _G.StudioWidgetsPluginGlobalDistributorObject = plugin
        for i,v in pairs(TempLib) do
            WidgetLibrary[v.Name] = require(v)
        end
    end
    return WidgetLibrary
end

return Return