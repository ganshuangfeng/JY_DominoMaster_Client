-- 创建时间:2022-02-09
-- LZHDLib 管理器

local basefunc = require "Game/Common/basefunc"
LZHDLib = {}
local M = LZHDLib

--根据牌的ID获取牌面的点数和花色
function M.GetCardInfo(card_id)
    local point = math.ceil( card_id / 4 )
    local color = card_id % 4
    if color == 0 then
        color = 4
    end
    return {point = point,color = color}
end

--判断谁赢了

function M.WhoWin(left_id,right_id)
    local left_point = M.GetCardInfo(left_id).point
    local right_point = M.GetCardInfo(right_id).point

    if left_point == right_point then
        return LZHDComparisonEnum.Draw
    elseif left_point <= right_point then
        return LZHDComparisonEnum.HuWin
    else
        return LZHDComparisonEnum.LongWin
    end
end