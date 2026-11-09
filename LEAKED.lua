local Lighting     = game:GetService("Lighting")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local player   = Players.LocalPlayer
local Camera   = workspace.CurrentCamera

local GIRL_IMAGE   = "rbxassetid://105815765007447"
local SPLASH_IMAGE = "rbxassetid://105815765007447"

local AUTOLOAD_FILE = "vizerVisuals_AnimeDream.lua"
local AUTOLOAD_URL  = ""

local AUTOSTART = false
pcall(function()
	if getgenv and getgenv().vizerAutoStart then
		AUTOSTART = true
		getgenv().vizerAutoStart = nil
	end
end)

local SND = {
	click = "rbxassetid://88442833509532",
	play  = "rbxassetid://116394299154002",
}
local UISnd = {gain = 3.5}
local function PlayUISound(assetId, volume, speed)
	if UISnd.off then return end
	pcall(function()
		local key = assetId .. "|" .. tostring(speed or 1)
		local snd = UISnd[key]
		if not snd then
			snd = Instance.new("Sound")
			snd.Name = "vizerUISound"
			snd.SoundId = assetId
			snd.PlaybackSpeed = speed or 1
			snd.Parent = game:GetService("SoundService")
			UISnd[key] = snd
		end
		snd.Volume = (volume or 0.4) * (UISnd.gain or 3.5)
		snd.TimePosition = 0
		snd:Play()
	end)
end

local fireTrailEnabled    = false
local petalEnabled        = false
local nightVisionEnabled  = false
local antiAfkEnabled      = false
local highJumpEnabled     = false
local nameplatesEnabled   = false
local cameraZoomEnabled   = false
local cameraZoomConn      = nil
local currentFireTrail    = nil
local petalLoopConn       = nil
local nightVisionEffect   = nil
local HJ = {}
local cameraSmoothEnabled = false
local fpsBoostEnabled     = false
local fpsSaved            = {}
local skyEnabledIndex     = 0
local skyInstance         = nil
local SKY = { hidden = {} }
local headlessEnabled     = false
local headlessLoopConn    = nil
local palletEnabled       = false
local AJ = { on = false, conn = nil }
local PK = { on = false, saved = setmetatable({}, {__mode = "k"}) }
local FOG = { on = false, t = 0.4 }
local JC = { on = false, last = 0, last2 = 0 }
local PW = { on = false, saved = setmetatable({}, {__mode = "k"}) }
local SN = { on = false }
local MISC = { visited = {}, fcSpeed = 40, espMap = {}, espConns = {}, friends = {}, ready = false, stretchV = 70, lagLevel = 2, animOff = false,
	lag = { parts = setmetatable({}, {__mode = "k"}), decals = setmetatable({}, {__mode = "k"}), emit = setmetatable({}, {__mode = "k"}),
		lagQ = nil },
	spawn = { id = "rbxassetid://105815765007447", default = "rbxassetid://105815765007447", on = false, orig = setmetatable({}, {__mode = "k"}) } }
local MV = { speedOn = false, speedV = 16, ij = false, fly = false, flyV = 50 }
local CSM = { level = 3, rates = {90, 60, 42, 30, 20} }
local MB  = { on = false, k = 50, size = 0 }
local GH  = { on = false, a = 60, parts = {} }
local ZM  = { latch = false, held = false, x = 3, m = 1 }

local savedMouseBehavior = UIS.MouseBehavior
local savedMouseIcon     = UIS.MouseIconEnabled

local Themes = {
	{
		Name = "💜 Anime Dream",
		Bg = Color3.fromRGB(18, 14, 46),  Panel = Color3.fromRGB(10, 8, 34),  Row = Color3.fromRGB(34, 28, 86),
		Accent = Color3.fromRGB(176, 122, 255), Accent2 = Color3.fromRGB(255, 140, 215),
		Text = Color3.fromRGB(246, 240, 255), Sub = Color3.fromRGB(170, 160, 216),
		On = Color3.fromRGB(150, 108, 255), Off = Color3.fromRGB(66, 62, 98),
	},
	{
		Name = "💎 vizer",
		Bg = Color3.fromRGB(44, 12, 34),  Panel = Color3.fromRGB(28, 8, 22),  Row = Color3.fromRGB(86, 28, 66),
		Accent = Color3.fromRGB(255, 112, 172), Accent2 = Color3.fromRGB(255, 190, 220),
		Text = Color3.fromRGB(255, 238, 246), Sub = Color3.fromRGB(230, 170, 202),
		On = Color3.fromRGB(255, 105, 165), Off = Color3.fromRGB(96, 58, 80),
	},
	{
		Name = "🌙 Night",
		Bg = Color3.fromRGB(8, 12, 32),   Panel = Color3.fromRGB(5, 8, 22),   Row = Color3.fromRGB(20, 30, 78),
		Accent = Color3.fromRGB(86, 136, 255), Accent2 = Color3.fromRGB(130, 210, 255),
		Text = Color3.fromRGB(226, 236, 255), Sub = Color3.fromRGB(150, 172, 230),
		On = Color3.fromRGB(80, 130, 255), Off = Color3.fromRGB(48, 56, 92),
	},
	{
		Name = "🌅 Sunset",
		Bg = Color3.fromRGB(46, 16, 10),  Panel = Color3.fromRGB(30, 10, 6),  Row = Color3.fromRGB(88, 36, 20),
		Accent = Color3.fromRGB(255, 150, 60), Accent2 = Color3.fromRGB(255, 100, 120),
		Text = Color3.fromRGB(255, 240, 224), Sub = Color3.fromRGB(235, 186, 150),
		On = Color3.fromRGB(255, 150, 60), Off = Color3.fromRGB(98, 64, 52),
	},
	{
		Name = "🧊 Ice",
		Bg = Color3.fromRGB(8, 32, 52),   Panel = Color3.fromRGB(5, 22, 36),  Row = Color3.fromRGB(16, 66, 100),
		Accent = Color3.fromRGB(100, 222, 255), Accent2 = Color3.fromRGB(160, 255, 232),
		Text = Color3.fromRGB(226, 250, 255), Sub = Color3.fromRGB(160, 214, 236),
		On = Color3.fromRGB(80, 210, 255), Off = Color3.fromRGB(48, 80, 100),
	},
	{
		Name = "🖤 Black",
		Bg = Color3.fromRGB(10, 10, 12),  Panel = Color3.fromRGB(5, 5, 7),  Row = Color3.fromRGB(30, 30, 34),
		Accent = Color3.fromRGB(96, 96, 104), Accent2 = Color3.fromRGB(205, 205, 212),
		Text = Color3.fromRGB(240, 240, 244), Sub = Color3.fromRGB(150, 150, 158),
		On = Color3.fromRGB(150, 150, 160), Off = Color3.fromRGB(44, 44, 50),
		TitleStroke = Color3.fromRGB(190, 190, 198),
		Shimmer = {Color3.fromRGB(18, 18, 22), Color3.fromRGB(125, 125, 133), Color3.fromRGB(240, 240, 245)},
	},
	{
		Name = "🤍 White",
		Bg = Color3.fromRGB(244, 242, 252),  Panel = Color3.fromRGB(255, 255, 255),  Row = Color3.fromRGB(226, 222, 242),
		Accent = Color3.fromRGB(120, 104, 200), Accent2 = Color3.fromRGB(190, 150, 235),
		Text = Color3.fromRGB(34, 30, 56), Sub = Color3.fromRGB(100, 94, 130),
		On = Color3.fromRGB(120, 104, 210), Off = Color3.fromRGB(206, 202, 222), KnobOff = Color3.fromRGB(130, 124, 160),
		TitleStroke = Color3.fromRGB(150, 138, 205),
		Shimmer = {Color3.fromRGB(40, 34, 80), Color3.fromRGB(120, 100, 205), Color3.fromRGB(200, 130, 235)},
	},
}
local currentTheme = 1

local EffectColors = {
	FireTrail   = Color3.fromRGB(120, 0, 255),
	Petals      = Color3.fromRGB(255, 160, 195),
	Fog         = Color3.fromRGB(190, 190, 205),
	JumpCircle  = Color3.fromRGB(136, 0, 170),
	Snow        = Color3.fromRGB(255, 255, 255),
	Summer      = Color3.fromRGB(255, 255, 0),
	Cloud       = Color3.fromRGB(255, 255, 255),
	ESP         = Color3.fromRGB(255, 70, 130),
	FriendESP   = Color3.fromRGB(90, 235, 130),
	Ambient     = Color3.fromRGB(150, 120, 255),
	Tint        = Color3.fromRGB(255, 150, 200),
}

local EffectDefaults = {}
for k, v in pairs(EffectColors) do EffectDefaults[k] = v end

local SkyPresets = {
	{
		Name="1", CelestialBodiesShown=false, MoonAngularSize=11, MoonTextureId="rbxasset://sky/moon.jpg",
		SkyboxBk="rbxassetid://271042516", SkyboxDn="rbxassetid://271077243", SkyboxFt="rbxassetid://271042556",
		SkyboxLf="rbxassetid://271042310", SkyboxRt="rbxassetid://271042467", SkyboxUp="rbxassetid://271077958",
		StarCount=1334, SunAngularSize=21, SunTextureId="rbxasset://sky/sun.jpg",
	},
	{
		Name="2", CelestialBodiesShown=true, MoonAngularSize=1.5, MoonTextureId="rbxasset://sky/moon.jpg",
		SkyboxBk="rbxassetid://18703245834", SkyboxDn="rbxassetid://18703243349", SkyboxFt="rbxassetid://18703240532",
		SkyboxLf="rbxassetid://18703237556", SkyboxRt="rbxassetid://18703235430", SkyboxUp="rbxassetid://18703232671",
		StarCount=3500, SunAngularSize=1.5, SunTextureId="rbxasset://sky/sun.jpg",
	},
	{
		Name="3", CelestialBodiesShown=true, MoonAngularSize=11, MoonTextureId="rbxassetid://6444320592",
		SkyboxBk="rbxassetid://7307273436", SkyboxDn="rbxassetid://7307275898", SkyboxFt="rbxassetid://7307282434",
		SkyboxLf="rbxassetid://7307284944", SkyboxRt="rbxassetid://7307287254", SkyboxUp="rbxassetid://7307290025",
		StarCount=3000, SunAngularSize=11, SunTextureId="rbxassetid://6196665106",
	},
	{
		Name="4", CelestialBodiesShown=false, MoonAngularSize=11, MoonTextureId="rbxasset://sky/moon.jpg",
		SkyboxBk="rbxassetid://237593887", SkyboxDn="rbxassetid://237593849", SkyboxFt="rbxassetid://237593922",
		SkyboxLf="rbxassetid://237593861", SkyboxRt="rbxassetid://237593835", SkyboxUp="rbxassetid://237593929",
		StarCount=5000, SunAngularSize=21, SunTextureId="rbxasset://sky/sun.jpg",
	},
	{
		Name="5", CelestialBodiesShown=false, MoonAngularSize=11, MoonTextureId="rbxassetid://6444320592",
		SkyboxBk="rbxassetid://81858382098344", SkyboxDn="rbxassetid://138472117789684", SkyboxFt="rbxassetid://95687237979398",
		SkyboxLf="rbxassetid://84924000207295", SkyboxRt="rbxassetid://99961685452126", SkyboxUp="rbxassetid://104038404823203",
		StarCount=5000, SunAngularSize=11, SunTextureId="rbxassetid://6196665106",
	},
	{
		Name="6", CelestialBodiesShown=false, MoonAngularSize=11, MoonTextureId="rbxasset://sky/moon.jpg",
		SkyboxBk="http://www.roblox.com/asset/?id=155657655", SkyboxDn="http://www.roblox.com/asset/?id=155674246",
		SkyboxFt="http://www.roblox.com/asset/?id=155657609", SkyboxLf="http://www.roblox.com/asset/?id=155657671",
		SkyboxRt="http://www.roblox.com/asset/?id=155657619", SkyboxUp="http://www.roblox.com/asset/?id=155674931",
		StarCount=3000, SunAngularSize=21, SunTextureId="rbxasset://sky/sun.jpg",
		Atmosphere = {
			Density = 0.348, Offset = 1, Color = Color3.fromRGB(216, 255, 250),
			Decay = Color3.fromRGB(92, 60, 13), Glare = 0.63, Haze = 0,
		},
	},
	{
		Name="7", CelestialBodiesShown=false, MoonAngularSize=11, MoonTextureId="rbxasset://sky/moon.jpg",
		SkyboxBk="rbxassetid://15876597103", SkyboxDn="rbxassetid://15876592775", SkyboxFt="rbxassetid://15876640231",
		SkyboxLf="rbxassetid://15876638420", SkyboxRt="rbxassetid://15876595486", SkyboxUp="rbxassetid://15876639348",
		StarCount=3000, SunAngularSize=21, SunTextureId="rbxasset://sky/sun.jpg",
	},
}

local ApplyFireTrail, ApplyPetals, ApplyCameraZoom
local ApplyNightVision, ApplyAntiAfk, ApplyHighJump, ApplyNameplates
local ApplyCameraSmooth, ApplyFPSBoost, ApplySky, ApplyHeadless, ApplyPallets
local UpdateToggleVisual, ApplyThemeToAll

local UI = {
	rows = {}, pending = {}, pages = {}, pdata = {}, tabs = {}, feats = {},
	themed = {}, ambient = {}, open = false, busy = false, rebinding = nil, active = "Visuals",
}

local EXT = { time = 12, lapse = 10, grav = 60, spin = 20, fpscap = 144, tilt = 8, blur = 8, bright = 15, fov = 70, jump = 50, jcMode = 1 }
local XS, XH, XC, XFX = {}, {}, {}, {}
local function XT(id)
	return function()
		local s = not XS[id]
		XS[id] = s
		if XH[id] then XH[id](s) end
		UpdateToggleVisual(id, s)
	end
end

MISC.FILE = "vizerSettings.json"
do
	local HttpService = game:GetService("HttpService")
	local ok, raw = pcall(function() return readfile and readfile(MISC.FILE) end)
	if ok and raw then
		local ok2, d = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok2 and type(d) == "table" then
			MISC.saved = d
			if Themes[d.theme or 0] then currentTheme = d.theme end
			if type(d.speed) == "number" then MV.speedV = d.speed end
			if type(d.fly) == "number" then MV.flyV = d.fly end
			if type(d.fc) == "number" then MISC.fcSpeed = d.fc end
			if type(d.fog) == "number" then FOG.t = math.clamp(d.fog, 0, 1) end
			if type(d.smooth) == "number" then CSM.level = math.clamp(math.floor(d.smooth), 1, 5) end
			if type(d.vol) == "number" then UISnd.vol = d.vol; UISnd.gain = d.vol / 100 * 7 end
			if d.soundOff == true then UISnd.off = true end
			if type(d.spawn) == "string" then MISC.spawn.id = d.spawn end
			if type(d.vip) == "string" then MISC.vip = d.vip end
			if type(d.stretch) == "number" then MISC.stretchV = math.clamp(d.stretch, 20, 100) end
			if type(d.lag) == "number" then MISC.lagLevel = math.clamp(math.floor(d.lag), 1, 3) end
			if d.animOff == true then MISC.animOff = true end
			if type(d.mb) == "number" then MB.k = math.clamp(d.mb, 10, 100) end
			if type(d.ghost) == "number" then GH.a = math.clamp(d.ghost, 10, 90) end
			if type(d.zoomx) == "number" then ZM.x = math.clamp(d.zoomx, 2, 10) end
			if type(d.ext) == "table" then
				for k, v in pairs(d.ext) do
					if type(v) == "number" and EXT[k] ~= nil then EXT[k] = v end
				end
			end
			if type(d.colors) == "table" then
				for k, v in pairs(d.colors) do
					if EffectColors[k] and type(v) == "table" then
						EffectColors[k] = Color3.fromRGB(v[1] or 255, v[2] or 255, v[3] or 255)
					end
				end
			end
			if type(d.friends) == "table" then
				for _, n in ipairs(d.friends) do
					if type(n) == "string" then MISC.friends[n:lower()] = n end
				end
			end
		end
	end
end

function MISC.save()
	if not MISC.ready or not writefile then return end
	pcall(function()
		local on, keys, colors, friends = {}, {}, {}, {}
		for id, r in pairs(UI.rows) do
			if r.state and not r.feat.Button and id ~= "Freecam" and id ~= "UISounds" and id ~= "MenuAnim" and id ~= "ZoomKey" then table.insert(on, id) end
			if r.feat.Key then keys[id] = r.feat.Key.Name end
		end
		for k, v in pairs(EffectColors) do
			colors[k] = {math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)}
		end
		for _, n in pairs(MISC.friends) do table.insert(friends, n) end
		local image = nil
		if UI.artImage and UI.artImage.Image ~= GIRL_IMAGE then image = UI.artImage.Image end
		local data = {
			on = on, keys = keys, colors = colors, friends = friends,
			theme = currentTheme, speed = MV.speedV, fly = MV.flyV, fc = MISC.fcSpeed,
			fog = FOG.t, smooth = CSM.level, vol = UISnd.vol or 50, soundOff = UISnd.off or false,
			spawn = MISC.spawn.id, image = image, vip = MISC.vip, stretch = MISC.stretchV, lag = MISC.lagLevel, animOff = MISC.animOff or false,
			mb = MB.k, ghost = GH.a, zoomx = ZM.x, ext = EXT,
			map = MISC.mapState and MISC.mapState() or nil,
			shader = MISC.shaderState and MISC.shaderState() or nil,
		}
		writefile(MISC.FILE, game:GetService("HttpService"):JSONEncode(data))
	end)
end

function MISC.dirty()
	if not MISC.ready or MISC.saveQueued then return end
	MISC.saveQueued = true
	task.delay(1.2, function()
		MISC.saveQueued = false
		MISC.save()
	end)
end

do
	local WHITE = Color3.new(1, 1, 1)
	local FULL  = UDim2.new(1, 0, 1, 0)
	local C     = Vector2.new(0.5, 0.5)
	local EASE  = Enum.EasingStyle
	local DIR   = Enum.EasingDirection

	local function new(class, props, parent)
		local o = Instance.new(class)
		for k, v in pairs(props) do o[k] = v end
		o.Parent = parent
		return o
	end
	local function corner(p, r)
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c
	end
	local function stroke(p, col, th, tr)
		local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th; s.Transparency = tr; s.Parent = p; return s
	end
	local function tween(o, t, props, style, dir)
		local tw = TweenService:Create(o, TweenInfo.new(t, style or EASE.Quad, dir or DIR.Out), props)
		tw:Play(); return tw
	end
	UI.new, UI.corner, UI.stroke, UI.tween = new, corner, stroke, tween

	function UI.bind(fn)
		table.insert(UI.themed, fn)
		local ok, err = pcall(fn, Themes[currentTheme])
		if not ok then warn("[vizerUI] " .. tostring(err)) end
	end

	local W, H = 994, 460
	local sg = new("ScreenGui", {
		Name = "vizerVisualsGUI", ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui"))

	local holder = new("Frame", {
		Name = "Holder", AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1,
	}, sg)
	local fitFrame = new("Frame", {
		AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 1,
	}, holder)
	local fit = new("UIScale", {}, fitFrame)
	local function refit()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local vp = cam.ViewportSize
		fit.Scale = math.clamp(math.min(vp.X / (W + 60), vp.Y / (H + 60)), 0.4, 1)
	end
	refit()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refit)
	end

	local root = new("Frame", {
		AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0), Size = FULL, BackgroundTransparency = 1,
	}, fitFrame)
	local pop = new("UIScale", {Scale = 1}, root)

	local glowGroup = new("CanvasGroup", {
		AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 80, 1, 80),
		BackgroundTransparency = 1, ZIndex = 1,
	}, root)
	local glows = {}
	for i = 1, 7 do
		local g = new("Frame", {
			AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -80 + i * 6, 1, -80 + i * 6),
			BackgroundColor3 = Themes[1].Accent, BackgroundTransparency = 0.95, BorderSizePixel = 0,
		}, glowGroup)
		corner(g, 22 + i * 2)
		glows[i] = g
	end
	UI.bind(function(t) for _, g in ipairs(glows) do g.BackgroundColor3 = t.Accent end end)

	local main = new("CanvasGroup", {
		Name = "Main", Size = FULL, BackgroundColor3 = Themes[1].Bg, BorderSizePixel = 0,
		ZIndex = 2, Active = true,
	}, root)
	corner(main, 22)

	local shade = new("Frame", {Size = FULL, BackgroundColor3 = Themes[1].Bg, BorderSizePixel = 0, ZIndex = 1}, main)
	new("UIGradient", {Rotation = 35, Color = ColorSequence.new(WHITE, Color3.fromRGB(140, 130, 185))}, shade)
	UI.bind(function(t) shade.BackgroundColor3 = t.Bg end)

	local petalLayer = new("Frame", {Size = FULL, BackgroundTransparency = 1, ZIndex = 3}, main)

	local dragZone = new("Frame", {Size = UDim2.new(1, 0, 0, 84), BackgroundTransparency = 1, ZIndex = 4, Active = true}, main)

	local TITLE = "vizer visual AI"
	local glowT = {}
	for _, cfg in ipairs({{16, 0.93}, {9, 0.85}, {4, 0.7}}) do
		local g = new("TextLabel", {
			Position = UDim2.new(0, 30, 0, 12), Size = UDim2.new(0, 380, 0, 46), BackgroundTransparency = 1,
			Text = TITLE, Font = Enum.Font.Fondamento, TextSize = 38, TextColor3 = Themes[1].Accent2,
			TextTransparency = 0.55, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
		}, main)
		table.insert(glowT, {g, stroke(g, Themes[1].Accent2, cfg[1], cfg[2])})
	end
	local title = new("TextLabel", {
		Position = UDim2.new(0, 30, 0, 12), Size = UDim2.new(0, 380, 0, 46), BackgroundTransparency = 1,
		Text = TITLE, Font = Enum.Font.Fondamento, TextSize = 38, TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	}, main)
	local titleStroke = stroke(title, Themes[1].Accent, 1.5, 0.35)
	local shimmer = new("UIGradient", {Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, WHITE), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(215, 195, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 175, 232)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(215, 195, 255)),
		ColorSequenceKeypoint.new(1, WHITE),
	})}, title)
	shimmer.Offset = Vector2.new(-1, 0)
	do
		local tw = TweenService:Create(shimmer, TweenInfo.new(3.4, EASE.Linear, DIR.Out, -1), {Offset = Vector2.new(1, 0)})
		tw:Play(); table.insert(UI.ambient, tw)
	end

	local sub = new("TextLabel", {
		Position = UDim2.new(0, 32, 0, 58), Size = UDim2.new(0, 300, 0, 20), BackgroundTransparency = 1,
		Text = "Dream bigger... ♡", Font = Enum.Font.Fondamento, TextSize = 16, TextColor3 = Themes[1].Accent,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	}, main)
	local defaultShimmer = shimmer.Color
	UI.bind(function(t)
		sub.TextColor3 = t.Accent2
		titleStroke.Color = t.TitleStroke or t.Accent
		titleStroke.Transparency = t.Shimmer and 0.1 or 0.35
		for _, p in ipairs(glowT) do p[1].TextColor3 = t.Accent2; p[2].Color = t.Accent2 end
		if t.Shimmer then
			local s1, s2, s3 = t.Shimmer[1], t.Shimmer[2], t.Shimmer[3]
			shimmer.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, s1), ColorSequenceKeypoint.new(0.35, s2), ColorSequenceKeypoint.new(0.5, s3),
				ColorSequenceKeypoint.new(0.65, s2), ColorSequenceKeypoint.new(1, s1),
			})
		else
			shimmer.Color = defaultShimmer
		end
	end)

	local hint = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -84, 0, 20), Size = UDim2.new(0, 110, 0, 42),
		BackgroundTransparency = 1, ZIndex = 5,
	}, main)
	local hintA = new("TextLabel", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "RightShift",
		Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = WHITE, ZIndex = 6}, hint)
	local hintB = new("TextLabel", {Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = "to toggle", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(205, 195, 238), ZIndex = 6}, hint)
	local hintDiv = new("Frame", {Position = UDim2.new(1, -68, 0, 20), Size = UDim2.new(0, 1, 0, 42), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.78, BorderSizePixel = 0, ZIndex = 5}, main)
	UI.bind(function(t) hintA.TextColor3 = t.Text; hintB.TextColor3 = t.Sub; hintDiv.BackgroundColor3 = t.Sub end)

	local closeBtn = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 20), Size = UDim2.new(0, 40, 0, 40),
		BackgroundColor3 = Color3.fromRGB(10, 8, 30), BackgroundTransparency = 0.35, Text = "",
		AutoButtonColor = false, ZIndex = 7,
	}, main)
	corner(closeBtn, 12)
	local closeBars = {}
	for _, rot in ipairs({45, -45}) do
		local bar = new("Frame", {AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 18, 0, 3),
			Rotation = rot, BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 8}, closeBtn)
		corner(bar, 2)
		table.insert(closeBars, bar)
	end
	local closeStroke = stroke(closeBtn, Themes[1].Accent, 1.5, 0.2)
	UI.bind(function(t)
		closeStroke.Color = t.Accent; closeBtn.BackgroundColor3 = t.Panel
		for _, bar in ipairs(closeBars) do bar.BackgroundColor3 = t.Text end
	end)
	closeBtn.MouseEnter:Connect(function()
		PlayUISound(SND.click, 0.08, 1.6)
		tween(closeBtn, 0.25, {Rotation = 90, BackgroundTransparency = 0.05}, EASE.Back)
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, 0.25, {Rotation = 0, BackgroundTransparency = 0.35}, EASE.Back)
	end)

	local panel = new("Frame", {
		Position = UDim2.new(0, 326, 0, 90), Size = UDim2.new(0, 654, 0, 358),
		BackgroundColor3 = Themes[1].Panel, BackgroundTransparency = 0.28, BorderSizePixel = 0, ZIndex = 4,
	}, main)
	corner(panel, 18)
	local panelStroke = stroke(panel, Themes[1].Accent, 1.2, 0.55)
	UI.bind(function(t) panel.BackgroundColor3 = t.Panel; panelStroke.Color = t.Accent end)

	local art = new("CanvasGroup", {
		Position = UDim2.new(0, 14, 0, 90), Size = UDim2.new(0, 300, 0, 358),
		BackgroundColor3 = Themes[1].Panel, BorderSizePixel = 0, ZIndex = 4,
	}, main)
	corner(art, 18)
	UI.artImage = new("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1, Image = GIRL_IMAGE, ScaleType = Enum.ScaleType.Crop, ZIndex = 1,
	}, art)
	local artFade = new("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 40, 1, 0), BackgroundColor3 = Themes[1].Panel, BorderSizePixel = 0, ZIndex = 2}, art)
	new("UIGradient", {Rotation = 180, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})}, artFade)
	local artFrame = new("Frame", {Position = UDim2.new(0, 14, 0, 90), Size = UDim2.new(0, 300, 0, 358),
		BackgroundTransparency = 1, ZIndex = 5}, main)
	corner(artFrame, 18)
	local artStroke = stroke(artFrame, Themes[1].Accent, 1.5, 0.3)
	UI.bind(function(t) art.BackgroundColor3 = t.Panel; artFade.BackgroundColor3 = t.Panel; artStroke.Color = t.Accent end)

	local sidebar = new("Frame", {Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 124, 0, 342), BackgroundTransparency = 1, ZIndex = 5}, panel)
	new("Frame", {Position = UDim2.new(0, 136, 0, 14), Size = UDim2.new(0, 1, 0, 330), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 5}, panel)
	local pagesHolder = new("Frame", {Position = UDim2.new(0, 142, 0, 8), Size = UDim2.new(0, 504, 0, 342),
		BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 5}, panel)

	local TABS = {
		{"Visuals", "✨"}, {"Movement", "🏃"}, {"Player", "👤"},
		{"World", "🌍"}, {"Map", "🗺"}, {"Misc", "🔧"}, {"Settings", "⚙"},
	}
	local selector = new("Frame", {
		Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(1, -12, 0, 38), BackgroundColor3 = Themes[1].Accent,
		BackgroundTransparency = 0.72, BorderSizePixel = 0, ZIndex = 2,
	}, sidebar)
	corner(selector, 11)
	local selStroke = stroke(selector, Themes[1].Accent, 1.6, 0.05)
	UI.bind(function(t) selector.BackgroundColor3 = t.Accent; selStroke.Color = t.Accent end)

	for i, def in ipairs(TABS) do
		local name = def[1]
		local y = 6 + (i - 1) * 44
		local btn = new("TextButton", {
			Position = UDim2.new(0, 6, 0, y), Size = UDim2.new(1, -12, 0, 38), BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, ZIndex = 4,
		}, sidebar)
		new("TextLabel", {Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 24, 1, 0), BackgroundTransparency = 1,
			Text = def[2], Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = WHITE, ZIndex = 5}, btn)
		local lbl = new("TextLabel", {
			Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1,
			Text = name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(185, 175, 222),
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
		}, btn)
		UI.tabs[name] = {btn = btn, name = lbl}

		btn.MouseEnter:Connect(function()
			PlayUISound(SND.click, 0.07, 1.7)
			tween(lbl, 0.2, {Position = UDim2.new(0, 43, 0, 0)})
		end)
		btn.MouseLeave:Connect(function() tween(lbl, 0.2, {Position = UDim2.new(0, 38, 0, 0)}) end)
		btn.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.4, 1)
			UI.switch(name)
		end)

		local pg = new("ScrollingFrame", {
			Name = name, Size = FULL, BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
			ScrollBarImageColor3 = Themes[1].Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false, ZIndex = 5,
		}, pagesHolder)
		new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
		new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12)}, pg)
		UI.pages[name] = pg
		UI.pdata[name] = {order = 0, grid = nil, pops = {}}
		UI.bind(function(t) pg.ScrollBarImageColor3 = t.Accent end)
	end

	local searchPage = new("ScrollingFrame", {
		Name = "Search", Size = FULL, BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = Themes[1].Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false, ZIndex = 5,
	}, pagesHolder)
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, searchPage)
	new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12)}, searchPage)
	UI.pages.Search = searchPage
	UI.pdata.Search = {order = 0, grid = nil, pops = {}}
	UI.bind(function(t) searchPage.ScrollBarImageColor3 = t.Accent end)

	local ver = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4), Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1, Text = "vizer", Font = Enum.Font.GothamMedium, TextSize = 11,
		TextColor3 = Color3.fromRGB(150, 140, 190), ZIndex = 5,
	}, sidebar)

	function UI.switch(name)
		if UI.searchBox and UI.searchBox.Text ~= "" then
			UI.clearing = true
			UI.searchBox.Text = ""
			UI.clearing = false
		end
		if UI.searchClear then UI.searchClear.Visible = false end
		UI.searching = false
		UI.active = name
		local idx = 1
		for i, def in ipairs(TABS) do if def[1] == name then idx = i end end
		for n, pg in pairs(UI.pages) do pg.Visible = (n == name) end
		local th = Themes[currentTheme]
		for n, tb in pairs(UI.tabs) do
			tween(tb.name, 0.25, {TextColor3 = (n == name) and th.Text or th.Sub})
		end
		tween(selector, 0.4, {Position = UDim2.new(0, 6, 0, 6 + (idx - 1) * 44)}, EASE.Back)
		UI.pages[name].CanvasPosition = Vector2.new(0, 0)
		for i, sc in ipairs(UI.pdata[name].pops) do
			sc.Scale = 0.85
			task.delay(math.min(i * 0.03, 0.35), function() tween(sc, 0.35, {Scale = 1}, EASE.Back) end)
		end
	end

	UI.bind(function(t)
		for n, tb in pairs(UI.tabs) do tb.name.TextColor3 = (n == UI.active) and t.Text or t.Sub end
	end)

	local function getGrid(tab)
		local d = UI.pdata[tab]
		if not d.grid then
			d.grid = new("Frame", {
				Name = "Grid", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1, LayoutOrder = d.order,
			}, UI.pages[tab])
			d.order = d.order + 1
			new("UIGridLayout", {
				CellSize = UDim2.new(0.5, -5, 0, 46), CellPadding = UDim2.new(0, 8, 0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, d.grid)
		end
		return d.grid
	end

	function UI.section(tab, text)
		local d = UI.pdata[tab]; d.grid = nil
		local l = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "  " .. text,
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = d.order, ZIndex = 6,
		}, UI.pages[tab])
		d.order = d.order + 1
		UI.bind(function(t) l.TextColor3 = t.Accent end)
	end

	function UI.fullRow(tab, h)
		local d = UI.pdata[tab]; d.grid = nil
		local row = new("Frame", {
			Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = d.order,
		}, UI.pages[tab])
		d.order = d.order + 1
		corner(row, 12)
		local s = stroke(row, Themes[1].Accent, 1, 0.75)
		UI.bind(function(t) row.BackgroundColor3 = t.Row; s.Color = t.Accent end)
		return row
	end

	function UI.infoRow(tab, text)
		local row = UI.fullRow(tab, 40)
		local lbl = new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 6}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Sub end)
		return lbl
	end

	function UI.stepRow(tab, text, buttons)
		local row = UI.fullRow(tab, 44)
		local lbl = new("TextLabel", {
			Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -160, 1, 0), BackgroundTransparency = 1,
			Text = text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
		}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		for i, b in ipairs(buttons) do
			local btn = new("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10 - (i - 1) * 42, 0.5, 0),
				Size = UDim2.new(0, 36, 0, 28), Text = b[1], Font = Enum.Font.GothamBold, TextSize = 15,
				TextColor3 = WHITE, AutoButtonColor = false, BackgroundTransparency = 0.25, ZIndex = 7,
			}, row)
			corner(btn, 8)
			UI.bind(function(t) btn.BackgroundColor3 = t.On end)
			btn.MouseEnter:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0}) end)
			btn.MouseLeave:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0.25}) end)
			btn.MouseButton1Click:Connect(function()
				PlayUISound(SND.click, 0.4, 1.2)
				b[2]()
			end)
		end
		return lbl
	end

	function UI.sliderRow(tab, prefix, min, max, init, onChange)
		local row = UI.fullRow(tab, 58)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 8),
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		local track = new("Frame", {Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 36),
			BackgroundColor3 = WHITE, BackgroundTransparency = 0.75, BorderSizePixel = 0, Active = true, ZIndex = 6}, row)
		corner(track, 5)
		UI.bind(function(t) track.BackgroundColor3 = t.Sub end)
		local fill = new("Frame", {BorderSizePixel = 0, ZIndex = 7}, track)
		corner(fill, 5)
		UI.bind(function(t) fill.BackgroundColor3 = t.On end)
		local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 22), AnchorPoint = C, BackgroundColor3 = WHITE,
			BorderSizePixel = 0, ZIndex = 8}, track)
		corner(knob, 5)
		stroke(knob, Color3.fromRGB(120, 120, 135), 1, 0.3)

		local obj = {}
		function obj.set(v, silent)
			v = math.clamp(math.floor(v + 0.5), min, max)
			local rel = (v - min) / (max - min)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			lbl.Text = prefix .. v
			obj.value = v
			if not silent then onChange(v); MISC.dirty() end
		end
		obj.set(init, true)
		obj.prefix = prefix
		UI.sliders = UI.sliders or {}
		table.insert(UI.sliders, obj)

		local dragging = false
		local function setFromX(x)
			obj.set(min + math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * (max - min))
		end
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true; setFromX(input.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		return obj
	end

	function UI.add(feat)
		local d = UI.pdata[feat.Tab]
		local grid = getGrid(feat.Tab)
		local cell = new("Frame", {Name = feat.Id, BackgroundTransparency = 1, LayoutOrder = d.order}, grid)
		d.order = d.order + 1

		local row = new("Frame", {
			AnchorPoint = C, Position = UDim2.new(0.5, 0, 0.5, 0), Size = FULL,
			BackgroundTransparency = 0.3, BorderSizePixel = 0,
		}, cell)
		corner(row, 12)
		local rs = stroke(row, Themes[1].Accent, 1, 0.78)
		local sc = new("UIScale", {Scale = 1}, row)
		table.insert(d.pops, sc)

		local ib = new("Frame", {Position = UDim2.new(0, 8, 0.5, -16), Size = UDim2.new(0, 32, 0, 32),
			BackgroundTransparency = 0.85, BorderSizePixel = 0}, row)
		corner(ib, 9)
		new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Text = feat.Icon or "✦",
			Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = WHITE}, ib)

		local nm = new("TextLabel", {
			Position = UDim2.new(0, 48, 0, 6), Size = UDim2.new(1, -104, 0, 18), BackgroundTransparency = 1,
			Text = feat.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		local sb = new("TextLabel", {
			Position = UDim2.new(0, 48, 0, 25), Size = UDim2.new(1, -104, 0, 14), BackgroundTransparency = 1,
			Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)

		local pill = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 40, 0, 22),
			BackgroundColor3 = Themes[1].Off, BorderSizePixel = 0,
		}, row)
		corner(pill, 11)
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = Color3.fromRGB(205, 200, 225), BorderSizePixel = 0,
		}, pill)
		corner(knob, 8)

		local btn = new("TextButton", {Size = FULL, BackgroundTransparency = 1, Text = "", ZIndex = 10}, row)

		if feat.Button then
			knob.Visible = false
			new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Text = "GO", Font = Enum.Font.GothamBold,
				TextSize = 11, TextColor3 = WHITE}, pill)
		end

		local r = {state = false, feat = feat, sub = sb}
		UI.rows[feat.Id] = r

		local function subText()
			return (feat.Sub or "") .. (feat.Key and ("  ·  " .. feat.Key.Name) or "")
		end
		r.updateSub = function() sb.Text = subText() end
		r.updateSub()

		r.set = function(state, instant)
			r.state = state
			if feat.Button then
				pill.BackgroundColor3 = Themes[currentTheme].On
				rs.Transparency = 0.78; ib.BackgroundTransparency = 0.85
				return
			end
			local t = Themes[currentTheme]
			local pc = state and t.On or t.Off
			local kp = UDim2.new(0, state and 21 or 3, 0.5, 0)
			local kc = state and WHITE or (t.KnobOff or Color3.fromRGB(205, 200, 225))
			local st = state and 0.25 or 0.78
			local it = state and 0.6 or 0.85
			if instant then
				pill.BackgroundColor3 = pc; knob.Position = kp; knob.BackgroundColor3 = kc
				rs.Transparency = st; ib.BackgroundTransparency = it
			else
				tween(pill, 0.25, {BackgroundColor3 = pc})
				tween(knob, 0.32, {Position = kp, BackgroundColor3 = kc}, EASE.Back)
				tween(rs, 0.25, {Transparency = st})
				if state then ib.BackgroundTransparency = 0.15 end
				tween(ib, 0.5, {BackgroundTransparency = it})
			end
		end

		UI.bind(function(t)
			row.BackgroundColor3 = t.Row; rs.Color = t.Accent; ib.BackgroundColor3 = t.Accent
			nm.TextColor3 = t.Text; sb.TextColor3 = t.Sub
			r.set(r.state, true)
		end)
		local init = UI.pending[feat.Id]
		if init ~= nil then r.set(init, true) end

		btn.MouseEnter:Connect(function()
			PlayUISound(SND.click, 0.06, 1.8)
			tween(row, 0.15, {BackgroundTransparency = 0.12})
			tween(sc, 0.2, {Scale = 1.025}, EASE.Back)
		end)
		btn.MouseLeave:Connect(function()
			tween(row, 0.2, {BackgroundTransparency = 0.3})
			tween(sc, 0.2, {Scale = 1})
		end)
		btn.MouseButton1Down:Connect(function() tween(sc, 0.08, {Scale = 0.95}) end)
		btn.MouseButton1Up:Connect(function() tween(sc, 0.15, {Scale = 1.025}, EASE.Back) end)
		btn.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.45, r.state and 0.9 or 1.18)
			feat.Toggle()
		end)
		btn.MouseButton2Click:Connect(function() UI.startRebind(feat) end)

		feat.DefKey = feat.Key
		table.insert(UI.feats, feat)
		return r
	end

	function UI.cancelRebind()
		if UI.rebinding then
			local r = UI.rows[UI.rebinding.Id]
			if r then r.updateSub() end
			UI.rebinding = nil
		end
	end
	function UI.startRebind(feat)
		UI.cancelRebind()
		UI.rebinding = feat
		local r = UI.rows[feat.Id]
		if r then r.sub.Text = "Press a key...  (Esc = cancel)" end
	end

	local sbox = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0, 600, 0, 22), Size = UDim2.new(0, 320, 0, 38),
		BackgroundColor3 = Themes[1].Panel, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 7,
	}, main)
	corner(sbox, 19)
	local sboxStroke = stroke(sbox, Themes[1].Accent, 1.5, 0.35)
	local sIcon = new("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 22, 1, 0), BackgroundTransparency = 1,
		Text = "🔍", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = WHITE, ZIndex = 8}, sbox)
	local sInput = new("TextBox", {
		Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -74, 1, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = "Search features...", Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
	}, sbox)
	local sClear = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 22, 0, 22),
		BackgroundTransparency = 1, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
		Visible = false, ZIndex = 8,
	}, sbox)
	UI.searchBox, UI.searchClear = sInput, sClear
	UI.bind(function(t)
		sbox.BackgroundColor3 = t.Panel; sboxStroke.Color = t.Accent
		sInput.TextColor3 = t.Text; sInput.PlaceholderColor3 = t.Sub
		sClear.TextColor3 = t.Sub; sIcon.TextColor3 = t.Text
	end)
	sInput.Focused:Connect(function() tween(sboxStroke, 0.2, {Transparency = 0}) end)
	sInput.FocusLost:Connect(function() tween(sboxStroke, 0.2, {Transparency = 0.35}) end)

	function UI.runSearch()
		local raw = sInput.Text
		local q = (raw:lower():gsub("^%s+", ""):gsub("%s+$", ""))
		sClear.Visible = raw ~= ""
		if q == "" then
			if UI.searching then UI.searching = false; UI.switch(UI.active) end
			return
		end
		UI.searching = true
		for n, pg in pairs(UI.pages) do pg.Visible = (n == "Search") end
		for _, c in ipairs(searchPage:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end

		local th = Themes[currentTheme]
		local found, order = 0, 1
		for _, feat in ipairs(UI.feats) do
			local hay = (feat.Name .. " " .. (feat.Sub or "") .. " " .. feat.Tab .. " " .. feat.Id .. " "
				.. (feat.Key and feat.Key.Name or "")):lower()
			if hay:find(q, 1, true) then
				found = found + 1
				local rst = UI.rows[feat.Id]
				local on = rst and rst.state or false

				local row = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = th.Row,
					BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = order}, searchPage)
				corner(row, 12)
				stroke(row, th.Accent, 1, on and 0.25 or 0.78)
				local ib = new("Frame", {Position = UDim2.new(0, 8, 0.5, -16), Size = UDim2.new(0, 32, 0, 32),
					BackgroundColor3 = th.Accent, BackgroundTransparency = on and 0.6 or 0.85, BorderSizePixel = 0}, row)
				corner(ib, 9)
				new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Text = feat.Icon or "✦",
					Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = WHITE}, ib)
				new("TextLabel", {Position = UDim2.new(0, 48, 0, 6), Size = UDim2.new(1, -104, 0, 18), BackgroundTransparency = 1,
					Text = feat.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = th.Text,
					TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
				new("TextLabel", {Position = UDim2.new(0, 48, 0, 25), Size = UDim2.new(1, -104, 0, 14), BackgroundTransparency = 1,
					Text = feat.Tab .. "  ·  " .. (feat.Sub or ""), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = th.Sub,
					TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)

				local pill = new("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.new(0, 40, 0, 22), BackgroundColor3 = (feat.Button or on) and th.On or th.Off,
					BorderSizePixel = 0}, row)
				corner(pill, 11)
				if feat.Button then
					new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Text = "GO", Font = Enum.Font.GothamBold,
						TextSize = 11, TextColor3 = WHITE}, pill)
				else
					local kn = new("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, on and 21 or 3, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16), BorderSizePixel = 0,
						BackgroundColor3 = on and WHITE or (th.KnobOff or Color3.fromRGB(205, 200, 225))}, pill)
					corner(kn, 8)
				end

				local btn = new("TextButton", {Size = FULL, BackgroundTransparency = 1, Text = "", ZIndex = 10}, row)
				btn.MouseEnter:Connect(function() tween(row, 0.15, {BackgroundTransparency = 0.12}) end)
				btn.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundTransparency = 0.3}) end)
				btn.MouseButton1Click:Connect(function()
					PlayUISound(SND.click, 0.45, on and 0.9 or 1.18)
					feat.Toggle()
					task.delay(0.15, function() if UI.searching then UI.runSearch() end end)
				end)
				order = order + 1
			end
		end

		new("TextLabel", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0,
			Text = found > 0 and ("  🔍  Found: " .. found) or "  🔍  Nothing found",
			Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = th.Accent,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, searchPage)
		searchPage.CanvasPosition = Vector2.new(0, 0)
	end

	sInput:GetPropertyChangedSignal("Text"):Connect(function()
		if UI.clearing then return end
		UI.runSearch()
	end)
	sClear.MouseButton1Click:Connect(function()
		PlayUISound(SND.click, 0.3, 1.3)
		sInput.Text = ""
	end)

	local toast = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 60), Size = UDim2.new(0, 0, 0, 38),
		AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Themes[1].Panel, BackgroundTransparency = 0.1,
		Text = "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE, Visible = false, ZIndex = 40,
	}, sg)
	corner(toast, 19)
	new("UIPadding", {PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)}, toast)
	local toastStroke = stroke(toast, Themes[1].Accent, 1.5, 0.15)
	UI.bind(function(t) toast.BackgroundColor3 = t.Panel; toast.TextColor3 = t.Text; toastStroke.Color = t.Accent end)
	local toastId = 0
	function UI.notify(text)
		toastId = toastId + 1
		local id = toastId
		toast.Text = text
		toast.Position = UDim2.new(0.5, 0, 1, 60)
		toast.Visible = true
		PlayUISound(SND.click, 0.4, 1.3)
		tween(toast, 0.4, {Position = UDim2.new(0.5, 0, 1, -28)}, EASE.Back)
		task.delay(3.4, function()
			if toastId ~= id then return end
			tween(toast, 0.3, {Position = UDim2.new(0.5, 0, 1, 60)}, EASE.Back, DIR.In)
			task.delay(0.35, function() if toastId == id then toast.Visible = false end end)
		end)
	end

	local mini = new("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -50), Size = UDim2.new(0, 176, 0, 36),
		Text = "  vizer visual AI", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(248, 232, 255),
		BackgroundColor3 = Color3.fromRGB(28, 16, 60), BackgroundTransparency = 0.2, AutoButtonColor = false,
		Visible = false, ZIndex = 20,
	}, sg)
	corner(mini, 18)
	local miniStroke = stroke(mini, Themes[1].Accent, 1.5, 0.15)
	UI.bind(function(t) miniStroke.Color = t.Accent; mini.TextColor3 = t.Text; mini.BackgroundColor3 = t.Panel end)
	mini.MouseEnter:Connect(function() tween(mini, 0.2, {Size = UDim2.new(0, 190, 0, 38)}, EASE.Back) end)
	mini.MouseLeave:Connect(function() tween(mini, 0.2, {Size = UDim2.new(0, 176, 0, 36)}) end)

	local border = new("Frame", {Size = FULL, BackgroundTransparency = 1, ZIndex = 8}, root)
	corner(border, 22)
	local bstroke = stroke(border, WHITE, 2.2, 0)
	local bgrad = new("UIGradient", {}, bstroke)
	UI.bind(function(t)
		bgrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, t.Accent), ColorSequenceKeypoint.new(0.5, t.Accent2), ColorSequenceKeypoint.new(1, t.Accent),
		})
	end)
	do
		local tw = TweenService:Create(bgrad, TweenInfo.new(5, EASE.Linear, DIR.Out, -1), {Rotation = 360})
		tw:Play(); table.insert(UI.ambient, tw)
	end

	function UI.applyAnim()
		local play = UI.open and not MISC.animOff
		for _, tw in ipairs(UI.ambient) do
			if play then tw:Play() else tw:Pause() end
		end
	end

	function UI.toggle()
		if UI.busy then return end
		UI.busy = true
		if UI.open then
			UI.open = false
			PlayUISound(SND.click, 0.5, 0.8)
			tween(pop, 0.28, {Scale = 0.88}, EASE.Back, DIR.In)
			tween(main, 0.28, {GroupTransparency = 1})
			tween(glowGroup, 0.28, {GroupTransparency = 1})
			tween(bstroke, 0.28, {Transparency = 1})
			UIS.MouseBehavior = savedMouseBehavior; UIS.MouseIconEnabled = savedMouseIcon
			task.delay(0.3, function()
				holder.Visible = false
				UI.applyAnim()
				mini.Position = UDim2.new(0.5, 0, 0, -50)
				mini.Visible = true
				tween(mini, 0.4, {Position = UDim2.new(0.5, 0, 0, 14)}, EASE.Back)
				UI.busy = false
			end)
		else
			UI.open = true
			UI.applyAnim()
			PlayUISound(SND.click, 0.5, 1.25)
			tween(mini, 0.25, {Position = UDim2.new(0.5, 0, 0, -50)}, EASE.Back, DIR.In)
			task.delay(0.26, function() mini.Visible = false end)
			savedMouseBehavior = UIS.MouseBehavior; savedMouseIcon = UIS.MouseIconEnabled
			UIS.MouseBehavior = Enum.MouseBehavior.Default; UIS.MouseIconEnabled = true
			pop.Scale = 0.88
			main.GroupTransparency = 1; glowGroup.GroupTransparency = 1; bstroke.Transparency = 1
			holder.Visible = true
			tween(pop, 0.45, {Scale = 1}, EASE.Back)
			tween(main, 0.35, {GroupTransparency = 0})
			tween(glowGroup, 0.5, {GroupTransparency = 0})
			tween(bstroke, 0.4, {Transparency = 0})
			task.delay(0.45, function() UI.busy = false end)
			if RefreshToggles then RefreshToggles() end
			UI.switch(UI.active)
		end
	end
	closeBtn.MouseButton1Click:Connect(function() UI.toggle() end)
	mini.MouseButton1Click:Connect(function() UI.toggle() end)

	local dragging, dragStart, startPos = false, nil, nil
	dragZone.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = holder.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	local petals = {}
	for i = 1, 10 do
		local f = new("Frame", {
			Size = UDim2.new(0, 7 + math.random() * 6, 0, 5 + math.random() * 3),
			BackgroundColor3 = Color3.fromRGB(255, 165 + math.random(0, 40), 215),
			BackgroundTransparency = 0.2 + math.random() * 0.3, BorderSizePixel = 0, ZIndex = 3,
		}, petalLayer)
		corner(f, 10)
		petals[i] = {f = f, x = math.random(), y = math.random(), vy = 0.04 + math.random() * 0.06,
			ph = math.random() * 6.28, rs = (math.random() - 0.5) * 140}
	end
	local sparks = {}
	for i = 1, 8 do
		local l = new("TextLabel", {
			Position = UDim2.new(math.random(), 0, math.random(), 0), Size = UDim2.new(0, 14, 0, 14),
			BackgroundTransparency = 1, Text = "✦", Font = Enum.Font.GothamBold, TextSize = 8 + math.random(0, 8),
			TextColor3 = Color3.fromRGB(255, 225, 250), ZIndex = 3,
		}, petalLayer)
		sparks[i] = {l = l, ph = math.random() * 6.28, sp = 1.2 + math.random() * 2}
	end
	UI.bind(function(t) for _, s in ipairs(sparks) do s.l.TextColor3 = t.Accent2 end end)
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		if not UI.open or MISC.animOff then return end
		accum = accum + dt
		if accum < 0.033 then return end
		dt = accum; accum = 0
		local tm = os.clock()
		for _, p in ipairs(petals) do
			p.y = p.y + p.vy * dt
			if p.y > 1.05 then p.y = -0.05; p.x = math.random() end
			p.f.Position = UDim2.new(p.x + math.sin(tm * 1.3 + p.ph) * 0.02, 0, p.y, 0)
			p.f.Rotation = p.f.Rotation + p.rs * dt
		end
		for _, s in ipairs(sparks) do
			s.l.TextTransparency = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(tm * s.sp + s.ph))
		end
	end)

	UI.applyAnim()
	UI.holder, UI.mini = holder, mini
end

UpdateToggleVisual = function(id, state)
	local r = UI.rows[id]
	if r then
		local changed = r.state ~= state
		r.set(state)
		if changed then MISC.dirty() end
	else
		UI.pending[id] = state
	end
end

do
	local K = Enum.KeyCode
	local function A(tab, id, name, sub, icon, key, fn)
		UI.add({Tab = tab, Id = id, Name = name, Sub = sub, Icon = icon, Key = key, Toggle = fn})
	end

	UI.section("Visuals", "✨  Visual effects")
	A("Visuals", "FireTrail", "Trail", "Fire trail effect", "🔥", K.C, function() ApplyFireTrail(not fireTrailEnabled) end)
	A("Visuals", "Petals", "vizer", "Cherry petals fall", "💎", K.Y, function() ApplyPetals(not petalEnabled) end)
	A("Visuals", "JumpCircle", "Jump Circle", "Ring on jump", "💠", K.N, function() ApplyJumpCircle(not JC.on) end)

	UI.section("Visuals", "🎞  Post effects")
	A("Visuals", "MotionBlur", "Motion blur", "Blur while moving the camera", "🌀", nil, function() ApplyMotionBlur(not MB.on) end)
	UI.sliderRow("Visuals", "🌀  Motion blur strength: ", 10, 100, MB.k, function(v) MB.k = v end)

	MISC.sl = {}
	UI.section("Movement", "🚀  Speed")
	A("Movement", "Speed", "Speed", "Change walk speed", "🚀", K.RightBracket, function() ApplySpeed(not MV.speedOn) end)
	MISC.sl.speed = UI.sliderRow("Movement", "🚀  Speed: ", 0, 100, MV.speedV, function(v) MV.speedV = v end)

	UI.section("Movement", "🕊  Flight")
	A("Movement", "Fly", "Fly", "WASD + Space / Shift", "🕊", K.Equals, function() ApplyFly(not MV.fly) end)
	A("Movement", "InfJump", "Infinity jump", "Jump in the air", "♾", K.Minus, function() ApplyInfJump(not MV.ij) end)
	A("Movement", "Noclip", "Noclip", "Walk through walls", "👻", K.Insert, function() ApplyNoclip(not MV.noclip) end)
	A("Movement", "ClickTP", "Click TP", "Right-click to teleport", "📍", K.Home, function() ApplyClickTP(not MV.ctp) end)
	MISC.sl.fly = UI.sliderRow("Movement", "🕊  Fly speed: ", 10, 200, MV.flyV, function(v) MV.flyV = v end)

	UI.section("Movement", "🏃  Jumping")
	A("Movement", "HighJump", "Long jump", "Jump higher", "🦘", K.T, function() ApplyHighJump(not highJumpEnabled) end)
	A("Movement", "AutoJump", "Auto jump", "Jump on landing", "🔁", K.J, function() ApplyAutoJump(not AJ.on) end)
	UI.speedLabel = UI.infoRow("Movement", "⚡  Speed: 0.0 stu/s")

	UI.section("Player", "👤  Character")
	A("Player", "Headless", "Headless", "Hide your head", "👻", K.H, function() ApplyHeadless(not headlessEnabled) end)
	A("Player", "Nameplates", "Player name", "Show player names", "🏷", K.M, function() ApplyNameplates(not nameplatesEnabled) end)

	UI.section("Player", "🧍  Body")
	A("Player", "Ghost", "Ghost mode", "Semi-transparent character", "💨", nil, function() ApplyGhost(not GH.on) end)
	UI.sliderRow("Player", "💨  Ghost transparency %: ", 10, 90, GH.a, function(v) GH.a = v end)

	UI.section("World", "🌍  Environment")
	A("World", "NightVision", "Night vision", "See in the dark", "🌙", K.O, function() ApplyNightVision(not nightVisionEnabled) end)
	A("World", "Fog", "Fog", "Soft colored fog", "🌫", K.G, function() ApplyFog(not FOG.on) end)
	A("World", "Snow", "Snow", "Snowfall", "❄", K.F2, function() ApplySnow(not SN.on) end)
	A("World", "FPSBoost", "Anti-lag", "Less lag, more FPS", "⚡", K.L, function() ApplyFPSBoost(not fpsBoostEnabled) end)
	A("World", "Fullbright", "Fullbright", "Remove darkness", "💡", K.End, function() ApplyFullbright(not MISC.fb) end)
	UI.sliderRow("World", "⚡  Anti-lag level (1 light · 3 max): ", 1, 3, MISC.lagLevel, function(v)
		MISC.lagLevel = v
		MISC.lagTick = (MISC.lagTick or 0) + 1
		local t = MISC.lagTick
		task.delay(0.6, function()
			if t == MISC.lagTick and fpsBoostEnabled then ApplyFPSBoost(true) end
		end)
	end)
	UI.section("World", "📦  Pallets")
	A("World", "Pallets", "Anonymous pallet", "Black pallet", "📦", K.V, function() ApplyPallets(not palletEnabled) end)
	A("World", "Pallets2", "Pink pallet", "Pink + crosses", "🎀", K.B, function() ApplyPallets2(not PK.on) end)
	A("World", "Pallets3", "White pallet", "White neon", "🤍", K.R, function() ApplyPallets3(not PW.on) end)
	UI.section("World", "☁  Sky")
	for i, preset in ipairs(SkyPresets) do
		UI.add({Tab = "World", Id = "Sky" .. i, Name = "Sky " .. preset.Name, Sub = "Skybox preset", Icon = "🌌",
			Toggle = function() ApplySky(i, skyEnabledIndex ~= i) end})
	end

	UI.section("Misc", "🔧  Utilities")
	A("Misc", "AntiAfk", "Anti-AFK", "Prevent AFK kick", "🛡", K.K, function() ApplyAntiAfk(not antiAfkEnabled) end)
	A("Misc", "CameraZoom", "Camera zoom", "Zoom out camera", "🔍", K.F5, function() ApplyCameraZoom(not cameraZoomEnabled) end)
	A("Misc", "CameraSmooth", "Camera smooth", "Smooth camera", "🎥", K.P, function() ApplyCameraSmooth(not cameraSmoothEnabled) end)
	A("Misc", "Freecam", "Freecam", "WASD QE · RMB look", "📷", K.F6, function() ApplyFreecam(not MISC.fcOn) end)
	A("Misc", "ESP", "ESP", "Player outline", "👁", K.F7, function() ApplyESP(not MISC.espOn) end)
	A("Misc", "FriendESP", "Friend ESP", "Friends: own color", "💚", nil, function() ApplyFriendESP(not MISC.fespOn) end)
	A("Misc", "FpsHud", "FPS counter", "Top-right HUD", "📊", nil, function() ApplyFpsHud(not MISC.fpsOn) end)
	A("Misc", "PingHud", "Ping counter", "Top-right HUD", "📶", nil, function() ApplyPingHud(not MISC.pingOn) end)
	UI.add({Tab = "Misc", Id = "Rejoin", Name = "Rejoin", Sub = "Same server", Icon = "🔁", Button = true,
		Toggle = function() MISC.rejoin() end})
	UI.add({Tab = "Misc", Id = "ServerHop", Name = "Server hop", Sub = "New server", Icon = "🌐", Button = true,
		Toggle = function() MISC.serverHop() end})
	UI.add({Tab = "Misc", Id = "VipServer", Name = "VIP server", Sub = "Join your private server", Icon = "👑", Button = true,
		Toggle = function() MISC.joinVip() end})

	local currentFOV = 70
	local fovLabel
	local function UpdateFOV(v)
		currentFOV = math.clamp(v, 30, 120)
		if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = currentFOV end
		fovLabel.Text = "🎥  FOV: " .. currentFOV
	end
	fovLabel = UI.stepRow("Misc", "🎥  FOV: 70", {
		{"+", function() UpdateFOV(currentFOV + 10) end},
		{"−", function() UpdateFOV(currentFOV - 10) end},
		{"↺", function() UpdateFOV(70) end},
	})

	local smLabel
	local function setLevel(n)
		CSM.level = math.clamp(n, 1, 5)
		smLabel.Text = "🎚  Smoothness: " .. CSM.level .. "/5"
		MISC.dirty()
	end
	smLabel = UI.stepRow("Misc", "", {
		{"+", function() setLevel(CSM.level + 1) end},
		{"−", function() setLevel(CSM.level - 1) end},
	})
	setLevel(CSM.level)
	UI.setSmooth = setLevel

	MISC.sl.fc = UI.sliderRow("Misc", "📷  Freecam speed: ", 10, 200, MISC.fcSpeed, function(v) MISC.fcSpeed = v end)

	UI.section("Misc", "🖥  Stretch screen")
	A("Misc", "Stretch", "Stretch screen", "Wide-screen look", "🖥", nil, function() ApplyStretch(not MISC.stretchOn) end)
	UI.sliderRow("Misc", "🖥  Stretch: ", 20, 100, MISC.stretchV, function(v) MISC.stretchV = v end)

	UI.section("Misc", "🔭  Hold zoom")
	UI.add({Tab = "Misc", Id = "ZoomKey", Name = "Hold zoom", Sub = "Hold the key (click = lock)", Icon = "🔭", Key = K.F,
		Hold = true,
		Toggle = function() ZM.latch = not ZM.latch; UpdateToggleVisual("ZoomKey", ZM.latch) end,
		Down = function() ZM.held = true end,
		Up = function() ZM.held = false end})
	UI.sliderRow("Misc", "🔭  Zoom power x: ", 2, 10, ZM.x, function(v) ZM.x = v end)

	local function T(tab, id, name, sub, icon)
		UI.add({Tab = tab, Id = id, Name = name, Sub = sub, Icon = icon, Toggle = XT(id)})
	end
	local function Bt(tab, id, name, sub, icon, fn)
		UI.add({Tab = tab, Id = id, Name = name, Sub = sub, Icon = icon, Button = true, Toggle = fn})
	end

	UI.section("Visuals", "🌈  More effects")
	T("Visuals", "Rain", "Rain", "Rainfall around you", "🌧")
	T("Visuals", "Rainbow", "Rainbow body", "Your body cycles colors", "🌈")
	T("Visuals", "Vibrant", "Vibrant colors", "More saturated image", "🎨")
	T("Visuals", "BW", "Black & white", "Monochrome filter", "⚫")
	T("Visuals", "Vignette", "Vignette", "Dark screen edges", "🔲")
	T("Visuals", "Bars", "Cinematic bars", "Black bars top & bottom", "🎬")

	UI.section("World", "🕒  Time & light")
	T("World", "CustomTime", "Custom time", "Fixed time of day", "🕒")
	UI.sliderRow("World", "🕒  Time of day (hour): ", 0, 24, EXT.time, function(v) EXT.time = v end)
	T("World", "TimeLapse", "Time lapse", "Day & night cycle fast", "⏩")
	UI.sliderRow("World", "⏩  Time lapse speed: ", 1, 100, EXT.lapse, function(v) EXT.lapse = v end)
	T("World", "Ambient", "Ambient color", "Tint the world light", "🎇")
	T("World", "XRay", "X-ray", "See-through map", "🔍")

	UI.section("Movement", "🌀  More movement")
	T("Movement", "LowGravity", "Gravity", "Custom world gravity", "🪐")
	UI.sliderRow("Movement", "🪐  Gravity: ", 10, 196, EXT.grav, function(v) EXT.grav = v end)
	T("Movement", "Spin", "Spin", "Your character spins", "🌪")
	UI.sliderRow("Movement", "🌪  Spin speed: ", 1, 100, EXT.spin, function(v) EXT.spin = v end)

	UI.section("Player", "👁  View")
	T("Player", "NameESP", "Name tags", "Nicks + distance overhead", "🏷")

	UI.section("Misc", "🧰  More utilities")
	T("Misc", "HideHUD", "Hide Roblox UI", "Chat, list, backpack off", "🫥")
	T("Misc", "CoordsHUD", "Coordinates", "XYZ on screen", "🧭")
	T("Misc", "FPSCap", "FPS unlock", "Raise the FPS cap", "🚀")
	UI.sliderRow("Misc", "🚀  FPS cap: ", 30, 360, EXT.fpscap, function(v)
		EXT.fpscap = v
		if XS.FPSCap then XApplyFpsCap() end
	end)
	Bt("Misc", "SetWP", "Set waypoint", "Save current position", "📍", function() XH.btnSetWP() end)
	Bt("Misc", "GoWP", "Go to waypoint", "Teleport to saved point", "🏁", function() XH.btnGoWP() end)
	Bt("Misc", "CopyPos", "Copy position", "XYZ to clipboard", "📋", function() XH.btnCopy() end)
	Bt("Misc", "Refresh", "Respawn here", "Reset, return to same spot", "🔄", function() XH.btnRefresh() end)
	Bt("Misc", "ResetChar", "Reset character", "Kill your character", "💀", function() XH.btnReset() end)
	Bt("Misc", "SitBtn", "Sit / stand", "Toggle sitting", "🪑", function() XH.btnSit() end)

	UI.section("Visuals", "🎥  Camera & screen")
	T("Visuals", "SpeedFov", "Speed FOV", "FOV widens when you run", "💨")
	T("Visuals", "CamTilt", "Camera tilt", "Rolled camera angle", "📐")
	UI.sliderRow("Visuals", "📐  Tilt angle: ", -45, 45, EXT.tilt, function(v) EXT.tilt = v end)
	T("Visuals", "Mirror", "Mirror screen", "Flip the image", "🪞")
	T("Visuals", "Blur", "Screen blur", "Constant soft blur", "🌫")
	UI.sliderRow("Visuals", "🌫  Blur size: ", 1, 40, EXT.blur, function(v)
		EXT.blur = v
		if XFX.blur then XFX.blur.Size = v end
	end)
	T("Visuals", "Tint", "Color tint", "Tint the whole screen", "🎨")
	T("Visuals", "Bright", "Brightness", "Brighter / darker image", "☀")
	UI.sliderRow("Visuals", "☀  Brightness: ", -50, 50, EXT.bright, function(v)
		EXT.bright = v
		if XFX.bright then XFX.bright.Brightness = v / 100 end
	end)
	T("Visuals", "Disco", "Disco light", "Flashing rainbow light", "🪩")

	T("Movement", "AntiVoid", "Anti-void", "Back to safe ground if you fall", "🛟")
	T("Movement", "Freeze", "Freeze", "Hold your character in place", "🧊")

	UI.section("Misc", "🧩  Extra tools")
	T("Misc", "CamNoclip", "Camera through walls", "Camera ignores walls", "🎥")
	T("Misc", "JoinAlerts", "Join alerts", "Notify when players join/leave", "🔔")
	T("Misc", "Mute", "Mute game", "Silence game audio", "🔇")
	T("Misc", "ClockHUD", "Clock", "Real time on screen", "🕐")
	T("Misc", "PlayersHUD", "Players counter", "Players in server", "👥")
	T("Misc", "SpeedHUD", "Speed counter", "Your speed on screen", "⚡")
	Bt("Misc", "SpawnTP", "Go to spawn", "Teleport to spawn", "🏠", function() XH.btnSpawn() end)
	Bt("Misc", "RandTP", "Random player", "Teleport to a random player", "🎲", function() XH.btnRandom() end)

	T("Visuals", "FovLock", "FOV lock", "Fixed field of view", "🔎")
	UI.sliderRow("Visuals", "🔎  FOV lock: ", 30, 120, EXT.fov, function(v) EXT.fov = v end)
	T("Movement", "JumpPower", "Jump power", "Custom jump strength", "🦘")
	UI.sliderRow("Movement", "🦘  Jump power: ", 20, 300, EXT.jump, function(v) EXT.jump = v end)
	Bt("World", "SetDay", "Set day", "Switch to daytime", "🌞", function() XH.btnDay() end)
	Bt("World", "SetNight", "Set night", "Switch to night", "🌙", function() XH.btnNight() end)
	T("Misc", "SessionHUD", "Play time", "Session timer on screen", "⏱")
	T("Misc", "ServerHUD", "Server uptime", "How long the server runs", "🖥")
end

local smoothCameraCFrame = nil

ApplyCameraSmooth = function(state)
	cameraSmoothEnabled = state
	pcall(function() RunService:UnbindFromRenderStep("vizerCameraSmooth") end)
	smoothCameraCFrame = nil

	if state then
		RunService:BindToRenderStep("vizerCameraSmooth", Enum.RenderPriority.Camera.Value + 1, function(dt)
			Camera = workspace.CurrentCamera
			if not Camera then return end
			if Camera.CameraType == Enum.CameraType.Scriptable then
				smoothCameraCFrame = nil
				return
			end

			local target = Camera.CFrame
			local targetRot = target.Rotation

			if not smoothCameraCFrame or smoothCameraCFrame.LookVector:Dot(target.LookVector) < 0.2 then
				smoothCameraCFrame = targetRot
				return
			end

			local alpha = 1 - math.exp(-CSM.rates[CSM.level] * dt)
			smoothCameraCFrame = smoothCameraCFrame:Lerp(targetRot, alpha)

			local pos = target.Position
			local offset = target.Position - Camera.Focus.Position
			if offset.Magnitude < 100 then
				local delta = smoothCameraCFrame * targetRot:Inverse()
				pos = Camera.Focus.Position + delta:VectorToWorldSpace(offset)
			end
			if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then
				smoothCameraCFrame = nil
				return
			end
			Camera.CFrame = CFrame.new(pos) * smoothCameraCFrame
		end)
	end

	UpdateToggleVisual("CameraSmooth", state)
end

MISC.lagQ = {Enum.QualityLevel.Level08, Enum.QualityLevel.Level04, Enum.QualityLevel.Level01}

function MISC.lagSkip(d)
	local ch = player.Character
	if ch and d:IsDescendantOf(ch) then return true end
	local m = d:FindFirstAncestorOfClass("Model")
	while m do
		if Players:GetPlayerFromCharacter(m) == player then return true end
		local up = m.Parent
		m = up and up:FindFirstAncestorOfClass("Model") or nil
	end
	local p = d.Parent
	for _ = 1, 3 do
		if not p then break end
		local n = p.Name
		if n:sub(1, 6) == "vizer" or n == "Shadoweffect" or n == "PinkPalletEffect" then return true end
		p = p.Parent
	end
	return false
end

function MISC.lagApply(d, level)
	local L = MISC.lag
	if d:IsA("BasePart") then
		if MISC.lagSkip(d) then return end
		local o = L.parts[d]
		if not o then
			o = {shadow = d.CastShadow, mat = d.Material, refl = d.Reflectance}
			if d:IsA("MeshPart") then o.rf = d.RenderFidelity end
			L.parts[d] = o
		end
		d.CastShadow = false
		if level >= 2 and o.mat ~= Enum.Material.Neon and o.mat ~= Enum.Material.ForceField then
			d.Material = Enum.Material.SmoothPlastic
			d.Reflectance = 0
			if o.rf then pcall(function() d.RenderFidelity = Enum.RenderFidelity.Performance end) end
		else
			d.Material = o.mat
			d.Reflectance = o.refl
			if o.rf then pcall(function() d.RenderFidelity = o.rf end) end
		end
	elseif d:IsA("Decal") or d:IsA("Texture") then
		if d.Name == "face" or d.Name:find("Pallet") or (d.Parent and d.Parent:IsA("SpawnLocation")) or MISC.lagSkip(d) then return end
		local o = L.decals[d]
		if level >= 3 then
			if o == nil then L.decals[d] = d.Transparency end
			d.Transparency = 1
		elseif o ~= nil then
			d.Transparency = o
		end
	elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
		if MISC.lagSkip(d) then return end
		if L.emit[d] == nil then L.emit[d] = d.Enabled end
		d.Enabled = false
	end
end

function MISC.lagGlobals(on, level)
	local L = MISC.lag
	if on then
		if not L.g then
			L.g = {post = {}}
			L.g.shadows = Lighting.GlobalShadows
			pcall(function() L.g.quality = settings().Rendering.QualityLevel end)
			pcall(function()
				local t = workspace.Terrain
				L.g.terrain = {deco = t.Decoration, size = t.WaterWaveSize, speed = t.WaterWaveSpeed, refl = t.WaterReflectance}
			end)
		end
		Lighting.GlobalShadows = false
		local function killPost(parent)
			for _, v in ipairs(parent:GetChildren()) do
				if v:IsA("PostEffect") and v.Name:sub(1, 6) ~= "vizer" and v.Enabled then
					L.g.post[v] = true
					v.Enabled = false
				end
			end
		end
		killPost(Lighting)
		if workspace.CurrentCamera then killPost(workspace.CurrentCamera) end
		pcall(function()
			local t = workspace.Terrain
			t.Decoration = false; t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0
		end)
		pcall(function() settings().Rendering.QualityLevel = MISC.lagQ[level] end)
	else
		local g = L.g
		if not g then return end
		L.g = nil
		Lighting.GlobalShadows = g.shadows
		for v in pairs(g.post) do if v.Parent then v.Enabled = true end end
		pcall(function()
			local t = workspace.Terrain
			if g.terrain then
				t.Decoration = g.terrain.deco; t.WaterWaveSize = g.terrain.size
				t.WaterWaveSpeed = g.terrain.speed; t.WaterReflectance = g.terrain.refl
			end
		end)
		pcall(function() if g.quality then settings().Rendering.QualityLevel = g.quality end end)
	end
end

ApplyFPSBoost = function(state)
	fpsBoostEnabled = state
	local L = MISC.lag
	L.token = (L.token or 0) + 1
	local tok = L.token
	if L.conn then L.conn:Disconnect(); L.conn = nil end

	if state then
		local level = MISC.lagLevel
		MISC.lagGlobals(true, level)
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if L.token ~= tok then return end
				MISC.lagApply(d, level)
				n = n + 1
				if n % 1500 == 0 then task.wait() end
			end
		end)
		L.conn = workspace.DescendantAdded:Connect(function(d)
			task.defer(function()
				if L.token == tok then MISC.lagApply(d, level) end
			end)
		end)
	else
		MISC.lagGlobals(false)
		task.spawn(function()
			local n = 0
			local function step()
				n = n + 1
				if n % 1500 == 0 then task.wait() end
			end
			for part, o in pairs(L.parts) do
				if L.token ~= tok then return end
				if part.Parent then
					part.CastShadow = o.shadow; part.Material = o.mat; part.Reflectance = o.refl
					if o.rf then pcall(function() part.RenderFidelity = o.rf end) end
				end
				L.parts[part] = nil
				step()
			end
			for dec, tr in pairs(L.decals) do
				if L.token ~= tok then return end
				if dec.Parent then dec.Transparency = tr end
				L.decals[dec] = nil
				step()
			end
			for e, en in pairs(L.emit) do
				if L.token ~= tok then return end
				if e.Parent then e.Enabled = en end
				L.emit[e] = nil
				step()
			end
		end)
	end

	UpdateToggleVisual("FPSBoost", state)
end

function SKY.clearAtm()
	if SKY.atm then SKY.atm:Destroy(); SKY.atm = nil end
	for _, a in ipairs(SKY.hidden) do
		pcall(function() a.Parent = Lighting end)
	end
	SKY.hidden = {}
end

function SKY.applyAtm(cfg)
	SKY.clearAtm()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then
			table.insert(SKY.hidden, v)
			v.Parent = nil
		end
	end
	local a = Instance.new("Atmosphere")
	a.Density = cfg.Density; a.Offset = cfg.Offset
	a.Color = cfg.Color; a.Decay = cfg.Decay
	a.Glare = cfg.Glare; a.Haze = cfg.Haze
	a.Parent = Lighting
	SKY.atm = a
end

ApplySky = function(index, state)
	if state then
		for i = 1, #SkyPresets do
			if i ~= index then UpdateToggleVisual("Sky" .. i, false) end
		end

		local preset = SkyPresets[index]
		if skyInstance then skyInstance:Destroy(); skyInstance = nil end
		SKY.clearAtm()

		skyInstance = Instance.new("Sky")
		skyInstance.CelestialBodiesShown = preset.CelestialBodiesShown
		skyInstance.MoonAngularSize      = preset.MoonAngularSize
		skyInstance.MoonTextureId        = preset.MoonTextureId
		skyInstance.SkyboxBk             = preset.SkyboxBk
		skyInstance.SkyboxDn             = preset.SkyboxDn
		skyInstance.SkyboxFt             = preset.SkyboxFt
		skyInstance.SkyboxLf             = preset.SkyboxLf
		skyInstance.SkyboxRt             = preset.SkyboxRt
		skyInstance.SkyboxUp             = preset.SkyboxUp
		skyInstance.StarCount            = preset.StarCount
		skyInstance.SunAngularSize       = preset.SunAngularSize
		skyInstance.SunTextureId         = preset.SunTextureId
		skyInstance.Parent               = Lighting

		if preset.Atmosphere then SKY.applyAtm(preset.Atmosphere) end

		skyEnabledIndex = index
		UpdateToggleVisual("Sky" .. index, true)
	else
		if skyEnabledIndex == index then
			skyEnabledIndex = 0
			if skyInstance then skyInstance:Destroy(); skyInstance = nil end
			SKY.clearAtm()
		end
		UpdateToggleVisual("Sky" .. index, false)
	end
end

local function GetHeadlessTargets(char)
	return char:FindFirstChild("Head")
end

ApplyHeadless = function(state)
	headlessEnabled = state
	if headlessLoopConn then headlessLoopConn:Disconnect(); headlessLoopConn = nil end

	if state then
		headlessLoopConn = RunService.Heartbeat:Connect(function()
			if not headlessEnabled then return end
			local ch = player.Character
			if not ch or not ch:IsDescendantOf(workspace) then return end
			local head = GetHeadlessTargets(ch)
			if head and head.LocalTransparencyModifier ~= 1 then
				head.LocalTransparencyModifier = 1
			end
		end)
	else
		local ch = player.Character
		local head = ch and GetHeadlessTargets(ch)
		if head then head.LocalTransparencyModifier = 0 end
	end

	UpdateToggleVisual("Headless", state)
end

local PALLET_NAME = "PalletLightBrown"
local PALLET_COLOR = Color3.fromRGB(0, 0, 0)
local PALLET_MATERIAL = Enum.Material.Plastic
local PALLET_DECAL_TEXTURE = "rbxassetid://7049300738"
local PALLET_PARTICLE_TEXTURE = "http://www.roblox.com/asset/?id=187823474"

local palletSaved = setmetatable({}, {__mode = "k"})

local function PalletGetParts(object)
	local parts = {}
	if object:IsA("BasePart") then
		table.insert(parts, object)
	else
		for _, obj in ipairs(object:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name ~= "Shadoweffect" then
				table.insert(parts, obj)
			end
		end
	end
	return parts
end

local function PalletFindTopPart(object)
	local parts = PalletGetParts(object)
	if #parts == 0 then return nil end

	local highestY = -math.huge
	for _, part in ipairs(parts) do
		local topY = part.Position.Y + part.Size.Y / 2
		if topY > highestY then highestY = topY end
	end

	local topPart = nil
	local biggestArea = 0
	for _, part in ipairs(parts) do
		local topY = part.Position.Y + part.Size.Y / 2
		if math.abs(topY - highestY) <= 0.2 then
			local area = part.Size.X * part.Size.Z
			if area > biggestArea then
				biggestArea = area
				topPart = part
			end
		end
	end
	return topPart
end

local function PalletSaveOriginal(pallet)
	local data = palletSaved[pallet]
	if not data then
		data = {parts = {}, textures = {}}
		palletSaved[pallet] = data
	end
	for _, part in ipairs(PalletGetParts(pallet)) do
		if not data.parts[part] then
			data.parts[part] = {Color = part.Color, Material = part.Material}
		end
	end
	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture"))
			and obj.Name ~= "CustomPalletDecal" and data.textures[obj] == nil then
			data.textures[obj] = obj.Transparency
		end
	end
end

local function PalletHideOriginalTextures(pallet)
	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Name ~= "CustomPalletDecal" then
			obj.Transparency = 1
		end
	end
end

local function PalletRemoveCustomObjects(pallet)
	for _, obj in ipairs(pallet:GetDescendants()) do
		if obj.Name == "CustomPalletDecal" or obj.Name == "Shadoweffect" then
			obj:Destroy()
		end
	end
end

local function PalletAddBigDecal(part)
	if not part then return end
	for _, obj in ipairs(part:GetChildren()) do
		if obj.Name == "CustomPalletDecal" and (obj:IsA("Decal") or obj:IsA("Texture")) then
			obj:Destroy()
		end
	end
	for i = 1, 2 do
		local decal = Instance.new("Decal")
		decal.Name = "CustomPalletDecal"
		decal.Face = Enum.NormalId.Top
		decal.Rotation = 90
		decal.Texture = PALLET_DECAL_TEXTURE
		decal.Color3 = Color3.fromRGB(255, 255, 255)
		decal.Transparency = 0
		decal.Parent = part
	end
end

local function PalletAddShadowEffectPart(pallet)
	local parts = PalletGetParts(pallet)
	if #parts == 0 then return end

	local centerPart = parts[1]
	local biggestVolume = 0
	for _, part in ipairs(parts) do
		local volume = part.Size.X * part.Size.Y * part.Size.Z
		if volume > biggestVolume then
			biggestVolume = volume
			centerPart = part
		end
	end

	local oldShadow = pallet:FindFirstChild("Shadoweffect")
	if oldShadow then oldShadow:Destroy() end

	local shadowPart = Instance.new("Part")
	shadowPart.Name = "Shadoweffect"
	shadowPart.Size = Vector3.new(2.5, 0.001, 11.5)
	shadowPart.Transparency = 1
	shadowPart.CanCollide = false
	shadowPart.CanTouch = false
	shadowPart.CanQuery = false
	shadowPart.CastShadow = false
	shadowPart.Material = Enum.Material.Plastic
	shadowPart.CFrame = centerPart.CFrame * CFrame.new(0, -0.75, 0) * CFrame.Angles(0, math.rad(90), 0)
	shadowPart.Parent = pallet

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = centerPart
	weld.Part1 = shadowPart
	weld.Parent = shadowPart

	local e = Instance.new("ParticleEmitter")
	e.Name = "Shadow"
	e.Texture = PALLET_PARTICLE_TEXTURE
	e.Brightness = 1
	e.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	e.LightEmission = 0
	e.LightInfluence = 0
	e.Orientation = Enum.ParticleOrientation.FacingCamera
	e.Size = NumberSequence.new(1)
	e.Squash = NumberSequence.new(0)
	e.Transparency = NumberSequence.new(0.5)
	e.ZOffset = 1
	e.EmissionDirection = Enum.NormalId.Left
	e.Enabled = true
	e.Lifetime = NumberRange.new(1, 1)
	e.Rate = 35
	e.Rotation = NumberRange.new(-180, 180)
	e.RotSpeed = NumberRange.new(0, 0)
	e.Speed = NumberRange.new(-5, 5)
	e.SpreadAngle = Vector2.new(360, 360)
	e.Acceleration = Vector3.new(0, 0, 0)
	pcall(function()
		e.Shape = Enum.ParticleEmitterShape.Box
		e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	end)
	e.Parent = shadowPart
end

local function PalletCustomize(pallet)
	if not pallet or pallet.Name ~= PALLET_NAME then return end
	if not pallet:IsA("Model") and not pallet:IsA("BasePart") then return end
	if not pallet.Parent then return end

	PalletSaveOriginal(pallet)
	for _, part in ipairs(PalletGetParts(pallet)) do
		part.Color = PALLET_COLOR
		part.Material = PALLET_MATERIAL
	end
	PalletHideOriginalTextures(pallet)

	local topPart = PalletFindTopPart(pallet)
	if topPart then PalletAddBigDecal(topPart) end
	PalletAddShadowEffectPart(pallet)
end

local function PalletRestore(pallet)
	local data = palletSaved[pallet]
	PalletRemoveCustomObjects(pallet)
	if not data then return end

	for part, info in pairs(data.parts) do
		if part and part.Parent then
			part.Color = info.Color
			part.Material = info.Material
		end
	end
	for obj, transparency in pairs(data.textures) do
		if obj and obj.Parent then obj.Transparency = transparency end
	end
end

local function SetAllPallets(state)
	if state then
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == PALLET_NAME then
				task.spawn(function() PalletCustomize(descendant) end)
			end
		end
	else
		for pallet in pairs(palletSaved) do
			if pallet and pallet.Parent then PalletRestore(pallet) end
		end
	end
end

PK.COLOR    = Color3.fromRGB(255, 78, 149)
PK.DECAL    = "rbxassetid://304489616"
PK.PARTICLE = "rbxassetid://501546562"

function PK.removeCustom(pallet)
	for _, obj in ipairs(pallet:GetDescendants()) do
		if obj.Name == "PinkPalletDecal" or obj.Name == "PinkPalletEffect" then obj:Destroy() end
	end
end

function PK.save(pallet)
	local data = PK.saved[pallet]
	if not data then
		data = {parts = {}, textures = {}}
		PK.saved[pallet] = data
	end
	for _, part in ipairs(PalletGetParts(pallet)) do
		if data.parts[part] == nil then data.parts[part] = part.Color end
	end
	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture"))
			and obj.Name ~= "PinkPalletDecal" and data.textures[obj] == nil then
			data.textures[obj] = obj.Transparency
		end
	end
end

function PK.customize(pallet)
	if not pallet or pallet.Name ~= PALLET_NAME or not pallet.Parent then return end
	if not pallet:IsA("Model") and not pallet:IsA("BasePart") then return end

	PK.save(pallet)
	PK.removeCustom(pallet)

	local parts = PalletGetParts(pallet)
	for _, part in ipairs(parts) do part.Color = PK.COLOR end

	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Name ~= "PinkPalletDecal" then
			obj.Transparency = 1
		end
	end

	local top = PalletFindTopPart(pallet)
	if top then
		local decal = Instance.new("Decal")
		decal.Name = "PinkPalletDecal"
		decal.Face = Enum.NormalId.Top
		decal.Rotation = 90
		decal.Texture = PK.DECAL
		decal.Color3 = Color3.fromRGB(255, 255, 255)
		decal.Transparency = 0
		decal.Parent = top
	end

	if #parts > 0 then
		local center = parts[1]
		local biggest = 0
		for _, part in ipairs(parts) do
			local v = part.Size.X * part.Size.Y * part.Size.Z
			if v > biggest then biggest = v; center = part end
		end

		local att = Instance.new("Attachment")
		att.Name = "PinkPalletEffect"
		att.Position = Vector3.new(0, -(center.Size.Y / 2) - 0.05, 0)
		att.Parent = center

		local e = Instance.new("ParticleEmitter")
		e.Name = "CenterCrossParticles"
		e.Texture = PK.PARTICLE
		e.Brightness = 1
		e.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		e.LightEmission = 0
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Size = NumberSequence.new(0.25)
		e.Squash = NumberSequence.new(0)
		e.Transparency = NumberSequence.new(0.5)
		e.ZOffset = 0
		e.EmissionDirection = Enum.NormalId.Bottom
		e.Enabled = true
		e.Lifetime = NumberRange.new(1, 1)
		e.Rate = 40
		e.Rotation = NumberRange.new(0, 360)
		e.RotSpeed = NumberRange.new(-30, 30)
		e.Speed = NumberRange.new(2.5, 2.5)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		end)
		e.Parent = att
	end
end

function PK.restore(pallet)
	PK.removeCustom(pallet)
	local data = PK.saved[pallet]
	if not data then return end
	for part, col in pairs(data.parts) do
		if part and part.Parent then part.Color = col end
	end
	for obj, tr in pairs(data.textures) do
		if obj and obj.Parent then obj.Transparency = tr end
	end
end

function PK.setAll(state)
	if state then
		for _, d in ipairs(workspace:GetDescendants()) do
			if d.Name == PALLET_NAME then task.spawn(function() PK.customize(d) end) end
		end
	else
		for pallet in pairs(PK.saved) do
			if pallet and pallet.Parent then PK.restore(pallet) end
		end
	end
end

do
	local pending = {}

	local function FindPallet(obj)
		local cur = obj
		while cur and cur ~= workspace do
			if cur.Name == PALLET_NAME and (cur:IsA("Model") or cur:IsA("BasePart")) then return cur end
			cur = cur.Parent
		end
	end

	local function Schedule(pallet)
		if pending[pallet] then return end
		pending[pallet] = true
		task.delay(0.4, function()
			pending[pallet] = nil
			if not pallet.Parent then return end
			if palletEnabled then PalletCustomize(pallet)
			elseif PK.on then PK.customize(pallet)
			elseif PW.on then PW.customize(pallet) end
		end)
	end

	workspace.DescendantAdded:Connect(function(d)
		if not (palletEnabled or PK.on or PW.on) then return end
		local n = d.Name
		if n == "CustomPalletDecal" or n == "Shadoweffect" or n == "PinkPalletDecal" or n == "PinkPalletEffect" or n == "WhitePalletDecal" then return end
		if not (n == PALLET_NAME or d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture")) then return end
		local pallet = FindPallet(d)
		if pallet then Schedule(pallet) end
	end)
end

PW.TEXTURE = "rbxassetid://71490357463486"
PW.TINT    = Color3.fromRGB(255, 0, 115)

function PW.removeCustom(pallet)
	for _, obj in ipairs(pallet:GetDescendants()) do
		if obj.Name == "WhitePalletDecal" then obj:Destroy() end
	end
end

function PW.save(pallet)
	local data = PW.saved[pallet]
	if not data then
		data = {parts = {}, textures = {}}
		PW.saved[pallet] = data
	end
	for _, part in ipairs(PalletGetParts(pallet)) do
		if data.parts[part] == nil then
			data.parts[part] = {Color = part.Color, Material = part.Material}
		end
	end
	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture"))
			and obj.Name ~= "WhitePalletDecal" and data.textures[obj] == nil then
			data.textures[obj] = obj.Transparency
		end
	end
end

function PW.customize(pallet)
	if not pallet or pallet.Name ~= PALLET_NAME or not pallet.Parent then return end
	if not pallet:IsA("Model") and not pallet:IsA("BasePart") then return end

	PW.save(pallet)
	PW.removeCustom(pallet)

	for _, part in ipairs(PalletGetParts(pallet)) do
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Material = Enum.Material.Neon
	end

	for _, obj in ipairs(pallet:GetDescendants()) do
		if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Name ~= "WhitePalletDecal" then
			obj.Transparency = 1
		end
	end

	local top = PalletFindTopPart(pallet)
	if top then
		local decal = Instance.new("Decal")
		decal.Name = "WhitePalletDecal"
		decal.Face = Enum.NormalId.Top
		decal.Texture = PW.TEXTURE
		decal.Color3 = Color3.fromRGB(255, 255, 255)
		decal.Transparency = 0
		pcall(function()
			decal.Rotation = 90
			decal.ZIndex = 1
			decal.EmissiveStrength = 1
			decal.EmissiveTint = PW.TINT
		end)
		decal.Parent = top
	end
end

function PW.restore(pallet)
	PW.removeCustom(pallet)
	local data = PW.saved[pallet]
	if not data then return end
	for part, info in pairs(data.parts) do
		if part and part.Parent then
			part.Color = info.Color
			part.Material = info.Material
		end
	end
	for obj, tr in pairs(data.textures) do
		if obj and obj.Parent then obj.Transparency = tr end
	end
end

function PW.setAll(state)
	if state then
		for _, d in ipairs(workspace:GetDescendants()) do
			if d.Name == PALLET_NAME then task.spawn(function() PW.customize(d) end) end
		end
	else
		for pallet in pairs(PW.saved) do
			if pallet and pallet.Parent then PW.restore(pallet) end
		end
	end
end

ApplyPallets = function(state)
	if state then
		if PK.on then ApplyPallets2(false) end
		if PW.on then ApplyPallets3(false) end
	end
	palletEnabled = state
	SetAllPallets(state)
	UpdateToggleVisual("Pallets", state)
end

function ApplyPallets2(state)
	if state then
		if palletEnabled then ApplyPallets(false) end
		if PW.on then ApplyPallets3(false) end
	end
	PK.on = state
	PK.setAll(state)
	UpdateToggleVisual("Pallets2", state)
end

function ApplyPallets3(state)
	if state then
		if palletEnabled then ApplyPallets(false) end
		if PK.on then ApplyPallets2(false) end
	end
	PW.on = state
	PW.setAll(state)
	UpdateToggleVisual("Pallets3", state)
end

local prevPos = Vector3.new()
local speedAccum = 0; local speedSamples = 0
RunService.Heartbeat:Connect(function(dt)
	if not UI.open or not UI.pages.Movement.Visible then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local spd = (root.Position - prevPos).Magnitude / dt
	prevPos = root.Position
	speedAccum = speedAccum + spd; speedSamples = speedSamples + 1
	if speedSamples >= 5 then
		UI.speedLabel.Text = "⚡  Speed: " .. string.format("%.1f", speedAccum / speedSamples) .. " stu/s"
		speedAccum = 0; speedSamples = 0
	end
end)

function RefreshToggles()
	local states = {
		FireTrail=fireTrailEnabled, Petals=petalEnabled, Headless=headlessEnabled,
		NightVision=nightVisionEnabled, AntiAfk=antiAfkEnabled, HighJump=highJumpEnabled,
		Nameplates=nameplatesEnabled, CameraSmooth=cameraSmoothEnabled, FPSBoost=fpsBoostEnabled,
		CameraZoom=cameraZoomEnabled, Pallets=palletEnabled, AutoJump=AJ.on,
		Pallets2=PK.on, Fog=FOG.on, JumpCircle=JC.on, Pallets3=PW.on, Snow=SN.on,
		UISounds = not UISnd.off, MenuAnim = not MISC.animOff, Speed = MV.speedOn, Fly = MV.fly, InfJump = MV.ij,
		SpawnDecal = MISC.spawn.on, Noclip = MV.noclip, ClickTP = MV.ctp, Fullbright = MISC.fb,
		Stretch = MISC.stretchOn, TabList = MISC.tabOn, FriendESP = MISC.fespOn, Freecam = MISC.fcOn, ESP = MISC.espOn, FpsHud = MISC.fpsOn, PingHud = MISC.pingOn,
		MotionBlur = MB.on, Ghost = GH.on, ZoomKey = ZM.latch,
	}
	if GetAccessoryStates then
		for id, st in pairs(GetAccessoryStates()) do states[id] = st end
	end
	for id, st in pairs(XS) do states[id] = st end
	for id, state in pairs(states) do UpdateToggleVisual(id, state) end
	for i = 1, #SkyPresets do
		UpdateToggleVisual("Sky" .. i, skyEnabledIndex == i)
	end
end

ApplyThemeToAll = function()
	local t = Themes[currentTheme]
	for _, fn in ipairs(UI.themed) do
		local ok, err = pcall(fn, t)
		if not ok then warn("[vizerUI] " .. tostring(err)) end
	end
	RefreshToggles()
end

UIS.InputBegan:Connect(function(input, gpe)
	if UI.rebinding then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				UI.cancelRebind()
			else
				local feat = UI.rebinding
				feat.Key = input.KeyCode
				UI.rebinding = nil
				local r = UI.rows[feat.Id]
				if r then r.updateSub() end
				MISC.dirty()
			end
		end
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		UI.toggle()
		return
	end
	if gpe then return end
	for _, feat in ipairs(UI.feats) do
		if feat.Key and input.KeyCode == feat.Key then
			if feat.Hold then
				if feat.Down then feat.Down() end
			else
				feat.Toggle()
			end
			return
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	for _, feat in ipairs(UI.feats) do
		if feat.Hold and feat.Key and input.KeyCode == feat.Key and feat.Up then
			feat.Up()
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if UI.open or UI.splash then
		if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
		if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
	end
end)

;(function()
	local InsertService   = game:GetService("InsertService")
	local ContentProvider = game:GetService("ContentProvider")

	local wingMeshEnabled     = false
	local wingParticleEnabled = false
	local haloEnabled         = false
	local wingRedEnabled      = false

	local floorEnabled        = false
	local cloudEnabled        = false
	local summerEnabled       = false
	local cloudCustom         = false

	local wingParticleLoopConn = nil
	local haloLoopConn         = nil

	local floorLoopConn        = nil

	local WM_MESH     = "rbxassetid://13655396450"
	local WM_TEX      = "rbxassetid://13655786322"
	local WM_SIZE     = Vector3.new(9, 5, 1)
	local WM_MESHSIZE = Vector3.new(2.53, 2.778, 1.082)
	local WM_COLOR    = Color3.fromRGB(0, 0, 0)
	local WM_MATERIAL = Enum.Material.Asphalt
	local WM_C0 = CFrame.new(
		4.55072021, 0.903738499, 0.949493408,
		-0.965925932, -0.258819014, 0,
		-0.258819014, 0.965925932, 0,
		0, 0, -1
	)

	local function WM_MakeBlackMist(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name = "Black Mist"; e.Texture = "rbxassetid://11381558781"
		e.Brightness = 1
		e.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		})
		e.LightEmission=0; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.FacingCamera
		e.Squash=NumberSequence.new(0)
		e.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0.9), NumberSequenceKeypoint.new(0.201,0.881), NumberSequenceKeypoint.new(1,1),
		})
		e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,3.31), NumberSequenceKeypoint.new(1,1.69)})
		e.ZOffset=-1; e.EmissionDirection=Enum.NormalId.Top; e.Enabled=true
		e.Lifetime=NumberRange.new(1,1); e.Rate=50
		e.Rotation=NumberRange.new(-360,360); e.RotSpeed=NumberRange.new(-45,45)
		e.Speed=NumberRange.new(2,3); e.SpreadAngle=Vector2.new(360,360)
		pcall(function()
			e.Shape=Enum.ParticleEmitterShape.Sphere; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
			e.ShapePartial=1; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
		end)
		pcall(function()
			e.FlipbookLayout=Enum.ParticleFlipbookLayout.Grid8x8; e.FlipbookFramerate=NumberRange.new(25,25)
			e.FlipbookMode=Enum.ParticleFlipbookMode.Loop; e.FlipbookStartRandom=false
		end)
		e.Acceleration=Vector3.new(6,2,4); e.Drag=1.25; e.LockedToPart=true; e.TimeScale=1
		e.Parent=parent
		return e
	end

	local function WM_MakeFeather(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="feather"; e.Texture="rbxassetid://13655187230"
		e.Brightness=1; e.Color=ColorSequence.new(Color3.fromRGB(29,29,29))
		e.LightEmission=0; e.LightInfluence=1; e.Orientation=Enum.ParticleOrientation.FacingCamera
		e.Squash=NumberSequence.new(0); e.Transparency=NumberSequence.new(0)
		e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.6), NumberSequenceKeypoint.new(1,0.25)})
		e.ZOffset=-1; e.EmissionDirection=Enum.NormalId.Top; e.Enabled=true
		e.Lifetime=NumberRange.new(0.85,1); e.Rate=35
		e.Rotation=NumberRange.new(-360,360); e.RotSpeed=NumberRange.new(-100,100)
		e.Speed=NumberRange.new(5,5); e.SpreadAngle=Vector2.new(360,360)
		pcall(function()
			e.Shape=Enum.ParticleEmitterShape.Sphere; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
			e.ShapePartial=1; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
		end)
		pcall(function()
			e.FlipbookLayout=Enum.ParticleFlipbookLayout.Grid2x2; e.FlipbookFramerate=NumberRange.new(5,5)
			e.FlipbookMode=Enum.ParticleFlipbookMode.Loop; e.FlipbookStartRandom=true
		end)
		e.Acceleration=Vector3.new(10,5,5); e.Drag=0; e.LockedToPart=false; e.TimeScale=1
		e.Parent=parent
		return e
	end

	local function WM_CreateWing(char)
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
		if not torso then return end
		local old = char:FindFirstChild("vizerWingsMesh")
		if old then old:Destroy() end

		local wing
		local ok, res = pcall(function()
			return InsertService:CreateMeshPartAsync(WM_MESH, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Automatic)
		end)
		if ok and res then
			wing = res; wing.Size = WM_SIZE
			pcall(function() wing.TextureID = WM_TEX end)
		else
			wing = Instance.new("Part"); wing.Size = Vector3.new(1,1,1)
			local sm = Instance.new("SpecialMesh", wing)
			sm.MeshType=Enum.MeshType.FileMesh; sm.MeshId=WM_MESH; sm.TextureId=WM_TEX
			sm.Scale = Vector3.new(WM_SIZE.X/WM_MESHSIZE.X, WM_SIZE.Y/WM_MESHSIZE.Y, WM_SIZE.Z/WM_MESHSIZE.Z)
		end

		wing.Name="vizerWingsMesh"; wing.Color=WM_COLOR; wing.Material=WM_MATERIAL
		wing.Reflectance=0; wing.Transparency=0
		wing.Anchored=false; wing.CanCollide=false; wing.CanTouch=false; wing.CanQuery=false
		wing.Massless=true; wing.CastShadow=false
		wing.CFrame = torso.CFrame * WM_C0
		wing.Parent = char

		local weld = Instance.new("Weld")
		weld.Part0=torso; weld.Part1=wing; weld.C0=WM_C0; weld.Parent=wing

		WM_MakeBlackMist(wing)
		WM_MakeFeather(wing)
		pcall(function() ContentProvider:PreloadAsync({wing}) end)
		return wing
	end

	local function WM_DestroyWing(char)
		local w = char and char:FindFirstChild("vizerWingsMesh")
		if w then w:Destroy() end
	end

	local WP_LEFT_POS  = Vector3.new(-1.617, -0.157, 1.203)
	local WP_RIGHT_POS = Vector3.new(1.604, -0.157, 1.04)
	local WP_LEFT_ORIENT  = Vector3.new(-0.001, 124.999, 89.999)
	local WP_RIGHT_ORIENT = Vector3.new(0.001, -119.996, 89.999)
	local WP_WING_TEXTURE = "rbxassetid://82114954422305"
	local WP_FEATHER_LEFT_POS  = Vector3.new(-1.104, 0.399, 1.023)
	local WP_FEATHER_RIGHT_POS = Vector3.new(0.909, 0.399, 1.023)
	local WP_FEATHER_ORIENT    = Vector3.new(0, 0, 0)
	local WP_FEATHER_TEXTURE   = "rbxassetid://115361100558524"

	local function WP_MakeWingParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="ParticleEmitter"; e.Texture=WP_WING_TEXTURE
		e.Brightness=10; e.Color=ColorSequence.new(Color3.fromRGB(255,39,233))
		e.LightEmission=1; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.VelocityPerpendicular
		e.Size=NumberSequence.new(2)
		e.Squash=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.501,0,0.0375),NumberSequenceKeypoint.new(1,0)})
		e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.502,0),NumberSequenceKeypoint.new(1,1)})
		e.ZOffset=0; e.EmissionDirection=Enum.NormalId.Top; e.Enabled=true
		e.Lifetime=NumberRange.new(2,2); e.Rate=3
		e.Rotation=NumberRange.new(0,0); e.RotSpeed=NumberRange.new(0,0)
		e.Speed=NumberRange.new(0.01,0.01); e.SpreadAngle=Vector2.new(0,0)
		pcall(function() e.Shape=Enum.ParticleEmitterShape.Box; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume end)
		pcall(function() e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end)
		e.Acceleration=Vector3.new(0,0,0); e.LockedToPart=true; e.TimeScale=1
		pcall(function() e.VelocityInheritance=0 end)
		pcall(function() e.WindAffectsDrag=false end)
		e.Parent=parent
		return e
	end

	local function WP_MakeFeatherParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="ParticleEmitter"; e.Texture=WP_FEATHER_TEXTURE
		e.Brightness=10; e.Color=ColorSequence.new(Color3.fromRGB(198,12,173))
		e.LightEmission=1; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.FacingCamera
		e.Size=NumberSequence.new(0.3); e.Squash=NumberSequence.new(0)
		e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.698,0,0),NumberSequenceKeypoint.new(1,0.725,0.275)})
		e.ZOffset=1; e.EmissionDirection=Enum.NormalId.Bottom; e.Enabled=true
		e.Lifetime=NumberRange.new(2,2); e.Rate=3
		e.Rotation=NumberRange.new(-50,-50); e.RotSpeed=NumberRange.new(100,100)
		e.Speed=NumberRange.new(2,2); e.SpreadAngle=Vector2.new(50,50)
		pcall(function() e.Shape=Enum.ParticleEmitterShape.Box; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume end)
		pcall(function() e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end)
		e.Acceleration=Vector3.new(0,0,0); e.LockedToPart=true; e.TimeScale=1
		e.Parent=parent
		return e
	end

	local function WP_BuildWingObjects(torso)
		local left = Instance.new("Attachment"); left.Name="WP Wing Left"; left.Parent=torso
		WP_MakeWingParticle(left)
		local right = Instance.new("Attachment"); right.Name="WP Wing right"; right.Parent=torso
		WP_MakeWingParticle(right)
		local featherL = Instance.new("Attachment"); featherL.Name="WP Feather Left"; featherL.Parent=torso
		WP_MakeFeatherParticle(featherL)
		local featherR = Instance.new("Attachment"); featherR.Name="WP Feather Right"; featherR.Parent=torso
		WP_MakeFeatherParticle(featherR)
		return left, right, featherL, featherR
	end

	local function WP_StartLoop(char)
		if wingParticleLoopConn then wingParticleLoopConn:Disconnect(); wingParticleLoopConn=nil end
		local leftOffset  = CFrame.new(WP_LEFT_POS)  * CFrame.fromOrientation(math.rad(WP_LEFT_ORIENT.X),  math.rad(WP_LEFT_ORIENT.Y),  math.rad(WP_LEFT_ORIENT.Z))
		local rightOffset = CFrame.new(WP_RIGHT_POS) * CFrame.fromOrientation(math.rad(WP_RIGHT_ORIENT.X), math.rad(WP_RIGHT_ORIENT.Y), math.rad(WP_RIGHT_ORIENT.Z))
		local featherLOffset = CFrame.new(WP_FEATHER_LEFT_POS)  * CFrame.fromOrientation(math.rad(WP_FEATHER_ORIENT.X), math.rad(WP_FEATHER_ORIENT.Y), math.rad(WP_FEATHER_ORIENT.Z))
		local featherROffset = CFrame.new(WP_FEATHER_RIGHT_POS) * CFrame.fromOrientation(math.rad(WP_FEATHER_ORIENT.X), math.rad(WP_FEATHER_ORIENT.Y), math.rad(WP_FEATHER_ORIENT.Z))

		wingParticleLoopConn = RunService.Heartbeat:Connect(function()
			if not wingParticleEnabled then return end
			local ch = player.Character
			if not ch or not ch:IsDescendantOf(workspace) then return end
			local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
			if not torso then return end
			local left     = torso:FindFirstChild("WP Wing Left")
			local right    = torso:FindFirstChild("WP Wing right")
			local featherL = torso:FindFirstChild("WP Feather Left")
			local featherR = torso:FindFirstChild("WP Feather Right")
			if not left or not right or not featherL or not featherR then
				left, right, featherL, featherR = WP_BuildWingObjects(torso)
			end
			left.CFrame=leftOffset; right.CFrame=rightOffset
			featherL.CFrame=featherLOffset; featherR.CFrame=featherROffset
		end)
	end

	local function WP_Create(char)
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if not torso then return end
		for _, name in ipairs({"WP Wing Left","WP Wing right","WP Feather Left","WP Feather Right"}) do
			local old = torso:FindFirstChild(name); if old then old:Destroy() end
		end
		WP_BuildWingObjects(torso)
		WP_StartLoop(char)
	end

	local function WP_Destroy(char)
		if wingParticleLoopConn then wingParticleLoopConn:Disconnect(); wingParticleLoopConn=nil end
		local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
		if torso then
			for _, name in ipairs({"WP Wing Left","WP Wing right","WP Feather Left","WP Feather Right"}) do
				local a = torso:FindFirstChild(name); if a then a:Destroy() end
			end
		end
	end

	local HL_HALO_POS    = Vector3.new(0, 1.946, 0.128)
	local HL_HALO_ORIENT = Vector3.new(25.002, 0, 0)
	local HL_RAIN_POS    = Vector3.new(-0.026, -0.025, 0.033)
	local HL_RAIN_ORIENT = Vector3.new(0, 0, 0)
	local HL_HALO_TEXTURE = "rbxassetid://10365549270"
	local HL_RAIN_TEXTURE = "rbxassetid://7216979420"

	local function HL_MakeHaloParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="ParticleEmitter"; e.Texture=HL_HALO_TEXTURE
		e.Brightness=10; e.Color=ColorSequence.new(Color3.fromRGB(248,107,253))
		e.LightEmission=1; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.VelocityPerpendicular
		e.Size=NumberSequence.new(1); e.Squash=NumberSequence.new(0); e.Transparency=NumberSequence.new(0); e.ZOffset=0
		e.EmissionDirection=Enum.NormalId.Top; e.Enabled=true
		e.Lifetime=NumberRange.new(1.5,1.5); e.Rate=2
		e.Rotation=NumberRange.new(10,10); e.RotSpeed=NumberRange.new(360,360)
		e.Speed=NumberRange.new(0.01,0.01); e.SpreadAngle=Vector2.new(0,0)
		pcall(function() e.Shape=Enum.ParticleEmitterShape.Box; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume end)
		pcall(function() e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end)
		e.Acceleration=Vector3.new(0,0,0); e.LockedToPart=true
		e.Parent=parent
		return e
	end

	local function HL_MakeRainParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="ParticleEmitter"; e.Texture=HL_RAIN_TEXTURE
		e.Brightness=10; e.Color=ColorSequence.new(Color3.fromRGB(198,12,173))
		e.LightEmission=1; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.FacingCamera
		e.Size=NumberSequence.new(0.2); e.Squash=NumberSequence.new(0)
		e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.496,0.5,0.156),NumberSequenceKeypoint.new(0.698,0,0),NumberSequenceKeypoint.new(1,0.725,0.275)})
		e.ZOffset=1; e.EmissionDirection=Enum.NormalId.Bottom; e.Enabled=true
		e.Lifetime=NumberRange.new(5,5); e.Rate=2
		e.Rotation=NumberRange.new(-90,-90); e.RotSpeed=NumberRange.new(0,0)
		e.Speed=NumberRange.new(5,5); e.SpreadAngle=Vector2.new(360,360)
		pcall(function() e.Shape=Enum.ParticleEmitterShape.Box; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Surface end)
		pcall(function() e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end)
		e.Acceleration=Vector3.new(0,-10,0); e.Drag=10; e.LockedToPart=true; e.TimeScale=1
		pcall(function() e.VelocityInheritance=0 end)
		pcall(function() e.WindAffectsDrag=false end)
		e.Parent=parent
		return e
	end

	local function HL_BuildObjects(head)
		local halo = Instance.new("Attachment"); halo.Name="vizerHalo"; halo.Parent=head
		HL_MakeHaloParticle(halo)
		local rain = Instance.new("Attachment"); rain.Name="Rain"
		rain.CFrame = CFrame.new(HL_RAIN_POS) * CFrame.fromOrientation(math.rad(HL_RAIN_ORIENT.X), math.rad(HL_RAIN_ORIENT.Y), math.rad(HL_RAIN_ORIENT.Z))
		rain.Parent = halo
		HL_MakeRainParticle(rain)
		return halo
	end

	local function HL_StartLoop(char)
		if haloLoopConn then haloLoopConn:Disconnect(); haloLoopConn=nil end
		local haloOffset = CFrame.new(HL_HALO_POS) * CFrame.fromOrientation(math.rad(HL_HALO_ORIENT.X), math.rad(HL_HALO_ORIENT.Y), math.rad(HL_HALO_ORIENT.Z))
		haloLoopConn = RunService.Heartbeat:Connect(function()
			if not haloEnabled then return end
			local ch = player.Character
			if not ch or not ch:IsDescendantOf(workspace) then return end
			local head = ch:FindFirstChild("Head")
			if not head then return end
			local halo = head:FindFirstChild("vizerHalo")
			if not halo then halo = HL_BuildObjects(head) end
			halo.CFrame = haloOffset
		end)
	end

	local function HL_Create(char)
		local head = char:WaitForChild("Head", 5)
		if not head then return end
		local old = head:FindFirstChild("vizerHalo")
		if old then old:Destroy() end
		HL_BuildObjects(head)
		HL_StartLoop(char)
	end

	local function HL_Destroy(char)
		if haloLoopConn then haloLoopConn:Disconnect(); haloLoopConn=nil end
		local head = char and char:FindFirstChild("Head")
		local halo = head and head:FindFirstChild("vizerHalo")
		if halo then halo:Destroy() end
	end

	local WR_LEFT_POS  = Vector3.new(-2.674835205078125, -0.07152819633483887, 1.7093048095703125)
	local WR_RIGHT_POS = Vector3.new(2.639812469482422, -0.05870652198791504, 1.8028453379638672)
	local WR_LEFT_ORIENT  = Vector3.new(-0.003, 118.569, 89.996)
	local WR_RIGHT_ORIENT = Vector3.new(0.002, -120.077, 89.997)
	local WR_PARTICLE_TEXTURE = "rbxassetid://140086278326241"

	local function WR_MakeWingParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name="ParticleEmitter"; e.Texture=WR_PARTICLE_TEXTURE
		e.Brightness=10
		e.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,     Color3.fromRGB(170,0,0)),
			ColorSequenceKeypoint.new(0.493, Color3.fromRGB(0,0,0)),
			ColorSequenceKeypoint.new(1,     Color3.fromRGB(170,0,0)),
		})
		e.LightEmission=0; e.LightInfluence=0; e.Orientation=Enum.ParticleOrientation.VelocityPerpendicular
		e.Size=NumberSequence.new(3)
		e.Squash=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.501,0,0.0375),NumberSequenceKeypoint.new(1,0)})
		e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.502,0),NumberSequenceKeypoint.new(1,1)})
		e.ZOffset=0; e.EmissionDirection=Enum.NormalId.Top; e.Enabled=true
		e.Lifetime=NumberRange.new(2,2); e.Rate=3
		e.Rotation=NumberRange.new(0,0); e.RotSpeed=NumberRange.new(0,0)
		e.Speed=NumberRange.new(0.01,0.01); e.SpreadAngle=Vector2.new(0,0)
		pcall(function() e.Shape=Enum.ParticleEmitterShape.Box; e.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward; e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume end)
		pcall(function() e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end)
		e.Acceleration=Vector3.new(0,0,0); e.Drag=0; e.LockedToPart=true; e.TimeScale=1
		pcall(function() e.VelocityInheritance=0 end)
		pcall(function() e.WindAffectsDrag=false end)
		e.Parent=parent
		return e
	end

	local function WR_MakeWingLight(parent, color)
		local l = Instance.new("PointLight")
		l.Name="PointLight"; l.Color=color; l.Brightness=1; l.Range=3; l.Enabled=true; l.Shadows=true
		l.Parent=parent
		return l
	end

	local function WR_MakeAttachment(torso, name, pos, orientDeg, lightColor)
		local att = Instance.new("Attachment")
		att.Name = name
		att.CFrame = CFrame.new(pos) * CFrame.fromOrientation(math.rad(orientDeg.X), math.rad(orientDeg.Y), math.rad(orientDeg.Z))
		att.Parent = torso
		WR_MakeWingParticle(att)
		WR_MakeWingLight(att, lightColor)
		return att
	end

	local function WR_Create(char)
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if not torso then return end
		for _, name in ipairs({"WR Wing Left","WR Wing right"}) do
			local old = torso:FindFirstChild(name); if old then old:Destroy() end
		end
		local oldMarker = char:FindFirstChild("vizerWingRedAttachments")
		if oldMarker then oldMarker:Destroy() end
		local marker = Instance.new("Folder"); marker.Name="vizerWingRedAttachments"; marker.Parent=char
		WR_MakeAttachment(torso, "WR Wing Left",  WR_LEFT_POS,  WR_LEFT_ORIENT,  Color3.fromRGB(255,0,0))
		WR_MakeAttachment(torso, "WR Wing right", WR_RIGHT_POS, WR_RIGHT_ORIENT, Color3.fromRGB(255,255,255))
		return marker
	end

	local function WR_Destroy(char)
		local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
		if torso then
			for _, name in ipairs({"WR Wing Left","WR Wing right"}) do
				local att = torso:FindFirstChild(name); if att then att:Destroy() end
			end
		end
		local marker = char and char:FindFirstChild("vizerWingRedAttachments")
		if marker then marker:Destroy() end
	end

	local FL_POS    = Vector3.new(0, -2.95, 0)
	local FL_ORIENT = Vector3.new(0, 0, 0)
	local FL_TEXTURE = "rbxassetid://86448734575922"

	local function FL_MakeParticle(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name    = "Circle29"
		e.Texture = FL_TEXTURE
		e.Brightness = 5
		e.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 85, 127)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 127)),
		})
		e.LightEmission  = 0
		e.LightInfluence = 0
		e.Orientation    = Enum.ParticleOrientation.VelocityPerpendicular
		e.Size           = NumberSequence.new(5)
		e.Squash         = NumberSequence.new(0)
		e.Transparency   = NumberSequence.new(0)
		e.ZOffset        = 0
		e.EmissionDirection = Enum.NormalId.Top
		e.Enabled     = true
		e.Lifetime    = NumberRange.new(1.01, 1.01)
		e.Rate        = 2
		e.Rotation    = NumberRange.new(180, 180)
		e.RotSpeed    = NumberRange.new(0, 0)
		e.Speed       = NumberRange.new(0.001, 0.001)
		e.SpreadAngle = Vector2.new(0, 0)
		pcall(function()
			e.Shape      = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		end)
		pcall(function()
			e.FlipbookLayout      = Enum.ParticleFlipbookLayout.Grid4x4
			e.FlipbookBlendFrames = true
			e.FlipbookMode        = Enum.ParticleFlipbookMode.OneShot
			e.FlipbookStartRandom = false
		end)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag         = 0
		e.LockedToPart = false
		e.TimeScale    = 1
		pcall(function() e.VelocityInheritance = 0 end)
		e.Parent = parent
		return e
	end

	local function FL_BuildObjects(torso)
		local floor = Instance.new("Attachment")
		floor.Name = "Floor"
		floor.Parent = torso
		FL_MakeParticle(floor)
		return floor
	end

	local function FL_StartLoop(char)
		if floorLoopConn then floorLoopConn:Disconnect(); floorLoopConn=nil end
		local floorOffset = CFrame.new(FL_POS) * CFrame.fromOrientation(
			math.rad(FL_ORIENT.X), math.rad(FL_ORIENT.Y), math.rad(FL_ORIENT.Z)
		)
		floorLoopConn = RunService.Heartbeat:Connect(function()
			if not floorEnabled then return end
			local ch = player.Character
			if not ch or not ch:IsDescendantOf(workspace) then return end
			local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
			if not torso then return end
			local floor = torso:FindFirstChild("Floor")
			if not floor then floor = FL_BuildObjects(torso) end
			floor.CFrame = floorOffset
		end)
	end

	local function FL_Create(char)
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if not torso then return end
		local old = torso:FindFirstChild("Floor")
		if old then old:Destroy() end
		FL_BuildObjects(torso)
		FL_StartLoop(char)
	end

	local function FL_Destroy(char)
		if floorLoopConn then floorLoopConn:Disconnect(); floorLoopConn=nil end
		local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
		local floor = torso and torso:FindFirstChild("Floor")
		if floor then floor:Destroy() end
	end

	local function CL_Paint(e)
		local col = EffectColors.Cloud
		e.Color = ColorSequence.new(col)
		local base = e:GetAttribute("BaseLE")
		if base then
			e.LightEmission = ((col.R + col.G + col.B) < 0.05) and 0 or base
		end
	end

	local function CL_Seq(points)
		local keys = {}
		for _, pt in ipairs(points) do
			table.insert(keys, NumberSequenceKeypoint.new(pt[1], pt[2]))
		end
		return NumberSequence.new(keys)
	end

	local function CL_MakeCloud(parent, name, texture, lightEmission, zOffset, speedMin, speedMax)
		local e = Instance.new("ParticleEmitter")
		e.Name = name
		e.Texture = texture
		e.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
		e.LightEmission = lightEmission
		e.LightInfluence = 1
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Size = CL_Seq({
			{0, 1}, {0.1, 1.5}, {0.134, 1.21}, {0.2, 1}, {0.3, 1.5}, {0.4, 1},
			{0.5, 1.5}, {0.6, 1}, {0.7, 1.5}, {0.8, 1}, {0.9, 1.5}, {1, 1},
		})
		e.Squash = NumberSequence.new(0.0267)
		e.Transparency = CL_Seq({
			{0, 1}, {0.0602, 0.843}, {0.166, 0.757}, {0.258, 0.68}, {0.384, 0.57},
			{0.498, 0.503}, {0.85, 0.72}, {0.93, 0.82}, {1, 1},
		})
		e.ZOffset = zOffset
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(2.5, 5)
		e.Rate = 10
		e.Rotation = NumberRange.new(-360, 360)
		e.RotSpeed = NumberRange.new(-100, 100)
		e.Speed = NumberRange.new(speedMin, speedMax)
		e.SpreadAngle = Vector2.new(120, 120)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 5
		e.LockedToPart = true
		e.TimeScale = 1
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
			e.FlipbookBlendFrames = true
			e.FlipbookFramerate = NumberRange.new(25, 25)
			e.FlipbookMode = Enum.ParticleFlipbookMode.Loop
			e.FlipbookStartRandom = false
			e.VelocityInheritance = 0
		end)
		e:SetAttribute("BaseLE", lightEmission)
		if cloudCustom then CL_Paint(e) end
		e.Enabled = true
		e.Parent = parent
		return e
	end

	local function CL_MakeCoins(parent)
		local e = Instance.new("ParticleEmitter")
		e.Name = "3"
		e.Texture = "rbxassetid://12010904379"
		e.Color = ColorSequence.new(Color3.fromRGB(173, 173, 173))
		e.LightEmission = 0
		e.LightInfluence = 1
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Size = NumberSequence.new(0.25)
		e.Squash = NumberSequence.new(0)
		e.Transparency = CL_Seq({{0, 0}, {0.75, 0}, {1, 1}})
		e.ZOffset = 0
		e.EmissionDirection = Enum.NormalId.Bottom
		e.Lifetime = NumberRange.new(1.8, 1.8)
		e.Rate = 2.5
		e.Rotation = NumberRange.new(-360, 360)
		e.RotSpeed = NumberRange.new(-100, 100)
		e.Speed = NumberRange.new(6, 6)
		e.SpreadAngle = Vector2.new(5, 5)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 0
		e.LockedToPart = false
		e.TimeScale = 1
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Disc
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapePartial = 1
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
			e.FlipbookBlendFrames = true
			e.FlipbookFramerate = NumberRange.new(20, 20)
			e.FlipbookMode = Enum.ParticleFlipbookMode.Loop
			e.FlipbookStartRandom = false
		end)
		if cloudCustom then CL_Paint(e) end
		e.Enabled = true
		e.Parent = parent
		return e
	end

	local function CL_Destroy(char)
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local att = root and root:FindFirstChild("vizerCloudAttachment")
		if att then att:Destroy() end
		local plate = char:FindFirstChild("vizerCloudPlate")
		if plate then plate:Destroy() end
	end

	local function CL_Create(char)
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		CL_Destroy(char)

		local att = Instance.new("Attachment")
		att.Name = "vizerCloudAttachment"
		att.CFrame = CFrame.new(0, 7.125, 0)
		att.Parent = root
		CL_MakeCloud(att, "1", "rbxassetid://11381556016", 0.65, 0.15, 4, 8)
		CL_MakeCloud(att, "2", "rbxassetid://11381557354", 1, 0.1, 4, 8)
		CL_MakeCloud(att, "3", "rbxassetid://11381560992", 1, 0.1, 2, 4)

		local plate = Instance.new("Part")
		plate.Name = "vizerCloudPlate"
		plate.Size = Vector3.new(5.5, 0.001, 5.75)
		plate.Color = Color3.fromRGB(17, 17, 17)
		plate.Material = Enum.Material.Neon
		plate.Transparency = 1
		plate.Anchored = false; plate.CanCollide = false; plate.CanTouch = false; plate.CanQuery = false
		plate.Massless = true; plate.CastShadow = false
		plate.CFrame = root.CFrame * CFrame.new(0, 7.188, 0)
		plate.Parent = char

		local weld = Instance.new("Weld")
		weld.Part0 = root; weld.Part1 = plate; weld.C0 = CFrame.new(0, 7.188, 0); weld.Parent = plate

		CL_MakeCoins(plate)
	end

	function CloudApplyColor(col)
		cloudCustom = true
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local att = root and root:FindFirstChild("vizerCloudAttachment")
		if att then
			for _, e in ipairs(att:GetChildren()) do
				if e:IsA("ParticleEmitter") then CL_Paint(e) end
			end
		end
		local plate = char:FindFirstChild("vizerCloudPlate")
		if plate then
			for _, e in ipairs(plate:GetChildren()) do
				if e:IsA("ParticleEmitter") then CL_Paint(e) end
			end
		end
	end

	local function SM_Destroy(char)
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			for _, n in ipairs({"vizerSummerTop", "vizerSummerBottom"}) do
				local a = root:FindFirstChild(n)
				if a then a:Destroy() end
			end
		end
		local head = char:FindFirstChild("Head")
		local face = head and head:FindFirstChild("vizerSummerFace")
		if face then face:Destroy() end
	end

	local function SM_Create(char)
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		SM_Destroy(char)

		local top = Instance.new("Attachment")
		top.Name = "vizerSummerTop"
		top.CFrame = CFrame.new(0, 5, 0)
		top.Parent = root

		local bottom = Instance.new("Attachment")
		bottom.Name = "vizerSummerBottom"
		bottom.CFrame = CFrame.new(0, -3.25, 0)
		bottom.Parent = root

		local beam = Instance.new("Beam")
		beam.Name = "Beam"
		beam.Attachment0 = top
		beam.Attachment1 = bottom
		beam.Color = ColorSequence.new(EffectColors.Summer)
		beam.LightEmission = 1
		beam.LightInfluence = 1
		beam.Texture = "rbxassetid://6091329339"
		beam.TextureLength = 0.1
		beam.TextureMode = Enum.TextureMode.Stretch
		beam.TextureSpeed = 1
		beam.Transparency = CL_Seq({{0, 1}, {0.2, 0}, {0.9, 1}, {1, 1}})
		beam.ZOffset = 1
		beam.FaceCamera = true
		beam.Segments = 10
		beam.Width0 = 1.25
		beam.Width1 = 9
		beam.CurveSize0 = 0
		beam.CurveSize1 = 0
		beam.Enabled = true
		beam.Parent = top

		local sun = Instance.new("ParticleEmitter")
		sun.Name = "ParticleEmitter"
		sun.Texture = "rbxassetid://9307120868"
		sun.Color = ColorSequence.new(EffectColors.Summer)
		sun.LightEmission = 1
		sun.LightInfluence = 1
		sun.Orientation = Enum.ParticleOrientation.FacingCamera
		sun.Size = NumberSequence.new(1.5)
		sun.Squash = NumberSequence.new(0)
		sun.Transparency = CL_Seq({{0, 1}, {0.2, 0}, {0.8, 0}, {1, 1}})
		sun.ZOffset = 1
		sun.EmissionDirection = Enum.NormalId.Top
		sun.Lifetime = NumberRange.new(1.2, 1.2)
		sun.Rate = 1.2
		sun.Rotation = NumberRange.new(0, 0)
		sun.RotSpeed = NumberRange.new(0, 0)
		sun.Speed = NumberRange.new(0, 0)
		sun.SpreadAngle = Vector2.new(0, 0)
		sun.Acceleration = Vector3.new(0, 0, 0)
		sun.Drag = 0
		sun.LockedToPart = true
		sun.TimeScale = 1
		pcall(function()
			sun.Shape = Enum.ParticleEmitterShape.Box
			sun.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			sun.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			sun.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		end)
		sun.Enabled = true
		sun.Parent = top

		local head = char:FindFirstChild("Head")
		if head then
			local att = Instance.new("Attachment")
			att.Name = "vizerSummerFace"
			att.CFrame = CFrame.new(0, 0.238, -0.665)
			att.Parent = head

			local e = Instance.new("ParticleEmitter")
			e.Name = "ParticleEmitter"
			e.Texture = "rbxassetid://9306956615"
			e.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
			e.LightEmission = 0
			e.LightInfluence = 1
			e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
			e.Size = NumberSequence.new(0.3)
			e.Squash = NumberSequence.new(-0.5)
			e.Transparency = CL_Seq({{0, 1}, {0.2, 0}, {0.8, 0}, {1, 1}})
			e.ZOffset = 0
			e.EmissionDirection = Enum.NormalId.Front
			e.Lifetime = NumberRange.new(3.5, 3.5)
			e.Rate = 3.5
			e.Rotation = NumberRange.new(0, 0)
			e.RotSpeed = NumberRange.new(0, 0)
			e.Speed = NumberRange.new(0.001, 0.001)
			e.SpreadAngle = Vector2.new(0, 0)
			e.Acceleration = Vector3.new(0, 0, 0)
			e.Drag = 0
			e.LockedToPart = true
			e.TimeScale = 1
			pcall(function()
				e.Shape = Enum.ParticleEmitterShape.Box
				e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
				e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
				e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
			end)
			e.Enabled = true
			e.Parent = att
		end
	end

	function SummerApplyColor(col)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local top = root and root:FindFirstChild("vizerSummerTop")
		if not top then return end
		for _, obj in ipairs(top:GetChildren()) do
			if obj:IsA("Beam") or obj:IsA("ParticleEmitter") then
				obj.Color = ColorSequence.new(col)
			end
		end
	end

	function ApplyWingMesh(state)
		wingMeshEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("WingMesh", state); return end
		if state then WM_CreateWing(char) else WM_DestroyWing(char) end
		UpdateToggleVisual("WingMesh", state)
	end

	function ApplyWingParticle(state)
		wingParticleEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("WingParticle", state); return end
		if state then WP_Create(char) else WP_Destroy(char) end
		UpdateToggleVisual("WingParticle", state)
	end

	function ApplyHalo(state)
		haloEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("Halo", state); return end
		if state then HL_Create(char) else HL_Destroy(char) end
		UpdateToggleVisual("Halo", state)
	end

	function ApplyWingRed(state)
		wingRedEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("WingRed", state); return end
		if state then WR_Create(char) else WR_Destroy(char) end
		UpdateToggleVisual("WingRed", state)
	end

	function ApplyFloor(state)
		floorEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("Floor", state); return end
		if state then FL_Create(char) else FL_Destroy(char) end
		UpdateToggleVisual("Floor", state)
	end

	function ApplyCloud(state)
		cloudEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("Cloud", state); return end
		if state then CL_Create(char) else CL_Destroy(char) end
		UpdateToggleVisual("Cloud", state)
	end

	function ApplySummer(state)
		summerEnabled = state
		local char = player.Character; if not char then UpdateToggleVisual("Summer", state); return end
		if state then SM_Create(char) else SM_Destroy(char) end
		UpdateToggleVisual("Summer", state)
	end

	local function OnAccessoryCharacter(char)
		char:WaitForChild("Humanoid", 10)
		char:WaitForChild("HumanoidRootPart", 10)
		task.wait(0.3)
		if wingMeshEnabled then WM_CreateWing(char) end
		if wingParticleEnabled then WP_Create(char) end
		if haloEnabled then HL_Create(char) end
		if wingRedEnabled then WR_Create(char) end

		if floorEnabled then FL_Create(char) end
		if cloudEnabled then CL_Create(char) end
		if summerEnabled then SM_Create(char) end
	end
	if player.Character then task.spawn(OnAccessoryCharacter, player.Character) end
	player.CharacterAdded:Connect(OnAccessoryCharacter)

	function GetAccessoryStates()
		return {
			WingMesh = wingMeshEnabled, WingParticle = wingParticleEnabled, Halo = haloEnabled,
			WingRed = wingRedEnabled, Floor = floorEnabled,
			Cloud = cloudEnabled, Summer = summerEnabled,
		}
	end

	local K = Enum.KeyCode
	UI.section("Player", "🦋  Accessories")
	UI.section("Visuals", "☁  Auras")
	local AccessoryFeatures = {
		{Tab="Player",  Id="WingMesh",     Name="Dark wing",   Sub="Black wings",    Icon="🦇", Key=K.Z,
			Toggle=function() ApplyWingMesh(not wingMeshEnabled) end},
		{Tab="Player",  Id="WingParticle", Name="Pink Wings",  Sub="Glowing wings",  Icon="🦋", Key=K.X,
			Toggle=function() ApplyWingParticle(not wingParticleEnabled) end},
		{Tab="Player",  Id="Halo",         Name="Nimbus",      Sub="Halo + sparkles", Icon="😇", Key=K.Comma,
			Toggle=function() ApplyHalo(not haloEnabled) end},
		{Tab="Player",  Id="WingRed",      Name="Red wing",    Sub="Crimson wings",  Icon="🔴", Key=K.Period,
			Toggle=function() ApplyWingRed(not wingRedEnabled) end},

		{Tab="Visuals", Id="Floor",        Name="Love floor",  Sub="Ring under feet", Icon="💗", Key=K.Slash,
			Toggle=function() ApplyFloor(not floorEnabled) end},
		{Tab="Visuals", Id="Cloud",        Name="Cloud",       Sub="Cloud + coins",  Icon="☁", Key=K.Semicolon,
			Toggle=function() ApplyCloud(not cloudEnabled) end},
		{Tab="Visuals", Id="Summer",       Name="Summer Lovin", Sub="Sun beam",      Icon="☀", Key=K.LeftBracket,
			Toggle=function() ApplySummer(not summerEnabled) end},
	}
	for _, feat in ipairs(AccessoryFeatures) do UI.add(feat) end
end)()

ApplyFireTrail = function(state)
	fireTrailEnabled = state
	if currentFireTrail then currentFireTrail.Enabled = state end
	UpdateToggleVisual("FireTrail", state)
end

ApplyPetals = function(state)
	petalEnabled = state
	if petalLoopConn then petalLoopConn:Disconnect(); petalLoopConn=nil end

	if state then
		petalLoopConn = RunService.Heartbeat:Connect(function()
			if math.random() > 0.35 then return end
			local ch = player.Character
			if not ch then return end
			local root = ch:FindFirstChild("HumanoidRootPart"); if not root then return end

			local p = Instance.new("Part", workspace)
			p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false
			p.Size=Vector3.new(0.45,0.12,0.32); p.Material=Enum.Material.Neon
			p.Color = EffectColors.Petals
			p.Transparency=0.1

			local spawnHeight = 28 + math.random() * 12
			local spawnRadius = 10 + math.random() * 8
			local spawnAngle  = math.random() * math.pi * 2
			local spawnPos = root.Position + Vector3.new(
				math.cos(spawnAngle) * spawnRadius,
				spawnHeight,
				math.sin(spawnAngle) * spawnRadius
			)
			local startRotX, startRotZ = math.random()*math.pi*2, math.random()*math.pi*2
			p.CFrame = CFrame.new(spawnPos) * CFrame.Angles(startRotX, 0, startRotZ)

			local mesh = Instance.new("SpecialMesh",p)
			mesh.MeshType=Enum.MeshType.Sphere
			mesh.Scale=Vector3.new(1, 0.35, 0.6)

			local sway = Vector3.new(math.random(-1,1)*2.5, 0, math.random(-1,1)*2.5)
			local fallDistance = spawnHeight + 3
			local duration = 3.5 + math.random() * 2.5

			TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = CFrame.new(spawnPos + sway - Vector3.new(0, fallDistance, 0))
					* CFrame.Angles(startRotX + math.pi*2, 0, startRotZ + math.pi*1.5),
				Transparency = 0.3
			}):Play()

			task.delay(duration, function()
				if p then
					TweenService:Create(p, TweenInfo.new(0.6), {Transparency = 1}):Play()
					task.delay(0.6, function() if p then p:Destroy() end end)
				end
			end)
		end)
	end
	UpdateToggleVisual("Petals", state)
end

ApplyNightVision = function(state)
	nightVisionEnabled = state
	if state then
		if not nightVisionEffect then
			nightVisionEffect = Instance.new("ColorCorrectionEffect", Lighting)
			nightVisionEffect.Name = "vizerNightVision"
		end
		TweenService:Create(nightVisionEffect, TweenInfo.new(0.8), {
			Brightness=0.4, Contrast=0.5, Saturation=-0.5,
			TintColor=Color3.fromRGB(150,255,180)
		}):Play()
	else
		if nightVisionEffect then
			TweenService:Create(nightVisionEffect, TweenInfo.new(0.8), {
				Brightness=0, Contrast=0, Saturation=0,
				TintColor=Color3.fromRGB(255,255,255)
			}):Play()
		end
	end
	UpdateToggleVisual("NightVision", state)
end

local antiAfkConn = nil
ApplyAntiAfk = function(state)
	antiAfkEnabled = state
	if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn=nil end
	if state then
		antiAfkConn = player.Idled:Connect(function()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new(0, 0))
			end)
		end)
	end
	UpdateToggleVisual("AntiAfk", state)
end

function HJ_Apply(hum, on)
	if not hum then return end
	if on then
		if not HJ.saved then
			HJ.saved = {UseJumpPower = hum.UseJumpPower, JumpPower = hum.JumpPower, JumpHeight = hum.JumpHeight}
		end
		if HJ.saved.UseJumpPower then
			hum.JumpPower = HJ.saved.JumpPower * 2.4
		else
			hum.JumpHeight = HJ.saved.JumpHeight * 2.4
		end
	elseif HJ.saved then
		hum.JumpPower = HJ.saved.JumpPower
		hum.JumpHeight = HJ.saved.JumpHeight
		hum.UseJumpPower = HJ.saved.UseJumpPower
		HJ.saved = nil
	end
end

ApplyHighJump = function(state)
	highJumpEnabled = state
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	HJ_Apply(hum, state)
	UpdateToggleVisual("HighJump", state)
end

ApplyNameplates = function(state)
	nameplatesEnabled = state
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local billboard = plr.Character:FindFirstChildWhichIsA("BillboardGui")
			if billboard then billboard.Enabled = state end
		end
	end
	UpdateToggleVisual("Nameplates", state)
end

function MV.hum()
	local ch = player.Character
	return ch and ch:FindFirstChildOfClass("Humanoid")
end

function MV.speedHook(hum)
	if MV.speedSig then MV.speedSig:Disconnect(); MV.speedSig = nil end
	MV.speedHumRef = hum
	MV.speedSig = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if MV.speedOn and not MV.speedGuard and hum.WalkSpeed ~= MV.speedV then
			MV.speedGuard = true
			hum.WalkSpeed = MV.speedV
			MV.speedGuard = false
		end
	end)
end

function MV.speedEnforce()
	local hum = MV.hum()
	if not hum then return end
	if MV.speedHumRef ~= hum then MV.speedHook(hum) end
	if hum.WalkSpeed ~= MV.speedV then
		MV.speedGuard = true
		hum.WalkSpeed = MV.speedV
		MV.speedGuard = false
	end
end

function MV.speedAssist(dt)
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hum or not root or hum.Health <= 0 or hum.Sit or hum.PlatformStand or MV.fly then return end
	local md = hum.MoveDirection
	if md.Magnitude < 0.1 then return end
	local v = root.AssemblyLinearVelocity
	local along = Vector3.new(v.X, 0, v.Z):Dot(md.Unit)
	local deficit = MV.speedV - along
	if deficit > 2 then
		local step = math.min(deficit, MV.speedV) * dt
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {ch}
		if not workspace:Raycast(root.Position, md.Unit * (step + 2), params) then
			root.CFrame = root.CFrame + md.Unit * step
		end
	end
end

function ApplySpeed(state)
	MV.speedOn = state
	if MV.speedConn then MV.speedConn:Disconnect(); MV.speedConn = nil end
	if MV.speedConn2 then MV.speedConn2:Disconnect(); MV.speedConn2 = nil end
	if MV.speedSig then MV.speedSig:Disconnect(); MV.speedSig = nil end
	MV.speedHumRef = nil
	pcall(function() RunService:UnbindFromRenderStep("vizerSpeed") end)

	if state then
		local h = MV.hum()
		if h and not MV.origSpeed then MV.origSpeed = h.WalkSpeed end
		MV.speedConn = RunService.Stepped:Connect(MV.speedEnforce)
		RunService:BindToRenderStep("vizerSpeed", Enum.RenderPriority.Last.Value, MV.speedEnforce)
		MV.speedConn2 = RunService.Heartbeat:Connect(MV.speedAssist)
		MV.speedEnforce()
	else
		local h = MV.hum()
		if h then h.WalkSpeed = MV.origSpeed or 16 end
		MV.origSpeed = nil
	end
	UpdateToggleVisual("Speed", state)
end

function ApplyInfJump(state)
	MV.ij = state
	if MV.ijConn then MV.ijConn:Disconnect(); MV.ijConn = nil end
	if state then
		MV.ijConn = UIS.JumpRequest:Connect(function()
			local h = MV.hum()
			if h and h.Health > 0 then
				pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
			end
		end)
	end
	UpdateToggleVisual("InfJump", state)
end

function MV.flyClean()
	if MV.bv then MV.bv:Destroy(); MV.bv = nil end
	if MV.bg then MV.bg:Destroy(); MV.bg = nil end
	local h = MV.hum()
	if h then h.PlatformStand = false end
end

function ApplyFly(state)
	MV.fly = state
	if MV.flyConn then MV.flyConn:Disconnect(); MV.flyConn = nil end
	MV.flyClean()

	if state then
		MV.flyConn = RunService.RenderStepped:Connect(function()
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			local cam = workspace.CurrentCamera
			if not root or not hum or hum.Health <= 0 or not cam then return end

			if not MV.bv or MV.bv.Parent ~= root then
				if MV.bv then MV.bv:Destroy() end
				if MV.bg then MV.bg:Destroy() end
				MV.bv = Instance.new("BodyVelocity")
				MV.bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				MV.bv.Velocity = Vector3.new()
				MV.bv.Parent = root
				MV.bg = Instance.new("BodyGyro")
				MV.bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				MV.bg.P = 9e4; MV.bg.D = 1000
				MV.bg.CFrame = cam.CFrame
				MV.bg.Parent = root
			end
			hum.PlatformStand = true

			local dir = Vector3.new()
			if not UIS:GetFocusedTextBox() then
				local cf = cam.CFrame
				if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
					dir = dir - Vector3.new(0, 1, 0)
				end
			end
			if dir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
				dir = hum.MoveDirection
				if hum.Jump then dir = dir + Vector3.new(0, 1, 0) end
			end

			if dir.Magnitude > 0 then
				MV.bv.Velocity = dir.Unit * MV.flyV
			else
				MV.bv.Velocity = Vector3.new()
			end
			MV.bg.CFrame = cam.CFrame
		end)
	end

	UpdateToggleVisual("Fly", state)
end

MV.ncSaved = setmetatable({}, {__mode = "k"})

function ApplyNoclip(state)
	MV.noclip = state
	if MV.ncConn then MV.ncConn:Disconnect(); MV.ncConn = nil end
	if state then
		MV.ncConn = RunService.Stepped:Connect(function()
			local ch = player.Character
			if not ch then return end
			for _, p in ipairs(ch:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide then
					MV.ncSaved[p] = true
					p.CanCollide = false
				end
			end
		end)
	else
		for p in pairs(MV.ncSaved) do
			if p and p.Parent then p.CanCollide = true end
		end
		MV.ncSaved = setmetatable({}, {__mode = "k"})
	end
	UpdateToggleVisual("Noclip", state)
end

function ApplyClickTP(state)
	MV.ctp = state
	if MV.ctpConn then MV.ctpConn:Disconnect(); MV.ctpConn = nil end
	if state then
		MV.ctpConn = UIS.InputBegan:Connect(function(input, gpe)
			if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
			if UI.rebinding or MISC.fcOn then return end
			if gpe and UI.open then return end
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not root or not cam then return end

			local origin, dir
			if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				origin, dir = cam.CFrame.Position, cam.CFrame.LookVector
			else
				local pos = UIS:GetMouseLocation()
				local ray = cam:ViewportPointToRay(pos.X, pos.Y)
				origin, dir = ray.Origin, ray.Direction
			end

			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {ch}
			local hit = workspace:Raycast(origin, dir * 3000, params)
			if hit then
				root.CFrame = CFrame.new(hit.Position + hit.Normal * 2 + Vector3.new(0, 3, 0))
				root.AssemblyLinearVelocity = Vector3.new()
			end
		end)
	end
	UpdateToggleVisual("ClickTP", state)
end

function ApplyFullbright(state)
	MISC.fb = state
	if MISC.fbConn then MISC.fbConn:Disconnect(); MISC.fbConn = nil end
	if state then
		if not MISC.fbSaved then
			MISC.fbSaved = {
				Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows,
			}
		end
		MISC.fbConn = RunService.Heartbeat:Connect(function()
			if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
			if Lighting.ClockTime ~= 14 then Lighting.ClockTime = 14 end
			if Lighting.GlobalShadows then Lighting.GlobalShadows = false end
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
			Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
		end)
	elseif MISC.fbSaved then
		for k, v in pairs(MISC.fbSaved) do pcall(function() Lighting[k] = v end) end
		MISC.fbSaved = nil
	end
	UpdateToggleVisual("Fullbright", state)
end

function ApplyAutoJump(state)
	AJ.on = state
	if AJ.conn then AJ.conn:Disconnect(); AJ.conn = nil end

	if state then
		AJ.conn = RunService.Stepped:Connect(function()
			local ch = player.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 or hum.Sit or hum.PlatformStand then return end

			local st = hum:GetState()
			if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
				or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Seated
				or st == Enum.HumanoidStateType.PlatformStanding or st == Enum.HumanoidStateType.Dead then
				return
			end

			if not hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
				pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
			end

			hum.Jump = true
			if hum.FloorMaterial ~= Enum.Material.Air
				and (st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.Landed
					or st == Enum.HumanoidStateType.RunningNoPhysics) then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
			end
		end)
	end

	UpdateToggleVisual("AutoJump", state)
end

function FOG.dist()
	return 60 + FOG.t * FOG.t * 2400
end

function ApplyFog(state)
	FOG.on = state
	if FOG.conn then FOG.conn:Disconnect(); FOG.conn = nil end

	if state then
		if not FOG.saved then
			FOG.saved = {Start = Lighting.FogStart, End = Lighting.FogEnd, Color = Lighting.FogColor, atm = {}}
		end
		FOG.conn = RunService.Heartbeat:Connect(function()
			local s = FOG.saved
			if not s then return end
			for _, v in ipairs(Lighting:GetChildren()) do
				if v:IsA("Atmosphere") then
					table.insert(s.atm, v)
					v.Parent = nil
				end
			end
			if Lighting.FogColor ~= EffectColors.Fog then Lighting.FogColor = EffectColors.Fog end
			if Lighting.FogStart ~= 0 then Lighting.FogStart = 0 end
			local dist = FOG.dist()
			if Lighting.FogEnd ~= dist then Lighting.FogEnd = dist end
		end)
	elseif FOG.saved then
		local s = FOG.saved
		FOG.saved = nil
		Lighting.FogColor = s.Color
		Lighting.FogStart = s.Start
		Lighting.FogEnd = s.End
		for _, a in ipairs(s.atm) do
			pcall(function() a.Parent = Lighting end)
		end
	end

	UpdateToggleVisual("Fog", state)
end

function JC.spawn(char)
	local now = os.clock()
	if now - JC.last < 0.2 then return end
	JC.last = now

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local pos = root.Position - Vector3.new(0, 3, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), params)
	if hit then pos = hit.Position + Vector3.new(0, 0.05, 0) end

	local part = Instance.new("Part")
	part.Name = "vizerJumpCircle"
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.CastShadow = false; part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(pos)
	part.Parent = workspace

	local att = Instance.new("Attachment")
	att.Name = "Attachment"
	att.Parent = part

	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxassetid://9596889087"
	e.Color = ColorSequence.new(EffectColors.JumpCircle)
	e.LightEmission = 5
	e.LightInfluence = 1
	e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
	e.Size = NumberSequence.new(5)
	e.Squash = NumberSequence.new(0)
	e.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	e.ZOffset = 0
	e.EmissionDirection = Enum.NormalId.Bottom
	e.Lifetime = NumberRange.new(0.75, 0.75)
	e.Rate = 0
	e.Rotation = NumberRange.new(0, 0)
	e.RotSpeed = NumberRange.new(2000, 2000)
	e.Speed = NumberRange.new(0.01, 0.01)
	e.SpreadAngle = Vector2.new(0, 0)
	e.Acceleration = Vector3.new(0, 0, 0)
	e.Drag = 0
	e.LockedToPart = true
	e.TimeScale = 0.3
	pcall(function()
		e.Shape = Enum.ParticleEmitterShape.Box
		e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		e.VelocityInheritance = 0
		e.WindAffectsDrag = false
	end)
	e.Enabled = true
	e.Parent = att
	e:Emit(1)

	task.delay(3.5, function()
		if part then part:Destroy() end
	end)
end

function JC.ground(char, root)
	local pos = root.Position - Vector3.new(0, 3, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), params)
	if hit then pos = hit.Position + Vector3.new(0, 0.05, 0) end
	return pos
end

function JC.spawn2(char)
	local now = os.clock()
	if now - JC.last2 < 0.3 then return end
	JC.last2 = now

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local pos = JC.ground(char, root)

	local part = Instance.new("Part")
	part.Name = "vizerJumpCircle2"
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.CastShadow = false; part.Transparency = 1
	part.Size = Vector3.new(0.001, 7, 7)
	part.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	part.Parent = workspace

	local att = Instance.new("Attachment")
	att.Name = "Attachment"
	att.CFrame = CFrame.Angles(0, 0, math.rad(-90))
	att.Parent = part

	local emitters = {}
	local col = EffectColors.JumpCircle

	local function MakeRing(texture, brightness, rate)
		local e = Instance.new("ParticleEmitter")
		e.Texture = texture
		e.Brightness = brightness
		e.Color = ColorSequence.new(col)
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		e.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 4),
			NumberSequenceKeypoint.new(1, 0),
		})
		e.Squash = NumberSequence.new(0)
		e.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.196, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
		e.ZOffset = 1
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(1, 1)
		e.Rate = rate
		e.Rotation = NumberRange.new(-180, 180)
		e.RotSpeed = NumberRange.new(750, 750)
		e.Speed = NumberRange.new(0.001, 0.001)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		end)
		e.Enabled = true
		e.Parent = att
		table.insert(emitters, e)
	end
	MakeRing("rbxassetid://8047533775", 5, 10)
	MakeRing("rbxassetid://14590122278", 15, 3)

	local sp = Instance.new("ParticleEmitter")
	sp.Texture = "rbxassetid://1084982817"
	sp.Brightness = 50
	sp.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sp.LightEmission = 0
	sp.LightInfluence = 0
	sp.Orientation = Enum.ParticleOrientation.FacingCamera
	sp.Size = NumberSequence.new(0.05)
	sp.Squash = NumberSequence.new(0)
	sp.Transparency = NumberSequence.new(0)
	sp.ZOffset = 0
	sp.EmissionDirection = Enum.NormalId.Right
	sp.Lifetime = NumberRange.new(1, 1.5)
	sp.Rate = 40
	sp.Rotation = NumberRange.new(0, 0)
	sp.RotSpeed = NumberRange.new(0, 0)
	sp.Speed = NumberRange.new(5, 5)
	sp.SpreadAngle = Vector2.new(15, 15)
	sp.Acceleration = Vector3.new(0, 0, 0)
	pcall(function()
		sp.Shape = Enum.ParticleEmitterShape.Disc
		sp.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		sp.ShapePartial = 1
		sp.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		sp.FlipbookLayout = Enum.ParticleFlipbookLayout.None
	end)
	sp.Enabled = true
	sp.Parent = part
	table.insert(emitters, sp)

	task.delay(0.5, function()
		for _, e in ipairs(emitters) do
			if e and e.Parent then e.Enabled = false end
		end
	end)
	task.delay(3.5, function()
		if part then part:Destroy() end
	end)
end

function JC.hook(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Jumping and JC.on then
			local m = EXT.jcMode
			if m == 2 then
				JC.spawn2(char)
			elseif m == 3 then
				if JC.spawn3 then JC.spawn3(char) end
			else
				JC.spawn(char)
			end
		end
	end)
end
if player.Character then task.spawn(JC.hook, player.Character) end
player.CharacterAdded:Connect(JC.hook)

function ApplyJumpCircle(state)
	JC.on = state
	UpdateToggleVisual("JumpCircle", state)
end

function SN.color(col)
	local e = SN.emitter
	if not e then return end
	e.Color = ColorSequence.new(col)
	e.LightEmission = ((col.R + col.G + col.B) < 0.05) and 0 or 0.5
end

function ApplySnow(state)
	SN.on = state
	if SN.conn then SN.conn:Disconnect(); SN.conn = nil end
	if SN.part then SN.part:Destroy(); SN.part = nil; SN.emitter = nil end

	if state then
		local part = Instance.new("Part")
		part.Name = "vizerSnow"
		part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		part.CastShadow = false; part.Transparency = 1
		part.Size = Vector3.new(200, 1, 200)
		part.Parent = workspace

		local e = Instance.new("ParticleEmitter")
		e.Texture = "rbxassetid://99851851"
		e.Brightness = 1
		e.LightEmission = 0.5
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Size = NumberSequence.new(0.5)
		e.Squash = NumberSequence.new(0)
		e.Transparency = NumberSequence.new(0)
		e.ZOffset = 0
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(3, 5)
		e.Rate = 300
		e.Rotation = NumberRange.new(0, 0)
		e.RotSpeed = NumberRange.new(0, 0)
		e.Speed = NumberRange.new(30, 30)
		e.SpreadAngle = Vector2.new(50, 50)
		e.Acceleration = Vector3.new(0, 0, 0)
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		end)
		e.Enabled = true
		e.Parent = part

		SN.part = part
		SN.emitter = e
		SN.color(EffectColors.Snow)

		SN.conn = RunService.Heartbeat:Connect(function()
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			if not root then return end
			if not part.Parent then part.Parent = workspace end
			part.CFrame = CFrame.new(root.Position + Vector3.new(0, 90, 0)) * CFrame.Angles(0, 0, math.pi)
		end)
	end

	UpdateToggleVisual("Snow", state)
end

local camZoomSavedMode, camZoomSavedMin, camZoomSavedMax = nil, nil, nil

ApplyCameraZoom = function(state)
	cameraZoomEnabled = state
	if cameraZoomConn then cameraZoomConn:Disconnect(); cameraZoomConn = nil end

	if state then
		camZoomSavedMode = player.CameraMode
		camZoomSavedMin  = player.CameraMinZoomDistance
		camZoomSavedMax  = player.CameraMaxZoomDistance

		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 128

		cameraZoomConn = RunService.Heartbeat:Connect(function()
			if player.CameraMode ~= Enum.CameraMode.Classic then
				player.CameraMode = Enum.CameraMode.Classic
			end
			if player.CameraMaxZoomDistance < 5 then
				player.CameraMaxZoomDistance = 128
			end
		end)
	else
		if camZoomSavedMode then
			player.CameraMode = camZoomSavedMode
			player.CameraMinZoomDistance = camZoomSavedMin
			player.CameraMaxZoomDistance = camZoomSavedMax
			camZoomSavedMode = nil
		end
	end

	UpdateToggleVisual("CameraZoom", state)
end

function ApplyStretch(state)
	MISC.stretchOn = state
	pcall(function() RunService:UnbindFromRenderStep("vizerStretch") end)
	if state then
		RunService:BindToRenderStep("vizerStretch", Enum.RenderPriority.Camera.Value + 10, function()
			local cam = workspace.CurrentCamera
			if not cam then return end
			local s = MISC.stretchV / 100
			cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, s, 0, 0, 0, 1, 0, 0, 0, 1)
		end)
	end
	UpdateToggleVisual("Stretch", state)
end

function ApplyMotionBlur(state)
	MB.on = state
	pcall(function() RunService:UnbindFromRenderStep("vizerMotionBlur") end)

	if state then
		if not MB.fx then
			MB.fx = Instance.new("BlurEffect")
			MB.fx.Name = "vizerMotionBlur"
			MB.fx.Size = 0
		end
		MB.fx.Size = 0
		MB.fx.Enabled = true
		MB.fx.Parent = Lighting
		MB.last = nil
		MB.size = 0

		RunService:BindToRenderStep("vizerMotionBlur", Enum.RenderPriority.Camera.Value + 20, function(dt)
			local cam = workspace.CurrentCamera
			if not cam or dt <= 0 then return end
			local cf = cam.CFrame
			local last = MB.last
			MB.last = cf
			if not last then return end

			local rot = math.acos(math.clamp(last.LookVector:Dot(cf.LookVector), -1, 1)) / dt
			local mov = (cf.Position - last.Position).Magnitude / dt
			if rot > 40 then rot = 0 end
			if mov > 300 then mov = 0 end

			local target = (rot * 3 + mov * 0.12) * (MB.k / 50)
			target = math.clamp(target, 0, 28)
			MB.size = MB.size + (target - MB.size) * math.min(1, dt * 14)
			MB.fx.Size = (MB.size < 0.2) and 0 or MB.size
		end)
	else
		if MB.fx then MB.fx.Size = 0; MB.fx.Parent = nil end
	end

	UpdateToggleVisual("MotionBlur", state)
end

function ApplyGhost(state)
	GH.on = state
	pcall(function() RunService:UnbindFromRenderStep("vizerGhost") end)
	GH.char = nil

	if state then
		local frame = 0
		RunService:BindToRenderStep("vizerGhost", Enum.RenderPriority.Last.Value, function()
			local ch = player.Character
			if not ch then return end
			frame = frame + 1
			if GH.char ~= ch or frame >= 30 then
				frame = 0
				GH.char = ch
				GH.parts = {}
				for _, p in ipairs(ch:GetDescendants()) do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then table.insert(GH.parts, p) end
				end
			end
			local a = GH.a / 100
			for _, p in ipairs(GH.parts) do
				if p.Parent then
					if headlessEnabled and p.Name == "Head" then
						p.LocalTransparencyModifier = 1
					else
						p.LocalTransparencyModifier = a
					end
				end
			end
		end)
	else
		local ch = player.Character
		if ch then
			for _, p in ipairs(ch:GetDescendants()) do
				if p:IsA("BasePart") then
					p.LocalTransparencyModifier = (headlessEnabled and p.Name == "Head") and 1 or 0
				end
			end
		end
		GH.parts = {}
	end

	UpdateToggleVisual("Ghost", state)
end

function ZM.active() return ZM.latch or ZM.held end

function ZM.step(dt)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local target = ZM.active() and ZM.x or 1
	if ZM.m <= 1.001 and target == 1 then
		ZM.m = 1; ZM.base = nil
		return
	end
	if not ZM.base then ZM.base = cam.FieldOfView end
	ZM.m = ZM.m + (target - ZM.m) * math.min(1, dt * 10)
	if target == 1 and ZM.m < 1.02 then
		cam.FieldOfView = ZM.base
		ZM.m = 1; ZM.base = nil
		return
	end
	cam.FieldOfView = math.clamp(ZM.base / ZM.m, 1, 120)
end
pcall(function() RunService:UnbindFromRenderStep("vizerZoom") end)
RunService:BindToRenderStep("vizerZoom", Enum.RenderPriority.Camera.Value + 11, ZM.step)

local function xLoop(key, fn)
	if XC[key] then XC[key]:Disconnect(); XC[key] = nil end
	if fn then XC[key] = RunService.Heartbeat:Connect(fn) end
end
local function xRoot()
	local ch = player.Character
	return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function xFx(key, class, name, props, on)
	local inst = XFX[key]
	if on then
		if not inst then
			inst = Instance.new(class); inst.Name = name
			XFX[key] = inst
		end
		for k, v in pairs(props) do inst[k] = v end
		inst.Parent = Lighting
	elseif inst then
		inst.Parent = nil
	end
end

local XHK = {}
player.CharacterAdded:Connect(function(ch)
	task.spawn(function()
		ch:WaitForChild("HumanoidRootPart", 10)
		task.wait(0.4)
		for _, fn in pairs(XHK) do pcall(fn, ch) end
	end)
end)

local OV = Instance.new("ScreenGui")
OV.Name = "vizerOverlay"; OV.ResetOnSpawn = false; OV.IgnoreGuiInset = true
OV.DisplayOrder = 9980; OV.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
OV.Parent = player:WaitForChild("PlayerGui")

local ovVig = Instance.new("Frame")
ovVig.Size = UDim2.new(1, 0, 1, 0); ovVig.BackgroundTransparency = 1; ovVig.Visible = false; ovVig.Parent = OV
local function vigStrip(size, pos, rot, t0, t1)
	local f = Instance.new("Frame")
	f.Size = size; f.Position = pos; f.BackgroundColor3 = Color3.new(0, 0, 0); f.BorderSizePixel = 0; f.Parent = ovVig
	local g = Instance.new("UIGradient")
	g.Rotation = rot
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, t0), NumberSequenceKeypoint.new(1, t1)})
	g.Parent = f
end
vigStrip(UDim2.new(1, 0, 0.3, 0), UDim2.new(0, 0, 0, 0),    90, 0.2, 1)
vigStrip(UDim2.new(1, 0, 0.3, 0), UDim2.new(0, 0, 0.7, 0),  90, 1, 0.2)
vigStrip(UDim2.new(0.2, 0, 1, 0), UDim2.new(0, 0, 0, 0),     0, 0.25, 1)
vigStrip(UDim2.new(0.2, 0, 1, 0), UDim2.new(0.8, 0, 0, 0),   0, 1, 0.25)

local ovBars = Instance.new("Frame")
ovBars.Size = UDim2.new(1, 0, 1, 0); ovBars.BackgroundTransparency = 1; ovBars.Visible = false; ovBars.Parent = OV
for _, y in ipairs({0, 0.89}) do
	local b = Instance.new("Frame")
	b.Size = UDim2.new(1, 0, 0.11, 0); b.Position = UDim2.new(0, 0, y, 0)
	b.BackgroundColor3 = Color3.new(0, 0, 0); b.BorderSizePixel = 0; b.Parent = ovBars
end

XH.Vignette  = function(on) ovVig.Visible = on end
XH.Bars      = function(on) ovBars.Visible = on end
function XColorUpdate(key, col)
	if key == "Tint" and XFX.tint then XFX.tint.TintColor = col end
end

XH.Vibrant  = function(on) xFx("vib", "ColorCorrectionEffect", "vizerVibrant", {Saturation = 0.45, Contrast = 0.08}, on) end
XH.BW       = function(on) xFx("bw", "ColorCorrectionEffect", "vizerBW", {Saturation = -1, Contrast = 0.1}, on) end

local XR = {}
XH.Rain = function(on)
	xLoop("rain", nil)
	if XR.part then XR.part:Destroy(); XR.part = nil end
	if not on then return end
	local part = Instance.new("Part")
	part.Name = "vizerRain"
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.CastShadow = false; part.Transparency = 1
	part.Size = Vector3.new(160, 1, 160)
	part.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxassetid://99851851"
	e.Color = ColorSequence.new(Color3.fromRGB(175, 205, 255))
	e.LightEmission = 0.3; e.LightInfluence = 0
	e.Orientation = Enum.ParticleOrientation.VelocityParallel
	e.Size = NumberSequence.new(0.5)
	e.Transparency = NumberSequence.new(0.35)
	e.Lifetime = NumberRange.new(1.1, 1.4)
	e.Rate = 500
	e.Speed = NumberRange.new(70, 80)
	e.EmissionDirection = Enum.NormalId.Bottom
	e.SpreadAngle = Vector2.new(2, 2)
	e.Acceleration = Vector3.new(0, -20, 0)
	e.Enabled = true
	e.Parent = part
	XR.part = part
	xLoop("rain", function()
		local r = xRoot()
		if not r then return end
		if not part.Parent then part.Parent = workspace end
		part.CFrame = CFrame.new(r.Position + Vector3.new(0, 70, 0))
	end)
end

local RB = {orig = setmetatable({}, {__mode = "k"}), parts = {}, frame = 0}
XH.Rainbow = function(on)
	pcall(function() RunService:UnbindFromRenderStep("vizerRainbow") end)
	if on then
		RunService:BindToRenderStep("vizerRainbow", Enum.RenderPriority.Last.Value, function()
			local ch = player.Character
			if not ch then return end
			RB.frame = RB.frame + 1
			if RB.ch ~= ch or RB.frame >= 30 then
				RB.frame = 0; RB.ch = ch; RB.parts = {}
				for _, p in ipairs(ch:GetDescendants()) do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name:sub(1, 6) ~= "vizer" then
						table.insert(RB.parts, p)
					end
				end
			end
			local c = Color3.fromHSV((os.clock() * 0.25) % 1, 0.8, 1)
			for _, p in ipairs(RB.parts) do
				if p.Parent then
					if RB.orig[p] == nil then RB.orig[p] = p.Color end
					p.Color = c
				end
			end
		end)
	else
		for p, c in pairs(RB.orig) do
			if p.Parent then p.Color = c end
			RB.orig[p] = nil
		end
	end
end

local TM = {}
function TM.release()
	if not XS.CustomTime and not XS.TimeLapse and TM.saved then
		Lighting.ClockTime = TM.saved; TM.saved = nil
	end
end
XH.CustomTime = function(on)
	xLoop("time", nil)
	if on then
		if XS.TimeLapse then
			XS.TimeLapse = false; xLoop("lapse", nil); UpdateToggleVisual("TimeLapse", false)
		end
		if TM.saved == nil then TM.saved = Lighting.ClockTime end
		xLoop("time", function()
			if Lighting.ClockTime ~= EXT.time then Lighting.ClockTime = EXT.time end
		end)
	else
		TM.release()
	end
end
XH.TimeLapse = function(on)
	xLoop("lapse", nil)
	if on then
		if XS.CustomTime then
			XS.CustomTime = false; xLoop("time", nil); UpdateToggleVisual("CustomTime", false)
		end
		if TM.saved == nil then TM.saved = Lighting.ClockTime end
		xLoop("lapse", function(dt)
			Lighting.ClockTime = (Lighting.ClockTime + dt * EXT.lapse / 10) % 24
		end)
	else
		TM.release()
	end
end

local AM = {}
XH.Ambient = function(on)
	xLoop("amb", nil)
	if on then
		if not AM.saved then AM.saved = {Lighting.Ambient, Lighting.OutdoorAmbient} end
		xLoop("amb", function()
			local c = EffectColors.Ambient
			Lighting.Ambient = c; Lighting.OutdoorAmbient = c
		end)
	elseif AM.saved and not XS.Disco then
		Lighting.Ambient = AM.saved[1]; Lighting.OutdoorAmbient = AM.saved[2]; AM.saved = nil
	end
end

local XRY = {set = setmetatable({}, {__mode = "k"}), token = 0}
local function xrayPart(d)
	if not d:IsA("BasePart") or d.Name:sub(1, 6) == "vizer" then return end
	local m = d:FindFirstAncestorOfClass("Model")
	if m and m:FindFirstChildOfClass("Humanoid") then return end
	XRY.set[d] = true
	d.LocalTransparencyModifier = 0.6
end
XH.XRay = function(on)
	XRY.token = XRY.token + 1
	local tok = XRY.token
	if XRY.conn then XRY.conn:Disconnect(); XRY.conn = nil end
	if on then
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if XRY.token ~= tok then return end
				xrayPart(d)
				n = n + 1
				if n % 1500 == 0 then task.wait() end
			end
		end)
		XRY.conn = workspace.DescendantAdded:Connect(function(d)
			task.defer(function() if XRY.token == tok then xrayPart(d) end end)
		end)
	else
		task.spawn(function()
			local n = 0
			for p in pairs(XRY.set) do
				if XRY.token ~= tok then return end
				if p.Parent then p.LocalTransparencyModifier = 0 end
				XRY.set[p] = nil
				n = n + 1
				if n % 1500 == 0 then task.wait() end
			end
		end)
	end
end

local GR = {}
XH.LowGravity = function(on)
	xLoop("grav", nil)
	if on then
		if not GR.saved then GR.saved = workspace.Gravity end
		xLoop("grav", function()
			if workspace.Gravity ~= EXT.grav then workspace.Gravity = EXT.grav end
		end)
	elseif GR.saved then
		workspace.Gravity = GR.saved; GR.saved = nil
	end
end
XH.Spin = function(on)
	xLoop("spin", on and function(dt)
		local r = xRoot()
		if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(EXT.spin * 10) * dt, 0) end
	end or nil)
end

local NE = {acc = 0}
local function nameTagsRemove()
	for _, plr in ipairs(Players:GetPlayers()) do
		local ch = plr.Character
		local head = ch and ch:FindFirstChild("Head")
		local t = head and head:FindFirstChild("vizerNameTag")
		if t then t:Destroy() end
	end
end
XH.NameESP = function(on)
	xLoop("nesp", nil)
	if not on then nameTagsRemove(); return end
	xLoop("nesp", function(dt)
		NE.acc = NE.acc + dt
		if NE.acc < 0.25 then return end
		NE.acc = 0
		local cam = workspace.CurrentCamera
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local ch = plr.Character
				local head = ch and ch:FindFirstChild("Head")
				if head then
					local bb = head:FindFirstChild("vizerNameTag")
					if not bb then
						bb = Instance.new("BillboardGui")
						bb.Name = "vizerNameTag"
						bb.Size = UDim2.new(0, 160, 0, 34)
						bb.StudsOffset = Vector3.new(0, 2.4, 0)
						bb.AlwaysOnTop = true
						bb.LightInfluence = 0
						bb.Adornee = head
						bb.Parent = head
						local l = Instance.new("TextLabel")
						l.Name = "L"; l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
						l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.TextStrokeTransparency = 0.35
						l.Parent = bb
					end
					local l = bb:FindFirstChild("L")
					if l then
						local dist = cam and (head.Position - cam.CFrame.Position).Magnitude or 0
						l.Text = plr.DisplayName .. "\n" .. math.floor(dist) .. " studs"
						l.TextColor3 = (MISC.isFriend and MISC.isFriend(plr)) and EffectColors.FriendESP or Color3.new(1, 1, 1)
					end
				end
			end
		end
	end)
end

XH.HideHUD = function(on)
	local sg = game:GetService("StarterGui")
	pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, not on) end)
	if not on and MISC.tabOn then
		pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)
	end
end
function XApplyFpsCap()
	if setfpscap then pcall(setfpscap, XS.FPSCap and EXT.fpscap or 60) end
end
XH.FPSCap = function(on)
	if not setfpscap then
		XS.FPSCap = false
		UpdateToggleVisual("FPSCap", false)
		UI.notify("⚠ Your executor has no setfpscap")
		return
	end
	XApplyFpsCap()
end

local WPT = {}
XH.btnSetWP = function()
	local r = xRoot()
	if r then WPT.cf = r.CFrame; UI.notify("📍 Waypoint saved") end
end
XH.btnGoWP = function()
	local r = xRoot()
	if not WPT.cf then UI.notify("⚠ Set a waypoint first"); return end
	if r then r.CFrame = WPT.cf; r.AssemblyLinearVelocity = Vector3.new() end
end
XH.btnCopy = function()
	local r = xRoot()
	if not r then return end
	local p = r.Position
	local s = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
	if setclipboard then pcall(setclipboard, s); UI.notify("📋 Copied: " .. s) else UI.notify("📋 " .. s) end
end
XH.btnRefresh = function()
	local r, h = xRoot(), MV.hum()
	if not r or not h then return end
	local cf = r.CFrame
	local conn
	conn = player.CharacterAdded:Connect(function(ch)
		conn:Disconnect()
		local nr = ch:WaitForChild("HumanoidRootPart", 10)
		if nr then task.wait(0.4); nr.CFrame = cf end
	end)
	h.Health = 0
	UI.notify("🔄 Respawning in place...")
end
XH.btnReset = function()
	local h = MV.hum()
	if h then h.Health = 0 end
end
XH.btnSit = function()
	local h = MV.hum()
	if h then h.Sit = not h.Sit end
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)

	local function findPlayer(txt)
		txt = txt:lower():gsub("^%s+", ""):gsub("%s+$", "")
		if txt == "" then return nil end
		local best
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				local n, d = p.Name:lower(), p.DisplayName:lower()
				if n == txt or d == txt then return p end
				if not best and (n:find(txt, 1, true) == 1 or d:find(txt, 1, true) == 1) then best = p end
			end
		end
		return best
	end

	UI.section("Misc", "🎬  Players")
	local row = UI.fullRow("Misc", 52)
	local box = new("TextBox", {Position = UDim2.new(0, 12, 0, 11), Size = UDim2.new(1, -176, 0, 30), BackgroundTransparency = 0.35,
		Text = "", PlaceholderText = "Player nickname", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
	corner(box, 8)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
	local boxStroke = stroke(box, Themes[1].Accent, 1, 0.55)
	UI.bind(function(t)
		box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub; boxStroke.Color = t.Accent
	end)
	box.Focused:Connect(function() tween(boxStroke, 0.2, {Transparency = 0}) end)
	box.FocusLost:Connect(function() tween(boxStroke, 0.2, {Transparency = 0.55}) end)

	local function mkBtn(text, offsetX, onClick)
		local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, offsetX, 0, 11),
			Size = UDim2.new(0, 64, 0, 30), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
			AutoButtonColor = false, BackgroundTransparency = 0.2, ZIndex = 14}, row)
		corner(b, 8)
		UI.bind(function(t) b.BackgroundColor3 = t.On end)
		b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
		b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
		b.MouseButton1Click:Connect(function() PlayUISound(SND.click, 0.45, 1.15); onClick() end)
		return b
	end

	local viewing, viewBtn
	local function stopView()
		viewing = nil
		local cam, h = workspace.CurrentCamera, MV.hum()
		if cam and h then cam.CameraSubject = h end
		if viewBtn then viewBtn.Text = "View" end
	end
	mkBtn("TP", -12, function()
		local plr = findPlayer(box.Text)
		local tr = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not tr then UI.notify("⚠ Player not found"); return end
		if r then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
	end)
	viewBtn = mkBtn("View", -82, function()
		if viewing then stopView(); return end
		local plr = findPlayer(box.Text)
		local h = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		local cam = workspace.CurrentCamera
		if not h or not cam then UI.notify("⚠ Player not found"); return end
		cam.CameraSubject = h
		viewing = plr
		viewBtn.Text = "Stop"
	end)
	Players.PlayerRemoving:Connect(function(p) if p == viewing then stopView() end end)
end

local function xConn(key, sig, fn)
	if XC[key] then XC[key]:Disconnect(); XC[key] = nil end
	if fn then XC[key] = sig:Connect(fn) end
end
local function xStep(name, prio, fn)
	pcall(function() RunService:UnbindFromRenderStep(name) end)
	if fn then RunService:BindToRenderStep(name, prio, fn) end
end
local function xGrounded()
	local h = MV.hum()
	return h and h.Health > 0 and h.FloorMaterial ~= Enum.Material.Air
end

local SF = {add = 0, last = nil, base = nil}
XH.SpeedFov = function(on)
	SF.add = 0; SF.last = nil; SF.base = nil
	xStep("vizerSpeedFov", Enum.RenderPriority.Camera.Value + 12, on and function(dt)
		local cam, r = workspace.CurrentCamera, xRoot()
		if not cam or not r then return end
		if SF.last == nil or math.abs(cam.FieldOfView - SF.last) > 0.01 then SF.base = cam.FieldOfView end
		local v = r.AssemblyLinearVelocity
		local spd = Vector3.new(v.X, 0, v.Z).Magnitude
		local target = math.clamp((spd - 16) * 0.6, 0, 25)
		SF.add = SF.add + (target - SF.add) * math.min(1, dt * 6)
		SF.last = math.clamp(SF.base + SF.add, 1, 120)
		cam.FieldOfView = SF.last
	end or nil)
	if not on then
		local cam = workspace.CurrentCamera
		if cam and SF.base then cam.FieldOfView = SF.base end
	end
end

XH.CamTilt = function(on)
	xStep("vizerTilt", Enum.RenderPriority.Camera.Value + 14, on and function()
		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = cam.CFrame * CFrame.Angles(0, 0, math.rad(EXT.tilt)) end
	end or nil)
end

XH.Mirror = function(on)
	xStep("vizerMirror", Enum.RenderPriority.Camera.Value + 15, on and function()
		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 1) end
	end or nil)
end

XH.CamNoclip = function(on)
	pcall(function()
		player.DevCameraOcclusionMode = on and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
	end)
end

XH.Blur   = function(on) xFx("blur", "BlurEffect", "vizerBlur", {Size = EXT.blur}, on) end
XH.Tint   = function(on) xFx("tint", "ColorCorrectionEffect", "vizerTint", {TintColor = EffectColors.Tint}, on) end
XH.Bright = function(on) xFx("bright", "ColorCorrectionEffect", "vizerBright", {Brightness = EXT.bright / 100}, on) end

XH.Disco = function(on)
	xLoop("disco", nil)
	if on then
		if not AM.saved then AM.saved = {Lighting.Ambient, Lighting.OutdoorAmbient} end
		xLoop("disco", function()
			local c = Color3.fromHSV((os.clock() * 0.5) % 1, 0.8, 1)
			Lighting.Ambient = c; Lighting.OutdoorAmbient = c
		end)
	elseif AM.saved and not XS.Ambient then
		Lighting.Ambient = AM.saved[1]; Lighting.OutdoorAmbient = AM.saved[2]; AM.saved = nil
	end
end

local AV = {}
XH.AntiVoid = function(on)
	AV.safe = nil
	xLoop("void", on and function()
		local r = xRoot()
		if not r then return end
		if xGrounded() then AV.safe = r.CFrame end
		if AV.safe and r.Position.Y < workspace.FallenPartsDestroyHeight + 80 then
			r.CFrame = AV.safe + Vector3.new(0, 4, 0)
			r.AssemblyLinearVelocity = Vector3.new()
		end
	end or nil)
end

XH.Freeze = function(on)
	local r = xRoot()
	if r then r.Anchored = on end
end
XHK.Freeze = function(ch)
	local r = ch:FindFirstChild("HumanoidRootPart")
	if XS.Freeze and r then r.Anchored = true end
end

XH.JoinAlerts = function(on)
	xConn("pa", Players.PlayerAdded, on and function(p)
		UI.notify(((MISC.isFriend and MISC.isFriend(p)) and "💚 " or "➕ ") .. p.DisplayName .. " joined")
	end or nil)
	xConn("pr", Players.PlayerRemoving, on and function(p)
		UI.notify(((MISC.isFriend and MISC.isFriend(p)) and "💚 " or "➖ ") .. p.DisplayName .. " left")
	end or nil)
end

local MU = {}
XH.Mute = function(on)
	pcall(function()
		local s = UserSettings():GetService("UserGameSettings")
		if on then MU.v = s.MasterVolume; s.MasterVolume = 0 else s.MasterVolume = MU.v or 1 end
	end)
end

XH.CoordsHUD  = function(on) if MISC.setExtra then MISC.setExtra("coords", on) end end
XH.ClockHUD   = function(on) if MISC.setExtra then MISC.setExtra("clock", on) end end
XH.PlayersHUD = function(on) if MISC.setExtra then MISC.setExtra("players", on) end end
XH.SpeedHUD   = function(on) if MISC.setExtra then MISC.setExtra("speed", on) end end

XH.btnSpawn = function()
	local r = xRoot()
	if not r then return end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("SpawnLocation") then
			r.CFrame = d.CFrame + Vector3.new(0, 4, 0)
			return
		end
	end
	UI.notify("⚠ No spawn found")
end
XH.btnRandom = function()
	local r, list = xRoot(), {}
	for _, p in ipairs(Players:GetPlayers()) do
		local tr = p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if tr then table.insert(list, tr) end
	end
	if not r or #list == 0 then UI.notify("⚠ No players to teleport to"); return end
	r.CFrame = list[math.random(#list)].CFrame * CFrame.new(0, 0, 3)
end
local function xCopy(s, label)
	if setclipboard then pcall(setclipboard, s); UI.notify("📋 " .. label .. " copied") else UI.notify("📋 " .. s) end
end

XH.FovLock = function(on)
	xStep("vizerFovLock", Enum.RenderPriority.Camera.Value + 16, on and function()
		local cam = workspace.CurrentCamera
		if cam then cam.FieldOfView = EXT.fov end
	end or nil)
end

local JP = {}
XH.JumpPower = function(on)
	xLoop("jump", nil)
	local h = MV.hum()
	if on then
		if h and not JP.saved then JP.saved = {h.UseJumpPower, h.JumpPower} end
		xLoop("jump", function()
			local hh = MV.hum()
			if not hh then return end
			if not hh.UseJumpPower then hh.UseJumpPower = true end
			if hh.JumpPower ~= EXT.jump then hh.JumpPower = EXT.jump end
		end)
	elseif JP.saved then
		if h then h.UseJumpPower = JP.saved[1]; h.JumpPower = JP.saved[2] end
		JP.saved = nil
	end
end

XH.SessionHUD = function(on) if MISC.setExtra then MISC.setExtra("session", on) end end
XH.ServerHUD  = function(on) if MISC.setExtra then MISC.setExtra("server", on) end end
XH.btnDay   = function() Lighting.ClockTime = 14 end
XH.btnNight = function() Lighting.ClockTime = 0 end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	UI.section("Misc", "📍  Teleport")
	local row = UI.fullRow("Misc", 52)
	local box = new("TextBox", {Position = UDim2.new(0, 12, 0, 11), Size = UDim2.new(1, -104, 0, 30), BackgroundTransparency = 0.35,
		Text = "", PlaceholderText = "X, Y, Z  (e.g. 100, 50, -20)", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
	corner(box, 8)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
	local bs = stroke(box, Themes[1].Accent, 1, 0.55)
	UI.bind(function(t)
		box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub; bs.Color = t.Accent
	end)
	box.Focused:Connect(function() tween(bs, 0.2, {Transparency = 0}) end)
	box.FocusLost:Connect(function() tween(bs, 0.2, {Transparency = 0.55}) end)
	local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 11), Size = UDim2.new(0, 72, 0, 30),
		Text = "Go", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
		BackgroundTransparency = 0.2, ZIndex = 14}, row)
	corner(b, 8)
	UI.bind(function(t) b.BackgroundColor3 = t.On end)
	b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
	b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
	b.MouseButton1Click:Connect(function()
		PlayUISound(SND.click, 0.45, 1.15)
		local nums = {}
		for n in box.Text:gmatch("%-?%d+%.?%d*") do table.insert(nums, tonumber(n)) end
		local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if #nums < 3 then UI.notify("⚠ Enter three numbers: X, Y, Z"); return end
		if r then r.CFrame = CFrame.new(nums[1], nums[2], nums[3]); r.AssemblyLinearVelocity = Vector3.new() end
	end)
end

function TrailApplyColor(trail, col)
	trail.Color = ColorSequence.new(col)
	trail.LightEmission = ((col.R + col.G + col.B) < 0.05) and 0 or 0.8
end

local function setupCharacter(char)
	task.wait(0.5); if not char then return end
	local hum=char:WaitForChild("Humanoid",5)
	local root=char:WaitForChild("HumanoidRootPart",5) or char:WaitForChild("Torso",5)
	if not hum or not root then return end

	HJ.saved = nil
	if highJumpEnabled then HJ_Apply(hum, true) end

	for _,n in ipairs({"TrailBottom","TrailTop","vizerFireTrail"}) do
		local v=root:FindFirstChild(n); if v then v:Destroy() end
	end
	local attBot=Instance.new("Attachment",root); attBot.Name="TrailBottom"; attBot.Position=Vector3.new(0,-2.5,0)
	local attTop=Instance.new("Attachment",root); attTop.Name="TrailTop";    attTop.Position=Vector3.new(0,1.5,0)

	currentFireTrail=Instance.new("Trail",root)
	currentFireTrail.Name="vizerFireTrail"; currentFireTrail.Attachment0=attBot; currentFireTrail.Attachment1=attTop
	currentFireTrail.Texture="rbxassetid://89925832"; currentFireTrail.TextureMode=Enum.TextureMode.Stretch
	currentFireTrail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
	currentFireTrail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
	currentFireTrail.Lifetime=1.5
	TrailApplyColor(currentFireTrail, EffectColors.FireTrail)
	currentFireTrail.Enabled=fireTrailEnabled

	if headlessEnabled then
		local head = char:FindFirstChild("Head")
		if head then head.LocalTransparencyModifier = 1 end
	end
end

if player.Character then task.spawn(setupCharacter,player.Character) end
player.CharacterAdded:Connect(setupCharacter)

function ApplyFreecam(state)
	MISC.fcOn = state
	local cas = game:GetService("ContextActionService")
	pcall(function() RunService:UnbindFromRenderStep("vizerFreecam") end)
	pcall(function() cas:UnbindAction("vizerFreecamSink") end)
	if MISC.fcInput then MISC.fcInput:Disconnect(); MISC.fcInput = nil end

	local cam = workspace.CurrentCamera
	if state and cam then
		MISC.fcSaved = {Type = cam.CameraType, Subject = cam.CameraSubject}
		local rx, ry = cam.CFrame:ToOrientation()
		MISC.fcPitch, MISC.fcYaw = rx, ry
		MISC.fcPos = cam.CFrame.Position
		cam.CameraType = Enum.CameraType.Scriptable

		local K = Enum.KeyCode
		cas:BindActionAtPriority("vizerFreecamSink", function() return Enum.ContextActionResult.Sink end,
		false, Enum.ContextActionPriority.High.Value + 1,
		K.W, K.A, K.S, K.D, K.Q, K.E, K.Space, K.LeftShift, K.LeftControl)

		MISC.fcInput = UIS.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement
				and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				MISC.fcYaw = MISC.fcYaw - input.Delta.X * 0.004
				MISC.fcPitch = math.clamp(MISC.fcPitch - input.Delta.Y * 0.004, -1.5, 1.5)
			end
		end)

		RunService:BindToRenderStep("vizerFreecam", Enum.RenderPriority.Camera.Value + 2, function(dt)
			local c = workspace.CurrentCamera
			if not c then return end
			if c.CameraType ~= Enum.CameraType.Scriptable then c.CameraType = Enum.CameraType.Scriptable end

			local move = Vector3.new()
			if not UIS:GetFocusedTextBox() then
				if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -1, 0) end
			end
			local rot = CFrame.fromOrientation(MISC.fcPitch, MISC.fcYaw, 0)
			if move.Magnitude > 0 then
				local spd = MISC.fcSpeed * (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 3 or 1)
				MISC.fcPos = MISC.fcPos + rot:VectorToWorldSpace(move.Unit) * spd * dt
			end
			c.CFrame = CFrame.new(MISC.fcPos) * rot
			c.Focus = c.CFrame
		end)
	elseif cam and MISC.fcSaved then
		cam.CameraType = MISC.fcSaved.Type or Enum.CameraType.Custom
		local h = MV.hum()
		if h then cam.CameraSubject = h end
		MISC.fcSaved = nil
	end

	UpdateToggleVisual("Freecam", state)
end

function MISC.espColorFor(plr)
	if MISC.fespOn and MISC.isFriend and MISC.isFriend(plr) then return EffectColors.FriendESP end
	if MISC.espOn then return EffectColors.ESP end
	return nil
end

function MISC.espClear(plr)
	local h = MISC.espMap[plr]
	if h then h:Destroy() end
	MISC.espMap[plr] = nil
end

function MISC.espAttach(plr)
	if plr == player then return end
	local col = MISC.espColorFor(plr)
	local char = plr.Character
	if not col or not char or not char.Parent then
		MISC.espClear(plr)
		return
	end
	local h = MISC.espMap[plr]
	if h and h.Parent == char then
		if h.OutlineColor ~= col then h.OutlineColor = col; h.FillColor = col end
		return
	end
	if h then h:Destroy() end
	h = Instance.new("Highlight")
	h.Name = "vizerESP"
	h.Adornee = char
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.FillColor = col
	h.OutlineColor = col
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = char
	MISC.espMap[plr] = h
end

function MISC.espHook(plr)
	if plr == player or MISC.espConns[plr] then return end
	local list = {}
	list[1] = plr.CharacterAdded:Connect(function()
		task.defer(function()
			if MISC.espOn or MISC.fespOn then MISC.espAttach(plr) end
		end)
	end)
	list[2] = plr.CharacterRemoving:Connect(function() MISC.espClear(plr) end)
	MISC.espConns[plr] = list
	MISC.espAttach(plr)
end

function MISC.espUnhook(plr)
	local list = MISC.espConns[plr]
	if list then for _, cn in ipairs(list) do cn:Disconnect() end end
	MISC.espConns[plr] = nil
	MISC.espClear(plr)
end

function MISC.espRefresh()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and MISC.espConns[plr] then MISC.espAttach(plr) end
	end
end

function MISC.espSync()
	local need = MISC.espOn or MISC.fespOn
	if need and not MISC.espWatch then
		for _, plr in ipairs(Players:GetPlayers()) do MISC.espHook(plr) end
		MISC.espAdded = Players.PlayerAdded:Connect(function(plr) MISC.espHook(plr) end)
		MISC.espRemoving = Players.PlayerRemoving:Connect(function(plr) MISC.espUnhook(plr) end)

		local acc = 0
		MISC.espWatch = RunService.Heartbeat:Connect(function(dt)
			acc = acc + dt
			if acc < 0.5 then return end
			acc = 0
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player then
					if not MISC.espConns[plr] then MISC.espHook(plr) end
					MISC.espAttach(plr)
				end
			end
			for plr in pairs(MISC.espMap) do
				if not plr.Parent then MISC.espUnhook(plr) end
			end
		end)
	elseif not need and MISC.espWatch then
		MISC.espWatch:Disconnect(); MISC.espWatch = nil
		if MISC.espAdded then MISC.espAdded:Disconnect(); MISC.espAdded = nil end
		if MISC.espRemoving then MISC.espRemoving:Disconnect(); MISC.espRemoving = nil end
		for plr in pairs(MISC.espConns) do MISC.espUnhook(plr) end
		for plr in pairs(MISC.espMap) do MISC.espClear(plr) end
		for _, plr in ipairs(Players:GetPlayers()) do
			local ch = plr.Character
			local old = ch and ch:FindFirstChild("vizerESP")
			if old then old:Destroy() end
		end
	end
	if need then MISC.espRefresh() end
end

function ApplyESP(state)
	MISC.espOn = state
	MISC.espSync()
	UpdateToggleVisual("ESP", state)
end

function ApplyFriendESP(state)
	MISC.fespOn = state
	MISC.espSync()
	UpdateToggleVisual("FriendESP", state)
end

do
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")

	pcall(function()
		local raw = readfile and readfile("vizerVisitedServers.json")
		if raw then
			local list = HttpService:JSONDecode(raw)
			if type(list) == "table" then
				for _, id in ipairs(list) do MISC.visited[id] = true end
			end
		end
	end)
	MISC.visited[game.JobId] = true

	local function saveVisited()
		pcall(function()
			if not writefile then return end
			local list = {}
			for id in pairs(MISC.visited) do table.insert(list, id) end
			while #list > 300 do table.remove(list, 1) end
			writefile("vizerVisitedServers.json", HttpService:JSONEncode(list))
		end)
	end

	local function httpGet(url)
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok and type(res) == "string" and #res > 0 then return res end
		local req = (syn and syn.request) or (http and http.request) or http_request or request
		if req then
			local ok2, r = pcall(function() return req({Url = url, Method = "GET"}) end)
			if ok2 and r and r.Body then return r.Body end
		end
		return nil
	end

	function MISC.prepareTeleport()
		MISC.save()
		local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
		if not q then return false end
		local src
		if AUTOLOAD_URL ~= "" then
			src = 'loadstring(game:HttpGet("' .. AUTOLOAD_URL .. '"))()'
		else
			local has = false
			pcall(function() has = isfile and isfile(AUTOLOAD_FILE) end)
			if has then src = 'loadstring(readfile("' .. AUTOLOAD_FILE .. '"))()' end
		end
		if not src then return false end
		local ok = pcall(q, 'getgenv().vizerAutoStart = true\n' .. src)
		return ok
	end

	function MISC.rejoin()
		local queued = MISC.prepareTeleport()
		UI.notify(queued and "🔁 Rejoining the same server... (auto-reconnect on)"
			or "🔁 Rejoining... ⚠ autoload not set, run the script again")
		local conn
		conn = TeleportService.TeleportInitFailed:Connect(function()
			conn:Disconnect()
			pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
		end)
		task.delay(10, function() if conn then conn:Disconnect() end end)
		local ok = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
		if not ok then pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end
	end

	function MISC.serverHop()
		if MISC.hopping then return end
		MISC.hopping = true
		UI.notify("🔎 Searching for a new server...")
		task.spawn(function()
			local pick, failed
			local cursor = ""
			for page = 1, 5 do
				local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId)
					.. "/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100"
				if cursor ~= "" then url = url .. "&cursor=" .. cursor end
				local body = httpGet(url)
				if not body then failed = true; break end
				local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
				if not ok or type(data) ~= "table" or type(data.data) ~= "table" then failed = true; break end

				local cands = {}
				for _, s in ipairs(data.data) do
					if s.id ~= game.JobId and not MISC.visited[s.id]
						and s.playing and s.maxPlayers and s.playing < s.maxPlayers - 1 then
						table.insert(cands, s)
					end
				end
				if #cands > 0 then pick = cands[math.random(#cands)]; break end
				cursor = data.nextPageCursor or ""
				if cursor == "" then break end
			end

			if not pick then
				UI.notify(failed and "⚠ Can't load the server list (executor has no HTTP?)" or "⚠ No new servers found")
				MISC.hopping = false
				return
			end

			MISC.visited[pick.id] = true
			saveVisited()
			local queued = MISC.prepareTeleport()
			UI.notify(queued and ("🚀 Joining a new server (" .. tostring(pick.playing) .. " players)... auto-reconnect on")
				or "🚀 New server... ⚠ autoload not set, run the script again")
			pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player) end)
			task.delay(8, function() MISC.hopping = false end)
		end)
	end
	saveVisited()

	function MISC.joinVip()
		local link = MISC.vip or ""
		if link == "" then
			UI.notify("⚠ Paste your VIP server link in Misc → VIP link first")
			return
		end
		local url
		local shareCode = link:match("share%?code=(%w+)")
		if shareCode then
			url = "https://www.roblox.com/share?code=" .. shareCode .. "&type=Server"
		else
			local code = link:match("privateServerLinkCode=([%w%-_]+)") or link:match("linkCode=([%w%-_]+)")
			local place = link:match("games/(%d+)") or link:match("placeId=(%d+)")
			if not code and link:match("^[%w%-_]+$") and #link > 10 then code = link end
			if code then
				url = "https://www.roblox.com/games/" .. (place or tostring(game.PlaceId)) .. "?privateServerLinkCode=" .. code
			elseif link:match("^https?://") then
				url = link
			else
				UI.notify("⚠ That doesn't look like a Roblox link")
				return
			end
		end
		pcall(function() if setclipboard then setclipboard(url) end end)
		MISC.save()
		local opened = pcall(function() game:GetService("GuiService"):OpenBrowserWindow(url) end)
		UI.notify(opened and "👑 VIP link opened in browser — press Play" or "👑 VIP link copied — paste it in your browser and press Play")
	end
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local FULL = UDim2.new(1, 0, 1, 0)

	local hudGui = new("ScreenGui", {
		Name = "vizerHUD", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9990,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui"))
	local stack = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1,
	}, hudGui)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, stack)

	local hex = {name = "FFFFFF", val = "FFFFFF"}
	local function makePill(order)
		local f = new("Frame", {Size = UDim2.new(0, 116, 0, 30), BackgroundTransparency = 0.18, BorderSizePixel = 0,
			LayoutOrder = order, Visible = false}, stack)
		corner(f, 15)
		local s = stroke(f, Themes[1].Accent, 1.5, 0.1)
		local l = new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14,
			RichText = true, Text = ""}, f)
		return f, l, s
	end
	local fpsF, fpsL, fpsS = makePill(1)
	local pingF, pingL, pingS = makePill(2)
	local fpsV, pingV = 0, 0

	local function fmt(name, val)
		return string.format('<font color="#%s">%s</font>  <font color="#%s">%s</font>', hex.name, name, hex.val, tostring(val))
	end
	local function refresh()
		fpsL.Text = fmt("FPS", fpsV)
		pingL.Text = fmt("PING", tostring(pingV) .. "ms")
	end
	UI.bind(function(t)
		hex.name = t.Accent:ToHex(); hex.val = t.Text:ToHex()
		fpsF.BackgroundColor3 = t.Panel; pingF.BackgroundColor3 = t.Panel
		fpsS.Color = t.Accent; pingS.Color = t.Accent
		refresh()
	end)

	local function getPing()
		local ok, v = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
		if ok and v then return math.floor(v + 0.5) end
		return math.floor(player:GetNetworkPing() * 2000 + 0.5)
	end

	MISC.getPing = getPing

	local acc, frames = 0, 0
	RunService.Heartbeat:Connect(function(dt)
		frames = frames + 1; acc = acc + dt
		if acc < 0.5 then return end
		fpsV = math.floor(frames / acc + 0.5)
		frames = 0; acc = 0
		if MISC.pingOn then pingV = getPing() end
		if MISC.fpsOn or MISC.pingOn then refresh() end
	end)

	local function show(frame, state)
		frame.Visible = state
		if state then
			frame.BackgroundTransparency = 1
			tween(frame, 0.3, {BackgroundTransparency = 0.18})
		end
	end

	local stack2 = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 86), Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1,
	}, hudGui)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, stack2)

	local extras = {}
	local function addExtra(id, label, width, order, getter)
		local f = new("Frame", {Size = UDim2.new(0, width, 0, 30), BackgroundTransparency = 0.18, BorderSizePixel = 0,
			LayoutOrder = order, Visible = false}, stack2)
		corner(f, 15)
		local s = stroke(f, Themes[1].Accent, 1.5, 0.1)
		local l = new("TextLabel", {Size = FULL, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14,
			RichText = true, Text = ""}, f)
		extras[id] = {f = f, l = l, s = s, label = label, get = getter, on = false}
	end
	local function myRoot()
		local ch = player.Character
		return ch and ch:FindFirstChild("HumanoidRootPart")
	end
	addExtra("coords", "XYZ", 214, 1, function()
		local r = myRoot()
		if not r then return "—" end
		local p = r.Position
		return string.format("%.0f, %.0f, %.0f", p.X, p.Y, p.Z)
	end)
	addExtra("clock", "TIME", 126, 2, function() return os.date("%H:%M:%S") end)
	addExtra("players", "PLAYERS", 150, 3, function() return #Players:GetPlayers() .. "/" .. Players.MaxPlayers end)
	addExtra("speed", "SPEED", 132, 4, function()
		local r = myRoot()
		if not r then return "0" end
		local v = r.AssemblyLinearVelocity
		return string.format("%.0f", Vector3.new(v.X, 0, v.Z).Magnitude)
	end)

	local sessionStart = os.clock()
	local function hms(s)
		s = math.floor(s)
		return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor((s % 3600) / 60), s % 60)
	end
	addExtra("session", "PLAYED", 150, 5, function() return hms(os.clock() - sessionStart) end)
	addExtra("server", "SERVER", 150, 6, function() return hms(workspace.DistributedGameTime) end)

	local function refreshExtras()
		for _, e in pairs(extras) do
			if e.on then e.l.Text = fmt(e.label, e.get()) end
		end
	end
	UI.bind(function(t)
		for _, e in pairs(extras) do e.f.BackgroundColor3 = t.Panel; e.s.Color = t.Accent end
		refreshExtras()
	end)
	local eacc = 0
	RunService.Heartbeat:Connect(function(dt)
		eacc = eacc + dt
		if eacc < 0.15 then return end
		eacc = 0
		refreshExtras()
	end)
	function MISC.setExtra(id, state)
		local e = extras[id]
		if not e then return end
		e.on = state
		show(e.f, state)
		refreshExtras()
	end

	function ApplyFpsHud(state)
		MISC.fpsOn = state
		show(fpsF, state)
		refresh()
		UpdateToggleVisual("FpsHud", state)
	end

	function ApplyPingHud(state)
		MISC.pingOn = state
		if state then pingV = getPing() end
		show(pingF, state)
		refresh()
		UpdateToggleVisual("PingHud", state)
	end
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)
	local HttpService = game:GetService("HttpService")
	local DIR, INDEX = "vizerConfigs", "vizerConfigIndex.json"
	local mem, names = {}, {}

	local SLIDER_DEFS = {
		{"Speed: ", 16}, {"Fly speed", 50}, {"Freecam speed", 40}, {"UI volume", 50}, {"Anti-lag level", 2},
		{"Stretch", 70}, {"Motion blur", 50}, {"Ghost", 60}, {"Zoom power", 3}, {"Time of day", 12},
		{"Time lapse", 10}, {"Gravity", 60}, {"Spin speed", 20}, {"FPS cap", 144}, {"Tilt", 8},
		{"Blur size", 8}, {"Brightness", 15}, {"FOV lock", 70}, {"Jump power", 50},
		{"Shader strength", 70}, {"Exposure", 0}, {"Light range", 24}, {"Cloud cover", 60}, {"Music volume", 50},
		{"Hover distance", 19}, {"FOV: ", 70}, {"Pallet glow", 0}, {"Target ESP distance", 19},
	}
	local function defFor(prefix)
		for _, d in ipairs(SLIDER_DEFS) do
			if prefix:find(d[1], 1, true) then return d[2] end
		end
	end

	local function clean(n)
		n = tostring(n or ""):gsub("[^%w _%-]", "")
		n = n:gsub("^%s+", ""):gsub("%s+$", "")
		return n:sub(1, 30)
	end
	local function path(n) return DIR .. "/" .. n .. ".json" end

	local function loadIndex()
		names = {}
		pcall(function()
			if readfile and isfile and isfile(INDEX) then
				local l = HttpService:JSONDecode(readfile(INDEX))
				if type(l) == "table" then
					for _, n in ipairs(l) do if type(n) == "string" then table.insert(names, n) end end
				end
			end
		end)
		for n in pairs(mem) do
			local has = false
			for _, x in ipairs(names) do if x == n then has = true end end
			if not has then table.insert(names, n) end
		end
		table.sort(names, function(a, b) return a:lower() < b:lower() end)
	end
	local function saveIndex()
		pcall(function() if writefile then writefile(INDEX, HttpService:JSONEncode(names)) end end)
	end
	local function writeCfg(n, data)
		local json = HttpService:JSONEncode(data)
		mem[n] = json
		pcall(function()
			if writefile then
				if makefolder and isfolder and not isfolder(DIR) then makefolder(DIR) end
				writefile(path(n), json)
			end
		end)
	end
	local function readCfg(n)
		local json = mem[n]
		if not json then
			pcall(function()
				if readfile and isfile and isfile(path(n)) then json = readfile(path(n)) end
			end)
		end
		if not json then return nil end
		local ok, d = pcall(function() return HttpService:JSONDecode(json) end)
		if ok and type(d) == "table" then return d end
	end

	function MISC.collectConfig()
		local on, keys, colors, sliders = {}, {}, {}, {}
		for id, r in pairs(UI.rows) do
			if r.state and not r.feat.Button and id ~= "Freecam" and id ~= "UISounds" and id ~= "MenuAnim" and id ~= "ZoomKey" then
				table.insert(on, id)
			end
			if r.feat.Key then keys[id] = r.feat.Key.Name end
		end
		for k, v in pairs(EffectColors) do
			colors[k] = {math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)}
		end
		for _, s in ipairs(UI.sliders or {}) do sliders[s.prefix] = s.value end
		return {v = 1, on = on, keys = keys, colors = colors, sliders = sliders, theme = currentTheme,
			fog = FOG.t, smooth = CSM.level, soundOff = UISnd.off or false}
	end

	function MISC.resetAll(silent)
		for _, feat in ipairs(UI.feats) do
			local r = UI.rows[feat.Id]
			if r and r.state and not feat.Button and feat.Id ~= "UISounds" and feat.Id ~= "MenuAnim" then pcall(feat.Toggle) end
		end
		local ru, rm = UI.rows.UISounds, UI.rows.MenuAnim
		if ru and UISnd.off then pcall(ru.feat.Toggle) end
		if rm and MISC.animOff then pcall(rm.feat.Toggle) end
		if MISC.map then
			for _, def in ipairs(MISC.map.list) do
				if def.isOn and def.isOn() then pcall(def.toggleNow) end
			end
		end
		for _, s in ipairs(UI.sliders or {}) do
			local d = defFor(s.prefix)
			if d ~= nil then s.set(d) end
		end
		for k, c in pairs(EffectDefaults) do
			EffectColors[k] = c
			if UI.colorSetters and UI.colorSetters[k] then UI.colorSetters[k](c) end
			if UI.liveColor then pcall(UI.liveColor, k, c) end
		end
		if MISC.setFogT then MISC.setFogT(0.4) end
		if UI.setSmooth then UI.setSmooth(3) end
		for _, feat in ipairs(UI.feats) do
			feat.Key = feat.DefKey
			local r = UI.rows[feat.Id]
			if r then r.updateSub() end
		end
		currentTheme = 1
		ApplyThemeToAll()
		MISC.dirty()
		if not silent then UI.notify("♻ Everything was reset") end
	end

	function MISC.applyConfig(d)
		if type(d) ~= "table" then UI.notify("⚠ Bad config"); return end
		MISC.resetAll(true)
		if type(d.sliders) == "table" then
			for _, s in ipairs(UI.sliders or {}) do
				local v = d.sliders[s.prefix]
				if type(v) == "number" then s.set(v) end
			end
		end
		if type(d.colors) == "table" then
			for k, v in pairs(d.colors) do
				if EffectColors[k] and type(v) == "table" then
					local c = Color3.fromRGB(v[1] or 255, v[2] or 255, v[3] or 255)
					EffectColors[k] = c
					if UI.colorSetters and UI.colorSetters[k] then UI.colorSetters[k](c) end
					if UI.liveColor then pcall(UI.liveColor, k, c) end
				end
			end
		end
		if type(d.fog) == "number" and MISC.setFogT then MISC.setFogT(math.clamp(d.fog, 0, 1)) end
		if type(d.smooth) == "number" and UI.setSmooth then UI.setSmooth(d.smooth) end
		if type(d.keys) == "table" then
			for id, name in pairs(d.keys) do
				local r = UI.rows[id]
				local ok, kc = pcall(function() return Enum.KeyCode[name] end)
				if r and ok and kc then r.feat.Key = kc; r.updateSub() end
			end
		end
		if Themes[d.theme or 0] then currentTheme = d.theme; ApplyThemeToAll() end
		if d.soundOff == true and not UISnd.off and UI.rows.UISounds then pcall(UI.rows.UISounds.feat.Toggle) end
		for _, id in ipairs(d.on or {}) do
			local r = UI.rows[id]
			if r and not r.state and not r.feat.Button then pcall(r.feat.Toggle) end
		end
		MISC.dirty()
	end

	local accentBtns = {}
	UI.bind(function(t) for _, b in ipairs(accentBtns) do b.BackgroundColor3 = t.On end end)

	local function mkBtn(parent, text, offsetX, y, w, color, fn)
		local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offsetX, 0, y),
			Size = UDim2.new(0, w, 0, 28), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
			AutoButtonColor = false, BackgroundColor3 = color or Themes[currentTheme].On, BackgroundTransparency = 0.2, ZIndex = 14}, parent)
		corner(b, 8)
		if not color and parent.Name == "CfgStatic" then table.insert(accentBtns, b) end
		b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
		b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
		b.MouseButton1Click:Connect(function() PlayUISound(SND.click, 0.45, 1.15); fn() end)
		return b
	end
	local function mkBox(parent, pos, size, placeholder)
		local box = new("TextBox", {Position = pos, Size = size, BackgroundTransparency = 0.35, Text = "", PlaceholderText = placeholder,
			Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14}, parent)
		corner(box, 8)
		new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
		local bs = stroke(box, Themes[1].Accent, 1, 0.55)
		UI.bind(function(t)
			box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub; bs.Color = t.Accent
		end)
		box.Focused:Connect(function() tween(bs, 0.2, {Transparency = 0}) end)
		box.FocusLost:Connect(function() tween(bs, 0.2, {Transparency = 0.55}) end)
		return box
	end
	local function mkLabel(parent, text, pos, size)
		local l = new("TextLabel", {Position = pos, Size = size, BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold,
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, parent)
		UI.bind(function(t) l.TextColor3 = t.Text end)
		return l
	end

	UI.section("Settings", "💾  Config manager")

	local nameRow = UI.fullRow("Settings", 52)
	nameRow.Name = "CfgStatic"
	local nameBox = mkBox(nameRow, UDim2.new(0, 12, 0, 11), UDim2.new(1, -112, 0, 30), "Config name")

	local pd = UI.pdata.Settings; pd.grid = nil
	local holder = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = pd.order}, UI.pages.Settings)
	pd.order = pd.order + 1
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, holder)

	local refreshList
	local function doSave()
		local n = clean(nameBox.Text)
		if n == "" then UI.notify("⚠ Enter a config name first"); return end
		writeCfg(n, MISC.collectConfig())
		local has = false
		for _, x in ipairs(names) do if x == n then has = true end end
		if not has then table.insert(names, n); table.sort(names, function(a, b) return a:lower() < b:lower() end) end
		saveIndex()
		refreshList()
		UI.notify("💾 Config '" .. n .. "' saved")
	end
	mkBtn(nameRow, "💾 Save", -12, 26, 88, nil, doSave)
	nameBox.FocusLost:Connect(function(enter) if enter then doSave() end end)

	refreshList = function()
		for _, c in ipairs(holder:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		local th = Themes[currentTheme]
		if #names == 0 then
			new("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 1,
				Text = "No saved configs yet — type a name and press Save", Font = Enum.Font.GothamMedium, TextSize = 12,
				TextColor3 = th.Sub}, holder)
			return
		end
		for i, n in ipairs(names) do
			local row = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = th.Row, BackgroundTransparency = 0.3,
				BorderSizePixel = 0, LayoutOrder = i}, holder)
			corner(row, 12)
			stroke(row, th.Accent, 1, 0.75)
			new("TextLabel", {Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -190, 1, 0), BackgroundTransparency = 1,
				Text = "💾  " .. n, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = th.Text,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
			mkBtn(row, "🗑", -10, 20, 36, Color3.fromRGB(190, 70, 90), function()
				mem[n] = nil
				for k, x in ipairs(names) do if x == n then table.remove(names, k) break end end
				pcall(function() if delfile and isfile and isfile(path(n)) then delfile(path(n)) end end)
				saveIndex()
				refreshList()
				UI.notify("🗑 Config '" .. n .. "' deleted")
			end)
			mkBtn(row, "Load", -54, 20, 70, th.On, function()
				local d = readCfg(n)
				if not d then UI.notify("⚠ Config file not found"); return end
				MISC.applyConfig(d)
				UI.notify("✓ Config '" .. n .. "' loaded")
			end)
		end
	end
	loadIndex()
	UI.bind(function() refreshList() end)

	local exRow = UI.fullRow("Settings", 84)
	exRow.Name = "CfgStatic"
	mkLabel(exRow, "📤  Share: Export copies your settings, paste a friend's text and press Import", UDim2.new(0, 12, 0, 6), UDim2.new(1, -20, 0, 22))
	local exBox = mkBox(exRow, UDim2.new(0, 12, 0, 34), UDim2.new(1, -184, 0, 30), "Config text")
	mkBtn(exRow, "📥 Import", -12, 49, 80, nil, function()
		local ok, d = pcall(function() return HttpService:JSONDecode(exBox.Text) end)
		if not ok or type(d) ~= "table" then UI.notify("⚠ That is not a valid config text"); return end
		MISC.applyConfig(d)
		UI.notify("✓ Config imported")
	end)
	mkBtn(exRow, "📤 Export", -98, 49, 80, nil, function()
		local json = HttpService:JSONEncode(MISC.collectConfig())
		exBox.Text = json
		if setclipboard then pcall(setclipboard, json); UI.notify("📤 Config copied to clipboard") else UI.notify("📤 Config text is in the box — copy it") end
	end)

	local rsRow = UI.fullRow("Settings", 52)
	rsRow.Name = "CfgStatic"
	mkLabel(rsRow, "♻  Reset all: turns everything off and restores defaults", UDim2.new(0, 12, 0, 0), UDim2.new(1, -190, 1, 0))
	local rsBtn, armed, token = nil, false, 0
	rsBtn = mkBtn(rsRow, "♻ Reset all", -12, 26, 150, Color3.fromRGB(190, 70, 90), function()
		if not armed then
			armed = true; token = token + 1
			local my = token
			rsBtn.Text = "Click again to confirm"
			task.delay(4, function()
				if token == my and armed then armed = false; rsBtn.Text = "♻ Reset all" end
			end)
		else
			armed = false; token = token + 1
			rsBtn.Text = "♻ Reset all"
			MISC.resetAll()
		end
	end)
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)
	local FULL  = UDim2.new(1, 0, 1, 0)

	UI.section("Settings", "🔊  Interface")
	UI.add({Tab = "Settings", Id = "UISounds", Name = "UI sounds", Sub = "Clicks & effects", Icon = "🔊",
		Toggle = function()
			UISnd.off = not UISnd.off
			UpdateToggleVisual("UISounds", not UISnd.off)
		end})
	UI.add({Tab = "Settings", Id = "MenuAnim", Name = "Menu animations", Sub = "Turn off for more FPS", Icon = "✨",
		Toggle = function()
			MISC.animOff = not MISC.animOff
			UI.applyAnim()
			UpdateToggleVisual("MenuAnim", not MISC.animOff)
		end})
	UpdateToggleVisual("UISounds", not UISnd.off)
	UpdateToggleVisual("MenuAnim", not MISC.animOff)
	UI.sliderRow("Settings", "🔊  UI volume: ", 0, 100, UISnd.vol or 50, function(v) UISnd.vol = v; UISnd.gain = v / 100 * 7 end)
	UI.infoRow("Settings", "💡  Right-click a feature to change its hotkey")

	UI.section("Settings", "🖼  Menu image")
	do
		local row = UI.fullRow("Settings", 84)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 12, 0, 6),
			Text = "🖼  Paste an image ID", Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		local status = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 12, 0, 62),
			Text = "", Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		local box = new("TextBox", {Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -170, 0, 30),
			BackgroundTransparency = 0.35, Text = "", PlaceholderText = "rbxassetid://... or just the number",
			Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 14}, row)
		corner(box, 8)
		new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
		local boxStroke = stroke(box, Themes[1].Accent, 1, 0.55)
		UI.bind(function(t)
			lbl.TextColor3 = t.Text; status.TextColor3 = t.Sub
			box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub
			boxStroke.Color = t.Accent
		end)
		box.Focused:Connect(function() tween(boxStroke, 0.2, {Transparency = 0}) end)
		box.FocusLost:Connect(function() tween(boxStroke, 0.2, {Transparency = 0.55}) end)

		local function setStatus(text, col)
			status.Text = text
			if col then status.TextColor3 = col end
		end

		local function applyImage(id)
			local img = UI.artImage
			if not img then return end
			img.Image = "rbxassetid://" .. id
			setStatus("⏳ Loading...", nil)
			task.delay(2, function()
				if img.Image ~= "rbxassetid://" .. id then return end
				if img.IsLoaded then
					setStatus("✓ Image applied", Color3.fromRGB(110, 230, 150))
				else
					setStatus("⚠ Not loaded — use an Image ID (not Decal)", Color3.fromRGB(255, 190, 110))
				end
			end)
		end

		local function Btn(text, offsetX, w, onClick)
			local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, offsetX, 0, 30),
				Size = UDim2.new(0, w, 0, 30), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
				AutoButtonColor = false, BackgroundTransparency = 0.2, ZIndex = 14}, row)
			corner(b, 8)
			UI.bind(function(t) b.BackgroundColor3 = t.On end)
			b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
			b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
			b.MouseButton1Click:Connect(function()
				PlayUISound(SND.click, 0.45, 1.15)
				onClick()
			end)
		end
		Btn("Apply", -12, 64, function()
			local id = string.match(box.Text, "%d+")
			if not id then
				setStatus("⚠ Enter an image ID (numbers)", Color3.fromRGB(255, 190, 110))
				return
			end
			applyImage(id)
			MISC.dirty()
		end)
		Btn("Reset", -82, 64, function()
			if UI.artImage then UI.artImage.Image = GIRL_IMAGE end
			box.Text = ""
			setStatus("↺ Default image restored", nil)
			MISC.dirty()
		end)
	end

	UI.section("Settings", "🎨  Theme")
	for i, thm in ipairs(Themes) do
		local row = UI.fullRow("Settings", 44)
		for j, col in ipairs({thm.Bg, thm.Accent, thm.Accent2, thm.On}) do
			local dot = new("Frame", {Position = UDim2.new(0, 12 + (j - 1) * 22, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 6}, row)
			corner(dot, 8); stroke(dot, WHITE, 1, 0.6)
		end
		local nameLbl = new("TextLabel", {Position = UDim2.new(0, 112, 0, 0), Size = UDim2.new(1, -170, 1, 0), BackgroundTransparency = 1,
			Text = thm.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(240, 232, 255),
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, row)
		UI.bind(function(t) nameLbl.TextColor3 = t.Text end)
		local check = new("TextLabel", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold,
			TextSize = 18, TextColor3 = Color3.fromRGB(110, 230, 150), ZIndex = 6}, row)
		local btn = new("TextButton", {Size = FULL, BackgroundTransparency = 1, Text = "", ZIndex = 9}, row)
		btn.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.45, 1.1)
			currentTheme = i
			MISC.dirty()
			ApplyThemeToAll()
		end)
		UI.bind(function() check.Visible = (currentTheme == i) end)
	end

	UI.section("Settings", "🌈  Effect colors")

	local ColorableEffects = {
		{Key="Petals",      Label="vizer", White=true},
		{Key="Fog",         Label="Fog", White=true},
		{Key="Snow",        Label="Snow", White=true},
		{Key="Summer",      Label="Summer Lovin", NoBlack=true, White=true},
		{Key="Cloud",       Label="Cloud", White=true},
		{Key="ESP",         Label="ESP outline", White=true},
		{Key="FriendESP",   Label="Friend ESP outline", White=true},
		{Key="Ambient",     Label="Ambient light", White=true},
		{Key="Tint",        Label="Color tint", White=true},

	}

	local function LiveUpdateEffectColor(key, col)
		if key == "FireTrail" and currentFireTrail then
			TrailApplyColor(currentFireTrail, col)
		elseif key == "Fog" and FOG.on then
			Lighting.FogColor = col
		elseif key == "Snow" then
			SN.color(col)
		elseif key == "Summer" and SummerApplyColor then
			SummerApplyColor(col)
		elseif key == "Cloud" and CloudApplyColor then
			CloudApplyColor(col)
		elseif key == "ESP" or key == "FriendESP" then
			MISC.espRefresh()
		elseif XColorUpdate then
			XColorUpdate(key, col)
		end
	end

	local function MakeHueSlider(parent, y, initColor, onChange, noBlack, withWhite)
		local ZB = noBlack and 0 or 0.1
		local ZW = withWhite and 0.1 or 0
		local hueEnd = 1 - ZW
		local BLACK = Color3.new(0, 0, 0)
		local BAR_H = 14
		local GAP = 8
		local EXTRA = 26

		local function relToColor(rel)
			if rel < ZB then return BLACK end
			if rel > hueEnd then return WHITE end
			return Color3.fromHSV((rel - ZB) / (hueEnd - ZB), 1, 1)
		end

		local function relFromColor(col)
			local h, sat, val = col:ToHSV()
			if ZB > 0 and (col.R + col.G + col.B) < 0.05 then
				return ZB / 2
			elseif ZW > 0 and sat < 0.2 and val > 0.5 then
				return 1 - ZW / 2
			end
			return math.clamp(ZB + h * (hueEnd - ZB), ZB, hueEnd)
		end

		local function shade(col, br)
			if br < 0.5 then
				return col:Lerp(BLACK, 1 - br * 2)
			end
			return col:Lerp(WHITE, (br - 0.5) * 2)
		end

		local function invert(col, baseCol)
			local _, s, v = col:ToHSV()
			if (baseCol.R + baseCol.G + baseCol.B) < 0.05 then
				return math.clamp(0.5 + v * 0.5, 0.5, 1)
			end
			local _, bs = baseCol:ToHSV()
			if bs < 0.2 or v < 0.999 then
				return math.clamp(v * 0.5, 0, 0.5)
			end
			return math.clamp(0.5 + (1 - s) * 0.5, 0.5, 1)
		end

		local initRel = relFromColor(initColor)

		local track = new("Frame", {Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, y),
			BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 14, Active = true}, parent)
		corner(track, 10)

		local keys = {}
		local startT = 0
		if ZB > 0 then
			table.insert(keys, ColorSequenceKeypoint.new(0, BLACK))
			table.insert(keys, ColorSequenceKeypoint.new(ZB, BLACK))
			startT = ZB + 0.001
		end
		for k = 0, 6 do
			local t = (k == 6) and hueEnd or (startT + (k / 6) * (hueEnd - startT))
			table.insert(keys, ColorSequenceKeypoint.new(t, Color3.fromHSV(k / 6, 1, 1)))
		end
		if ZW > 0 then
			table.insert(keys, ColorSequenceKeypoint.new(hueEnd + 0.001, WHITE))
			table.insert(keys, ColorSequenceKeypoint.new(1, WHITE))
		end
		new("UIGradient", {Color = ColorSequence.new(keys)}, track)
		stroke(track, WHITE, 1, 0.6)

		local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 28), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(initRel, 0, 0.5, 0), BackgroundColor3 = relToColor(initRel),
			BorderSizePixel = 0, ZIndex = 16}, track)
		corner(knob, 5)
		local knobStroke = stroke(knob, WHITE, 2, 0)

		local function paintKnob(col)
			knob.BackgroundColor3 = col
			knobStroke.Color = ((col.R + col.G + col.B) > 2.9) and Color3.fromRGB(50, 50, 50) or WHITE
		end
		paintKnob(relToColor(initRel))

		local limit = y + 20
		local bar = new("Frame", {Size = UDim2.new(1, -24, 0, BAR_H), Position = UDim2.new(0, 12, 0, limit + GAP),
			BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 14, Active = true}, parent)
		corner(bar, 7)
		local barGrad = new("UIGradient", {}, bar)
		stroke(bar, WHITE, 1, 0.6)
		new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "Brightness",
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = WHITE, TextStrokeColor3 = BLACK,
			TextStrokeTransparency = 0.4, ZIndex = 15}, bar)
		local barKnob = new("Frame", {Size = UDim2.new(0, 14, 0, 22), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 16}, bar)
		corner(barKnob, 5)
		local barKnobStroke = stroke(barKnob, WHITE, 2, 0)

		local b = invert(initColor, relToColor(initRel))
		local lastOut = nil
		local dragging = false
		local barDrag = false

		local function paintBar()
			local c = knob.BackgroundColor3
			barGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, BLACK),
				ColorSequenceKeypoint.new(0.5, c),
				ColorSequenceKeypoint.new(1, WHITE),
			})
			local s = shade(c, b)
			barKnob.BackgroundColor3 = s
			barKnobStroke.Color = ((s.R + s.G + s.B) > 2.9) and Color3.fromRGB(50, 50, 50) or WHITE
			barKnob.Position = UDim2.new(b, 0, 0.5, 0)
		end
		paintBar()

		local function emit(col)
			lastOut = col
			onChange(col)
		end

		local function setFromX(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local col = relToColor(rel)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			paintKnob(col)
			paintBar()
			emit(shade(col, b))
		end

		local function setFromBarX(x)
			b = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			paintBar()
			emit(shade(knob.BackgroundColor3, b))
		end

		local function isPress(input)
			return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
		end

		local function isMove(input)
			return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
		end

		track.InputBegan:Connect(function(input)
			if isPress(input) then
				dragging = true
				setFromX(input.Position.X)
			end
		end)
		bar.InputBegan:Connect(function(input)
			if isPress(input) then
				barDrag = true
				setFromBarX(input.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if not isMove(input) then return end
			if dragging then
				setFromX(input.Position.X)
			elseif barDrag then
				setFromBarX(input.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if isPress(input) then
				dragging = false
				barDrag = false
			end
		end)

		task.defer(function()
			local preview
			for _, c in ipairs(parent:GetChildren()) do
				if c ~= track and c ~= bar and c:IsA("GuiObject") and c.Position.Y.Scale == 0 and c.Position.Y.Offset >= limit - 1 then
					c.Position = UDim2.new(c.Position.X.Scale, c.Position.X.Offset, 0, c.Position.Y.Offset + EXTRA)
				end
				if c:IsA("Frame") and c ~= track and c ~= bar and c.Size.X.Offset == 22 and c.Size.Y.Offset == 22 then
					preview = c
				end
			end
			parent.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, parent.Size.Y.Scale, parent.Size.Y.Offset + EXTRA)
			if preview then
				preview:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
					if dragging or barDrag then return end
					if preview.BackgroundColor3 == lastOut then return end
					b = invert(preview.BackgroundColor3, knob.BackgroundColor3)
					paintBar()
				end)
			end
		end)

		return function(col)
			local rel = relFromColor(col)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			local bc = relToColor(rel)
			paintKnob(bc)
			b = invert(col, bc)
			paintBar()
		end
	end

	UI.hueSlider = MakeHueSlider

	UI.colorSetters = {}
	UI.liveColor = LiveUpdateEffectColor

	for _, eff in ipairs(ColorableEffects) do
		local row = UI.fullRow("Settings", 72)
		local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = EffectColors[eff.Key], BorderSizePixel = 0, ZIndex = 14}, row)
		corner(preview, 11); stroke(preview, WHITE, 1, 0.5)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = eff.Label, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)

		local setHue = MakeHueSlider(row, 40, EffectColors[eff.Key], function(col)
			EffectColors[eff.Key] = col
			MISC.dirty()
			preview.BackgroundColor3 = col
			LiveUpdateEffectColor(eff.Key, col)
		end, eff.NoBlack, eff.White)
		UI.colorSetters[eff.Key] = function(col) preview.BackgroundColor3 = col; setHue(col) end
	end

	do
		local row = UI.fullRow("Settings", 62)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 12, 0, 8),
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)

		local track = new("Frame", {Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 40),
			BackgroundColor3 = WHITE, BackgroundTransparency = 0.75, BorderSizePixel = 0, ZIndex = 14, Active = true}, row)
		corner(track, 5)
		UI.bind(function(t) track.BackgroundColor3 = t.Sub end)
		local fill = new("Frame", {BackgroundColor3 = Themes[1].Accent, BorderSizePixel = 0, ZIndex = 15}, track)
		corner(fill, 5)
		UI.bind(function(t) fill.BackgroundColor3 = t.Accent end)
		local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 22), AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 16}, track)
		corner(knob, 5)

		local function setT(rel)
			FOG.t = rel
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			lbl.Text = "🌫  Fog: transparency " .. math.floor(rel * 100 + 0.5) .. "%"
			MISC.dirty()
		end
		setT(FOG.t)
		MISC.setFogT = setT

		local dragging = false
		local function setFromX(x)
			setT(math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
		end
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true; setFromX(input.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)
	local GREEN = Color3.fromRGB(90, 235, 130)
	local CELL_W, CELL_H = 236, 24

	function MISC.isFriend(plr)
		return MISC.friends[plr.Name:lower()] ~= nil or MISC.friends[plr.DisplayName:lower()] ~= nil
	end

	local gui = new("ScreenGui", {Name = "vizerTabList", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9995,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, player:WaitForChild("PlayerGui"))
	local panel = new("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 48),
		Size = UDim2.new(0, 300, 0, 100), BackgroundTransparency = 0.18, BorderSizePixel = 0, Visible = false}, gui)
	corner(panel, 10)
	local pStroke = stroke(panel, Themes[1].Accent, 1.5, 0.15)
	local pScale = new("UIScale", {Scale = 1}, panel)

	local title = new("TextLabel", {Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
		Text = game.Name, Font = Enum.Font.GothamBold, TextSize = 15}, panel)
	local sub = new("TextLabel", {Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = "", Font = Enum.Font.Gotham, TextSize = 12}, panel)
	local line = new("Frame", {Position = UDim2.new(0, 12, 0, 50), Size = UDim2.new(1, -24, 0, 1), BorderSizePixel = 0}, panel)
	local grid = new("Frame", {Position = UDim2.new(0, 10, 0, 58), Size = UDim2.new(1, -20, 1, -66), BackgroundTransparency = 1}, panel)
	local layout = new("UIGridLayout", {CellSize = UDim2.new(0, CELL_W, 0, CELL_H), CellPadding = UDim2.new(0, 6, 0, 3),
		FillDirection = Enum.FillDirection.Vertical, FillDirectionMaxCells = 16, SortOrder = Enum.SortOrder.LayoutOrder}, grid)

	UI.bind(function(t)
		panel.BackgroundColor3 = t.Panel; pStroke.Color = t.Accent
		title.TextColor3 = t.Text; sub.TextColor3 = t.Sub; line.BackgroundColor3 = t.Accent
	end)
	task.spawn(function()
		local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
		if ok and info and info.Name then title.Text = info.Name end
	end)

	local entries = {}
	local function makeEntry(plr)
		local f = new("Frame", {BackgroundTransparency = 0.6, BorderSizePixel = 0}, grid)
		corner(f, 5)
		local icon = new("ImageLabel", {Position = UDim2.new(0, 4, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1}, f)
		corner(icon, 4)
		local nm = new("TextLabel", {Position = UDim2.new(0, 28, 0, 0), Size = UDim2.new(1, -92, 1, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Text = plr.Name}, f)
		local pg = new("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0), Size = UDim2.new(0, 58, 1, 0),
			BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Text = "—"}, f)
		local e = {frame = f, icon = icon, name = nm, ping = pg}
		entries[plr] = e
		task.spawn(function()
			local ok, img = pcall(function()
				return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok and img and icon.Parent then icon.Image = img end
		end)
		return e
	end

	local function pingOf(plr)
		if plr == player then return MISC.getPing and MISC.getPing() or nil end
		local v = plr:GetAttribute("Ping")
		if type(v) ~= "number" then
			local ls = plr:FindFirstChild("leaderstats")
			local pv = ls and (ls:FindFirstChild("Ping") or ls:FindFirstChild("ping"))
			v = pv and tonumber(pv.Value)
		end
		return v
	end

	local function update()
		local t = Themes[currentTheme]
		local list = Players:GetPlayers()
		table.sort(list, function(x, y)
			local fx, fy = MISC.isFriend(x), MISC.isFriend(y)
			if fx ~= fy then return fx end
			return x.Name:lower() < y.Name:lower()
		end)
		for plr, e in pairs(entries) do
			if not plr.Parent then e.frame:Destroy(); entries[plr] = nil end
		end
		local n = #list
		local per = math.max(16, math.ceil(n / 4))
		layout.FillDirectionMaxCells = per
		for i, plr in ipairs(list) do
			local e = entries[plr] or makeEntry(plr)
			e.frame.LayoutOrder = i
			e.frame.BackgroundColor3 = t.Row
			e.name.Text = plr.Name
			e.name.TextColor3 = MISC.isFriend(plr) and GREEN or (plr == player and t.Accent2 or t.Text)
			local pv = pingOf(plr)
			if pv then
				pv = math.floor(pv + 0.5)
				e.ping.Text = tostring(pv) .. "ms"
				e.ping.TextColor3 = pv < 80 and Color3.fromRGB(90, 235, 130) or (pv < 160 and Color3.fromRGB(255, 210, 90) or Color3.fromRGB(255, 90, 90))
			else
				e.ping.Text = "—"
				e.ping.TextColor3 = t.Sub
			end
		end
		sub.Text = "Online: " .. n .. " / " .. Players.MaxPlayers
		local rows = math.min(n, per)
		local cols = math.ceil(n / per)
		panel.Size = UDim2.new(0, cols * (CELL_W + 6) - 6 + 20, 0, 58 + rows * (CELL_H + 3) + 8)
	end

	local function show()
		if not MISC.tabOn then return end
		update()
		panel.Visible = true
		pScale.Scale = 0.94
		tween(pScale, 0.15, {Scale = 1}, Enum.EasingStyle.Back)
	end
	local function hide() panel.Visible = false end

	UIS.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab and not UIS:GetFocusedTextBox() then show() end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab then hide() end
	end)

	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		if not panel.Visible then return end
		acc = acc + dt
		if acc >= 0.5 then acc = 0; update() end
	end)
	Players.PlayerAdded:Connect(function() if panel.Visible then update() end end)
	Players.PlayerRemoving:Connect(function() task.defer(function() if panel.Visible then update() end end) end)

	function ApplyTabList(state)
		MISC.tabOn = state
		pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not state) end)
		if not state then hide() end
		UpdateToggleVisual("TabList", state)
	end

	UI.section("Player", "📋  Tab list")
	UI.add({Tab = "Player", Id = "TabList", Name = "Tab list", Sub = "Hold TAB: nicks & ping", Icon = "📋",
		Toggle = function() ApplyTabList(not MISC.tabOn) end})
	UI.infoRow("Player", "ℹ  Others' ping shows only if the game exposes it")

	UI.section("Misc", "👑  VIP server")
	local vipRow = UI.fullRow("Misc", 52)
	local vipBox = new("TextBox", {Position = UDim2.new(0, 12, 0, 11), Size = UDim2.new(1, -104, 0, 30), BackgroundTransparency = 0.35,
		Text = MISC.vip or "", PlaceholderText = "Paste your VIP server link", Font = Enum.Font.Gotham, TextSize = 12,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14}, vipRow)
	corner(vipBox, 8)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, vipBox)
	local vipStroke = stroke(vipBox, Themes[1].Accent, 1, 0.55)
	UI.bind(function(t)
		vipBox.BackgroundColor3 = t.Panel; vipBox.TextColor3 = t.Text; vipBox.PlaceholderColor3 = t.Sub; vipStroke.Color = t.Accent
	end)
	local vipSave = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 11), Size = UDim2.new(0, 72, 0, 30),
		Text = "Save", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, AutoButtonColor = false,
		BackgroundTransparency = 0.2, ZIndex = 14}, vipRow)
	corner(vipSave, 8)
	UI.bind(function(t) vipSave.BackgroundColor3 = t.On end)
	vipSave.MouseEnter:Connect(function() tween(vipSave, 0.15, {BackgroundTransparency = 0}) end)
	vipSave.MouseLeave:Connect(function() tween(vipSave, 0.15, {BackgroundTransparency = 0.2}) end)
	local function saveVip()
		local v = vipBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
		MISC.vip = v
		MISC.dirty()
		UI.notify(v == "" and "VIP link cleared" or "👑 VIP link saved")
	end
	vipSave.MouseButton1Click:Connect(function() PlayUISound(SND.click, 0.45, 1.15); saveVip() end)
	vipBox.FocusLost:Connect(function(enter) tween(vipStroke, 0.2, {Transparency = 0.55}); if enter then saveVip() end end)
	vipBox.Focused:Connect(function() tween(vipStroke, 0.2, {Transparency = 0}) end)

	UI.section("Player", "💚  Friends")
	local addRow = UI.fullRow("Player", 52)
	local box = new("TextBox", {Position = UDim2.new(0, 12, 0, 11), Size = UDim2.new(1, -104, 0, 30), BackgroundTransparency = 0.35,
		Text = "", PlaceholderText = "Friend's nickname", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, addRow)
	corner(box, 8)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
	local boxStroke = stroke(box, Themes[1].Accent, 1, 0.55)
	UI.bind(function(t)
		box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub; boxStroke.Color = t.Accent
	end)
	local addBtn = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 11), Size = UDim2.new(0, 72, 0, 30),
		Text = "Add", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, AutoButtonColor = false,
		BackgroundTransparency = 0.2, ZIndex = 14}, addRow)
	corner(addBtn, 8)
	UI.bind(function(t) addBtn.BackgroundColor3 = t.On end)
	addBtn.MouseEnter:Connect(function() tween(addBtn, 0.15, {BackgroundTransparency = 0}) end)
	addBtn.MouseLeave:Connect(function() tween(addBtn, 0.15, {BackgroundTransparency = 0.2}) end)

	local friendRows = {}
	local function addFriendRow(name)
		local key = name:lower()
		if friendRows[key] then return end
		local row = UI.fullRow("Player", 38)
		friendRows[key] = row
		new("TextLabel", {Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
			Text = "💚  " .. name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = GREEN,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14}, row)
		local rm = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 74, 0, 26),
			Text = "Remove", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = WHITE, AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(190, 70, 90), BackgroundTransparency = 0.2, ZIndex = 14}, row)
		corner(rm, 8)
		rm.MouseEnter:Connect(function() tween(rm, 0.15, {BackgroundTransparency = 0}) end)
		rm.MouseLeave:Connect(function() tween(rm, 0.15, {BackgroundTransparency = 0.2}) end)
		rm.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.45, 0.9)
			MISC.friends[key] = nil
			friendRows[key] = nil

			row:Destroy()
			UI.notify("Removed " .. name .. " from friends")
			MISC.dirty()
			MISC.espSync()
			if panel.Visible then update() end
		end)
	end

	local function addFriend(text)
		local name = text:gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then UI.notify("⚠ Enter a nickname first"); return end
		local key = name:lower()
		if MISC.friends[key] then UI.notify("⚠ " .. name .. " is already your friend"); return end
		MISC.friends[key] = name
		addFriendRow(name)
		box.Text = ""
		UI.notify("💚 " .. name .. " added to friends")
		MISC.dirty()
		MISC.espSync()
		if panel.Visible then update() end
	end
	addBtn.MouseButton1Click:Connect(function()
		PlayUISound(SND.click, 0.45, 1.15)
		addFriend(box.Text)
	end)
	box.FocusLost:Connect(function(enter)
		tween(boxStroke, 0.2, {Transparency = 0.55})
		if enter then addFriend(box.Text) end
	end)
	box.Focused:Connect(function() tween(boxStroke, 0.2, {Transparency = 0}) end)

	local sorted = {}
	for _, n in pairs(MISC.friends) do table.insert(sorted, n) end
	table.sort(sorted, function(x, y) return x:lower() < y:lower() end)
	for _, n in ipairs(sorted) do addFriendRow(n) end
end

do
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)

	function UI.idRow(tab, title, placeholder, onApply, onReset)
		local row = UI.fullRow(tab, 84)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 12, 0, 6),
			Text = title, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		local status = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 12, 0, 62),
			Text = "", Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		local box = new("TextBox", {Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -170, 0, 30),
			BackgroundTransparency = 0.35, Text = "", PlaceholderText = placeholder, Font = Enum.Font.Gotham, TextSize = 12,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		corner(box, 8)
		new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
		local boxStroke = stroke(box, Themes[1].Accent, 1, 0.55)
		UI.bind(function(t)
			lbl.TextColor3 = t.Text; status.TextColor3 = t.Sub
			box.BackgroundColor3 = t.Panel; box.TextColor3 = t.Text; box.PlaceholderColor3 = t.Sub
			boxStroke.Color = t.Accent
		end)
		box.Focused:Connect(function() tween(boxStroke, 0.2, {Transparency = 0}) end)
		box.FocusLost:Connect(function() tween(boxStroke, 0.2, {Transparency = 0.55}) end)

		local function Btn(text, offsetX, onClick)
			local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, offsetX, 0, 30),
				Size = UDim2.new(0, 64, 0, 30), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
				AutoButtonColor = false, BackgroundTransparency = 0.2, ZIndex = 14}, row)
			corner(b, 8)
			UI.bind(function(t) b.BackgroundColor3 = t.On end)
			b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
			b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
			b.MouseButton1Click:Connect(function()
				PlayUISound(SND.click, 0.45, 1.15)
				onClick()
			end)
		end
		local entry = {title = title, id = nil}
		UI.idList = UI.idList or {}
		table.insert(UI.idList, entry)
		function entry.set(id)
			box.Text = id
			entry.id = id
			status.Text = onApply(id) or "✓ Applied"
			status.TextColor3 = Color3.fromRGB(110, 230, 150)
		end
		function entry.clear()
			box.Text = ""
			entry.id = nil
			status.Text = onReset() or "↺ Default restored"
			status.TextColor3 = Color3.fromRGB(110, 230, 150)
		end
		Btn("Apply", -12, function()
			local id = string.match(box.Text, "%d+")
			if not id then
				status.Text = "⚠ Enter an image ID (numbers)"; status.TextColor3 = Color3.fromRGB(255, 190, 110)
				return
			end
			status.Text = onApply(id) or "✓ Applied"
			status.TextColor3 = Color3.fromRGB(110, 230, 150)
			entry.id = id
		end)
		Btn("Reset", -82, function()
			box.Text = ""
			status.Text = onReset() or "↺ Default restored"
			status.TextColor3 = Color3.fromRGB(110, 230, 150)
			entry.id = nil
		end)
	end

	local PAL = {name = "PalletLightBrown"}

	function MISC.palletTarget()
		local cam = workspace.CurrentCamera
		local look = cam.CFrame.LookVector
		local pitch = math.asin(look.Y)
		local alpha = math.clamp((-pitch) / (math.pi / 2), 0, 1)
		local off = -0.66 + alpha * (-14.9 - (-0.66))
		return cam.CFrame.Position + look * off, cam.CFrame
	end

	function MISC.spawnPallet()
		if os.clock() - (PAL.last or 0) < 0.2 then return end
		PAL.last = os.clock()
		if not player.Character then return end
		local pos, cf = MISC.palletTarget()
		local _, yaw = cf:ToOrientation()
		local newCFrame = cf.Rotation + pos
		local rot = Vector3.new(0, math.deg(yaw), 0)
		task.spawn(function()
			local ok, remote = pcall(function()
				return game:GetService("ReplicatedStorage"):WaitForChild("MenuToys", 1):WaitForChild("SpawnToyRemoteFunction", 1)
			end)
			if not ok or not remote then
				UI.notify("⚠ This game has no toy spawner")
				return
			end
			pcall(function() remote:InvokeServer(PAL.name, newCFrame, rot) end)
		end)
	end

	UI.section("Map", "🛠  Spawn Tools")

	UI.add({Tab = "Map", Id = "PalletSpawn", Name = "Spawn Pallet", Sub = "Press the key", Icon = "📦",
		Key = Enum.KeyCode.Q, Button = true, Toggle = function() MISC.spawnPallet() end})

	function MISC.spawnSafePallet()
		if not player.Character then return end
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		local cam = workspace.CurrentCamera
		if not root or not cam then return end

		local originalCFrame = cam.CFrame
		local _, origYaw = originalCFrame:ToOrientation()

		cam.CFrame = CFrame.new(root.Position + Vector3.new(0, 10, 0), root.Position)
		task.wait(0.15)

		local success = false
		local conn
		conn = workspace.DescendantAdded:Connect(function(desc)
			if not success and desc.Name == "PalletLightBrown" then
				success = true

				task.spawn(function()
					task.wait(0.1)

					local targetPos = root.Position - Vector3.new(0, 3, 0)
					local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(0, origYaw, 0)

					for _, part in ipairs(desc:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = false
							pcall(function() part:SetNetworkOwner(player) end)
						end
					end

					desc:PivotTo(targetCFrame)
					UI.notify("📦 Safe Pallet spawned")
					if conn then conn:Disconnect() end
				end)
			end
		end)

		task.spawn(function()
			local ok, remote = pcall(function()
				return game:GetService("ReplicatedStorage"):WaitForChild("MenuToys", 1):WaitForChild("SpawnToyRemoteFunction", 1)
			end)
			if ok and remote then
				pcall(function() remote:InvokeServer("PalletLightBrown", CFrame.new(root.Position), Vector3.new(0, math.deg(origYaw), 0)) end)
			else
				UI.notify("⚠ This game has no toy spawner")
				success = true
				if conn then conn:Disconnect() end
			end
		end)

		task.wait(0.5)
		cam.CFrame = originalCFrame

		task.delay(2, function() if conn then conn:Disconnect() end end)
	end

	UI.add({Tab = "Map", Id = "SpawnSafePallet", Name = "Safe Pallet", Sub = "Spawns pallet exactly under feet", Icon = "📦",
		Key = Enum.KeyCode.V, Button = true, Toggle = function() MISC.spawnSafePallet() end})

	function MISC.spawnFlyBug()
		if not player.Character then return end
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		local cam = workspace.CurrentCamera
		if not root or not cam then return end

		local originalCFrame = cam.CFrame
		local _, origYaw = originalCFrame:ToOrientation()

		cam.CFrame = CFrame.new(root.Position + Vector3.new(0, 10, 0), root.Position)
		task.wait(0.15)

		local success = false
		local conn
		conn = workspace.DescendantAdded:Connect(function(desc)
			if not success and desc.Name == "JapaneseShelf" then
				success = true

				task.spawn(function()
					task.wait(0.1)

					local targetPos = root.Position - Vector3.new(0, 3, 0)
					local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(0, origYaw, 0)

					for _, part in ipairs(desc:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = false
							pcall(function() part:SetNetworkOwner(player) end)
						end
					end

					desc:PivotTo(targetCFrame)
					UI.notify("🗄 Fly Bug spawned")
					if conn then conn:Disconnect() end
				end)
			end
		end)

		task.spawn(function()
			local ok, remote = pcall(function()
				return game:GetService("ReplicatedStorage"):WaitForChild("MenuToys", 1):WaitForChild("SpawnToyRemoteFunction", 1)
			end)
			if ok and remote then
				pcall(function() remote:InvokeServer("JapaneseShelf", CFrame.new(root.Position), Vector3.new(0, math.deg(origYaw), 0)) end)
			else
				UI.notify("⚠ This game has no toy spawner")
				success = true
				if conn then conn:Disconnect() end
			end
		end)

		task.wait(0.5)
		cam.CFrame = originalCFrame

		task.delay(2, function() if conn then conn:Disconnect() end end)
	end

	UI.add({Tab = "Map", Id = "SpawnFlyBug", Name = "Fly Bug", Sub = "Spawns shelf under feet", Icon = "🗄",
		Key = Enum.KeyCode.Z, Button = true, Toggle = function() MISC.spawnFlyBug() end})

	local S = MISC.spawn

	local function paintDecal(dec)
		if S.orig[dec] == nil then S.orig[dec] = dec.Texture end
		if dec.Texture ~= S.id then dec.Texture = S.id end
	end
	local function paintSpawn(sp)
		for _, ch in ipairs(sp:GetChildren()) do
			if ch:IsA("Decal") then paintDecal(ch) end
		end
	end

	function ApplySpawnDecal(state)
		S.on = state
		if S.conn then S.conn:Disconnect(); S.conn = nil end
		if S.watch then S.watch:Disconnect(); S.watch = nil end

		if state then
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if not S.on then return end
					if d:IsA("SpawnLocation") then paintSpawn(d) end
					n = n + 1
					if n % 4000 == 0 then task.wait() end
				end
			end)
			S.conn = workspace.DescendantAdded:Connect(function(d)
				if d:IsA("SpawnLocation") then
					task.delay(0.2, function() if S.on and d.Parent then paintSpawn(d) end end)
				elseif d:IsA("Decal") and d.Parent and d.Parent:IsA("SpawnLocation") then
					task.defer(function() if S.on and d.Parent then paintDecal(d) end end)
				end
			end)
			local acc = 0
			S.watch = RunService.Heartbeat:Connect(function(dt)
				acc = acc + dt
				if acc < 1 then return end
				acc = 0
				for dec in pairs(S.orig) do
					if dec.Parent and dec.Texture ~= S.id then dec.Texture = S.id end
				end
			end)
		else
			for dec, tex in pairs(S.orig) do
				if dec.Parent then dec.Texture = tex end
			end
			S.orig = setmetatable({}, {__mode = "k"})
		end
		UpdateToggleVisual("SpawnDecal", state)
	end

	UI.add({Tab = "Map", Id = "SpawnDecal", Name = "Spawn Decal", Sub = "Replace spawn picture", Icon = "🖼",
		Toggle = function() ApplySpawnDecal(not S.on) end})

	UI.idRow("Map", "🖼  Paste a spawn decal ID", "rbxassetid://... or just the number",
		function(id)
			S.id = "rbxassetid://" .. id
			MISC.dirty()
			ApplySpawnDecal(true)
			return "✓ Spawn decal applied"
		end,
		function()
			S.id = S.default
			MISC.dirty()
			if S.on then ApplySpawnDecal(true) end
			return "↺ Default spawn decal restored"
		end)

	do
		local EASE = Enum.EasingStyle
		local DIR  = Enum.EasingDirection
		local POP  = {}

		function UI.closePop(instant)
			local p = POP.cur
			if not p then return end
			POP.cur = nil
			for _, c in ipairs(p.conns) do c:Disconnect() end
			p.catcher:Destroy()
			if instant then p.frame:Destroy(); return end
			tween(p.frame, 0.16, {Size = UDim2.new(0, p.w, 0, 0)}, EASE.Quad, DIR.In)
			task.delay(0.2, function() p.frame:Destroy() end)
		end

		function UI.dropUp(anchor, items, current, onPick, cols, maxH)
			UI.closePop(true)
			local page   = anchor:FindFirstAncestorOfClass("ScrollingFrame")
			local holder = page and page.Parent
			if not holder then return end
			local sc = holder.AbsoluteSize.X / math.max(holder.Size.X.Offset, 1)
			if sc <= 0 then return end

			local relX = (anchor.AbsolutePosition.X - holder.AbsolutePosition.X) / sc
			local relY = (anchor.AbsolutePosition.Y - holder.AbsolutePosition.Y) / sc
			local aw   = anchor.AbsoluteSize.X / sc
			local ah   = anchor.AbsoluteSize.Y / sc
			local HH   = holder.AbsoluteSize.Y / sc

			cols = cols or 3
			local CELL_H, GAP, PAD = 28, 6, 8
			local rowsN = math.ceil(#items / cols)
			local want  = rowsN * (CELL_H + GAP) - GAP + PAD * 2
			local h     = math.min(want, maxH or 200)
			local above = relY - 6
			local below = HH - (relY + ah) - 6
			local up    = true
			if above < math.min(h, 120) and below > above then up = false end
			h = math.max(math.min(h, up and above or below), 60)

			local th = Themes[currentTheme]
			local catcher = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
				AutoButtonColor = false, Active = true, ZIndex = 40}, holder)
			local frame = new("Frame", {
				AnchorPoint = Vector2.new(0, up and 1 or 0),
				Position = UDim2.new(0, relX, 0, up and (relY - 4) or (relY + ah + 4)),
				Size = UDim2.new(0, aw, 0, 0),
				BackgroundColor3 = th.Panel, BackgroundTransparency = 0.04, BorderSizePixel = 0,
				ClipsDescendants = true, ZIndex = 50}, holder)
			corner(frame, 12)
			stroke(frame, th.Accent, 1.2, 0.3)

			local list = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
				ScrollBarThickness = 3, ScrollBarImageColor3 = th.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 51}, frame)
			new("UIPadding", {PaddingTop = UDim.new(0, PAD), PaddingBottom = UDim.new(0, PAD),
				PaddingLeft = UDim.new(0, PAD), PaddingRight = UDim.new(0, PAD)}, list)
			local cellW = math.floor((aw - PAD * 2 - 6 - GAP * (cols - 1)) / cols)
			new("UIGridLayout", {CellSize = UDim2.new(0, cellW, 0, CELL_H), CellPadding = UDim2.new(0, GAP, 0, GAP),
				SortOrder = Enum.SortOrder.LayoutOrder}, list)

			local selBtn
			for i, it in ipairs(items) do
				local sel = (it.value == current)
				local b = new("TextButton", {Text = it.text, Font = Enum.Font.GothamBold, TextSize = 11,
					TextColor3 = sel and WHITE or th.Text, BackgroundColor3 = sel and th.On or th.Row,
					BackgroundTransparency = sel and 0.05 or 0.3, AutoButtonColor = false, LayoutOrder = i,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 52}, list)
				corner(b, 8)
				if sel then selBtn = b end
				b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundTransparency = 0}) end)
				b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = sel and 0.05 or 0.3}) end)
				b.MouseButton1Click:Connect(function()
					PlayUISound(SND.click, 0.45, 1.2)
					UI.closePop()
					onPick(it.value, it.text)
				end)
			end

			local p = {catcher = catcher, frame = frame, w = aw, conns = {}}
			POP.cur = p
			table.insert(p.conns, page:GetPropertyChangedSignal("CanvasPosition"):Connect(function() UI.closePop(true) end))
			if UI.holder then
				table.insert(p.conns, UI.holder:GetPropertyChangedSignal("Visible"):Connect(function() UI.closePop(true) end))
			end
			catcher.MouseButton1Click:Connect(function() UI.closePop() end)

			tween(frame, 0.24, {Size = UDim2.new(0, aw, 0, h)}, EASE.Back, DIR.Out)
			if selBtn then
				task.defer(function()
					pcall(function() list.CanvasPosition = Vector2.new(0, math.max(selBtn.AbsolutePosition.Y - list.AbsolutePosition.Y - 40, 0)) end)
				end)
			end
		end

		function UI.pickRow(tab, label, items, getCurrent, onPick, cols, maxH)
			local row = UI.fullRow(tab, 46)
			local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 14, 0, 0),
				Text = label, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
			local btn = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0.58, -10, 0, 30), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
				TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14}, row)
			corner(btn, 8)
			local bs = stroke(btn, Themes[1].Accent, 1, 0.55)
			UI.bind(function(t) lbl.TextColor3 = t.Text; btn.BackgroundColor3 = t.Panel; btn.TextColor3 = t.Text; bs.Color = t.Accent end)
			local obj = {}
			function obj.refresh()
				local cur = getCurrent()
				for _, it in ipairs(items) do
					if it.value == cur then btn.Text = it.text .. "   ▲"; return end
				end
			end
			btn.MouseButton1Click:Connect(function()
				PlayUISound(SND.click, 0.45, 1.1)
				UI.dropUp(btn, items, getCurrent(), function(v) onPick(v); obj.refresh() end, cols, maxH)
			end)
			UI.pickList = UI.pickList or {}
			local nSame = 0
			for _, q in ipairs(UI.pickList) do
				if q.label == label then nSame = nSame + 1 end
			end
			table.insert(UI.pickList, {label = label, key = label .. "#" .. nSame, get = getCurrent,
				set = function(v) onPick(v); obj.refresh() end})
			obj.refresh()
			return obj
		end

		local origSwitch = UI.switch
		function UI.switch(name)
			UI.closePop(true)
			return origSwitch(name)
		end
	end

	local MAP = {index = {}, orig = setmetatable({}, {__mode = "k"}), color = {}, on = {}, term = {}}
	MISC.map = MAP
	MAP.mat = {}
	MAP.origMat = setmetatable({}, {__mode = "k"})

	local MAT_ICON = {
		Grass = "🌱", LeafyGrass = "🌿", Sand = "🏖", Sandstone = "🏜", Snow = "❄", Ice = "🧊", Glacier = "🏔",
		Wood = "🪵", WoodPlanks = "🪵", Brick = "🧱", Neon = "💡", Glass = "🪟", ForceField = "🔮", Metal = "⚙",
		CorrodedMetal = "🔩", DiamondPlate = "🔷", Foil = "✨", Rock = "🪨", Slate = "🪨", Basalt = "🪨",
		CrackedLava = "🌋", Mud = "🟤", Ground = "🟫", Concrete = "🏢", Asphalt = "🛣", Pavement = "🛣",
		Cobblestone = "🧱", Marble = "🤍", Granite = "🩶", Fabric = "🧵", Plastic = "🧩", SmoothPlastic = "🧩",
		Pebble = "⚪", Salt = "🧂", Limestone = "🪨",
	}
	local MAT_ITEMS = {{text = "↺  Original", value = ""}}
	do
		local names = {}
		for _, m in ipairs(Enum.Material:GetEnumItems()) do
			if m ~= Enum.Material.Air and m ~= Enum.Material.Water then table.insert(names, m.Name) end
		end
		table.sort(names)
		for _, n in ipairs(names) do
			table.insert(MAT_ITEMS, {text = (MAT_ICON[n] and (MAT_ICON[n] .. " ") or "") .. n, value = n})
		end
	end

	local function paint(part, name)
		if MAP.orig[part] == nil then MAP.orig[part] = part.Color end
		if MAP.origMat[part] == nil then MAP.origMat[part] = part.Material end
		part.Color = MAP.color[name]
		local m = MAP.mat[name] or MAP.origMat[part]
		if part.Material ~= m then part.Material = m end
	end

	local function terrainSet(def, col)
		if not def.Terrain then return end
		pcall(function()
			local t = workspace.Terrain
			if MAP.term[def.Terrain] == nil then MAP.term[def.Terrain] = t:GetMaterialColor(def.Terrain) end
			t:SetMaterialColor(def.Terrain, col)
		end)
	end
	local function terrainRestore(def)
		if not def.Terrain or MAP.term[def.Terrain] == nil then return end
		pcall(function() workspace.Terrain:SetMaterialColor(def.Terrain, MAP.term[def.Terrain]) end)
		MAP.term[def.Terrain] = nil
	end

	function MAP.apply(def)
		local set = MAP.index[def.Name]
		if set then
			for part in pairs(set) do
				if part.Parent then paint(part, def.Name) else set[part] = nil end
			end
		end
		terrainSet(def, MAP.color[def.Name])
	end

	function MAP.restore(def)
		local set = MAP.index[def.Name]
		if set then
			for part in pairs(set) do
				local o = MAP.orig[part]
				if o and part.Parent then part.Color = o end
				local om = MAP.origMat[part]
				if om and part.Parent and part.Material ~= om then part.Material = om end
			end
		end
		terrainRestore(def)
	end

	function MAP.applyMat(def)
		local gen = (def._matGen or 0) + 1
		def._matGen = gen
		task.spawn(function()
			local set = MAP.index[def.Name]
			if not set then return end
			local n = 0
			for part in pairs(set) do
				if def._matGen ~= gen then return end
				if part.Parent then paint(part, def.Name) else set[part] = nil end
				n = n + 1
				if n % 150 == 0 then task.wait() end
			end
		end)
	end

	function MAP.track(def)
		local name = def.Name
		if MAP.index[name] then return end
		local set = setmetatable({}, {__mode = "k"})
		MAP.index[name] = set
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if d.Name == name and d:IsA("BasePart") then set[d] = true end
				n = n + 1
				if n % 4000 == 0 then task.wait() end
			end
			if def.enabled and def.Name == name then MAP.apply(def) end
		end)
		if not MAP.conn then
			MAP.conn = workspace.DescendantAdded:Connect(function(d)
				local s = MAP.index[d.Name]
				if s and d:IsA("BasePart") then
					s[d] = true
					task.delay(0.1, function()
						local nm = d.Name
						if d.Parent and MAP.defs[nm] and MAP.defs[nm].enabled then paint(d, nm) end
					end)
				end
			end)
		end
	end
	MAP.defs = {}

	MAP.list = {}
	local function MapRow(def)
		local key = def.Custom and "custom" or def.Name
		local sv = MISC.saved and MISC.saved.map and MISC.saved.map[key]
		if type(sv) == "table" and type(sv.c) == "table" then
			def.Color = Color3.fromRGB(sv.c[1] or 255, sv.c[2] or 255, sv.c[3] or 255)
		end
		def.key = key
		if type(sv) == "table" and type(sv.m) == "string" then
			local okm, em = pcall(function() return Enum.Material[sv.m] end)
			if okm and em then MAP.mat[def.Name] = em end
		end
		table.insert(MAP.list, def)
		MAP.defs[def.Name] = def
		MAP.color[def.Name] = def.Color
		local row = UI.fullRow("Map", 114)

		local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = def.Color, BorderSizePixel = 0, ZIndex = 14}, row)
		corner(preview, 11); stroke(preview, WHITE, 1, 0.5)

		local nameBox
		if def.Custom then
			nameBox = new("TextBox", {Position = UDim2.new(0, 40, 0, 5), Size = UDim2.new(0, 170, 0, 28), BackgroundTransparency = 0.35,
				Text = "", PlaceholderText = "Part name (e.g. Brick)", Font = Enum.Font.GothamBold, TextSize = 12,
				ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
			corner(nameBox, 8)
			new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, nameBox)
			UI.bind(function(t)
				nameBox.BackgroundColor3 = t.Panel; nameBox.TextColor3 = t.Text; nameBox.PlaceholderColor3 = t.Sub
			end)
		else
			local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 22), Position = UDim2.new(0, 40, 0, 8),
				Text = def.Label, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
			UI.bind(function(t) lbl.TextColor3 = t.Text end)
		end

		local state = false
		local btn = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.new(0, 56, 0, 24),
			Text = "OFF", Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 14}, row)
		corner(btn, 12)
		local function paintBtn(animate)
			local t = Themes[currentTheme]
			btn.Text = state and "ON" or "OFF"
			btn.TextColor3 = state and WHITE or t.Text
			local col = state and t.On or t.Off
			if animate then tween(btn, 0.2, {BackgroundColor3 = col}) else btn.BackgroundColor3 = col end
		end
		UI.bind(function() paintBtn(false) end)

		local function setEnabled(on)
			def.enabled = on
			if on then
				MAP.track(def)
				MAP.apply(def)
			else
				MAP.restore(def)
			end
		end

		local function toggleNow()
			if def.Custom and nameBox then
				local nm = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
				if nm == "" then UI.notify("⚠ Enter a part name first"); return end
				if not state and nm ~= def.Name then
					local oldName = def.Name
					def.Name = nm
					MAP.defs[nm] = def
					MAP.color[nm] = MAP.color[oldName] or def.Color
					MAP.mat[nm] = MAP.mat[oldName]
				end
			end
			state = not state
			PlayUISound(SND.click, 0.45, state and 1.18 or 0.9)
			paintBtn(true)
			setEnabled(state)
			MISC.dirty()
		end
		btn.MouseButton1Click:Connect(toggleNow)
		def.toggleNow = toggleNow
		def.isOn = function() return state end
		def.nameBox = nameBox

		local setHue = UI.hueSlider(row, 44, def.Color, function(col)
			MAP.color[def.Name] = col
			preview.BackgroundColor3 = col
			if def.enabled then MAP.apply(def) end
			MISC.dirty()
		end, false, true)

		local matBtn = new("TextButton", {Position = UDim2.new(0, 12, 0, 78), Size = UDim2.new(1, -24, 0, 28),
			Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 14}, row)
		corner(matBtn, 8)
		local matStroke = stroke(matBtn, Themes[1].Accent, 1, 0.55)
		UI.bind(function(t) matBtn.BackgroundColor3 = t.Panel; matBtn.TextColor3 = t.Text; matStroke.Color = t.Accent end)
		local function matLabel()
			local m = MAP.mat[def.Name]
			local txt = "Original"
			if m then txt = (MAT_ICON[m.Name] and (MAT_ICON[m.Name] .. " ") or "") .. m.Name end
			matBtn.Text = "🧱  Material:  " .. txt .. "   ▲"
		end
		matLabel()
		matBtn.MouseEnter:Connect(function() tween(matStroke, 0.15, {Transparency = 0.1}) end)
		matBtn.MouseLeave:Connect(function() tween(matStroke, 0.2, {Transparency = 0.55}) end)
		matBtn.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.45, 1.1)
			local cur = MAP.mat[def.Name]
			UI.dropUp(matBtn, MAT_ITEMS, cur and cur.Name or "", function(v)
				MAP.mat[def.Name] = (v ~= "") and Enum.Material[v] or nil
				matLabel()
				if def.enabled then
					MAP.applyMat(def)
				elseif v ~= "" then
					toggleNow()
				end
				MISC.dirty()
			end, 3, 190)
		end)

		function def.applySaved(info)
			if type(info) ~= "table" then return end
			if type(info.c) == "table" then
				local col = Color3.fromRGB(info.c[1] or 255, info.c[2] or 255, info.c[3] or 255)
				MAP.color[def.Name] = col
				preview.BackgroundColor3 = col
				setHue(col)
				if def.enabled then MAP.apply(def) end
			end
			local em = nil
			if type(info.m) == "string" and info.m ~= "" then
				local okm, v = pcall(function() return Enum.Material[info.m] end)
				if okm then em = v end
			end
			MAP.mat[def.Name] = em
			matLabel()
			if def.enabled then MAP.applyMat(def) end
		end
	end

	function MISC.mapState()
		local out = {}
		for _, def in ipairs(MAP.list) do
			local col = MAP.color[def.Name] or def.Color
			out[def.key] = {
				on = (def.isOn and def.isOn()) or false,
				c = {math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5)},
				name = (def.Custom and def.Name ~= "__custom__") and def.Name or nil,
				m = MAP.mat[def.Name] and MAP.mat[def.Name].Name or nil,
			}
		end
		return out
	end

	function MISC.mapRestore(m)
		if type(m) ~= "table" then return end
		for _, def in ipairs(MAP.list) do
			local info = m[def.key]
			if type(info) == "table" and info.on and not def.isOn() then
				if def.Custom and def.nameBox and info.name then def.nameBox.Text = info.name end
				def.toggleNow()
			end
		end
	end

	UI.section("Map", "🎨  Map colors")
	UI.infoRow("Map", "💡  Color + material for parts by name (Grass, Sand...). Terrain: color only")
	for _, def in ipairs({
		{Name = "Grass",      Label = "🌱  Grass",       Color = Color3.fromRGB(0, 255, 0),     Terrain = Enum.Material.Grass},
		{Name = "Rock",       Label = "🪨  Rock",        Color = Color3.fromRGB(150, 150, 150), Terrain = Enum.Material.Rock},
		{Name = "LushGrass",  Label = "🌿  Lush grass",  Color = Color3.fromRGB(50, 205, 50),   Terrain = Enum.Material.LeafyGrass},
		{Name = "Sand",       Label = "🏖  Sand",        Color = Color3.fromRGB(240, 215, 120), Terrain = Enum.Material.Sand},
		{Name = "WasteGrass", Label = "🍂  Waste grass", Color = Color3.fromRGB(160, 140, 70),  Terrain = Enum.Material.Ground},
		{Name = "Snow",       Label = "❄  Snow",         Color = Color3.fromRGB(240, 240, 255), Terrain = Enum.Material.Snow},
		{Name = "__custom__",   Custom = true,             Color = Color3.fromRGB(255, 120, 200)},
		}) do
		MapRow(def)
	end
end

do
	local SH = {on = false, preset = 1, quality = 2, level = 70, gen = 0, inst = {}}
	local WHITE = Color3.new(1, 1, 1)
	local function C(r, g, b) return Color3.fromRGB(r, g, b) end

	local PRESETS = {
		{Name = "🎬 Cinematic", b = -0.02, c = 0.18, s = 0.10,  t = C(255, 244, 232), bi = 0.35, bs = 22, bt = 1.00, ri = 0.08, rs = 0.70},
		{Name = "🌈 Vibrant",   b =  0.02, c = 0.10, s = 0.45,  t = C(255, 255, 255), bi = 0.40, bs = 24, bt = 0.95, ri = 0.10, rs = 0.80},
		{Name = "🌅 Warm",      b =  0.00, c = 0.10, s = 0.20,  t = C(255, 214, 170), bi = 0.45, bs = 28, bt = 0.90, ri = 0.18, rs = 0.90},
		{Name = "❄ Cold",       b =  0.00, c = 0.12, s = 0.10,  t = C(190, 215, 255), bi = 0.30, bs = 20, bt = 1.00, ri = 0.05, rs = 0.60},
		{Name = "💎 Dream",     b =  0.03, c = 0.06, s = 0.30,  t = C(255, 205, 235), bi = 0.80, bs = 34, bt = 0.80, ri = 0.12, rs = 0.90},
		{Name = "🌙 Night",     b = -0.06, c = 0.20, s = 0.05,  t = C(170, 190, 255), bi = 0.55, bs = 26, bt = 0.85, ri = 0.00, rs = 0.50},
		{Name = "🖤 Noir",      b = -0.03, c = 0.30, s = -0.85, t = C(235, 235, 245), bi = 0.15, bs = 16, bt = 1.10, ri = 0.00, rs = 0.50},
		{Name = "🍑 Soft Glow", b =  0.04, c = 0.02, s = 0.18,  t = C(255, 230, 220), bi = 0.90, bs = 40, bt = 0.75, ri = 0.06, rs = 0.80},
	}
	local QUALITY = {
		{text = "⚡ Lite  (color only, 0 FPS cost)", value = 1},
		{text = "⚖ Balanced  (+ bloom)",            value = 2},
		{text = "💎 Full  (+ bloom + sun rays)",     value = 3},
	}
	local PRESET_ITEMS = {}
	for i, p in ipairs(PRESETS) do table.insert(PRESET_ITEMS, {text = p.Name, value = i}) end

	do
		local sv = MISC.saved and MISC.saved.shader
		if type(sv) == "table" then
			if type(sv.p) == "number" then SH.preset = math.clamp(math.floor(sv.p), 1, #PRESETS) end
			if type(sv.q) == "number" then SH.quality = math.clamp(math.floor(sv.q), 1, 3) end
			if type(sv.l) == "number" then SH.level = math.clamp(math.floor(sv.l), 10, 100) end
		end
	end
	function MISC.shaderState() return {p = SH.preset, q = SH.quality, l = SH.level} end

	local function drop(name)
		local o = SH.inst[name]
		if o then pcall(function() o:Destroy() end) end
		SH.inst[name] = nil
	end
	local function mk(class, name)
		local o = SH.inst[name]
		if o and o.Parent == Lighting then return o end
		if o then pcall(function() o:Destroy() end) end
		o = Instance.new(class); o.Name = name; o.Parent = Lighting
		SH.inst[name] = o
		return o
	end

	function SH.apply()
		if not SH.on then return end
		local p, k = PRESETS[SH.preset], SH.level / 100
		local cc = mk("ColorCorrectionEffect", "vizerShaderCC")
		cc.Brightness = p.b * k
		cc.Contrast   = p.c * k
		cc.Saturation = p.s * k
		cc.TintColor  = WHITE:Lerp(p.t, k)
		if SH.quality >= 2 then
			local bl = mk("BloomEffect", "vizerShaderBloom")
			bl.Intensity = p.bi * k; bl.Size = p.bs; bl.Threshold = p.bt
		else
			drop("vizerShaderBloom")
		end
		if SH.quality >= 3 and p.ri > 0 then
			local sr = mk("SunRaysEffect", "vizerShaderRays")
			sr.Intensity = p.ri * k; sr.Spread = p.rs
		else
			drop("vizerShaderRays")
		end
	end

	local function guardStart()
		SH.gen = SH.gen + 1
		local gen = SH.gen
		local frames = 0
		SH.hb = RunService.Heartbeat:Connect(function() frames = frames + 1 end)
		task.spawn(function()
			local low = 0
			while SH.on and SH.gen == gen do
				frames = 0
				local t0 = os.clock()
				task.wait(3)
				if not (SH.on and SH.gen == gen) then break end
				local cc = SH.inst.vizerShaderCC
				if not cc or cc.Parent ~= Lighting then SH.apply() end
				local fps = frames / math.max(os.clock() - t0, 0.01)
				if fps < 20 and SH.quality > 1 then low = low + 1 else low = 0 end
				if low >= 2 then
					low = 0
					SH.quality = SH.quality - 1
					SH.apply()
					if SH.qRow then SH.qRow.refresh() end
					UI.notify("⚡ Shader: low FPS, quality lowered")
					MISC.dirty()
				end
			end
		end)
	end

	function SH.set(on)
		SH.on = on
		if on then
			SH.apply()
			guardStart()
		else
			SH.gen = SH.gen + 1
			if SH.hb then SH.hb:Disconnect(); SH.hb = nil end
			for name in pairs(SH.inst) do drop(name) end
		end
	end

	XH.Shader = function(on)
		local ok, err = pcall(SH.set, on)
		if not ok then warn("[vizer] Shader: " .. tostring(err)); UI.notify("⚠ Shader failed") end
	end

	local pd = UI.pdata.Visuals
	local keepOrder, keepGrid = pd.order, pd.grid
	pd.order = -30; pd.grid = nil
	UI.section("Visuals", "🔮  Shader  (FPS-safe)")
	UI.add({Tab = "Visuals", Id = "Shader", Name = "Shader", Sub = "Cinematic light & color", Icon = "🔮", Toggle = XT("Shader")})
	SH.pRow = UI.pickRow("Visuals", "🎨  Preset", PRESET_ITEMS, function() return SH.preset end,
		function(v) SH.preset = v; SH.apply(); MISC.dirty() end, 2, 150)
	SH.qRow = UI.pickRow("Visuals", "⚡  Quality", QUALITY, function() return SH.quality end,
		function(v) SH.quality = v; SH.apply(); MISC.dirty() end, 1, 150)
	UI.sliderRow("Visuals", "✨  Shader strength: ", 10, 100, SH.level, function(v) SH.level = v; SH.apply() end)
	UI.infoRow("Visuals", "💡  Auto-lowers quality if FPS drops under 20")
	pd.order, pd.grid = keepOrder, keepGrid
end

do
	local N = {}
	local new, corner, stroke, tween = UI.new, UI.corner, UI.stroke, UI.tween
	local WHITE = Color3.new(1, 1, 1)
	local NS, KP, CS, CK = NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new, ColorSequenceKeypoint.new
	local function dark(c) return (c.R + c.G + c.B) < 0.05 end
	local function hsv(off, spd) return Color3.fromHSV(((os.clock() * (spd or 0.35)) + (off or 0)) % 1, 1, 1) end
	local function rootPart()
		local ch = player.Character
		return ch and ch:FindFirstChild("HumanoidRootPart")
	end

	local function H(id, fn)
		XH[id] = function(on)
			local ok, err = pcall(fn, on)
			if not ok then
				warn("[vizer] " .. id .. ": " .. tostring(err))
				UI.notify("⚠ " .. id .. " failed")
			end
		end
	end

	local function sectionGrid(tab, text)
		local pg = UI.pages[tab]
		if not pg then return nil end
		for _, c in ipairs(pg:GetChildren()) do
			if c:IsA("TextLabel") and c.Text:find(text, 1, true) then
				for _, g in ipairs(pg:GetChildren()) do
					if g.Name == "Grid" and g.LayoutOrder == c.LayoutOrder + 1 then return g end
				end
			end
		end
		return nil
	end

	local function addInto(tab, text, feat)
		local d = UI.pdata[tab]
		local g = sectionGrid(tab, text)
		local prev = d.grid
		if g then d.grid = g end
		local r = UI.add(feat)
		d.grid = prev
		return r
	end
	local function Tg(tab, sec, id, name, sub, icon)
		return addInto(tab, sec, {Tab = tab, Id = id, Name = name, Sub = sub, Icon = icon, Toggle = XT(id)})
	end
	local function Tn(tab, id, name, sub, icon)
		return UI.add({Tab = tab, Id = id, Name = name, Sub = sub, Icon = icon, Toggle = XT(id)})
	end

	do
		if UI.rows.Nameplates then
			if nameplatesEnabled then pcall(ApplyNameplates, false) end
			local cell = UI.pages.Player and UI.pages.Player:FindFirstChild("Nameplates", true)
			if cell then cell:Destroy() end
			UI.rows.Nameplates = nil
			for i, f in ipairs(UI.feats) do
				if f.Id == "Nameplates" then table.remove(UI.feats, i); break end
			end
		end
		if UI.rows.Rain then
			if XS.Rain and XH.Rain then pcall(XH.Rain, false) end
			XS.Rain = nil
			local cell = UI.pages.Visuals and UI.pages.Visuals:FindFirstChild("Rain", true)
			if cell then cell:Destroy() end
			UI.rows.Rain = nil
			for i, f in ipairs(UI.feats) do
				if f.Id == "Rain" then table.remove(UI.feats, i); break end
			end
		end
	end

	do
		local EXD = {expo = 0, cloud = 60, lightR = 24, mvol = 50}
		local sx = MISC.saved and MISC.saved.ext
		for k, v in pairs(EXD) do
			EXT[k] = (type(sx) == "table" and type(sx[k]) == "number") and sx[k] or v
		end

		local defs = {
			UiBeam    = Color3.fromRGB(0, 0, 0),
			UiPart    = Color3.fromRGB(179, 255, 98),
			Shift     = Color3.fromRGB(255, 170, 220),
			Light     = Color3.fromRGB(255, 235, 200),
		}
		local sc = MISC.saved and MISC.saved.colors
		for k, c in pairs(defs) do
			EffectColors[k] = c
			EffectDefaults[k] = c
			local v = sc and sc[k]
			if type(v) == "table" then EffectColors[k] = Color3.fromRGB(v[1] or 255, v[2] or 255, v[3] or 255) end
		end
	end

	palletEnabled = false
	PK.on = false
	PW.on = false
	ApplyPallets = function() end
	ApplyPallets2 = function() end
	ApplyPallets3 = function() end

	local PALLET_NAME = "PalletLightBrown"
	local myActivePallet = nil
	local savedPallets = setmetatable({}, {__mode = "k"})

	local function PalletGetParts(object)
		local parts = {}
		if object:IsA("BasePart") then
			table.insert(parts, object)
		else
			for _, obj in ipairs(object:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name ~= "Shadoweffect" and obj.Name ~= "vizerPalEffect" then
					table.insert(parts, obj)
				end
			end
		end
		return parts
	end

	local function getWorldUpFace(part)
		local faces = {
			{face = Enum.NormalId.Top,    dir = Vector3.new(0, 1, 0),  dims = {part.Size.X, part.Size.Z}},
			{face = Enum.NormalId.Bottom, dir = Vector3.new(0, -1, 0), dims = {part.Size.X, part.Size.Z}},
			{face = Enum.NormalId.Front,  dir = Vector3.new(0, 0, -1), dims = {part.Size.X, part.Size.Y}},
			{face = Enum.NormalId.Back,   dir = Vector3.new(0, 0, 1),  dims = {part.Size.X, part.Size.Y}},
			{face = Enum.NormalId.Left,   dir = Vector3.new(-1, 0, 0), dims = {part.Size.Z, part.Size.Y}},
			{face = Enum.NormalId.Right,  dir = Vector3.new(1, 0, 0),  dims = {part.Size.Z, part.Size.Y}},
		}
		local bestFace, bestScore = nil, -math.huge
		for _, f in ipairs(faces) do
			local worldNormal = part.CFrame:VectorToWorldSpace(f.dir)
			if worldNormal.Y > 0.3 then
				local area = f.dims[1] * f.dims[2]
				local projArea = area * worldNormal.Y
				local topY = part.Position.Y + part.Size.Y / 2
				local score = projArea * (1 + topY / 1000)
				if score > bestScore then
					bestScore = score
					bestFace = f.face
				end
			end
		end
		return bestFace
	end

	local function PalletFindTopPart(object)
		local parts = PalletGetParts(object)
		if #parts == 0 then return nil, nil end

		local bestPart, bestFace, bestScore = nil, nil, -math.huge
		for _, part in ipairs(parts) do
			local face = getWorldUpFace(part)
			if face then
				local size = part.Size
				local area
				if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
					area = size.X * size.Z
				elseif face == Enum.NormalId.Front or face == Enum.NormalId.Back then
					area = size.X * size.Y
				else
					area = size.Z * size.Y
				end
				local worldNormal = part.CFrame:VectorToWorldSpace(
					face == Enum.NormalId.Top and Vector3.new(0,1,0) or
						face == Enum.NormalId.Bottom and Vector3.new(0,-1,0) or
						face == Enum.NormalId.Front and Vector3.new(0,0,-1) or
						face == Enum.NormalId.Back and Vector3.new(0,0,1) or
						face == Enum.NormalId.Left and Vector3.new(-1,0,0) or
						Vector3.new(1,0,0)
				)
				local projArea = area * worldNormal.Y
				local topY = part.Position.Y + size.Y / 2
				local score = projArea * (1 + topY / 1000)
				if score > bestScore then
					bestScore = score
					bestPart = part
					bestFace = face
				end
			end
		end
		return bestPart, bestFace
	end

	local function isMyPallet(pallet)
		if not pallet or not pallet.Parent then return false end
		local myName = player.Name:lower()
		local cur = pallet
		while cur and cur ~= workspace do
			if cur.Name:lower():find(myName, 1, true) then return true end
			cur = cur.Parent
		end
		local parts = PalletGetParts(pallet)
		for _, part in ipairs(parts) do
			local ok, owner = pcall(function() return part:GetNetworkOwner() end)
			if ok and owner == player then return true end
		end
		return false
	end

	local function applyPalletStyle(pallet, cfg)
		if not isMyPallet(pallet) then return end
		local data = savedPallets[pallet]
		if not data then data = {parts = {}, textures = {}}; savedPallets[pallet] = data end

		for _, part in ipairs(PalletGetParts(pallet)) do
			if data.parts[part] == nil then data.parts[part] = {Color = part.Color, Material = part.Material} end
			part.Color = cfg.color
			if cfg.material then part.Material = cfg.material end
		end
		for _, obj in ipairs(pallet:GetDescendants()) do
			if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Name ~= "vizerPalDecal" and obj.Name ~= "vizerPalEffect" then
				if data.textures[obj] == nil then data.textures[obj] = obj.Transparency end
				obj.Transparency = 1
			end
		end

		local top, face = PalletFindTopPart(pallet)
		if top and face then
			local decal = Instance.new("Decal")
			decal.Name = "vizerPalDecal"
			decal.Face = face
			decal.Texture = cfg.decal
			decal.Color3 = Color3.fromRGB(255, 255, 255)
			pcall(function()
				if decal.Rotation ~= 90 then decal.Rotation = 90 end
				if cfg.tint then
					decal.EmissiveStrength = 1
					decal.EmissiveTint = cfg.tint
				end
			end)
			decal.Parent = top
		end
	end

	local function restorePallet(pallet)
		local data = savedPallets[pallet]
		if not data then return end
		for part, info in pairs(data.parts) do
			if part and part.Parent then part.Color = info.Color; part.Material = info.Material end
		end
		for obj, tr in pairs(data.textures) do
			if obj and obj.Parent then obj.Transparency = tr end
		end
		for _, obj in ipairs(pallet:GetDescendants()) do
			if obj.Name == "vizerPalDecal" or obj.Name == "vizerPalEffect" then obj:Destroy() end
		end
		savedPallets[pallet] = nil
	end

	local function togglePallet(id, name, sub, icon, color, texture, tint, material)
		local cfg = { id = id, color = color, decal = texture, tint = tint, material = material }
		local function toggleFn()
			local state = not XS[id]
			XS[id] = state
			UpdateToggleVisual(id, state)

			if state then
				if myActivePallet and myActivePallet.id ~= id then
					XS[myActivePallet.id] = false
					UpdateToggleVisual(myActivePallet.id, false)
					for pallet in pairs(savedPallets) do restorePallet(pallet) end
				end
				myActivePallet = cfg
				task.spawn(function()
					for _, d in ipairs(workspace:GetDescendants()) do
						if myActivePallet ~= cfg then return end
						if d.Name == PALLET_NAME and isMyPallet(d) then applyPalletStyle(d, cfg) end
						task.wait()
					end
				end)
			else
				if myActivePallet == cfg then
					myActivePallet = nil
					for pallet in pairs(savedPallets) do restorePallet(pallet) end
				end
			end
			MISC.dirty()
		end

		if UI.rows[id] then
			UI.rows[id].feat.Toggle = toggleFn
		else
			addInto("World", "Pallets", {Tab = "World", Id = id, Name = name, Sub = sub, Icon = icon, Toggle = toggleFn})
		end
	end

	togglePallet("Pallets", "Anonymous pallet", "Black pallet", "📦", Color3.fromRGB(0, 0, 0), "rbxassetid://7049300738", nil, Enum.Material.Plastic)
	togglePallet("Pallets2", "Pink pallet", "Pink + crosses", "🎀", Color3.fromRGB(255, 78, 149), "rbxassetid://304489616", nil, nil)
	togglePallet("Pallets3", "White pallet", "White neon", "🤍", Color3.fromRGB(255, 255, 255), "rbxassetid://71490357463486", Color3.fromRGB(255, 0, 115), Enum.Material.Neon)

	local smoke = Color3.fromRGB(91, 93, 105)
	pcall(function()
		local bc = BrickColor.new("Smoky grey")
		if bc.Name == "Smoky grey" then smoke = bc.Color end
	end)
	togglePallet("PalletBlack", "Black pallet 2", "Black + new decal", "⬛", Color3.fromRGB(0, 0, 0), "rbxassetid://120900747312435", Color3.fromRGB(255, 255, 255), nil)
	togglePallet("PalletSmoke", "Smoke pallet", "Smoky grey + new decal", "🌫", smoke, "rbxassetid://10076753898", Color3.fromRGB(255, 0, 115), nil)

	workspace.DescendantAdded:Connect(function(d)
		if not myActivePallet then return end
		if d.Name == PALLET_NAME then
			task.delay(0.5, function()
				if d.Parent and myActivePallet then applyPalletStyle(d, myActivePallet) end
			end)
		end
	end)

	N.uip = {}

	function N.uip.torso(ch)
		return ch and (ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso"))
	end

	function N.uip.destroy(ch)
		local torso = N.uip.torso(ch)
		if not torso then return end
		for _, nm in ipairs({"vizerUI_A13", "vizerUI_A7", "vizerUI_A8", "vizerUIBeam"}) do
			local o = torso:FindFirstChild(nm)
			if o then o:Destroy() end
		end
	end

	function N.uip.paint(beamCol, partCol)
		local torso = N.uip.torso(player.Character)
		if not torso then return end
		local b = torso:FindFirstChild("vizerUIBeam")
		if b then b.Color = CS(beamCol) end
		local a7 = torso:FindFirstChild("vizerUI_A7")
		local e = a7 and a7:FindFirstChild("vizerUIEmitter")
		if e then
			e.Color = CS(partCol)
			e.LightEmission = dark(partCol) and 0 or 1
		end
	end

	function N.uip.build(ch)
		local torso = N.uip.torso(ch)
		if not torso then return end
		N.uip.destroy(ch)

		local function att(nm, pos, ori)
			local a = Instance.new("Attachment")
			a.Name = nm
			a.CFrame = CFrame.new(pos) * CFrame.fromOrientation(math.rad(ori.X), math.rad(ori.Y), math.rad(ori.Z))
			a.Parent = torso
			return a
		end
		local a13 = att("vizerUI_A13", Vector3.new(-4.85, 2.817, 5.983), Vector3.new(-5.287, 17.596, -0.002))
		local a7  = att("vizerUI_A7",  Vector3.new(1.033, 2.817, 4.117), Vector3.new(-84.712, -162.411, 0.009))
		local a8  = att("vizerUI_A8",  Vector3.new(7.154, 2.817, 2.176), Vector3.new(-5.287, 17.596, -0.002))

		local beam = Instance.new("Beam")
		beam.Name = "vizerUIBeam"
		beam.Attachment0 = a8
		beam.Attachment1 = a13
		beam.Color = CS(EffectColors.UiBeam)
		beam.Brightness = 1
		beam.LightEmission = 0
		beam.LightInfluence = 0
		beam.TextureMode = Enum.TextureMode.Stretch
		beam.TextureLength = 1
		beam.TextureSpeed = 1
		beam.Transparency = NS(0)
		beam.ZOffset = 0
		beam.FaceCamera = false
		beam.Segments = 10
		beam.Width0 = 5
		beam.Width1 = 5
		beam.CurveSize0 = 0
		beam.CurveSize1 = 0
		beam.Enabled = true
		beam.Parent = torso

		local e = Instance.new("ParticleEmitter")
		e.Name = "vizerUIEmitter"
		e.Texture = "rbxassetid://15780623325"
		e.Brightness = 1
		e.Color = CS(EffectColors.UiPart)
		e.LightEmission = dark(EffectColors.UiPart) and 0 or 1
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		e.Size = NS(5.00965)
		e.Squash = NS(-0.6)
		e.Transparency = NS({KP(0, 1), KP(0.2, 0.2), KP(0.8, 0.2), KP(1, 1)})
		e.ZOffset = 0.2
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(1, 1)
		e.Rate = 4
		e.Rotation = NumberRange.new(0, 0)
		e.RotSpeed = NumberRange.new(0, 0)
		e.Speed = NumberRange.new(0.25, 0.25)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 0
		e.LockedToPart = true
		e.TimeScale = 1
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
			e.FlipbookBlendFrames = true
			e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
			e.FlipbookStartRandom = false
			e.VelocityInheritance = 0
			e.WindAffectsDrag = false
		end)
		e.Enabled = true
		e.Parent = a7
	end

	H("UiPanel", function(on)
		local ch = player.Character
		if on then
			if ch then N.uip.build(ch) end
		else
			N.uip.destroy(ch)
		end
	end)
	XHK.UiPanel = function(ch) if XS.UiPanel then N.uip.build(ch) end end

	H("UiPanelRainbow", function(on)
		xLoop("uiprain", on and function() N.uip.paint(hsv(0), hsv(0.5)) end or nil)
		if not on then N.uip.paint(EffectColors.UiBeam, EffectColors.UiPart) end
	end)

	Tg("Player", "Accessories", "UiPanel", "UI panel", "Black beam + glowing particle", "🔳")
	Tg("Player", "Accessories", "UiPanelRainbow", "UI panel rainbow", "Colors cycle", "🌈")

	N.j3 = {active = {}, last = 0}

	function N.j3.paint(en, col)
		for _, e in ipairs(en.ems) do
			if e.Parent then e.Color = CS(col) end
		end
		if en.light and en.light.Parent then
			en.light.Color = Color3.new(col.R * 0.667, col.G * 0.667, col.B * 0.667)
		end
	end

	function N.j3.spawn(char)
		local now = os.clock()
		if now - N.j3.last < 0.3 then return end
		N.j3.last = now

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local pos = root.Position - Vector3.new(0, 3, 0)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {char}
		local hit = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), params)
		if hit then pos = hit.Position + Vector3.new(0, 0.05, 0) end

		local part = Instance.new("Part")
		part.Name = "vizerJC3"
		part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		part.CastShadow = false; part.Transparency = 1
		part.Size = Vector3.new(0.2, 0.2, 0.2)
		part.CFrame = CFrame.new(pos)
		part.Parent = workspace

		local att = Instance.new("Attachment")
		att.Name = "Floor"
		att.Parent = part

		local col = EffectColors.JumpCircle
		local ems = {}

		local function mk(c)
			local e = Instance.new("ParticleEmitter")
			e.Name = c.name
			e.Texture = c.tex
			e.Brightness = c.bright
			e.Color = CS(col)
			e.LightEmission = 0
			e.LightInfluence = 0
			e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
			e.Size = c.size
			e.Squash = NS(0)
			e.Transparency = c.trans
			e.ZOffset = c.z
			e.EmissionDirection = Enum.NormalId.Top
			e.Lifetime = c.life
			e.Rate = c.rate
			e.Rotation = c.rot
			e.RotSpeed = c.rs
			e.Speed = NumberRange.new(0.001, 0.001)
			e.SpreadAngle = Vector2.new(0, 0)
			e.Acceleration = c.acc or Vector3.new(0, 0, 0)
			e.Drag = 0
			e.LockedToPart = false
			e.TimeScale = 1
			pcall(function()
				e.Shape = Enum.ParticleEmitterShape.Box
				e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
				e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
				e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
				e.VelocityInheritance = 0
				e.WindAffectsDrag = false
			end)
			e.Enabled = true
			e.Parent = att
			table.insert(ems, e)
			return e
		end

		mk({name = "Circle16", tex = "rbxassetid://16878073342", bright = 2, z = 0.01,
			size = NS({KP(0, 1.5), KP(0.5, 4), KP(1, 5)}), trans = NS({KP(0, 1), KP(0.15, 0.35), KP(1, 1)}),
			life = NumberRange.new(1, 1.5), rate = 35, rot = NumberRange.new(0, 360), rs = NumberRange.new(-50, 50),
			acc = Vector3.new(0, 2, 0)})
		local ring = mk({name = "Circle29", tex = "rbxassetid://16878102398", bright = 5, z = 0,
			size = NS(5), trans = NS(0), life = NumberRange.new(1.01, 1.01), rate = 2,
			rot = NumberRange.new(0, 0), rs = NumberRange.new(-180, -180)})
		mk({name = "Circle29", tex = "rbxassetid://16878102398", bright = 6, z = -0.01,
			size = NS({KP(0, 2), KP(1, 6)}), trans = NS({KP(0, 0.2), KP(1, 1)}),
			life = NumberRange.new(1.01, 1.01), rate = 20, rot = NumberRange.new(0, 0), rs = NumberRange.new(-180, -180)})

		local light = Instance.new("PointLight")
		light.Name = "PointLight"
		light.Brightness = 4
		light.Range = 11
		light.Shadows = false
		light.Enabled = true
		light.Parent = part

		local en = {part = part, ems = ems, light = light}
		N.j3.paint(en, col)
		table.insert(N.j3.active, en)
		pcall(function() ring:Emit(1) end)

		task.delay(0.5, function()
			for _, e in ipairs(ems) do
				if e.Parent then e.Enabled = false end
			end
			if light.Parent then
				TweenService:Create(light, TweenInfo.new(1.2), {Brightness = 0}):Play()
			end
		end)
		task.delay(3.5, function()
			for i, a in ipairs(N.j3.active) do
				if a == en then table.remove(N.j3.active, i); break end
			end
			if part then part:Destroy() end
		end)
	end

	JC.spawn3 = N.j3.spawn

	local function follower(name, size, yOff)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
		p.CastShadow = false; p.Transparency = 1
		p.Size = size
		p.Parent = workspace
		return p
	end

	N.click = {}
	H("ClickFx", function(on)
		if N.click.conn then N.click.conn:Disconnect(); N.click.conn = nil end
		if on then
			if not N.click.gui then
				N.click.gui = new("ScreenGui", {Name = "vizerClicks", ResetOnSpawn = false, IgnoreGuiInset = true,
					DisplayOrder = 10001, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, player:WaitForChild("PlayerGui"))
			end
			N.click.conn = UIS.InputBegan:Connect(function(io)
				local ut = io.UserInputType
				if ut ~= Enum.UserInputType.MouseButton1 and ut ~= Enum.UserInputType.Touch then return end
				local pos = (ut == Enum.UserInputType.Touch) and Vector2.new(io.Position.X, io.Position.Y) or UIS:GetMouseLocation()
				local c = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, pos.X, 0, pos.Y),
					Size = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, ZIndex = 900}, N.click.gui)
				corner(c, 100)
				local s = stroke(c, Themes[currentTheme].Accent2, 2.5, 0)
				tween(c, 0.5, {Size = UDim2.new(0, 70, 0, 70)})
				tween(s, 0.5, {Transparency = 1})
				task.delay(0.55, function() c:Destroy() end)
			end)
		end
	end)

	do
		local g = new("ScreenGui", {Name = "vizerCompass", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9986,
			Enabled = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, player:WaitForChild("PlayerGui"))
		local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 60), Size = UDim2.new(0, 150, 0, 30),
			BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 500}, g)
		corner(f, 15)
		local s = stroke(f, Themes[1].Accent, 1.5, 0.1)
		local l = new("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
			TextSize = 14, Text = "N 0°", ZIndex = 501}, f)
		UI.bind(function(t) f.BackgroundColor3 = t.Panel; s.Color = t.Accent; l.TextColor3 = t.Text end)
		N.cmp = {gui = g, label = l}
	end
	H("Compass", function(on)
		N.cmp.gui.Enabled = on
		pcall(function() RunService:UnbindFromRenderStep("vizerCompass") end)
		if on then
			local acc = 0
			local dirs = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
			RunService:BindToRenderStep("vizerCompass", Enum.RenderPriority.Camera.Value + 23, function(dt)
				acc = acc + dt
				if acc < 0.06 then return end
				acc = 0
				local cam = workspace.CurrentCamera
				if not cam then return end
				local look = cam.CFrame.LookVector
				local h = math.deg(math.atan2(look.X, -look.Z)) % 360
				N.cmp.label.Text = dirs[math.floor((h + 22.5) / 45) % 8 + 1] .. "  " .. math.floor(h + 0.5) .. "°"
			end)
		end
	end)

	H("Sepia", function(on)
		xFx("sepia", "ColorCorrectionEffect", "vizerSepia", {TintColor = Color3.fromRGB(255, 225, 180), Saturation = -0.35, Contrast = 0.08}, on)
	end)

	N.light = {}
	H("Exposure", function(on)
		xLoop("expo", nil)
		if on then
			if N.light.expo == nil then N.light.expo = Lighting.ExposureCompensation end
			xLoop("expo", function()
				local v = EXT.expo / 10
				if Lighting.ExposureCompensation ~= v then Lighting.ExposureCompensation = v end
			end)
		elseif N.light.expo ~= nil then
			Lighting.ExposureCompensation = N.light.expo
			N.light.expo = nil
		end
	end)
	H("ColorShift", function(on)
		xLoop("shift", nil)
		if on then
			if not N.light.shift then N.light.shift = {Lighting.ColorShift_Top, Lighting.ColorShift_Bottom} end
			xLoop("shift", function()
				local c = EffectColors.Shift
				Lighting.ColorShift_Top = c
				Lighting.ColorShift_Bottom = c
			end)
		elseif N.light.shift then
			Lighting.ColorShift_Top = N.light.shift[1]
			Lighting.ColorShift_Bottom = N.light.shift[2]
			N.light.shift = nil
		end
	end)
	H("PlayerLight", function(on)
		xLoop("plight", nil)
		if not on then
			local r = rootPart()
			local l = r and r:FindFirstChild("vizerPlayerLight")
			if l then l:Destroy() end
			return
		end
		xLoop("plight", function()
			local r = rootPart()
			if not r then return end
			local l = r:FindFirstChild("vizerPlayerLight")
			if not l then
				l = Instance.new("PointLight")
				l.Name = "vizerPlayerLight"; l.Shadows = false; l.Parent = r
			end
			l.Range = EXT.lightR; l.Brightness = 2; l.Color = EffectColors.Light
		end)
	end)
	H("Flashlight", function(on)
		pcall(function() RunService:UnbindFromRenderStep("vizerFlashlight") end)
		if N.fl then N.fl:Destroy(); N.fl = nil end
		if not on then return end
		local p = follower("vizerFlashPart", Vector3.new(0.2, 0.2, 0.2))
		local s = Instance.new("SpotLight")
		s.Brightness = 3; s.Range = 80; s.Angle = 55; s.Face = Enum.NormalId.Front; s.Shadows = false
		s.Parent = p
		N.fl = p
		RunService:BindToRenderStep("vizerFlashlight", Enum.RenderPriority.Camera.Value + 22, function()
			local cam = workspace.CurrentCamera
			if cam then p.CFrame = cam.CFrame end
		end)
	end)

	H("Clouds", function(on)
		local t = workspace:FindFirstChildOfClass("Terrain")
		if not t then return end
		xLoop("clouds", nil)
		if on then
			local c = t:FindFirstChildOfClass("Clouds")
			if not N.cloudSaved then
				N.cloudSaved = c and {existed = true, Cover = c.Cover, Density = c.Density, Enabled = c.Enabled} or {existed = false}
			end
			if not c then
				c = Instance.new("Clouds")
				c.Name = "vizerClouds"
				c.Parent = t
			end
			xLoop("clouds", function()
				local cl = t:FindFirstChildOfClass("Clouds")
				if not cl then return end
				cl.Enabled = true
				cl.Cover = EXT.cloud / 100
				cl.Density = 0.7
			end)
		elseif N.cloudSaved then
			local c = t:FindFirstChildOfClass("Clouds")
			if c then
				if N.cloudSaved.existed then
					c.Cover = N.cloudSaved.Cover; c.Density = N.cloudSaved.Density; c.Enabled = N.cloudSaved.Enabled
				else
					c:Destroy()
				end
			end
			N.cloudSaved = nil
		end
	end)

	H("AirWalk", function(on)
		xLoop("airwalk", nil)
		if N.air then N.air:Destroy(); N.air = nil end
		if not on then return end
		local r = rootPart()
		if not r then return end
		local hum = MV.hum()
		local p = follower("vizerAirWalk", Vector3.new(8, 1, 8))
		p.CanCollide = true
		N.air = p
		local y = r.Position.Y - (r.Size.Y / 2 + (hum and hum.HipHeight or 2)) - 0.5
		xLoop("airwalk", function(dt)
			local rr = rootPart()
			if not rr then return end
			if not UIS:GetFocusedTextBox() then
				if UIS:IsKeyDown(Enum.KeyCode.Space) then y = y + 14 * dt end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then y = y - 14 * dt end
			end
			p.CFrame = CFrame.new(rr.Position.X, y, rr.Position.Z)
		end)
	end)

	H("FreeCursor", function(on)
		xLoop("freecursor", on and function()
			if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
			if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
		end or nil)
	end)

	Tg("Visuals", "More effects", "Sepia", "Sepia", "Warm old-photo filter", "🟤")
	Tg("Visuals", "More effects", "ClickFx", "Click ripple", "Ring where you click", "🔘")
	Tg("Visuals", "More effects", "Compass", "Compass", "Heading on screen", "🧭")
	Tg("Visuals", "More effects", "Flashlight", "Flashlight", "Light from your camera", "🔦")

	UI.section("Visuals", "💡  Light & glow")
	Tn("Visuals", "Exposure", "Exposure", "Brighter / darker world", "🔅")
	Tn("Visuals", "PlayerLight", "Player light", "Lamp around you", "💡")
	Tn("Visuals", "ColorShift", "Color shift", "Tint the world light", "🎨")
	UI.sliderRow("Visuals", "🔅  Exposure: ", -30, 30, EXT.expo, function(v) EXT.expo = v end)
	UI.sliderRow("Visuals", "💡  Light range: ", 8, 60, EXT.lightR, function(v) EXT.lightR = v end)

	UI.section("Movement", "🛸  Extra movement")
	Tn("Movement", "AirWalk", "Air walk", "Walk on air (Space / Ctrl)", "☁")

	UI.section("World", "🌤  Sky & weather")
	Tn("World", "Clouds", "Clouds", "Custom cloud cover", "☁")
	UI.sliderRow("World", "☁  Cloud cover %: ", 0, 100, EXT.cloud, function(v) EXT.cloud = v end)
	UI.idRow("World", "🌌  Custom sky: paste an image ID (all 6 sides)", "rbxassetid://... or just the number",
		function(id)
			local s = Lighting:FindFirstChild("vizerCustomSky")
			if not s then s = Instance.new("Sky"); s.Name = "vizerCustomSky"; s.Parent = Lighting end
			local u = "rbxassetid://" .. id
			s.SkyboxBk = u; s.SkyboxDn = u; s.SkyboxFt = u; s.SkyboxLf = u; s.SkyboxRt = u; s.SkyboxUp = u
			return "✓ Custom sky applied"
		end,
		function()
			local s = Lighting:FindFirstChild("vizerCustomSky")
			if s then s:Destroy() end
			return "↺ Custom sky removed"
		end)

	UI.section("Misc", "🧰  Server tools")
	Tn("Misc", "FreeCursor", "Free cursor", "Mouse always unlocked", "🖱")

	UI.section("Misc", "🎵  Music player")
	N.mus = {}
	UI.idRow("Misc", "🎵  Audio ID — Apply plays, Reset stops", "rbxassetid://... or just the number",
		function(id)
			if N.mus.sound then N.mus.sound:Destroy() end
			local s = Instance.new("Sound")
			s.Name = "vizerMusic"
			s.SoundId = "rbxassetid://" .. id
			s.Looped = true
			s.Volume = EXT.mvol / 50
			s.Parent = game:GetService("SoundService")
			s:Play()
			N.mus.sound = s
			task.delay(3, function()
				if N.mus.sound == s and not s.IsLoaded then UI.notify("⚠ Audio did not load (private or wrong ID?)") end
			end)
			return "▶ Playing"
		end,
		function()
			if N.mus.sound then N.mus.sound:Destroy(); N.mus.sound = nil end
			return "⏹ Stopped"
		end)
	UI.sliderRow("Misc", "🎵  Music volume: ", 0, 100, EXT.mvol, function(v)
		EXT.mvol = v
		if N.mus.sound then N.mus.sound.Volume = v / 50 end
	end)

	do
		N.live = {
			UiBeam = function() if not XS.UiPanelRainbow then N.uip.paint(EffectColors.UiBeam, EffectColors.UiPart) end end,
			UiPart = function() if not XS.UiPanelRainbow then N.uip.paint(EffectColors.UiBeam, EffectColors.UiPart) end end,
		}
		local oldXC = XColorUpdate
		function XColorUpdate(key, col)
			if oldXC then oldXC(key, col) end
			local f = N.live[key]
			if f then f(col) end
		end

		local function colorRow(key, label)
			local row = UI.fullRow("Settings", 72)
			local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
				BackgroundColor3 = EffectColors[key], BorderSizePixel = 0, ZIndex = 14}, row)
			corner(preview, 11); stroke(preview, WHITE, 1, 0.5)
			local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0, 40, 0, 8),
				Text = label, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
			UI.bind(function(t) lbl.TextColor3 = t.Text end)
			local setHue = UI.hueSlider(row, 40, EffectColors[key], function(col)
				EffectColors[key] = col
				MISC.dirty()
				preview.BackgroundColor3 = col
				XColorUpdate(key, col)
			end, false, true)
			if UI.colorSetters then
				UI.colorSetters[key] = function(col) preview.BackgroundColor3 = col; setHue(col) end
			end
			return row
		end

		local list = {
			{"UiBeam", "UI panel: beam"}, {"UiPart", "UI panel: particle"},
			{"Shift", "Color shift"}, {"Light", "Player light"},
		}

		local pg = UI.pages.Settings
		local lab
		for _, c in ipairs(pg:GetChildren()) do
			if c:IsA("TextLabel") and c.Text:find("Effect colors", 1, true) then lab = c; break end
		end
		local base = lab and lab.LayoutOrder
		if base then
			for _, c in ipairs(pg:GetChildren()) do
				if c:IsA("GuiObject") and c ~= lab and c.LayoutOrder > base then c.LayoutOrder = c.LayoutOrder + #list end
			end
			UI.pdata.Settings.order = UI.pdata.Settings.order + #list
		end
		for i, it in ipairs(list) do
			local row = colorRow(it[1], it[2])
			if base then row.LayoutOrder = base + i end
		end
	end
end

ApplyPetals(petalEnabled)
ApplyPallets(palletEnabled)
ApplyNightVision(nightVisionEnabled)
ApplyAntiAfk(antiAfkEnabled)
ApplyNameplates(nameplatesEnabled)
ApplyCameraSmooth(cameraSmoothEnabled)
ApplyFPSBoost(fpsBoostEnabled)
ApplyAutoJump(AJ.on)
ApplyThemeToAll(); UI.switch("Visuals")

do
	local WD = {acc = 0, warned = 0}
	RunService.Heartbeat:Connect(function(dt)
		WD.acc = WD.acc + dt
		if WD.acc < 0.5 then return end
		WD.acc = 0
		if GH.on then return end
		local ch = player.Character
		local cam = workspace.CurrentCamera
		local head = ch and ch:FindFirstChild("Head")
		if not ch or not cam or not head then return end
		if (cam.CFrame.Position - head.Position).Magnitude < 4 then return end
		local fixed = 0
		for _, p in ipairs(ch:GetDescendants()) do
			if p:IsA("BasePart") and p.LocalTransparencyModifier > 0.5 then
				if not (headlessEnabled and p == head) then
					p.LocalTransparencyModifier = 0
					fixed = fixed + 1
				end
			end
		end
		if fixed > 0 and os.clock() - WD.warned > 10 then
			WD.warned = os.clock()
			warn("[vizer] character visibility restored")
		end
	end)
end

function MISC.restore()
	local d = MISC.saved
	task.spawn(function()
		if d then
			for id, name in pairs(d.keys or {}) do
				local r = UI.rows[id]
				local ok, kc = pcall(function() return Enum.KeyCode[name] end)
				if r and ok and kc then r.feat.Key = kc; r.updateSub() end
			end
			if type(d.image) == "string" and UI.artImage then UI.artImage.Image = d.image end
			UpdateToggleVisual("UISounds", not UISnd.off)
			local ch = player.Character or player.CharacterAdded:Wait()
			ch:WaitForChild("Humanoid", 10)
			ch:WaitForChild("HumanoidRootPart", 10)
			ch:WaitForChild("Head", 10)
			local waitStart = os.clock()
			while not player:HasAppearanceLoaded() and os.clock() - waitStart < 8 do task.wait(0.2) end
			task.wait(1.5)
			local order = {}
			for _, id in ipairs(d.on or {}) do table.insert(order, id) end
			table.sort(order)
			for _, id in ipairs(order) do
				local r = UI.rows[id]
				if r and not r.state and not r.feat.Button then pcall(r.feat.Toggle) end
				task.wait(0.05)
			end
			if MISC.mapRestore then pcall(MISC.mapRestore, d.map) end
		end
		MISC.ready = true
	end)
end
MISC.restore()

UI.holder.Visible = false; UI.mini.Visible = false; UI.open = false

if AUTOSTART then
	UI.mini.Position = UDim2.new(0.5, 0, 0, -50)
	UI.mini.Visible = true
	TweenService:Create(UI.mini, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0, 14)}):Play()
	task.spawn(function()
		if not player.Character then player.CharacterAdded:Wait() end
		task.wait(1.5)
		UI.notify("✓ vizer reconnected automatically")
	end)
else
	savedMouseBehavior=UIS.MouseBehavior; savedMouseIcon=UIS.MouseIconEnabled
	UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true

	do
		UI.splash = true
		local splashGui = Instance.new("ScreenGui")
		splashGui.Name = "vizerSplashGUI"
		splashGui.ResetOnSpawn = false
		splashGui.IgnoreGuiInset = true
		splashGui.DisplayOrder = 10000
		splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		splashGui.Parent = player:WaitForChild("PlayerGui")

		local root = Instance.new("CanvasGroup")
		root.Size = UDim2.new(1, 0, 1, 0)
		root.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
		root.BorderSizePixel = 0
		root.GroupTransparency = 1
		root.Parent = splashGui

		local WHITE = Color3.fromRGB(255, 255, 255)
		local PINK  = Color3.fromRGB(255, 80, 160)

		local function Pill(parent, size, pos, anchor, bgColor, bgTransp, strokeColor, strokeTransp, z)
			local f = Instance.new("Frame")
			f.AnchorPoint = anchor; f.Position = pos; f.Size = size
			f.BackgroundColor3 = bgColor; f.BackgroundTransparency = bgTransp
			f.BorderSizePixel = 0; f.ZIndex = z; f.Parent = parent
			Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
			if strokeColor then
				local st = Instance.new("UIStroke", f)
				st.Color = strokeColor; st.Thickness = 1; st.Transparency = strokeTransp
			end
			return f
		end

		local function Text(parent, txt, font, size, color, z)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
			l.Text = txt; l.Font = font; l.TextSize = size; l.TextColor3 = color
			l.ZIndex = z; l.Parent = parent
			return l
		end

		if SPLASH_IMAGE ~= "" then
			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1
			img.Image = SPLASH_IMAGE; img.ScaleType = Enum.ScaleType.Crop
			img.ZIndex = 1; img.Parent = root
		else
			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.new(1, 1, 1)
			bg.BorderSizePixel = 0; bg.ZIndex = 1; bg.Parent = root
			local g = Instance.new("UIGradient", bg)
			g.Rotation = 90
			g.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,    Color3.fromRGB(60, 20, 80)),
				ColorSequenceKeypoint.new(0.45, Color3.fromRGB(190, 70, 130)),
				ColorSequenceKeypoint.new(0.72, Color3.fromRGB(245, 140, 120)),
				ColorSequenceKeypoint.new(1,    Color3.fromRGB(70, 30, 70)),
			})
		end

		local darkTint = Instance.new("Frame")
		darkTint.Size = UDim2.new(1, 0, 1, 0); darkTint.BackgroundColor3 = Color3.fromRGB(30, 5, 25)
		darkTint.BackgroundTransparency = 0.5; darkTint.BorderSizePixel = 0; darkTint.ZIndex = 2; darkTint.Parent = root

		local pinkTint = Instance.new("Frame")
		pinkTint.Size = UDim2.new(1, 0, 1, 0); pinkTint.BackgroundColor3 = Color3.fromRGB(235, 40, 125)
		pinkTint.BackgroundTransparency = 0.72; pinkTint.BorderSizePixel = 0; pinkTint.ZIndex = 2; pinkTint.Parent = root

		local glow = Instance.new("Frame")
		glow.AnchorPoint = Vector2.new(0.5, 0.5); glow.Position = UDim2.new(0.5, 0, 0.42, 0)
		glow.Size = UDim2.new(0, 0, 0, 0); glow.BackgroundTransparency = 1; glow.ZIndex = 3; glow.Parent = root
		local glowScale = Instance.new("UIScale", glow)
		for n = 1, 14 do
			local e = Instance.new("Frame")
			e.AnchorPoint = Vector2.new(0.5, 0.5); e.Position = UDim2.new(0, 0, 0, 0)
			e.Size = UDim2.new(0, 300 + n * 55, 0, 120 + n * 24)
			e.BackgroundColor3 = Color3.fromRGB(255, 70, 150); e.BackgroundTransparency = 0.92
			e.BorderSizePixel = 0; e.ZIndex = 3; e.Parent = glow
			Instance.new("UICorner", e).CornerRadius = UDim.new(0.5, 0)
		end
		TweenService:Create(glowScale, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Scale = 1.07}):Play()

		local function Vignette(size, pos, rotation, t0, t1)
			local f = Instance.new("Frame")
			f.Size = size; f.Position = pos; f.BackgroundColor3 = Color3.new(0, 0, 0)
			f.BorderSizePixel = 0; f.ZIndex = 4; f.Parent = root
			local g = Instance.new("UIGradient", f)
			g.Rotation = rotation
			g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, t0), NumberSequenceKeypoint.new(1, t1)})
		end
		Vignette(UDim2.new(1, 0, 0.35, 0),  UDim2.new(0, 0, 0, 0),    90, 0.15, 1)
		Vignette(UDim2.new(1, 0, 0.40, 0),  UDim2.new(0, 0, 0.60, 0), 90, 1, 0.05)
		Vignette(UDim2.new(0.25, 0, 1, 0),  UDim2.new(0, 0, 0, 0),    0,  0.2, 1)
		Vignette(UDim2.new(0.25, 0, 1, 0),  UDim2.new(0.75, 0, 0, 0), 0,  1, 0.2)

		local logo = Pill(root, UDim2.new(0, 34, 0, 34), UDim2.new(0, 24, 0, 20), Vector2.new(0, 0),
			Color3.fromRGB(20, 5, 20), 0.35, PINK, 0.3, 6)
		Text(logo, "💎", Enum.Font.GothamBold, 16, WHITE, 7)
		local logoName = Instance.new("TextLabel")
		logoName.Position = UDim2.new(0, 66, 0, 20); logoName.Size = UDim2.new(0, 80, 0, 34)
		logoName.BackgroundTransparency = 1; logoName.Text = "SV"; logoName.Font = Enum.Font.GothamBold
		logoName.TextSize = 14; logoName.TextColor3 = WHITE; logoName.TextXAlignment = Enum.TextXAlignment.Left
		logoName.ZIndex = 6; logoName.Parent = root

		for k, nm in ipairs({"Home", "About", "Credits"}) do
			local pill = Pill(root, UDim2.new(0, 84, 0, 30), UDim2.new(0.5, (k - 2) * 96, 0, 22), Vector2.new(0.5, 0),
				Color3.new(0, 0, 0), 0.55, WHITE, 0.78, 6)
			Text(pill, nm, Enum.Font.GothamMedium, 12, WHITE, 7)
		end

		local verPill = Pill(root, UDim2.new(0, 64, 0, 30), UDim2.new(1, -134, 0, 22), Vector2.new(1, 0),
			Color3.new(0, 0, 0), 0.55, WHITE, 0.78, 6)
		Text(verPill, "💎", Enum.Font.GothamMedium, 12, WHITE, 7)
		local welcomePill = Pill(root, UDim2.new(0, 96, 0, 30), UDim2.new(1, -24, 0, 22), Vector2.new(1, 0),
			PINK, 0.1, Color3.fromRGB(255, 170, 205), 0.4, 6)
		Text(welcomePill, "Welcome", Enum.Font.GothamBold, 12, WHITE, 7)

		local function MakeTitle(z, color, textTransp)
			local t = Instance.new("TextLabel")
			t.AnchorPoint = Vector2.new(0.5, 0.5)
			t.Position = UDim2.new(0.5, 0, 0.42, 0)
			t.Size = UDim2.new(0.9, 0, 0, 150)
			t.BackgroundTransparency = 1
			t.Text = "SV"; t.Font = Enum.Font.GothamBlack; t.TextScaled = true
			t.TextColor3 = color; t.TextTransparency = textTransp
			t.ZIndex = z; t.Parent = root
			Instance.new("UISizeConstraint", t).MaxSize = Vector2.new(560, 150)
			Instance.new("UITextSizeConstraint", t).MaxTextSize = 120
			return t
		end
		for _, cfg in ipairs({{18, 0.93}, {10, 0.85}, {5, 0.7}}) do
			local g = MakeTitle(5, PINK, 0.6)
			local st = Instance.new("UIStroke", g)
			st.Color = PINK; st.Thickness = cfg[1]; st.Transparency = cfg[2]
		end
		local title = MakeTitle(6, WHITE, 0)
		local titleStroke = Instance.new("UIStroke", title)
		titleStroke.Color = Color3.fromRGB(255, 150, 200); titleStroke.Thickness = 1.5; titleStroke.Transparency = 0.45

		local credits = Instance.new("TextLabel")
		credits.AnchorPoint = Vector2.new(0.5, 0.5)
		credits.Position = UDim2.new(0.5, 0, 0.42, 100)
		credits.Size = UDim2.new(0.9, 0, 0, 24)
		credits.BackgroundTransparency = 1
		credits.Text = "Made by VIZER"; credits.Font = Enum.Font.GothamMedium; credits.TextSize = 15
		credits.TextColor3 = Color3.fromRGB(255, 232, 245)
		credits.ZIndex = 6; credits.Parent = root

		local glass = Pill(root, UDim2.new(0.8, 0, 0, 38), UDim2.new(0.5, 0, 0.42, 150), Vector2.new(0.5, 0.5),
			WHITE, 0.86, WHITE, 0.62, 6)
		Instance.new("UISizeConstraint", glass).MaxSize = Vector2.new(400, 38)
		Text(glass, "https://discord.gg/7U7S9bGuv", Enum.Font.GothamMedium, 12, Color3.fromRGB(255, 240, 248), 7)

		local PLAY_Y = UDim2.new(0.5, 0, 0.42, 215)
		for n = 1, 6 do
			Pill(root, UDim2.new(0, 230 + n * 14, 0, 46 + n * 10), PLAY_Y, Vector2.new(0.5, 0.5),
				PINK, 0.9, nil, 1, 5)
		end
		local play = Instance.new("TextButton")
		play.AnchorPoint = Vector2.new(0.5, 0.5)
		play.Position = PLAY_Y
		play.Size = UDim2.new(0, 230, 0, 46)
		play.BackgroundColor3 = Color3.fromRGB(255, 105, 165)
		play.AutoButtonColor = false
		play.Text = "Play"; play.Font = Enum.Font.GothamBold; play.TextSize = 18
		play.TextColor3 = WHITE
		play.ZIndex = 7; play.Parent = root
		play.Modal = true
		Instance.new("UICorner", play).CornerRadius = UDim.new(1, 0)
		local playStroke = Instance.new("UIStroke", play)
		playStroke.Color = Color3.fromRGB(255, 190, 215); playStroke.Thickness = 1.5; playStroke.Transparency = 0.25
		play.MouseEnter:Connect(function()
			TweenService:Create(play, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 140, 190)}):Play()
		end)
		play.MouseLeave:Connect(function()
			TweenService:Create(play, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 165)}):Play()
		end)

		local caption = Instance.new("TextLabel")
		caption.AnchorPoint = Vector2.new(0.5, 0.5)
		caption.Position = UDim2.new(0.5, 0, 0.42, 275)
		caption.Size = UDim2.new(0.9, 0, 0, 18)
		caption.BackgroundTransparency = 1
		caption.Text = "vizer"; caption.Font = Enum.Font.GothamMedium; caption.TextSize = 11
		caption.TextColor3 = Color3.fromRGB(255, 200, 225); caption.TextTransparency = 0.25
		caption.ZIndex = 6; caption.Parent = root

		local closing = false
		play.MouseButton1Click:Connect(function()
			if closing then return end
			closing = true
			UI.splash = false
			PlayUISound(SND.play, 0.4)
			UIS.MouseBehavior = savedMouseBehavior; UIS.MouseIconEnabled = savedMouseIcon
			if not UI.open then UI.toggle() end
			local tw = TweenService:Create(root, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1})
			tw:Play()
			tw.Completed:Connect(function()
				splashGui:Destroy()
			end)
		end)

		TweenService:Create(root, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
	end
end

do
	local new, corner, stroke = UI.new, UI.corner, UI.stroke
	local WHITE = Color3.new(1, 1, 1)
	local NS, KP, CS = NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new

	local DEF = {airGlow = 25, airStar = 20, airArea = 14, airSize = 8, airLife = 12}
	local sx = MISC.saved and MISC.saved.ext
	for k, v in pairs(DEF) do
		EXT[k] = (type(sx) == "table" and type(sx[k]) == "number") and sx[k] or v
	end
	local CDEF = {AirGlow = Color3.fromRGB(255, 255, 255), AirStar = Color3.fromRGB(70, 95, 255)}
	local sc = MISC.saved and MISC.saved.colors
	for k, c in pairs(CDEF) do
		EffectColors[k] = c
		EffectDefaults[k] = c
		local v = sc and sc[k]
		if type(v) == "table" then EffectColors[k] = Color3.fromRGB(v[1] or 255, v[2] or 255, v[3] or 255) end
	end

	local function dark(c) return (c.R + c.G + c.B) < 0.05 end
	local function rootPart()
		local ch = player.Character
		return ch and ch:FindFirstChild("HumanoidRootPart")
	end
	local function H(id, fn)
		XH[id] = function(on)
			local ok, err = pcall(fn, on)
			if not ok then
				warn("[vizer] " .. id .. ": " .. tostring(err))
				UI.notify("⚠ " .. id .. " failed")
			end
		end
	end

	local function glowLook(e)
		local s, life = EXT.airSize / 10, EXT.airLife / 10
		e.Size = NS({KP(0, s * 0.3), KP(0.4, s * 1.6), KP(1, s * 0.3)})
		e.Transparency = NS({KP(0, 1), KP(0.25, 0.1), KP(0.75, 0.1), KP(1, 1)})
		e.Lifetime = NumberRange.new(life * 0.8, life * 1.2)
	end
	local function starLook(e)
		local s, life = EXT.airSize / 10, EXT.airLife / 10
		e.Size = NS({KP(0, s * 0.2), KP(0.5, s), KP(1, s * 0.2)})
		e.Transparency = NS({KP(0, 1), KP(0.3, 0.1), KP(0.7, 0.1), KP(1, 1)})
		e.Lifetime = NumberRange.new(life * 0.8, life * 1.2)
	end
	local function boxShape(e)
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		end)
	end

	local function buildGlow(att)
		local e = Instance.new("ParticleEmitter")
		e.Name = "Glowing Core"
		e.Texture = "rbxassetid://1084970835"
		e.Brightness = 1
		e.Color = CS(EffectColors.AirGlow)
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Squash = NS(0)
		e.ZOffset = 0
		e.EmissionDirection = Enum.NormalId.Top
		e.Rate = 0
		e.Rotation = NumberRange.new(0, 0)
		e.RotSpeed = NumberRange.new(0, 0)
		e.Speed = NumberRange.new(0, 0)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 0
		e.LockedToPart = false
		boxShape(e)
		glowLook(e)
		e.Enabled = true
		e.Parent = att
		return e
	end

	local function buildStar(att)
		local c = EffectColors.AirStar
		local e = Instance.new("ParticleEmitter")
		e.Name = "CenterStar (30)"
		e.Texture = "rbxassetid://8611887703"
		e.Brightness = 6.46
		e.Color = CS(c)
		e.LightEmission = dark(c) and 0 or 0.45
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		e.Squash = NS(0)
		e.ZOffset = 0
		e.EmissionDirection = Enum.NormalId.Front
		e.Rate = 0
		e.Rotation = NumberRange.new(0, 0)
		e.RotSpeed = NumberRange.new(0, 0)
		e.Speed = NumberRange.new(0.001, 0.001)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 0
		e.LockedToPart = false
		boxShape(e)
		starLook(e)
		e.Enabled = true
		e.Parent = att
		return e
	end

	local POOL = 16
	local function newSpawner(name, build, faceCam, rateKey)
		return {name = name, build = build, faceCam = faceCam, rateKey = rateKey, pool = {}, idx = 0, acc = 0}
	end
	local SP = {
		glow = newSpawner("vizerAirGlow",  buildGlow, false, "airGlow"),
		star = newSpawner("vizerAirStars", buildStar, true,  "airStar"),
	}

	local function spInit(sp)
		for i = 1, POOL do
			local p = Instance.new("Part")
			p.Name = sp.name
			p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
			p.CastShadow = false; p.Transparency = 1
			p.Size = Vector3.new(0.2, 0.2, 0.2)
			p.Parent = workspace
			local att = Instance.new("Attachment")
			att.Name = "Middle"
			att.Parent = p
			sp.pool[i] = {part = p, e = sp.build(att)}
		end
	end
	local function spDestroy(sp)
		for _, it in ipairs(sp.pool) do
			if it.part then it.part:Destroy() end
		end
		sp.pool = {}
	end

	local function spawnOne(sp)
		local r = rootPart()
		if not r or #sp.pool == 0 then return end
		local R = EXT.airArea
		local ang = math.random() * math.pi * 2
		local dist = 3 + math.random() * math.max(1, R - 3)
		local h = -1.5 + math.random() * 9.5
		local pos = r.Position + Vector3.new(math.cos(ang) * dist, h, math.sin(ang) * dist)

		sp.idx = sp.idx % #sp.pool + 1
		local it = sp.pool[sp.idx]
		local cam = workspace.CurrentCamera
		if sp.faceCam and cam and (cam.CFrame.Position - pos).Magnitude > 0.5 then
			it.part.CFrame = CFrame.new(pos, cam.CFrame.Position)
		else
			it.part.CFrame = CFrame.new(pos)
		end
		it.e:Emit(1)
	end

	local function runSpawner(key, sp)
		sp.acc = 0
		xLoop(key, function(dt)
			sp.acc = sp.acc + dt * EXT[sp.rateKey]
			local n = 0
			while sp.acc >= 1 and n < 6 do
				sp.acc = sp.acc - 1
				n = n + 1
				spawnOne(sp)
			end
			if sp.acc > 6 then sp.acc = 0 end
		end)
	end

	H("AirGlow", function(on)
		xLoop("airglow", nil)
		spDestroy(SP.glow)
		if not on then return end
		spInit(SP.glow)
		runSpawner("airglow", SP.glow)
	end)
	H("AirStars", function(on)
		xLoop("airstars", nil)
		spDestroy(SP.star)
		if not on then return end
		spInit(SP.star)
		runSpawner("airstars", SP.star)
	end)

	local function relook()
		for _, it in ipairs(SP.glow.pool) do glowLook(it.e) end
		for _, it in ipairs(SP.star.pool) do starLook(it.e) end
	end

	local sliders = {}
	local function S(tab, prefix, min, max, key, onChange)
		local obj = UI.sliderRow(tab, prefix, min, max, EXT[key], function(v)
			EXT[key] = v
			if onChange then onChange(v) end
		end)
		table.insert(sliders, {obj, key})
	end
	UI.section("Visuals", "💫  Air particles")
	UI.add({Tab = "Visuals", Id = "AirGlow", Name = "Air glow", Sub = "Glowing orbs pop in the air", Icon = "✨", Toggle = XT("AirGlow")})
	S("Visuals", "✨  Air glow amount: ", 1, 60, "airGlow")
	UI.add({Tab = "Visuals", Id = "AirStars", Name = "Air stars", Sub = "Stars flash in the air around you", Icon = "🌟", Toggle = XT("AirStars")})
	S("Visuals", "🌟  Air stars amount: ", 1, 60, "airStar")
	S("Visuals", "💫  Air radius: ", 6, 40, "airArea")
	S("Visuals", "📏  Air particle size: ", 2, 30, "airSize", relook)
	S("Visuals", "⏳  Air particle lifetime: ", 3, 40, "airLife", relook)

	do
		local oldReset = MISC.resetAll
		if oldReset then
			MISC.resetAll = function(silent)
				oldReset(silent)
				for _, it in ipairs(sliders) do pcall(it[1].set, DEF[it[2]]) end
			end
		end
	end

	do
		local prevXC = XColorUpdate
		function XColorUpdate(key, col)
			if prevXC then prevXC(key, col) end
			if key == "AirGlow" then
				for _, it in ipairs(SP.glow.pool) do it.e.Color = CS(col) end
			elseif key == "AirStar" then
				for _, it in ipairs(SP.star.pool) do
					it.e.Color = CS(col)
					it.e.LightEmission = dark(col) and 0 or 0.45
				end
			end
		end
	end

	do
		local function colorRow(key, label, noBlack)
			local row = UI.fullRow("Settings", 72)
			local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
				BackgroundColor3 = EffectColors[key], BorderSizePixel = 0, ZIndex = 14}, row)
			corner(preview, 11); stroke(preview, WHITE, 1, 0.5)
			local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 22), Position = UDim2.new(0, 40, 0, 8),
				Text = label, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
			UI.bind(function(t) lbl.TextColor3 = t.Text end)
			local setHue = UI.hueSlider(row, 40, EffectColors[key], function(col)
				EffectColors[key] = col
				MISC.dirty()
				preview.BackgroundColor3 = col
				XColorUpdate(key, col)
			end, noBlack, true)
			if UI.colorSetters then
				UI.colorSetters[key] = function(col) preview.BackgroundColor3 = col; setHue(col) end
			end
			return row
		end

		local list = {
			{"AirGlow", "Air glow  (any color except black)", true},
			{"AirStar", "Air stars  (any color, black & white too)", false},
		}

		local pg = UI.pages.Settings
		local lab
		for _, c in ipairs(pg:GetChildren()) do
			if c:IsA("TextLabel") and c.Text:find("Effect colors", 1, true) then lab = c; break end
		end
		local base = lab and lab.LayoutOrder
		if base then
			for _, c in ipairs(pg:GetChildren()) do
				if c:IsA("GuiObject") and c ~= lab and c.LayoutOrder > base then c.LayoutOrder = c.LayoutOrder + #list end
			end
			UI.pdata.Settings.order = UI.pdata.Settings.order + #list
		end
		for i, it in ipairs(list) do
			local row = colorRow(it[1], it[2], it[3])
			if base then row.LayoutOrder = base + i end
		end
	end
end

do
	local CW = {removed = {}, token = 0}

	local function isOcean(d) return d.Name:lower() == "ocean" end

	local function hide(d)
		if CW.removed[d] ~= nil or not d.Parent then return end
		for inst in pairs(CW.removed) do
			if d:IsDescendantOf(inst) then return end
		end
		CW.removed[d] = d.Parent
		d.Parent = nil
	end

	XH.ClearWater = function(on)
		CW.token = CW.token + 1
		local tok = CW.token
		if CW.conn then CW.conn:Disconnect(); CW.conn = nil end

		if on then
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if CW.token ~= tok then return end
					if isOcean(d) then hide(d) end
					n = n + 1
					if n % 1500 == 0 then task.wait() end
				end
			end)
			CW.conn = workspace.DescendantAdded:Connect(function(d)
				if isOcean(d) then
					task.defer(function() if CW.token == tok then hide(d) end end)
				end
			end)
		else
			for inst, parent in pairs(CW.removed) do
				if parent and parent.Parent then inst.Parent = parent end
				CW.removed[inst] = nil
			end
		end
	end

	UI.section("Map", "🌊  Water")
	UI.add({Tab = "Map", Id = "ClearWater", Name = "Clear water", Sub = "Remove all Ocean parts", Icon = "🌊", Toggle = XT("ClearWater")})
end

do
	local HoverHL = { on = false, conn = nil, currentTarget = nil, highlight = nil, dist = 7 }

	EffectColors.HoverHighlight = Color3.fromRGB(255, 105, 180)
	EffectDefaults.HoverHighlight = Color3.fromRGB(255, 105, 180)

	local function UpdateHoverHL()
		if HoverHL.highlight then
			HoverHL.highlight:Destroy()
			HoverHL.highlight = nil
		end
		HoverHL.currentTarget = nil

		if HoverHL.conn then HoverHL.conn:Disconnect(); HoverHL.conn = nil end

		if HoverHL.on then
			HoverHL.conn = RunService.RenderStepped:Connect(function()
				local localChar = player.Character
				local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
				local cam = workspace.CurrentCamera

				if not localRoot or not cam then return end

				local mousePos = UIS:GetMouseLocation()
				local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)

				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {localChar}

				local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
				local targetPart = hit and hit.Instance
				local targetModel = targetPart and targetPart:FindFirstAncestorOfClass("Model")
				local targetPlr = targetModel and Players:GetPlayerFromCharacter(targetModel)

				local valid = false

				if targetPlr and targetPlr ~= player and targetPlr.Character then
					local targetRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
					if targetRoot then

						local dist = (localRoot.Position - targetRoot.Position).Magnitude
						if dist <= HoverHL.dist then
							valid = true

							if HoverHL.currentTarget ~= targetPlr then
								if HoverHL.highlight then HoverHL.highlight:Destroy() end

								local hl = Instance.new("Highlight")
								hl.Name = "vizerHoverHL"
								hl.Adornee = targetPlr.Character
								hl.FillColor = EffectColors.HoverHighlight
								hl.OutlineColor = EffectColors.HoverHighlight
								hl.FillTransparency = 0.5
								hl.OutlineTransparency = 0
								hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
								hl.Parent = targetPlr.Character

								HoverHL.highlight = hl
								HoverHL.currentTarget = targetPlr
							end
						end
					end
				end

				if not valid and HoverHL.highlight then
					HoverHL.highlight:Destroy()
					HoverHL.highlight = nil
					HoverHL.currentTarget = nil
				end
			end)
		end
	end

	UI.section("Visuals", "🎯  Hover Highlight")
	UI.add({
		Tab = "Visuals",
		Id = "HoverHighlight",
		Name = "Old hover highlight",
		Sub = "Highlights the player within 7 studs",
		Icon = "🎯",
		Toggle = function()
			HoverHL.on = not HoverHL.on
			UpdateHoverHL()
			UpdateToggleVisual("HoverHighlight", HoverHL.on)
			if HoverHL.on then MISC.dirty() end
		end
	})

	UI.sliderRow("Visuals", "🎯  Old distance: ", 19, 30, HoverHL.dist, function(v) HoverHL.dist = v end)

	do
		local row = UI.fullRow("Settings", 72)
		local preview = UI.new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = EffectColors.HoverHighlight, BorderSizePixel = 0, ZIndex = 14}, row)
		UI.corner(preview, 11); UI.stroke(preview, Color3.new(1,1,1), 1, 0.5)

		local lbl = UI.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = "🎯  Old highlight color (Hover)", Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)

		local setHue = UI.hueSlider(row, 40, EffectColors.HoverHighlight, function(col)
			EffectColors.HoverHighlight = col
			MISC.dirty()
			preview.BackgroundColor3 = col
			if HoverHL.highlight then
				HoverHL.highlight.FillColor = col
				HoverHL.highlight.OutlineColor = col
			end
		end, false, true)

		if UI.colorSetters then
			UI.colorSetters.HoverHighlight = function(col) preview.BackgroundColor3 = col; setHue(col) end
		end

		local pg = UI.pages.Settings
		local lab
		for _, c in ipairs(pg:GetChildren()) do
			if c:IsA("TextLabel") and c.Text:find("Effect colors", 1, true) then lab = c; break end
		end
		if lab then
			row.LayoutOrder = 999
		end
	end
end

do
	local NeonWorld = {saved = setmetatable({}, {__mode = "k"})}
	XH.NeonWorld = function(on)
		if on then
			for _, d in ipairs(workspace:GetDescendants()) do
				if d:IsA("BasePart") and not d:IsDescendantOf(player.Character) then
					pcall(function()
						if NeonWorld.saved[d] == nil then NeonWorld.saved[d] = {mat = d.Material, col = d.Color} end
						d.Material = Enum.Material.Neon
					end)
				end
			end
		else
			for p, info in pairs(NeonWorld.saved) do
				pcall(function()
					if p and p.Parent then p.Material = info.mat; p.Color = info.col end
				end)
			end
			NeonWorld.saved = setmetatable({}, {__mode = "k"})
		end
	end

	local Wireframe = {saved = setmetatable({}, {__mode = "k"})}
	XH.Wireframe = function(on)
		if on then
			for _, d in ipairs(workspace:GetDescendants()) do
				if d:IsA("BasePart") and not d:IsDescendantOf(player.Character) then
					pcall(function()
						if Wireframe.saved[d] == nil then Wireframe.saved[d] = d.Transparency end
						d.Transparency = 0.9
					end)
				end
			end
		else
			for p, t in pairs(Wireframe.saved) do
				pcall(function()
					if p and p.Parent then p.Transparency = t end
				end)
			end
			Wireframe.saved = setmetatable({}, {__mode = "k"})
		end
	end

	local ColorPulse = {on = false, hue = 0}
	XH.ColorPulse = function(on)
		ColorPulse.on = on
		if on then
			if not XFX.colorPulse then
				XFX.colorPulse = Instance.new("ColorCorrectionEffect")
				XFX.colorPulse.Name = "vizerColorPulse"
				XFX.colorPulse.Parent = Lighting
			end
			xLoop("cpulse", function(dt)
				ColorPulse.hue = (ColorPulse.hue + dt * 0.5) % 1
				XFX.colorPulse.TintColor = Color3.fromHSV(ColorPulse.hue, 0.6, 1)
			end)
		else
			xLoop("cpulse", nil)
			if XFX.colorPulse then XFX.colorPulse:Destroy(); XFX.colorPulse = nil end
		end
	end

	local GrayPulse = {on = false, t = 0}
	XH.GrayscalePulse = function(on)
		GrayPulse.on = on
		if on then
			if not XFX.grayp then
				XFX.grayp = Instance.new("ColorCorrectionEffect")
				XFX.grayp.Name = "vizerGrayP"
				XFX.grayp.Parent = Lighting
			end
			xLoop("grayp", function(dt)
				GrayPulse.t = GrayPulse.t + dt
				XFX.grayp.Saturation = -0.5 + 0.5 * math.sin(GrayPulse.t * 2)
			end)
		else
			xLoop("grayp", nil)
			if XFX.grayp then XFX.grayp:Destroy(); XFX.grayp = nil end
		end
	end

	local HideOthers = {saved = setmetatable({}, {__mode = "k"})}
	XH.HideOthers = function(on)
		if on then
			local acc = 0
			xLoop("hideoth", function(dt)
				acc = acc + dt
				if acc < 0.3 then return end
				acc = 0
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character then
						for _, p in ipairs(plr.Character:GetDescendants()) do
							if p:IsA("BasePart") then
								if HideOthers.saved[p] == nil then HideOthers.saved[p] = p.LocalTransparencyModifier end
								p.LocalTransparencyModifier = 1
							end
						end
					end
				end
			end)
		else
			xLoop("hideoth", nil)
			for p, v in pairs(HideOthers.saved) do
				if p and p.Parent then p.LocalTransparencyModifier = v end
			end
			HideOthers.saved = setmetatable({}, {__mode = "k"})
		end
	end

	local ShowInvisible = {saved = setmetatable({}, {__mode = "k"})}
	XH.ShowInvisible = function(on)
		if on then
			for _, d in ipairs(workspace:GetDescendants()) do
				if d:IsA("BasePart") and d.Transparency > 0 and not d:IsDescendantOf(player.Character) then
					ShowInvisible.saved[d] = d.Transparency
					d.Transparency = 0
				end
			end
		else
			for p, t in pairs(ShowInvisible.saved) do
				if p and p.Parent then p.Transparency = t end
			end
			ShowInvisible.saved = setmetatable({}, {__mode = "k"})
		end
	end

		local MaxBrightSave = nil
	XH.MaxBright = function(on)
		if on then
			if not MaxBrightSave then
				MaxBrightSave = {
					Ambient = Lighting.Ambient,
					OutdoorAmbient = Lighting.OutdoorAmbient,
					Brightness = Lighting.Brightness,
				}
			end
			xLoop("maxbright", function()
				Lighting.Ambient = Color3.fromRGB(255, 255, 255)
				Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
				Lighting.Brightness = 5
			end)
		else
			xLoop("maxbright", nil)
			if MaxBrightSave then
				Lighting.Ambient = MaxBrightSave.Ambient
				Lighting.OutdoorAmbient = MaxBrightSave.OutdoorAmbient
				Lighting.Brightness = MaxBrightSave.Brightness
				MaxBrightSave = nil
			end
		end
	end

	UI.section("World", "🌍  World Visuals")
	UI.add({Tab="World", Id="NeonWorld",      Name="Neon World",      Sub="All parts become neon",   Icon="🌈", Toggle=XT("NeonWorld")})
	UI.add({Tab="World", Id="Wireframe",      Name="Wireframe",       Sub="Walls become transparent", Icon="🔲", Toggle=XT("Wireframe")})
	UI.add({Tab="World", Id="ColorPulse",     Name="Color Pulse",     Sub="Screen color cycles",     Icon="🌈", Toggle=XT("ColorPulse")})
	UI.add({Tab="World", Id="GrayscalePulse", Name="Grayscale Pulse", Sub="Black and white pulse",   Icon="⚫", Toggle=XT("GrayscalePulse")})
	UI.add({Tab="World", Id="HideOthers",     Name="Hide Others",     Sub="Hide all other players",  Icon="👻", Toggle=XT("HideOthers")})
	UI.add({Tab="World", Id="ShowInvisible",  Name="Show Invisible",  Sub="Makes transparent parts solid", Icon="👁", Toggle=XT("ShowInvisible")})
	UI.add({Tab="World", Id="MaxBright",      Name="Max Brightness",  Sub="Force maximum lighting",  Icon="☀", Toggle=XT("MaxBright")})
end

;(function()
	local HS = game:GetService("HttpService")
	local new, corner, stroke = UI.new, UI.corner, UI.stroke
	local WHITE = Color3.new(1, 1, 1)
	local FULL = UDim2.new(1, 0, 1, 0)
	local EXF = "vizerExtras.json"

	local X = {}
	do
		local ok, raw = pcall(function() return readfile and readfile(EXF) end)
		if ok and raw then
			local ok2, d = pcall(function() return HS:JSONDecode(raw) end)
			if ok2 and type(d) == "table" then X = d end
		end
	end
	local P = {
		hover = math.clamp(tonumber(X.hover) or 19, 19, 30),
		sky   = X.skyId and tostring(X.skyId) or nil,
		music = X.musicId and tostring(X.musicId) or nil,
		fov   = tonumber(X.fov),
	}

	local origSave = MISC.save
	function MISC.save()
		origSave()
		if not MISC.ready or not writefile then return end
		pcall(function()
			writefile(EXF, HS:JSONEncode({
				hover = P.hover, skyId = P.sky, musicId = P.music, fov = P.fov,
				theme = Themes[currentTheme] and Themes[currentTheme].Name or nil,
			}))
		end)
	end

	local function lastRow(tab)
		local want = UI.pdata[tab].order - 1
		for _, c in ipairs(UI.pages[tab]:GetChildren()) do
			if c:IsA("GuiObject") and c.LayoutOrder == want then return c end
		end
	end

	do
		local vis, st = UI.pages.Visuals, UI.pages.Settings
		local cell = vis:FindFirstChild("HoverHighlight", true)
		if cell then cell:Destroy() end
		UI.rows.HoverHighlight = nil
		for i = #UI.feats, 1, -1 do
			if UI.feats[i].Id == "HoverHighlight" then table.remove(UI.feats, i) end
		end
		for _, d in ipairs(vis:GetChildren()) do
			if d:IsA("TextLabel") and d.Text:find("Hover Highlight", 1, true) then d:Destroy() end
		end
		for _, d in ipairs(vis:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text:find("Old distance", 1, true) and d.Parent then d.Parent:Destroy() break end
		end
		for i = #UI.sliders, 1, -1 do
			if UI.sliders[i].prefix:find("Old distance", 1, true) then table.remove(UI.sliders, i) end
		end
		for _, d in ipairs(st:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text:find("Old highlight color", 1, true) and d.Parent then d.Parent:Destroy() break end
		end
	end

	do
		local sc = MISC.saved and MISC.saved.colors and MISC.saved.colors.HoverHighlight
		EffectColors.HoverHighlight = Color3.fromRGB(255, 105, 180)
		EffectDefaults.HoverHighlight = Color3.fromRGB(255, 105, 180)
		if type(sc) == "table" then
			EffectColors.HoverHighlight = Color3.fromRGB(sc[1] or 255, sc[2] or 255, sc[3] or 255)
		end

		local H = {on = false}
		local function clear()
			if H.hl then H.hl:Destroy() end
			H.hl = nil; H.target = nil
		end
		local function setOn(state)
			H.on = state
			if H.conn then H.conn:Disconnect(); H.conn = nil end
			clear()
			if not state then return end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			H.conn = RunService.RenderStepped:Connect(function()
				local ch = player.Character
				local root = ch and ch:FindFirstChild("HumanoidRootPart")
				local cam = workspace.CurrentCamera
				if not root or not cam then clear() return end
				params.FilterDescendantsInstances = {ch}
				local origin, dir
				if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
					origin, dir = cam.CFrame.Position, cam.CFrame.LookVector
				else
					local m = UIS:GetMouseLocation()
					local ray = cam:ViewportPointToRay(m.X, m.Y)
					origin, dir = ray.Origin, ray.Direction
				end
				local hit = workspace:Raycast(origin, dir * 1000, params)
				local model = hit and hit.Instance:FindFirstAncestorOfClass("Model")
				local plr = model and Players:GetPlayerFromCharacter(model)
				local tr = plr and plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if tr and (root.Position - tr.Position).Magnitude <= P.hover then
					if H.target ~= plr or not H.hl or not H.hl.Parent then
						clear()
						local hl = Instance.new("Highlight")
						hl.Name = "vizerHoverHL"
						hl.Adornee = plr.Character
						hl.FillColor = EffectColors.HoverHighlight
						hl.OutlineColor = EffectColors.HoverHighlight
						hl.FillTransparency = 0.5
						hl.OutlineTransparency = 0
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = plr.Character
						H.hl = hl; H.target = plr
					end
				else
					clear()
				end
			end)
		end

		UI.section("Visuals", "🎯  Hover highlight")
		UI.add({Tab = "Visuals", Id = "HoverHighlight", Name = "Hover highlight", Sub = "Highlight the player you point at",
			Icon = "🎯", Toggle = function() setOn(not H.on); UpdateToggleVisual("HoverHighlight", H.on) end})
		UI.sliderRow("Visuals", "🎯  Hover distance: ", 19, 30, P.hover, function(v) P.hover = v end)

		local row = UI.fullRow("Settings", 72)
		row:SetAttribute("Sec", "effect colors")
		local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = EffectColors.HoverHighlight, BorderSizePixel = 0, ZIndex = 14}, row)
		corner(preview, 11); stroke(preview, WHITE, 1, 0.5)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = "🎯  Hover highlight color", Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		local setHue = UI.hueSlider(row, 40, EffectColors.HoverHighlight, function(col)
			EffectColors.HoverHighlight = col
			MISC.dirty()
			preview.BackgroundColor3 = col
			if H.hl then H.hl.FillColor = col; H.hl.OutlineColor = col end
		end, false, true)
		UI.colorSetters.HoverHighlight = function(col) preview.BackgroundColor3 = col; setHue(col) end
	end

	do
		for _, d in ipairs(UI.pages.Misc:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text:find("🎥  FOV:", 1, true) and d.Parent then
				d.Parent:Destroy()
				break
			end
		end
		UI.sliderRow("Misc", "🎥  FOV: ", 30, 120, P.fov or 70, function(v)
			P.fov = v
			local cam = workspace.CurrentCamera
			if cam then cam.FieldOfView = v end
		end)
		local r = lastRow("Misc")
		if r then r:SetAttribute("Sec", "utilities") end
		if P.fov then
			task.delay(2, function()
				local cam = workspace.CurrentCamera
				if cam then cam.FieldOfView = P.fov end
			end)
		end
	end

	do
		local function findRow(tab, text)
			local pg = UI.pages[tab]
			for _, d in ipairs(pg:GetDescendants()) do
				if d:IsA("TextLabel") and d.Parent and d.Parent.Parent == pg and d.Text:find(text, 1, true) then
					return d.Parent
				end
			end
		end
		local function hook(row, onApply, onReset)
			if not row then return nil end
			local box = row:FindFirstChildOfClass("TextBox")
			for _, b in ipairs(row:GetChildren()) do
				if b:IsA("TextButton") and b.Text == "Apply" then
					b.MouseButton1Click:Connect(function()
						local id = box and string.match(box.Text, "%d+")
						if id then onApply(id) end
					end)
				elseif b:IsA("TextButton") and b.Text == "Reset" then
					b.MouseButton1Click:Connect(function() onReset() end)
				end
			end
			return box
		end

		local function setSky(id)
			local s = Lighting:FindFirstChild("vizerCustomSky")
			if not s then s = Instance.new("Sky"); s.Name = "vizerCustomSky"; s.Parent = Lighting end
			local u = "rbxassetid://" .. id
			s.SkyboxBk = u; s.SkyboxDn = u; s.SkyboxFt = u; s.SkyboxLf = u; s.SkyboxRt = u; s.SkyboxUp = u
		end
		local skyBox = hook(findRow("World", "Custom sky"),
			function(id) P.sky = id; MISC.dirty() end,
			function() P.sky = nil; MISC.dirty() end)
		if skyBox and P.sky then skyBox.Text = P.sky; setSky(P.sky) end

		local function killLoaded()
			if P.snd then P.snd:Destroy(); P.snd = nil end
		end
		local musBox = hook(findRow("Misc", "Audio ID"),
			function(id) killLoaded(); P.music = id; MISC.dirty() end,
			function() killLoaded(); P.music = nil; MISC.dirty() end)
		if musBox and P.music then
			musBox.Text = P.music
			local s = Instance.new("Sound")
			s.Name = "vizerMusic"
			s.SoundId = "rbxassetid://" .. P.music
			s.Looped = true
			s.Volume = (EXT.mvol or 50) / 50
			s.Parent = game:GetService("SoundService")
			s:Play()
			P.snd = s
		end
		for _, sl in ipairs(UI.sliders) do
			if sl.prefix:find("Music volume", 1, true) then
				local o = sl.set
				sl.set = function(v, silent)
					o(v, silent)
					if P.snd then P.snd.Volume = sl.value / 50 end
				end
			end
		end
	end

	if #Themes <= 7 then
		local NEW = {
			{ Name = "🌿 Emerald",
			  Bg = Color3.fromRGB(8, 34, 24), Panel = Color3.fromRGB(5, 22, 16), Row = Color3.fromRGB(16, 72, 50),
			  Accent = Color3.fromRGB(60, 230, 140), Accent2 = Color3.fromRGB(170, 255, 210),
			  Text = Color3.fromRGB(230, 255, 242), Sub = Color3.fromRGB(150, 214, 184),
			  On = Color3.fromRGB(50, 210, 125), Off = Color3.fromRGB(46, 84, 70) },
			{ Name = "🍒 Crimson",
			  Bg = Color3.fromRGB(44, 8, 14), Panel = Color3.fromRGB(28, 5, 9), Row = Color3.fromRGB(88, 18, 30),
			  Accent = Color3.fromRGB(255, 64, 84), Accent2 = Color3.fromRGB(255, 150, 160),
			  Text = Color3.fromRGB(255, 236, 238), Sub = Color3.fromRGB(232, 160, 168),
			  On = Color3.fromRGB(240, 52, 72), Off = Color3.fromRGB(96, 48, 54) },
			{ Name = "🌊 Ocean",
			  Bg = Color3.fromRGB(6, 32, 40), Panel = Color3.fromRGB(4, 22, 28), Row = Color3.fromRGB(12, 70, 84),
			  Accent = Color3.fromRGB(40, 200, 210), Accent2 = Color3.fromRGB(120, 240, 235),
			  Text = Color3.fromRGB(225, 250, 252), Sub = Color3.fromRGB(140, 200, 206),
			  On = Color3.fromRGB(30, 190, 200), Off = Color3.fromRGB(42, 82, 90) },
			{ Name = "👑 Gold",
			  Bg = Color3.fromRGB(40, 30, 8), Panel = Color3.fromRGB(26, 19, 5), Row = Color3.fromRGB(84, 64, 16),
			  Accent = Color3.fromRGB(255, 200, 60), Accent2 = Color3.fromRGB(255, 235, 150),
			  Text = Color3.fromRGB(255, 248, 226), Sub = Color3.fromRGB(230, 206, 140),
			  On = Color3.fromRGB(240, 185, 40), Off = Color3.fromRGB(96, 82, 48) },
			{ Name = "🍇 Violet",
			  Bg = Color3.fromRGB(30, 10, 50), Panel = Color3.fromRGB(20, 6, 36), Row = Color3.fromRGB(62, 24, 104),
			  Accent = Color3.fromRGB(190, 90, 255), Accent2 = Color3.fromRGB(230, 160, 255),
			  Text = Color3.fromRGB(248, 236, 255), Sub = Color3.fromRGB(200, 166, 230),
			  On = Color3.fromRGB(176, 80, 250), Off = Color3.fromRGB(78, 52, 104) },
			{ Name = "☢ Toxic",
			  Bg = Color3.fromRGB(10, 18, 6), Panel = Color3.fromRGB(6, 12, 4), Row = Color3.fromRGB(26, 50, 10),
			  Accent = Color3.fromRGB(160, 255, 40), Accent2 = Color3.fromRGB(220, 255, 120),
			  Text = Color3.fromRGB(240, 255, 225), Sub = Color3.fromRGB(170, 206, 130),
			  On = Color3.fromRGB(140, 235, 30), Off = Color3.fromRGB(52, 72, 36) },
			{ Name = "🍃 Mint (light)",
			  Bg = Color3.fromRGB(234, 248, 240), Panel = Color3.fromRGB(255, 255, 255), Row = Color3.fromRGB(212, 236, 222),
			  Accent = Color3.fromRGB(40, 160, 110), Accent2 = Color3.fromRGB(110, 210, 160),
			  Text = Color3.fromRGB(20, 50, 38), Sub = Color3.fromRGB(80, 120, 100),
			  On = Color3.fromRGB(40, 170, 115), Off = Color3.fromRGB(196, 216, 204), KnobOff = Color3.fromRGB(120, 150, 135),
			  TitleStroke = Color3.fromRGB(70, 170, 125),
			  Shimmer = {Color3.fromRGB(20, 70, 50), Color3.fromRGB(60, 170, 120), Color3.fromRGB(140, 220, 180)} },
		}
		for _, t in ipairs(NEW) do table.insert(Themes, t) end
	end

	local function addThemeRow(i, thm)
		local row = UI.fullRow("Settings", 44)
		row:SetAttribute("Sec", "theme")
		for j, col in ipairs({thm.Bg, thm.Accent, thm.Accent2, thm.On}) do
			local dot = new("Frame", {Position = UDim2.new(0, 12 + (j - 1) * 22, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 6}, row)
			corner(dot, 8); stroke(dot, WHITE, 1, 0.6)
		end
		local nameLbl = new("TextLabel", {Position = UDim2.new(0, 112, 0, 0), Size = UDim2.new(1, -170, 1, 0),
			BackgroundTransparency = 1, Text = thm.Name, Font = Enum.Font.GothamBold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, row)
		UI.bind(function(t) nameLbl.TextColor3 = t.Text end)
		local check = new("TextLabel", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold,
			TextSize = 18, TextColor3 = Color3.fromRGB(110, 230, 150), ZIndex = 6}, row)
		local btn = new("TextButton", {Size = FULL, BackgroundTransparency = 1, Text = "", ZIndex = 9}, row)
		btn.MouseButton1Click:Connect(function()
			PlayUISound(SND.click, 0.45, 1.1)
			currentTheme = i
			MISC.dirty()
			ApplyThemeToAll()
		end)
		UI.bind(function() check.Visible = (currentTheme == i) end)
	end
	for i = 8, #Themes do addThemeRow(i, Themes[i]) end

	local function stripKeys()
		for _, f in ipairs(UI.feats) do
			if f.Tab == "Visuals" then
				f.Key = nil; f.DefKey = nil; f.NoKey = true
				local r = UI.rows[f.Id]
				if r then r.updateSub() end
			end
		end
	end
	stripKeys()

	local oldRebind = UI.startRebind
	UI.startRebind = function(feat)
		if feat.NoKey then UI.notify("Visual effects have no hotkeys") return end
		oldRebind(feat)
	end
	local oldApply = MISC.applyConfig
	if oldApply then MISC.applyConfig = function(d) oldApply(d); stripKeys() end end
	local oldReset = MISC.resetAll
	if oldReset then MISC.resetAll = function(s) oldReset(s); stripKeys() end end

	do
		local used = {}
		for _, f in ipairs(UI.feats) do
			if f.Key then
				if used[f.Key] then
					f.Key = nil
					local r = UI.rows[f.Id]
					if r then r.updateSub() end
				else
					used[f.Key] = true
				end
			end
		end
		local function ensureKey(id, k)
			for _, f in ipairs(UI.feats) do
				if f.Id == id and not f.Key and not used[k] then
					f.Key = k; f.DefKey = k; used[k] = true
					local r = UI.rows[id]
					if r then r.updateSub() end
				end
			end
		end
		ensureKey("SpawnSafePallet", Enum.KeyCode.PageUp)
		ensureKey("SpawnFlyBug", Enum.KeyCode.PageDown)
	end

	local LAYOUT = {
		Visuals = {
			{"✨  Effects",          {"visual effects", "more effects"}},
			{"☁  Auras & light",    {"auras", "light & glow"}},
			{"💫  Air particles",    {"air particles"}},
			{"🎯  Hover highlight",  {"hover highlight"}},
			{"🎞  Post effects",     {"post effects"}},
			{"🎥  Camera & screen",  {"camera & screen"}},
		},
		Movement = {
			{"🚀  Speed",            {"speed"}},
			{"🕊  Flight",           {"flight"}},
			{"🏃  Jumping",          {"jumping"}},
			{"🌀  More movement",    {"more movement", "extra movement"}},
		},
		Player = {
			{"👤  Character",        {"character", "body", "view", "tab list"}},
			{"🦋  Accessories",      {"accessories"}},
			{"💚  Friends",          {"friends"}},
		},
		World = {
			{"🌍  Environment",      {"environment"}},
			{"🕒  Time & light",     {"time & light"}},
			{"☁  Sky",              {"sky", "sky & weather"}},
			{"🌈  World visuals",    {"world visuals"}},
			{"📦  Pallets",          {"pallets"}},
		},
		Map = {
			{"🛠  Spawn tools",      {"spawn tools"}},
			{"🌊  Water",            {"water"}},
			{"🎨  Map colors",       {"map colors"}},
		},
		Misc = {
			{"🔧  Utilities",        {"utilities"}},
			{"🔭  Camera tools",     {"stretch screen", "hold zoom"}},
			{"📊  HUD",              {"hud"}},
			{"🧰  Tools",            {"more utilities", "extra tools", "server tools"}},
			{"🎬  Players",          {"players"}},
			{"📍  Teleport",         {"teleport"}},
			{"🌐  Server",           {"vip server", "server"}},
			{"🎵  Music player",     {"music player"}},
		},
		Settings = {
			{"🔊  Interface",        {"interface"}},
			{"🖼  Menu image",       {"menu image"}},
			{"💾  Config manager",   {"config manager"}},
			{"🎨  Theme",            {"theme"}},
			{"🌈  Effect colors",    {"effect colors"}},
		},
	}
	local MOVE = {
		Visuals = {
			Rainbow = "visual effects", Disco = "visual effects",
			Sepia = "post effects", Vibrant = "post effects", BW = "post effects", Vignette = "post effects", Bars = "post effects",
			Compass = "camera & screen", ClickFx = "camera & screen", Flashlight = "camera & screen",
		},
		World = { Clouds = "environment" },
		Misc = {
			FpsHud = "hud", PingHud = "hud", CoordsHUD = "hud", ClockHUD = "hud", PlayersHUD = "hud",
			SpeedHUD = "hud", SessionHUD = "hud", ServerHUD = "hud",
			Rejoin = "server", ServerHop = "server", VipServer = "server",
			JoinAlerts = "more utilities", CamNoclip = "hold zoom", FreeCursor = "hold zoom",
		},
	}

	local function nkey(t) return (t:gsub("^[^%w]+", "")):lower() end

	local function organizeTab(tab)
		local pg = UI.pages[tab]
		local layout, move = LAYOUT[tab] or {}, MOVE[tab] or {}
		local kids = {}
		for i, c in ipairs(pg:GetChildren()) do
			if c:IsA("GuiObject") then table.insert(kids, {c = c, i = i}) end
		end
		table.sort(kids, function(a, b)
			if a.c.LayoutOrder ~= b.c.LayoutOrder then return a.c.LayoutOrder < b.c.LayoutOrder end
			return a.i < b.i
		end)

		local pre = {cells = {}, rows = {}}
		local secs, cur, oldGrids, forced = {}, pre, {}, {}
		for _, k in ipairs(kids) do
			local c = k.c
			local tag = c:GetAttribute("Sec")
			if tag then
				table.insert(forced, {key = tag, c = c, cell = false})
			elseif c:IsA("TextLabel") then
				cur = {key = nkey(c.Text), hdr = c, cells = {}, rows = {}}
				table.insert(secs, cur)
			elseif c.Name == "Grid" then
				local cs = {}
				for _, cell in ipairs(c:GetChildren()) do
					if cell:IsA("GuiObject") then table.insert(cs, cell) end
				end
				table.sort(cs, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
				for _, cell in ipairs(cs) do
					local mk = move[cell.Name]
					if mk then table.insert(forced, {key = mk, c = cell, cell = true})
					else table.insert(cur.cells, cell) end
				end
				table.insert(oldGrids, c)
			else
				table.insert(cur.rows, c)
			end
		end

		local byKey = {}
		for idx, def in ipairs(layout) do
			for _, s in ipairs(def[2]) do byKey[s] = idx end
		end
		local groups, extras = {}, {}
		local function ensure(idx)
			local g = groups[idx]
			if not g then
				g = {title = layout[idx][1], rename = true, cells = {}, rows = {}}
				groups[idx] = g
			end
			return g
		end
		for _, sec in ipairs(secs) do
			local idx = byKey[sec.key]
			if idx then
				local g = ensure(idx)
				if sec.hdr then
					if g.hdr then sec.hdr:Destroy() else g.hdr = sec.hdr end
				end
				for _, x in ipairs(sec.cells) do table.insert(g.cells, x) end
				for _, x in ipairs(sec.rows) do table.insert(g.rows, x) end
			else
				table.insert(extras, sec)
			end
		end
		for _, f in ipairs(forced) do
			local idx = byKey[f.key]
			if idx then
				local g = ensure(idx)
				table.insert(f.cell and g.cells or g.rows, f.c)
			else
				table.insert(f.cell and pre.cells or pre.rows, f.c)
			end
		end

		local ordered = {pre}
		for idx = 1, #layout do if groups[idx] then table.insert(ordered, groups[idx]) end end
		for _, e in ipairs(extras) do table.insert(ordered, e) end

		local order = 0
		local function nx() order = order + 1; return order end
		for _, sec in ipairs(ordered) do
			if #sec.cells == 0 and #sec.rows == 0 then
				if sec.hdr then sec.hdr:Destroy() end
			else
				if sec.rename and not sec.hdr then
					local l = new("TextLabel", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
						Text = "  " .. sec.title, Font = Enum.Font.GothamBold, TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, pg)
					UI.bind(function(t) l.TextColor3 = t.Accent end)
					sec.hdr = l
				end
				if sec.hdr then
					if sec.rename then sec.hdr.Text = "  " .. sec.title end
					sec.hdr.LayoutOrder = nx()
				end
				local n = #sec.cells
				local pairsN = n - (n % 2)
				if pairsN > 0 then
					local grid = new("Frame", {Name = "Grid", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1, LayoutOrder = nx()}, pg)
					new("UIGridLayout", {CellSize = UDim2.new(0.5, -5, 0, 46), CellPadding = UDim2.new(0, 8, 0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder}, grid)
					for i = 1, pairsN do
						sec.cells[i].LayoutOrder = i
						sec.cells[i].Parent = grid
					end
				end
				if n % 2 == 1 then
					local wrap = new("Frame", {Name = "Wide", Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1,
						LayoutOrder = nx()}, pg)
					local cell = sec.cells[n]
					cell.Size = FULL
					cell.Parent = wrap
				end
				for _, r in ipairs(sec.rows) do r.LayoutOrder = nx() end
			end
		end
		for _, g in ipairs(oldGrids) do g:Destroy() end
		UI.pdata[tab].order = order + 1
		UI.pdata[tab].grid = nil
	end

	for tab in pairs(UI.pages) do
		if tab ~= "Search" then
			local ok, err = pcall(organizeTab, tab)
			if not ok then warn("[vizer] organize " .. tab .. ": " .. tostring(err)) end
		end
	end

	if X.theme then
		for i, t in ipairs(Themes) do
			if t.Name == X.theme and i ~= currentTheme then
				currentTheme = i
				ApplyThemeToAll()
				break
			end
		end
	end

	UI.switch(UI.active or "Visuals")
end)()

;(function()
	local HS = game:GetService("HttpService")
	local new, corner, stroke = UI.new, UI.corner, UI.stroke
	local WHITE = Color3.new(1, 1, 1)
	local FILE = "vizerCustomPallet.json"
	local PALLET = "PalletLightBrown"
	local OTHERS = {"Pallets", "Pallets2", "Pallets3", "PalletBlack", "PalletSmoke"}

	local CP = {
		on = false, all = false, gen = 0, scanGen = 0,
		color = Color3.fromRGB(255, 80, 160), mat = "", glow = 0, decal = "", rot = 90,
		known = setmetatable({}, {__mode = "k"}),
		styled = setmetatable({}, {__mode = "k"}),
		saved = setmetatable({}, {__mode = "k"}),
	}

	pcall(function()
		if readfile and isfile and isfile(FILE) then
			local d = HS:JSONDecode(readfile(FILE))
			if type(d) == "table" then
				if type(d.c) == "table" then CP.color = Color3.fromRGB(d.c[1] or 255, d.c[2] or 255, d.c[3] or 255) end
				if type(d.m) == "string" and (d.m == "" or pcall(function() return Enum.Material[d.m] end)) then CP.mat = d.m end
				if type(d.g) == "number" then CP.glow = math.clamp(d.g, 0, 100) end
				if type(d.d) == "string" then CP.decal = d.d:match("%d+") or "" end
				if type(d.r) == "number" then CP.rot = d.r end
			end
		end
	end)

	function CP.save()
		if CP.sq then return end
		CP.sq = true
		task.delay(1, function()
			CP.sq = false
			pcall(function()
				if not writefile then return end
				local c = CP.color
				writefile(FILE, HS:JSONEncode({
					c = {math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)},
					m = CP.mat, g = CP.glow, d = CP.decal, r = CP.rot,
				}))
			end)
		end)
	end

	local function partsOf(pallet)
		local list = {}
		if pallet:IsA("BasePart") then
			table.insert(list, pallet)
		else
			for _, o in ipairs(pallet:GetDescendants()) do
				if o:IsA("BasePart") and o.Name ~= "Shadoweffect" and not o.Name:find("vizerPalletCP", 1, true) then
					table.insert(list, o)
				end
			end
		end
		return list
	end

	local FACES = {
		{Enum.NormalId.Top,    Vector3.new(0, 1, 0),  1},
		{Enum.NormalId.Bottom, Vector3.new(0, -1, 0), 1},
		{Enum.NormalId.Front,  Vector3.new(0, 0, -1), 2},
		{Enum.NormalId.Back,   Vector3.new(0, 0, 1),  2},
		{Enum.NormalId.Left,   Vector3.new(-1, 0, 0), 3},
		{Enum.NormalId.Right,  Vector3.new(1, 0, 0),  3},
	}
	local function faceArea(s, k)
		if k == 1 then return s.X * s.Z elseif k == 2 then return s.X * s.Y else return s.Z * s.Y end
	end
	local function findTop(pallet)
		local bp, bf, bs = nil, nil, -math.huge
		for _, p in ipairs(partsOf(pallet)) do
			for _, f in ipairs(FACES) do
				local ny = p.CFrame:VectorToWorldSpace(f[2]).Y
				if ny > 0.5 then
					local score = faceArea(p.Size, f[3]) * ny * (1 + (p.Position.Y + p.Size.Y / 2) / 1000)
					if score > bs then bs = score; bp = p; bf = f[1] end
				end
			end
		end
		return bp, bf
	end

	local function nested(d)
		local c = d.Parent
		while c and c ~= workspace do
			if c.Name == PALLET then return true end
			c = c.Parent
		end
		return false
	end

	local function mine(p)
		local nm = player.Name:lower()
		local c = p.Parent
		while c and c ~= workspace do
			local n = c.Name:lower()
			if n == nm or (#nm >= 4 and n:find(nm, 1, true)) then return true end
			c = c.Parent
		end
		for _, part in ipairs(partsOf(p)) do
			local ok, owner = pcall(function() return part:GetNetworkOwner() end)
			if ok and owner == player then return true end
		end
		return false
	end

	local function clean(pallet)
		for _, o in ipairs(pallet:GetDescendants()) do
			if o.Name == "vizerPalletCPDecal" or o.Name == "vizerPalletCPLight" then o:Destroy() end
		end
	end

	local function style(pallet)
		local sv = CP.saved[pallet]
		if not sv then sv = {parts = {}, tex = {}}; CP.saved[pallet] = sv end
		local list = partsOf(pallet)
		local biggest, bv = nil, 0
		for _, p in ipairs(list) do
			if not sv.parts[p] then sv.parts[p] = {c = p.Color, m = p.Material} end
			p.Color = CP.color
			if CP.mat ~= "" then
				pcall(function() p.Material = Enum.Material[CP.mat] end)
			else
				p.Material = sv.parts[p].m
			end
			local v = p.Size.X * p.Size.Y * p.Size.Z
			if v > bv then bv = v; biggest = p end
		end

		clean(pallet)
		local hasDecal = CP.decal ~= ""
		for _, o in ipairs(pallet:GetDescendants()) do
			if (o:IsA("Decal") or o:IsA("Texture")) and not o.Name:find("vizerPalletCP", 1, true) then
				if sv.tex[o] == nil then sv.tex[o] = o.Transparency end
				o.Transparency = hasDecal and 1 or sv.tex[o]
			end
		end

		if hasDecal then
			local top, face = findTop(pallet)
			if top and face then
				local d = Instance.new("Decal")
				d.Name = "vizerPalletCPDecal"
				d.Face = face
				d.Texture = "rbxassetid://" .. CP.decal
				d.Color3 = WHITE
				pcall(function() d.Rotation = CP.rot end)
				pcall(function() d.EmissiveStrength = CP.glow / 50 end)
				d.Parent = top
			end
		end

		if CP.glow > 0 and biggest then
			local l = Instance.new("PointLight")
			l.Name = "vizerPalletCPLight"
			l.Color = CP.color
			l.Brightness = CP.glow / 100 * 4
			l.Range = 8 + CP.glow / 100 * 10
			l.Shadows = false
			l.Parent = biggest
		end
	end

	local function restore(pallet)
		local sv = CP.saved[pallet]
		clean(pallet)
		if sv then
			for p, i in pairs(sv.parts) do
				if p.Parent then p.Color = i.c; p.Material = i.m end
			end
			for o, t in pairs(sv.tex) do
				if o.Parent then o.Transparency = t end
			end
		end
		CP.saved[pallet] = nil
		CP.styled[pallet] = nil
	end

	function CP.tick()
		if not CP.on then return end
		local now = os.clock()
		for p, added in pairs(CP.known) do
			if not p.Parent then
				CP.known[p] = nil; CP.styled[p] = nil; CP.saved[p] = nil
			elseif CP.styled[p] ~= CP.gen and now - added > 0.4 then
				if CP.all or mine(p) then
					pcall(style, p)
					CP.styled[p] = CP.gen
				end
			end
		end
	end

	function CP.change()
		CP.save()
		CP.gen = CP.gen + 1
		local my = CP.gen
		task.delay(0.2, function()
			if CP.gen == my and CP.on then CP.tick() end
		end)
	end

	local function scan(sg)
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if CP.scanGen ~= sg then return end
			if d.Name == PALLET and (d:IsA("Model") or d:IsA("BasePart")) and not nested(d) then
				CP.known[d] = 0
			end
			n = n + 1
			if n % 1500 == 0 then task.wait() end
		end
		CP.tick()
	end

	local function setCustom(state)
		if state == CP.on then return end
		if state then
			for _, id in ipairs(OTHERS) do
				local r = UI.rows[id]
				if r and r.state then pcall(r.feat.Toggle) end
			end
		end
		CP.on = state
		XS.PalletCustom = state
		UpdateToggleVisual("PalletCustom", state)
		CP.scanGen = CP.scanGen + 1
		if CP.conn then CP.conn:Disconnect(); CP.conn = nil end
		xLoop("palcustom", nil)

		if state then
			CP.gen = CP.gen + 1
			local sg = CP.scanGen
			task.spawn(scan, sg)
			CP.conn = workspace.DescendantAdded:Connect(function(d)
				if d.Name == PALLET and (d:IsA("Model") or d:IsA("BasePart")) and not nested(d) then
					CP.known[d] = os.clock()
				end
			end)
			local acc = 0
			xLoop("palcustom", function(dt)
				acc = acc + dt
				if acc < 1 then return end
				acc = 0
				CP.tick()
			end)
		else
			for p in pairs(CP.saved) do pcall(restore, p) end
		end
	end

	for _, id in ipairs(OTHERS) do
		local r = UI.rows[id]
		if r then
			local old = r.feat.Toggle
			r.feat.Toggle = function()
				if CP.on then setCustom(false) end
				old()
			end
		end
	end

	UI.section("World", "🎨  Custom pallet")
	UI.add({Tab = "World", Id = "PalletCustom", Name = "Custom pallet", Sub = "Your color, material, glow, decal",
		Icon = "🎨", Toggle = function() setCustom(not CP.on) end})

	do
		local row = UI.fullRow("World", 72)
		local preview = new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = CP.color, BorderSizePixel = 0, ZIndex = 14}, row)
		corner(preview, 11); stroke(preview, WHITE, 1, 0.5)
		local lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = "🎨  Pallet color", Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		local setCpHue = UI.hueSlider(row, 40, CP.color, function(col)
			CP.color = col
			preview.BackgroundColor3 = col
			CP.change()
		end, false, true)
		MISC.cpColor = {
			get = function() return CP.color end,
			set = function(col)
				CP.color = col
				preview.BackgroundColor3 = col
				setCpHue(col)
				CP.change()
			end,
		}
	end

	do
		local items = {{text = "↺  Original", value = ""}}
		local names = {}
		for _, m in ipairs(Enum.Material:GetEnumItems()) do
			if m ~= Enum.Material.Air and m ~= Enum.Material.Water then table.insert(names, m.Name) end
		end
		table.sort(names)
		for _, n in ipairs(names) do table.insert(items, {text = n, value = n}) end
		if UI.pickRow then
			UI.pickRow("World", "🧱  Material", items, function() return CP.mat end,
				function(v) CP.mat = v; CP.change() end, 3, 190)
		else
			warn("[vizer] UI.pickRow not found: material list skipped")
		end
	end

	UI.sliderRow("World", "✨  Pallet glow: ", 0, 100, CP.glow, function(v)
		CP.glow = v
		CP.change()
	end)

	do
		local before = UI.pdata.World.order
		UI.idRow("World", "🖼  Custom decal: paste an ID (Reset = original)", "rbxassetid://... or just the number",
			function(id)
				CP.decal = id
				CP.change()
				return "✓ Decal applied"
			end,
			function()
				CP.decal = ""
				CP.change()
				return "↺ Original decal"
			end)
		for _, c in ipairs(UI.pages.World:GetChildren()) do
			if c:IsA("Frame") and c.LayoutOrder == before then
				local box = c:FindFirstChildOfClass("TextBox")
				if box and CP.decal ~= "" then box.Text = CP.decal end
			end
		end
	end

	if UI.pickRow then
		UI.pickRow("World", "🔄  Decal rotation", {
			{text = "0°", value = 0}, {text = "90°", value = 90}, {text = "180°", value = 180}, {text = "270°", value = 270},
		}, function() return CP.rot end, function(v) CP.rot = v; CP.change() end, 4, 90)
	end
end)()

do
	local NS, KP, CS, CK = NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new, ColorSequenceKeypoint.new

	local DEF = {srRadius = 40, srAmount = 500, spRadius = 60, spAmount = 40}
	local sx = MISC.saved and MISC.saved.ext
	for k, v in pairs(DEF) do
		EXT[k] = (type(sx) == "table" and type(sx[k]) == "number") and sx[k] or v
	end

	local SIZE = NS({KP(0, 0, 0), KP(1, 1.06, 0.625)})
	local TRANS = NS({KP(0, 1, 0), KP(0.499, 0, 0), KP(1, 1, 0)})

	local SPEC = {
		{name = "dots", squash = 0, off = 0},
		{name = "specs", squash = 1, off = 0.33},
		{name = "specs", squash = 1, off = 0.66},
	}

	local SR = {part = nil, list = {}, lastSize = 0, acc = 0}

	local function rootPart()
		local ch = player.Character
		return ch and ch:FindFirstChild("HumanoidRootPart")
	end

	local function buildEmitter(spec, parent)
		local e = Instance.new("ParticleEmitter")
		e.Name = spec.name
		e.Texture = "rbxassetid://1084997326"
		e.Brightness = 50
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.VelocityParallel
		e.Squash = NS(spec.squash)
		e.Size = SIZE
		e.Transparency = TRANS
		e.ZOffset = 1
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(3, 3)
		e.Rate = EXT.srAmount
		e.Rotation = NumberRange.new(90, 90)
		e.RotSpeed = NumberRange.new(0, 0)
		e.Speed = NumberRange.new(6, 6)
		e.SpreadAngle = Vector2.new(10000, 10000)
		e.Acceleration = Vector3.new(0, -20, 0)
		e.Drag = 0
		e.LockedToPart = false
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Sphere
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			e.ShapePartial = 1
			e.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		end)
		e.Enabled = true
		e.Parent = parent
		return e
	end

	local function paintColors()
		local t = os.clock() * 0.3
		for _, it in ipairs(SR.list) do
			local keys = {}
			for k = 0, 6 do
				table.insert(keys, CK(k / 6, Color3.fromHSV((t + it.off + k / 6) % 1, 0.85, 1)))
			end
			it.e.Color = CS(keys)
		end
	end

	local SP = {part = nil, e = nil, lastSize = 0}
	local SP_TRANS = NS({KP(0, 1, 0), KP(0.0515, 0, 0), KP(0.926, 0, 0), KP(1, 1, 0)})

	local function stopSpecks()
		xLoop("specks", nil)
		if SP.part then SP.part:Destroy() end
		SP.part = nil
		SP.e = nil
		SP.lastSize = 0
	end

	local function startSpecks()
		stopSpecks()
		local p = Instance.new("Part")
		p.Name = "Specks"
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Transparency = 1
		p.Size = Vector3.new(EXT.spRadius * 2, EXT.spRadius * 2, EXT.spRadius * 2)
		SP.lastSize = EXT.spRadius
		local r = rootPart()
		p.CFrame = CFrame.new(r and r.Position or Vector3.new(0, 0, 0))
		p.Parent = workspace
		SP.part = p
		local e = Instance.new("ParticleEmitter")
		e.Name = "ParticleEmitter"
		e.Texture = "rbxassetid://173642823"
		e.Brightness = 1
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Orientation = Enum.ParticleOrientation.FacingCamera
		e.Size = NS(4)
		e.Squash = NS(0)
		e.Transparency = SP_TRANS
		e.ZOffset = 3
		e.EmissionDirection = Enum.NormalId.Top
		e.Lifetime = NumberRange.new(10, 10)
		e.Rate = EXT.spAmount
		e.Rotation = NumberRange.new(0, 135)
		e.RotSpeed = NumberRange.new(10, 20)
		e.Speed = NumberRange.new(0, 0)
		e.SpreadAngle = Vector2.new(0, 0)
		e.Acceleration = Vector3.new(0, 0, 0)
		e.Drag = 0
		e.LockedToPart = false
		pcall(function()
			e.Shape = Enum.ParticleEmitterShape.Box
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		end)
		e.Enabled = true
		e.Parent = p
		SP.e = e
		local acc = 0
		xLoop("specks", function(dt)
			local part = SP.part
			if not part or not part.Parent then return end
			local root = rootPart()
			if root then part.CFrame = CFrame.new(root.Position) end
			if SP.lastSize ~= EXT.spRadius then
				SP.lastSize = EXT.spRadius
				part.Size = Vector3.new(EXT.spRadius * 2, EXT.spRadius * 2, EXT.spRadius * 2)
			end
			acc = acc + dt
			if acc >= 0.05 then
				acc = 0
				local t = os.clock() * 0.3
				local keys = {}
				for k = 0, 6 do
					table.insert(keys, CK(k / 6, Color3.fromHSV((t + k / 6) % 1, 0.85, 1)))
				end
				e.Color = CS(keys)
			end
		end)
	end

	local function stop()
		xLoop("starrain", nil)
		if SR.part then SR.part:Destroy() end
		SR.part = nil
		SR.list = {}
		SR.lastSize = 0
	end

	local function start()
		stop()
		local p = Instance.new("Part")
		p.Name = "StarRain"
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Transparency = 1
		p.Size = Vector3.new(EXT.srRadius * 2, EXT.srRadius * 2, EXT.srRadius * 2)
		SR.lastSize = EXT.srRadius
		local r = rootPart()
		p.CFrame = CFrame.new(r and r.Position or Vector3.new(0, 0, 0))
		p.Parent = workspace
		SR.part = p
		for _, spec in ipairs(SPEC) do
			table.insert(SR.list, {e = buildEmitter(spec, p), off = spec.off})
		end
		paintColors()
		SR.acc = 0
		xLoop("starrain", function(dt)
			local part = SR.part
			if not part or not part.Parent then return end
			local root = rootPart()
			if root then part.CFrame = CFrame.new(root.Position) end
			if SR.lastSize ~= EXT.srRadius then
				SR.lastSize = EXT.srRadius
				part.Size = Vector3.new(EXT.srRadius * 2, EXT.srRadius * 2, EXT.srRadius * 2)
			end
			SR.acc = SR.acc + dt
			if SR.acc >= 0.05 then
				SR.acc = 0
				paintColors()
			end
		end)
	end

	XH.StarRain = function(on)
		local ok, err = pcall(function()
			if on then start() else stop() end
		end)
		if not ok then
			warn("[vizer] StarRain: " .. tostring(err))
			UI.notify("⚠ StarRain failed")
		end
	end

	XH.Specks = function(on)
		local ok, err = pcall(function()
			if on then startSpecks() else stopSpecks() end
		end)
		if not ok then
			warn("[vizer] Specks: " .. tostring(err))
			UI.notify("⚠ Specks failed")
		end
	end

	local sliders = {}
	local function S(prefix, min, max, key, onChange)
		local obj = UI.sliderRow("Visuals", prefix, min, max, EXT[key], function(v)
			EXT[key] = v
			if onChange then onChange(v) end
		end)
		table.insert(sliders, {obj, key})
	end

	UI.section("Visuals", "🌠  Star rain")
	UI.add({Tab = "Visuals", Id = "StarRain", Name = "Star rain", Sub = "Color-changing stars fall around you", Icon = "🌠", Toggle = XT("StarRain")})
	S("🌠  Star rain radius: ", 10, 200, "srRadius")
	S("🌠  Star rain amount: ", 20, 500, "srAmount", function(v)
		for _, it in ipairs(SR.list) do it.e.Rate = v end
	end)

	UI.section("Visuals", "✨  Specks")
	UI.add({Tab = "Visuals", Id = "Specks", Name = "Specks", Sub = "Color-changing specks float around you", Icon = "✨", Toggle = XT("Specks")})
	S("✨  Specks radius: ", 10, 200, "spRadius")
	S("✨  Specks amount: ", 5, 300, "spAmount", function(v)
		if SP.e then SP.e.Rate = v end
	end)

	local oldReset = MISC.resetAll
	if oldReset then
		MISC.resetAll = function(silent)
			oldReset(silent)
			for _, it in ipairs(sliders) do pcall(it[1].set, DEF[it[2]]) end
		end
	end
end

do
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local C = Color3.fromRGB
	local V3 = Vector3.new
	local NS, KP, CS, CK = NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new, ColorSequenceKeypoint.new
	local WHITE = Color3.new(1, 1, 1)

	local sx = MISC.saved and MISC.saved.ext
	EXT.trMode = (type(sx) == "table" and type(sx.trMode) == "number") and sx.trMode or 2

	local STYLES = {
		{name = "1.  Classic", col = C(120, 0, 255)},
		{name = "2.  Comet",      col = C(255, 45, 70),  strands = 2, lines = 0, sparkRate = 45,  sparkSpeed = NumberRange.new(1, 4), rings = false},
		{name = "3.  Star",       col = C(255, 165, 25), strands = 0, lines = 0, sparkRate = 40,  sparkSpeed = NumberRange.new(3, 9), sparkTex = "rbxassetid://8611887703", sparkSize = 0.9, rings = false},
		{name = "4.  Classic 2",   col = C(245, 50, 230), strands = 0, lines = 5, sparkRate = 70,  sparkSpeed = NumberRange.new(1, 5), rings = false},
		{name = "5.  Spiral",      col = C(40, 150, 255), strands = 3, lines = 0, sparkRate = 40,  sparkSpeed = NumberRange.new(1, 4), rings = false},
		{name = "6.  Ring",        col = C(165, 70, 255), strands = 0, lines = 0, sparkRate = 45,  sparkSpeed = NumberRange.new(1, 4), rings = true},
	}
	local ITEMS = {}
	for i, st in ipairs(STYLES) do table.insert(ITEMS, {text = st.name, value = i}) end

	local TR = {objs = {}, layers = {}, strands = {}, emitters = {}, root = nil, ringAcc = 0}

	local function palette()
		local main = EffectColors.FireTrail
		return main, main:Lerp(WHITE, 0.55)
	end
	local function isDark(c) return (c.R + c.G + c.B) < 0.05 end

	local function add(o)
		table.insert(TR.objs, o)
		return o
	end

	local function attach(root, pos)
		local a = add(Instance.new("Attachment"))
		a.Position = pos
		a.Parent = root
		return a
	end

	local function mkTrail(root, p0, p1, life, colorFn, trans, width)
		local a0, a1 = attach(root, p0), attach(root, p1)
		local t = add(Instance.new("Trail"))
		local main, edge = palette()
		t.Attachment0 = a0
		t.Attachment1 = a1
		t.Lifetime = life
		t.MinLength = 0.02
		t.FaceCamera = true
		t.LightEmission = isDark(main) and 0 or 1
		t.LightInfluence = 0
		t.Color = colorFn(main, edge)
		t.Transparency = trans
		t.WidthScale = width
		t.Parent = root
		table.insert(TR.layers, {o = t, fn = colorFn, trail = true})
		return a0, a1
	end

	local function recolor()
		local main, edge = palette()
		for _, l in ipairs(TR.layers) do
			if l.o.Parent then
				l.o.Color = l.fn(main, edge)
				if l.trail then l.o.LightEmission = isDark(main) and 0 or 1 end
			end
		end
	end

	local function spawnRing(pos)
		local _, edge = palette()
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Transparency = 1
		p.Size = V3(0.2, 0.2, 0.2)
		p.CFrame = CFrame.new(pos)
		p.Parent = workspace
		local g = Instance.new("BillboardGui")
		g.Adornee = p
		g.Size = UDim2.new(0.5, 0, 1, 0)
		g.LightInfluence = 0
		g.Parent = p
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 1, 0)
		f.BackgroundTransparency = 1
		f.Parent = g
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = f
		local s = Instance.new("UIStroke")
		s.Thickness = 3
		s.Color = edge
		s.Transparency = 0.1
		s.Parent = f
		local info = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(g, info, {Size = UDim2.new(2.4, 0, 5, 0)}):Play()
		TweenService:Create(s, info, {Transparency = 1}):Play()
		Debris:AddItem(p, 0.7)
	end

	local function stopComet()
		xLoop("cometTrail", nil)
		for _, o in ipairs(TR.objs) do
			pcall(function() o:Destroy() end)
		end
		TR.objs = {}
		TR.layers = {}
		TR.strands = {}
		TR.emitters = {}
		TR.root = nil
	end

	local function buildComet(root, st)
		stopComet()
		TR.root = root

		mkTrail(root, V3(0, 1.1, 0), V3(0, -1.1, 0), 1.0, function(m, e) return CS(m) end,
			NS({KP(0, 0.55), KP(1, 1)}), NS({KP(0, 1), KP(1, 0)}))
		mkTrail(root, V3(0, 0.4, 0), V3(0, -0.4, 0), 0.95, function(m, e) return CS({CK(0, e), CK(1, m)}) end,
			NS({KP(0, 0.1), KP(1, 1)}), NS({KP(0, 1), KP(1, 0)}))
		mkTrail(root, V3(0, 0.1, 0), V3(0, -0.1, 0), 0.75, function(m, e) return CS({CK(0, WHITE), CK(0.5, e), CK(1, m)}) end,
			NS({KP(0, 0), KP(1, 1)}), NS({KP(0, 1), KP(1, 0)}))

		for i = 1, st.strands do
			local a0, a1 = mkTrail(root, V3(0, 0.07, 0), V3(0, -0.07, 0), 0.9, function(m, e) return CS({CK(0, e), CK(1, m)}) end,
				NS({KP(0, 0.1), KP(1, 1)}), NS({KP(0, 1), KP(1, 0)}))
			table.insert(TR.strands, {a0 = a0, a1 = a1, ph = (i - 1) * math.pi * 2 / st.strands, f = 12 + i * 2, amp = 0.9})
		end

		local lifes = {1.1, 0.5, 0.9, 0.4, 0.7}
		for i = 1, st.lines do
			local y = (i - (st.lines + 1) / 2) * 0.4
			mkTrail(root, V3(0, y + 0.04, 0), V3(0, y - 0.04, 0), lifes[i] or 0.7,
				function(m, e) return CS({CK(0, WHITE), CK(0.3, e), CK(1, m)}) end,
				NS({KP(0, 0), KP(1, 1)}), NS({KP(0, 1), KP(1, 0.6)}))
		end

		local head = attach(root, V3(0, 0, 0))
		local main, edge = palette()
		local sparks = add(Instance.new("ParticleEmitter"))
		sparks.Texture = st.sparkTex or "rbxassetid://1084997326"
		sparks.Color = CS({CK(0, WHITE), CK(1, edge)})
		sparks.LightEmission = 1
		sparks.LightInfluence = 0
		sparks.Brightness = 5
		sparks.Orientation = Enum.ParticleOrientation.FacingCamera
		sparks.Size = NS({KP(0, st.sparkSize or 0.35), KP(1, 0)})
		sparks.Transparency = NS({KP(0, 0), KP(1, 1)})
		sparks.Lifetime = NumberRange.new(0.5, 1.2)
		sparks.Rate = st.sparkRate
		sparks.Speed = st.sparkSpeed
		sparks.SpreadAngle = Vector2.new(180, 180)
		sparks.Drag = 2
		sparks.Acceleration = V3(0, 1, 0)
		sparks.LockedToPart = false
		sparks.Enabled = false
		sparks.Parent = head
		table.insert(TR.emitters, sparks)
		table.insert(TR.layers, {o = sparks, fn = function(m, e) return CS({CK(0, WHITE), CK(1, e)}) end})

		xLoop("cometTrail", function(dt)
			local r = TR.root
			if not r or not r.Parent then return end
			local t = os.clock()
			for _, s in ipairs(TR.strands) do
				local x = math.sin(t * s.f + s.ph) * s.amp
				local y = math.cos(t * s.f + s.ph) * s.amp * 0.6
				s.a0.Position = V3(x, y + 0.07, 0)
				s.a1.Position = V3(x, y - 0.07, 0)
			end
			local moving = r.AssemblyLinearVelocity.Magnitude > 2
			for _, e in ipairs(TR.emitters) do e.Enabled = moving end
			if st.rings and moving then
				TR.ringAcc = TR.ringAcc + dt
				if TR.ringAcc >= 0.1 then
					TR.ringAcc = 0
					local cam = workspace.CurrentCamera
					if cam and (cam.CFrame.Position - r.Position).Magnitude > 6 then
						local back = r.AssemblyLinearVelocity
						local pos = r.Position
						if back.Magnitude > 0.1 then pos = pos - back.Unit * 1.5 end
						spawnRing(pos)
					end
				end
			end
		end)
	end

	local function sync()
		local mode = math.clamp(math.floor(EXT.trMode), 1, #STYLES)
		if currentFireTrail then currentFireTrail.Enabled = fireTrailEnabled and mode == 1 end
		if fireTrailEnabled and mode > 1 then
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			if root then buildComet(root, STYLES[mode]) end
		else
			stopComet()
		end
	end

	local oldApplyFT = ApplyFireTrail
	ApplyFireTrail = function(state)
		oldApplyFT(state)
		local ok, err = pcall(sync)
		if not ok then warn("[vizer] Trail: " .. tostring(err)) end
	end

	XHK.TrailMode = function(ch)
		task.spawn(function()
			local root = ch:WaitForChild("HumanoidRootPart", 5)
			if not root then return end
			task.wait(0.7)
			pcall(sync)
		end)
	end

	local prevXC = XColorUpdate
	function XColorUpdate(key, col)
		if prevXC then prevXC(key, col) end
		if key == "FireTrail" then
			recolor()
			if currentFireTrail then TrailApplyColor(currentFireTrail, col) end
		end
	end

	UI.pickList = UI.pickList or {}
	table.insert(UI.pickList, {label = "Trail mode", key = "Trail mode#0",
		get = function() return EXT.trMode end,
		set = function(v) EXT.trMode = v; sync() end})

	local old
	for _, f in ipairs(UI.feats) do
		if f.Id == "FireTrail" then old = f break end
	end
	if old then
		local oldCell = UI.pages.Visuals:FindFirstChild("FireTrail", true)
		if oldCell then oldCell:Destroy() end
		for i = #UI.feats, 1, -1 do
			if UI.feats[i].Id == "FireTrail" then table.remove(UI.feats, i) end
		end
		UI.rows.FireTrail = nil

		local pd = UI.pdata.Visuals
		local keepOrder, keepGrid = pd.order, pd.grid
		pd.order = -80
		pd.grid = nil
		UI.section("Visuals", "☄  Trail")
		local feat = {Tab = "Visuals", Id = "FireTrail", Name = "Trail", Sub = "Glowing trail  —  ⚙ pick a mode", Icon = "☄",
			Key = old.DefKey, Toggle = old.Toggle}
		local r = UI.add(feat)
		feat.Key = old.Key
		r.updateSub()
		r.set(fireTrailEnabled, true)

		local cell = UI.pages.Visuals:FindFirstChild("FireTrail", true)
		local rowFrame = cell and cell:FindFirstChildWhichIsA("Frame")
		if rowFrame then
			for _, ch in ipairs(rowFrame:GetChildren()) do
				if ch:IsA("Frame") and ch.Size.X.Offset == 40 and ch.Size.Y.Offset == 22 then
					ch.Position = UDim2.new(1, -42, 0.5, 0)
				end
			end
			local g = UI.new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 26, 0, 26), Text = "⚙", Font = Enum.Font.GothamBold, TextSize = 15,
				AutoButtonColor = false, ZIndex = 12}, rowFrame)
			UI.corner(g, 8)
			UI.bind(function(t) g.BackgroundColor3 = t.Panel; g.TextColor3 = t.Text end)
			g.MouseButton1Click:Connect(function()
				UI.dropUp(rowFrame, ITEMS, EXT.trMode, function(v)
					EXT.trMode = v
					MISC.dirty()
					if not fireTrailEnabled then ApplyFireTrail(true) else sync() end
				end, 1, 260)
			end)
		end

		local row = UI.fullRow("Visuals", 72)
		local preview = UI.new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = EffectColors.FireTrail, BorderSizePixel = 0, ZIndex = 14}, row)
		UI.corner(preview, 11)
		UI.stroke(preview, WHITE, 1, 0.5)
		local lbl = UI.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = "🎨  Trail color & brightness", Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		local prevSetter = UI.colorSetters and UI.colorSetters.FireTrail
		local setHue = UI.hueSlider(row, 40, EffectColors.FireTrail, function(col)
			EffectColors.FireTrail = col
			preview.BackgroundColor3 = col
			if prevSetter then pcall(prevSetter, col) end
			XColorUpdate("FireTrail", col)
			MISC.dirty()
		end, false, true)
		if UI.colorSetters then
			UI.colorSetters.FireTrail = function(col)
				preview.BackgroundColor3 = col
				setHue(col)
				if prevSetter then pcall(prevSetter, col) end
			end
		end

		pd.order, pd.grid = keepOrder, keepGrid
	end

	local oldReset = MISC.resetAll
	if oldReset then
		MISC.resetAll = function(silent)
			oldReset(silent)
			EXT.trMode = 2
			pcall(sync)
		end
	end

	pcall(sync)
end

do
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	local C = Color3.fromRGB
	local V3 = Vector3.new
	local NS, KP, CS, CK = NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new, ColorSequenceKeypoint.new
	local WHITE = Color3.new(1, 1, 1)

	local sx = MISC.saved and MISC.saved.ext
	EXT.teMode = (type(sx) == "table" and type(sx.teMode) == "number") and sx.teMode or 1
	EXT.teDist = (type(sx) == "table" and type(sx.teDist) == "number") and sx.teDist or 19

	local MODES = {
		{name = "1.  Corners", col = C(255, 70, 240)},
		{name = "2.  Orbit",   col = C(255, 70, 240)},
		{name = "3.  Crystal", col = C(255, 60, 235)},
	}
	local ITEMS = {}
	for i, m in ipairs(MODES) do table.insert(ITEMS, {text = m.name, value = i}) end

	EffectColors.TargetESP = MODES[1].col
	EffectDefaults.TargetESP = MODES[1].col
	local sc = MISC.saved and MISC.saved.colors and MISC.saved.colors.TargetESP
	if type(sc) == "table" then
		EffectColors.TargetESP = C(sc[1] or 255, sc[2] or 255, sc[3] or 255)
	end

	local TE = {target = nil, fx = nil, root = nil, update = nil, lost = 0, conn = nil}

	local function frame(parent, x, y, w, h, color, transp, z)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = color
		f.BackgroundTransparency = transp
		f.BorderSizePixel = 0
		f.Position = UDim2.new(x, 0, y, 0)
		f.Size = UDim2.new(w, 0, h, 0)
		f.ZIndex = z
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = f
		f.Parent = parent
		return f
	end

	local function bar(parent, x, y, w, h, col)
		local gx, gy = 0.03, 0.025
		frame(parent, x - 2 * gx, y - 2 * gy, w + 4 * gx, h + 4 * gy, col, 0.88, 1)
		frame(parent, x - gx, y - gy, w + 2 * gx, h + 2 * gy, col, 0.7, 2)
		frame(parent, x, y, w, h, col, 0.05, 3)
		local ix, iy = math.min(w * 0.3, 0.02), math.min(h * 0.3, 0.02)
		frame(parent, x + ix, y + iy, w - 2 * ix, h - 2 * iy, col:Lerp(WHITE, 0.55), 0.35, 4)
	end

	local function buildCorners(root, col, folder)
		local g = Instance.new("BillboardGui")
		g.Adornee = root
		g.AlwaysOnTop = true
		g.LightInfluence = 0
		g.Size = UDim2.new(4.6, 0, 5.8, 0)
		g.StudsOffset = V3(0, 0.2, 0)
		g.Parent = folder
		local box = Instance.new("Frame")
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.Position = UDim2.new(0.5, 0, 0.5, 0)
		box.Size = UDim2.new(1, 0, 1, 0)
		box.BackgroundTransparency = 1
		box.Parent = g
		local tx, ty, lx, ly = 0.098, 0.078, 0.30, 0.24
		bar(box, 0, 0, lx, ty, col)
		bar(box, 0, 0, tx, ly, col)
		bar(box, 1 - lx, 0, lx, ty, col)
		bar(box, 1 - tx, 0, tx, ly, col)
		bar(box, 0, 1 - ty, lx, ty, col)
		bar(box, 0, 1 - ly, tx, ly, col)
		bar(box, 1 - lx, 1 - ty, lx, ty, col)
		bar(box, 1 - tx, 1 - ly, tx, ly, col)
		return function(t)
			local p = 1 + 0.04 * math.sin(t * 3)
			box.Size = UDim2.new(p, 0, p, 0)
			box.Rotation = math.sin(t * 1.5) * 4
		end
	end

	local function mkAnchor(root, folder)
		local anchor = Instance.new("Part")
		anchor.Anchored = true
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = false
		anchor.CastShadow = false
		anchor.Transparency = 1
		anchor.Size = V3(0.2, 0.2, 0.2)
		anchor.CFrame = CFrame.new(root.Position)
		anchor.Parent = folder
		return anchor
	end

	local function sparkEmitter(att, col, rate, speed, size, life, accel)
		local e = Instance.new("ParticleEmitter")
		e.Texture = "rbxassetid://1084997326"
		e.Color = CS({CK(0, WHITE), CK(1, col)})
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Brightness = 4
		e.Size = NS({KP(0, size), KP(1, 0)})
		e.Transparency = NS({KP(0, 0), KP(1, 1)})
		e.Lifetime = NumberRange.new(life * 0.7, life)
		e.Rate = rate
		e.Speed = speed
		e.SpreadAngle = Vector2.new(180, 180)
		e.Drag = 1.5
		e.Acceleration = accel
		e.LockedToPart = false
		e.Parent = att
		return e
	end

	local function buildOrbit(root, col, folder)
		local anchor = mkAnchor(root, folder)
		local light = col:Lerp(WHITE, 0.5)
		local orbs = {}
		for i = 1, 2 do
			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")
			local ah = Instance.new("Attachment")
			a0.Parent = anchor
			a1.Parent = anchor
			ah.Parent = anchor

			local function layer(life, widthStart, trans0, color)
				local tr = Instance.new("Trail")
				tr.Attachment0 = a0
				tr.Attachment1 = a1
				tr.Lifetime = life
				tr.MinLength = 0.03
				tr.FaceCamera = true
				tr.LightEmission = 1
				tr.LightInfluence = 0
				tr.Color = color
				tr.Transparency = NS({KP(0, trans0), KP(0.5, 0.5 + trans0 * 0.5), KP(1, 1)})
				tr.WidthScale = NS({KP(0, widthStart), KP(0.25, widthStart * 0.85), KP(1, 0)})
				tr.Parent = anchor
			end
			layer(0.85, 1.9, 0.6, CS(col))
			layer(0.75, 1.2, 0.1, CS({CK(0, light), CK(0.35, col), CK(1, col)}))
			layer(0.55, 0.4, 0, CS({CK(0, WHITE), CK(1, light)}))

			local glow = Instance.new("ParticleEmitter")
			glow.Texture = "rbxassetid://1084970835"
			glow.Color = CS(col)
			glow.LightEmission = 1
			glow.LightInfluence = 0
			glow.Brightness = 2
			glow.Size = NS({KP(0, 2.8), KP(1, 2)})
			glow.Transparency = NS({KP(0, 0.3), KP(1, 1)})
			glow.Lifetime = NumberRange.new(0.15, 0.15)
			glow.Rate = 40
			glow.Speed = NumberRange.new(0, 0)
			glow.LockedToPart = true
			glow.Parent = ah
			sparkEmitter(ah, col, 28, NumberRange.new(0.5, 1.8), 0.28, 0.7, V3(0, 1.5, 0))

			local bb = Instance.new("BillboardGui")
			bb.Adornee = ah
			bb.AlwaysOnTop = true
			bb.LightInfluence = 0
			bb.Size = UDim2.new(1.1, 0, 1.1, 0)
			bb.Parent = anchor
			local core = Instance.new("Frame")
			core.Size = UDim2.new(1, 0, 1, 0)
			core.BackgroundColor3 = light
			core.BackgroundTransparency = 0.05
			core.BorderSizePixel = 0
			core.Parent = bb
			local cc = Instance.new("UICorner")
			cc.CornerRadius = UDim.new(1, 0)
			cc.Parent = core
			local cs = Instance.new("UIStroke")
			cs.Color = col
			cs.Thickness = 3
			cs.Transparency = 0.35
			cs.Parent = core

			orbs[i] = {a0 = a0, a1 = a1, ah = ah}
		end

		return function(t)
			anchor.CFrame = CFrame.new(root.Position)
			for i, o in ipairs(orbs) do
				local th = t * 3.4 + (i - 1) * math.pi
				local r = 2.3
				local base = V3(math.cos(th) * r, 0, math.sin(th) * r)
				local tilt = CFrame.Angles(0, 0, (i == 1 and 0.4 or -0.4))
				local h = (i == 1 and 1.1 or -1.7) + math.sin(t * 2.1 + i * 1.7) * 0.5
				local pos = tilt * base + V3(0, h, 0)
				o.a0.Position = pos + V3(0, 0.5, 0)
				o.a1.Position = pos - V3(0, 0.5, 0)
				o.ah.Position = pos
			end
		end
	end

	local function buildCrystal(root, col, folder)
		local light = col:Lerp(WHITE, 0.3)
		local deep = col:Lerp(Color3.new(0.3, 0, 0.45), 0.3)
		local COUNT = 12
		local crystals = {}

		local function wedge(parent, color)
			local w = Instance.new("WedgePart")
			w.Anchored = true
			w.CanCollide = false
			w.CanTouch = false
			w.CanQuery = false
			w.CastShadow = false
			w.Material = Enum.Material.Neon
			w.Color = color
			w.Transparency = 0.08
			w.Parent = parent
			return w
		end

		local function tri(parent, a, b, c, color)
			local ab, ac, bc = b - a, c - a, c - b
			local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
			if abd > acd and abd > bcd then
				c, a = a, c
			elseif acd > bcd and acd > abd then
				a, b = b, a
			end
			ab, ac, bc = b - a, c - a, c - b
			local right = ac:Cross(ab).Unit
			local up = bc:Cross(right).Unit
			local back = bc.Unit
			local height = math.abs(ab:Dot(up))
			local w1 = wedge(parent, color)
			w1.Size = V3(0, height, math.abs(ab:Dot(back)))
			w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
			local w2 = wedge(parent, color)
			w2.Size = V3(0, height, math.abs(ac:Dot(back)))
			w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)
		end

		for i = 1, COUNT do
			local h = (i % 2 == 0) and 0.36 or 0.28
			local w = h * 0.5
			local model = Instance.new("Model")
			model.Name = "Crystal" .. i

			local core = Instance.new("Part")
			core.Anchored = true
			core.CanCollide = false
			core.CanTouch = false
			core.CanQuery = false
			core.CastShadow = false
			core.Transparency = 1
			core.Size = V3(0.2, 0.2, 0.2)
			core.CFrame = CFrame.new(0, 0, 0)
			core.Parent = model
			model.PrimaryPart = core

			local T, B = V3(0, h, 0), V3(0, -h, 0)
			local E = {V3(w, 0, 0), V3(0, 0, w), V3(-w, 0, 0), V3(0, 0, -w)}
			for k = 1, 4 do
				local n = k % 4 + 1
				tri(model, T, E[k], E[n], k % 2 == 0 and light or col)
				tri(model, B, E[n], E[k], k % 2 == 0 and col or deep)
			end

			local att = Instance.new("Attachment")
			att.Parent = core

			local glow = Instance.new("ParticleEmitter")
			glow.Texture = "rbxassetid://1084970835"
			glow.Color = CS(col)
			glow.LightEmission = 1
			glow.LightInfluence = 0
			glow.Brightness = 2
			glow.Size = NS({KP(0, h * 1.5), KP(1, h * 1.2)})
			glow.Transparency = NS({KP(0, 0.7), KP(1, 1)})
			glow.Lifetime = NumberRange.new(0.2, 0.2)
			glow.Rate = 10
			glow.Speed = NumberRange.new(0, 0)
			glow.LockedToPart = true
			glow.Parent = att

			sparkEmitter(att, col, 2, NumberRange.new(0.2, 0.6), 0.08, 0.5, V3(0, 0.6, 0))

			model.Parent = folder

			crystals[i] = {
				model = model,
				phase = (i - 1) / COUNT * math.pi * 2,
				y = -1.9 + (i - 1) / (COUNT - 1) * 3.9,
				spin = 1.8,
			}
		end

		return function(t)
			local base = root.Position
			for _, c in ipairs(crystals) do
				local th = t * 1.4 + c.phase
				local y = c.y + math.sin(t * 1.5 + c.phase) * 0.2
				local pos = base + V3(math.cos(th) * 2.1, y, math.sin(th) * 2.1)
				c.model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, t * c.spin + c.phase, 0))
			end
		end
	end

	local BUILD = {buildCorners, buildOrbit, buildCrystal}

	local function clear()
		if TE.fx then pcall(function() TE.fx:Destroy() end) end
		TE.fx = nil
		TE.update = nil
		TE.root = nil
		TE.target = nil
	end

	local function rebuild(plr)
		clear()
		if not plr then return end
		local ch = plr.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local folder = Instance.new("Folder")
		folder.Name = "vizerTargetESP"
		folder.Parent = workspace
		local mode = math.clamp(math.floor(EXT.teMode), 1, #BUILD)
		TE.fx = folder
		TE.root = root
		TE.target = plr
		TE.update = BUILD[mode](root, EffectColors.TargetESP, folder)
	end

	local function setOn(on)
		if TE.conn then TE.conn:Disconnect(); TE.conn = nil end
		clear()
		if not on then return end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		TE.lost = 0
		TE.conn = RunService.RenderStepped:Connect(function(dt)
			local ch = player.Character
			local myRoot = ch and ch:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not myRoot or not cam then clear() return end
			params.FilterDescendantsInstances = {ch}
			local origin, dir
			if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				origin, dir = cam.CFrame.Position, cam.CFrame.LookVector
			else
				local m = UIS:GetMouseLocation()
				local ray = cam:ViewportPointToRay(m.X, m.Y)
				origin, dir = ray.Origin, ray.Direction
			end
			local hit = workspace:Raycast(origin, dir * 1000, params)
			local model = hit and hit.Instance:FindFirstAncestorOfClass("Model")
			local plr = model and Players:GetPlayerFromCharacter(model)
			local tr = plr and plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if tr and (myRoot.Position - tr.Position).Magnitude <= EXT.teDist then
				TE.lost = 0
				if TE.target ~= plr or not TE.fx or not TE.fx.Parent or TE.root ~= tr then rebuild(plr) end
			else
				TE.lost = TE.lost + dt
				if TE.lost > 0.15 and TE.fx then clear() end
			end
			if TE.update and TE.root and TE.root.Parent then
				TE.update(os.clock())
			end
		end)
	end

	XH.TargetESP = function(on)
		local ok, err = pcall(setOn, on)
		if not ok then
			warn("[vizer] TargetESP: " .. tostring(err))
			UI.notify("⚠ Target ESP failed")
		end
	end

	local function redo()
		if TE.target then rebuild(TE.target) end
	end

	local prevXC = XColorUpdate
	function XColorUpdate(key, col)
		if prevXC then prevXC(key, col) end
		if key == "TargetESP" then redo() end
	end

	UI.pickList = UI.pickList or {}
	table.insert(UI.pickList, {label = "Target ESP mode", key = "Target ESP mode#0",
		get = function() return EXT.teMode end,
		set = function(v) EXT.teMode = v; redo() end})

	local pd = UI.pdata.Visuals
	local keepOrder, keepGrid = pd.order, pd.grid
	pd.order = -60
	pd.grid = nil
	UI.section("Visuals", "🎯  Target ESP")
	UI.add({Tab = "Visuals", Id = "TargetESP", Name = "Target ESP", Sub = "Effects on the player you aim at  —  ⚙ mode",
		Icon = "🎯", Toggle = XT("TargetESP")})

	local cell = UI.pages.Visuals:FindFirstChild("TargetESP", true)
	local rowFrame = cell and cell:FindFirstChildWhichIsA("Frame")
	if rowFrame then
		for _, ch in ipairs(rowFrame:GetChildren()) do
			if ch:IsA("Frame") and ch.Size.X.Offset == 40 and ch.Size.Y.Offset == 22 then
				ch.Position = UDim2.new(1, -42, 0.5, 0)
			end
		end
		local g = UI.new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0, 26, 0, 26), Text = "⚙", Font = Enum.Font.GothamBold, TextSize = 15,
			AutoButtonColor = false, ZIndex = 12}, rowFrame)
		UI.corner(g, 8)
		UI.bind(function(t) g.BackgroundColor3 = t.Panel; g.TextColor3 = t.Text end)
		g.MouseButton1Click:Connect(function()
			UI.dropUp(rowFrame, ITEMS, EXT.teMode, function(v)
				EXT.teMode = v
				MISC.dirty()
				redo()
			end, 1, 200)
		end)
	end

	local row = UI.fullRow("Visuals", 72)
	local preview = UI.new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
		BackgroundColor3 = EffectColors.TargetESP, BorderSizePixel = 0, ZIndex = 14}, row)
	UI.corner(preview, 11)
	UI.stroke(preview, WHITE, 1, 0.5)
	local lbl = UI.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 22), Position = UDim2.new(0, 40, 0, 8),
		Text = "🎨  Target ESP color & brightness", Font = Enum.Font.GothamBold, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
	UI.bind(function(t) lbl.TextColor3 = t.Text end)
	local setHue = UI.hueSlider(row, 40, EffectColors.TargetESP, function(col)
		EffectColors.TargetESP = col
		preview.BackgroundColor3 = col
		MISC.dirty()
		redo()
	end, false, true)
	if UI.colorSetters then
		UI.colorSetters.TargetESP = function(col)
			preview.BackgroundColor3 = col
			setHue(col)
		end
	end

	UI.sliderRow("Visuals", "🎯  Target ESP distance: ", 19, 60, EXT.teDist, function(v) EXT.teDist = v end)
	pd.order, pd.grid = keepOrder, keepGrid

	local oldReset = MISC.resetAll
	if oldReset then
		MISC.resetAll = function(silent)
			oldReset(silent)
			EXT.teMode = 1
			redo()
		end
	end
end

do
	local WHITE = Color3.new(1, 1, 1)
	local MODES = {
		{name = "1.  Ring"},
		{name = "2.  Disc"},
		{name = "3.  Rings + light"},
	}
	local ITEMS = {}
	for i, m in ipairs(MODES) do table.insert(ITEMS, {text = m.name, value = i}) end

	EXT.jcMode = math.clamp(math.floor(tonumber(EXT.jcMode) or 1), 1, #MODES)

	UI.pickList = UI.pickList or {}
	table.insert(UI.pickList, {label = "Jump Circle mode", key = "Jump Circle mode#0",
		get = function() return EXT.jcMode end,
		set = function(v) EXT.jcMode = v end})

	local old
	for _, f in ipairs(UI.feats) do
		if f.Id == "JumpCircle" then old = f break end
	end
	if old then
		local oldCell = UI.pages.Visuals:FindFirstChild("JumpCircle", true)
		if oldCell then
			local wrap = oldCell.Parent
			oldCell:Destroy()
			if wrap and wrap.Name == "Wide" then wrap:Destroy() end
		end
		for i = #UI.feats, 1, -1 do
			if UI.feats[i].Id == "JumpCircle" then table.remove(UI.feats, i) end
		end
		UI.rows.JumpCircle = nil

		local pd = UI.pdata.Visuals
		local keepOrder, keepGrid = pd.order, pd.grid
		pd.order = -40
		pd.grid = nil
		UI.section("Visuals", "💠  Jump Circle")
		local feat = {Tab = "Visuals", Id = "JumpCircle", Name = "Jump Circle", Sub = "Effect on jump  —  ⚙ pick a mode", Icon = "💠",
			Key = old.DefKey, Toggle = old.Toggle}
		local r = UI.add(feat)
		feat.Key = old.Key
		r.updateSub()
		r.set(JC.on, true)

		local cell = UI.pages.Visuals:FindFirstChild("JumpCircle", true)
		local rowFrame = cell and cell:FindFirstChildWhichIsA("Frame")
		if rowFrame then
			for _, ch in ipairs(rowFrame:GetChildren()) do
				if ch:IsA("Frame") and ch.Size.X.Offset == 40 and ch.Size.Y.Offset == 22 then
					ch.Position = UDim2.new(1, -42, 0.5, 0)
				end
			end
			local g = UI.new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 26, 0, 26), Text = "⚙", Font = Enum.Font.GothamBold, TextSize = 15,
				AutoButtonColor = false, ZIndex = 12}, rowFrame)
			UI.corner(g, 8)
			UI.bind(function(t) g.BackgroundColor3 = t.Panel; g.TextColor3 = t.Text end)
			g.MouseButton1Click:Connect(function()
				UI.dropUp(rowFrame, ITEMS, EXT.jcMode, function(v)
					EXT.jcMode = v
					MISC.dirty()
					if not JC.on then ApplyJumpCircle(true) end
				end, 1, 200)
			end)
		end

		local row = UI.fullRow("Visuals", 72)
		local preview = UI.new("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 8),
			BackgroundColor3 = EffectColors.JumpCircle, BorderSizePixel = 0, ZIndex = 14}, row)
		UI.corner(preview, 11)
		UI.stroke(preview, WHITE, 1, 0.5)
		local lbl = UI.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 22), Position = UDim2.new(0, 40, 0, 8),
			Text = "🎨  Jump Circle color & brightness", Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14}, row)
		UI.bind(function(t) lbl.TextColor3 = t.Text end)
		local prevSetter = UI.colorSetters and UI.colorSetters.JumpCircle
		local setHue = UI.hueSlider(row, 40, EffectColors.JumpCircle, function(col)
			EffectColors.JumpCircle = col
			preview.BackgroundColor3 = col
			if prevSetter then pcall(prevSetter, col) end
			MISC.dirty()
		end, true, true)
		if UI.colorSetters then
			UI.colorSetters.JumpCircle = function(col)
				preview.BackgroundColor3 = col
				setHue(col)
				if prevSetter then pcall(prevSetter, col) end
			end
		end

		pd.order, pd.grid = keepOrder, keepGrid
	end

	local oldReset = MISC.resetAll
	if oldReset then
		MISC.resetAll = function(silent)
			oldReset(silent)
			EXT.jcMode = 1
		end
	end
end

do
	local oldCollect, oldApply = MISC.collectConfig, MISC.applyConfig
	if oldCollect and oldApply then
		local function rgb(c)
			return {math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)}
		end

		function MISC.collectConfig()
			local data = oldCollect()
			local ids, picks, friends = {}, {}, {}
			for _, e in ipairs(UI.idList or {}) do
				if e.id then ids[e.title] = tostring(e.id) end
			end
			for _, q in ipairs(UI.pickList or {}) do
				local ok, v = pcall(q.get)
				if ok and (type(v) == "string" or type(v) == "number") then picks[q.key] = v end
			end
			for _, n in pairs(MISC.friends or {}) do table.insert(friends, n) end
			data.ids = ids
			data.picks = picks
			data.friends = friends
			if MISC.mapState then
				local ok, m = pcall(MISC.mapState)
				if ok then data.map = m end
			end
			if MISC.cpColor then data.cpColor = rgb(MISC.cpColor.get()) end
			return data
		end

		function MISC.applyConfig(d)
			oldApply(d)
			if type(d) ~= "table" then return end
			pcall(function()
				if type(d.map) == "table" and MISC.map then
					for _, def in ipairs(MISC.map.list) do
						local info = d.map[def.key]
						if type(info) == "table" and def.applySaved then pcall(def.applySaved, info) end
					end
					if MISC.mapRestore then pcall(MISC.mapRestore, d.map) end
				end
				if type(d.ids) == "table" then
					for _, e in ipairs(UI.idList or {}) do
						local id = d.ids[e.title]
						if type(id) == "string" or type(id) == "number" then
							pcall(e.set, tostring(id))
						elseif e.id then
							pcall(e.clear)
						end
					end
				end
				if type(d.picks) == "table" then
					for _, q in ipairs(UI.pickList or {}) do
						local v = d.picks[q.key]
						local ok, cur = pcall(q.get)
						if v ~= nil and ok and v ~= cur then pcall(q.set, v) end
					end
				end
				if type(d.cpColor) == "table" and MISC.cpColor then
					pcall(MISC.cpColor.set, Color3.fromRGB(d.cpColor[1] or 255, d.cpColor[2] or 255, d.cpColor[3] or 255))
				end
				if type(d.friends) == "table" and MISC.friends then
					for k in pairs(MISC.friends) do MISC.friends[k] = nil end
					for _, n in ipairs(d.friends) do
						if type(n) == "string" then MISC.friends[n:lower()] = n end
					end
					if MISC.espRefresh then pcall(MISC.espRefresh) end
				end
			end)
			MISC.dirty()
		end
	end
end

do
	local PICKS = {
		{"Preset", 1}, {"Quality", 2}, {"Material", ""}, {"Decal rotation", 90},
		{"Trail mode", 2}, {"Target ESP mode", 1}, {"Jump Circle mode", 1},
	}

	local oldReset = MISC.resetAll
	MISC.resetAll = function(silent)
		oldReset(silent)
		for _, q in ipairs(UI.pickList or {}) do
			for _, p in ipairs(PICKS) do
				if q.label:find(p[1], 1, true) then
					pcall(q.set, p[2])
					break
				end
			end
		end
		for _, e in ipairs(UI.idList or {}) do
			if e.id then pcall(e.clear) end
		end
		if MISC.cpColor then pcall(MISC.cpColor.set, Color3.fromRGB(255, 80, 160)) end
		if UI.artImage then UI.artImage.Image = GIRL_IMAGE end
		MISC.dirty()
	end

	local oldCollect, oldApply = MISC.collectConfig, MISC.applyConfig
	function MISC.collectConfig()
		local data = oldCollect()
		data.animOff = MISC.animOff or false
		if UI.artImage and UI.artImage.Image ~= GIRL_IMAGE then data.image = UI.artImage.Image end
		return data
	end

	function MISC.applyConfig(d)
		oldApply(d)
		if type(d) ~= "table" then return end
		pcall(function()
			if d.animOff == true and not MISC.animOff and UI.rows.MenuAnim then UI.rows.MenuAnim.feat.Toggle() end
			if type(d.image) == "string" and UI.artImage then UI.artImage.Image = d.image end
		end)
		MISC.dirty()
	end
end

do
	local sin, cos, abs, floor = math.sin, math.cos, math.abs, math.floor
	local ID = CFrame.new()

	local function A(side, fwd, out)
		return CFrame.Angles(0, 0, side * out) * CFrame.Angles(fwd, 0, 0)
	end
	local function F(side, fwd, inward)
		return CFrame.Angles(0, side * inward, 0) * CFrame.Angles(fwd, 0, 0)
	end
	local function Hd(nod, turn, tilt)
		return CFrame.Angles(0, turn, 0) * CFrame.Angles(0, 0, tilt) * CFrame.Angles(-nod, 0, 0)
	end
	local function B(turn, up, side, back, lean)
		return CFrame.new(side, up, back) * CFrame.Angles(0, turn, 0) * CFrame.Angles(-lean, 0, 0)
	end

	local EM6 = {
		{name = "1.  👋 Wave", fn = function(t)
			return {rs = A(1, 0.15, 2.6 + sin(t * 9) * 0.3), ls = A(-1, 0, 0.1), n = Hd(0, 0.15, 0.1), r = B(0, 0, 0, 0, 0)}
		end},
		{name = "2.  💃 Dance", fn = function(t)
			local s, w = sin(t * 5), sin(t * 2.5)
			return {r = B(w * 0.3, abs(s) * 0.25, w * 0.15, 0, 0), rs = A(1, 0.2, 2.2 + s * 0.6), ls = A(-1, 0.2, 2.2 - s * 0.6),
				rh = A(1, s * 0.5, 0.1), lh = A(-1, -s * 0.5, 0.1), n = Hd(0, -w * 0.3, s * 0.15)}
		end},
		{name = "3.  🪩 Disco", fn = function(t)
			local s = sin(t * 4)
			return {r = B(s * 0.25, 0, 0, 0, 0.05), rs = A(1, 0.3, 1.6 + s * 1.4), ls = A(-1, 0.3, 1.6 - s * 1.4),
				rh = A(1, 0, 0.15), lh = A(-1, 0, 0.15), n = Hd(0, -s * 0.3, 0)}
		end},
		{name = "4.  🎽 Floss", fn = function(t)
			local s = sin(t * 8)
			return {r = B(s * 0.2, abs(s) * 0.05, -s * 0.35, 0, 0.1), rs = A(1, -0.7, s * 0.9), ls = A(-1, -0.7, -s * 0.9),
				rh = A(1, 0, 0.1), lh = A(-1, 0, 0.1), n = Hd(0, -s * 0.15, 0)}
		end},
		{name = "5.  🎉 Cheer", fn = function(t)
			local j, x = abs(sin(t * 6)), sin(t * 12)
			return {r = B(0, j * 0.6, 0, 0, 0), rs = A(1, 0, 2.7 + x * 0.25), ls = A(-1, 0, 2.7 - x * 0.25),
				rh = A(1, 0, j * 0.2), lh = A(-1, 0, j * 0.2), n = Hd(-0.2, 0, 0)}
		end},
		{name = "6.  😂 Laugh", fn = function(t)
			local k = sin(t * 18)
			return {r = B(0, k * 0.05, 0, 0, -0.25 + k * 0.05), n = Hd(-0.4 + k * 0.1, 0, 0),
				rs = F(1, 1.0, 0.35), ls = F(-1, 1.0, 0.35)}
		end},
		{name = "7.  👉 Point", fn = function(t)
			local p = sin(t * 5) * 0.06
			return {rs = A(1, 1.57 + p, 0), ls = A(-1, 0, 0.1), n = Hd(0, 0.25, 0), r = B(0.2, 0, 0, 0, 0)}
		end},
		{name = "8.  🫡 Salute", fn = function(t)
			return {rs = A(1, 2.0, -0.5), ls = A(-1, 0, 0.1), n = Hd(-0.1, 0, 0), r = B(0, 0, 0, 0, -0.05)}
		end},
		{name = "9.  🧍 T-Pose", fn = function(t)
			return {rs = A(1, 0, 1.57), ls = A(-1, 0, 1.57)}
		end},
		{name = "10. 💪 Flex", fn = function(t)
			local p = sin(t * 6)
			return {rs = A(1, 0, 2.0 + p * 0.15), ls = A(-1, 0, 2.0 + p * 0.15), r = B(sin(t * 3) * 0.1, abs(p) * 0.08, 0, 0, 0.05),
				rh = A(1, 0, 0.3), lh = A(-1, 0, 0.3), n = Hd(-0.15, 0, 0)}
		end},
		{name = "11. 🌪 Spin", fn = function(t)
			return {r = B(t * 8, 0, 0, 0, 0), rs = A(1, 0, 1.4), ls = A(-1, 0, 1.4)}
		end},
		{name = "12. 🤘 Headbang", fn = function(t)
			local s = sin(t * 10)
			return {n = Hd(s * 0.6, 0, 0), r = B(0, 0, 0, 0, s * 0.15), rs = A(1, 0, 2.5), ls = A(-1, 0, 2.5),
				rh = A(1, 0, 0.25), lh = A(-1, 0, 0.25)}
		end},
		{name = "13. 🤖 Robot", fn = function(t)
			local st = floor(t * 3) % 4
			return {rs = A(1, st == 0 and 1.57 or 0, st == 1 and 1.57 or 0), ls = A(-1, st == 2 and 1.57 or 0, st == 3 and 1.57 or 0),
				n = Hd(0, (st - 1.5) * 0.3, 0), r = B((st - 1.5) * 0.15, 0, 0, 0, 0)}
		end},
		{name = "14. 🧟 Zombie", fn = function(t)
			return {rs = F(1, 1.5, 0.05), ls = F(-1, 1.5, 0.05), r = B(sin(t * 3) * 0.1, 0, 0, 0, 0.15),
				rh = A(1, sin(t * 4) * 0.4, 0), lh = A(-1, -sin(t * 4) * 0.4, 0), n = Hd(0.2, 0, sin(t * 2) * 0.3)}
		end},
		{name = "15. 🤷 Shrug", fn = function(t)
			local p = (sin(t * 3) + 1) / 2
			return {rs = A(1, 0, 0.5 + p * 0.3), ls = A(-1, 0, 0.5 + p * 0.3), r = B(0, p * 0.12, 0, 0, 0), n = Hd(0, 0, p * 0.2)}
		end},
		{name = "16. 😎 Dab", fn = function(t)
			local p = (sin(t * 4) + 1) / 2
			return {rs = A(1, 0, 2.6), ls = F(-1, 2.0, 0.9), n = Hd(0.5 + p * 0.1, 0.5, 0), r = B(0.2, 0, 0, 0, 0.2)}
		end},
		{name = "17. 🙇 Bow", fn = function(t)
			local k = 0.5 - 0.5 * cos(t * 2)
			return {r = B(0, 0, 0, 0, k * 1.0), n = Hd(k * 0.3, 0, 0), rs = A(1, 0.3, 0.1), ls = A(-1, 0.3, 0.1)}
		end},
		{name = "18. 🤸 Jumping jacks", fn = function(t)
			local s = abs(sin(t * 6))
			return {r = B(0, s * 0.4, 0, 0, 0), rs = A(1, 0, s * 3.0), ls = A(-1, 0, s * 3.0), rh = A(1, 0, s * 0.6), lh = A(-1, 0, s * 0.6)}
		end},
		{name = "19. 🔥 Hype jump", fn = function(t)
			local j = abs(sin(t * 7))
			local x = sin(t * 7)
			return {r = B(sin(t * 3.5) * 0.2, j * 0.9, 0, 0, 0), rs = A(1, 0, 2.2 + x * 0.8), ls = A(-1, 0, 2.2 - x * 0.8),
				rh = A(1, 0.4, 0.1), lh = A(-1, -0.2, 0.1)}
		end},
		{name = "20. 🪑 Sit", fn = function(t)
			return {r = B(0, -1.5, 0, 0, 0), rh = A(1, 1.57, 0.05), lh = A(-1, 1.57, 0.05), rs = F(1, 0.5, 0.2), ls = F(-1, 0.5, 0.2)}
		end},
		{name = "21. 👏 Clap", fn = function(t)
			local s = (sin(t * 12) + 1) / 2
			return {rs = F(1, 1.45, 0.05 + s * 0.45), ls = F(-1, 1.45, 0.05 + s * 0.45), n = Hd(0.1, 0, 0), r = B(0, abs(sin(t * 6)) * 0.12, 0, 0, 0)}
		end},
		{name = "22. 🕺 Shuffle", fn = function(t)
			local s = sin(t * 8)
			return {r = B(s * 0.15, abs(s) * 0.1, s * 0.2, 0, 0), rh = A(1, s * 0.8, 0), lh = A(-1, -s * 0.8, 0),
				rs = A(1, -s * 0.6, 0.2), ls = A(-1, s * 0.6, 0.2)}
		end},
	}

	local EM15 = {
		{name = "1.  🕺 Hype Dance",   id = "3695333486"},
		{name = "2.  ⚡ Godlike",       id = "3337994105"},
		{name = "3.  🎽 Floss",         id = "5917570207"},
		{name = "4.  🐬 Dolphin",       id = "5918726674"},
		{name = "5.  👶 Baby Dance",    id = "4265725525"},
		{name = "6.  💃 Dance 1",       id = "507771019"},
		{name = "7.  💃 Dance 2",       id = "507776043"},
		{name = "8.  💃 Dance 3",       id = "507777268"},
		{name = "9.  😎 Fashionable",   id = "3333499508"},
		{name = "10. 🎉 Cheer",         id = "507770677"},
		{name = "11. 😂 Laugh",         id = "507770818"},
		{name = "12. 👋 Wave",          id = "507770239"},
		{name = "13. 👉 Point",         id = "507770453"},
		{name = "14. 🫡 Salute",        id = "3360689775"},
		{name = "15. 🙃 Tilt",          id = "3360692915"},
		{name = "16. 🏟 Stadium",       id = "3360686498"},
		{name = "17. 🤷 Shrug",         id = "3576968026"},
		{name = "18. 🙋 Hello",         id = "3344650532"},
		{name = "19. 🥱 Bored",         id = "5230599789"},
		{name = "20. 😴 Sleep",         id = "4686925579"},
		{name = "21. 😕 Confused",      id = "4940561610"},
		{name = "22. 🤫 Sneaky",        id = "3334392772"},
		{name = "23. 😡 Tantrum",       id = "5104341999"},
		{name = "24. 🪑 Sit",           id = "2506281703"},
	}

	local ITEMS6, ITEMS15 = {}, {}
	for i, e in ipairs(EM6) do table.insert(ITEMS6, {text = e.name, value = i}) end
	for i, e in ipairs(EM15) do table.insert(ITEMS15, {text = e.name, value = i}) end

	local sx = MISC.saved and MISC.saved.ext
	local function sv(k, d) return (type(sx) == "table" and type(sx[k]) == "number") and sx[k] or d end
	EXT.apMode = math.clamp(floor(sv("apMode", 1)), 1, #EM15)
	EXT.apMode6 = math.clamp(floor(sv("apMode6", 1)), 1, #EM6)
	EXT.apSpeed = sv("apSpeed", 10)

	local AP = {track = nil, anim = nil, custom = nil, paused = false, gen = 0, r6 = false,
		j = nil, o = nil, c = nil, animWas = nil, t0 = 0, sweep = 0}

	local function isR6()
		local h = MV.hum()
		return h ~= nil and h.RigType == Enum.HumanoidRigType.R6
	end

	local function stop15()
		AP.gen = AP.gen + 1
		if AP.track then
			pcall(function() AP.track:Stop(0.2) end)
			pcall(function() AP.track:Destroy() end)
		end
		if AP.anim then pcall(function() AP.anim:Destroy() end) end
		AP.track, AP.anim = nil, nil
	end

	local function stop6()
		pcall(function() RunService:UnbindFromRenderStep("vizerAnim6") end)
		if AP.j and AP.o then
			for k, m in pairs(AP.j) do
				if m and m.Parent and AP.o[k] then m.C0 = AP.o[k].c0 end
			end
		end
		AP.j, AP.o, AP.c = nil, nil, nil
		local ch = player.Character
		local an = ch and ch:FindFirstChild("Animate")
		if an and AP.animWas ~= nil then an.Disabled = AP.animWas end
		AP.animWas = nil
		AP.r6 = false
	end

	local function stopAll()
		stop15()
		stop6()
	end

	local function killTracks()
		local h = MV.hum()
		local a = h and h:FindFirstChildOfClass("Animator")
		if a then
			for _, tr in ipairs(a:GetPlayingAnimationTracks()) do pcall(function() tr:Stop(0) end) end
		end
	end

	local function play6()
		local ch = player.Character
		local hum = MV.hum()
		local torso = ch and ch:FindFirstChild("Torso")
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not hum or not torso or not root or hum.Health <= 0 then return false end
		stopAll()
		local j = {
			r = root:FindFirstChild("RootJoint"),
			n = torso:FindFirstChild("Neck"),
			rs = torso:FindFirstChild("Right Shoulder"),
			ls = torso:FindFirstChild("Left Shoulder"),
			rh = torso:FindFirstChild("Right Hip"),
			lh = torso:FindFirstChild("Left Hip"),
		}
		local o, c = {}, {}
		local count = 0
		for k, m in pairs(j) do
			if m and m:IsA("Motor6D") then
				local c0 = m.C0
				local p = c0.Position
				o[k] = {c0 = c0, p = p, rot = c0 - p}
				c[k] = ID
				count = count + 1
			else
				j[k] = nil
			end
		end
		if count == 0 then return false end
		AP.j, AP.o, AP.c = j, o, c
		local an = ch:FindFirstChild("Animate")
		if an then
			AP.animWas = an.Disabled
			an.Disabled = true
		end
		killTracks()
		AP.r6 = true
		AP.t0 = os.clock() * EXT.apSpeed / 10
		AP.sweep = 0
		RunService:BindToRenderStep("vizerAnim6", Enum.RenderPriority.Last.Value, function(dt)
			local em = EM6[EXT.apMode6]
			if not em or not AP.j then return end
			local t = os.clock() * EXT.apSpeed / 10 - AP.t0
			local ok, pose = pcall(em.fn, t)
			if not ok then return end
			AP.sweep = AP.sweep + dt
			if AP.sweep > 0.2 then
				AP.sweep = 0
				killTracks()
			end
			local alpha = math.min(1, dt * 14)
			for k, m in pairs(AP.j) do
				if m and m.Parent then
					local cur = AP.c[k]:Lerp(pose[k] or ID, alpha)
					AP.c[k] = cur
					local oo = AP.o[k]
					m.C0 = CFrame.new(oo.p) * cur * oo.rot
				end
			end
		end)
		return true
	end

	local function play15()
		local hum = MV.hum()
		if not hum or hum.Health <= 0 then return end
		stopAll()
		local id = AP.custom or EM15[EXT.apMode].id
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. id
		local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
		if not ok or not track then
			anim:Destroy()
			UI.notify("⚠ Animation failed to load")
			return
		end
		AP.anim, AP.track = anim, track
		pcall(function() track.Priority = Enum.AnimationPriority.Action4 end)
		track.Looped = true
		track:Play(0.25)
		track:AdjustSpeed(EXT.apSpeed / 10)
		local my = AP.gen
		task.delay(2, function()
			if AP.gen == my and AP.track == track and XS.AnimPlayer and track.Length == 0 then
				UI.notify("⚠ This animation is not available here")
			end
		end)
	end

	local function play()
		if isR6() and not AP.custom then
			if not play6() then UI.notify("⚠ R6 joints not found") end
		else
			play15()
		end
	end

	local function active()
		return AP.r6 or (AP.track ~= nil and AP.track.IsPlaying)
	end

	local function loop()
		local acc = 0
		xLoop("animplayer", function(dt)
			if not XS.AnimPlayer then return end
			local hum = MV.hum()
			if not hum or hum.Health <= 0 then return end
			if XS.AnimMoveStop then
				local moving = hum.MoveDirection.Magnitude > 0.1
				if moving and active() then
					stopAll()
					AP.paused = true
					return
				elseif not moving and AP.paused then
					AP.paused = false
					play()
					return
				end
			end
			if AP.paused then return end
			acc = acc + dt
			if acc < 0.5 then return end
			acc = 0
			if AP.r6 then
				if not AP.j or not AP.j.rs or not AP.j.rs.Parent then play() end
			elseif not AP.track or not AP.track.IsPlaying then
				play()
			end
		end)
	end

	XH.AnimPlayer = function(on)
		local ok, err = pcall(function()
			xLoop("animplayer", nil)
			AP.paused = false
			if on then
				play()
				loop()
			else
				stopAll()
			end
		end)
		if not ok then
			warn("[vizer] AnimPlayer: " .. tostring(err))
			UI.notify("⚠ Animation player failed")
		end
	end

	XHK.AnimPlayer = function(ch)
		if XS.AnimPlayer then
			task.wait(0.3)
			AP.paused = false
			AP.j, AP.o, AP.c = nil, nil, nil
			AP.r6 = false
			AP.animWas = nil
			play()
		end
	end

	UI.pickList = UI.pickList or {}
	table.insert(UI.pickList, {label = "Animation mode", key = "Animation mode#0",
		get = function() return EXT.apMode end,
		set = function(v) EXT.apMode = v; AP.custom = nil; if XS.AnimPlayer and not isR6() then play() end end})
	table.insert(UI.pickList, {label = "Animation mode R6", key = "Animation mode R6#0",
		get = function() return EXT.apMode6 end,
		set = function(v) EXT.apMode6 = v; AP.custom = nil; if XS.AnimPlayer and isR6() then play() end end})

	local pd = UI.pdata.Player
	local keepOrder, keepGrid = pd.order, pd.grid
	pd.order = -50
	pd.grid = nil
	UI.section("Player", "🎭  Animation player")
	UI.add({Tab = "Player", Id = "AnimPlayer", Name = "Animation player", Sub = "R6 + R15 emotes  —  ⚙ pick an emote",
		Icon = "🎭", Toggle = XT("AnimPlayer")})
	UI.add({Tab = "Player", Id = "AnimMoveStop", Name = "Stop on move", Sub = "Pause emote while walking",
		Icon = "🚶", Toggle = XT("AnimMoveStop")})

	local cell = UI.pages.Player:FindFirstChild("AnimPlayer", true)
	local rowFrame = cell and cell:FindFirstChildWhichIsA("Frame")
	if rowFrame then
		for _, ch in ipairs(rowFrame:GetChildren()) do
			if ch:IsA("Frame") and ch.Size.X.Offset == 40 and ch.Size.Y.Offset == 22 then
				ch.Position = UDim2.new(1, -42, 0.5, 0)
			end
		end
		local g = UI.new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0, 26, 0, 26), Text = "⚙", Font = Enum.Font.GothamBold, TextSize = 15,
			AutoButtonColor = false, ZIndex = 12}, rowFrame)
		UI.corner(g, 8)
		UI.bind(function(t) g.BackgroundColor3 = t.Panel; g.TextColor3 = t.Text end)
		g.MouseButton1Click:Connect(function()
			local r6 = isR6()
			UI.dropUp(rowFrame, r6 and ITEMS6 or ITEMS15, r6 and EXT.apMode6 or EXT.apMode, function(v)
				if r6 then EXT.apMode6 = v else EXT.apMode = v end
				AP.custom = nil
				MISC.dirty()
				if not XS.AnimPlayer then
					XS.AnimPlayer = true
					XH.AnimPlayer(true)
					UpdateToggleVisual("AnimPlayer", true)
				else
					play()
				end
			end, 2, 260)
		end)
	end

	local speedSlider = UI.sliderRow("Player", "🎭  Animation speed: ", 1, 40, EXT.apSpeed, function(v)
		EXT.apSpeed = v
		if AP.track then pcall(function() AP.track:AdjustSpeed(v / 10) end) end
	end)

	UI.idRow("Player", "🎭  Custom animation: paste an ID", "rbxassetid://... or just the number",
		function(id)
			AP.custom = id
			if not XS.AnimPlayer then
				XS.AnimPlayer = true
				XH.AnimPlayer(true)
				UpdateToggleVisual("AnimPlayer", true)
			else
				play()
			end
			return "▶ Custom animation playing"
		end,
		function()
			AP.custom = nil
			if XS.AnimPlayer then play() end
			return "↺ Back to the emote list"
		end)

	pd.order, pd.grid = keepOrder, keepGrid

	local oldReset = MISC.resetAll
	if oldReset then
		MISC.resetAll = function(silent)
			oldReset(silent)
			EXT.apMode = 1
			EXT.apMode6 = 1
			AP.custom = nil
			pcall(speedSlider.set, 10)
			if XS.AnimPlayer then play() end
		end
	end
end

do
	function MISC.espAttach(plr)
		if plr == player then return end
		local col = MISC.espColorFor(plr)
		local char = plr.Character
		if not col or not char or not char.Parent then
			MISC.espClear(plr)
			return
		end
		local h = MISC.espMap[plr]
		if h and h.Parent == char then
			if h.OutlineColor ~= col then h.OutlineColor = col; h.FillColor = col end
			if h.DepthMode ~= Enum.HighlightDepthMode.Occluded then h.DepthMode = Enum.HighlightDepthMode.Occluded end
			return
		end
		if h then h:Destroy() end
		h = Instance.new("Highlight")
		h.Name = "vizerESP"
		h.Adornee = char
		h.FillTransparency = 1
		h.OutlineTransparency = 0
		h.FillColor = col
		h.OutlineColor = col
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = char
		MISC.espMap[plr] = h
	end

	for _, h in pairs(MISC.espMap) do
		if h and h.Parent then h.DepthMode = Enum.HighlightDepthMode.Occluded end
	end

	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		acc = acc + dt
		if acc < 0.4 then return end
		acc = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			local ch = plr.Character
			local head = ch and ch:FindFirstChild("Head")
			local tag = head and head:FindFirstChild("vizerNameTag")
			if tag and tag.AlwaysOnTop then tag.AlwaysOnTop = false end
		end
	end)
end
