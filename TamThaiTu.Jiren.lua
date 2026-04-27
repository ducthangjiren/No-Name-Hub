--// SERVICES
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

--// SETTINGS
local fileName = "TTTHub.json"
local settings = {speed=false,jump=false}

pcall(function()
	if readfile and isfile(fileName) then
		settings = HttpService:JSONDecode(readfile(fileName))
	end
end)

local function save()
	if writefile then
		writefile(fileName,HttpService:JSONEncode(settings))
	end
end

--// GUI
local gui = Instance.new("ScreenGui",player.PlayerGui)
gui.Name = "TamThaiTuHub"

-- Toggle
local toggle = Instance.new("TextButton",gui)
toggle.Size = UDim2.new(0,120,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "TTT HUB"
toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggle.TextColor3 = Color3.new(1,1,1)

-- MAIN
local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,480,0,360)
main.Position = UDim2.new(0.5,-240,0.5,-180)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.Visible = false
main.Active = true
main.Draggable = true

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

-- TITLE
local title = Instance.new("TextLabel",main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🖤 Tam Thái Tử Hub"
title.BackgroundColor3 = Color3.fromRGB(15,15,15)
title.TextColor3 = Color3.new(1,1,1)

-- FPS (luôn hiện)
local fpsLabel = Instance.new("TextLabel",gui)
fpsLabel.Size = UDim2.new(0,120,0,30)
fpsLabel.Position = UDim2.new(1,-130,0,10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Text = "FPS: ..."

RunService.RenderStepped:Connect(function(dt)
	fpsLabel.Text = "FPS: "..math.floor(1/dt)
end)

-- TABS
local tabs = Instance.new("Frame",main)
tabs.Size = UDim2.new(1,0,0,40)
tabs.Position = UDim2.new(0,0,0,40)

local pages = Instance.new("Frame",main)
pages.Size = UDim2.new(1,0,1,-80)
pages.Position = UDim2.new(0,0,0,80)

local function tab(name,pos)
	local b = Instance.new("TextButton",tabs)
	b.Size = UDim2.new(0,160,1,0)
	b.Position = UDim2.new(0,(pos-1)*160,0,0)
	b.Text = name
	
	local p = Instance.new("Frame",pages)
	p.Size = UDim2.new(1,0,1,0)
	p.Visible = false
	
	b.MouseButton1Click:Connect(function()
		for _,v in pairs(pages:GetChildren()) do v.Visible=false end
		p.Visible=true
	end)
	
	return p
end

local tab1 = tab("Server",1)
local tab2 = tab("Player",2)
local tab3 = tab("Info",3)
tab1.Visible = true

--// SERVER HOP
local visited = {}

local function hop()
	local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"
	local data = HttpService:JSONDecode(game:HttpGet(url))
	
	for _,s in pairs(data.data) do
		if s.playing < s.maxPlayers and not visited[s.id] then
			visited[s.id] = true
			TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,player)
			break
		end
	end
end

local hopBtn = Instance.new("TextButton",tab1)
hopBtn.Size = UDim2.new(0,240,0,50)
hopBtn.Position = UDim2.new(0,20,0,20)
hopBtn.Text = "🔄 Hop Server"

hopBtn.MouseButton1Click:Connect(hop)

--// PLAYER
local speed = 16
local flying = false
local bv,bg

local function apply()
	local h = player.Character and player.Character:FindFirstChild("Humanoid")
	if h then
		h.WalkSpeed = settings.speed and speed or 16
		h.JumpPower = settings.jump and 80 or 50
	end
end

-- SPEED TOGGLE
local speedBtn = Instance.new("TextButton",tab2)
speedBtn.Size = UDim2.new(0,240,0,40)
speedBtn.Position = UDim2.new(0,20,0,20)
speedBtn.Text = "Speed"

speedBtn.MouseButton1Click:Connect(function()
	settings.speed = not settings.speed
	save()
	apply()
end)

-- JUMP
local jumpBtn = Instance.new("TextButton",tab2)
jumpBtn.Size = UDim2.new(0,240,0,40)
jumpBtn.Position = UDim2.new(0,20,0,70)
jumpBtn.Text = "Jump"

jumpBtn.MouseButton1Click:Connect(function()
	settings.jump = not settings.jump
	save()
	apply()
end)

-- SPEED +/- 
local up = Instance.new("TextButton",tab2)
up.Size = UDim2.new(0,110,0,40)
up.Position = UDim2.new(0,20,0,120)
up.Text = "+Speed"

local down = Instance.new("TextButton",tab2)
down.Size = UDim2.new(0,110,0,40)
down.Position = UDim2.new(0,140,0,120)
down.Text = "-Speed"

up.MouseButton1Click:Connect(function()
	speed = speed + 4
	apply()
end)

down.MouseButton1Click:Connect(function()
	speed = math.max(8,speed-4)
	apply()
end)

-- FLY
local flyBtn = Instance.new("TextButton",tab2)
flyBtn.Size = UDim2.new(0,240,0,50)
flyBtn.Position = UDim2.new(0,20,0,180)
flyBtn.Text = "🕊️ Fly"

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	
	if flying then
		bv = Instance.new("BodyVelocity",hrp)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		
		bg = Instance.new("BodyGyro",hrp)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		
		RunService.RenderStepped:Connect(function()
			if flying and hrp then
				bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
				bg.CFrame = workspace.CurrentCamera.CFrame
			end
		end)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

-- APPLY WHEN SPAWN
player.CharacterAdded:Connect(function()
	wait(1)
	apply()
end)
