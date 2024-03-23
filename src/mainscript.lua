local out_template = mainForm:GetChildChecked("Outcoming", true)
local inc_template = mainForm:GetChildChecked("Incoming", true)
local counter = 0
local TEMPLATE = {
	['out'] = out_template,
	['inc'] = inc_template
}
local STACK = {
	['out'] = {},
	['inc'] = {}
}

----------------------------------------------------------------------------------------------------
-- AOPanel support

local IsAOPanelEnabled = GetConfig("EnableAOPanel") or GetConfig("EnableAOPanel") == nil

local function onAOPanelStart(p)
	if IsAOPanelEnabled then
		local SetVal = { val1 = userMods.ToWString("DD"), class1 = "RelicCursed" }
		local params = { header = SetVal, ptype = "button", size = 32 }
		userMods.SendEvent("AOPANEL_SEND_ADDON",
			{ name = common.GetAddonName(), sysName = common.GetAddonName(), param = params })

		local cfgBtn = mainForm:GetChildChecked("ConfigButton", false)
		if cfgBtn then
			cfgBtn:Show(false)
		end
	end
end

local function onAOPanelLeftClick(p)
	if p.sender == common.GetAddonName() then
		UI.toggle()
	end
end

local function onAOPanelRightClick(p)
	if p.sender == common.GetAddonName() then
		ToggleDnd()
	end
end

local function onAOPanelChange(params)
	if params.unloading and params.name == "UserAddon/AOPanelMod" then
		local cfgBtn = mainForm:GetChildChecked("ConfigButton", false)
		if cfgBtn then
			cfgBtn:Show(true)
		end
	end
end

----------------------------------------------------------------------------------------------------

