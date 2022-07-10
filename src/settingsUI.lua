Global( "UI", {} )
Global( "UI_SETTINGS", {} )
Global( "SETTING_GROUPS", {} )
Global( "SETTING_GROUPS_KEYS_ORDER", {} )
Global( "PANEL_WIDGETS", {} )

local SettingsMainFrame = mainForm:GetChildChecked("SettingsMain", false)

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-                  U T I L S                  -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function printSettings()
    for k,v in pairs(UI_SETTINGS) do
        pushToChatSimple("|___ "..(k).." = "..tostring(v.value))
    end 
end

function saveSettings()
    userMods.SetGlobalConfigSection("UI_SETTINGS", UI_SETTINGS)
end

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =- S E T T I N G S   C H A N G E   E V E N T S -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function onListBtn(params)
    if params.active then
        local settings = UI_SETTINGS[params.sender]
        if (params.sender and settings) then
            local index = settings.index

            if (params.name == "list_leftbutton_pressed" and index > 1) then
                index = index - 1
            elseif (index < #(settings.options)) then
                index = index + 1
            else
                return
            end

            settings.widgets.value:SetVal("text", tostring(settings.options[index]))
            settings.widgets.lBtn:Enable(index > 1)
            settings.widgets.rBtn:Enable(index < #(settings.options))

            local tmp = tostring(settings.options[index])
            UI_SETTINGS[params.sender].value = tmp
            UI_SETTINGS[params.sender].index = index

            if (COLOR_CLASSES and COLOR_CLASSES[tmp]) then
                settings.widgets.value:SetClassVal("class", tmp)
            else
                settings.widgets.value:SetClassVal("class", "tip_white")
            end

            saveSettings()
        end
    end
end

function onCB(params)
    if params.active then
        if (params.sender and UI_SETTINGS[params.sender]) then
            UI_SETTINGS[params.sender].value = not UI_SETTINGS[params.sender].value 
            params.widget:SetVariant(chVariant(UI_SETTINGS[params.sender].value))
            saveSettings()
        end
    end
end

function onInputChange(params)
    if (params.sender and UI_SETTINGS[params.sender]) then
        local tempVal = params.widget:GetString()

        if (UI_SETTINGS[params.sender].filter == "_NUM") then
            tempVal = tostring(extractFloatFromString(tempVal))
            params.widget:SetText(toWS(tempVal))
        end

        UI_SETTINGS[params.sender].value = tempVal
        params.widget:SetFocus(false)
        saveSettings()
    end
end

function onInputEsc(params)
    if (params.widget) then
        onInputChange(params)
        params.widget:SetFocus(false)
    end
end

function onSliderChange(params)
    if (params.sender and UI_SETTINGS[params.sender]) then
        local descPanel = params.widget:GetParent():GetParent()
        local label = descPanel:GetChildChecked("SliderPanelBarText", true)
        local value = params.widget:GetPos()
        label:SetVal("text", tostring(value))

        UI_SETTINGS[params.sender].value = value
        saveSettings()
    end
end

function onSettingButton(params)
    if (params.sender and UI_SETTINGS[params.sender]) then
        local cb = UI_SETTINGS[params.sender].callback
        if (cb and type(cb) == "function") then
            cb(params.widget, UI_SETTINGS[params.sender])
        end
    end
end

function onMainAccept()
    saveSettings()
    UI.toggle()
end

function onMainRestore()
    -- userMods.SetGlobalConfigSection("UI_SETTINGS", {})
    -- UI_SETTINGS = {}

    for k, v in pairs(UI_SETTINGS) do
        pushToChatSimple(k)
        if (v and v.type) then
            if (v.type == "Checkbox" or v.type == "Slider" or v.type == "Input") then
                UI_SETTINGS[k].value = v.defaultValue
            elseif (v.type == "List") then
                UI_SETTINGS[k].index = v.defaultIndex
                UI_SETTINGS[k].value = v.options[v.defaultIndex]
            elseif (v.type == "Button") then
                UI_SETTINGS[k].state = v.defaultState
                UI_SETTINGS[k].value = v.states[v.defaultState]
            end
        end
    end

    UI.render()
end

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-                   I N I T                   -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function UI.init(name)
    common.RegisterReactionHandler(onCB, "checkbox_pressed")
    common.RegisterReactionHandler(onListBtn, "list_leftbutton_pressed")
    common.RegisterReactionHandler(onListBtn, "list_rightbutton_pressed")
    common.RegisterReactionHandler(onInputChange, "RenameBuildReaction")
    common.RegisterReactionHandler(onInputEsc, "RenameCancelReaction")
    common.RegisterReactionHandler(onSliderChange, "slider_changed")
    common.RegisterReactionHandler(onSettingButton, "setting_button_pressed")
    common.RegisterReactionHandler(onMainAccept, "main_accept_pressed")
    common.RegisterReactionHandler(onMainRestore, "main_restore_pressed")

    local config = userMods.GetGlobalConfigSection("UI_SETTINGS")
    if (config and len(config) > 0) then UI_SETTINGS = config end

    local frameHeader = SettingsMainFrame:GetChildChecked("WindowHeader", true)
    if (not name) then name = "Settings" end
    frameHeader:GetChildChecked("HeaderText", true):SetVal("header", name)

    frameHeader:SetTransparentInput(false)
    DnD.Init(SettingsMainFrame, frameHeader)
    DnD.Enable(SettingsMainFrame, false)
end

function UI.save()
    saveSettings()
end

function UI.print()
    printSettings()
end

function UI.dnd(value)
    DnD.Enable(SettingsMainFrame, value)
end

function UI.toggle()
    local ui = mainForm:GetChildChecked("SettingsMain", false)
	ui:Show(not ui:IsVisibleEx())
	wtSetPlace(ui, {alignX=2, alignY=2})
end

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-          U I   G E N E R A T O R S          -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function UI.createCheckBox(name, label, default)
    local temp = { name = name, label = label, type = "Checkbox", params = {}}

    if (default == nil) then default = false end

    temp.params.value = default
    temp.params.defaultValue = default

    return temp
end

function UI.createList(name, label, options, default)
    local temp = { name = name, label = label, type = "List", params = {
        options = options,
    }}

    if (default == nil or default < 1) then default = 1 end
    if (default > #options) then default = #options end

    temp.params.value = options[default]
    temp.params.defaultIndex = default
    temp.params.index = default

    return temp
end

function UI.createSlider(name, label, options, default)
    local temp = { name = name, label = label, type = "Slider", params = {
        options = {
            stepsCount = options.stepsCount or 10,
            width = options.width or 212
        },
    }}

    if (default == nil) then default = 0 end
    if (default > options.stepsCount) then default = options.stepsCount end

    temp.params.value = default
    temp.params.defaultValue = default

    return temp
end

function UI.createInput(name, label, options, default)
    local temp = { name = name, label = label, type = "Input", params = {
        options = {
            isPassword = options.isPassword or false,
            maxChars = options.maxChars or nil,
            width = options.width or (options.maxChars and options.maxChars * 12 + 10) or 100,
            filter = options.filter or ""
        },
    }}

    if (default == nil) then default = "" end

    temp.params.value = default
    temp.params.defaultValue = default

    return temp
end

function UI.createButton(name, label, options, default)

    local temp = { name = name, label = label, btnLabel = btnLabel, type = "Button", params = {
        callback = options.callback,
        states = options.states,
        options = {
            width = options.width or 100,
        },
    }}

    if (default == nil or default < 1) then default = 1 end
    if (default > #(options.states)) then default = #(options.states) end

    temp.params.value = options.states[default]
    temp.params.defaultState = default
    temp.params.state = default

    return temp
end

function UI.addGroup(name, label, settings)
    SETTING_GROUPS[name] = {
        label = label,
        settings = settings
    }
    table.insert(SETTING_GROUPS_KEYS_ORDER, name)
end

function UI.removeGroup(name)
    SETTING_GROUPS[name] = nil
    table.remove(SETTING_GROUPS_KEYS_ORDER, name)
end

function UI.render()

    local scrollCont = mainForm:GetChildChecked("OptionsContainer", true)
    local minPosY = 16
    local maxW = 575

    -- reset scroll content
    scrollCont:RemoveItems()

    for _index, _key in pairs(SETTING_GROUPS_KEYS_ORDER) do
        local group_name = _key
        local group = SETTING_GROUPS[_key]
        if (not group) then return end

        local settings = group.settings
        local grouplabel = group.label
        local frameH = ((#settings) * 45) + 30

        local groupFrame = CreateWG("BackFrame", "BG", mainForm, true, { alignX=3, posX = 0, highPosX = 0, alignY = 0, sizeY=frameH })
        groupFrame:Show(true)

        local header = groupFrame:GetChildChecked("GroupHeader", false):GetChildChecked("HeaderText", false)
        header:SetVal("name", grouplabel)

        for i = 1, #settings, 1 do
            local v = settings[i]
            if (v and v.type) then
                local id = group_name.."_"..v.name
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-               C H E C K B O X               -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                if (v.type == "Checkbox") then
                    local panel = CreateWG("CheckboxPanel", "CheckboxPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local button = panel:GetChildChecked("Checkbox", false)
                    local label = panel:GetChildChecked("CheckboxPanelText", false)
                    groupFrame:AddChild(panel)

                    button:SetName(id)
                    label:SetVal("checkbox_text", v.label)
                    
                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.value, defaultValue = v.params.defaultValue }
                    end

                    button:SetVariant(chVariant(UI_SETTINGS[id].value))
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                 B U T T O N                 -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "Button") then
                    local panel = CreateWG("ButtonPanel", "ButtonPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local button = panel:GetChildChecked("Button", true)
                    local label = panel:GetChildChecked("ButtonPanelText", false)
                    groupFrame:AddChild(panel)

                    label:SetVal("text", v.label)
                    button:SetName(id)
                    wtSetPlace(button, { sizeX = v.params.options.width })

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = {
                            type = v.type, 
                            value = v.params.value,
                            defaultState = v.params.defaultState,
                            callback = v.params.callback,
                            states = v.params.states,
                            state = v.params.state
                        }
                    end

                    button:SetVal("label", toWS(UI_SETTINGS[id].value))
                    UI_SETTINGS[id].callback = v.params.callback
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                   L I S T                   -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "List") then
                    local panel = CreateWG("ListPanel", "ListPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local label = panel:GetChildChecked("ListPanelText", false)
                    local valueLabel = panel:GetChildChecked("ListPanelDescText", true)
                    local lBtn = panel:GetChildChecked("ListPanelButtonLeft", true)
                    local rBtn = panel:GetChildChecked("ListPanelButtonRight", true)
                    groupFrame:AddChild(panel)

                    label:SetVal("list_text", v.label)
                    lBtn:SetName(id)
                    rBtn:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.value, defaultIndex = v.params.defaultIndex, index = v.params.index, options = v.params.options }
                    end

                    local tmp = tostring(UI_SETTINGS[id].value)
                    valueLabel:SetVal("text", tmp)

                    if (COLOR_CLASSES and COLOR_CLASSES[tmp]) then
                        valueLabel:SetClassVal("class", tmp)
                    else
                        valueLabel:SetClassVal("class", "tip_white")
                    end

                    lBtn:Enable(UI_SETTINGS[id].index > 1)
                    rBtn:Enable(UI_SETTINGS[id].index < #(UI_SETTINGS[id].options))

                    UI_SETTINGS[id].widgets = {
                        lBtn = lBtn, rBtn = rBtn, value = panel:GetChildChecked("ListPanelDescText", true)
                    }
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                 S L I D E R                 -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "Slider") then
                    local panel = CreateWG("SliderPanel", "SliderPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local label = panel:GetChildChecked("SliderPanelText", false)
                    local discreteSlider = panel:GetChildChecked("DiscreteSlider", true)
                    local barPanel = panel:GetChildChecked("SliderPanelBar", true)
                    local valueLabel = barPanel:GetChildChecked("SliderPanelBarText", true)

                    groupFrame:AddChild(panel)

                    label:SetVal("slider_text", v.label)
                    wtSetPlace(barPanel, { sizeX = (v.params.options.width + 61) })
                    discreteSlider:SetStepsCount(v.params.options.stepsCount)
                    discreteSlider:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.value, defaultValue = v.params.defaultValue }
                    end 

                    discreteSlider:SetPos(UI_SETTINGS[id].value)
                    valueLabel:SetVal("text", tostring(UI_SETTINGS[id].value))
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                  I N P U T                  -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "Input") then
                    local panel = CreateWG("InputPanel", "InputPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local label = panel:GetChildChecked("InputPanelText", false):SetVal("text", v.label)
                    groupFrame:AddChild(panel)

                    local inputBg = panel:GetChildChecked("InputPanelBg", true)
                    wtSetPlace(inputBg, { sizeX = (v.params.options.width) })
                    local editLine = panel:GetChildChecked("EditLine"..v.params.options.filter, true)
                    editLine:SetMaxSize( v.params.options.maxChars )
                    editLine:SetMaxSize( v.params.options.maxChars )
                    editLine:Show(true)
                    editLine:Enable(true)
                    editLine:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.value, defaultValue = v.params.defaultValue, filter = v.params.options.filter}
                    end

                    editLine:SetText(toWS(UI_SETTINGS[id].value))
                end
            end
        end

        printSettings()
        scrollCont:PushBack( groupFrame )
    end
end

	-- UI.addGroup("ShowDD", "Отображение урона", {
	-- 	UI.createCheckBox("shorten", "Сокращать цифры урона", true),
	-- 	UI.createList("maxBars", "Количество панелей", {
	-- 		2, 3, 4, 5, 6, 7, 8, 9, 10
	-- 	}, 1),
	-- 	UI.createList("colors", "Цвета", {
	-- 		"ColorWhite", "ColorGreen", "ColorRed", "ColorBlue", "ColorOrange", "ColorYellow", "ColorBlack", "ColorMagenta", "ColorCian"
	-- 	}, 1),
	-- 	UI.createInput("testInput", "Пример инпута" , {
	-- 		maxChars = 10,
	-- 	}, 'test'),
	-- 	UI.createInput("testInput2", "Пример инпута NUM" , {
	-- 		maxChars = 10,
	-- 		filter = "_NUM"
	-- 	}, 'test'),
	-- 	UI.createInput("testInput3", "Пример инпута INT" , {
	-- 		maxChars = 10,
	-- 		filter = "_INT"
	-- 	}, '100'),
	-- 	UI.createSlider("redColor", "Пример слайдера", {
	-- 		stepsCount = 255,
	-- 		width = 212,
	-- 	}, 0),
	-- 	UI.createButton("testButton", "Пример кнопки", {
	-- 		width = 128,
	-- 		states = {
	-- 			'Стейт 1',
	-- 			'Стейт 2',
	-- 			'Стейт 3',
	-- 		},
	-- 		callback = switchButtonState
	-- 	}, 2)
	-- })