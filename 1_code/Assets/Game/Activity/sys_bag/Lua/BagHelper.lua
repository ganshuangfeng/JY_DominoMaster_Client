-- 创建时间:2021-12-27

local basefunc = require "Game.Common.basefunc"
BagHelper = {}
local M = BagHelper

function M.BagListToGridGroupMap(list)
    return M.BagListLenToGridGroupMap(#list)
end

function M.BagListLenToGridGroupMap(listLen)
    local map = {}
    local len = math.floor(listLen / 12) 
    local index = 1
    if listLen % 12 > 0 then
        len = len + 1
    end
    for i = 1, len do
        map[i] = {}
        for j = 1, 12 do
            map[i][j] = index
            if index + 1 > listLen then
                break
            end
            index = index + 1
        end
    end
    return map
end

function M.AddNumToGridGroupMap(oldMap, addNum)
    if #oldMap == 0 then
        return M.BagListLenToGridGroupMap(addNum)
    end
    local xLen = #oldMap
    local yLen = #oldMap[xLen]
    local len = oldMap[xLen][yLen] + addNum
    return M.BagListLenToGridGroupMap(len)
end

function M.DelNumToGridGroupMap(oldMap, delNum)
    local xLen = #oldMap
    local yLen = #oldMap[xLen]
    local len = oldMap[xLen][yLen] - delNum
    return M.BagListLenToGridGroupMap(len)
end

function M.BagItemPagePosListFromMap(map)
    local len = #map
    local list = {}
    if len > 1 then
		local d = 1 / (len - 1)
		local pos = 0
		for i = 1, len do
			list[i] = pos
			pos = pos + d
			if i == len then
				list[i] = 1
			end
		end
	end
    return list
end

function M.NearIndexInNormalizedList(list, hNormalized, direct)
    local breakValue = 0.35
    local d = list[2]
    local range = function(value)
        local range = {}
        if direct == 1 then
            range.min = value - d * (1 - breakValue)
            range.max = value + d * breakValue
        elseif direct == -1 then
            range.min = value - d * breakValue
            range.max = value + d * (1 - breakValue)
        else
            dump("BagHelper NearIndexInNormalizedList Error: direct error")
        end
        return range
    end

    for i = 1, #list do
        local range = range(list[i])
        if hNormalized >= range.min and hNormalized < range.max then
            return i
        end
    end
    return 1
end

function M.SortPage(a, b)
    -- -- local aa = GameItemModel.GetItemToKey(a)
    -- -- local bb = GameItemModel.GetItemToKey(b)
    local aa = a.cfg.order
    local bb = b.cfg.order
    return aa < bb
end

function M.SortBagItem(a, b)
    local aa = GameItemModel.GetItemToKey(a)
    local bb = GameItemModel.GetItemToKey(b)
    return aa.order < bb.order
end
