local m_all_tree = GetAVLWStrTree()

Global( "Shelf", {} )

function Shelf.put(key, value)
    local obj = {
        key = key,
        value = value
    }

    if (not Shelf.has(key)) then
        m_all_tree:add(obj)
    end
end

function Shelf.save()
    local kv = {}
    for record in m_all_tree:iterate() do 
        kv[record.key] = {
            key = record.key,
            value = record.value
        }
    end

    userMods.SetGlobalConfigSection("SHELF", kv)
end

function Shelf.load()
    pushToChatSimple("Load")
    local kv = userMods.GetGlobalConfigSection("SHELF") or {}
    for k, v in pairs(kv) do
        pushToChatSimple(k.."  =  "..tostring(v.value))
    end
end

function Shelf.has(key)
    for record in m_all_tree:iterate() do 
        if (key == record.key) then return true end
    end
    return false
end

function Shelf.print()
    for record in m_all_tree:iterate() do 
        pushToChatSimple(record.key.."  =  "..(tostring(record.value)))
    end
end