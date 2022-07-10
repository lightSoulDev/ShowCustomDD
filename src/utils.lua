function toWS( arg )
	return userMods.ToWString(arg)
end

function fromWS( arg )
	return userMods.FromWString(arg)
end

function pushToChat(message,size,color)
	local fsize = size or 18
	local textFormat = string.format('<header color="0x%s" fontsize="%s" outline="1" shadow="1"><rs class="class">%s</rs></header>',color, tostring(fsize),message)
	local VT = common.CreateValuedText()
	VT:SetFormat(toWS(textFormat))
	local chatContainer = stateMainForm:GetChildUnchecked("ChatLog", false):GetChildUnchecked("Area", false):GetChildUnchecked("Panel02",false):GetChildUnchecked("Container", false)
	chatContainer:PushFrontValuedText(VT)
end

function pushToChatSimple(message)
	local textFormat = string.format("<html fontsize='16'><rs class='class'>%s</rs></html>",message)
	local VT = common.CreateValuedText()
	VT:SetFormat(toWS(textFormat))
	VT:SetClassVal("class", "LogColorWhite")
	local chatContainer = stateMainForm:GetChildUnchecked("ChatLog", false):GetChildUnchecked("Area", false):GetChildUnchecked("Panel02",false):GetChildUnchecked("Container", false)
	chatContainer:PushFrontValuedText(VT)
end

function wtSetPlace(w, place )
	local p = w:GetPlacementPlain()
	for k, v in pairs(place) do	
		p[k] = place[k] or v
	end
	w:SetPlacementPlain(p)
end

function CreateWG(desc, name, parent, show, place)
	local n = mainForm:CreateWidgetByDesc( mainForm:GetChildChecked( desc, true ):GetWidgetDesc() )
	if name then n:SetName( name ) end
	if parent then parent:AddChild(n) end
	if place then wtSetPlace( n, place ) end
	n:Show( show == true )
	return n
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

function len(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function chVariant(value)
    if (value) then return 1 end
    return 0
end