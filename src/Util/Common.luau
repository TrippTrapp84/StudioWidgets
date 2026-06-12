local Util = {}

function Util.AddChildren(Parent: {AddChild: <T>(self: any, Child: T) -> T}, Children: {any})
    for _, Child in Children do
        if typeof(Child) ~= "table" then continue end
        if not Child.GetFrame then continue end

        Parent:AddChild(Child:GetFrame())
    end
end

return Util