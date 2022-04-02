local basefunc = require "Game.Common.basefunc"
SlotsLionLib = basefunc.class()
local M = SlotsLionLib

local _xMax = 5
local _yMax = 3
local _xSize = 170
local _ySize = 150
local _xSpac = 3
local _ySpac = 5
local _betCfg
local GetPlayerMoney


M.save_path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
M.save_file = "SlotsLionMini2Items"

---- 元素枚举
local itemEnum = {
	[1] = "1" , -- "J",
	[2] = "2" , -- "Q",
	[3] = "3" , -- "K",
	[4] = "4" , -- "A",
	[5] = "5" , -- "铜锣",
	[6] = "6" , -- "灯笼",
	[7] = "7" , -- "鼓",
	[8] = "8" , -- "金花",
	--特殊元素
	[9] =  "9" , --"醒狮 wild",
	[10] = "A" , --"鞭炮 free spins",
}

------ 基础元素的连线倍数
local baseItemRate = {
	[1] = { 0,0,2,5,10, 30 },
	[2] = { 0,0,3,10,20, 50 },
	[3] = { 0,0,5,15,30, 80 },
	[4] = { 0,0,7,20,50, 100 },
	[5] = { 0,0,10,30,80, 200 },
	[6] = { 0,0,15,40,100, 300 },
	[7] = { 0,0,20,80,200, 500 },
	[8] = { 0,0,50,200,500, 1000 },
	[9] = { 0,0,0 ,0 ,0 , 2000 },
}

local itemLine = {
	[1] = {{1,2},{2,2},{3,2},{4,2},{5,2}},
	[2] = {{1,3},{2,3},{3,3},{4,3},{5,3}},
	[3] = {{1,1},{2,1},{3,1},{4,1},{5,1}},
	[4] = {{1,3},{2,2},{3,1},{4,2},{5,3}},
	[5] = {{1,1},{2,2},{3,3},{4,2},{5,1}},
	[6] = {{1,3},{2,3},{3,2},{4,3},{5,3}},
	[7] = {{1,1},{2,1},{3,2},{4,1},{5,1}},
	[8] = {{1,2},{2,3},{3,3},{4,3},{5,2}},
	[9] = {{1,2},{2,1},{3,1},{4,1},{5,2}},
}

