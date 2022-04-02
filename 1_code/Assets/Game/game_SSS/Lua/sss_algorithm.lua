-- 创建时间:2022-02-10
local basefunc = require "Game.Common.basefunc"
sss_algorithm = {}
local M = sss_algorithm

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











