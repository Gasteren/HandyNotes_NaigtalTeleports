local ADDON_NAME, ns = ...

-- HandyNotes must be loaded for this module to do anything.
local HandyNotes = _G.HandyNotes
if not HandyNotes then
	return
end

-- Naigtal's uiMapID (Patch 12.0.7 / Midnight Void Showdown zone)
local MAP_ID = 16943

-- Icon shown for each teleport pin on the world map / minimap.
-- Swap this for any texture path you prefer (e.g. a custom TGA in a Textures/ folder).
local ICON = "interface/icons/spell_arcane_portaldarnassus"

--------------------------------------------------------------------------------
-- NODE DATA
--------------------------------------------------------------------------------
-- coord = HandyNotes-style packed coordinate: floor(x*10000) + y (x,y as percentages, 0-100)
-- e.g. x=47.66, y=82.09  ->  476600 + 8209  ->  use the helper below instead of doing this by hand.


local function C(x, y)
	return (math.floor(x * 10000) + math.floor(y))
end

local nodes = {
	[C(46.68, 82.91)] = {
		name = "Umbral Base Camp",
		desc = "Main hub translocator node.",
	},
	[C(32.27, 46.06)] = {
		name = "Extraction Coast",
		desc = "Left top translocator node.",
	},
	[C(55.04, 46.98)] = {
		name = "Nexus Port",
		desc = "Middle translocator node.",
	},
	[C(77.30, 42.91)] = {
		name = "Sporeforge",
		desc = "Right Top translocator node.",
	},
}

--------------------------------------------------------------------------------
-- HandyNotes plugin registration
--------------------------------------------------------------------------------

local function OnClick(coord, buttonName)
	-- No default click behavior yet. Hook a teleport-item/spell cast here if you want
	-- one-click travel, e.g. C_Item.UseItemByName("Manaforge Translocator Beacon").
end

local function OnEnter(coord)
	local node = nodes[coord]
	if not node then
		return
	end

	local tooltip = HandyNotes:GetTooltip and HandyNotes:GetTooltip() or GameTooltip
	tooltip:SetOwner(WorldMapFrame and WorldMapFrame.ScrollContainer or UIParent, "ANCHOR_RIGHT")
	tooltip:AddLine(node.name)
	tooltip:AddLine(node.desc, 1, 1, 1, true)
	tooltip:Show()
end

local function OnLeave()
	local tooltip = HandyNotes:GetTooltip and HandyNotes:GetTooltip() or GameTooltip
	tooltip:Hide()
end

HandyNotes:RegisterPluginDB(ADDON_NAME, {
	name = "Naigtal Teleports",
	icon = ICON,

	-- Modern HandyNotes API: coroutine-style iterator, one yield per node.
	-- yields: coord, icon, onEnterFn, onLeaveFn, onClickFn, minimapEnabled
	GetNodes2 = function(mapID)
		if mapID ~= MAP_ID then
			return
		end
		for coord in pairs(nodes) do
			coroutine.yield(coord, ICON, OnEnter, OnLeave, OnClick, true)
		end
	end,
}, {
	[MAP_ID] = true,
})
