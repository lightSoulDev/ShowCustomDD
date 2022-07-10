Global("Settings", {
    -- ������ ������
        size = 28,
    -- ������� ������ ������
        padding = 0,
    -- ������ ������ �� ������
        paddingText = 1,
    -- ����� ����� ������ (��)
        showTime = 8000,
    -- ������������ ���������� �������
        maxBars = 7,
    -- ����������� ��������
        showBg = false,
    -- ��������� ����� �����
        shortNum = true,
    -- ���������� ��� ����� ������ ��������
        replaceByUnitName = false,
    -- ����� ����������
        ignoreBloodlust = true,
    -- ���� ������ ��������
        bgColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.5},
    -- ����� �� ����� ������
        ignoredNames = {
            -- ['���������'] = {
            --     enabled = true,
            --     filters = {
            --         ['incP'] = true,
            --         ['outP'] = true,
            --         ['incU'] = true,
            --         ['outU'] = true,
            --     }
            -- }
        },
    -- ���������� ������ ��������� ���� ������
        showOnlySelected = false,
        showOnlyList = {
            ['incP'] = {
                -- ['�����'] = true,
            },
            ['outP'] = {
                -- ['�����'] = true,
            },
            ['incU'] = {
                -- ['�����'] = true,
            },
            ['outU'] = {
                -- ['�����'] = true,
            },
        },
    -- �������� �������
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
    -- ���������� �������� ����� �������
        floatFormat = 1,
    -- ��������� �� ��������
        shortenToMill = true,
    -- �������� ��������� �������
        hideOutMisses = false,
    -- �������� �������� �������
        hideIncMisses = false,
    
    -- ����������� ����������� ���������� ����� (�� �������)
        minOutPlayerDmg = 10000,
    -- ����������� ����������� ���������� ����� (�� �����)
        minOutUnitDmg = 10000,
    -- ����������� ����������� ���������� ������� (�� �������)
        minOutPlayerHeal = 1000,
    -- ����������� ����������� ���������� ������� (�� �����)
        minOutUnitHeal = 10000,

    -- ����������� ����������� ��������� ����� (�� �������)
        minIncPlayerDmg = 1000,
    -- ����������� ����������� ��������� ����� (�� �����)
        minIncUnitDmg = 1000,
    -- ����������� ����������� ��������� ������� (�� �������)
        minIncPlayerHeal = 1000,
    -- ����������� ����������� ��������� ������� (�� �����)
        minIncUnitHeal = 1000,
})