--- 免费元素个数 对应免费游戏次数
local freeItemGameNum = {
	[0] = 0,
	[1] = 0,
	[2] = 0,
	[3] = 5,
	[4] = 10,
	[5] = 20,
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

local function GetWinLine(itemDataMap,changeItems,line,ignoreItems)
	local idList = {}
	for x = 1, _xMax do
		idList[x] = itemDataMap[line[x][1]][line[x][2]]
	end
	local lList = {}
	local lMap = {}
	local bId = idList[1]

	if changeItems then	
		for i = 1, _xMax, 1 do
			if not changeItems[idList[i]] and (ignoreItems and not ignoreItems[idList[i]]) then
				bId = idList[i]
				break
			end
		end
	end

	for i = 1, #idList do
		local id = idList[i]
		if bId == id or (changeItems and changeItems[id]) then
			lList[#lList+1] = id
			lMap[i] = id
		else
			break
		end
	end

	local rList = {}
	local rMap = {}
	local bId = idList[_xMax]

	if changeItems then	
		for i = _xMax, 1, -1 do
			if not changeItems[idList[i]] and (ignoreItems and not ignoreItems[idList[i]]) then
				bId = idList[i]
				break
			end
		end
	end

	for i = _xMax, 1, -1 do
		local id = idList[i]
		if bId == id or (changeItems and changeItems[id]) then
			rList[#rList+1] = id
			rMap[i] = id
		else
			break
		end
	end

	--左右两边相同，只算一边
	if #lList == 5 and #rList == 5 then
		rList = {}
	end

	local lIds = {}
	for i, v in pairs(lList) do
		lIds[v] = v
	end
	local b = false
	for k, v in pairs(lIds) do
		if not(v == "A" or v == "9") then
			b = true
		end
	end
	if not b then
		lList = {}
	end


	local rIds = {}
	for i, v in pairs(rList) do
		rIds[v] = v
	end
	local b = false
	for k, v in pairs(rIds) do
		if not(v == "A" or v == "9") then
			b = true
		end
	end
	if not b then
		rList = {}
	end

	if #lList < 3 then
		lList = {}
		lMap = {}
	end

	if #rList < 3 then
		rList = {}
		rMap = {}
	end
	return lList,rList,lMap,rMap
end

local function GetItemDataMapChanged(itemDataMap,gameType)
	local idm = basefunc.deepcopy(itemDataMap)

	if gameType == "main" then
		local c = 0
		for x = 1, _xMax do
			if idm[x][_yMax] == "9" then
				c = c + 1
			end
		end

		if c > 1 then
			for x = 1, _xMax do
				if idm[x][_yMax] == "9" then
					for y = 1, _yMax - 1 do
						idm[x][y] = "9"
					end
				end
			end
		end
	elseif gameType == "mini1" then
		local l = {}
		for x = 1, _xMax do
			for y = 1, _yMax do
				if idm[x][y] == "9" then
					l[x] = true
				end
			end
		end

		for x, b in pairs(l) do
			for y = 1, _yMax do
				idm[x][y] = "9"
			end
		end
	end

	return idm
end

--获取map中一个普通元素的id
local function GetItemDataMapNormalId(itemDataMap,changeItems)
	for x = 1, _xMax do
		for y = 1, _yMax do
			local id = itemDataMap[x][y]
			if not changeItems or not next(changeItems) or not changeItems[id] then
				return id
			end
		end
	end
end

--检查是否是全屏元素
local function CheckIsTotalRewards(_itemDataMap,changeItems,ignoreItems,gameType)
	local itemDataMap = GetItemDataMapChanged(_itemDataMap,gameType)
	--全部是狮子
	local id = GetItemDataMapNormalId(itemDataMap,changeItems)
	if not id then
		return true
	end

	local ids = {}
	for x = 1, _xMax do
		for y = 1, _yMax do
			local id = itemDataMap[x][y]
			ids[id] = id
		end
	end

	local changeItemsCount = 0
	for key, value in pairs(changeItems or {}) do
		changeItemsCount = changeItemsCount + 1
	end

	local idsCount = 0
	for key, value in pairs(ids or {}) do
		idsCount = idsCount + 1
	end

	if idsCount - changeItemsCount < 2 then
		return true
	end
	return false
end

local function GetTotalRewardsItemId(itemDataMap,changeItems)
	local id = GetItemDataMapNormalId(itemDataMap,changeItems)
	if not id then
		local _id
		for k, v in pairs(changeItems or {}) do
			_id = v
			break
		end
		return _id
	end

	for x = 1, _xMax do
		for y = 1, _yMax do
			local _id = itemDataMap[x][y]
			if (not changeItems or not changeItems[_id]) and _id ~= id then
				return
			end
		end
	end

	return id
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

--检查一个元素是否再某一天线上中奖，前后都算
local function CheckIsWinLine(itemDataMap,changeItems,line,ignoreItems)
	local lList,rList = GetWinLine(itemDataMap,changeItems,line,ignoreItems)
	return #lList > 2 or #rList > 2
end

local function GetItemWinOneLineRate(itemDataMap,changeItems,line,i,ignoreItems)
	local lineRate = {}
	lineRate.line = line
	lineRate.index = i
	local lList,rList,lMap,rMap = GetWinLine(itemDataMap,changeItems,line,ignoreItems)

	lineRate.pos = {}
	for k, id in pairs(lMap) do
		lineRate.pos[k] = line[k]
	end

	for k, id in pairs(rMap) do
		lineRate.pos[k] = line[k]
	end

	lineRate.id = {}
	local rate = 0
	if #lList > 0 then
		local lId = lList[1]
		if changeItems then
			for i, v in ipairs(lList) do
				if not changeItems[v] then
					lId = v
					break
				end
			end
		end
		rate = rate + GetItemRate(lId,#lList)
		lineRate.id[#lineRate.id+1] = lId
	end
	if #rList > 0 then
		local rId = rList[1]
		if changeItems then
			for i, v in ipairs(rList) do
				if not changeItems[v] then
					rId = v
					break
				end
			end
		end
		rate = rate + GetItemRate(rId,#rList)
		lineRate.id[#lineRate.id+1] = rId
	end

	lineRate.rate = rate
	return lineRate
end

local function GetItemWinTotalRewardsLineRate(id,line,i)
	local lineRate = {}
	lineRate.id = {id}
	lineRate.line = line
	lineRate.index = i
	lineRate.pos = line
	lineRate.rate = GetItemRate(id,6)
	return lineRate
end

local function GetItemWinLineRate(_itemDataMap,changeItems,ignoreItems,gameType)
	local itemDataMap = GetItemDataMapChanged(_itemDataMap,gameType)
	local isTotalRewards = CheckIsTotalRewards(itemDataMap,changeItems,ignoreItems,gameType)
	local lineRate = {}

	if isTotalRewards then
		local id = GetTotalRewardsItemId(itemDataMap,changeItems)
		for i, v in ipairs(itemLine) do
			lineRate[i] = GetItemWinTotalRewardsLineRate(id,v,i)
		end
	else
		for i, v in ipairs(itemLine) do
			if CheckIsWinLine(itemDataMap,changeItems,v,ignoreItems) then
				lineRate[i] = GetItemWinOneLineRate(itemDataMap,changeItems,v,i,ignoreItems)
			end
		end
	end

	return lineRate
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
			errorDesc = b
			break
		end
	end
	if not bet then
		bet = betCfg[1]
	end

	-- bet = betCfg[#betCfg]
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

local function CheckLongX45(itemDataMap)
	local longX4
	local longX5
	local itemEC = {}
	local c = 0
	for x, v in ipairs(itemDataMap) do
		for y, id in ipairs(v) do
			if id == "A" then
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

local function CheckLongX345(itemDataMap)
	local longX3
	local longX4
	local longX5
	local itemEC = {}
	local item9 = {}
	local c = 0
	for x, v in ipairs(itemDataMap) do
		for y, id in ipairs(v) do
			if id == "A" then
				c = c + 1
			end
			if id == "9" then
				item9[x] = true
			end
		end
		itemEC[x] = c
	end

	if itemEC[2] >= 2 and item9[3] ~= true then
		longX3 = true
	end

	if itemEC[3] >= 2 and item9[4] ~= true then
		longX4 = true
	end

	if itemEC[4] >= 2 and item9[5] ~= true then
		longX5 = true
	end

	return longX3,longX4,longX5 
end

local function GetItemEnum()
	return itemEnum
end

local function exchange_slot_wushi_jackpot_rate( _jackpot_rate_str , _jackpot_str )
	
	assert( #_jackpot_rate_str == #_jackpot_str , "xxx-----------error data len not equal " )

	local tar_ret = {}

	for i = 1 , #_jackpot_rate_str do
		local rate = string.sub( _jackpot_rate_str , i , i )
		local jackpot = tonumber( string.sub( _jackpot_str , i , i ) )


		if jackpot == 3 then
			if rate == "0" then
				tar_ret[#tar_ret + 1] = 0
			else
				tar_ret[#tar_ret + 1] = string.byte( rate )
			end
		else
			tar_ret[#tar_ret + 1] = string.byte( rate ) - 50
		end

	end
	return tar_ret
end

local function GetFreeCount(itemDataMapList,mainItemDataMap)
	local freeCount = {}
	local ac = 0

	local ic = 0
	for x, v in pairs(mainItemDataMap) do
		for y, id in pairs(v) do
			if id == "A" then
				ic = ic + 1
			end
		end
	end
	ac = freeItemGameNum[ic]

	for i, itemDataMap in ipairs(itemDataMapList) do
		local ic = 0
		for x, v in pairs(itemDataMap) do
			for y, id in pairs(v) do
				if id == "A" then
					ic = ic + 1
				end
			end
		end

		freeCount[i] = {}
		if i == 1 then
			freeCount[i].add = ac
			freeCount[i].cur = freeItemGameNum[ic] + ac
		else
			local c = freeCount[i - 1].cur - 1
			c = c < 0 and 0 or c
			freeCount[i].cur = freeItemGameNum[ic] + c
			freeCount[i].add = freeItemGameNum[ic]
		end
		ac = ac + freeItemGameNum[ic]
		freeCount[i].all = ac
	end
	return freeCount
end

local function BuildLocalGameMini2Items(id)
	local itemMap = {}
	if not id or id == "0" or id == 0 then
		itemMap[2] = math.random(1,3)
	else
		itemMap[2] = id
	end
	local buildItemId
	buildItemId = function (i)
		local _id = math.random(1,3)
		local b
		for k, v in pairs(itemMap) do
			if v == _id then
				b = true
				break
			end
		end

		if b then
			buildItemId(i)
		else
			itemMap[i] = _id
		end
	end

	buildItemId(1)
	buildItemId(3)
	local list = {1,2,3}
	list[itemMap[3]] = nil
	list[itemMap[2]] = nil
	for k, v in pairs(list) do
		itemMap[4] = v
	end
	dump({id,itemMap},"<color=white>生成的游戏系数据？？？？xxxx</color>")
	return itemMap
end

local function GetLocalGameMini2Items(gameData,baseData)
	local id = baseData.mini2Data[#baseData.mini2Data].item
	local itemMap = BuildLocalGameMini2Items(id)
	--处理中奖数据，这里保存2个数据在客户端，用作中奖的一前一后的数据
	local mini2Items = load_json2lua(M.save_file .. gameData.service_time,M.save_path)
	if not mini2Items or not next(mini2Items) or mini2Items.key ~= gameData.freegame_data then
		mini2Items = {}
		mini2Items.key = gameData.freegame_data
		mini2Items.data = itemMap
		save_lua2json(mini2Items,M.save_file .. gameData.service_time,M.save_path)
	end
	return mini2Items.data
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
		baseData.awardPool3ExtraMoney = tonumber(data.big_award_pool_num) or 0

		--主游戏
		local mainData = {}
		mainData.game = "main"
        -- mainData.itemDataList = DataStrToList(defaultData)
        mainData.itemDataMap = DataStrToMap(defaultData,_xMax)
		baseData.mainData = mainData

		--小游戏2
		baseData.mini2Data = {}
		local miniData = {}
		miniData.game = "mini2"
		miniData.type = "main"
		miniData.index = 1
		miniData.item = 2
		miniData.items = BuildLocalGameMini2Items()
		baseData.mini2Data[#baseData.mini2Data+1] = miniData

		return baseData
    end

	baseData.totalMoney = data.award_money or 0
	baseData.bet = GetBetById(data.bet_index)
	baseData.awardPool3ExtraMoney = tonumber(data.big_award_pool_num) or 0

	local gameData = data.game_data

	baseData.totalRate = gameData.total_rate
	dump(baseData, "<color=yellow>baseData : </color>")

	local mainData = {}
	mainData.game = "main"
	mainData.itemDataMap = DataStrToMap(gameData.data,_xMax)
	mainData.isTotalRewards = CheckIsTotalRewards(mainData.itemDataMap,{["9"] = "9"},{["A"] = "A"},"main")
	mainData.lineRate = GetItemWinLineRate(mainData.itemDataMap,{["9"] = "9"},{["A"] = "A"},"main")
	mainData.rate = 0
	if mainData.lineRate and next(mainData.lineRate) then
		for k, v in pairs(mainData.lineRate) do
			mainData.rate = mainData.rate + v.rate
		end
	end

	baseData.mainData = mainData
	dump(mainData, "<color=yellow>baseData mainData : </color>")

	--免费小游戏
	if gameData.freegame_data then
		local miniData = {}
		miniData.game = "mini1"
		miniData.itemDataMapList = GetMapList(DataStrToList(gameData.freegame_data))
		miniData.freeCount = GetFreeCount(miniData.itemDataMapList,baseData.mainData.itemDataMap)
		for i, itemDataMap in ipairs(miniData.itemDataMapList) do
			miniData.isTotalRewardsList = miniData.isTotalRewardsList or {}
			miniData.isTotalRewardsList[#miniData.isTotalRewardsList+1] = CheckIsTotalRewards(itemDataMap,{["9"] = "9"},{["A"] = "A"},"mini1")
			miniData.lineRateList = miniData.lineRateList or {}
			miniData.lineRateList[#miniData.lineRateList+1] = GetItemWinLineRate(itemDataMap,{["9"] = "9"},{["A"] = "A"},"mini1")
		end
		baseData.mini1Data = miniData
		dump(baseData.mini1Data,"<color=yellow>baseData min1Data : </color>")
	end

	--jackpot小游戏
	baseData.mini2Data = {}
	baseData.mini2Data.jackpotTotalRate = gameData.freegame_jackpot_total_rate
	if gameData.jackpot then
		local miniData = {}
		miniData.game = "mini2"
		miniData.type = "main"
		miniData.index = 1
		miniData.item = gameData.jackpot
		miniData.rate = gameData.jackpot_rate * 9
		miniData.rateExt = gameData.big_jackpot_rate
		baseData.mini2Data[#baseData.mini2Data+1] = miniData
	end
	if gameData.freegame_jackpot then
		local freegame_jackpot = DataStrToList(gameData.freegame_jackpot)
		local freegame_jackpot_rate = exchange_slot_wushi_jackpot_rate( gameData.freegame_jackpot_rate , gameData.freegame_jackpot )
		for i = 1, #freegame_jackpot do
			local miniData = {}
			miniData.game = "mini2"
			miniData.type = "mini1"
			miniData.index = i
			miniData.item = freegame_jackpot[i]
			miniData.rate = freegame_jackpot_rate[i] * 9
			baseData.mini2Data[#baseData.mini2Data+1] = miniData
		end
	end
	
	baseData.mini2Data[#baseData.mini2Data].items = GetLocalGameMini2Items(gameData,baseData)
	dump(baseData.mini2Data,"<color=yellow>baseData min2Data : </color>")
	dump(baseData, "<color=yellow>baseData : </color>")

	--倍率打印
	-- dump(baseData.mini1Data.lineRateList,"<color=yellow>baseData min2Data lineRateList: </color>")
	-- local rate = 0
	-- rate = rate + baseData.mainData.rate
	-- for i, val1 in ipairs(baseData.mini1Data.lineRateList) do
	-- 	for i1, val in pairs(val1) do
	-- 		dump({i,i1,val},"<color=green>总的倍率？？？？？？？？？？？？？</color>")
	-- 		rate = rate + val.rate
	-- 	end
	-- end

	-- for i, v in ipairs(baseData.mini2Data) do
	-- 	rate = rate + v.rate
	-- end

	-- dump(rate,"<color=green>总的倍率？？？？？？？？？？？？？</color>")

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
	SlotsLionModel.itemEnum = itemEnum
end

local function GetItemLine()
	return itemLine
end

M.Init = Init
M.GetItemIdByIndex = GetItemIdByIndex
M.GetPosByIndex = GetPosByIndex
M.GetIndexByPos = GetIndexByPos
M.GetItemRate = GetItemRate
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
M.GetMapValue = GetMapValue
M.GetItemMap = GetItemMap
M.CheckLongX45 = CheckLongX45
M.CheckLongX345 = CheckLongX345
M.GetItemEnum = GetItemEnum
M.GetItemLine = GetItemLine
M.GetItemIndexById = GetItemIndexById
M.BuildLocalGameMini2Items = BuildLocalGameMini2Items