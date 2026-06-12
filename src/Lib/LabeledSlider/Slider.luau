local function GetLayerCollectorAncestor(instance: Instance)
	local LocalInstance: Instance? = instance
	while LocalInstance and not LocalInstance:IsA("LayerCollector") do
		LocalInstance = LocalInstance.Parent
	end
	return LocalInstance
end

local function SetSliderPos(NewAbsPosX: number, Slider: GuiObject, SliderPosition: IntValue, Bar: GuiObject, Steps: number)
	local NewStep = Steps - 1 --otherwise we really get one more step than we want
	local RelativePosX = math.min(1, math.max(0, (NewAbsPosX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X))
	local WholeNum, Remainder = math.modf(RelativePosX * NewStep)
	if Remainder > 0.5 then
		WholeNum = WholeNum + 1
	end
	RelativePosX = WholeNum / NewStep

	local Result = math.ceil(RelativePosX * NewStep)
	if SliderPosition.Value ~= (Result + 1) then --only update if we moved a step
		SliderPosition.Value = Result + 1
		Slider.Position = UDim2.new(RelativePosX, -Slider.AbsoluteSize.X / 2, Slider.Position.Y.Scale, Slider.Position.Y.Offset)
	end
end

local function CancelSlide(AreaSoak: GuiObject)
	AreaSoak.Visible = false
end

type Slider = GuiObject & {
	SliderSteps: IntValue,
	AreaSoak: TextButton,
	SliderPosition: IntValue,
	Bar: TextButton & {
		Slider: ImageButton
	}
}

local function CreateSlider(Steps: number, Width: number, Position: UDim2): (Slider, IntValue, IntValue)
	local SliderGui = Instance.new("Frame")
	SliderGui.Size = UDim2.new(1, 0, 1, 0)
	SliderGui.BackgroundTransparency = 1
	SliderGui.Name = "SliderGui"

	local SliderSteps = Instance.new("IntValue")
	SliderSteps.Name = "SliderSteps"
	SliderSteps.Value = Steps
	SliderSteps.Parent = SliderGui

	local AreaSoak = Instance.new("TextButton")
	AreaSoak.Name = "AreaSoak"
	AreaSoak.Text = ""
	AreaSoak.BackgroundTransparency = 1
	AreaSoak.Active = false
	AreaSoak.Size = UDim2.new(1, 0, 1, 0)
	AreaSoak.Visible = false
	AreaSoak.ZIndex = 4

	SliderGui.AncestryChanged:Connect(function(Child, Parent)
		if Parent == nil then
			AreaSoak.Parent = nil
		else
			AreaSoak.Parent = GetLayerCollectorAncestor(SliderGui)
		end
	end)

	local SliderPosition = Instance.new("IntValue")
	SliderPosition.Name = "SliderPosition"
	SliderPosition.Value = 0
	SliderPosition.Parent = SliderGui

	local Bar = Instance.new("TextButton")
	Bar.Text = ""
	Bar.AutoButtonColor = false
	Bar.Name = "Bar"
	Bar.BackgroundColor3 = Color3.new(0, 0, 0)
	if type(Width) == "number" then
		Bar.Size = UDim2.new(0, Width, 0, 5)
	else
		Bar.Size = UDim2.new(0, 200, 0, 5)
	end
	Bar.BorderColor3 = Color3.new(95 / 255, 95 / 255, 95 / 255)
	Bar.ZIndex = 2
	Bar.Parent = SliderGui

	Bar.Position = Position

	local Slider = Instance.new("ImageButton")
	Slider.Name = "Slider"
	Slider.BackgroundTransparency = 1
	Slider.Image = "rbxasset://textures/ui/Slider.png"
	Slider.Position = UDim2.new(0, 0, 0.5, -10)
	Slider.Size = UDim2.new(0, 20, 0, 20)
	Slider.ZIndex = 3
	Slider.Parent = Bar

	local AreaSoakMouseMoveCon: RBXScriptConnection? = nil

	AreaSoak.MouseLeave:Connect(function()
		if AreaSoak.Visible then
			CancelSlide(AreaSoak)
		end
	end)
	AreaSoak.MouseButton1Up:Connect(function()
		if AreaSoak.Visible then
			CancelSlide(AreaSoak)
		end
	end)

	Slider.MouseButton1Down:Connect(function()
		AreaSoak.Visible = true
		if AreaSoakMouseMoveCon then
			AreaSoakMouseMoveCon:Disconnect()
		end
		AreaSoakMouseMoveCon = AreaSoak.MouseMoved:Connect(function(x, y)
			SetSliderPos(x, Slider, SliderPosition, Bar, Steps)
		end)
	end)

	Slider.MouseButton1Up:Connect(function()
		CancelSlide(AreaSoak)
	end)

	SliderPosition.Changed:Connect(function(Prop)
		SliderPosition.Value = math.min(Steps, math.max(1, SliderPosition.Value))
		local RelativePosX = (SliderPosition.Value - 1) / (Steps - 1)
		Slider.Position = UDim2.new(RelativePosX, -Slider.AbsoluteSize.X / 2, Slider.Position.Y.Scale, Slider.Position.Y.Offset)
	end)

	Bar.MouseButton1Down:Connect(function(x, y)
		SetSliderPos(x, Slider, SliderPosition, Bar, Steps)
	end)

	return SliderGui :: Slider, SliderPosition, SliderSteps
end

return CreateSlider
