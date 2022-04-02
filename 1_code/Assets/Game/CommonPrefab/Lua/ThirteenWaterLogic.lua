--[[
十三水
牌型计算
--]]

local basefunc = require "Game.Common.basefunc"

local M = {}

-- A＞K＞Q＞J＞10＞9＞8＞7＞6＞5＞4＞3＞2
-- 牌型的类型值与对应权值
M.PokerType = 
{
    Node    = {ptype=0, weight=0, on_off = true},
    
    ptHJTHS = {ptype=1, weight=80000, on_off = true},       --皇家同花顺：5张同花色的10、J、Q、K、A
    ptTHS   = {ptype=1, weight=50000, on_off = true},       --同花顺：5张同花色的顺子
    ptZD    = {ptype=2, weight=20000, on_off = true},       --炸弹：4张同点数的牌+1张任意牌
    ptHL    = {ptype=3, weight=10000, on_off = true},       --满屋：3张同点数的牌+2张同点数的牌
    ptTH    = {ptype=4, weight=5000, on_off = true},        --同花：5张同花色的牌
    ptSZ    = {ptype=5, weight=2500, on_off = true},        --顺子：5张点数依次递增的牌
    ptST    = {ptype=6, weight=1200, on_off = true},        --三条：3张同点数的牌+2张不同的牌
    ptCS    = {ptype=7, weight=1200, on_off = true},        --冲三(三条)：3张同点数的牌
    ptLD    = {ptype=8, weight=500, on_off = true},         --两对：2张同点数的牌+2张同点数的牌+1张牌
    ptYD    = {ptype=9, weight=200, on_off = true},         --对子：2张同点数的牌+3张不同的牌、2张同点数的牌+1张牌
    ptSP    = {ptype=10, weight=0, on_off = true},          --散牌：未达成以上任意牌型组合的5张牌或3张牌

    THSSS   = {ptype=101, weight=900000, on_off = true},    --同花十三水：13张同花色的牌，点数为从2到A
    SSS     = {ptype=102, weight=890000, on_off = true},    --十三水：13张不同花色的牌，点数从2到A
    SEHZ    = {ptype=103, weight=880000, on_off = false},       --十二皇族
    QHZ     = {ptype=1031, weight=880000, on_off = true},   --全皇家：13张由J、Q、K、A组成的牌
    STHS    = {ptype=104, weight=870000, on_off = true},    --三同花顺：前中后墩均能组成同花顺
    SFTX    = {ptype=105, weight=860000, on_off = true},    --三炸弹：13张牌包含3套炸弹+1张任意牌
    QD      = {ptype=106, weight=850000, on_off = true},    --全大牌：13张牌的点数均大于等于8
    QX      = {ptype=107, weight=840000, on_off = true},    --全小牌：13张牌的点数均小于等于8
    CYS     = {ptype=108, weight=830000, on_off = true},    --单色：13张牌颜色相同，即全是黑色（黑桃/梅花）或全是红色（红桃/方块）
    SGCS    = {ptype=109, weight=829000, on_off = false},       --双怪冲三
    SCJD    = {ptype=110, weight=828000, on_off = false},       --三冲加弹
    STST    = {ptype=111, weight=827000, on_off = true},    --四三条：13张牌包含4套三条+1张任意牌
    WDST    = {ptype=112, weight=826000, on_off = false},       --五对三条
    LDB     = {ptype=113, weight=820000, on_off = true},    --六对子：13张牌包含6套对子+1张任意牌
    STH     = {ptype=114, weight=810000, on_off = true},    --三同花：前中后墩均能组成同花
    SSZ     = {ptype=115, weight=800000, on_off = true},    --三顺子：前中后墩均能组成顺子
}

