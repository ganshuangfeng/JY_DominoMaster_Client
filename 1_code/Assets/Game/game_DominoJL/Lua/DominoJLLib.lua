-- 创建时间:2021-11-08
local basefunc = require "Game/Common/basefunc"
DominoJLLib = {}

function DominoJLLib.transform_seat(seatNum,s2cSeatNum,mySeatNum, maxP)
    maxP = maxP or 4
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

--[[
    牌 id = 1, 2, 3, 4, 5, 6, 7, 8, 9 ...
    多米诺牌 0|0, 0|1, 0|2, 0|3, 0|4, 0|5, 0|6, 1|1, 1|2 ...
]]
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

function DominoJLLib.GetDataById(id)
    if not id or type(id) ~= "number" then return end
    return cardData[id]
end

function DominoJLLib.GetIdByData(data)
    if not data or not next(data) then return end
    for id, v in ipairs(cardData) do
        if v[1] == data[1] and v[2] == data[2] then
            return id
        end
    end
end

function DominoJLLib.GetData()
    return cardData
end

function DominoJLLib.GetRemCardCount(handPai,deskPai)
	local remCard = {}
	for i, p in ipairs(cardData) do
		if p[1] == p[2] then
			remCard[p[1]] = remCard[p[1]] or 0
			remCard[p[1]] = remCard[p[1]] + 1
		else
			remCard[p[1]] = remCard[p[1]] or 0
			remCard[p[1]] = remCard[p[1]] + 1
			remCard[p[2]] = remCard[p[2]] or 0
			remCard[p[2]] = remCard[p[2]] + 1
		end
	end

	for k, pai in pairs(handPai or {}) do
		local p = DominoJLLib.GetDataById(pai)
		if p[1] == p[2] then
			remCard[p[1]] = remCard[p[1]] - 1
		else
			remCard[p[1]] = remCard[p[1]] - 1
			remCard[p[2]] = remCard[p[2]] - 1
		end
	end

	for k, pai in pairs(deskPai or {}) do
		local p = DominoJLLib.GetDataById(pai)
		if p[1] == p[2] then
			remCard[p[1]] = remCard[p[1]] - 1
		else
			remCard[p[1]] = remCard[p[1]] - 1
			remCard[p[2]] = remCard[p[2]] - 1
		end
	end

	return remCard
end

function DominoJLLib.GetRemCardByPoint(handPai,deskPai,point)
	local curPai = {}
	for k, pai in pairs(handPai or {}) do
		curPai[pai] = pai
	end

	for k, pai in pairs(deskPai or {}) do
		curPai[pai] = pai
	end

	local remCard = {}
	for pai, p in ipairs(cardData) do
		if not curPai[pai] and (p[1] == point or p[2] == point) then
			remCard[pai] = pai
		end
	end
	return remCard
end

