Global("LOCALES", {})

-- ger
-- fra
-- tr

function getLocaleText(name)
    local lang = LANG or "rus"

	local l = LOCALES[lang]

	if l then
		return l[name] or name
    else
        return name
	end
end

LOCALES = {
    ["rus"] = {
        ["DMG_FALL"] = "Падение",
        ["DMG_BARRIER"] = "Из барьера",

        ["ButtonAccept"] = "Принять",
        ["ButtonRestore"] = "Сбросить",
        ["ButtonAdd"] = "Добавить",
        ["ButtonDelete"] = "Удалить",

        ["TAB_Common"] = "Основные",
        ["TAB_Visual"] = "Цвета",
        ["TAB_Ignored"] = "Игнор.",
        ["TAB_ShowOnly"] = "Показ.",

        ["GROUP_PanelSettings"] = "Настройки панелей",
        ["SETTING_MaxBars"] = "Максимально количество панелей",
        ["SETTING_IconSize"] = "Размер иконки",
        ["SETTING_ShowTime"] = "Время жизни панели (мс)",

        ["GROUP_Formatting"] = "Форматирование",
        ["SETTING_IgnoreBloodlust"] = "Игнор кровожадности и прочего нерунического хила",
    },
    ["eng_eu"] = {
        ["DMG_FALL"] = "Fall",
        ["DMG_BARRIER"] = "From barrier",
        ["ButtonAccept"] = "Accept",
        ["ButtonRestore"] = "Restore",
        ["ButtonAdd"] = "Add",
        ["ButtonDelete"] = "Delete",

        ["TAB_Common"] = "Common",
        ["TAB_Visual"] = "Colors",
        ["TAB_Ignored"] = "Ignore",

        ["GROUP_PanelSettings"] = "Panel settings",
        ["SETTING_MaxBars"] = "Max panel count",
        ["SETTING_IconSize"] = "Icon size",
        ["SETTING_ShowTime"] = "Time to live (ms)",

        ["GROUP_Formatting"] = "Formating",
        ["SETTING_IgnoreBloodlust"] = "Ignore bloodthirst and other non-runic heals",
    }
}

LOCALES["eng"] = LOCALES["eng_eu"]