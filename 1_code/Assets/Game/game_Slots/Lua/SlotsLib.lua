local basefunc = require "Game.Common.basefunc"
SlotsLib = basefunc.class()
local M = SlotsLib

local _xMax = 5
local _yMax = 3
local _xSize = 164
local _ySize = 129
local _xSpac = 0
local _ySpac = 0
local _betCfg
local GetPlayerMoney

---- 元素枚举
local itemEnum = {
	[1] = "1" , -- "Q",
	[2] = "2" , -- "K",
	[3] = "3" , -- "A",
	[4] = "4" , -- "金币(金)",
	[5] = "5" , -- "银锭",
	[6] = "6" , -- "扳指",
	[7] = "7" , -- "玉佩",
	[8] = "8" , -- "夜明珠",
	---- 金色元素
	[9] =  "9" , --"银锭(金)",
	[10] = "A" , --"扳指(金)",
	[11] = "B" ,  --"玉佩(金)",
	[12] = "C" ,  --"夜明珠(金)",
	--特殊元素
	[13] = "D" , --"聚宝盆(WILD)" ,
	[14] = "E" , --"福红" ,
	[15] = "F" , --"福绿" ,
	[16] = "G" , --"福金" ,
	[17] = "H" , --"+1 SPIN" ,
}

------ 基础元素的连线倍数
local baseItemRate = {
	[1] = { 0,0,5,8,10 },
	[2] = { 0,0,5,8,10 },
	[3] = { 0,0,5,8,10 },
	[4] = { 0,0,10,15,50 },
	[5] = { 0,0,5,10,20 },
	[6] = { 0,0,5,10,20 },
	[7] = { 0,0,5,10,20 },
	[8] = { 0,0,5,10,20 },
	[9] = { 0,0,10,20,100 },
	[10] = { 0,0,15,25,150 },
	[11] = { 0,0,15,50,200 },
	[12] = { 0,0,20,60,250 },
}

local itemERate = {
	[1] = 8,
	[2] = 18,
	[3] = 38,
	[4] = 68,
	[5] = 88,
	[6] = 888,
}

local function GetItemIdByIndex(i)
	return itemEnum[i]
end

--获取一个x,y表中的值
local function GetMapValue(map,x,y)
	if not map or not next(map) or not x or not y or not map[x] or not map[x][y] then
		return
	end
	return map[x][y]
end

local function GetPositionByPos(x,y,xSize,ySize,xSpac,ySpac)
	xSize = xSize or _xSize
	ySize = ySize or _ySize
	xSpac = xSpac or _xSpac
	ySpac = ySpac or _ySpac
	local position = {x = 0,y = 0}
	position.x = (x - 1) * (xSize + xSpac)
	position.y = (y - 1) * (ySize + ySpac)
	return position
end

local function GetBgPositonByPos(x,y,xSize,ySize,xSpac,ySpac)
	xSize = xSize or _xSize + _xSpac
	ySize = ySize or _ySize + _ySpac
	xSpac = xSpac or _xSpac
	ySpac = ySpac or _ySpac
	local position = {x = 0,y = 0}
	position.x = (x - 1) * (xSize + xSpac)
	position.y = (y - 1) * (ySize + ySpac)
	return position
end

local function GetPosByPosition(x,y,xSize,ySize,xSpac,ySpac)
	xSize = xSize or _xSize
	ySize = ySize or _ySize
	xSpac = xSpac or _xSpac
	ySpac = ySpac or _ySpac
	local pos = {x = 1,y = 1}
	pos.x = math.floor(x / (xSize + xSpac)) + 1
	pos.y = math.floor(y / (ySize + ySpac)) + 1
	return pos
end

--获取pos根据index：1,2,3,4,5,6,7,8
local function GetPosByIndex(index)
	if not index then
		return
	end
	local pos = {}
	pos.x = index % _xMax
	pos.x = pos.x == 0 and _xMax or pos.x
	pos.y = math.ceil(index / _xMax)
	return pos
end

--获取index根据pos
local function GetIndexByPos(pos)
	if not pos or not next(pos) then
		return
	end

	local index = pos.x + (pos.y - 1) * _xMax
	return index
end