local function updatePlacement(stack)
	for i = #STACK[stack], 1, -1 do
		local v = STACK[stack][i]
		local tempPos = TEMPLATE[stack]:GetPlacementPlain()

		tempPos.posY = tempPos.posY +
			(tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "IconPadding")) * 2) *
			(#STACK[stack] - i)
		WtSetPlace(v, tempPos)
		local show = (#STACK[stack] + 1 - i) <= tonumber(UI.get("PanelSettings", "MaxBars"))
		v:Show(show)

		if (not show) then
			table.remove(STACK[stack], i)
			v:DestroyWidget()
		end
	end
end

local function fadePlate(plate)
	plate:PlayFadeEffect(1.0, 0.0, 500, EA_MONOTONOUS_INCREASE, true)
end

local function destroyPlate(widget, stack)
	widget:Show(false)

	for k, v in pairs(STACK[stack]) do
		if (v:GetName() == widget:GetName()) then
			table.remove(STACK[stack], k)
			v:DestroyWidget()
		end
	end

	updatePlacement(stack)
end

local function onPlayEffectFinished(e)
	if e.wtOwner then
		if (e.effectType == 2) then
			local split_string = {}
			for w in e.wtOwner:GetName():gmatch('([^_]+)') do table.insert(split_string, w) end

			if (TEMPLATE[split_string[1]]) then
				e.wtOwner:SetName(e.wtOwner:GetName() .. "_fading")
				fadePlate(e.wtOwner)
			end
		elseif (e.effectType == 1) then
			local split_string = {}
			for w in e.wtOwner:GetName():gmatch('([^_]+)') do table.insert(split_string, w) end

			if (TEMPLATE[split_string[1]]) then
				if (split_string[3] and split_string[3] == 'fading') then
					destroyPlate(e.wtOwner, split_string[1])
				end
			end
		end
	end
end

local function pushToStack(params, stack)
	if (not TEMPLATE[stack]) then return end
	if ((params.name == "" or params.name == nil) and not UI.get("PanelSettings", "ShowUnnamed")) then return end

	counter = counter + 1
	local plate = mainForm:CreateWidgetByDesc(TEMPLATE[stack]:GetWidgetDesc())
	plate:SetName(stack .. "_" .. tostring(counter))
	plate:Show(true)

	plate:SetBackgroundColor({ r = 0.0, g = 0.0, b = 0.0, a = 0.0 })
	local tempPos = TEMPLATE[stack]:GetPlacementPlain()
	WtSetPlace(plate, tempPos)
	WtSetPlace(plate,
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "IconPadding")) * 2,
			sizeX = 300
		})
	table.insert(STACK[stack], plate)
	updatePlacement(stack)

	plate:PlayFadeEffect(0.0, 1.0, 500, EA_MONOTONOUS_INCREASE, true)

	local background
	if (UI.get("PanelBackground", "ShowBg")) then
		background = CreateWG("PlateBg", "BG", plate, true,
			{
				alignX = 0,
				sizeX = tempPos.sizeX,
				posX = 0,
				highPosX = 0,
				alignY = 0,
				sizeY = tempPos.sizeY,
				posY = 0,
				highPosY = 0
			})
		background:SetBackgroundColor(UI.getGroupColor("PanelBackgroundColor"))
		background:Show(true)
	end

	if (params.icon) then
		plate:GetChildChecked("IconSpell", true):SetBackgroundTexture(params.icon)
	end

	local _name = ""
	local _amount = 0

	if (params.name) then _name = params.name end
	if (params.amount) then _amount = params.amount end

	local _formatedAmount = tostring(_amount)

	if (UI.get("Formatting", "ShortNum")) then
		local floatP = UI.get("Formatting", "FloatFormat")
		if (floatP and floatP ~= "0") then
			floatP = "%." .. floatP
		else
			floatP = nil
		end

		if (UI.get("Formatting", "ShortenToMill") and _amount >= 1000000) then
			if (floatP) then
				_formatedAmount = FromWS(common.FormatFloat(_amount / 1000000, floatP .. 'f')) .. "M"
			else
				---@diagnostic disable-next-line: undefined-field
				_formatedAmount = FromWS(common.FormatInt(math.round(_amount / 1000000), '%d')) .. "M"
			end
		elseif (_amount >= 1000) then
			if (floatP) then
				_formatedAmount = FromWS(common.FormatFloat(_amount / 1000, floatP .. 'f')) .. "K"
			else
				---@diagnostic disable-next-line: undefined-field
				_formatedAmount = FromWS(common.FormatInt(math.round(_amount / 1000), '%d')) .. "K"
			end
		end
	end

	local maxTextSize = 1000
	local fontSize = (tonumber(UI.get("PanelSettings", "IconSize")) / 2 + 4)

	if (stack == 'inc') then
		WtSetPlace(plate:GetChildChecked("IconSpell", true),
			{
				sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
				sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
				posX = tonumber(UI.get("PanelSettings", "IconPadding")),
				highPosX = 0
			})

		local incLabel = CreateWG("Label", "CastName", plate, true,
			{
				alignX = 0,
				sizeX = maxTextSize,
				posX = tonumber(UI.get("PanelSettings", "IconSize")) +
					tonumber(UI.get("PanelSettings", "TextPadding")) * 2,
				highPosX = 0,
				alignY = 2,
				sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
				posY = 0,
				highPosY = 0
			})
		incLabel:SetFormat(userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='" ..
			tostring(fontSize) ..
			"' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>"))
		incLabel:SetVal("dmg", _formatedAmount)
		incLabel:SetClassVal("dmg", params.amountClass or "ColorRed")
		if (not UI.get("PanelSettings", "HideLabels")) then
			incLabel:SetVal("sep", " - ")
			incLabel:SetClassVal("sep", "ColorWhite")
			incLabel:SetVal("name", _name)
			incLabel:SetClassVal("class", params.nameClass or "ColorWhite")
		end
	else
		WtSetPlace(plate:GetChildChecked("IconSpell", true),
			{
				sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
				sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
				posX = 0,
				highPosX = tonumber(UI.get("PanelSettings", "IconPadding"))
			})
		local outLabel = CreateWG("Label", "CastName", plate, true,
			{
				alignX = 1,
				sizeX = maxTextSize,
				posX = 0,
				highPosX = tonumber(UI.get("PanelSettings", "IconSize")) +
					tonumber(UI.get("PanelSettings", "TextPadding")) *
					2,
				alignY = 2,
				sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
				posY = 0,
				highPosY = 0
			})
		outLabel:SetFormat(userMods.ToWString("<html><body alignx='right' aligny='middle' fontsize='" ..
			tostring(fontSize) ..
			"' outline='1' shadow='1'><rs class='class'><r name='name'/></rs><rs class='sep'><r name='sep'/></rs><rs class='dmg'><r name='dmg'/></rs></body></html>"))
		outLabel:SetVal("dmg", _formatedAmount)
		outLabel:SetClassVal("dmg", params.amountClass or "ColorRed")

		if (not UI.get("PanelSettings", "HideLabels")) then
			outLabel:SetVal("name", _name)
			outLabel:SetClassVal("class", params.nameClass or "ColorWhite")
			outLabel:SetVal("sep", " - ")
			outLabel:SetClassVal("sep", "ColorWhite")
		end
	end

	if (background) then
		local w = (#(_formatedAmount) + 3 + #_name) * (fontSize * 0.61)
		if (UI.get("PanelBackground", "UseBgCustomWidth")) then
			w = tonumber(UI.get("PanelBackground", "BgCustomWidth"))
		elseif (UI.get("PanelSettings", "HideLabels")) then
			w = (#(_formatedAmount)) * (fontSize * 0.61)
		end
		if (stack == "out") then
			WtSetPlace(background, {
				sizeX = (tonumber(UI.get("PanelSettings", "IconPadding")) + tonumber(UI.get("PanelSettings", "TextPadding")) + tonumber(UI.get("PanelSettings", "IconSize")) + w),
				alignX = 1,
				highPosX = 0,
				posX = 0,
				sizeY = tonumber(UI.get("PanelSettings", "IconSize"))
			})
		else
			WtSetPlace(background, {
				sizeX = (tonumber(UI.get("PanelSettings", "IconPadding")) + tonumber(UI.get("PanelSettings", "TextPadding")) + tonumber(UI.get("PanelSettings", "IconSize")) + w),
				alignX = 0,
				highPosX = 0,
				posX = 0,
				sizeY = tonumber(UI.get("PanelSettings", "IconSize"))
			})
		end
	end

	plate:SetTransparentInput(true)
	plate:SetClipContent(false)
	plate:PlayResizeEffect(plate:GetPlacementPlain(), plate:GetPlacementPlain(),
		tonumber(UI.get("PanelSettings", "ShowTime")), EA_MONOTONOUS_INCREASE, true)
end

local function onUnitHeal(e)
	-- pushToChatSimple("onUnitHeal: "..FromWS(e.ability).." - ("..FromWS(object.GetName(e.target))..") from ("..FromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.healerId,
		target = e.unitId,
		amount = e.heal,
		amountClass = UI.get("NumColors", "HEAL_NUM"),
		nameClass = UI.get("LabelColors", "HEAL_NAME"),
		icon = nil,
		name = ""
	}

	if (params.target == nil or params.source == nil) then return end

	if (UI.get("Formatting", "IgnoreBloodlust") and e.runeResisted == 0 and object.IsInCombat(avatar.GetId())) then return end

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		-- We got healed by player
		if (unit.IsPlayer(params.source)) then
			category = "incP"
			if (tonumber(UI.get("DamageFilteringP", "MinIncPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinIncPlayerHeal"))) then return end
		else -- We got healed by unit
			category = "incU"
			if (tonumber(UI.get("DamageFilteringU", "MinIncUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinIncUnitHeal"))) then return end
		end
		stack = "inc"
	elseif (params.source == avatar.GetId()) then
		-- We healed player
		if (unit.IsPlayer(params.target)) then
			category = "outP"
			if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal"))) then return end
		else -- We healed unit
			category = "outU"
			if (tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal"))) then return end
		end

		if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and unit.IsPlayer(params.target)) then return end
		if (tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and not unit.IsPlayer(params.target)) then return end
		stack = "out"
	end

	if (stack) then
		if (e.spellId) then
			params.icon = spellLib.GetIcon(e.spellId)
			params.name = FromWS(spellLib.GetDescription(e.spellId).name)
		elseif (e.buffId) then
			local info = object.GetBuffInfo(e.buffId) or avatar.GetBuffInfo(e.buffId)

			if (info) then
				if (info.texture) then
					params.icon = info.texture
				elseif (info.producer and info.producer.spellId) then
					params.icon = spellLib.GetIcon(info.producer.spellId)
				end

				if (info.name) then params.name = FromWS(info.name) end
			end
		elseif (e.abilityId) then
			local info = avatar.GetAbilityInfo(e.abilityId)
			if (info and info.texture) then params.icon = info.texture end
			if (info and info.name) then params.name = FromWS(info.name) end
		end

		params.realName = params.name

		-- if (params.name == lastDMG and UI.get("Formatting", "IgnoreBloodlust")) then return end

		if (params.target == avatar.GetId()) then
			if (UI.get("Formatting", "ReplaceByName") and FromWS(object.GetName(params.source)) ~= "") then
				params.name =
					FromWS(object.GetName(params.source))
			end
		elseif (params.source == avatar.GetId()) then
			if (UI.get("Formatting", "ReplaceByName") and FromWS(object.GetName(params.target)) ~= "") then
				params.name =
					FromWS(object.GetName(params.target))
			end
		end

		if (UI.get("ShowOnlyNames", "ShowOnly") and not (UI.get("ShowOnlyNames", "ShowOnlyInc") and stack == "inc")) then
			local item = UI.getItem("ShowOnlyNames", FromWS(e.ability))
			if (not item or not item.enabled) then
				return
			else
				if (not item[category]) then return end
			end
		elseif (UI.get("IgnoredNames", "EnableIgnore")) then
			local item = UI.getItem("IgnoredNames", FromWS(e.ability))
			if (item and item.enabled and item[category]) then return end
		end

		if (e.isCritical and UI.get("LabelColors", "CRIT_HEAL_NAME")) then
			params.nameClass = UI.get("LabelColors",
				"CRIT_HEAL_NAME")
		end
		if (e.isCritical and UI.get("NumColors", "CRIT_HEAL_NUM")) then
			params.amountClass = UI.get("NumColors",
				"CRIT_HEAL_NUM")
		end

		if (UI.get("PanelSettings", "EnableCustomIcons") and GetGroupTexture("CUSTOM_ICONS", params.realName) ~= nil) then
			params.icon = GetGroupTexture("CUSTOM_ICONS", params.realName)
		end

		pushToStack(params, stack)
	end
end

local function onUnitDamage(e)
	-- pushToChatSimple("onUnitDamage: "..FromWS(e.ability).." - ("..FromWS(object.GetName(e.target))..") from ("..FromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.source,
		target = e.target,
		amount = e.amount,
		amountClass = UI.get("NumColors", "DMG_NUM") or "DamageYellow",
		nameClass = UI.get("LabelColors", "DMG_NAME") or "ColorWhite",
		icon = nil,
		name = ""
	}

	if (params.target == nil or params.source == nil) then return end

	if (e.ability ~= nil) then
		params.name = FromWS(e.ability)
	end

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		if (params.source ~= nil and UI.get("Formatting", "ReplaceByName") and FromWS(object.GetName(params.source)) ~= "") then
			params.name = FromWS(object.GetName(params.source))
		end
		if (UI.get("Formatting", "HideIncMisses") and (e.isMiss or e.isDodge)) then return end

		-- We got damage from player
		if (params.source ~= nil) then
			if (unit.IsPlayer(params.source)) then
				category = "incP"
				if (tonumber(UI.get("DamageFilteringP", "MinIncPlayerDmg")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinIncPlayerDmg"))) then return end
			else -- We got damage from unit
				category = "incU"
				if (tonumber(UI.get("DamageFilteringU", "MinIncUnitDmg")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinIncUnitDmg"))) then return end
			end
		end

		stack = "inc"
		if (UI.get("PanelSettings", "SwapPanels")) then
			stack = "out"
		end
	elseif (params.source ~= nil and (params.source == avatar.GetId() or (unit.IsPet(params.source) and avatar.GetId() == unit.GetPetOwner(params.source)))) then
		if (params.target ~= nil and UI.get("Formatting", "ReplaceByName") and FromWS(object.GetName(params.target)) ~= "") then
			params.name =
				FromWS(object.GetName(params.target))
		end
		if (UI.get("Formatting", "HideOutMisses") and (e.isMiss or e.isDodge)) then return end

		-- We did damage to player
		if (params.target ~= nil) then
			if (unit.IsPlayer(params.target)) then
				category = "outP"
				if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerDmg")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerDmg"))) then return end
			else -- We did damage to unit
				category = "outU"
				if (tonumber(UI.get("DamageFilteringU", "MinOutUnitDmg")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitDmg"))) then return end
			end
		end

		stack = "out"
		if (UI.get("PanelSettings", "SwapPanels")) then
			stack = "inc"
		end
	else
		return
	end

	if (UI.get("ShowOnlyNames", "ShowOnly") and not (UI.get("ShowOnlyNames", "ShowOnlyInc") and stack == "inc")) then
		local item = UI.getItem("ShowOnlyNames", FromWS(e.ability))
		if (not item or not item.enabled) then
			return
		else
			if (not item[category]) then return end
		end
	elseif (UI.get("IgnoredNames", "EnableIgnore")) then
		local item = UI.getItem("IgnoredNames", FromWS(e.ability))
		if (item and item.enabled and item[category]) then return end
	end

	local shelf_val = {

	}

	if (stack) then
		if (e.buffId) then
			local info = object.GetBuffInfo(e.buffId) or avatar.GetBuffInfo(e.buffId)

			if (info) then
				if (info.texture) then
					params.icon = info.texture
				elseif (info.producer and info.producer.spellId) then
					params.icon = spellLib.GetIcon(info.producer.spellId)
				end
				shelf_val.buffId = object.GetBuffInfo(e.buffId).buffId
			end
		end
		if (not params.icon and e.spellId) then
			params.icon = spellLib.GetIcon(e.spellId)
			shelf_val.spellId = e.spellId
		end
		if (not params.icon and e.abilityId) then
			local info = avatar.GetAbilityInfo(e.abilityId)
			if (info and info.texture) then params.icon = info.texture end
			shelf_val.abilityId = e.abilityId
		end
		if (not params.icon and e.mapModifierId) then
			local info = cartographer.GetMapModifierInfo(e.mapModifierId)
			if (info and info.image) then params.icon = info.image end
			shelf_val.mapModifierId = e.mapModifierId
		end

		if (e.isFall) then
			params.icon = GetGroupTexture("RELATED_TEXTURES", "FALL")
			params.name = GetLocaleText("DMG_FALL")
		end

		if (e.damageSource) then
			if (e.damageSource == "DamageSource_BARRIER") then
				params.name = GetLocaleText("DMG_BARRIER")
				if (params.icon == nil) then
					params.icon = GetGroupTexture("RELATED_TEXTURES", "BARRIER")
				end
			end
		end

		if (params.icon) then
			UI.registerTexture(FromWS(e.ability), shelf_val)
		elseif (UI.get("PanelSettings", "ReplacePlaceholder")) then
			params.icon = GetGroupTexture("RELATED_TEXTURES", "UNKNOWN_ATTACK")
		end

		if (e.lethal and UI.get("LabelColors", "LETHAL_NAME") ~= "-") then
			params.nameClass = UI.get("LabelColors",
				"LETHAL_NAME")
		end
		if (e.lethal and UI.get("NumColors", "LETHAL_NUM") ~= "-") then
			params.amountClass = UI.get("NumColors",
				"LETHAL_NUM")
		end

		if (e.isCritical and UI.get("LabelColors", "CRIT_DMG_NAME")) then
			params.nameClass = UI.get("LabelColors",
				"CRIT_DMG_NAME")
		end
		if (e.isCritical and UI.get("NumColors", "CRIT_DMG_NUM")) then
			params.amountClass = UI.get("NumColors",
				"CRIT_DMG_NUM")
		end

		if (e.isDodge and UI.get("LabelColors", "MISS_NAME")) then params.nameClass = UI.get("LabelColors", "MISS_NAME") end
		if (e.isDodge and UI.get("NumColors", "MISS_NUM")) then params.amountClass = UI.get("NumColors", "MISS_NUM") end

		if (e.isMiss and UI.get("LabelColors", "MISS_NAME")) then params.nameClass = UI.get("LabelColors", "MISS_NAME") end
		if (e.isMiss and UI.get("NumColors", "MISS_NUM")) then params.amountClass = UI.get("NumColors", "MISS_NUM") end

		if (UI.get("PanelSettings", "EnableCustomIcons") and GetGroupTexture("CUSTOM_ICONS", FromWS(e.ability)) ~= nil) then
			params.icon = GetGroupTexture("CUSTOM_ICONS", FromWS(e.ability))
		end

		pushToStack(params, stack)
	end
end

local function onSlash(p)
	local m = userMods.FromWString(p.text)
	local split_string = {}
	for w in m:gmatch("%S+") do table.insert(split_string, w) end

	if (split_string[1]:lower() == "/ddtest" and split_string[2]) then
		pushToStack({}, split_string[2])
	elseif (split_string[1]:lower() == "/ddsettings") then
		UI.print()
	end
end

function ToggleDnd()
	local dndEnabled = not (out_template:IsVisibleEx() and inc_template:IsVisibleEx())

	DnD.Enable(out_template, dndEnabled)
	out_template:Show(dndEnabled)
	out_template:SetTransparentInput(not dndEnabled)

	DnD.Enable(inc_template, dndEnabled)
	inc_template:Show(dndEnabled)
	inc_template:SetTransparentInput(not dndEnabled)


	if (dndEnabled) then
		Log("Drag & Drop - On.")
	else
		Log("Drag & Drop - Off.")
	end

	UI.dnd(dndEnabled)
end

local function onCfgLeft()
	if DnD:IsDragging() then
		return
	end

	UI.toggle()
end

local function onCfgRight()
	if DnD:IsDragging() then
		return
	end

	ToggleDnd()
end

local function setUpTemplates()
	local maxTextSize = 1000

	WtSetPlace(inc_template,
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "IconPadding")) * 2,
			sizeX = 300
		})
	WtSetPlace(inc_template:GetChildChecked("IconSpell", true),
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
			posX = tonumber(UI.get("PanelSettings", "IconPadding")),
			highPosX = 0
		})

	local incLabel = CreateWG("Label", "CastName", inc_template, true,
		{
			alignX = 0,
			sizeX = maxTextSize,
			posX = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "TextPadding")) * 2,
			highPosX = 0,
			alignY = 2,
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			posY = 0,
			highPosY = 0
		})
	incLabel:SetFormat(userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='" ..
		tostring(tonumber(UI.get("PanelSettings", "IconSize")) / 2 + 4) ..
		"' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>"))
	incLabel:SetVal("name", "Anafema")
	incLabel:SetClassVal("class", "DamageYellow")

	incLabel:SetVal("dmg", "5411K")
	incLabel:SetClassVal("dmg", "ColorRed")

	incLabel:SetVal("sep", " - ")
	incLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(inc_template, inc_template:GetChildChecked("IconSpell", true), true)
	inc_template:SetTransparentInput(true)
	inc_template:Show(false)


	WtSetPlace(out_template,
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "IconPadding")) * 2,
			sizeX = 300
		})
	WtSetPlace(out_template:GetChildChecked("IconSpell", true),
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
			highPosX = tonumber(UI.get("PanelSettings", "IconPadding")),
			posX = 0
		})

	local outLabel = CreateWG("Label", "CastName", out_template, true,
		{
			alignX = 1,
			sizeX = maxTextSize,
			posX = 0,
			highPosX = tonumber(UI.get("PanelSettings", "IconSize")) +
				tonumber(UI.get("PanelSettings", "TextPadding")) * 2,
			alignY = 2,
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			posY = 0,
			highPosY = 0
		})
	outLabel:SetFormat(userMods.ToWString("<html><body alignx='right' aligny='middle' fontsize='" ..
		tostring(tonumber(UI.get("PanelSettings", "IconSize")) / 2 + 4) ..
		"' outline='1' shadow='1'><rs class='class'><r name='name'/></rs><rs class='sep'><r name='sep'/></rs><rs class='dmg'><r name='dmg'/></rs></body></html>"))

	outLabel:SetVal("name", "Anafema")
	outLabel:SetClassVal("class", "DamageYellow")

	outLabel:SetVal("dmg", "5411K")
	outLabel:SetClassVal("dmg", "ColorRed")

	outLabel:SetVal("sep", " - ")
	outLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(out_template, out_template:GetChildChecked("IconSpell", true), true)
	out_template:SetTransparentInput(true)
	out_template:Show(false)
