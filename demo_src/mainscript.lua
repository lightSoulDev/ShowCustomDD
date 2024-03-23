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

function onPlayEffectFinished(e)
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

function fadePlate(plate)
	plate:PlayFadeEffect(1.0, 0.0, 500, EA_MONOTONOUS_INCREASE, true)
end

function destroyPlate(widget, stack)
	widget:Show(false)

	for k, v in pairs(STACK[stack]) do
		if (v:GetName() == widget:GetName()) then
			table.remove(STACK[stack], k)
			v:DestroyWidget()
		end
	end

	updatePlacement(stack)
end

function updatePlacement(stack)
	for i = #STACK[stack], 1, -1 do
		local v = STACK[stack][i]
		local tempPos = TEMPLATE[stack]:GetPlacementPlain()

		tempPos.posY = tempPos.posY + (tonumber(UI.get("PanelSettings", "IconSize")) + 0 * 2) * (#STACK[stack] - i)
		WtSetPlace(v, tempPos)
		local show = (#STACK[stack] + 1 - i) <= tonumber(UI.get("PanelSettings", "MaxBars"))
		v:Show(show)

		if (not show) then
			table.remove(STACK[stack], i)
			v:DestroyWidget()
		end
	end
end

function getTexture(name)
	local group = common.GetAddonRelatedTextureGroup("RELATED_TEXTURES")

	if group and group:HasTexture(name) then
		return group:GetTexture(name)
	end

	return nil
end

function getCustomIcon(name)
	local group = common.GetAddonRelatedTextureGroup("CUSTOM_ICONS")

	if group and group:HasTexture(name) then
		return group:GetTexture(name)
	end

	return nil
end

function onUnitHeal(e)
	-- pushToChatSimple("onUnitHeal: "..FromWS(e.ability).." - ("..FromWS(object.GetName(e.target))..") from ("..FromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.healerId,
		target = e.unitId,
		amount = e.heal,
		amountClass = "ColorWarmGreen",
		nameClass = "ColorWhite",
		icon = nil,
		name = ""
	}

	if (params.target == nil or params.source == nil) then return end

	if (UI.get("Formatting", "IgnoreBloodlust") and e.runeResisted == 0 and object.IsInCombat(avatar.GetId())) then return end

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		if (unit.IsPlayer(params.source)) then
			category = "incP"
			category = "incU"
		end
		stack = "inc"
	elseif (params.source == avatar.GetId()) then
		if (unit.IsPlayer(params.target)) then
			category = "outP"
			category = "outU"
		end

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

		if (e.isCritical) then params.amountClass = "DamageGreen" end

		pushToStack(params, stack)
	end
end

function onUnitDamage(e)
	-- pushToChatSimple("onUnitDamage: "..FromWS(e.ability).." - ("..FromWS(object.GetName(e.target))..") from ("..FromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.source,
		target = e.target,
		amount = e.amount,
		amountClass = "DamageYellow",
		nameClass = "ColorWhite",
		icon = nil,
		name = FromWS(e.ability)
	}

	local stack
	local category = "any"

	if (params.target == nil or params.source == nil) then return end

	if (params.target == avatar.GetId()) then
		-- ��� ������ �����
		if (unit.IsPlayer(params.source)) then
			category = "incP"
		else -- ��� ������ ���
			category = "incU"
		end

		stack = "inc"
	elseif (params.source == avatar.GetId() or (unit.IsPet(params.source) and avatar.GetId() == unit.GetPetOwner(params.source))) then
		-- ������� �� ������
		if (unit.IsPlayer(params.target)) then
			category = "outP"
		else -- ������� �� ������
			category = "outU"
		end

		stack = "out"
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
			params.icon = getTexture("FALL")
			params.name = GetLocaleText("DMG_FALL")
		end

		if (e.damageSource) then
			if (e.damageSource == "DamageSource_BARRIER") then
				params.name = GetLocaleText("DMG_BARRIER")
				if (params.icon == nil) then
					params.icon = getTexture("BARRIER")
				end
			end
		end

		if (params.icon) then UI.registerTexture(FromWS(e.ability), shelf_val) end

		if (e.isCritical) then params.amountClass = "DamageRed" end

		if (e.isDodge) then params.amountClass = "Junk" end
		if (e.isMiss) then params.amountClass = "Junk" end

		pushToStack(params, stack)
	end
end

function pushToStack(params, stack)
	if (not TEMPLATE[stack]) then return end

	counter = counter + 1
	local plate = mainForm:CreateWidgetByDesc(TEMPLATE[stack]:GetWidgetDesc())
	plate:SetName(stack .. "_" .. tostring(counter))
	plate:Show(true)

	plate:SetBackgroundColor({ r = 0.0, g = 0.0, b = 0.0, a = 0.0 })
	local tempPos = TEMPLATE[stack]:GetPlacementPlain()
	WtSetPlace(plate, tempPos)
	WtSetPlace(plate, { sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + 0 * 2, sizeX = 300 })
	table.insert(STACK[stack], plate)
	updatePlacement(stack)

	plate:PlayFadeEffect(0.0, 1.0, 500, EA_MONOTONOUS_INCREASE, true)

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
				posX = 0,
				highPosX = 0
			})

		local incLabel = CreateWG("Label", "CastName", plate, true,
			{
				alignX = 0,
				sizeX = maxTextSize,
				posX = tonumber(UI.get("PanelSettings", "IconSize")) + 2 * 2,
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
				highPosX = 0
			})
		local outLabel = CreateWG("Label", "CastName", plate, true,
			{
				alignX = 1,
				sizeX = maxTextSize,
				posX = 0,
				highPosX = tonumber(UI.get("PanelSettings", "IconSize")) + 2 * 2,
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

	plate:SetTransparentInput(true)
	plate:SetClipContent(false)
	plate:PlayResizeEffect(plate:GetPlacementPlain(), plate:GetPlacementPlain(),
		tonumber(UI.get("PanelSettings", "ShowTime")), EA_MONOTONOUS_INCREASE, true)
end

function onSlash(p)
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

	UI.dnd(dndEnabled)
end

function onCfgLeft()
	if DnD:IsDragging() then
		return
	end

	UI.toggle()
end

function onCfgRight()
	if DnD:IsDragging() then
		return
	end

	ToggleDnd()
end

function Init()
	LANG = common.GetLocalization() or "rus"
	UI.init("DemoShowCustomDD")

	common.RegisterEventHandler(onUnitDamage, 'EVENT_UNIT_DAMAGE_RECEIVED')
	common.RegisterEventHandler(onUnitHeal, 'EVENT_HEALING_RECEIVED')

	common.RegisterEventHandler(onPlayEffectFinished, 'EVENT_EFFECT_FINISHED')
	common.RegisterEventHandler(onSlash, 'EVENT_UNKNOWN_SLASH_COMMAND')
	common.RegisterReactionHandler(onCfgLeft, "ConfigLeftClick")
	common.RegisterReactionHandler(onCfgRight, "ConfigRightClick")

	local cfgBtn = mainForm:GetChildChecked("ConfigButton", false)
	DnD.Init(cfgBtn, cfgBtn, true)
	DnD.Enable(cfgBtn, true)

	setupUI()
	setUpTemplates()

	if (stateMainForm:GetChildUnchecked("ContextDamageVisualization", false) ~= nil) then
		stateMainForm:GetChildChecked("ContextDamageVisualization", false):Show(false)
	end
end

function setUpTemplates()
	local maxTextSize = 1000

	WtSetPlace(inc_template, { sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + 0 * 2, sizeX = 300 })
	WtSetPlace(inc_template:GetChildChecked("IconSpell", true),
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
			posX = 0,
			highPosX = 0
		})

	local incLabel = CreateWG("Label", "CastName", inc_template, true,
		{
			alignX = 0,
			sizeX = maxTextSize,
			posX = tonumber(UI.get("PanelSettings", "IconSize")) + 2 * 2,
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


	WtSetPlace(out_template, { sizeY = tonumber(UI.get("PanelSettings", "IconSize")) + 0 * 2, sizeX = 300 })
	WtSetPlace(out_template:GetChildChecked("IconSpell", true),
		{
			sizeY = tonumber(UI.get("PanelSettings", "IconSize")),
			sizeX = tonumber(UI.get("PanelSettings", "IconSize")),
			highPosX = 0,
			posX = 0
		})

	local outLabel = CreateWG("Label", "CastName", out_template, true,
		{
			alignX = 1,
			sizeX = maxTextSize,
			posX = 0,
			highPosX = tonumber(UI.get("PanelSettings", "IconSize")) + 2 * 2,
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

function setupUI()
	UI.addGroup("PanelSettings", {
		UI.createInput("MaxBars", {
			maxChars = 1,
			filter = "_INT"
		}, '7'),
		UI.createList("IconSize", range(20, 32, 4), 24, false),
		UI.createInput("ShowTime", {
			maxChars = 6,
			filter = "_INT"
		}, '8000'),
		UI.createCheckBox("HideLabels", false),
	})

	UI.addGroup("Formatting", {
		UI.createCheckBox("IgnoreBloodlust", true),
		UI.createCheckBox("ShortNum", true),
		UI.createCheckBox("ShortenToMill", true),
		UI.createList("FloatFormat", range(0, 2, 1), 2, false),
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
			}
		}
	}, "Common")

	UI.loadUserSettings()
	UI.render()
end

if (avatar.IsExist()) then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end
