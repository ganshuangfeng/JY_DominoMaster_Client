-- 创建时间:2021-11-08
local basefunc = require "Game/Common/basefunc"
QiuQiuLib = {}

function QiuQiuLib.transform_seat(seatNum,s2cSeatNum,mySeatNum, maxP)
    maxP = maxP or 7
    if mySeatNum then
        seatNum[1]=mySeatNum
        s2cSeatNum[mySeatNum]=1
        for i=2,maxP do
            mySeatNum=mySeatNum+1
            if mySeatNum>maxP then
                mySeatNum=1
            end
            seatNum[i]=mySeatNum
            s2cSeatNum[mySeatNum]=i
        end
    end
end

local cardData = {
    [1] = {0,0},
    [2] = {0,1},
    [3] = {0,2},
    [4] = {0,3},
    [5] = {0,4},
    [6] = {0,5},
    [7] = {0,6},
    [8] = {1,1},
    [9] = {1,2},
    [10] = {1,3},
    [11] = {1,4},
    [12] = {1,5},
    [13] = {1,6},
    [14] = {2,2},
    [15] = {2,3},
    [16] = {2,4},
    [17] = {2,5},
    [18] = {2,6},
    [19] = {3,3},
    [20] = {3,4},
    [21] = {3,5},
    [22] = {3,6},
    [23] = {4,4},
    [24] = {4,5},
    [25] = {4,6},
    [26] = {5,5},
    [27] = {5,6},
    [28] = {6,6},
}

function QiuQiuLib.GetDataById(id)
    if not id or type(id) ~= "number" then return end
    return cardData[id]
end

function QiuQiuLib.GetIdByData(data)
    if not data or not next(data) then return end
    for id, v in ipairs(cardData) do
        if v[1] == data[1] and v[2] == data[2] then
            return id
        end
    end
end

function QiuQiuLib.GetData()
    return cardData
end

--输入牌，给出点数
function QiuQiuLib.GetPoint(card1_point,card2_point)
    card2_point = card2_point or 0
    return (card1_point + card2_point) % 10
end
--输入牌，给出点数(用ID)
function QiuQiuLib.GetPointByID(card1_id,card2_id)
    local data1 = QiuQiuLib.GetDataById(card1_id)
    local card1_point = data1[1] + data1[2]

    local card2_point = 0
    if card2_id then
        local data2 = QiuQiuLib.GetDataById(card2_id)
        card2_point = data2[1] + data2[2]
    end
    return QiuQiuLib.GetPoint(card1_point,card2_point)
end

--输入手牌，判断骨牌类型
function QiuQiuLib.GetCardType(handCard)
    local id_list = {}
    for i = 1,#handCard.card_list do
        id_list[i] = handCard.card_list[i].card_id
    end
    return QiuQiuLib.GetCardTypeByID(id_list)
end

--根据两组ID判断手牌类型
function QiuQiuLib.GetCardTypeByID(id_list)
    --判断是不是SixDevi
    local isSixDevi = true
    for i = 1,#id_list do
        local data = QiuQiuLib.GetDataById(id_list[i])
        if data[1] + data[2] == 6 then
            
        else
            isSixDevi = false
        end
    end
    if isSixDevi then
        return QiuQiuEnum.CardType.SixDevil
    end

    --判断是不是TwinCards
    local isTwinCards = true
    for i = 1,#id_list do
        local data = QiuQiuLib.GetDataById(id_list[i])
        if data[1] == data[2]then
            
        else
            isTwinCards = false
        end
    end
    if isTwinCards then
        return QiuQiuEnum.CardType.TwinCards
    end

    --判断是不是SmallCards
    local point = 0
    for i = 1,#id_list do
        local data = QiuQiuLib.GetDataById(id_list[i])
        point = point + data[1] + data[2]
    end
    if point <= 9 then
        return QiuQiuEnum.CardType.SmallCards
    end

    --判断是不是BigCards
    local point = 0
    for i = 1,#id_list do
        local data = QiuQiuLib.GetDataById(id_list[i])
        point = point + data[1] + data[2]
    end

    if point >= 39 then
        return QiuQiuEnum.CardType.BigCards
    end

    --判断QiuQiu
    if #id_list == 4 then
        local data_list = {}
        for i = 1,4 do
            local data = QiuQiuLib.GetDataById(id_list[i])
            data_list[i] = data[1] + data[2]
        end
        if QiuQiuLib.GetPoint(data_list[1],data_list[2]) == 9 and QiuQiuLib.GetPoint(data_list[3],data_list[4]) == 9 then
            return QiuQiuEnum.CardType.QiuQiu
        end
    end
    --如果不是上面的特殊牌，就是普通牌了
    return QiuQiuEnum.CardType.kartuBiasa
