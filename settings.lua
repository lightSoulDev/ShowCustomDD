Global("Settings", {
    -- Размер иконки
        size = 28,
    -- Отступы вокруг иконки
        padding = 0,
    -- Отступ текста от иконки
        paddingText = 1,
    -- Время жизни панели (мс)
        showTime = 8000,
    -- Максимальное количество панелей
        maxBars = 7,
    -- отображение подложки
        showBg = false,
    -- Сокращать цифры урона
        shortNum = true,
    -- Показывать имя юнита вместо названия
        replaceByUnitName = false,
    -- Игнор кровожадки
        ignoreBloodlust = true,
    -- Цвет задней подложки
        bgColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.5},
    -- Игнор по имени спелла
        ignoredNames = {
            -- ['Возмездие'] = {
            --     enabled = true,
            --     filters = {
            --         ['incP'] = true,
            --         ['outP'] = true,
            --         ['incU'] = true,
            --         ['outU'] = true,
            --     }
            -- }
        },
    -- Показывает только указанные ниже скиллы
        showOnlySelected = false,
        showOnlyList = {
            ['incP'] = {
                -- ['Казнь'] = true,
            },
            ['outP'] = {
                -- ['Казнь'] = true,
            },
            ['incU'] = {
                -- ['Казнь'] = true,
            },
            ['outU'] = {
                -- ['Казнь'] = true,
            },
        },
    -- Цветовые форматы
        colorClasses = {
            ['DMG_NUM'] = "DamageYellow",
            ['CRIT_DMG_NUM'] = "DamageRed",
            ['LETHAL_NUM'] = nil,
            ['HEAL_NUM'] = "ColorWarmGreen",
            ['CRIT_HEAL_NUM'] = "DamageGreen",
            ['DODGE_NUM'] = "Junk",
            ['MISS_NUM'] = "Junk",
            ['GLANCING_NUM'] = nil,
            ['GLANCING_HEAL_NUM'] = nil,


            ['DMG_NAME'] = "ColorWhite",
            ['CRIT_DMG_NAME'] = "ColorWhite",
            ['LETHAL_NAME'] = "CombatOrange",
            ['HEAL_NAME'] = "ColorWhite",
            ['CRIT_HEAL_NAME'] = "ColorWhite",
            ['DODGE_NAME'] = "ColorWhite",
            ['MISS_NAME'] = "ColorWhite",
            ['GLANCING_NAME'] = "ColorWhite",
            ['GLANCING_HEAL_NAME'] = "ColorWhite",
        },
    -- Количество символов после запятой
        floatFormat = 1,
    -- Сокращать до миллиона
        shortenToMill = true,
    -- Скрывать исходящие промахи
        hideOutMisses = false,
    -- Скрывать входящие промахи
        hideIncMisses = false,
    
    -- Минимальное отображение исходящего урона (по игрокам)
        minOutPlayerDmg = 10000,
    -- Минимальное отображение исходящего урона (по мобам)
        minOutUnitDmg = 10000,
    -- Минимальное отображение исходящего лечения (по игрокам)
        minOutPlayerHeal = 1000,
    -- Минимальное отображение исходящего лечения (по мобам)
        minOutUnitHeal = 10000,

    -- Минимальное отображение входящего урона (от игроков)
        minIncPlayerDmg = 1000,
    -- Минимальное отображение входящего урона (от мобов)
        minIncUnitDmg = 1000,
    -- Минимальное отображение входящего лечения (от игроков)
        minIncPlayerHeal = 1000,
    -- Минимальное отображение входящего лечения (от мобов)
        minIncUnitHeal = 1000,
})