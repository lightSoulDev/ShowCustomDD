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

		tempPos.posY = tempPos.posY + (Settings.size + Settings.padding*2)*(#STACK[stack] - i)
		wtSetPlace(v, tempPos)
		v:Show((#STACK[stack] + 1 - i) <= (Settings.maxBars or 6))
	end
end

function getTexture(name)
	local group = common.GetAddonRelatedTextureGroup( "RELATED_TEXTURES" )

	if group then
		return group:GetTexture(name)
	end
end

function onUnitHeal(e)
	-- pushToChatSimple("onUnitHeal: "..fromWS(e.ability).." - ("..fromWS(object.GetName(e.target))..") from ("..fromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.healerId,
		target = e.unitId,
		amount = e.heal,
		amountClass = Settings.colorClasses["HEAL_NUM"] or "DamageGreen",
		nameClass = Settings.colorClasses["HEAL_NAME"] or "ColorWhite",
		icon = nil,
		name = ""
	}

	if (Settings.ignoreBloodlust and e.runeResisted == 0 and object.IsInCombat(avatar.GetId())) then return end

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		-- Нас похилил игрок
		if (unit.IsPlayer(params.source)) then 
			category = "incP"
			if (Settings.minIncPlayerHeal and params.amount < Settings.minIncPlayerHeal) then return end
		else -- Нас похилил моб
			category = "incU"
			if (Settings.minIncUnitHeal and params.amount < Settings.minIncUnitHeal) then return end
		end
		stack = "inc"
	elseif (params.source == avatar.GetId()) then

		-- Похилили по игроку
		if (unit.IsPlayer(params.target)) then 
			category = "outP"
			if (Settings.minOutPlayerHeal and params.amount < Settings.minOutPlayerHeal) then return end
		else -- Похилили по юниту
			category = "outU"
			if (Settings.minOutUnitHeal and params.amount < Settings.minOutUnitHeal) then return end
		end

		-- Похилили по игроку
		if (Settings.minOutPlayerHeal and params.amount < Settings.minOutPlayerHeal and unit.IsPlayer(params.target)) then return end
		-- Похилили по игроку
		if (Settings.minOutUnitHeal and params.amount < Settings.minOutUnitHeal and not unit.IsPlayer(params.target)) then return end
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

		-- if (params.name == lastDMG and Settings.ignoreBloodlust) then return end

		if (params.target == avatar.GetId()) then
			if (Settings.replaceByUnitName and fromWS(object.GetName(params.source)) ~= "") then params.name = fromWS(object.GetName(params.source)) end
		elseif (params.source == avatar.GetId()) then
			if (Settings.replaceByUnitName and fromWS(object.GetName(params.target)) ~= "") then params.name = fromWS(object.GetName(params.target)) end
		end

		if (Settings.showOnlySelected and Settings.showOnlyList) then
			if (Settings.showOnlyList[category] and len(Settings.showOnlyList[category]) > 0 and not Settings.showOnlyList[category][params.name]) then return end
		elseif (Settings.ignoredNames and Settings.ignoredNames[params.name] and Settings.ignoredNames[params.name].enabled) then
			local filters = Settings.ignoredNames[params.name].filters
			if (filters and filters[category]) then return end
		end

		if (e.isCritical and Settings.colorClasses["CRIT_HEAL_NAME"]) then params.nameClass = Settings.colorClasses["CRIT_HEAL_NAME"] end
		if (e.isCritical and Settings.colorClasses["CRIT_HEAL_NUM"]) then params.amountClass = Settings.colorClasses["CRIT_HEAL_NUM"] end

		if (e.isGlancing and Settings.colorClasses["GLANCING_HEAL_NAME"]) then params.nameClass = Settings.colorClasses["GLANCING_HEAL_NAME"] end
		if (e.isGlancing and Settings.colorClasses["GLANCING_HEAL_NUM"]) then params.amountClass = Settings.colorClasses["GLANCING_HEAL_NUM"] end

		pushToStack(params, stack) 
	end
end

function onUnitDamage(e)
	-- pushToChatSimple("onUnitDamage: "..fromWS(e.ability).." - ("..fromWS(object.GetName(e.target))..") from ("..fromWS(object.GetName(e.source))..") = "..(tostring(e.amount)) )

	local params = {
		source = e.source,
		target = e.target,
		amount = e.amount,
		amountClass = Settings.colorClasses["DMG_NUM"] or "DamageYellow",
		nameClass = Settings.colorClasses["DMG_NAME"] or "ColorWhite",
		icon = nil,
		name = fromWS(e.ability)
	}

	local stack
	local category = "any"

	if (params.target == avatar.GetId()) then
		if (Settings.replaceByUnitName and fromWS(object.GetName(params.source)) ~= "") then params.name = fromWS(object.GetName(params.source)) end
		if (Settings.hideIncMisses and (e.isMiss or e.isDodge)) then return end

		-- Нас ударил игрок
		if (unit.IsPlayer(params.source)) then
			category = "incP"
			if (Settings.minIncPlayerDmg and params.amount < Settings.minIncPlayerDmg) then return end
		else -- Нас ударил моб
			category = "incU"
			if (Settings.minIncUnitDmg and params.amount < Settings.minIncUnitDmg) then return end
		end

		stack = "inc"
	elseif (params.source == avatar.GetId() or (unit.IsPet(params.source) and avatar.GetId() == unit.GetPetOwner(params.source))) then
		if (Settings.replaceByUnitName and fromWS(object.GetName(params.target)) ~= "") then params.name = fromWS(object.GetName(params.target)) end
		if (Settings.hideOutMisses and (e.isMiss or e.isDodge)) then return end

		-- Ударили по игроку
		if (unit.IsPlayer(params.target)) then 
			category = "outP"
			if (Settings.minOutPlayerDmg and params.amount < Settings.minOutPlayerDmg) then return end
		else -- Ударили по игроку
			category = "outU"
			if (Settings.minOutUnitDmg and params.amount < Settings.minOutUnitDmg) then return end
		end

		stack = "out"
	else
		return
	end

	if (Settings.showOnlySelected and Settings.showOnlyList) then
		if (Settings.showOnlyList[category] and len(Settings.showOnlyList[category]) > 0 and not Settings.showOnlyList[category][params.name]) then return end
	elseif (Settings.ignoredNames and Settings.ignoredNames[params.name] and Settings.ignoredNames[params.name].enabled) then
		local filters = Settings.ignoredNames[params.name].filters
		if (filters and filters[category]) then return end
	end

	if (stack) then
		if (e.spellId) then
			params.icon = spellLib.GetIcon(e.spellId)
		elseif (e.buffId) then
			local info = object.GetBuffInfo( e.buffId ) or avatar.GetBuffInfo(e.buffId)

			if (info) then
				if (info.texture) then
					params.icon = info.texture
				elseif (info.producer and info.producer.spellId) then
					params.icon = spellLib.GetIcon(info.producer.spellId)
				end
			end
		elseif (e.abilityId) then
			local info = avatar.GetAbilityInfo( e.abilityId )
			if (info and info.texture) then params.icon = texture end
		elseif (e.mapModifierId) then
			local info = cartographer.GetMapModifierInfo( e.mapModifierId )
			if (info and info.image) then params.icon = info.image end
		end

		if (e.isFall) then
			params.icon = getTexture("FALL")
			params.name = "Падение"
		end
		if (e.isExploit) then pushToChatSimple("DamageFromExploit") end

		-- pushToChatSimple(e.damageSource)

		if (e.damageSource) then
			if (e.damageSource == "DamageSource_BARRIER") then
				params.name = "Из барьера"
				if (params.icon == nil) then
					params.icon = getTexture("BARRIER")
				end
			end
		end

		if (e.lethal and Settings.colorClasses["LETHAL_NAME"]) then params.nameClass = Settings.colorClasses["LETHAL_NAME"] end
		if (e.lethal and Settings.colorClasses["LETHAL_NUM"]) then params.amountClass = Settings.colorClasses["LETHAL_NUM"] end

		if (e.isCritical and Settings.colorClasses["CRIT_DMG_NAME"]) then params.nameClass = Settings.colorClasses["CRIT_DMG_NAME"] end
		if (e.isCritical and Settings.colorClasses["CRIT_DMG_NUM"]) then params.amountClass = Settings.colorClasses["CRIT_DMG_NUM"] end

		if (e.isDodge and Settings.colorClasses["DODGE_NAME"]) then params.nameClass = Settings.colorClasses["DODGE_NAME"] end
		if (e.isDodge and Settings.colorClasses["DODGE_NUM"]) then params.amountClass = Settings.colorClasses["DODGE_NUM"] end

		if (e.isMiss and Settings.colorClasses["MISS_NAME"]) then params.nameClass = Settings.colorClasses["MISS_NAME"] end
		if (e.isMiss and Settings.colorClasses["MISS_NUM"]) then params.amountClass = Settings.colorClasses["MISS_NUM"] end

		if (e.isGlancing and Settings.colorClasses["GLANCING_NAME"]) then params.nameClass = Settings.colorClasses["GLANCING_NAME"] end
		if (e.isGlancing and Settings.colorClasses["GLANCING_NUM"]) then params.amountClass = Settings.colorClasses["GLANCING_NUM"] end

		pushToStack(params, stack) 
	end
end

function pushToStack(params, stack)
	if (not TEMPLATE[stack]) then return end

	counter = counter + 1
	local plate = mainForm:CreateWidgetByDesc(TEMPLATE[stack]:GetWidgetDesc())
	plate:SetName(stack.."_"..tostring(counter))
	plate:Show(true)

	plate:SetBackgroundColor({r = 0.0, g = 0.0, b = 0.0, a = 0.0})
	local tempPos = TEMPLATE[stack]:GetPlacementPlain()
	wtSetPlace(plate, tempPos)
	wtSetPlace(plate, {sizeY=Settings.size+Settings.padding*2, sizeX=300})
	table.insert(STACK[stack], plate)
	updatePlacement(stack)

	plate:PlayFadeEffect( 0.0, 1.0, 500 )

	local background
	if (Settings.showBg) then
		background = CreateWG("PlateBg", "BG", plate, true, { alignX=0, sizeX=tempPos.sizeX, posX = 0, highPosX = 0, alignY = 0, sizeY=tempPos.sizeY, posY=0, highPosY=0})
		background:SetBackgroundColor(Settings.bgColor or {r = 0.0, g = 0.0, b = 0.0, a = 0.5})
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

	if (Settings.shortNum) then
		if (Settings.shortenToMill and _amount >= 1000000) then
			if (Settings.floatFormat == "auto") then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000000, '%f3K5')).."M"
			elseif (Settings.floatFormat) then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000000, '%.'..tostring(Settings.floatFormat)..'f')).."M"
			end
		elseif (_amount >= 1000) then
			if (Settings.floatFormat == "auto") then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000, '%f3K5')).."K"
			elseif (Settings.floatFormat) then
				_formatedAmount = fromWS(common.FormatFloat(_amount / 1000, '%.'..tostring(Settings.floatFormat)..'f')).."K"
			end
		end
	end

	local maxTextSize = 1000
	local fontSize = (Settings.size/2 + 4)

	if (stack == 'inc') then
		wtSetPlace(plate:GetChildChecked("IconSpell", true), {sizeY=Settings.size, sizeX=Settings.size, posX=Settings.padding, highPosX=0})

		local incLabel = CreateWG("Label", "CastName", plate, true, { alignX=0, sizeX=maxTextSize, posX = Settings.size + Settings.paddingText*2, highPosX = 0, alignY = 2, sizeY=Settings.size, posY=0, highPosY=0})
		incLabel:SetFormat (userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='"..tostring(fontSize).."' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>" ))
		incLabel:SetVal("name", _name)
		incLabel:SetClassVal("class", params.nameClass or "ColorWhite")
		incLabel:SetVal("dmg", _formatedAmount)
		incLabel:SetClassVal("dmg", params.amountClass or "ColorRed")
		incLabel:SetVal("sep", " - ")
		incLabel:SetClassVal("sep", "ColorWhite")
	else
		wtSetPlace(plate:GetChildChecked("IconSpell", true), {sizeY=Settings.size, sizeX=Settings.size, posX=0, highPosX=Settings.padding})

		local outLabel = CreateWG("Label", "CastName", plate, true, { alignX=1, sizeX=maxTextSize, posX = 0, highPosX = Settings.size + Settings.paddingText*2, alignY = 2, sizeY=Settings.size, posY=0, highPosY=0})
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
		wtSetPlace(background, { sizeX=(Settings.padding + Settings.paddingText + Settings.size + w ), alignX=1})
	end

	plate:SetTransparentInput( true )
	plate:SetClipContent( false )
	plate:PlayResizeEffect(plate:GetPlacementPlain(), plate:GetPlacementPlain(), Settings.showTime, EA_MONOTONOUS_INCREASE)
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
	UI.init("ShowDD")
	common.RegisterEventHandler(onUnitDamage, 'EVENT_UNIT_DAMAGE_RECEIVED')
	common.RegisterEventHandler(onUnitHeal, 'EVENT_HEALING_RECEIVED')

	common.RegisterEventHandler(onPlayEffectFinished, 'EVENT_EFFECT_FINISHED')
	common.RegisterEventHandler(onSlash, 'EVENT_UNKNOWN_SLASH_COMMAND')
	common.RegisterReactionHandler(onCfgLeft, "ConfigLeftClick")
	common.RegisterReactionHandler(onCfgRight, "ConfigRightClick")

	local cfgBtn = mainForm:GetChildChecked( "ConfigButton", false )
	DnD.Init(cfgBtn,cfgBtn, true)
	DnD.Enable(cfgBtn, true)

	if (not Settings.size) then Settings.size = 28 end
	if (not Settings.padding) then Settings.padding = 1 end
	if (not Settings.paddingText) then Settings.paddingText = 5 end
	if (not Settings.colorClasses) then Settings.colorClasses = {} end
	if (not Settings.floatFormat) then Settings.floatFormat = 1 end

	setUpTemplates()

	if (stateMainForm:GetChildChecked( "ContextDamageVisualization", false )) then
		stateMainForm:GetChildChecked( "ContextDamageVisualization", false ):Show(false)
	end
end

function setUpTemplates()
	local maxTextSize = 1000

	wtSetPlace(inc_template, {sizeY=Settings.size+Settings.padding*2, sizeX=300})
	wtSetPlace(inc_template:GetChildChecked("IconSpell", true), {sizeY=Settings.size, sizeX=Settings.size, posX=Settings.padding, highPosX=0})

	local incLabel = CreateWG("Label", "CastName", inc_template, true, { alignX=0, sizeX=maxTextSize, posX = Settings.size + Settings.paddingText*2, highPosX = 0, alignY = 2, sizeY=Settings.size, posY=0, highPosY=0})
	incLabel:SetFormat (userMods.ToWString("<html><body alignx='left' aligny='middle' fontsize='"..tostring(Settings.size/2 + 4).."' outline='1' shadow='1'><rs class='dmg'><r name='dmg'/></rs><rs class='sep'><r name='sep'/></rs><rs class='class'><r name='name'/></rs></body></html>" ))
	incLabel:SetVal("name", "Anafema")
	incLabel:SetClassVal("class", "DamageYellow")

	incLabel:SetVal("dmg", "5411K")
	incLabel:SetClassVal("dmg", "ColorRed")

	incLabel:SetVal("sep", " - ")
	incLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(inc_template,inc_template:GetChildChecked("IconSpell", true), true)
	inc_template:SetTransparentInput( true )
	inc_template:Show(false)


	wtSetPlace(out_template, {sizeY=Settings.size+Settings.padding*2, sizeX=300})
	wtSetPlace(out_template:GetChildChecked("IconSpell", true), {sizeY=Settings.size, sizeX=Settings.size, highPosX=Settings.padding, posX=0})

	local outLabel = CreateWG("Label", "CastName", out_template, true, { alignX=1, sizeX=maxTextSize, posX = 0, highPosX = Settings.size + Settings.paddingText*2, alignY = 2, sizeY=Settings.size, posY=0, highPosY=0})
	outLabel:SetFormat (userMods.ToWString("<html><body alignx='right' aligny='middle' fontsize='"..tostring(Settings.size/2 + 4).."' outline='1' shadow='1'><rs class='class'><r name='name'/></rs><rs class='sep'><r name='sep'/></rs><rs class='dmg'><r name='dmg'/></rs></body></html>" ))
	
	outLabel:SetVal("name", "Anafema")
	outLabel:SetClassVal("class", "DamageYellow")

	outLabel:SetVal("dmg", "5411K")
	outLabel:SetClassVal("dmg", "ColorRed")

	outLabel:SetVal("sep", " - ")
	outLabel:SetClassVal("sep", "ColorWhite")

	DnD.Init(out_template, out_template:GetChildChecked("IconSpell", true), true)
	out_template:SetTransparentInput( true )
	out_template:Show(false)

	UI_SETTINGS = {}

	UI.addGroup("PanelSettings", "Настройки панелей", {
		UI.createInput("MaxBars", "Максимально количество панелей" , {
			maxChars = 3,
			filter = "_INT"
		}, '7'),
		UI.createList("IconSize", "Размер иконки", range(16, 128, 4), 4, false),
		UI.createList("IconPadding", "Отступ вокруг иконки", range(0, 6, 1), 1, false),
		UI.createList("TextPadding", "Отступ текста от иконки", range(0, 10, 1), 2, false),
		UI.createInput("ShowTime", "Время жизни панели (мс)" , {
			maxChars = 6,
			filter = "_INT"
		}, '8000'),
	})

	UI.addGroup("Formatting", "Форматирование", {
		UI.createCheckBox("ShortNum", "Сокращать цифры урона", true),
		UI.createCheckBox("ShortenToMill", "Сокращать до миллиона", true),
		UI.createList("FloatFormat", "Количество символов после запятой", range(0, 5, 1), 2, false),

		UI.createCheckBox("ReplaceByName", "Отображать имя юнита вместо названия", false),
		UI.createCheckBox("IgnoreBloodlust", "Игнор кровожадности и прочего нерунического хила (в бою)", true),
		UI.createCheckBox("HideOutMisses", "Скрывать исходящие промахи", true),
		UI.createCheckBox("HideIncMisses", "Скрывать входящие промахи", true),
	})

	UI.addGroup("NumColors", "Цвета значений", {
		UI.createList("DMG_NUM", "Обычный урон", classListAll(), 2, true),
		UI.createList("CRIT_DMG_NUM", "Критический урон", classListAll(), 3, true),
		UI.createList("HEAL_NUM", "Обычный хил", classListAll(), 4, true),
		UI.createList("CRIT_HEAL_NUM", "Критический. урон", classListAll(), 5, true),
		UI.createList("MISS_NUM", "Уклонение", classListAll(), 6, true),
		UI.createList("LETHAL_NUM", "Летальный урон", classListAll(true), 0, true),
	})

	UI.addGroup("LabelColors", "Цвета подписей", {
		UI.createList("DMG_NAME", "Обыч. урон", classListAll(), 1, true),
		UI.createList("CRIT_DMG_NAME", "Крит. урон", classListAll(), 1, true),
		UI.createList("HEAL_NAME", "Обыч. хил", classListAll(), 1, true),
		UI.createList("CRIT_HEAL_NAME", "Крит. урон", classListAll(), 1, true),
		UI.createList("MISS_NAME", "Уклонение", classListAll(), 1, true),
		UI.createList("LETHAL_NAME", "Летальный урон", classListAll(true), 15, true),
	})

	UI.addGroup("DamageFilteringP", "Фильтрация [Игроки]", {
		UI.createInput("MinOutPlayerDmg", "Минимальное отображение исходящего урона" , {
			maxChars = 10,
			filter = "_INT"
		}, '10000'),
		UI.createInput("MinOutPlayerHeal", "Минимальное отображение исходящего лечения" , {
			maxChars = 10,
			filter = "_INT"
		}, '10000'),
		UI.createInput("MinIncPlayerDmg", "Минимальное отображение входящего урона" , {
			maxChars = 10,
			filter = "_INT"
		}, '1000'),
		UI.createInput("MinIncPlayerHeal", "Минимальное отображение входящего лечения" , {
			maxChars = 10,
			filter = "_INT"
		}, '1000'),
	})

	UI.addGroup("DamageFilteringU", "Фильтрация [Мобы]", {
		UI.createInput("MinOutUnitDmg", "Минимальное отображение исходящего урона" , {
			maxChars = 10,
			filter = "_INT"
		}, '10000'),
		UI.createInput("MinOutUnitHeal", "Минимальное отображение исходящего лечения" , {
			maxChars = 10,
			filter = "_INT"
		}, '10000'),
		UI.createInput("MinIncUnitDmg", "Минимальное отображение входящего урона" , {
			maxChars = 10,
			filter = "_INT"
		}, '1000'),
		UI.createInput("MinIncUnitHeal", "Минимальное отображение входящего лечения" , {
			maxChars = 10,
			filter = "_INT"
		}, '1000'),
	})

	UI.addGroup("PanelBackground", "Подложка", {
		UI.createCheckBox("ShowBg", "Отображение подложки", false),
		UI.createSlider("r", "Красный канал", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("g", "Зеленый канал", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("b", "Синий канал", {
			stepsCount = 255,
			width = 212,
		}, 0),
		UI.createSlider("a", "Альфа канал", {
			stepsCount = 255,
			width = 212,
		}, 0),
	})

	UI.addGroup("IgnoredNames", "Игнор по имени", {
		UI.createCheckBox("EnableIgnore", "Включить фильтр по имени", false),
		UI.createButtonInput("AddIgnore", "Новый фильтр по имени", {
			width = 90,
			states = {
				'Добавить',
			},
			callback = addIgnoreCB
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
				left = { "Restore" },
				right = { "Accept" }
			},
			groups = {
				"IgnoredNames"
			}
		}
	}, "Common")

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

function addIgnoreCB(widget, settings, editline)
	editline:SetFocus(false)
	local text = editline:GetString()
	pushToChatSimple(text)

	UI.groupPush("IgnoredNames", {
		UI.createItemSetting(text, text, {
			iconName = text,
			checkboxes = {
				{
					name = "outP",
					label = "Исх. И",
					default = false
				},
				{
					name = "incP",
					label = "Вход. И",
					default = false
				},
				{
					name = "outU",
					label = "Исх. М",
					default = false
				},
				{
					name = "incU",
					label = "Вход. М",
					default = false
				},
			}
		}, true),
	})
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end