--获取元素移动一圈的距离
local function GetDistance()
	return (_ySize + _ySpac) * (_yMax + 1)
end

--最底端的Y值
local function GetMinY()
	return -(_ySize / 2 + _ySpac)
end

--最顶端的Y值
local function GetMaxY()
	return (_ySize + _ySpac) * _yMax + _ySize / 2
end

--获取一个元素的索引
local function GetItemIndexById(id)
	for i = 1, #itemEnum do
		if itemEnum[i] == id then
			return i
		end
	end
end

--获取一个元素的单线倍率
local function GetItemRate(item,count)
	if not item or not count then
		return 0
	end
	local i = GetItemIndexById(item)
	if not i then
		return 0
	end

	if not baseItemRate[i] then
		return 0
	end

	if count > #baseItemRate[i] then
		count = #baseItemRate[i]
	end

	return baseItemRate[i][count]
end

--获取一些元素的单线倍率
local function GetItemRates(items,counts)
	local rates = {}
	for i = 1, #items do
		rates[i] = GetItemRate(items[i],counts[i])
	end
	return rates
end

--检查某一列是否有元素
local function CheckHaveItemInCol(itemDataMap,id,col,changeItems)
	for y = 1, #itemDataMap[col] do
		if itemDataMap[col][y] == id or (changeItems and changeItems[itemDataMap[col][y]]) then
			return true
		end
	end
end

--获取元素在某一行的个数
local function GetItemCountInCol(itemDataMap,id,col,changeItems)
	local c = 0
	for y = 1, #itemDataMap[col] do
		if itemDataMap[col][y] == id or (changeItems and changeItems[itemDataMap[col][y]]) then
			c = c + 1
		end
	end
	return c
end

--获取map中一个元素的中奖倍率
local function GetItemWinRate(itemDataMap,id,changeItems)
	if not CheckHaveItemInCol(itemDataMap,id,1,changeItems) or not CheckHaveItemInCol(itemDataMap,id,2,changeItems) then
		return 0
	end

	local c = 1
	local i
	for col = 1, _xMax do
		local _c = GetItemCountInCol(itemDataMap,id,col,changeItems)
		if _c == 0 then
			break
		end
		i = col
		c = c * _c
	end
	local rate = GetItemRate(id,i) * c
	return rate
end

--获取map中所有元素的中奖倍率
local function GetItemWinRateAll(itemDataMap,changeItems)
	local itemRate = {}
	local x = 1
	for y = 1, #itemDataMap[x] do
		local id = itemDataMap[x][y]
		if not itemRate[id] then
			local rate = GetItemWinRate(itemDataMap,id,changeItems)
			if rate > 0 then
				itemRate[id] = rate
			end
		end
	end

	if next(itemRate) then
		for k, v in pairs(changeItems or {}) do
			itemRate[v] = itemRate[v] or 0
		end
	end

	return itemRate
end

--获取map中一个元素的中奖的最大长度
local function GetItemWinLength(itemDataMap,id,changeItems)
	if not CheckHaveItemInCol(itemDataMap,id,1,changeItems) or not CheckHaveItemInCol(itemDataMap,id,2,changeItems) then
		return 0
	end

	local c = 1
	local i
	for col = 1, _xMax do
		local _c = GetItemCountInCol(itemDataMap,id,col,changeItems)
		if _c == 0 then
			break
		end
		i = col
	end
	return i
end

--获取连线了的中奖元素
local function GetItemWinConnect(itemDataMap,itemRate)
	if not itemRate or not next(itemRate) then
		return {}
	end
	local changeItems = {}
	for id, rate in pairs(itemRate) do
		if rate == 0 then
			changeItems[id] = id
		end
	end

	local itemWinMap = {}
	for id, rate in pairs(itemRate) do
		if rate ~= 0 then
			local length = GetItemWinLength(itemDataMap,id,changeItems)
			if length > 0 then
				for x = 1, length, 1 do
					for y = 1, _yMax do
						if itemDataMap[x][y] == id then
							itemWinMap[x] = itemWinMap[x] or {}
							itemWinMap[x][y] = itemDataMap[x][y]
						elseif changeItems[itemDataMap[x][y]] then
							itemWinMap[x] = itemWinMap[x] or {}
							itemWinMap[x][y] = itemDataMap[x][y]
						end
					end
				end
			end
		end
	end
	return itemWinMap
