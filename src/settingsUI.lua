Global( "UI", {} )
Global( "UI_SETTINGS", {} )
Global( "SETTING_GROUPS", {} )
Global( "SETTING_GROUPS_KEYS_ORDER", {} )
Global( "PANEL_WIDGETS", {} )
Global( "TABS", {} )

local ITEM_SETTING_CB_POS = {
    {
        alignX = 0, posX = 371, highPosX = 0,
        alignY = 0, posY = 4, highPosY = 0,
    },
    {
        alignX = 0, posX = 471, highPosX = 0,
        alignY = 0, posY = 4, highPosY = 0,
    },
    {
        alignX = 0, posX = 371, highPosX = 0,
        alignY = 1, posY = 0, highPosY = 6,
    },
    {
        alignX = 0, posX = 471, highPosX = 0,
        alignY = 1, posY = 0, highPosY = 6,
    },
}

local ACTIVE_BUTTONS = {}
local CURRENT_TAB = nil
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

            if (params.name == "list_leftbutton_pressed") then
                index = index - 1
                if (not settings.cycle and index < 1) then return end
                if (index < 1) then index = #(settings.options) end
            else
                index = index + 1
                if (not settings.cycle and index > #(settings.options)) then return end

                if (index > #(settings.options)) then index = 1 end
            end

            settings.widgets.value:SetVal("text", tostring(settings.options[index]))
            settings.widgets.lBtn:Enable(settings.cycle or index > 1)
            settings.widgets.rBtn:Enable(settings.cycle or index < #(settings.options))

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
        local split_string = {}
        for w in k:gmatch('([^_]+)') do table.insert(split_string, w) end

        if (TABS and not tabContainsGroup(TABS, CURRENT_TAB, split_string[1])) then goto continue end

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
        ::continue::
    end

    UI.render()
end

function onTabSwitch(params)
    if (not params.sender) then return end
    local split_string = {}
    for w in params.sender:gmatch('([^_]+)') do table.insert(split_string, w) end

    if (split_string[2]) then
        for i, t in pairs(TABS) do
            if (t.widget) then
                t.widget:SetVariant(0)
            end
        end

        CURRENT_TAB = split_string[2]
        params.widget:SetVariant(1)
        UI.render()
    end
end

function onItemSettingEnable(params)
    local id = params.widget:GetParent():GetName()

    if (id and UI_SETTINGS[id]) then
        UI_SETTINGS[id].value = not UI_SETTINGS[id].value
        params.widget:SetVariant(chVariant(UI_SETTINGS[id].value))
        saveSettings()
    end
end

function onItemSettingCB(params)
    local id = params.widget:GetParent():GetName()

    if (id and UI_SETTINGS[id] and UI_SETTINGS[id].cb[params.sender] ~= nil) then
        UI_SETTINGS[id].cb[params.sender] = not UI_SETTINGS[id].cb[params.sender]
        params.widget:SetVariant(chVariant(UI_SETTINGS[id].cb[params.sender]))
        saveSettings()
    end
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
    common.RegisterReactionHandler(onTabSwitch, "tab_pressed")
    common.RegisterReactionHandler(onItemSettingEnable, "setting_itemsetting_enable")
    common.RegisterReactionHandler(onItemSettingCB, "setting_itemsetting_cb")

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

function UI.createList(name, label, options, default, cycle)
    local temp = { name = name, label = label, type = "List", params = {
        options = options,
    }}

    if (default == nil or default < 1) then default = 1 end
    if (default > #options) then default = #options end

    temp.params.value = options[default]
    temp.params.defaultIndex = default
    temp.params.index = default
    temp.params.cycle = cycle

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

-- name - string
-- label - string
-- options - {
--  iconName, checkboxes = { { name, label, default }} 
-- }
function UI.createItemSetting(name, label, options, enabled)

    local temp = { name = name, label = label, type = "ItemSetting", params = {
        options = {},
        iconName = options.iconName or "_Placeholder_",
        enabled = enabled
    }}

    for k, v in pairs(options.checkboxes) do
        local cb = {
            name = v.name,
            label = v.label,
            value = v.default
        }

        table.insert(temp.params.options, cb)
    end

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

function UI.setTabs(tabs, default)
    TABS = tabs
    CURRENT_TAB = default

    local settingsPanel = mainForm:GetChildChecked("SettingsMain", true)
    local tabTemplate = settingsPanel:GetChildChecked("TabTemplate", false)
    local i = 0
    for k, v in pairs(tabs) do
        local label = v.label
        local tab = CreateWG("TabTemplate", "Tab_"..label, settingsPanel, true,
        { posX = i * 120 + 35})

        tab:Show(true)
        tab:Enable(true)
        tab:SetVal("tab_label", toWS(label))
        tab:SetVariant(0)
        if (label == default) then tab:SetVariant(1) end
        i = i + 1

        TABS[k].widget = tab
    end

    i = nil
end

function UI.render()

    local scrollCont = mainForm:GetChildChecked("OptionsContainer", true)
    local minPosY = 16
    local maxW = 575

    for index, active_btn in pairs(ACTIVE_BUTTONS) do
        active_btn:Show(false)
    end

    local tabSettings = getTab(TABS, CURRENT_TAB)
    if (tabSettings.buttons) then
        if (tabSettings.buttons.left) then
            for i, v in pairs(tabSettings.buttons.left) do
                local button = SettingsMainFrame:GetChildChecked("Button"..(v), false)
                if (button) then
                    button:Show(true)
                    wtSetPlace(button, { alignX = 0, posX = (35 + (i-1) * 115)})
                    table.insert(ACTIVE_BUTTONS, button)
                end
            end
        end
        if (tabSettings.buttons.right) then
            for i, v in pairs(tabSettings.buttons.right) do
                local button = SettingsMainFrame:GetChildChecked("Button"..(v), false)
                if (button) then
                    button:Show(true)
                    wtSetPlace(button, { alignX = 1, highPosX = (45 + (i-1) * 115)})
                    table.insert(ACTIVE_BUTTONS, button)
                end
            end
        end
    end

    -- reset scroll content
    scrollCont:RemoveItems()

    for _index, _key in pairs(SETTING_GROUPS_KEYS_ORDER) do
        local group_name = _key
        local group = SETTING_GROUPS[_key]
        if (not group) then return end
        local TAB_SHOW = true
        if (TABS and not tabContainsGroup(TABS, CURRENT_TAB, group_name)) then TAB_SHOW = false end
        
        local settings = group.settings
        local grouplabel = group.label
        local frameH = ((#settings) * 45) + 30
        local extraPadding = 0

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
                    local panel = CreateWG("CheckboxPanel", "CheckboxPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
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
                -- =-           I T E M S E T T I N G S           -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "ItemSetting") then
                    local panel = CreateWG("ItemSettingPanel", "ItemSettingPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
                    local enable = panel:GetChildChecked("EnableCheckbox", false)
                    local label = panel:GetChildChecked("ItemSettingPanelText", false)
                    extraPadding = extraPadding + 22
                    wtSetPlace(groupFrame, { sizeY = frameH + extraPadding})
                    groupFrame:AddChild(panel)
                    panel:SetName(id)
                    label:SetVal("text", v.label)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.enabled, cb = {}}
                    end

                    for i = 1, 4, 1 do
                        local option = v.params.options[i]
                        local cb = panel:GetChildChecked("CB_"..tostring(i), false)
                        local label = panel:GetChildChecked("Text_"..tostring(i), false)

                        if (cb and option) then
                            label:SetVal("text", option.label)
                            cb:SetName(option.name)
                            cb:Show(true)

                            if (#(v.params.options) == 2) then
                                wtSetPlace(cb, { alignY = 2, posY = 2, highPosY = 0 })
                                wtSetPlace(label, { alignY = 2, posY = 2, highPosY = 0 })
                            elseif (#(v.params.options) == 1) then
                                local tmp = ITEM_SETTING_CB_POS[2]
                                wtSetPlace(cb, { alignY = 2, posY = 2, highPosY = 0, posX = tmp.posX })
                                wtSetPlace(label, { alignY = 2, posY = 2, highPosY = 0, posX = tmp.posX + 31 })
                            else
                                local tmp = ITEM_SETTING_CB_POS[i]
                                wtSetPlace(cb, tmp)
                                wtSetPlace(label, tmp)
                                wtSetPlace(label, { posX = tmp.posX + 31 })
                            end
                            
                            if (UI_SETTINGS[id].cb[option.name] == nil) then
                                UI_SETTINGS[id].cb[option.name] = option.value
                            end

                            cb:SetVariant(chVariant(UI_SETTINGS[id].cb[option.name]))
                        end
                    end

                    enable:SetVariant(chVariant(UI_SETTINGS[id].value))
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                 B U T T O N                 -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "Button") then
                    local panel = CreateWG("ButtonPanel", "ButtonPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
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
                    local panel = CreateWG("ListPanel", "ListPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
                    local label = panel:GetChildChecked("ListPanelText", false)
                    local valueLabel = panel:GetChildChecked("ListPanelDescText", true)
                    local lBtn = panel:GetChildChecked("ListPanelButtonLeft", true)
                    local rBtn = panel:GetChildChecked("ListPanelButtonRight", true)
                    groupFrame:AddChild(panel)

                    label:SetVal("list_text", v.label)
                    lBtn:SetName(id)
                    rBtn:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { type = v.type, value = v.params.value, defaultIndex = v.params.defaultIndex, index = v.params.index, options = v.params.options, cycle = v.params.cycle }
                    end

                    local tmp = tostring(UI_SETTINGS[id].value)
                    valueLabel:SetVal("text", tmp)

                    if (COLOR_CLASSES and COLOR_CLASSES[tmp]) then
                        valueLabel:SetClassVal("class", tmp)
                    else
                        valueLabel:SetClassVal("class", "tip_white")
                    end

                    lBtn:Enable(v.params.cycle or UI_SETTINGS[id].index > 1)
                    rBtn:Enable(v.params.cycle or UI_SETTINGS[id].index < #(UI_SETTINGS[id].options))

                    UI_SETTINGS[id].widgets = {
                        lBtn = lBtn, rBtn = rBtn, value = panel:GetChildChecked("ListPanelDescText", true)
                    }
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                -- =-                 S L I D E R                 -=
                -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                elseif (v.type == "Slider") then
                    local panel = CreateWG("SliderPanel", "SliderPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
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
                    local panel = CreateWG("InputPanel", "InputPanel", groupFrame, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45 + extraPadding, highPosX = 0, alignY = 0 })
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

        -- printSettings()
        if (TAB_SHOW) then scrollCont:PushBack( groupFrame )
        else groupFrame:Show(false) end
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