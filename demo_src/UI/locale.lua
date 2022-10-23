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
        ["DMG_FALL"] = "�������",
        ["DMG_BARRIER"] = "�� �������",

        ["ButtonAccept"] = "�������",
        ["ButtonRestore"] = "��������",
        ["ButtonAdd"] = "��������",
        ["ButtonDelete"] = "�������",

        ["TAB_Common"] = "��������",
        ["TAB_Visual"] = "�����",
        ["TAB_Ignored"] = "�����.",
        ["TAB_ShowOnly"] = "�����.",

        ["GROUP_PanelSettings"] = "��������� �������",
        ["SETTING_MaxBars"] = "����������� ���������� �������",
        ["SETTING_IconSize"] = "������ ������",
        ["SETTING_ShowTime"] = "����� ����� ������ (��)",

        ["GROUP_Formatting"] = "��������������",
        ["SETTING_IgnoreBloodlust"] = "����� ������������� � ������� ������������� ����",
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