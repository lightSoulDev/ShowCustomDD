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
        ["SETTING_IconPadding"] = "������ ������ ������",
        ["SETTING_TextPadding"] = "������ ������ �� ������",
        ["SETTING_ShowTime"] = "����� ����� ������ (��)",
        ["SETTING_ReplacePlaceholder"] = "���������� ������ ����-����� ������ ���������",
        ["SETTING_ShowUnnamed"] = "���������� ���������� ����/�������",
        ["SETTING_EnableCustomIcons"] = "�������� ��������� ������ (CustomIcons)",
        ["SETTING_HideLabels"] = "������ ����� (�������� ������ ������ � �����)",


        ["GROUP_Formatting"] = "��������������",
        ["SETTING_ShortNum"] = "��������� ����� �����",
        ["SETTING_ShortenToMill"] = "��������� �� ��������",
        ["SETTING_FloatFormat"] = "���������� �������� ����� �������",
        ["SETTING_ReplaceByName"] = "���������� ��� ����� ������ ��������",
        ["SETTING_IgnoreBloodlust"] = "����� ������������� � ������� ������������� ����",
        ["SETTING_HideOutMisses"] = "�������� ��������� �������",
        ["SETTING_HideIncMisses"] = "�������� �������� �������",

        ["GROUP_NumColors"] = "����� ��������",
        ["SETTING_DMG_NUM"] = "������� ����",
        ["SETTING_CRIT_DMG_NUM"] = "����������� ����",
        ["SETTING_HEAL_NUM"] = "������� ���",
        ["SETTING_CRIT_HEAL_NUM"] = "�����������. ����",
        ["SETTING_MISS_NUM"] = "���������",
        ["SETTING_LETHAL_NUM"] = "��������� ����",

        ["GROUP_LabelColors"] = "����� ��������",
        ["SETTING_DMG_NAME"] = "������� ����",
        ["SETTING_CRIT_DMG_NAME"] = "����������� ����",
        ["SETTING_HEAL_NAME"] = "������� ���",
        ["SETTING_CRIT_HEAL_NAME"] = "�����������. ����",
        ["SETTING_MISS_NAME"] = "���������",
        ["SETTING_LETHAL_NAME"] = "��������� ����",

        ["GROUP_DamageFilteringP"] = "���������� [������]",
        ["SETTING_MinOutPlayerDmg"] = "����������� ����������� ���������� �����",
        ["SETTING_MinOutPlayerHeal"] = "����������� ����������� ���������� �������",
        ["SETTING_MinIncPlayerDmg"] = "����������� ����������� ��������� �����",
        ["SETTING_MinIncPlayerHeal"] = "����������� ����������� ��������� �������",

        ["GROUP_DamageFilteringU"] = "���������� [����]",
        ["SETTING_MinOutUnitDmg"] = "����������� ����������� ���������� �����",
        ["SETTING_MinOutUnitHeal"] = "����������� ����������� ���������� �������",
        ["SETTING_MinIncUnitDmg"] = "����������� ����������� ��������� �����",
        ["SETTING_MinIncUnitHeal"] = "����������� ����������� ��������� �������",

        ["GROUP_PanelBackground"] = "��������",
        ["SETTING_ShowBg"] = "����������� ��������",
        ["SETTING_r"] = "������� �����",
        ["SETTING_g"] = "������� �����",
        ["SETTING_b"] = "����� �����",
        ["SETTING_a"] = "����� �����",

        ["GROUP_IgnoredNames"] = "�������� �� �����",
        ["SETTING_EnableIgnore"] = "�������� ������",
        ["SETTING_AddIgnore"] = "����� ������ �� �����",

        ["GROUP_ShowOnlyNames"] = "������ �� �����",
        ["SETTING_ShowOnly"] = "�������� ������ (����������� ��� �������)",
        ["SETTING_ShowOnlyInc"] = "�� �������� �������� ����/�������",
        ["SETTING_AddShow"] = "����� ������ �� �����",

        ["CB_outP"] = "���. �",
        ["CB_incP"] = "����. �",
        ["CB_outU"] = "���. �",
        ["CB_incU"] = "����. �",
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
        ["SETTING_IconPadding"] = "Icon padding",
        ["SETTING_TextPadding"] = "Text padding",
        ["SETTING_ShowTime"] = "Time to live (ms)",
        ["SETTING_ReplacePlaceholder"] = "Show auto-attack icon instead of placeholder",
        ["SETTING_ShowUnnamed"] = "Show unnamed damage/heal",
        ["SETTING_EnableCustomIcons"] = "Enable custom icons (CustomIcons)",
        ["SETTING_HideLabels"] = "Hide label (Show only icon and dmg)",

        ["GROUP_Formatting"] = "Formating",
        ["SETTING_ShortNum"] = "Abbreviate damage numbers",
        ["SETTING_ShortenToMill"] = "Abbreviate to Mil",
        ["SETTING_FloatFormat"] = "Number of characters after the decimal point",
        ["SETTING_ReplaceByName"] = "Show unit name instead",
        ["SETTING_IgnoreBloodlust"] = "Ignore bloodthirst and other non-runic heals",
        ["SETTING_HideOutMisses"] = "Hide outgoing misses",
        ["SETTING_HideIncMisses"] = "Hide incoming misses",

        ["GROUP_NumColors"] = "Number colors",
        ["SETTING_DMG_NUM"] = "Common damage",
        ["SETTING_CRIT_DMG_NUM"] = "Crit. damage",
        ["SETTING_HEAL_NUM"] = "Common heal",
        ["SETTING_CRIT_HEAL_NUM"] = "Crit. heal",
        ["SETTING_MISS_NUM"] = "Miss",
        ["SETTING_LETHAL_NUM"] = "Lethal",

        ["GROUP_LabelColors"] = "Label colors",
        ["SETTING_DMG_NAME"] = "Common damage",
        ["SETTING_CRIT_DMG_NAME"] = "Crit. damage",
        ["SETTING_HEAL_NAME"] = "Common heal",
        ["SETTING_CRIT_HEAL_NAME"] = "Crit. heal",
        ["SETTING_MISS_NAME"] = "Miss",
        ["SETTING_LETHAL_NAME"] = "Lethal",

        ["GROUP_DamageFilteringP"] = "Filtration [Players]",
        ["SETTING_MinOutPlayerDmg"] = "Minimum outgoing damage",
        ["SETTING_MinOutPlayerHeal"] = "Minimum outgoing heal",
        ["SETTING_MinIncPlayerDmg"] = "Minimum incoming damage",
        ["SETTING_MinIncPlayerHeal"] = "Minimum incoming heal",

        ["GROUP_DamageFilteringU"] = "Filtration [Mobs]",
        ["SETTING_MinOutUnitDmg"] = "Minimum outgoing damage",
        ["SETTING_MinOutUnitHeal"] = "Minimum outgoing heal",
        ["SETTING_MinIncUnitDmg"] = "Minimum incoming damage",
        ["SETTING_MinIncUnitHeal"] = "Minimum incoming heal",

        ["GROUP_PanelBackground"] = "Backlayer",
        ["SETTING_ShowBg"] = "Show Backlayer",
        ["SETTING_r"] = "Red channel",
        ["SETTING_g"] = "Green channel",
        ["SETTING_b"] = "Blue channel",
        ["SETTING_a"] = "Alpha channel",

        ["GROUP_IgnoredNames"] = "Ignore by name",
        ["SETTING_EnableIgnore"] = "Enable all filters",
        ["SETTING_AddIgnore"] = "New filter",

        ["GROUP_ShowOnlyNames"] = "Hide all, except",
        ["SETTING_ShowOnly"] = "Enable filter (overlaps all filters)",
        ["SETTING_ShowOnlyInc"] = "Don't hide incoming damage/heal",
        ["SETTING_AddShow"] = "New filter",

        ["CB_outP"] = "Out. P",
        ["CB_incP"] = "Inc. P",
        ["CB_outU"] = "Out. M",
        ["CB_incU"] = "Inc. �",
    }
}

LOCALES["eng"] = LOCALES["eng_eu"]