end

--输入手牌，得到一系列可能的组合
function QiuQiuLib.GetCombination(handCard)
    local card_list = basefunc.deepcopy(handCard.card_list)

    --第一步的处理

    --当这个手牌数量为4的时候,拥有的变化可能性
    local changeType4 = {
        {1,2,3,4},
        {1,3,2,4},
        {1,4,2,3},
    }
    --当这个手牌数量为3的时候,拥有的变化可能性
    local changeType3 = {
        {1,2,3},
        {1,3,2},
        {2,3,1},
    }

    --收集组合的可能性
    local re = {}
    local currChangeType = nil
    if #card_list == 3 then
        currChangeType = changeType3
    elseif #card_list == 4 then
        currChangeType = changeType4
    else
        return 
    end

    for i = 1,#currChangeType do
        local data = {}
        for ii = 1,#currChangeType[i] do
            data[ii] = card_list[currChangeType[i][ii]].card_id
        end
        local r1 = QiuQiuLib.GetPointByID(data[1],data[2])
        local r2 = QiuQiuLib.GetPointByID(data[3],data[4])
        if #card_list == 4 then
           
        end
        if r1 < r2 then
            data[1],data[3] = data[3],data[1]
            data[2],data[4] = data[4],data[2]
        end
        re[#re+1] = data
    end

    for i = 1,#re do
        local data = re[i]
        for ii = 4,1,-1 do
            if not data[ii] then
                table.remove(data,ii)
            end
        end
    end

    table.sort(re,function (a,b)
        local r1 = QiuQiuLib.GetPointByID(a[1],a[2])
        local r2 = QiuQiuLib.GetPointByID(b[1],b[2])
        return r1 > r2
    end)

    --检查是否有重复
    local new_re = {}
    local is_had = function (data)
        local is_same = function (d1,d2)
            for i = 1,#d1 do
                if d1[i] == d2[i] then
                 
                else
                    return false
                end
            end
            return true
        end
        for i = 1,#new_re do
            local _data = new_re[i]
            local is_same = is_same(_data,data)
            if is_same then
                return true
            end
        end

        return false
    end

    for i = 1,#re do
        if not is_had(re[i]) then
            new_re[#new_re+1] = re[i]
        end
    end

    table.sort(new_re,function (a,b)
        local r1 = QiuQiuLib.GetPointByID(a[1],a[2])
        local r2 = QiuQiuLib.GetPointByID(b[1],b[2])
        return r1 > r2
    end)
    return new_re
end

--输入牌，得到一个预测概率
function QiuQiuLib.GetForecast(card_list)
    local is_used = function (card_id)
        for i = 1,#card_list do
            if card_id == card_list[i] then
                return true
            end
        end
        return false
    end

    local total = 0
    local result = {}
    local UESD = {}
    for k , v in pairs(cardData) do
        --如果这张牌没有被用过
        if k and not is_used(k) then
            local this_card_data = basefunc.deepcopy(card_list)
            this_card_data[4] = k
            local handCard = {
                card_list = {
                    [1] = {card_id = this_card_data[1]},
                    [2] = {card_id = this_card_data[2]},
                    [3] = {card_id = this_card_data[3]},
                    [4] = {card_id = this_card_data[4]},
                }
            }
            local re = QiuQiuLib.GetCombination(handCard)
            total = total + 1
            local l_r = {}
            local Used = {}
            for i = 1,#re do
                local r = QiuQiuLib.GetCardTypeByID(re[i])
                l_r[r] = l_r[r] or 0
                l_r[r] = l_r[r] + 1
                if r > 1 then
                    Used = re[i]
                    break
                end
            end

            for kk, vv in pairs(l_r) do
                if vv > 0 then
                    result[kk] = result[kk] or 0
                    result[kk] = result[kk] + 1
                    if kk > 1 then
                        UESD[#UESD + 1] = Used
                    end
                end
            end
        end
    end
    dump(UESD,"<color=red>特殊排</color>")
    for k,v in pairs(result) do
        result[k] = tonumber(string.format("%.2f",result[k] / total)) 
    end
    return result
end