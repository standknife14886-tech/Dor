-- T-F Doors ESP v2
-- Для планшета: меню в PlayerGui (CoreGui может блокироваться)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Lighting   = game:GetService("Lighting")
local UserInput  = game:GetService("UserInputService")
local LP         = Players.LocalPlayer

local C = {
    DoorESP      = true,
    LockedESP    = true,
    FakeESP      = true,
    EntityESP    = true,
    ItemESP      = true,
    FullBright   = true,
    ShowDist     = true,
    MaxDist      = 500,
    DoorCol      = Color3.fromRGB(0,255,120),
    LockCol      = Color3.fromRGB(255,60,60),
    FakeCol      = Color3.fromRGB(255,200,0),
    EntCol       = Color3.fromRGB(255,30,30),
    ItemCol      = Color3.fromRGB(0,180,255),
}

-- Fullbright
if C.FullBright then
    Lighting.Ambient = Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
end

local cache = {hl={}, bb={}}

local function setHL(part, color)
    if not part or not part.Parent then return end
    if cache.hl[part] and cache.hl[part].Parent then
        cache.hl[part].FillColor = color
        cache.hl[part].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.FillTransparency = 0.45
    h.OutlineColor = color
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = part
    h.Parent = part
    cache.hl[part] = h
end

local function setBB(part, text, color)
    if not part or not part.Parent then return end
    if cache.bb[part] and cache.bb[part].Parent then
        cache.bb[part].TextLabel.Text = text
        cache.bb[part].TextLabel.TextColor3 = color
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,140,0,32)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
    bb.Parent = part
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextColor3 = color
    tl.TextStrokeTransparency = 0
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.Parent = bb
    cache.bb[part] = bb
end

local function dist(part)
    local ch = LP.Character
    if not ch then return 0 end
    local r = ch:FindFirstChild("HumanoidRootPart")
    if not r or not part then return 0 end
    return (r.Position - part.Position).Magnitude
end

local function scanDoors()
    local c = Workspace:FindFirstChild("DoorModelNew")
    if not c then return end
    for _, o in ipairs(c:GetDescendants()) do
        if o:IsA("Model") or o:IsA("BasePart") then
            local n = o.Name:lower()
            if n:find("door") then
                local col, lbl = C.DoorCol, "Door"
                if n:find("lock") and C.LockedESP then col, lbl = C.LockCol, "LOCKED"
                elseif n:find("fake") and C.FakeESP then col, lbl = C.FakeCol, "FAKE"
                elseif not C.DoorESP then goto cont end
                local num = n:match("%d+")
                if num then lbl = lbl.." #"..num end
                local p = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = dist(p)
                    if d <= C.MaxDist then
                        setHL(p, col)
                        if C.ShowDist then lbl = string.format("%s [%dm]", lbl, math.floor(d)) end
                        setBB(p, lbl, col)
                    end
                end
            end
        end
        ::cont::
    end
end

local ENTS = {"rush","ambush","seek","halt","eyes","screech","glitch","figure","hide","jack","window","shadow","dupe","snare","timothy","void","guiding","el goblino"}
local function isEnt(n)
    n = n:lower()
    for _, e in ipairs(ENTS) do if n:find(e,1,true) then return true end end
    return false
end

local function scanEnts()
    local cs = {Workspace:FindFirstChild("Entities"), Workspace:FindFirstChild("Entity"), Workspace:FindFirstChild("Monsters"), Workspace}
    for _, c in ipairs(cs) do
        if c then
            for _, o in ipairs(c:GetDescendants()) do
                if (o:IsA("Model") or o:IsA("BasePart")) and isEnt(o.Name) then
                    local p = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                    if p and p:IsDescendantOf(Workspace) then
                        local d = dist(p)
                        if d <= C.MaxDist*2 then
                            setHL(p, C.EntCol)
                            local lbl = o.Name
                            if C.ShowDist then lbl = string.format("%s [%dm]", lbl, math.floor(d)) end
                            setBB(p, lbl, C.EntCol)
                        end
                    end
                end
            end
        end
    end
end

