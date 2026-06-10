local Util = {}

function Util.SetPluginDistributorObject(PluginDistributor: Plugin)
    Util.PluginDistributorObject = PluginDistributor
end

function Util.GetPluginDistributorObject(): Plugin
    assert(Util.PluginDistributorObject :: never ~= nil, "Attempt to fetch PluginDistributorObject before it was initialized")

    return Util.PluginDistributorObject
end

return Util