function DominoJLLib.GetCardByPoint(point)
	local card = {}
	for pai, p in ipairs(cardData) do
		if p[1] == point or p[2] == point then
			card[#card+1] = pai
		end
	end
	return card
end

--当前摆牌的方向
local DirEnum = {
	right = "right",
	left = "left",
	up = "up",
	down = "down",
}

--牌在队列中的哪端
local QueuePos = {
	front = "front",
	back = "back",
}

--[[
	cardQueue 桌面牌的队列，左边为back，右边为front
	--队列中的牌的数据
	card = {
		card --牌对象
		cardData = {1,2},
		pos = {x = 1,y = 2, z = 3},
		rot = 0 , 90 , 180, 270 --z轴旋转角度
		queuePos = front or back,
		dir = right left up down --当前牌的排列方向
		backNum, --后面的数字
		frontNum, --前面的数字
	}
]]

--设置牌的数字队列 card：桌上的牌
function DominoJLLib.SetCardNum(card)
	local b
	if card.queuePos == QueuePos.front then
		if card.dir == DirEnum.right then
			if card.rot == 90 then
				b = true
			end
		elseif card.dir == DirEnum.left then
			if card.rot == 270 then
				b = true
			end
		elseif card.dir == DirEnum.up then
			if card.rot == 180 then
				b = true
			end
		elseif card.dir == DirEnum.down then
			if card.rot == 0 then
				b = true
			end
		end
	else
		if card.dir == DirEnum.right then
			if card.rot == 270 then
				b = true
			end
		elseif card.dir == DirEnum.left then
			if card.rot == 90 then
				b = true
			end
		elseif card.dir == DirEnum.up then
			if card.rot == 0 then
				b = true
			end
		elseif card.dir == DirEnum.down then
			if card.rot == 180 then
				b = true
			end
		end
	end

	if b then
		card.frontNum = card.cardData[2]
		card.backNum = card.cardData[1]
	else
		card.frontNum = card.cardData[1]
		card.backNum = card.cardData[2]
	end
end

--计算首尾的点数 cardQueue：桌上的牌队列
function DominoJLLib.GetFrontAndBackNumbers(cardQueue)
	--首尾的点数
	local cardNums = {}

	--没有出过牌
	if cardQueue:empty() then
		cardNums = {[0] = 0,[1] = 1,[2] = 2,[3] = 3,[4] = 4,[5] = 5,[6] = 6,}
		return cardNums
	end

	local frontCard = cardQueue:front()
	local backCard = cardQueue:back()
	cardNums[frontCard.frontNum] = frontCard.frontNum
	cardNums[backCard.backNum] = backCard.backNum

	return cardNums
end

--计算出哪些牌可以出 cardDatas = {[1] = {1,2},[2] = {2,3}} 牌的点数，cardQueue：桌上的牌队列
function DominoJLLib.GetCanPlayCardDatas(cardDatas,cardQueue)
	local canPlayCardDatas = {}
	--没有出过牌
	if cardQueue:empty() then
		canPlayCardDatas = cardDatas
	else
		--首尾的点数
		local cardNums = DominoJLLib.GetFrontAndBackNumbers(cardQueue)
		for k, v in pairs(cardDatas) do
			--首位包含点数
			if cardNums[v[1]] or cardNums[v[2]] then
				canPlayCardDatas[#canPlayCardDatas+1] = v
			end
		end
	end
	if next(canPlayCardDatas) then
		return canPlayCardDatas
	end
end

--确定牌在队列中的位置，可能有多个 cardData = {1,2} 牌的点数，cardQueue：桌上的牌队列
function DominoJLLib.GetQueuePos(cardData,cardQueue)
	if cardQueue:empty() then
		local d = {}
		d[#d+1] = QueuePos.front
		return d
	end

	local frontCard = cardQueue:front()
	local backCard = cardQueue:back()

	local d = {}
	if frontCard.frontNum == cardData[1] or frontCard.frontNum == cardData[2] then
		d[#d+1] = QueuePos.front
	end
	if backCard.backNum == cardData[1] or backCard.backNum == cardData[2] then
		d[#d+1] = QueuePos.back
	end
	return d
end

--计算摆牌方向 card:当前牌，preCard:上一张牌, cardQueue：桌上的牌队列,cardW 牌的宽,cardH 牌的高
function DominoJLLib.GetDir(card,preCard,cardQueue,cardW,cardH,width)
	--对子牌和上一张牌的垂直
	local isPair = card.cardData[1] == card.cardData[2]
	local dir
	if preCard.dir == DirEnum.down then
		--向下已经放过了，立即改变方向，不用检查是否超过
		local func = cardQueue:values()
		local preCard2
		for i = 1, 2 do
			preCard2 = func()
		end

		if preCard2.dir == DirEnum.right then
			dir = DirEnum.left
		elseif preCard2.dir == DirEnum.left then
			dir = DirEnum.right
		end
	elseif preCard.dir == DirEnum.up then
		--向上已经放过了，立即改变方向，不用检查是否超过
		local func = cardQueue:rvalues()
		local preCard2
		for i = 1, 2 do
			preCard2 = func()
		end
		
		if preCard2.dir == DirEnum.right then
			dir = DirEnum.left
		elseif preCard2.dir == DirEnum.left then
			dir = DirEnum.right
		end
	elseif preCard.dir == DirEnum.right then
		--检查是否超过边界，超过了要改变方向
		local cardX
		if isPair then
			--对子要竖着放
			cardX = cardW / 2
		else
			cardX = cardH / 2
		end

		local preCardX = 0
		if preCard.rot == 0 or preCard.rot == 180 or preCard.rot == 360 then
			preCardX = cardW / 2
		elseif preCard.rot == 90 or preCard.rot == 270 then
			preCardX = cardH / 2
		end

		local isOut = (preCard.pos.x + cardX + preCardX) > width / 2
		if isOut then
			--超过边界，改变方向
			if preCard.queuePos == QueuePos.front then
				dir = DirEnum.down
			elseif preCard.queuePos == QueuePos.back then
				dir = DirEnum.up
			end
		else
			--没有超过边界
			if cardQueue:size() == 1 then
				if card.queuePos == QueuePos.front then
					dir = DirEnum.right
				elseif card.queuePos == QueuePos.back then
					dir = DirEnum.left
				end
			else
				if preCard.queuePos == QueuePos.front then
					if card.queuePos == QueuePos.front then
						dir = DirEnum.right
					elseif card.queuePos == QueuePos.back then
						dir = DirEnum.left
					end
				elseif preCard.queuePos == QueuePos.back then
					if card.queuePos == QueuePos.back then
						dir = DirEnum.right
					elseif card.queuePos == QueuePos.front then
						dir = DirEnum.left
					end
				end
			end
		end
	elseif preCard.dir == DirEnum.left then
		--检查是否超过边界，超过了要改变方向
		local cardX
		if isPair then
			--对子要竖着放
			cardX = cardW / 2
		else
			cardX = cardH / 2
		end

		local preCardX = 0
		if preCard.rot == 0 or preCard.rot == 180 or preCard.rot == 360 then
			preCardX = cardW / 2
		elseif preCard.rot == 90 or preCard.rot == 270 then
			preCardX = cardH / 2
		end

		local isOut = (preCard.pos.x - cardX - preCardX) < -width / 2
		if isOut then
			--超过边界，改变方向
			if preCard.queuePos == QueuePos.front then
				dir = DirEnum.down
			elseif preCard.queuePos == QueuePos.back then
				dir = DirEnum.up
			end
		else
			--没有超过边界
			if cardQueue:size() == 1 then
				if card.queuePos == QueuePos.front then
					dir = DirEnum.left
				elseif card.queuePos == QueuePos.back then
					dir = DirEnum.right
				end
			else
				if preCard.queuePos == QueuePos.front then
					if card.queuePos == QueuePos.front then
						dir = DirEnum.left
					elseif card.queuePos == QueuePos.back then
						dir = DirEnum.right
					end
				elseif preCard.queuePos == QueuePos.back then
					if card.queuePos == QueuePos.back then
						dir = DirEnum.left
					elseif card.queuePos == QueuePos.front then
						dir = DirEnum.right
					end
				end
			end
		end
	end
	return dir
end

--计算牌的旋转 card:当前牌，preCard:上一张牌
function DominoJLLib.GetRot(card,preCard)
	local cardData = card.cardData
	local rot = preCard.rot
	--对子牌和上一张牌的垂直
	local isPair = cardData[1] == cardData[2]
	if isPair then
		if rot == 0 or rot == 180 then
			return 90
		elseif rot == 90 or rot == 270 then
			return 0
		end
	end

	local dir = card.dir
	local num
	if card.queuePos == QueuePos.front then
		num = preCard.frontNum
	elseif card.queuePos == QueuePos.back then
		num = preCard.backNum
	end

	if dir == DirEnum.right then
		if num == cardData[1] then
			return 90
		elseif num == cardData[2] then
			return 270
		end
	elseif dir == DirEnum.left then
		if num == cardData[1] then
			return 270
		elseif num == cardData[2] then
			return 90
		end
	elseif dir == DirEnum.down then
		if num == cardData[1] then
			return 0
		elseif num == cardData[2] then
			return 180
		end
	elseif dir == DirEnum.up then
		if num == cardData[1] then
			return 180
		elseif num == cardData[2] then
			return 0
		end
	end
end

--计算牌的位置 card:当前牌，preCard:上一张牌, cardQueue：桌上的牌队列,cardW 牌的宽,cardH 牌的高
function DominoJLLib.GetPos(card,preCard,cardQueue,cardW,cardH)
	local isPair = card.cardData[1] == card.cardData[2]
 	local isLine

	if card.dir == DirEnum.right or card.dir == DirEnum.left then
		if preCard.dir == DirEnum.left or preCard.dir == DirEnum.right then
			isLine = true
		end
	elseif card.dir == DirEnum.up or card.dir == DirEnum.down then
		if preCard.dir == DirEnum.up or preCard.dir == DirEnum.down then
			isLine = true
		end
	end

	if cardQueue:size() == 1 then
		isLine = true
	end
	local preX = 0
	local preY = 0
	local curX = 0
	local curY = 0
	local pos = basefunc.deepcopy(preCard.pos)
	if isLine then
		--在一条线上，不转弯
		if card.dir == DirEnum.right then
			if preCard.rot == 0 or preCard.rot == 180 then
				preX = cardW / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preX = cardH / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curX = cardW / 2
			elseif card.rot == 90 or card.rot == 270 then
				curX = cardH / 2
			end
			pos.x = pos.x + (preX + curX)
		elseif card.dir == DirEnum.left then
			if preCard.rot == 0 or preCard.rot == 180 then
				preX = cardW / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preX = cardH / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curX = cardW / 2
			elseif card.rot == 90 or card.rot == 270 then
				curX = cardH / 2
			end
			pos.x = pos.x - (preX + curX)
		elseif card.dir == DirEnum.up then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end
			pos.y = pos.y + (preY + curY)
		elseif card.dir == DirEnum.down then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end
			pos.y = pos.y - (preY + curY)
		end
	else
		--转弯
		if card.dir == DirEnum.right then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end
			if preCard.dir == DirEnum.up then
				pos.y = pos.y + (preY + curY)
			elseif preCard.dir == DirEnum.down then
				pos.y = pos.y - (preY + curY)
			end

			if not isPair then
				curX = cardH / 4
			end
			pos.x = pos.x + (preX + curX)
		elseif card.dir == DirEnum.left then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end
			if preCard.dir == DirEnum.up then
				pos.y = pos.y + (preY + curY)
			elseif preCard.dir == DirEnum.down then
				pos.y = pos.y - (preY + curY)
			end

			if not isPair then
				curX = cardH / 4
			end
			pos.x = pos.x - (preX + curX)
		elseif card.dir == DirEnum.up then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preX = cardH / 4
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end

			if preCard.dir == DirEnum.right then
				pos.x = pos.x + (preX + curX)
			elseif preCard.dir == DirEnum.left then
				pos.x = pos.x - (preX + curX)
			end

			pos.y = pos.y + (preY + curY)
		elseif card.dir == DirEnum.down then
			if preCard.rot == 0 or preCard.rot == 180 then
				preY = cardH / 2
			elseif preCard.rot == 90 or preCard.rot == 270 then
				preX = cardH / 4
				preY = cardW / 2
			end
			if card.rot == 0 or card.rot == 180 then
				curY = cardH / 2
			elseif card.rot == 90 or card.rot == 270 then
				curY = cardW / 2
			end

			if preCard.dir == DirEnum.right then
				pos.x = pos.x + (preX + curX)
			elseif preCard.dir == DirEnum.left then
				pos.x = pos.x - (preX + curX)
			end

			pos.y = pos.y - (preY + curY)
		end
	end
	return pos
end

--计算牌在首尾位置时的位置和方向 cardData:当前牌的点数, frontOrBack:首尾, cardQueue：桌上的牌队列,startPos 牌的起始位置,cardW 牌的宽,cardH 牌的高,width 桌面的宽
function DominoJLLib.GetCardDirRotPos(cardData,frontOrBack,cardQueue,startPos,cardW,cardH,width)
	local isPair = cardData[1] == cardData[2]
	if cardQueue:empty() then
		local d = {}
		d.rot = isPair and 0 or 90 --第一张牌左边为小点数
		d.pos = startPos
		d.dir = DirEnum.right
		return d
	end

	local card = {}
	card.queuePos = frontOrBack
	card.cardData = cardData
	local preCard
	if frontOrBack == QueuePos.front then
		preCard = cardQueue:front()
	elseif frontOrBack == QueuePos.back then
		preCard = cardQueue:back()
	end

	--没有上一张牌数据
	if not preCard then
		local frontCard = cardQueue:front()
		local backCard = cardQueue:back()
		if frontCard.frontNum == cardData[1] or frontCard.frontNum == cardData[2] then
			preCard = frontCard
		elseif backCard.backNum == cardData[1] or backCard.backNum == cardData[2] then
			preCard = backCard
		end
	end

	--确定当前牌摆的方向
	card.dir = DominoJLLib.GetDir(card,preCard,cardQueue,cardW,cardH,width)
	--确定当前牌的旋转
	card.rot = DominoJLLib.GetRot(card,preCard)
	--确定当前牌的位置
	card.pos = DominoJLLib.GetPos(card,preCard,cardQueue,cardW,cardH)

	return card
end

--计算出的牌在桌上的信息,可能会有多个位置 cardData = {1,2}, cardQueue：桌上的牌队列,startPos 牌的起始位置,cardW 牌的宽,cardH 牌的高,width 桌面的宽
function DominoJLLib.GetCardOnDeskInfo(cardData,cardQueue,startPos,cardW,cardH,width)
	local queuePos = DominoJLLib.GetQueuePos(cardData,cardQueue)
	if not queuePos or not next(queuePos) then return end --不能放到桌上直接退出

	local data = {}
	for i, v in ipairs(queuePos) do
		local d = DominoJLLib.GetCardDirRotPos(cardData,v,cardQueue,startPos,cardW,cardH,width)
		if d and next(d) then
			d.cardData = cardData
			d.queuePos = v
			data[v] = d
		end
	end
	return data
end

--检查并修正出牌位置，保证位置正确 cardData = {1,2}：牌数据,cardQueue：桌上的牌队列,chooseQueuePos：选择的队列位置, canPlayQueuePos：可以出牌的队列位置
function DominoJLLib.CheckChoosePos(cardData,cardQueue,chooseQueuePos,canPlayQueuePos)
	canPlayQueuePos = DominoJLLib.GetQueuePos(cardData,cardQueue)
	if not canPlayQueuePos or not next(canPlayQueuePos) then
		return
	end
	
	if not chooseQueuePos then
		chooseQueuePos = canPlayQueuePos[1]
		return true,chooseQueuePos
	else
		for i, v in ipairs(canPlayQueuePos) do
			if v == chooseQueuePos then
				return true,chooseQueuePos
			end
		end
	end
end

function DominoJLLib.SortPai(paiList)
	if not paiList or not next(paiList) then
		return
	end
	local paiTable = {}
	for i, paiId in ipairs(paiList) do
		paiTable[#paiTable+1] = DominoJLLib.GetDataById(paiId)
	end
	MathExtend.SortListCom(paiTable, function (v1, v2)
		if v1[2] < v2[2] then
			return true
		elseif v1[2] > v2[2] then
			return false
		else
			if v1[1] < v2[1] then
				return true
			else
				return false
			end
		end
	end)
	for i = 1, #paiList do
		paiList[i] = DominoJLLib.GetIdByData(paiTable[i])
	end
	return paiList
end

-- 摄像机 用于坐标转化
function DominoJLLib.SetCamera()
    DominoJLLib.camera2d = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
end

--屏幕坐标转UI坐标
function DominoJLLib.ScreenToWorldPoint(pos)
    local _pos = DominoJLLib.camera2d:ScreenToWorldPoint(pos)
    return _pos
end

--UI坐标转屏幕坐标
function DominoJLLib.WorldToScreenPoint(pos)
    local _pos = DominoJLLib.camera2d:WorldToScreenPoint(pos)
    return _pos
end