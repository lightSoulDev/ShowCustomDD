Global( "UI", {} )
Global( "UI_SETTINGS", {} )

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-                  U T I L S                  -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function toWS( arg )
	return userMods.ToWString(arg)
end

function fromWS( arg )
	return userMods.FromWString(arg)
end
function PushToChat(message,size,color)
	local fsize = size or 18
	local textFormat = string.format('<header color="0x%s" fontsize="%s" outline="1" shadow="1"><rs class="class">%s</rs></header>',color, tostring(fsize),message)
	local VT = common.CreateValuedText()
	VT:SetFormat(toWS(textFormat))
	local chatContainer = stateMainForm:GetChildUnchecked("ChatLog", false):GetChildUnchecked("Area", false):GetChildUnchecked("Panel02",false):GetChildUnchecked("Container", false)
	chatContainer:PushFrontValuedText(VT)
end

function PushToChatSimple(message)
	local textFormat = string.format("<html fontsize='16'><rs class='class'>%s</rs></html>",message)
	local VT = common.CreateValuedText()
	VT:SetFormat(toWS(textFormat))
	VT:SetClassVal("class", "LogColorWhite")
	local chatContainer = stateMainForm:GetChildUnchecked("ChatLog", false):GetChildUnchecked("Area", false):GetChildUnchecked("Panel02",false):GetChildUnchecked("Container", false)
	chatContainer:PushFrontValuedText(VT)
end

function chVariant(value)
    if (value) then return 1 end
    return 0
end

function len(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function extractFloatFromString(s)
    local parts = {}

    for w in s:gmatch("%d[%d.,]*") do table.insert(parts, w) end
    local result = ""
    for k, v in pairs(parts) do
        result = result..tostring(v)
    end

    return tonumber(result) or 0
end

function printSettings()
    for k,v in pairs(UI_SETTINGS) do
        PushToChatSimple("|___ "..(k).." = "..tostring(v.value))
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

            settings.widgets.value:SetVal("list_desctext", tostring(settings.options[index]))
            settings.widgets.lBtn:Enable(index > 1)
            settings.widgets.rBtn:Enable(index < #(settings.options))

            UI_SETTINGS[params.sender].value = settings.options[index]
            UI_SETTINGS[params.sender].index = index

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

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- =-                   I N I T                   -=
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function UI.init()
    common.RegisterReactionHandler(onCB, "checkbox_pressed")
    common.RegisterReactionHandler(onListBtn, "list_leftbutton_pressed")
    common.RegisterReactionHandler(onListBtn, "list_rightbutton_pressed")
    common.RegisterReactionHandler(onInputChange, "RenameBuildReaction")
    common.RegisterReactionHandler(onInputEsc, "RenameCancelReaction")
    common.RegisterReactionHandler(onSliderChange, "slider_changed")

    local config = userMods.GetGlobalConfigSection("UI_SETTINGS")
    if (config and len(config) > 0) then UI_SETTINGS = config end
end

function UI.save()
    saveSettings()
end

function UI.print()
    printSettings()
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
    temp.params.defaultValue = options[default]
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

function UI.addGroup(name, label, settings)
	local scrollCont = mainForm:GetChildChecked("SettingsMain", false):GetChildChecked("OptionsContainer", true)
    local minPosY = 16
    local maxW = 575
    local frameH = ((#settings + 2) * 45) + 30
    
    local background = CreateWG("BackFrame", "BG", mainForm, true, { alignX=3, posX = 0, highPosX = 0, alignY = 0, sizeY=frameH })
    background:Show(true)
    local header = background:GetChildChecked("GroupHeader", false):GetChildChecked("HeaderText", false)
    header:SetVal("name", label)

    if (settings) then
        for i = 1, #settings, 1 do
            local v = settings[i]
            if (v and v.type) then
                local id = name.."_"..v.name

                if (v.type == "Checkbox") then
                    local checkboxPanel = CreateWG("CheckboxPanel", "CheckboxPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    local checkboxBtn = checkboxPanel:GetChildChecked("Checkbox", false)
                    checkboxBtn:SetName(id)

                    checkboxPanel:GetChildChecked("CheckboxPanelText", false):SetVal("checkbox_text", v.label)
                    background:AddChild(checkboxPanel)
                    
                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue }
                    end
                    checkboxBtn:SetVariant(chVariant(UI_SETTINGS[id].value))

                elseif (v.type == "List") then
                    local listPanel = CreateWG("ListPanel", "ListPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    background:AddChild(listPanel)
                    listPanel:GetChildChecked("ListPanelText", false):SetVal("list_text", v.label)

                    local lBtn = listPanel:GetChildChecked("ListPanelButtonLeft", true)
                    local rBtn = listPanel:GetChildChecked("ListPanelButtonRight", true)
                    lBtn:SetName(id)
                    rBtn:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue, index = v.params.index, options = v.params.options }
                    end

                    listPanel:GetChildChecked("ListPanelDescText", true):SetVal("list_desctext", tostring(UI_SETTINGS[id].value))
                    lBtn:Enable(UI_SETTINGS[id].index > 1)
                    rBtn:Enable(UI_SETTINGS[id].index < #(UI_SETTINGS[id].options))

                    UI_SETTINGS[id].widgets = {
                        lBtn = lBtn, rBtn = rBtn, value = listPanel:GetChildChecked("ListPanelDescText", true)
                    }

                elseif (v.type == "Slider") then
                    local sliderPanel = CreateWG("SliderPanel", "SliderPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    background:AddChild(sliderPanel)
                    sliderPanel:GetChildChecked("SliderPanelText", false):SetVal("slider_text", v.label)

                    local discreteSlider = sliderPanel:GetChildChecked("DiscreteSlider", true)
                    local barPanel = sliderPanel:GetChildChecked("SliderPanelBar", true)
                    local valueLabel = barPanel:GetChildChecked("SliderPanelBarText", true)

                    wtSetPlace(barPanel, { sizeX = (v.params.options.width + 61) })
                    discreteSlider:SetStepsCount(v.params.options.stepsCount)
                    discreteSlider:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue }
                    end 

                    discreteSlider:SetPos(UI_SETTINGS[id].value)
                    valueLabel:SetVal("text", tostring(UI_SETTINGS[id].value))

                elseif (v.type == "Input") then
                    local inputPanel = CreateWG("InputPanel", "InputPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    background:AddChild(inputPanel)
                    inputPanel:GetChildChecked("InputPanelText", false):SetVal("text", v.label)

                    local inputBg = inputPanel:GetChildChecked("InputPanelBg", true)
                    wtSetPlace(inputBg, { sizeX = (v.params.options.width) })
                    local editLine = inputPanel:GetChildChecked("EditLine"..v.params.options.filter, true)
                    editLine:SetMaxSize( v.params.options.maxChars )
                    editLine:SetMaxSize( v.params.options.maxChars )
                    editLine:Show(true)
                    editLine:Enable(true)
                    editLine:SetName(id)

                    if (not UI_SETTINGS[id]) then
                        UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue, filter = v.params.options.filter}
                    end

                    editLine:SetText(toWS(UI_SETTINGS[id].value))
                end
            end
        end
    end

    printSettings()

    scrollCont:PushBack( background )
end