end

--元素数据有str转为map
local function DataStrToMap(s,w)
	if not s then return end
	local t = {}
	local x = 1
	local y = 1
	for i = 1, #s do
		t[x] = t[x] or {}
		t[x][y] = string.sub(s,i,i)
		x = x + 1
		if x > w then
			x = 1
			y = y + 1
		end
	end
	return t
end

--元素数据有str转为list
local function DataStrToList(s)
	if not s then return end
	local t = {}
	for i = 1, #s do
		t[i] = string.sub(s,i,i)
	end
	return t
end

local function GetFixedMap(map,fixedIds)
	local fixedMap = {}
	for x = 1, _xMax do
		for y = 1, _yMax do
			if fixedIds[map[x][y]] then
				fixedMap[x] = fixedMap[x] or {}
				fixedMap[x][y] = map[x][y]
			end
		end
	end
	return fixedMap
end

--获取一个MapList，在有固定元素的时候
local function GetMapListOnFixedItem(list,map,fixedIds)
	local fixedMap = GetFixedMap(map,fixedIds)
	local mapList = {}
	local i = 0
	local getMapList
	getMapList = function ()
		local t = {}
		for y = 1, _yMax do
			for x = 1, _xMax do
				t[x] = t[x] or {}
				if GetMapValue(fixedMap,x,y) then
					t[x][y] = fixedMap[x][y]
				else
					i = i + 1
					t[x][y] = list[i]
					if fixedIds[list[i]] then
						fixedMap[x] = fixedMap[x] or {}
						fixedMap[x][y] = list[i]
					end
				end
			end
		end
		mapList[#mapList+1] = t
		if i < #list then
			getMapList()
		end
	end
	getMapList()
	return mapList
end

--获取一个MapList
local function GetMapList(list)
	local mapList = {}
	local i = 0
	local getMapList
	getMapList = function ()
		local t = {}
		for y = 1, _yMax do
			for x = 1, _xMax do
				t[x] = t[x] or {}
				i = i + 1
				t[x][y] = list[i]
			end
		end
		mapList[#mapList+1] = t
		if i < #list then
			getMapList()
		end
	end
	getMapList()
	return mapList
end

local function GetBetMaxByPermission(betCfg)
	betCfg = betCfg or _betCfg
	local errorDesc
	local bet
	for i, v in ipairs(betCfg) do
		local a,b = SYSQXManager.CheckCondition({gotoui="sys_qx", _permission_key="fxgz_bet_".. i})
		if a then
			bet = v
		else
			errorDesc = b.error_desc
			break
		end
	end
	if not bet then
		bet = betCfg[1]
	end
	return bet ,errorDesc
end

--获取最大押注，根据玩家的钱计算，并闲置在VIP权限内
local function GetBetMaxByMoney(betCfg,money)
	betCfg = betCfg or _betCfg
	money = money or GetPlayerMoney()
	local bet
	for i, v in ipairs(betCfg) do
		if v.bet_money > money then
			break
		end
		bet = v
	end
	if not bet then
		bet = betCfg[1]
	end

	local permissionBet = GetBetMaxByPermission()

	if permissionBet.id < bet.id then
		return permissionBet
	end

	return bet
end

--获取押注，根据玩家的钱推荐默认押注
local function GetBetByMoney(betCfg,money)
	betCfg = betCfg or _betCfg
	money = money or GetPlayerMoney()
	money = money / 20
	return GetBetMaxByMoney(betCfg,money)
end

local function GetBetById(id,betCfg)
	id = id or 1
	betCfg = betCfg or _betCfg
	return betCfg[id]
end

--获取福红的倍率列表
local function GetRateListItemE(list)
	local rate = {}
	for i = 1, #list do
		rate[i] = itemERate[tonumber(list[i])]
	end
	return rate
end

local function GetRateMap(itemDataMap,rateList,rateIds)
	if not rateList or not next(rateList) then
		return
	end
	local rateMap = {}
	local i = 0

	for y = 1, _yMax do
		for x = 1, _xMax do
			local id = itemDataMap[x][y]
			if rateIds[id] then
				i = i + 1
				rateMap[x] = rateMap[x] or {}
				rateMap[x][y] = rateList[i]
			end
		end
	end

	return rateMap
end

local function GetRateMapItemEFGList(itemDataMap,itemDataMapList,rateList,rateIds,fixedIds)
	if not rateList or not next(rateList) then
		return
	end
	local fixedMap = GetFixedMap(itemDataMap,fixedIds)
	local rateMapList = {}
	local rateIndex = 1
	for i, itemIdMap in ipairs(itemDataMapList) do
		local rateMap = {}
		for y = 1, _yMax do
			for x = 1, _xMax do
				local id = itemIdMap[x][y]
				if not GetMapValue(fixedMap,x,y) then
					if rateIds[id] then
						rateMap = rateMap or {}
						rateMap[x] = rateMap[x] or {}
						rateMap[x][y] = rateList[rateIndex]
						rateIndex = rateIndex + 1
					end
	
					if fixedIds[id] then
						fixedMap[x] = fixedMap[x] or {}
						fixedMap[x][y] = id
					end
				end
			end
		end
		rateMapList[i] = rateMap
	end

	return rateMapList
end

local function GetRateMapItemEFGMap(rateMapItemEFGList,rateMapItemE)
	local t = {}
	for i, v in ipairs(rateMapItemEFGList) do
		for x, value in pairs(v) do
			for y, rate in pairs(value) do
				t[x] = t[x] or {}
				t[x][y] = rate
			end
		end
	end

	for x, v in pairs(rateMapItemE) do
		for y, rate in pairs(v) do
			t[x] = t[x] or {}
			t[x][y] = rate
		end
	end

	return t
end

local function GetAwardPoolMaxIndexById(itemDataMapList,Ids)
	local t = {}

	for index, value in ipairs(itemDataMapList) do
		for x, xv in ipairs(value) do
			for y, id in ipairs(xv) do
				if Ids[id] then
					t[#t+1] = {
						i = index,
						x = x,
						y = y,
						id = id
					}
				end
			end
		end
	end

	if not next(t) then
		return
	end

	local i = math.random(1,#t)

	return t[i]
end

local function GetAwardPoolMaxIndexByNum(itemDataMapList,Ids,num)
	local t = {}
	for index, value in ipairs(itemDataMapList) do
		local c = 0
		for x, xv in ipairs(value) do
			for y, id in ipairs(xv) do
				if Ids[id] then
					c = c + 1
					if c == num then
						t = {
							i = index,
							x = x,
							y = y,
							id = id
						}
						return t
					end
				end
			end
		end
	end
end

local function GetTriggerMini3Index(itemDataMap,i,ids)
	local t
	local c = 0
	for x, v in ipairs(itemDataMap) do
		for y, id in ipairs(v) do
			if ids[id] then
				c = c + 1
				if c == i then
					t = {x = x,y = y,id = id}
					return t
				end
			end
		end
	end
end

local function GetItemCountByItemDataList(itemDataList,ids)
	local c = 0
	for i, id in ipairs(itemDataList) do
		if ids[id] then
			c = c + 1
		end
	end
	return c
end

local function GetItemMap(itemMap,ids)
	local t = {}
	for x, v in pairs(itemMap) do
		for y, id in pairs(v) do
			if ids[id] then
				t[x] = t[x] or {}
				t[x][y] = id
			end
		end
	end
	return t
end

local idEFG = {E = "E",F = "F",G = "G"}
local function CheckIdIsEFG(id)
	return idEFG[id]
end

local idEFGH = {E = "E",F = "F",G = "G",H = "H"}
local function CheckIdIsEFGH(id)
	return idEFGH[id]
end

local idDEFG = {D = "D", E = "E",F = "F",G = "G"}
local function CheckIdIsDEFG(id)
	return idDEFG[id]
end

local function CheckLongX45(itemDataMap)
	local longX4
	local longX5
	local itemEC = {}
	local c = 0
	for x, v in ipairs(itemDataMap) do
		for y, id in ipairs(v) do
			if id == "E" then
				c = c + 1
			end
		end
		itemEC[x] = c
	end

	if itemEC[3] >= 3 and itemEC[3] < 6 then
		longX4 = true
	end

	if itemEC[4] >= 3 and itemEC[4] < 6 then
		longX5 = true
	end

	return longX4,longX5 
end

local function GetItemEnum()
	return itemEnum
end

local function SetFontById(txt,id)
	local font

    if id == "F" then
        font = "fxgz_imgf_szh"
    elseif id == "G" then
        font = "fxgz_imgf_szlan"
    else
        font = "fxgz_imgf_szl"
    end
    
    txt.font = GetFont(font)
end

--客户端默认元素
local defaultData = "123457768877688"
--获取baseData数据,根据服务器数据
local function GetBaseData(data)
	local baseData = {}
	--初次进入游戏
    if not data.game_data or not next(data.game_data) then
		baseData.totalMoney = data.award_money or 0
		baseData.bet = GetBetByMoney(_betCfg,GetPlayerMoney())
		baseData.awardPool4ExtraMoney = tonumber(data.jjcj_extra_award) or 0

		local mainData = {}
		mainData.game = "main"
        mainData.itemDataList = DataStrToList(defaultData)
        mainData.itemDataMap = DataStrToMap(defaultData,_xMax)
		baseData.mainData = mainData
		return baseData
    end

	baseData.totalMoney = data.award_money or 0
	baseData.bet = GetBetById(data.bet_index)
	baseData.awardPool4ExtraMoney = tonumber(data.jjcj_extra_award) or 0
	baseData.awardPool4Money = tonumber(data.jjcj_award) or 0

	baseData.totalRate = data.game_data.total_rate
	baseData.maxGold = data.game_data.max_gold
	if data.game_data.wild_item_num and data.game_data.wild_item_rate then
		baseData.totalRateGame = data.game_data.total_rate - data.game_data.wild_item_num * data.game_data.wild_item_rate
	end
	dump(baseData, "<color=yellow>baseData : </color>")

	local mainData = {}
	mainData.game = "main"
	mainData.itemDataList = DataStrToList(data.game_data.data)
	mainData.itemDataMap = DataStrToMap(data.game_data.data,_xMax)
	mainData.itemRate = GetItemWinRateAll(mainData.itemDataMap,{D = "D"})
	mainData.rateListItemE = GetRateListItemE(DataStrToList(data.game_data.fu_rate_list))
	mainData.rateMapItemE = GetRateMap(mainData.itemDataMap,mainData.rateListItemE,{E = "E"})
	mainData.itemDNum = data.game_data.wild_item_num
	mainData.itemDRate = data.game_data.wild_item_rate
	mainData.awardPoolMaxId = data.game_data.is_jjcj == 1 and 4 or nil
	mainData.rate = 0
	if mainData.itemRate and next(mainData.itemRate) then
		for k, v in pairs(mainData.itemRate) do
			mainData.rate = mainData.rate + v
		end
	end

	if data.game_data.jackpot_data and next(data.game_data.jackpot_data) then
		mainData.triggerMini3Index = GetTriggerMini3Index(mainData.itemDataMap,data.game_data.jackpot_data.wild_item_index,{D = "D"})
	end

	baseData.mainData = mainData
	dump(mainData, "<color=yellow>baseData mainData : </color>")

	--金玉满堂小游戏
	if data.game_data.jymt_data and next(data.game_data.jymt_data) then
		local miniData = {}
		miniData.game = "mini1"
		miniData.rate = data.game_data.jymt_data.rate
		miniData.itemDataList = DataStrToList(data.game_data.jymt_data.data)
		miniData.itemDataMapList = GetMapListOnFixedItem(miniData.itemDataList,baseData.mainData.itemDataMap,{E = "E",F = "F",G = "G"})--福会固定
		miniData.rateListItemEFG = data.game_data.jymt_data.fu_rate_list
		miniData.rateMapItemEFGList = GetRateMapItemEFGList(baseData.mainData.itemDataMap,miniData.itemDataMapList,miniData.rateListItemEFG,{E = "E",F = "F",G = "G"},{E = "E",F = "F",G = "G"})
		miniData.rateMapItemEFGMap = GetRateMapItemEFGMap(miniData.rateMapItemEFGList,baseData.mainData.rateMapItemE)
		miniData.awardPoolMaxIndex = GetAwardPoolMaxIndexByNum(miniData.itemDataMapList,{E = "E",F = "F",G = "G"},15)-- {i = 1,x = 1, y = 1, id = id}
		miniData.awardPoolMaxId = data.game_data.jymt_data.is_jjcj == 1 and 4 or nil
		miniData.itemHNum = GetItemCountByItemDataList(miniData.itemDataList,{H = "H"})
		baseData.mini1Data = miniData
		dump(baseData.mini1Data,"<color=yellow>baseData mini1Data : </color>")
	end

	--招财进宝小游戏
	if data.game_data.zcjb_data and next(data.game_data.zcjb_data) then
		local miniData = {}
		miniData.game = "mini2"
		miniData.rate = data.game_data.zcjb_data.rate
		miniData.rateInitItemE = data.game_data.zcjb_data.fuhong_init_rate
		miniData.rateItemF = data.game_data.zcjb_data.fulv_rate
		miniData.itemDataList = DataStrToList(data.game_data.zcjb_data.data)
		miniData.itemDataMapList = GetMapList(miniData.itemDataList)
		for i, itemDataMap in ipairs(miniData.itemDataMapList) do
			miniData.itemRateList = miniData.itemRateList or {}
			--福绿作为万能元素
			miniData.itemRateList[#miniData.itemRateList+1] = GetItemWinRateAll(itemDataMap,{F = "F"})
		end
		miniData.awardPoolMaxIndex = GetAwardPoolMaxIndexById(miniData.itemDataMapList,{F = "F"})-- {i = 1,x = 1, y = 1, id = id}
		miniData.awardPoolMaxId = data.game_data.zcjb_data.is_jjcj == 1 and 4 or nil
		baseData.mini2Data = miniData
		dump(baseData.mini2Data,"<color=yellow>baseData min2Data : </color>")
	end

	--jackpot小游戏
	if data.game_data.jackpot_data and next(data.game_data.jackpot_data) then
		local miniData = {}
		miniData.game = "mini3"
		miniData.rate = data.game_data.jackpot_data.rate
		miniData.itemDataList = DataStrToList(data.game_data.jackpot_data.kj_list)
		miniData.awardPoolId = data.game_data.jackpot_data.award_pool_id
		miniData.awardPoolMaxId = data.game_data.jackpot_data.is_jjcj == 1 and 4 or nil
		baseData.mini3Data = miniData
		dump(baseData.mini3Data,"<color=yellow>baseData min3Data : </color>")
	end

	dump(baseData, "<color=yellow>baseData : </color>")
	return baseData
end

local function Init(size,betCfg,getPlayerMoney)
	_yMax = size.yMax
	_xMax = size.xMax
	_xSize = size.xSize
	_ySize = size.ySize
	_xSpac = size.xSpac
	_ySpac = size.ySpac
	_betCfg = betCfg
	GetPlayerMoney = getPlayerMoney
	SlotsModel.itemEnum = itemEnum
end

M.Init = Init
M.GetItemIdByIndex = GetItemIdByIndex
M.GetPosByIndex = GetPosByIndex
M.GetIndexByPos = GetIndexByPos
M.GetItemRate = GetItemRate
M.GetItemRates = GetItemRates
M.GetBaseData = GetBaseData
M.GetBetMaxByMoney = GetBetMaxByMoney
M.GetBetMaxByPermission = GetBetMaxByPermission
M.GetBetById = GetBetById
M.GetPositionByPos = GetPositionByPos
M.GetBgPositonByPos = GetBgPositonByPos
M.GetPosByPosition = GetPosByPosition
M.GetDistance = GetDistance
M.GetMinY = GetMinY
M.GetMaxY = GetMaxY
M.GetFixedMap = GetFixedMap
M.GetItemWinConnect = GetItemWinConnect
M.GetMapValue = GetMapValue
M.GetItemWinLength = GetItemWinLength
M.GetItemMap = GetItemMap
M.CheckIdIsEFG = CheckIdIsEFG
M.CheckIdIsEFGH = CheckIdIsEFGH
M.CheckIdIsDEFG = CheckIdIsDEFG
M.CheckLongX45 = CheckLongX45
M.GetItemEnum = GetItemEnum
M.SetFontById = SetFontById