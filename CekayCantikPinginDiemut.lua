repeat task.wait() until game:IsLoaded()

local p=game:GetService("Players").LocalPlayer
local ps=game:GetService("Players")
local rs=game:GetService("RunService")

local function c() return p.Character or p.CharacterAdded:Wait() end
local ch=c()
local r=ch:WaitForChild("HumanoidRootPart")
local h=ch:WaitForChild("Humanoid")

h.MaxHealth=9e9
h.Health=9e9

-- GUI MANUAL
local g=Instance.new("ScreenGui",p:WaitForChild("PlayerGui"))
g.Name="CekayUI"

local f=Instance.new("Frame",g)
f.Size=UDim2.new(0,200,0,260)
f.Position=UDim2.new(0,20,0.3,0)
f.BackgroundColor3=Color3.fromRGB(20,20,20)

local function btn(txt,y,cb)
 local b=Instance.new("TextButton",f)
 b.Size=UDim2.new(1,-10,0,30)
 b.Position=UDim2.new(0,5,0,y)
 b.Text=txt
 b.BackgroundColor3=Color3.fromRGB(40,40,40)
 b.TextColor3=Color3.new(1,1,1)
 b.MouseButton1Click:Connect(cb)
 return b
end

-- FLY
local fly=false
local spd=130
local bv,bg

function startFly()
 fly=true
 h.PlatformStand=true
 bv=Instance.new("BodyVelocity",r)
 bv.MaxForce=Vector3.new(1e6,1e6,1e6)
 bg=Instance.new("BodyGyro",r)
 bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
 rs.RenderStepped:Connect(function()
  if not fly then return end
  local cam=workspace.CurrentCamera
  bv.Velocity=cam.CFrame.LookVector*spd
  bg.CFrame=cam.CFrame
 end)
end

function stopFly()
 fly=false
 h.PlatformStand=false
 if bv then bv:Destroy() end
 if bg then bg:Destroy() end
end

-- AURA
local aura=false
rs.Heartbeat:Connect(function()
 if not aura then return end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl~=p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
   if (pl.Character.HumanoidRootPart.Position-r.Position).Magnitude<50 then
    pl.Character:BreakJoints()
   end
  end
 end
end)

-- FREEZE
local freeze=false
rs.Heartbeat:Connect(function()
 if not freeze then return end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl~=p and pl.Character then
   local hu=pl.Character:FindFirstChild("Humanoid")
   local ro=pl.Character:FindFirstChild("HumanoidRootPart")
   if hu and ro then
    hu.PlatformStand=true
    ro.AssemblyLinearVelocity=Vector3.new()
   end
  end
 end
end)

-- ESP
local esp=false
rs.Heartbeat:Connect(function()
 if not esp then return end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl~=p and pl.Character and not pl.Character:FindFirstChild("HL") then
   local hl=Instance.new("Highlight")
   hl.Name="HL"
   hl.Adornee=pl.Character
   hl.FillColor=Color3.fromRGB(255,0,255)
   hl.Parent=pl.Character
  end
 end
end)

-- BUTTONS
btn("Fly ON/OFF",10,function()
 if fly then stopFly() else startFly() end
end)

btn("Aura ON/OFF",50,function()
 aura=not aura
end)

btn("Freeze ON/OFF",90,function()
 freeze=not freeze
end)

btn("ESP ON/OFF",130,function()
 esp=not esp
end)

btn("Speed+",170,function()
 spd=spd+50
end)

btn("Speed-",210,function()
 spd=math.max(50,spd-50)
end)

-- RESPAWN FIX
p.CharacterAdded:Connect(function(n)
 ch=n
 r=n:WaitForChild("HumanoidRootPart")
 h=n:WaitForChild("Humanoid")
 h.MaxHealth=9e9
 h.Health=9e9
end)