end

local function addShowCB(widget, settings, editline)
	editline:SetFocus(false)
	local text = editline:GetString()

	UI.groupPush("ShowOnlyNames",
		UI.createItemSetting(text, {
			iconName = text,
			checkboxes = {
				{
					name = "outP",
					label = "CB_outP",
					default = false
				},
				{
					name = "incP",
					label = "CB_incP",
					default = false
				},
				{
					name = "outU",
					label = "CB_outU",
					default = false
				},
				{
					name = "incU",
					label = "CB_incU",
					default = false
				},
			}
		}, true), true
	)

	UI.render()
end

local function addIgnoreCB(widget, settings, editline)
	editline:SetFocus(false)
	local text = editline:GetString()

	UI.groupPush("IgnoredNames",
		UI.createItemSetting(text, {
			iconName = text,
			checkboxes = {
				{
					name = "outP",
					label = "CB_outP",
					default = false
				},
				{
					name = "incP",
					label = "CB_incP",
					default = false
				},
				{
					name = "outU",
					label = "CB_outU",
					default = false
				},
				{
					name = "incU",
					label = "CB_incU",
					default = false
				},
			}
		}, true), true
	)

	UI.render()
end

local function setupUI()
	UI.addGroup("PanelSettings", {
		UI.createInput("MaxBars", {
			maxChars = 3,
			filter = "_INT"
		}, '7'),
		UI.createList("IconSize", range(16, 128, 4), 4, false),
		UI.createList("IconPadding", range(0, 6, 1), 1, false),
		UI.createList("TextPadding", range(0, 10, 1), 2, false),
		UI.createInput("ShowTime", {
			maxChars = 6,
			filter = "_INT"
		}, '8000'),
		UI.createCheckBox("ReplacePlaceholder", true),
		UI.createCheckBox("ShowUnnamed", false),
		UI.createCheckBox("EnableCustomIcons", true),
		UI.createCheckBox("HideLabels", false),
		UI.createCheckBox("SwapPanels", false),
	})

	UI.addGroup("Formatting", {
		UI.createCheckBox("ShortNum", true),
		UI.createCheckBox("ShortenToMill", true),
		UI.createList("FloatFormat", range(0, 2, 1), 2, false),

		UI.createCheckBox("ReplaceByName", false),
		UI.createCheckBox("IgnoreBloodlust", true),
		UI.createCheckBox("HideOutMisses", true),
		UI.createCheckBox("HideIncMisses", true),
	})

	UI.addGroup("NumColors", {
		UI.createList("DMG_NUM", UI.getClassList(), 2, true),
		UI.createList("CRIT_DMG_NUM", UI.getClassList(), 3, true),
		UI.createList("HEAL_NUM", UI.getClassList(), 4, true),
		UI.createList("CRIT_HEAL_NUM", UI.getClassList(), 5, true),
		UI.createList("MISS_NUM", UI.getClassList(), 6, true),
		UI.createList("LETHAL_NUM", UI.getClassList(true), 0, true),
	})

	UI.addGroup("LabelColors", {
		UI.createList("DMG_NAME", UI.getClassList(), 1, true),
		UI.createList("CRIT_DMG_NAME", UI.getClassList(), 1, true),
		UI.createList("HEAL_NAME", UI.getClassList(), 1, true),
		UI.createList("CRIT_HEAL_NAME", UI.getClassList(), 1, true),
		UI.createList("MISS_NAME", UI.getClassList(), 1, true),
		UI.createList("LETHAL_NAME", UI.getClassList(true), 15, true),
	})

	UI.addGroup("DamageFilteringP", {
		UI.createInput("MinOutPlayerDmg", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinOutPlayerHeal", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinIncPlayerDmg", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinIncPlayerHeal", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
	})

	UI.addGroup("DamageFilteringU", {
		UI.createInput("MinOutUnitDmg", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinOutUnitHeal", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinIncUnitDmg", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
		UI.createInput("MinIncUnitHeal", {
			maxChars = 10,
			filter = "_INT"
		}, '1'),
	})

	UI.addGroup("PanelBackground", {
		UI.createCheckBox("ShowBg", false),
		UI.createCheckBox("UseBgCustomWidth", false),
		UI.createInput("BgCustomWidth", {
			maxChars = 5,
			filter = "_INT"
		}, '100'),
	})

	UI.createColorGroup("PanelBackgroundColor", {
		r = 0,
		g = 0,
		b = 0,
		a = 50,
	})

	UI.addGroup("IgnoredNames", {
		UI.createCheckBox("EnableIgnore", false),
		UI.createButtonInput("AddIgnore", {
			width = 90,
			states = {
				"ButtonAdd",
			},
			callback = addIgnoreCB
		}, 1),
	})

	UI.addGroup("ShowOnlyNames", {
		UI.createCheckBox("ShowOnly", false),
		UI.createCheckBox("ShowOnlyInc", false),
		UI.createButtonInput("AddShow", {
			width = 90,
			states = {
				"ButtonAdd",
			},
			callback = addShowCB
		}, 1),
	})

	UI.setTabs({
		{
			label = "Common",
			buttons = {
				left = { "Restore" },
				right = { "Accept" }
			},
			groups = {
				"PanelSettings",
				"Formatting",
				"DamageFilteringP",
				"DamageFilteringU",
			}
		},
		{
			label = "Visual",
			buttons = {
				left = { "Restore" },
				right = { "Accept" }
			},
			groups = {
				"NumColors",
				"LabelColors",
				"PanelBackground",
				"PanelBackgroundColor",
			}
		},
		{
			label = "Ignored",
			buttons = {
				right = { "Accept" }
			},
			groups = {
				"IgnoredNames"
			}
		},
		{
			label = "ShowOnly",
			buttons = {
				right = { "Accept" }
			},
			groups = {
				"ShowOnlyNames"
			}
		}
	}, "Common")

	UI.loadUserSettings()
	UI.render()
end

function Init()
	LANG = common.GetLocalization() or "rus"
	UI.init("ShowCustomDD")

	common.RegisterEventHandler(onUnitDamage, 'EVENT_UNIT_DAMAGE_RECEIVED')
	common.RegisterEventHandler(onUnitHeal, 'EVENT_HEALING_RECEIVED')

	common.RegisterEventHandler(onPlayEffectFinished, 'EVENT_EFFECT_FINISHED')
	common.RegisterEventHandler(onSlash, 'EVENT_UNKNOWN_SLASH_COMMAND')
	common.RegisterReactionHandler(onCfgLeft, "ConfigLeftClick")
	common.RegisterReactionHandler(onCfgRight, "ConfigRightClick")

	-- AOPanel
	common.RegisterEventHandler(onAOPanelStart, "AOPANEL_START")
	common.RegisterEventHandler(onAOPanelLeftClick, "AOPANEL_BUTTON_LEFT_CLICK")
	common.RegisterEventHandler(onAOPanelRightClick, "AOPANEL_BUTTON_RIGHT_CLICK")
	common.RegisterEventHandler(onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED")

	local cfgBtn = mainForm:GetChildChecked("ConfigButton", false)
	DnD.Init(cfgBtn, cfgBtn, true)
	DnD.Enable(cfgBtn, true)

	setupUI()
	setUpTemplates()
	local damageVis = common.GetAddonMainForm("ContextDamageVisualization")
	if (damageVis ~= nil) then
		damageVis:Show(false)
	end
end

if (avatar.IsExist()) then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end
