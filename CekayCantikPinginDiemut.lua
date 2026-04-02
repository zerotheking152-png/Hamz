repeat task.wait() until game:IsLoaded()

local p=game:GetService("Players").LocalPlayer
if not p then return end
local ps=game:GetService("Players")
local rs=game:GetService("RunService")

local function c() return p.Character or p.CharacterAdded:Wait() end
local ch=c()
local r=ch:WaitForChild("HumanoidRootPart")
local h=ch:WaitForChild("Humanoid")

h.MaxHealth=9e9
h.Health=9e9
h.HealthChanged:Connect(function()
 if h.Health<9e9 then h.Health=9e9 end
end)

-- UI
local Rayfield
pcall(function()
 Rayfield=loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end)

if not Rayfield then
 local g=Instance.new("ScreenGui",p:WaitForChild("PlayerGui"))
 local t=Instance.new("TextLabel",g)
 t.Size=UDim2.new(0,300,0,50)
 t.Position=UDim2.new(0.5,-150,0,100)
 t.Text="LOADED"
 t.TextScaled=true
 t.BackgroundColor3=Color3.new()
 t.TextColor3=Color3.new(1,1,1)
 return
end

local w=Rayfield:CreateWindow({Name="CekayCantik"})
local t=w:CreateTab("Main",4483362458)

-- FLY
local f=false
local s=130
local bv,bg

function fly()
 if f then return end
 f=true
 h.PlatformStand=true
 bv=Instance.new("BodyVelocity",r)
 bv.MaxForce=Vector3.new(1e6,1e6,1e6)
 bg=Instance.new("BodyGyro",r)
 bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
 rs.RenderStepped:Connect(function()
  if not f then return end
  local cam=workspace.CurrentCamera
  bv.Velocity=cam.CFrame.LookVector*s
  bg.CFrame=cam.CFrame
 end)
end

function unfly()
 f=false
 h.PlatformStand=false
 if bv then bv:Destroy() end
 if bg then bg:Destroy() end
end

-- AURA
local aura=false
local ar=50
local ac

function auraOn()
 if aura then return end
 aura=true
 ac=rs.Heartbeat:Connect(function()
  for _,pl in ipairs(ps:GetPlayers()) do
   if pl~=p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
    local d=(pl.Character.HumanoidRootPart.Position-r.Position).Magnitude
    if d<=ar then
     pl.Character:BreakJoints()
    end
   end
  end
 end)
end

function auraOff()
 aura=false
 if ac then ac:Disconnect() end
end

-- FREEZE
local fr=false
local frc

function frOn()
 if fr then return end
 fr=true
 frc=rs.Heartbeat:Connect(function()
  for _,pl in ipairs(ps:GetPlayers()) do
   if pl~=p and pl.Character then
    local hu=pl.Character:FindFirstChild("Humanoid")
    local ro=pl.Character:FindFirstChild("HumanoidRootPart")
    if hu and ro then
     hu.PlatformStand=true
     ro.AssemblyLinearVelocity=Vector3.new()
     ro.AssemblyAngularVelocity=Vector3.new()
    end
   end
  end
 end)
end

function frOff()
 fr=false
 if frc then frc:Disconnect() end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl~=p and pl.Character then
   local hu=pl.Character:FindFirstChild("Humanoid")
   if hu then hu.PlatformStand=false end
  end
 end
end

-- BURN
local br=false
local brc

function brOn()
 if br then return end
 br=true
 brc=rs.Heartbeat:Connect(function()
  for _,pl in ipairs(ps:GetPlayers()) do
   if pl~=p and pl.Character then
    local ro=pl.Character:FindFirstChild("HumanoidRootPart")
    if ro and not ro:FindFirstChild("Fire") then
     local f=Instance.new("Fire")
     f.Size=6
     f.Heat=25
     f.Parent=ro
    end
   end
  end
 end)
end

function brOff()
 br=false
 if brc then brc:Disconnect() end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl~=p and pl.Character then
   local ro=pl.Character:FindFirstChild("HumanoidRootPart")
   if ro then
    local f=ro:FindFirstChild("Fire")
    if f then f:Destroy() end
   end
  end
 end
end

-- ESP
local esp=false
local ec

function espOn()
 if esp then return end
 esp=true
 ec=rs.Heartbeat:Connect(function()
  for _,pl in ipairs(ps:GetPlayers()) do
   if pl~=p and pl.Character and not pl.Character:FindFirstChild("HL") then
    local hl=Instance.new("Highlight")
    hl.Name="HL"
    hl.Adornee=pl.Character
    hl.FillColor=Color3.fromRGB(255,0,255)
    hl.OutlineColor=Color3.new(1,1,1)
    hl.FillTransparency=0.5
    hl.Parent=pl.Character
   end
  end
 end)
end

function espOff()
 esp=false
 if ec then ec:Disconnect() end
 for _,pl in ipairs(ps:GetPlayers()) do
  if pl.Character then
   local hl=pl.Character:FindFirstChild("HL")
   if hl then hl:Destroy() end
  end
 end
end

-- UI
t:CreateToggle({Name="Fly",CurrentValue=false,Callback=function(v)if v then fly() else unfly() end end})
t:CreateSlider({Name="Speed",Range={50,300},CurrentValue=130,Callback=function(v)s=v end})
t:CreateToggle({Name="Aura",CurrentValue=false,Callback=function(v)if v then auraOn() else auraOff() end end})
t:CreateToggle({Name="Freeze",CurrentValue=false,Callback=function(v)if v then frOn() else frOff() end end})
t:CreateToggle({Name="Burn",CurrentValue=false,Callback=function(v)if v then brOn() else brOff() end end})
t:CreateToggle({Name="ESP",CurrentValue=false,Callback=function(v)if v then espOn() else espOff() end end})

-- RESPAWN
p.CharacterAdded:Connect(function(n)
 ch=n
 r=n:WaitForChild("HumanoidRootPart")
 h=n:WaitForChild("Humanoid")
 h.MaxHealth=9e9
 h.Health=9e9
end)
