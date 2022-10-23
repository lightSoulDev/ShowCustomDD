Global( "UI", {} )
Global( "UI_SETTINGS", {} )
Global( "SETTING_GROUPS", {} )
Global( "SETTING_GROUPS_KEYS_ORDER", {} )
Global( "PANEL_WIDGETS", {} )
Global( "TABS", {} )
Global( "USER_SETTINGS", {} )

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

local ITEM_SETTING_CB_POS_6 = {
    {
        alignX = 0, posX = 271, highPosX = 0,
        alignY = 0, posY = 4, highPosY = 0,
    },
    {
        alignX = 0, posX = 371, highPosX = 0,
        alignY = 0, posY = 4, highPosY = 0,
    },
    {
        alignX = 0, posX = 471, highPosX = 0,
        alignY = 0, posY = 4, highPosY = 0,
    },
    {
        alignX = 0, posX = 271, highPosX = 0,
        alignY = 1, posY = 0, highPosY = 6,
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

            if (params.name == "setting_list_button_left") then
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
        saveSettings()
    end

    params.widget:SetFocus(false)
end

function onInputEsc(params)
    if (params.widget) then
        onInputChange(params)
        params.widget:SetFocus(false)
    end
end

function onInputFocus(params)
    if (not params.active) then
        onInputChange(params)
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
            if (v.type == "Checkbox" or v.type == "Input") then
                UI_SETTINGS[k].value = v.defaultValue
            elseif (v.type == "List") then
                UI_SETTINGS[k].index = v.defaultIndex
                UI_SETTINGS[k].value = v.options[v.defaultIndex]
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

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-                   I N I T                   -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function UI.init(name)
    common.RegisterReactionHandler(onCB, "setting_cb")
    common.RegisterReactionHandler(onListBtn, "setting_list_button_left")
    common.RegisterReactionHandler(onListBtn, "setting_list_button_right")
    common.RegisterReactionHandler(onInputChange, "setting_input_change")
    common.RegisterReactionHandler(onInputEsc, "setting_input_esc")
    common.RegisterReactionHandler(onMainAccept, "main_accept_pressed")
    common.RegisterReactionHandler(onMainRestore, "main_restore_pressed")
    common.RegisterReactionHandler(onTabSwitch, "tab_pressed")
    common.RegisterReactionHandler(onInputFocus, "setting_input_focus")

    local config = userMods.GetGlobalConfigSection("UI_SETTINGS")
    if (config and len(config) > 0) then UI_SETTINGS = config end

    if (not UI_SETTINGS.registeredTextures) then UI_SETTINGS.registeredTextures = {} end

    local frameHeader = SettingsMainFrame:GetChildChecked("WindowHeader", true)
    if (not name) then name = "Settings" end
    frameHeader:GetChildChecked("HeaderText", true):SetVal("header", name)

    frameHeader:SetTransparentInput(false)
    DnD.Init(SettingsMainFrame, frameHeader)
    DnD.Enable(SettingsMainFrame, false)
end

function UI.get(group, name)
    local id = group.."_"..name

    if (UI_SETTINGS[id]) then
        return UI_SETTINGS[id].value
    end

    return nil
end

function UI.getItem(group, item)
    local id = group.."_"..item

    if (UI_SETTINGS[id]) then
        local tmp =  {
            enabled = UI_SETTINGS[id].value
        }
        for k, v in pairs(UI_SETTINGS[id].cb) do
            tmp[k] = v
        end

        return tmp
    end

    return nil
end

function UI.getGroupColor(group)
    local r = group.."_r"
    local g = group.."_g"
    local b = group.."_b"
    local a = group.."_a"

    if (UI_SETTINGS[r] and UI_SETTINGS[g] and UI_SETTINGS[b] and UI_SETTINGS[a]) then
        return {
            r = tonumber(UI_SETTINGS[r].value) / 255.0,
            g = tonumber(UI_SETTINGS[g].value) / 255.0,
            b = tonumber(UI_SETTINGS[b].value) / 255.0,
            a = tonumber(UI_SETTINGS[a].value) / 100.0,
        }
    end

    return {r = 0.0, g = 0.0, b = 0.0, a = 0.0}
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function UI.registerTexture(key, obj)
    if UI_SETTINGS.registeredTextures[key] ~= nil then return end

    UI_SETTINGS.registeredTextures[key] = {
        obj = obj,
		spellId = obj.spellId,
		buffId = obj.buffId,
		abilityId = obj.abilityId,
		mapModifierId = obj.mapModifierId
    }

    saveSettings()
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
    local show = not ui:IsVisibleEx()
	ui:Show(show)
	wtSetPlace(ui, {alignX=2, alignY=2})
    if (show) then
        UI.render()
    end
end

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-          U I   G E N E R A T O R S          -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function UI.createCheckBox(name, default)
    local label = getLocaleText("SETTING_"..name)

    local temp = { name = name, label = label, type = "Checkbox", params = {}}

    if (default == nil) then default = false end

    temp.params.value = default
    temp.params.defaultValue = default

    return temp
end

function UI.createList(name, options, default, cycle)
    local label = getLocaleText("SETTING_"..name)

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

function UI.createInput(name, options, default)
    local label = getLocaleText("SETTING_"..name)
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

function UI.loadUserSettings()
    USER_SETTINGS = userMods.GetGlobalConfigSection("USER_SETTINGS") or {}
    for group_name, list in pairs(USER_SETTINGS) do
        if (#list > 0) then
            for i, setting in pairs(list) do
                UI.groupPush(group_name, setting, false)
            end
        end
    end
end

function UI.groupPush(name, setting, user)
    if (SETTING_GROUPS[name]) then
        if (user) then
            if (not USER_SETTINGS[name]) then USER_SETTINGS[name] = {} end
            table.insert(USER_SETTINGS[name], setting)
            userMods.SetGlobalConfigSection("USER_SETTINGS", USER_SETTINGS)
        end
        table.insert(SETTING_GROUPS[name].settings, setting)
    end
end

function UI.groupPop(name, settingName)
    if (SETTING_GROUPS[name]) then
        for k, v in pairs(SETTING_GROUPS[name].settings) do
            if (v and v.name == settingName) then
                table.remove(SETTING_GROUPS[name].settings, k)
            end
        end

        if (USER_SETTINGS[name]) then
            for k, v in pairs(USER_SETTINGS[name]) do
                if (v and v.name == settingName) then
                    table.remove(USER_SETTINGS[name], k)
                end
            end
            userMods.SetGlobalConfigSection("USER_SETTINGS", USER_SETTINGS)
        end
    end
end

function UI.addGroup(name, settings)
    local label = getLocaleText("GROUP_"..name)
    
    SETTING_GROUPS[name] = {
        label = label,
        settings = settings
    }
    table.insert(SETTING_GROUPS_KEYS_ORDER, name)
end

-- function UI.removeGroup(name)
--     SETTING_GROUPS[name] = nil
--     table.remove(SETTING_GROUPS_KEYS_ORDER, name)
-- end

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
        tab:SetVal("tab_label", toWS(getLocaleText("TAB_"..label)))
        tab:SetVariant(0)
        if (label == default) then tab:SetVariant(1) end
        i = i + 1

        TABS[k].widget = tab
    end

    i = nil
end

function getConfigIcon(e)
    local icon
    if (e.buffId) then
        local info = object.GetBuffInfo( e.buffId ) or avatar.GetBuffInfo(e.buffId)
        if (info) then
            if (info.texture) then
                icon = info.texture
            elseif (info.producer and info.producer.spellId) then
                icon = spellLib.GetIcon(info.producer.spellId)
            end
        end
    end
    if (not icon and e.spellId) then
        icon = spellLib.GetIcon(e.spellId)
    end
    if (not icon and e.abilityId) then
        local info = avatar.GetAbilityInfo( e.abilityId )
        if (info and info.texture) then icon = info.texture end
    end
    if (not icon and e.mapModifierId) then
        local info = cartographer.GetMapModifierInfo( e.mapModifierId )
        if (info and info.image) then icon = info.image end
    end

    return icon
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
                    button:SetVal("label", toWS(getLocaleText("Button"..(v))))

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
                    button:SetVal("label", toWS(getLocaleText("Button"..(v))))
                    
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