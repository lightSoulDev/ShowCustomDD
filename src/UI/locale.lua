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
        ["SETTING_IconPadding"] = "Отступ вокруг иконки",
        ["SETTING_TextPadding"] = "Отступ текста от иконки",
        ["SETTING_ShowTime"] = "Время жизни панели (мс)",
        ["SETTING_ReplacePlaceholder"] = "Показывать икноку авто-атаки вместо вопросика",
        ["SETTING_ShowUnnamed"] = "Показывать безымянный урон/лечение",
        ["SETTING_EnableCustomIcons"] = "Включить кастомные иконки (CustomIcons)",
        ["SETTING_HideLabels"] = "Скрыть текст (оставить только иконку и цифры)",


        ["GROUP_Formatting"] = "Форматирование",
        ["SETTING_ShortNum"] = "Сокращать цифры урона",
        ["SETTING_ShortenToMill"] = "Сокращать до миллиона",
        ["SETTING_FloatFormat"] = "Количество символов после запятой",
        ["SETTING_ReplaceByName"] = "Отображать имя юнита вместо названия",
        ["SETTING_IgnoreBloodlust"] = "Игнор кровожадности и прочего нерунического хила",
        ["SETTING_HideOutMisses"] = "Скрывать исходящие промахи",
        ["SETTING_HideIncMisses"] = "Скрывать входящие промахи",

        ["GROUP_NumColors"] = "Цвета значений",
        ["SETTING_DMG_NUM"] = "Обычный урон",
        ["SETTING_CRIT_DMG_NUM"] = "Критический урон",
        ["SETTING_HEAL_NUM"] = "Обычный хил",
        ["SETTING_CRIT_HEAL_NUM"] = "Критический. урон",
        ["SETTING_MISS_NUM"] = "Уклонение",
        ["SETTING_LETHAL_NUM"] = "Летальный урон",

        ["GROUP_LabelColors"] = "Цвета подписей",
        ["SETTING_DMG_NAME"] = "Обычный урон",
        ["SETTING_CRIT_DMG_NAME"] = "Критический урон",
        ["SETTING_HEAL_NAME"] = "Обычный хил",
        ["SETTING_CRIT_HEAL_NAME"] = "Критический. урон",
        ["SETTING_MISS_NAME"] = "Уклонение",
        ["SETTING_LETHAL_NAME"] = "Летальный урон",

        ["GROUP_DamageFilteringP"] = "Фильтрация [Игроки]",
        ["SETTING_MinOutPlayerDmg"] = "Минимальное отображение исходящего урона",
        ["SETTING_MinOutPlayerHeal"] = "Минимальное отображение исходящего лечения",
        ["SETTING_MinIncPlayerDmg"] = "Минимальное отображение входящего урона",
        ["SETTING_MinIncPlayerHeal"] = "Минимальное отображение входящего лечения",

        ["GROUP_DamageFilteringU"] = "Фильтрация [Мобы]",
        ["SETTING_MinOutUnitDmg"] = "Минимальное отображение исходящего урона",
        ["SETTING_MinOutUnitHeal"] = "Минимальное отображение исходящего лечения",
        ["SETTING_MinIncUnitDmg"] = "Минимальное отображение входящего урона",
        ["SETTING_MinIncUnitHeal"] = "Минимальное отображение входящего лечения",

        ["GROUP_PanelBackground"] = "Подложка",
        ["SETTING_ShowBg"] = "Отображение подложки",
        ["SETTING_r"] = "Красный канал",
        ["SETTING_g"] = "Зеленый канал",
        ["SETTING_b"] = "Синий канал",
        ["SETTING_a"] = "Альфа канал",

        ["GROUP_IgnoredNames"] = "Показать всё кроме",
        ["SETTING_EnableIgnore"] = "Включить фильтр",
        ["SETTING_AddIgnore"] = "Новый фильтр по имени",

        ["GROUP_ShowOnlyNames"] = "Скрыть всё кроме",
        ["SETTING_ShowOnly"] = "Включить фильтр (перекрывает все фильтры)",
        ["SETTING_ShowOnlyInc"] = "Не скрывать входящий урон/лечение",
        ["SETTING_AddShow"] = "Новый фильтр по имени",

        ["CB_outP"] = "Исх. И",
        ["CB_incP"] = "Вход. И",
        ["CB_outU"] = "Исх. М",
        ["CB_incU"] = "Вход. М",
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
        ["CB_incU"] = "Inc. М",
    }
}

LOCALES["eng"] = LOCALES["eng_eu"]