-- 传入13张牌，是不是特殊牌
-- 特殊牌型：同花十三水>十三水>十二皇族>三同花顺>三分天下>全大>全小>凑一色 >六对半>三同花>三顺子
function M.IsTS(cards)
    cards = M.SortPoker(cards)
    if M.IsTHSSS(cards) and M.PokerType.THSSS.on_off then
        return M.PokerType.THSSS
    end
    if M.IsSSS(cards) and M.PokerType.SSS.on_off then
        return M.PokerType.SSS
    end
    if M.IsSEHZ(cards) and M.PokerType.SEHZ.on_off then
        return M.PokerType.SEHZ
    end
    if M.IsQHZ(cards) and M.PokerType.QHZ.on_off then
        return M.PokerType.QHZ
    end
    if M.IsSTHS(cards) and M.PokerType.STHS.on_off then
        return M.PokerType.STHS
    end
    if M.IsSFTX(cards) and M.PokerType.SFTX.on_off then
        return M.PokerType.SFTX
    end
    if M.IsQD(cards) and M.PokerType.QD.on_off then
        return M.PokerType.QD
    end
    if M.IsQX(cards) and M.PokerType.QX.on_off then
        return M.PokerType.QX
    end
    if M.IsCYS(cards) and M.PokerType.CYS.on_off then
        return M.PokerType.CYS
    end
    if M.IsSGCS(cards) and M.PokerType.SGCS.on_off then
        return M.PokerType.SGCS
    end
    if M.IsSCJD(cards) and M.PokerType.SCJD.on_off then
        return M.PokerType.SCJD
    end
    if M.IsSTST(cards) and M.PokerType.STST.on_off then
        return M.PokerType.STST
    end
    if M.IsWDST(cards) and M.PokerType.WDST.on_off then
        return M.PokerType.WDST
    end
    if M.IsLDB(cards) and M.PokerType.LDB.on_off then
        return M.PokerType.LDB
    end
    if M.IsSTH(cards) and M.PokerType.STH.on_off then
        return M.PokerType.STH
    end
    if M.IsSSZ(cards) and M.PokerType.SSZ.on_off then
        return M.PokerType.SSZ
    end
end
function M.IsHighShow(PokerType)
    if PokerType.weight >= M.PokerType.ptHL.weight then
        return true
    end
    return false
end
function M.GetTypeToName(PokerType)
    return M.GetName(PokerType.ptype)
end
function M.GetName(ptype)
    if tonumber(ptype) == tonumber(M.PokerType.ptHJTHS.ptype) then
        return "皇家同花顺"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptTHS.ptype) then
        return "同花顺"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptZD.ptype) then
        return "炸弹"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptHL.ptype) then
        return "葫芦"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptTH.ptype) then
        return "同花"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptSZ.ptype) then
        return "顺子"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptST.ptype) then
        return "三条"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptCS.ptype) then
        return "冲三"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptLD.ptype) then
        return "两对"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptYD.ptype) then
        return "一对"
    end
    if tonumber(ptype) == tonumber(M.PokerType.ptSP.ptype) then
        return "散牌"
    end

    if tonumber(ptype) == tonumber(M.PokerType.THSSS.ptype) then
        return "同花十三水"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SSS.ptype) then
        return "十三水"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SEHZ.ptype) then
        return "十二皇族"
    end
    if tonumber(ptype) == tonumber(M.PokerType.STHS.ptype) then
        return "三同花顺"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SFTX.ptype) then
        return "三分天下"
    end
    if tonumber(ptype) == tonumber(M.PokerType.QD.ptype) then
        return "全大"
    end
    if tonumber(ptype) == tonumber(M.PokerType.QX.ptype) then
        return "全小"
    end
    if tonumber(ptype) == tonumber(M.PokerType.CYS.ptype) then
        return "凑一色"
    end
    if tonumber(ptype) == tonumber(M.PokerType.LDB.ptype) then
        return "六对半"
    end
    if tonumber(ptype) == tonumber(M.PokerType.STH.ptype) then
        return "三同花"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SSZ.ptype) then
        return "三顺子"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SGCS.ptype) then
        return "双怪冲三"
    end
    if tonumber(ptype) == tonumber(M.PokerType.SCJD.ptype) then
        return "三冲加弹"
    end
    if tonumber(ptype) == tonumber(M.PokerType.STST.ptype) then
        return "四套三条"
    end
    if tonumber(ptype) == tonumber(M.PokerType.WDST.ptype) then
        return "五对三条"
    end
    return "错误牌型"
end
-- 同花十三水
function M.IsTHSSS(cards)
    return M.IsTH(cards) and M.IsSZ(cards)
end
-- 十三水
function M.IsSSS(cards)
    return M.IsSZ(cards)
end
-- 十二皇族
function M.IsSEHZ(cards)
    local count = #cards
    local num = 0
    for i = 1, count do
        if tonumber(cards[i].CardNumber) < 11 or tonumber(cards[i].CardNumber) > 13 then
            num = num + 1
            if num > 1 then
                return false
            end
        end
    end
    return true
