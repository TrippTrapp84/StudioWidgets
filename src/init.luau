local PluginUtil = require(script.Util.Plugin)

local StudioWidgets = {}

StudioWidgets.Widgets = require(script.Lib)

function StudioWidgets.Load(plugin: Plugin)
    PluginUtil.SetPluginDistributorObject(plugin)
end

return StudioWidgets