local ITEMS = {"key","gold","coin","lighter","flashlight","lockpick","vitamin","crucifix","candle","bandage"}
local function isItem(n)
    n = n:lower()
    for _, e in ipairs(ITEMS) do if n:find(e,1,true) then return true end end
    return false
end

local function scanItems()
    local cs = {Workspace:FindFirstChild("Items"), Workspace:FindFirstChild("Item"), Workspace:FindFirstChild("Pickups")}
    for _, c in ipairs(cs) do
        if c then
            for _, o in ipairs(c:GetDescendants()) do
                if (o:IsA("Model") or o:IsA("BasePart")) and isItem(o.Name) then
                    local p = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local d = dist(p)
                        if d <= C.MaxDist then
                            setHL(p, C.ItemCol)
                            local lbl = o.Name
                            if C.ShowDist then lbl = string.format("%s [%dm]", lbl, math.floor(d)) end
                            setBB(p, lbl, C.ItemCol)
                        end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    pcall(scanDoors)
    pcall(scanEnts)
    pcall(scanItems)
end)

-- Меню
local function buildMenu()
    local pg = LP:WaitForChild("PlayerGui")
    if pg:FindFirstChild("TF_Menu") then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "TF_Menu"
    sg.ResetOnSpawn = false
    sg.Parent = pg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,70,0,70)
    btn.Position = UDim2.new(0,20,0.4,0)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,25)
    btn.TextColor3 = Color3.fromRGB(0,255,120)
    btn.Text = "TF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.BorderSizePixel = 0
    btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,280,0,380)
    f.Position = UDim2.new(0.5,-140,0.5,-190)
    f.BackgroundColor3 = Color3.fromRGB(18,18,22)
    f.BorderSizePixel = 0
    f.Visible = false
    f.Parent = sg
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,14)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,0,40)
    t.BackgroundColor3 = Color3.fromRGB(30,30,38)
    t.Text = "T-F DOORS ESP"
    t.TextColor3 = Color3.fromRGB(0,255,120)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 16
    t.Parent = f
    Instance.new("UICorner", t).CornerRadius = UDim.new(0,14)

    local y = 55
    local function add(name, key)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1,-20,0,38)
        row.Position = UDim2.new(0,10,0,y)
        row.BackgroundColor3 = Color3.fromRGB(28,28,34)
        row.TextColor3 = C[key] and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,80,80)
        row.Font = Enum.Font.Gotham
        row.TextSize = 14
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Text = "  "..name..":  "..(C[key] and "ON" or "OFF")
        row.BorderSizePixel = 0
        row.Parent = f
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
        row.MouseButton1Click:Connect(function()
            C[key] = not C[key]
            row.Text = "  "..name..":  "..(C[key] and "ON" or "OFF")
            row.TextColor3 = C[key] and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,80,80)
            if key=="FullBright" then
                if C.FullBright then
                    Lighting.Ambient = Color3.fromRGB(178,178,178)
                    Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
                    Lighting.Brightness = 3
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 1e6
                    Lighting.GlobalShadows = false
                else
                    Lighting.Ambient = Color3.fromRGB(70,70,70)
                    Lighting.Brightness = 1
                    Lighting.FogEnd = 1000
                    Lighting.GlobalShadows = true
                end
            end
        end)
        y = y + 44
    end

    add("Door ESP","DoorESP")
    add("Locked Doors","LockedESP")
    add("Fake Doors","FakeESP")
    add("Entity ESP","EntityESP")
    add("Item ESP","ItemESP")
    add("Show Distance","ShowDist")
    add("Fullbright","FullBright")

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-36,0,5)
    close.BackgroundColor3 = Color3.fromRGB(255,60,60)
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.BorderSizePixel = 0
    close.Parent = f
    Instance.new("UICorner", close).CornerRadius = UDim.new(0,8)
    close.MouseButton1Click:Connect(function() f.Visible = false end)

    btn.MouseButton1Click:Connect(function()
        f.Visible = not f.Visible
    end)
end

buildMenu()
print("[T-F] Doors ESP v2 loaded")