end
-- 全皇族
function M.IsQHZ(cards)
    local count = #cards
    for i = 1, count do
        if tonumber(cards[i].CardNumber) < 11 then
            return false
        end
    end
    return true
end
-- 三同花顺
function M.IsSTHS(cards)
    local c1 = {}
    local c2 = {}
    local c3 = {}
    local c = M.GetSTH(cards)
    for i = 1, #c do
        -- nmg10:讨巧的判断方式，13牌拆开,75只能是3，5，5相乘得到的(质数)
        c1 = c[i][1]
        c2 = c[i][2]
        c3 = c[i][3]
        if (#c1 * #c2 * #c3) == 75 then
            if M.IsSZ(c1) and M.IsSZ(c2) and M.IsSZ(c3) then
                return true
            end
        end
    end

    return false
end
-- 三分天下
function M.IsSFTX(cards)
    local num = M.GetZD(cards)
    if num == 3 then
        return true
    end
    return false
end
-- 全大
function M.IsQD(cards)
    local count = #cards
    local b = true
    for i = 1, count do
        if tonumber(cards[i].CardNumber) < 8 then
            b = false
            break
        end
    end
    return b
end
-- 全小
function M.IsQX(cards)
    local count = #cards
    local b = true
    for i = 1, count do
        if tonumber(cards[i].CardNumber) > 8 then
            b = false
            break
        end
    end
    return b
end
-- 凑一色
function M.IsCYS(cards)
    local count = #cards
    local color = cards[1].Color
    local b = true
    for i = 2, count do
        if (tonumber(cards[i].Color) + tonumber(color))%2 ~= 0 then
            b = false
            break
        end
    end
    return b
end
-- 双怪冲三
function M.IsSGCS(cards)
    if M.GetST(cards) == 2 and M.GetDZ(cards) == 3 then
        return true
    else
        return false
    end
end
-- 三冲加弹
function M.IsSCJD(cards)
    if M.GetST(cards) == 3 and M.GetZD(cards) == 1 then
        return true
    else
        return false
    end
end
-- 四套三条
function M.IsSTST(cards)
    if M.GetST(cards) == 4 then
        return true
    else
        return false
    end
end
-- 五对三条
function M.IsWDST(cards)
    if M.GetST(cards) == 1 and M.GetDZ(cards) == 5 then
        return true
    else
        return false
    end
end
-- 六对半
function M.IsLDB(cards)
    if M.GetDZ(cards) == 6 then
        return true
    else
        return false
    end
end
-- 三同花
function M.IsSTH(cards)
    local count = #cards
    local num1 = 1
    local num2 = 0
    local num3 = 0
    local num4 = 0
    local c1 = cards[1].Color
    local c2,c3
    for i = 2, count do
        if num1 < 5 and tonumber(cards[i].Color) == tonumber(c1) then
            num1 = num1 + 1
        elseif num2 == 0 or (num2 < 5 and tonumber(cards[i].Color) == tonumber(c2)) then
            c2 = cards[i].Color
            num2 = num2 + 1
        elseif num3 == 0 or (num3 < 5 and tonumber(cards[i].Color) == tonumber(c3)) then
            c3 = cards[i].Color
            num3 = num3 + 1
        else
            num4 = num4 + 1
        end
    end
    -- nmg10:讨巧的判断方式，13牌拆开,75只能是3，5，5相乘得到的(质数)
    if num4 == 0 and (num1 * num2 * num3) == 75 then
        return true
    end
    return false
end
-- 三顺子
function M.IsSSZ(cards)
    local c1 = {}
    local c2 = {}
    local c3 = {}
    local c = M.GetSSZ(cards)
    for i = 1, #c do
        c1 = c[i][1]
        c2 = c[i][2]
        c3 = c[i][3]
        if (#c1 * #c2 * #c3) == 75 then
            return true
        end
    end

    return false
end
-- 三同花
function M.GetSTH(cards)
    local buf = {}
    local count = #cards
    local bufV = {{3,5,5},{5,3,5},{5,5,3}}
    for j = 1, 3 do
        local c1 = {}
        local c2 = {}
        local c3 = {}
        local num1 = 1
        local num2 = 0
        local num3 = 0
        c1[1] = {Color = cards[1].Color, CardNumber = cards[1].CardNumber}
        for i = 2, count do
            if num1 < bufV[j][1] and tonumber(cards[i].Color) == tonumber(c1[num1].Color) then
                num1 = num1 + 1
                c1[num1] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            elseif num2 == 0 or (num2 < bufV[j][2] and tonumber(cards[i].Color) == tonumber(c2[num2].Color)) then
                num2 = num2 + 1
                c2[num2] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            elseif num3 == 0 or (num3 < bufV[j][3] and tonumber(cards[i].Color) == tonumber(c3[num3].Color)) then
                num3 = num3 + 1
                c3[num3] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            else
            end
        end
        -- nmg10:讨巧的判断方式，13牌拆开,75只能是3，5，5相乘得到的(质数)
        if (num1 * num2 * num3) == 75 then
            local c = {}
            table.insert(c, c1)
            table.insert(c, c2)
            table.insert(c, c3)
            table.insert(buf, c)
        end
    end
    return buf
end
-- 三顺子
function M.GetSSZ(cards)
    local buf = {}
    local count = #cards
    local bufV = {{3,5,5},{5,3,5},{5,5,3}}
    for j = 1, 3 do
        local c1 = {}
        local c2 = {}
        local c3 = {}
        local num1 = 1
        local num2 = 0
        local num3 = 0
        c1[1] = {Color = cards[1].Color, CardNumber = cards[1].CardNumber}
        for i = 2, count do
            if num1 < bufV[j][1] and (tonumber(cards[i].CardNumber) - 1) == tonumber(c1[num1].CardNumber) then
                num1 = num1 + 1
                c1[num1] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            elseif num2 == 0 or (num2 < bufV[j][2] and (tonumber(cards[i].CardNumber) - 1) == tonumber(c2[num2].CardNumber)) then
                num2 = num2 + 1
                c2[num2] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            elseif num3 == 0 or (num3 < bufV[j][3] and (tonumber(cards[i].CardNumber) - 1) == tonumber(c3[num3].CardNumber)) then
                num3 = num3 + 1
                c3[num3] = {Color = cards[i].Color, CardNumber = cards[i].CardNumber}
            else
            end
        end
        -- nmg10:讨巧的判断方式，13牌拆开,75只能是3，5，5相乘得到的(质数)
        if (num1 * num2 * num3) == 75 then
            local c = {}
            table.insert(c, c1)
            table.insert(c, c2)
            table.insert(c, c3)
            table.insert(buf, c)
        end
    end
    return buf
end

-- >>>>>>>>>>>>>>>>>>>com
-- 同花
function M.IsTH(cards)
    if not cards or #cards <= 0 then
        return false
    end
    local count = #cards
    local color = cards[1].Color
    local b = true
    for i = 2, count do
        if tonumber(cards[i].Color) ~= tonumber(color) then
            b = false
            break
        end
    end
    return b
end
-- 顺子
function M.IsSZ(cards)
    if not cards or #cards <= 0 then
        return false
    end
    local count = #cards
    local num = cards[1].CardNumber
    local b = true
    for i = 2, count do
        if tonumber(cards[i].CardNumber) ~= tonumber(tonumber(num) + 1) then
            b = false
            break
        end
        num = cards[i].CardNumber
    end
    -- 特殊顺子A2345
    -- if count == 5 and cards[1].CardNumber == 2 and cards[2].CardNumber == 3 and cards[3].CardNumber == 4 and cards[4].CardNumber == 5 and cards[5].CardNumber == 14 then
    --     b = true
    -- end
    return b
end
-- 炸弹数
function M.GetZD(cards)
    local num = 0
    local i = 1
    local count = #cards - 3
    while i <= count do
       if tonumber(cards[i].CardNumber) == tonumber(cards[i+3].CardNumber) then
            num = num + 1
            i = i + 4
        else
            i = i + 1
        end 
    end
    return num
end
-- 三条数
function M.GetST(cards)
    local num = 0
    local i = 1
    local count = #cards - 2
    while i <= count do
       if tonumber(cards[i].CardNumber) == tonumber(cards[i+2].CardNumber) and 
       (not cards[i+3] or tonumber(cards[i].CardNumber) ~= tonumber(cards[i+3].CardNumber)) and
       (not cards[i-1] or tonumber(cards[i-1].CardNumber) ~= tonumber(cards[i+1].CardNumber)) then
            num = num + 1
            i = i + 3
        else
            i = i + 1
        end 
    end
    return num
end
-- 对子数
function M.GetDZ(cards)
    local num = 0
    local i = 1
    local count = #cards - 1
    while i <= count do
       if tonumber(cards[i].CardNumber) == tonumber(cards[i+1].CardNumber) and 
       (not cards[i+2] or tonumber(cards[i].CardNumber) ~= tonumber(cards[i+2].CardNumber)) and
       (not cards[i-1] or tonumber(cards[i-1].CardNumber) ~= tonumber(cards[i+1].CardNumber)) then
            num = num + 1
            i = i + 2
        else
            i = i + 1
        end 
    end
    return num
end

-- 炸弹分数 针对5张牌
function M.GetZDValue(cards)
    local val = {}
    if tonumber(cards[1].CardNumber) == tonumber(cards[4].CardNumber) then
        val = {cards[1].CardNumber, cards[5].CardNumber}
    else
        val = {cards[2].CardNumber, cards[1].CardNumber}
    end 
    return val
end
-- 葫芦分数
function M.GetHLValue(cards)
    local val = {}
    if tonumber(cards[1].CardNumber) == tonumber(cards[2].CardNumber) and tonumber(cards[1].CardNumber) == tonumber(cards[3].CardNumber) then
        val = {cards[1].CardNumber, cards[5].CardNumber}
    else
        val = {cards[3].CardNumber, cards[1].CardNumber}
    end 
    return val
end
-- 三条分数
function M.GetSTValue(cards)
    local val = {}
    if tonumber(cards[1].CardNumber) == tonumber(cards[2].CardNumber) and tonumber(cards[1].CardNumber) == tonumber(cards[3].CardNumber) then        
        if cards[4].CardNumber > cards[5].CardNumber then
            val = {cards[1].CardNumber, cards[4].CardNumber, cards[5].CardNumber}
        else
            val = {cards[1].CardNumber, cards[5].CardNumber, cards[4].CardNumber}
        end
    elseif tonumber(cards[2].CardNumber) == tonumber(cards[3].CardNumber) and tonumber(cards[2].CardNumber) == tonumber(cards[4].CardNumber) then
        if cards[1].CardNumber > cards[5].CardNumber then
            val = {cards[2].CardNumber, cards[1].CardNumber, cards[5].CardNumber}
        else
            val = {cards[2].CardNumber, cards[5].CardNumber, cards[1].CardNumber}
        end
    else
        if cards[1].CardNumber > cards[2].CardNumber then
            val = {cards[3].CardNumber, cards[1].CardNumber, cards[2].CardNumber}
        else
            val = {cards[3].CardNumber, cards[2].CardNumber, cards[1].CardNumber}
        end
    end
    return val
end
-- 两对分数
function M.GetLDValue(cards)
    local val = {}
    if tonumber(cards[1].CardNumber) == tonumber(cards[2].CardNumber) then        
        if cards[4].CardNumber == cards[5].CardNumber then
            val = {cards[4].CardNumber, cards[1].CardNumber, cards[3].CardNumber}
        else
            val = {cards[1].CardNumber, cards[4].CardNumber, cards[5].CardNumber}
        end
    else
        val = {cards[4].CardNumber, cards[2].CardNumber, cards[1].CardNumber}
    end
    return val
end
-- 一对分数
function M.GetYDValue(cards)
    local val = {}
    if #cards == 3 then
        if tonumber(cards[1].CardNumber) == tonumber(cards[2].CardNumber) then
            val = {cards[1].CardNumber, cards[3].CardNumber}
        else
            val = {cards[3].CardNumber, cards[1].CardNumber}
        end
    else
        if tonumber(cards[1].CardNumber) == tonumber(cards[2].CardNumber) then        
            val = {cards[1].CardNumber, cards[5].CardNumber, cards[4].CardNumber, cards[3].CardNumber}
        elseif tonumber(cards[3].CardNumber) == tonumber(cards[2].CardNumber) then        
            val = {cards[2].CardNumber, cards[5].CardNumber, cards[4].CardNumber, cards[1].CardNumber}
        elseif tonumber(cards[3].CardNumber) == tonumber(cards[4].CardNumber) then        
            val = {cards[3].CardNumber, cards[5].CardNumber, cards[2].CardNumber, cards[1].CardNumber}
        else
            val = {cards[4].CardNumber, cards[3].CardNumber, cards[2].CardNumber, cards[1].CardNumber}
        end
    end
    return val
end

--local bufCards
local arrCard = {}
local zhongNum = 0
local sp3Num = 0
local MaxCache = 5--最大推荐组合数量
local CacheData = {}--缓存推荐的组合
local CacheData3 = {}--缓存推荐的组合 后
local indexCacheData3 = 0
function M.SortCacheData3(data)
    local count = #CacheData3
    if count > 1 then
        for i = 1, count do
            local b = true
            if data.ptype.ptype ~= CacheData3[i].ptype.ptype then
                b = false
            end
            if b then
                return
            end
        end
    end
    local ii = 1
    for i = 1, count do
        ii = i
        if CacheData3[i].fenshu < data.fenshu then
            break
        end
    end
    local bufdata = basefunc.deepcopy(data)
    table.insert(CacheData3, ii, bufdata)
end
function M.SortCacheData(data)
    local count = #CacheData
    if count > 1 then
        for i = 1, count do
            local b = true
            for k = 1, 3 do
                if data[k].ptype.ptype ~= CacheData[i][k].ptype.ptype then
                    b = false
                end
            end
            if b then
                return
            end
        end
    end
    local ii = 1
    for i = 1, count do
        ii = i
        if CacheData[i].fenshu < data.fenshu then
            break
        end
    end
    local bufdata = basefunc.deepcopy(data)
    table.insert(CacheData, ii, bufdata)
end
-- 传入13张牌，返回几个牌型的组合(不判断特殊牌型)
-- 通过穷举选择牌型
function M.CombineLogic(cards)
    local bufCards = basefunc.deepcopy(cards)
    bufCards = M.SortPoker(bufCards)
    CacheCards = {}
    CacheData = {}
    CacheData3 = {}
    arrCard = {}
    zhongNum = 0
    sp3Num = 0
    indexCacheData3 = 0
    local b = os.clock()
    M.ZHFun5(1, 0, bufCards)
    for i = 1, #CacheData3 do
        local bufA = {}
        for k = 1, #bufCards do
            local b1 = true
            for j = 1, #CacheData3[i].cards do
                if CacheData3[i].cards[j].Color == bufCards[k].Color and CacheData3[i].cards[j].CardNumber == bufCards[k].CardNumber then
                    b1 = false
                    break
                end
            end
            if b1 then
                table.insert(bufA, bufCards[k])
            end
        end
        indexCacheData3 = i
        arrCard = {}
        M.ZHFun8(1, 0, bufA)
    end
    local e = os.clock()
    print("time = " .. (e - b))
    dump(CacheData, "CacheData")
    return CacheData,(e - b),zhongNum,sp3Num
end
-- 索引 已选择的数量 选择的阶段(3,5,5)
function M.ZHFun5(i, num, bufCards)
    if 5 == num then
        zhongNum = zhongNum + 1
        local cache = {}
        cache.fenshu = 0
        cache.cards = {}
        for i = 1, #arrCard do
            cache.cards[i] = arrCard[i].card
        end
        cache.ptype = M.MaxPTType(cache.cards)
        cache.fenshu = cache.ptype.weight
        -- 剪枝:第三墩不可能是散牌
        if cache.ptype == M.PokerType.ptSP then
            sp3Num = sp3Num + 1
            return
        end
        M.SortCacheData3(cache)
        if #CacheData3 > MaxCache then
            table.remove(CacheData3)
        end
    elseif (#bufCards - i + 1) < (5 - num) then
        return
    else
        -- 不选当前的值
        M.ZHFun5(i+1, num, bufCards)
        -- 选当前的值
        table.insert(arrCard, {i=i,card=bufCards[i]})
        M.ZHFun5(i+1, num+1, bufCards)
        table.remove(arrCard)
    end
end
function M.ZHFun8(i, num, bufCards)
    if 5 == num then
        zhongNum = zhongNum + 1
        local newbufCards = basefunc.deepcopy(bufCards)
        for j = #arrCard, 1, -1 do
            table.remove(newbufCards, arrCard[j].i)
        end
        local c1 = {}-- 头墩
        for j = 1, #newbufCards do
            table.insert(c1, {i=j,card=newbufCards[j]})
        end

        local cache = {}
        cache[1] = {}
        cache[1].cards = {}
        cache[2] = {}
        cache[2].cards = {}
        cache[3] = {}
        cache[3].cards = {}
        for k = 1, #c1 do
            cache[1].cards[k] = c1[k].card
        end
        for k = 1, #arrCard do
            cache[2].cards[k] = arrCard[k].card
        end
        for k = 1, #CacheData3[indexCacheData3].cards do
            cache[3].cards[k] = CacheData3[indexCacheData3].cards[k]
        end

        cache.fenshu = 0
        for j = 1, 3 do
            cache[j].ptype = M.MaxPTType(cache[j].cards)
            cache.fenshu = tonumber(cache.fenshu) + tonumber(cache[j].ptype.weight)
        end
        if (cache[1].ptype.weight < cache[2].ptype.weight or (cache[1].ptype.weight == cache[2].ptype.weight and M.GetCardToString(cache[1].cards, cache[1].ptype) <= M.GetCardToString(cache[2].cards, cache[2].ptype))) and
            (cache[2].ptype.weight < cache[3].ptype.weight or (cache[2].ptype.weight == cache[3].ptype.weight and M.GetCardToString(cache[2].cards, cache[2].ptype) <= M.GetCardToString(cache[3].cards, cache[3].ptype))) then
            M.SortCacheData(cache)
            if #CacheData > MaxCache then
                table.remove(CacheData)
            end
        end
    elseif (#bufCards - i + 1) < (5 - num) then
        return
    else
        -- 不选当前的值
        M.ZHFun8(i+1, num, bufCards)
        -- 选当前的值
        table.insert(arrCard, {i=i,card=bufCards[i]})
        M.ZHFun8(i+1, num+1, bufCards)
        table.remove(arrCard)
    end
end

function M.MaxPTType(cards)
    if #cards == 3 then
        return M.MaxPTType3(cards)
    elseif #cards == 5 then
        return M.MaxPTType5(cards)
    else
        return M.PokerType.Node
    end
end
-- 5张，最大牌型
function M.MaxPTType5(cards)
    if M.IsTH(cards) and M.IsSZ(cards) and cards[1].CardNumber == 10 and M.PokerType.ptHJTHS.on_off then
        return M.PokerType.ptHJTHS
    end
    if M.IsTH(cards) and M.IsSZ(cards) and M.PokerType.ptTHS.on_off then
        return M.PokerType.ptTHS
    end
    if M.GetZD(cards) == 1 and M.PokerType.ptZD.on_off then
        return M.PokerType.ptZD
    end
    if M.GetST(cards) == 1 and M.GetDZ(cards) == 1 and M.PokerType.ptHL.on_off then
        return M.PokerType.ptHL
    end
    if M.IsTH(cards) and M.PokerType.ptTH.on_off then
        return M.PokerType.ptTH
    end
    if M.IsSZ(cards) and M.PokerType.ptSZ.on_off then
        return M.PokerType.ptSZ
    end
    if M.GetST(cards) == 1 and M.PokerType.ptST.on_off then
        return M.PokerType.ptST
    end
    if M.GetDZ(cards) == 2 and M.PokerType.ptLD.on_off then
        return M.PokerType.ptLD
    end
    if M.GetDZ(cards) == 1 and M.PokerType.ptYD.on_off then
        return M.PokerType.ptYD
    end
    return M.PokerType.ptSP
end
-- 3张，最大牌型
function M.MaxPTType3(cards)
    local num1 = tonumber(cards[1].CardNumber)
    local num2 = tonumber(cards[2].CardNumber)
    local num3 = tonumber(cards[3].CardNumber)
    if num1 == num2 and num1 == num3 and M.PokerType.ptCS.on_off then
        return M.PokerType.ptCS
    end
    if num1 == num2 or num1 == num3 or num2 == num3 and M.PokerType.ptYD.on_off then
        return M.PokerType.ptYD
    end
    return M.PokerType.ptSP
end
-- 是不是倒水
function M.IsDaoshui(cache)
    if (cache[1].ptype.weight > cache[2].ptype.weight or (cache[1].ptype.weight == cache[2].ptype.weight and cache[1].twoFS > cache[2].twoFS)) or
    (cache[1].ptype.weight > cache[3].ptype.weight or (cache[1].ptype.weight == cache[3].ptype.weight and cache[1].twoFS > cache[3].twoFS)) then
        return true
    end
    return false
end
-- 是不是倒水
function M.IsDaoshuiC3(cards)
    local cache = {}
    cache.fenshu = 0
    for j = 1, 3 do
        cache[j] = {}
        cache[j].cards = {}
        for k = 1, #cards[j] do
            cache[j].cards[k] = cards[j][k]
        end
        cache[j].ptype = M.MaxPTType(cache[j].cards)
        cache.fenshu = tonumber(cache.fenshu) + tonumber(cache[j].ptype.weight)
        cache[j].twoFS = M.GetCardToString(cache[j].cards, cache[j].ptype)
    end
    if (cache[1].ptype.weight > cache[2].ptype.weight or (cache[1].ptype.weight == cache[2].ptype.weight and cache[1].twoFS > cache[2].twoFS)) or
    (cache[1].ptype.weight > cache[3].ptype.weight or (cache[1].ptype.weight == cache[3].ptype.weight and cache[1].twoFS > cache[3].twoFS)) or
    (cache[2].ptype.weight > cache[3].ptype.weight or (cache[2].ptype.weight == cache[3].ptype.weight and cache[2].twoFS > cache[3].twoFS)) then
        return true
    end
    return false
end
-- 从大到小排序，然后每张牌补齐成两位拼接成字符串
function M.GetCardToString(data, ptype)
    local cards = {}
    if ptype.ptype == M.PokerType.ptHJTHS.ptype or
        ptype.ptype == M.PokerType.ptTHS.ptype or
        ptype.ptype == M.PokerType.ptTH.ptype or
        ptype.ptype == M.PokerType.ptSZ.ptype or
        ptype.ptype == M.PokerType.ptSP.ptype then
        
        cards = basefunc.deepcopy(data)
        cards = M.SortPokerBig(cards)
        local st = ""
        for i = 1, #cards do
            st = st .. string.format("%02d", cards[i].CardNumber)
        end
        local nn = 5 - #cards
        for i = 1, nn do
            st = st .. "00"
        end
        return st        
    end
    
    if ptype.ptype == M.PokerType.ptZD then
        cards = M.GetZDValue(data)
    elseif ptype.ptype == M.PokerType.ptHL.ptype then
        cards = M.GetHLValue(data)
    elseif ptype.ptype == M.PokerType.ptST.ptype then
        cards = M.GetSTValue(data)
    elseif ptype.ptype == M.PokerType.ptLD.ptype then
        cards = M.GetLDValue(data)
    elseif ptype.ptype == M.PokerType.ptYD.ptype then
        cards = M.GetYDValue(data)
    elseif ptype.ptype == M.PokerType.ptCS.ptype then
        cards = {data[1].CardNumber}
    end
    local st = ""
    for i = 1, #cards do
        st = st .. string.format("%02d", cards[i])
    end
    local nn = 5 - #cards
    for i = 1, nn do
        st = st .. "00"
    end
    return st
end

-- 排序 从小到大 从桃到方
function M.SortPoker (cards)
    for i = 1, #cards do
        for j = i + 1, #cards do
            if (cards[i].CardNumber > cards[j].CardNumber) or (cards[i].CardNumber == cards[j].CardNumber and cards[i].Color > cards[j].Color) then
                cards[i].CardNumber, cards[j].CardNumber = cards[j].CardNumber, cards[i].CardNumber
                cards[i].Color, cards[j].Color = cards[j].Color, cards[i].Color
            end
        end
    end
    return cards
end
-- 排序 从大到小 从桃到方
function M.SortPokerBig (cards)
    for i = 1, #cards do
        for j = i + 1, #cards do
            if (cards[i].CardNumber < cards[j].CardNumber) or (cards[i].CardNumber == cards[j].CardNumber and cards[i].Color > cards[j].Color) then
                cards[i].CardNumber, cards[j].CardNumber = cards[j].CardNumber, cards[i].CardNumber
                cards[i].Color, cards[j].Color = cards[j].Color, cards[i].Color
            end
        end
    end
    return cards
end

--[[ 样例数据

    local Cards = {
        {CardNumber = 3, Color = 1},
        {CardNumber = 3, Color = 2},
        {CardNumber = 3, Color = 3},
        {CardNumber = 4, Color = 1},
        {CardNumber = 4, Color = 2},
        {CardNumber = 4, Color = 3},
        {CardNumber = 4, Color = 4},
        {CardNumber = 5, Color = 1},
        {CardNumber = 6, Color = 1},
        {CardNumber = 6, Color = 2},
        {CardNumber = 6, Color = 3},
        {CardNumber = 6, Color = 4},
        {CardNumber = 7, Color = 1},
    }
    local ll = require "Game.CommonPrefab.ThirteenWaterLogic"
    local tjPoker,t1,t2,t3 = ll.CombineLogic(Cards)
    dump({tjPoker,t1,t2,t3}, "addasdasdad")

--]]

return M