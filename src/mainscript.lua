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
				e.wtOwner:SetName(e.wtOwner:GetName().."_fading")
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
	plate:PlayFadeEffect( 1.0, 0.0, 500 )
end

function destroyPlate(widget, stack)
	widget:Show(false)

	for k,v in pairs(STACK[stack]) do
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

		tempPos.posY = tempPos.posY + (tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "IconPadding"))*2)*(#STACK[stack] - i)
		wtSetPlace(v, tempPos)
		v:Show((#STACK[stack] + 1 - i) <= tonumber(UI.get("PanelSettings", "MaxBars")))
	end
end

function getTexture(name)
	local group = common.GetAddonRelatedTextureGroup( "RELATED_TEXTURES" )

	if group then
		return group:GetTexture(name)
	end

	return nil
end

function getCustomIcon(name)
	local group = common.GetAddonRelatedTextureGroup( "CUSTOM_ICONS" )

	if group then
		return group:GetTexture(name)
	end

	return nil
end

function onUnitHeal(e)
	-- pushToChatSimple("onUnitHeal: "..fromWS(e.ability).." - ("..fromWS(object.GetName(e.target))..") from ("..fromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.healerId,
		target = e.unitId,
		amount = e.heal,
		amountClass = UI.get("NumColors", "HEAL_NUM"),
		nameClass = UI.get("LabelColors", "HEAL_NAME"),
		icon = nil,
		name = ""
	}

	if (UI.get("Formatting", "IgnoreBloodlust") and e.runeResisted == 0 and object.IsInCombat(avatar.GetId())) then return end

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		-- Нас похилил игрок
		if (unit.IsPlayer(params.source)) then 
			category = "incP"
			if (tonumber(UI.get("DamageFilteringP", "MinIncPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinIncPlayerHeal"))) then return end
		else -- Нас похилил моб
			category = "incU"
			if (tonumber(UI.get("DamageFilteringU", "MinIncUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinIncUnitHeal"))) then return end
		end
		stack = "inc"
	elseif (params.source == avatar.GetId()) then

		-- Похилили по игроку
		if (unit.IsPlayer(params.target)) then 
			category = "outP"
			if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal"))) then return end
		else -- Похилили по юниту
			category = "outU"
			if (tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal"))) then return end
		end

		-- Похилили по игроку
		if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerHeal")) and unit.IsPlayer(params.target)) then return end
		-- Похилили по игроку
		if (tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitHeal")) and not unit.IsPlayer(params.target)) then return end
		stack = "out"
	end

	if (stack) then

		if (e.spellId) then
			params.icon = spellLib.GetIcon(e.spellId)
			params.name = fromWS(spellLib.GetDescription(e.spellId).name)
		elseif (e.buffId) then
			local info = object.GetBuffInfo( e.buffId ) or avatar.GetBuffInfo(e.buffId)

			if (info) then
				if (info.texture) then
					params.icon = info.texture
				elseif (info.producer and info.producer.spellId) then
					params.icon = spellLib.GetIcon(info.producer.spellId)
				end

				if (info.name) then params.name = fromWS(info.name) end
			end
		elseif (e.abilityId) then
			local info = avatar.GetAbilityInfo( e.abilityId )
			if (info and info.texture) then params.icon = texture end
			if (info and info.name) then params.name = fromWS(info.name) end
		end

		-- if (params.name == lastDMG and UI.get("Formatting", "IgnoreBloodlust")) then return end

		if (params.target == avatar.GetId()) then
			if (UI.get("Formatting", "ReplaceByName") and fromWS(object.GetName(params.source)) ~= "") then params.name = fromWS(object.GetName(params.source)) end
		elseif (params.source == avatar.GetId()) then
			if (UI.get("Formatting", "ReplaceByName") and fromWS(object.GetName(params.target)) ~= "") then params.name = fromWS(object.GetName(params.target)) end
		end

		if (UI.get("ShowOnlyNames", "ShowOnly") and not ( UI.get("ShowOnlyNames", "ShowOnlyInc") and stack == "inc") ) then
			local item = UI.getItem("ShowOnlyNames", fromWS(e.ability))
			if (not item or not item.enabled) then
				return
			else 
				if (not item[category]) then return end
			end
		elseif (UI.get("IgnoredNames", "EnableIgnore")) then
			local item = UI.getItem("IgnoredNames", fromWS(e.ability))
			if (item and item.enabled and item[category]) then return end
		end

		if (e.isCritical and UI.get("LabelColors", "CRIT_HEAL_NAME")) then params.nameClass = UI.get("LabelColors", "CRIT_HEAL_NAME") end
		if (e.isCritical and UI.get("NumColors", "CRIT_HEAL_NUM")) then params.amountClass = UI.get("NumColors", "CRIT_HEAL_NUM") end

		pushToStack(params, stack) 
	end
end

function onUnitDamage(e)
	-- pushToChatSimple("onUnitDamage: "..fromWS(e.ability).." - ("..fromWS(object.GetName(e.target))..") from ("..fromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.source,
		target = e.target,
		amount = e.amount,
		amountClass = UI.get("NumColors", "DMG_NUM") or "DamageYellow",
		nameClass = UI.get("LabelColors", "DMG_NAME") or "ColorWhite",
		icon = nil,
		name = fromWS(e.ability)
	}

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		if (UI.get("Formatting", "ReplaceByName") and fromWS(object.GetName(params.source)) ~= "") then params.name = fromWS(object.GetName(params.source)) end
		if (UI.get("Formatting", "HideIncMisses") and (e.isMiss or e.isDodge)) then return end

		-- Нас ударил игрок
		if (unit.IsPlayer(params.source)) then
			category = "incP"
			if (tonumber(UI.get("DamageFilteringP", "MinIncPlayerDmg")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinIncPlayerDmg"))) then return end
		else -- Нас ударил моб
			category = "incU"
			if (tonumber(UI.get("DamageFilteringU", "MinIncUnitDmg")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinIncUnitDmg"))) then return end
		end

		stack = "inc"
	elseif (params.source == avatar.GetId() or (unit.IsPet(params.source) and avatar.GetId() == unit.GetPetOwner(params.source))) then
		if (UI.get("Formatting", "ReplaceByName") and fromWS(object.GetName(params.target)) ~= "") then params.name = fromWS(object.GetName(params.target)) end
		if (UI.get("Formatting", "HideOutMisses") and (e.isMiss or e.isDodge)) then return end

		-- Ударили по игроку
		if (unit.IsPlayer(params.target)) then 
			category = "outP"
			if (tonumber(UI.get("DamageFilteringP", "MinOutPlayerDmg")) and params.amount < tonumber(UI.get("DamageFilteringP", "MinOutPlayerDmg"))) then return end
		else -- Ударили по игроку
			category = "outU"
			if (tonumber(UI.get("DamageFilteringU", "MinOutUnitDmg")) and params.amount < tonumber(UI.get("DamageFilteringU", "MinOutUnitDmg"))) then return end
		end

		stack = "out"
	else
		return
	end

	if (UI.get("ShowOnlyNames", "ShowOnly") and not ( UI.get("ShowOnlyNames", "ShowOnlyInc") and stack == "inc") ) then
		local item = UI.getItem("ShowOnlyNames", fromWS(e.ability))
		if (not item or not item.enabled) then
			return
		else 
			if (not item[category]) then return end
		end
	elseif (UI.get("IgnoredNames", "EnableIgnore")) then
		local item = UI.getItem("IgnoredNames", fromWS(e.ability))
		if (item and item.enabled and item[category]) then return end
	end

	local shelf_val = {

	}

	if (stack) then
		if (e.buffId) then
			local info = object.GetBuffInfo( e.buffId ) or avatar.GetBuffInfo(e.buffId)

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
			local info = avatar.GetAbilityInfo( e.abilityId )
			if (info and info.texture) then params.icon = info.texture end
			shelf_val.abilityId = e.abilityId
		end
		if (not params.icon and e.mapModifierId) then
			local info = cartographer.GetMapModifierInfo( e.mapModifierId )
			if (info and info.image) then params.icon = info.image end
			shelf_val.mapModifierId = e.mapModifierId
		end

		if (e.isFall) then
			params.icon = getTexture("FALL")
			params.name = getLocaleText("DMG_FALL")
		end
		if (e.isExploit) then pushToChatSimple("DamageFromExploit") end

		-- pushToChatSimple(e.damageSource)

		if (e.damageSource) then
			if (e.damageSource == "DamageSource_BARRIER") then
				params.name = getLocaleText("DMG_BARRIER")
				if (params.icon == nil) then
					params.icon = getTexture("BARRIER")
				end
			end
		end
		
		if (params.icon) then UI.registerTexture(fromWS(e.ability), shelf_val)
		elseif (UI.get("PanelSettings", "ReplacePlaceholder")) then params.icon = getTexture("UNKNOWN_ATTACK") end 

		if (e.lethal and UI.get("LabelColors", "LETHAL_NAME") ~= "-") then params.nameClass = UI.get("LabelColors", "LETHAL_NAME") end
		if (e.lethal and UI.get("NumColors", "LETHAL_NUM") ~= "-") then params.amountClass = UI.get("NumColors", "LETHAL_NUM") end

		if (e.isCritical and UI.get("LabelColors", "CRIT_DMG_NAME")) then params.nameClass = UI.get("LabelColors", "CRIT_DMG_NAME") end
		if (e.isCritical and UI.get("NumColors", "CRIT_DMG_NUM")) then params.amountClass = UI.get("NumColors", "CRIT_DMG_NUM") end

		if (e.isDodge and UI.get("LabelColors", "MISS_NAME")) then params.nameClass = UI.get("LabelColors", "MISS_NAME") end
		if (e.isDodge and UI.get("NumColors", "MISS_NUM")) then params.amountClass = UI.get("NumColors", "MISS_NUM") end

		if (e.isMiss and UI.get("LabelColors", "MISS_NAME")) then params.nameClass = UI.get("LabelColors", "MISS_NAME") end
		if (e.isMiss and UI.get("NumColors", "MISS_NUM")) then params.amountClass = UI.get("NumColors", "MISS_NUM") end

		if (UI.get("PanelSettings", "EnableCustomIcons") and getCustomIcon(fromWS(e.ability)) ~= nil) then
			params.icon = getCustomIcon(fromWS(e.ability))
		end

		pushToStack(params, stack) 
	end
end

function pushToStack(params, stack)
	if (not TEMPLATE[stack]) then return end
	if ((params.name == "" or params.name == nil) and not UI.get("PanelSettings", "ShowUnnamed")) then return end

	counter = counter + 1
	local plate = mainForm:CreateWidgetByDesc(TEMPLATE[stack]:GetWidgetDesc())
	plate:SetName(stack.."_"..tostring(counter))
	plate:Show(true)

	plate:SetBackgroundColor({r = 0.0, g = 0.0, b = 0.0, a = 0.0})
	local tempPos = TEMPLATE[stack]:GetPlacementPlain()
	wtSetPlace(plate, tempPos)
	wtSetPlace(plate, {sizeY=tonumber(UI.get("PanelSettings", "IconSize"))+tonumber(UI.get("PanelSettings", "IconPadding"))*2, sizeX=300})
	table.insert(STACK[stack], plate)
	updatePlacement(stack)

	plate:PlayFadeEffect( 0.0, 1.0, 500 )

	local background
	if (UI.get("PanelBackground", "ShowBg")) then
		background = CreateWG("PlateBg", "BG", plate, true, { alignX=0, sizeX=tempPos.sizeX, posX = 0, highPosX = 0, alignY = 0, sizeY=tempPos.sizeY, posY=0, highPosY=0})
		background:SetBackgroundColor(UI.getGroupColor("PanelBackground"))
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
		if (floatP and floatP ~= "0") then floatP = "%."..floatP
		else floatP = nil end

		if (UI.get("Formatting", "ShortenToMill") and _amount >= 1000000) then
			if (floatP) then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000000, floatP..'f')).."M"
			else
				_formatedAmount = fromWS(common.FormatInt(math.round(_amount / 1000000), '%d')).."M"
			end
		elseif (_amount >= 1000) then
			if (floatP) then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000, floatP..'f')).."K"
			else
				_formatedAmount = fromWS(common.FormatInt(math.round(_amount / 1000), '%d')).."K"
			end
		end
	end

	local maxTextSize = 1000
	local fontSize = (tonumber(UI.get("PanelSettings", "IconSize"))/2 + 4)

	if (stack == 'inc') then
		wtSetPlace(plate:GetChildChecked("IconSpell", true), {sizeY=tonumber(UI.get("PanelSettings", "IconSize")), sizeX=tonumber(UI.get("PanelSettings", "IconSize")), posX=tonumber(UI.get("PanelSettings", "IconPadding")), highPosX=0})

		local incLabel = CreateWG("Label", "CastName", plate, true, { alignX=0, sizeX=maxTextSize, posX = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "TextPadding"))*2, highPosX = 0, alignY = 2, sizeY=tonumber(UI.get("PanelSettings", "IconSize")), posY=0, highPosY=0})
		incLabel:SetFormat (userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='"..tostring(fontSize).."' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>" ))
		incLabel:SetVal("name", _name)
		incLabel:SetClassVal("class", params.nameClass or "ColorWhite")
		incLabel:SetVal("dmg", _formatedAmount)
		incLabel:SetClassVal("dmg", params.amountClass or "ColorRed")
		incLabel:SetVal("sep", " - ")
		incLabel:SetClassVal("sep", "ColorWhite")
	else
		wtSetPlace(plate:GetChildChecked("IconSpell", true), {sizeY=tonumber(UI.get("PanelSettings", "IconSize")), sizeX=tonumber(UI.get("PanelSettings", "IconSize")), posX=0, highPosX=tonumber(UI.get("PanelSettings", "IconPadding"))})

		local outLabel = CreateWG("Label", "CastName", plate, true, { alignX=1, sizeX=maxTextSize, posX = 0, highPosX = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "TextPadding"))*2, alignY = 2, sizeY=tonumber(UI.get("PanelSettings", "IconSize")), posY=0, highPosY=0})
		outLabel:SetFormat (userMods.ToWString("<html><body alignx='right' aligny='middle' fontsize='"..tostring(fontSize).."' outline='1' shadow='1'><rs class='class'><r name='name'/></rs><rs class='sep'><r name='sep'/></rs><rs class='dmg'><r name='dmg'/></rs></body></html>" ))
		
		outLabel:SetVal("name", _name)
		outLabel:SetClassVal("class", params.nameClass or "ColorWhite")
		outLabel:SetVal("dmg", _formatedAmount)
		outLabel:SetClassVal("dmg", params.amountClass or "ColorRed")
		outLabel:SetVal("sep", " - ")
		outLabel:SetClassVal("sep", "ColorWhite")
	end

	if (background) then
		local w = (#(_formatedAmount) + 3 + #_name) * (fontSize * 0.61)
		if (stack == "out") then
			wtSetPlace(background, { 
			sizeX=(tonumber(UI.get("PanelSettings", "IconPadding")) + tonumber(UI.get("PanelSettings", "TextPadding")) + tonumber(UI.get("PanelSettings", "IconSize")) + w ),
			alignX=1, highPosX = 0, posX = 0})
		else
			wtSetPlace(background, { 
				sizeX=(tonumber(UI.get("PanelSettings", "IconPadding")) + tonumber(UI.get("PanelSettings", "TextPadding")) + tonumber(UI.get("PanelSettings", "IconSize")) + w ),
				alignX=0, highPosX = 0, posX = 0})
		end
	end

	plate:SetTransparentInput( true )
	plate:SetClipContent( false )
	plate:PlayResizeEffect(plate:GetPlacementPlain(), plate:GetPlacementPlain(), tonumber(UI.get("PanelSettings", "ShowTime")), EA_MONOTONOUS_INCREASE)
end

function onSlash(p)
	local m = userMods.FromWString(p.text)
	local split_string = {}
	for w in m:gmatch("%S+") do table.insert(split_string, w) end

	if (split_string[1]:lower() == "/ddtest" and split_string[2]) then
		pushToStack({}, split_string[2])
	elseif(split_string[1]:lower() == "/ddsettings") then
		UI.print()
	end
end

function ToggleDnd()
	local dndEnabled = not (out_template:IsVisibleEx() and inc_template:IsVisibleEx())

	DnD.Enable(out_template, dndEnabled)
	out_template:Show(dndEnabled)
	out_template:SetTransparentInput( not dndEnabled )

	DnD.Enable(inc_template, dndEnabled)
	inc_template:Show(dndEnabled)
	inc_template:SetTransparentInput( not dndEnabled )

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
	UI.init("ShowCustomDD")

	common.RegisterEventHandler(onUnitDamage, 'EVENT_UNIT_DAMAGE_RECEIVED')
	common.RegisterEventHandler(onUnitHeal, 'EVENT_HEALING_RECEIVED')

	common.RegisterEventHandler(onPlayEffectFinished, 'EVENT_EFFECT_FINISHED')
	common.RegisterEventHandler(onSlash, 'EVENT_UNKNOWN_SLASH_COMMAND')
	common.RegisterReactionHandler(onCfgLeft, "ConfigLeftClick")
	common.RegisterReactionHandler(onCfgRight, "ConfigRightClick")

	local cfgBtn = mainForm:GetChildChecked( "ConfigButton", false )
	DnD.Init(cfgBtn,cfgBtn, true)
	DnD.Enable(cfgBtn, true)

	setUpTemplates()
	setupUI()

	if (stateMainForm:GetChildChecked( "ContextDamageVisualization", false )) then
		stateMainForm:GetChildChecked( "ContextDamageVisualization", false ):Show(false)
	end
end

function setUpTemplates()
	local maxTextSize = 1000

	wtSetPlace(inc_template, {sizeY=tonumber(UI.get("PanelSettings", "IconSize"))+tonumber(UI.get("PanelSettings", "IconPadding"))*2, sizeX=300})
	wtSetPlace(inc_template:GetChildChecked("IconSpell", true), {sizeY=tonumber(UI.get("PanelSettings", "IconSize")), sizeX=tonumber(UI.get("PanelSettings", "IconSize")), posX=tonumber(UI.get("PanelSettings", "IconPadding")), highPosX=0})

	local incLabel = CreateWG("Label", "CastName", inc_template, true, { alignX=0, sizeX=maxTextSize, posX = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "TextPadding"))*2, highPosX = 0, alignY = 2, sizeY=tonumber(UI.get("PanelSettings", "IconSize")), posY=0, highPosY=0})
	incLabel:SetFormat (userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='"..tostring(tonumber(UI.get("PanelSettings", "IconSize"))/2 + 4).."' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>" ))
	incLabel:SetVal("name", "Anafema")
	incLabel:SetClassVal("class", "DamageYellow")

	incLabel:SetVal("dmg", "5411K")
	incLabel:SetClassVal("dmg", "ColorRed")

	incLabel:SetVal("sep", " - ")
	incLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(inc_template,inc_template:GetChildChecked("IconSpell", true), true)
	inc_template:SetTransparentInput( true )
	inc_template:Show(false)


	wtSetPlace(out_template, {sizeY=tonumber(UI.get("PanelSettings", "IconSize"))+tonumber(UI.get("PanelSettings", "IconPadding"))*2, sizeX=300})
	wtSetPlace(out_template:GetChildChecked("IconSpell", true), {sizeY=tonumber(UI.get("PanelSettings", "IconSize")), sizeX=tonumber(UI.get("PanelSettings", "IconSize")), highPosX=tonumber(UI.get("PanelSettings", "IconPadding")), posX=0})

	local outLabel = CreateWG("Label", "CastName", out_template, true, { alignX=1, sizeX=maxTextSize, posX = 0, highPosX = tonumber(UI.get("PanelSettings", "IconSize")) + tonumber(UI.get("PanelSettings", "TextPadding"))*2, alignY = 2, sizeY=tonumber(UI.get("PanelSettings", "IconSize")), posY=0, highPosY=0})
	outLabel:SetFormat (userMods.ToWString("<html><body alignx='right' aligny='middle' fontsize='"..tostring(tonumber(UI.get("PanelSettings", "IconSize"))/2 + 4).."' outline='1' shadow='1'><rs class='class'><r name='name'/></rs><rs class='sep'><r name='sep'/></rs><rs class='dmg'><r name='dmg'/></rs></body></html>" ))
	
	outLabel:SetVal("name", "Anafema")
	outLabel:SetClassVal("class", "DamageYellow")

	outLabel:SetVal("dmg", "5411K")
	outLabel:SetClassVal("dmg", "ColorRed")

	outLabel:SetVal("sep", " - ")
	outLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(out_template, out_template:GetChildChecked("IconSpell", true), true)
	out_template:SetTransparentInput( true )
	out_template:Show(false)
end

function setupUI()
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
		UI.createList("DMG_NUM", classListAll(), 2, true),
		UI.createList("CRIT_DMG_NUM", classListAll(), 3, true),
		UI.createList("HEAL_NUM", classListAll(), 4, true),
		UI.createList("CRIT_HEAL_NUM", classListAll(), 5, true),
		UI.createList("MISS_NUM", classListAll(), 6, true),
		UI.createList("LETHAL_NUM", classListAll(true), 0, true),
	})

	UI.addGroup("LabelColors", {
		UI.createList("DMG_NAME", classListAll(), 1, true),
		UI.createList("CRIT_DMG_NAME", classListAll(), 1, true),
		UI.createList("HEAL_NAME", classListAll(), 1, true),
		UI.createList("CRIT_HEAL_NAME", classListAll(), 1, true),
		UI.createList("MISS_NAME", classListAll(), 1, true),
		UI.createList("LETHAL_NAME", classListAll(true), 15, true),
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
		UI.createSlider("r", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("g", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("b", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("a", {
			stepsCount = 100,
			width = 212,
		}, 0),
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

function switchButtonState(widget, settings)
	local prevState = settings.state
	local newState = prevState

	if (prevState == #(settings.states)) then
		newState = 1
	else
		newState = newState + 1
	end

	settings.state = newState
	settings.value = settings.states[newState]
	widget:SetVal("label", toWS(settings.value))

	UI.save()
	UI.print()
end

function addShowCB(widget, settings, editline)
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

function addIgnoreCB(widget, settings, editline)
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

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end