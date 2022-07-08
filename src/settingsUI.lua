Global( "UI", {} )
Global( "UI_SETTINGS", {} )

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

function printSettings()
    for k,v in pairs(UI_SETTINGS) do
        PushToChatSimple("|___ "..(k).." = "..tostring(v.value))
    end 
end

function onListBtn(params)
    -- for k,v in pairs(params) do 
    --     PushToChatSimple(tostring(k).." = "..tostring(v))
    -- end

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
        end

        printSettings()
    end
end

function onCB(params)
    if params.active then
        if (params.sender and UI_SETTINGS[params.sender]) then
            UI_SETTINGS[params.sender].value = not UI_SETTINGS[params.sender].value 
            params.widget:SetVariant( chVariant(UI_SETTINGS[params.sender].value) )
        end
        printSettings()
    end
end

function onInputFocus(params)
    for k,v in pairs(params) do 
        PushToChatSimple(tostring(k).." = "..tostring(v))
    end
end

function onSliderChange(params)
    -- for k,v in pairs(params) do 
        -- PushToChatSimple(tostring(k).." = "..tostring(v))
    -- end

    local descPanel = params.widget:GetParent():GetParent()
    local label = descPanel:GetChildChecked("SliderPanelBarText", true)
    local value = params.widget:GetPos()

    label:SetVal("text", tostring(value))
end

function UI.init()
    common.RegisterReactionHandler(onCB, "checkbox_pressed")
    common.RegisterReactionHandler(onListBtn, "list_leftbutton_pressed")
    common.RegisterReactionHandler(onListBtn, "list_rightbutton_pressed")
    common.RegisterReactionHandler(onInputFocus, "RenameFocusChanged")
    common.RegisterReactionHandler(onSliderChange, "slider_changed")

end

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

    if (default == nil) then default = 1 end

    temp.params.value = options[default]
    temp.params.defaultValue = options[default]
    temp.params.index = default

    return temp
end

function UI.createSlider(name, label, options, default)
    local temp = { name = name, label = label, type = "List", params = {
        options = options,
    }}

    -- if (default == nil) then default = 1 end

    -- temp.params.value = options[default]
    -- temp.params.defaultValue = options[default]
    -- temp.params.index = default

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
                    
                    UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue }
                    checkboxBtn:SetVariant( chVariant(v.params.value) )
                elseif (v.type == "List") then
                    local listPanel = CreateWG("ListPanel", "ListPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (i-1)*45, highPosX = 0, alignY = 0 })
                    background:AddChild(listPanel)
                    listPanel:GetChildChecked("ListPanelText", false):SetVal("list_text", v.label)
                    listPanel:GetChildChecked("ListPanelDescText", true):SetVal("list_desctext", tostring(v.params.value))

                    local lBtn = listPanel:GetChildChecked("ListPanelButtonLeft", true)
                    local rBtn = listPanel:GetChildChecked("ListPanelButtonRight", true)

                    lBtn:Enable(v.params.index > 1)
                    lBtn:SetName(id)
                    rBtn:Enable(v.params.index < #(v.params.options))
                    rBtn:SetName(id)

                    UI_SETTINGS[id] = { value = v.params.value, defaultValue = v.params.defaultValue, index = v.params.index, options = v.params.options, widgets = {
                        lBtn = lBtn, rBtn = rBtn, value = listPanel:GetChildChecked("ListPanelDescText", true)
                    }}
                end
            end
        end
    end

    local inputPanel = CreateWG("InputPanel", "InputPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (3-1)*45, highPosX = 0, alignY = 0 })
    background:AddChild(inputPanel)
    inputPanel:GetChildChecked("InputPanelText", false):SetVal("list_text", "test")

    local sliderPanel = CreateWG("SliderPanel", "SliderPanel", background, true, { alignX=2, posX=1, sizeX=maxW, posY=minPosY + (4-1)*45, highPosX = 0, alignY = 0 })
    background:AddChild(sliderPanel)
    sliderPanel:GetChildChecked("SliderPanelText", false):SetVal("slider_text", "test")

    printSettings()

    scrollCont:PushBack( background )
end