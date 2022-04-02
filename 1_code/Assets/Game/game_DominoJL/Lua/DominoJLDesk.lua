-- 创建时间:2021-11-08
-- Panel:DominoJLDesk
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

DominoJLDesk = basefunc.class()
local C = DominoJLDesk
C.name = "DominoJLDesk"

local width = 680 --桌面宽
local height = 360 --桌面高
local cardScale = 0.4 --牌在桌面的缩放
local cardW = 75 * cardScale --牌的宽
local cardH = 152 * cardScale --牌的高
local startPos = {x = 0, y = 0, z = 0} --牌在桌面的起始位置
--当前摆牌的方向-
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
	self.cardQueue 桌面牌的队列，左边为back，右边为front
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

local instance
function C.Create(data)
	if not instance then
		instance = C.New(data)
	else
		instance:MyRefresh()
	end
	C.Instance = instance
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["me_play_card"] = basefunc.handler(self, self.me_play_card)
	self.lister["me_recover_card"] = basefunc.handler(self, self.me_recover_card)
	self.lister["me_choose_card"] = basefunc.handler(self, self.me_choose_card)
	self.lister["other_play_card"] = basefunc.handler(self, self.other_play_card)
	self.lister["clear_choose_card"] = basefunc.handler(self,self.clear_choose_card)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()

	if self.update then
		self.update:Stop()
	end
	self.update = nil

	self:ClearQueueCard()
	self:ClearPlayerCard()
	self:ClearCardHint()
	destroy(self.gameObject)

	instance = nil
	C.Instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = data.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitData()
	self:InitUI()

	self.update = Timer.New(function ()
		self:Update()
	end,0.02,-1,false,false)
	self.update:Start()
end

function C:InitData()
	self.cardQueue = basefunc.queue.New() --牌队列
	self.frontDir = DirEnum.right --首端的朝向
	self.backDir = DirEnum.left	--尾端的朝向
	self.frontLength = 0	--首段的长度
	self.backLength = 0		--尾端的长度
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshQueueCard()
	self:RefreshPlayerCard()
	self:HideCardHint()
end

function C:Update()
	self:UpdateHintCard()
end

--根据出的牌的位置更新提示
function C:UpdateHintCard()
	if not self.chooseCard or not self.chooseCard.data then return end
	if not self.canPlayQueuePos or not next(self.canPlayQueuePos) then
		return
	end
	if self.OnDarging and self:CheckMePlayCard() then
		self:ShowCardHint()
	end
end

function C:ClearCardHint()
	if self.hintLightPrefabList then
		for i = 1,#self.hintLightPrefabList do
			destroy(self.hintLightPrefabList[i].gameObject)
		end
		self.hintLightPrefabList = nil
	end
end

function C:ShowCardHint()
	if not self.hintLightPrefabList then
		self.hintLightPrefabList = {}
		for i = 1,2 do
			local card = DominoJLCard.Create({parent = self.card_node,cardData = self.chooseCard.data.cardData})
			card.gameObject.name = "HintCard"
			card.transform.localScale = Vector3.one * cardScale
			self.hintLightPrefabList[i] = card
			card.gameObject:SetActive(false)
			card:SetIsOnDesk(true)
			card:SetAlpha(0.5)
		end
	else
		local min_dis = 99999
		for i = 1,#self.canPlayQueuePos do
			local data = self:GetCardDirRotPos(self.chooseCard.data.cardData,self.canPlayQueuePos[i])
			local card = self.hintLightPrefabList[i]
			card:InitPoint(self.chooseCard.data.cardData)
			card:SetPosition(data.pos)
			card:SetRotation(data.rot)
			card:SetIsOnDesk(true)
			card:SetAlpha(0.5)
			if self.canPlayQueuePos[i] == QueuePos.front then
				card.transform:SetAsLastSibling()
			elseif self.canPlayQueuePos[i] == QueuePos.back then
				card.transform:SetAsFirstSibling()
			end
			card.gameObject:SetActive(true)
			local dis = Vector3.Distance(card.transform.position,self.chooseCard.gameObject.transform.position)
			if dis < min_dis then
				min_dis = dis
				self.chooseQueuePos = self.canPlayQueuePos[i]
			end
		end
	end
end

function C:HideCardHint()
	if self.hintLightPrefabList then
		for i = 1,#self.hintLightPrefabList do
			self.hintLightPrefabList[i].gameObject:SetActive(false)
		end
	end
end

function C:RefreshQueueCard()
	if not DominoJLModel or not DominoJLModel.data or not DominoJLModel.data.table_pai or not next(DominoJLModel.data.table_pai) then
		--桌面上没有牌，清空当前桌上的牌
		self:ClearQueueCard()
		return
	end

	local tablePai = DominoJLModel.data.table_pai
	local same = true
	for i, v in ipairs(tablePai) do
		if v.pai ~= 0 then
			if not self.cardMap or not next(self.cardMap) or not self.cardMap[v.pai] or self.cardMap[v.pai].index ~= i then
				same = false
				break
			end
		end
	end

	for pai, card in pairs(self.cardMap or {}) do
		local b = false
		for i, v in ipairs(tablePai) do
			if v.pai == pai and i == card.index then
				b = true
				break
			end
		end
		if not b then
			same = false
			break
		end
	end

	--客户端已经创建的牌和服务器上的牌相同
	if same then
		return
	end

	self:ClearQueueCard()
	for i, v in ipairs(tablePai) do
		if v.pai ~= 0 then
			if not self.cardMap or not next(self.cardMap) or not self.cardMap[v.pai] then
				--桌面上没有这张牌
				local cardData = DominoJLLib.GetDataById(v.pai)
				local queuePos = DominoJLModel.S2CQueuePos(v.lr)
				self:AddCardToQueue(cardData,queuePos)
			end
		end
	end

end

function C:SetQueueCardGray()
	if not self.cardMap or not next(self.cardMap) then
		return
	end

	for k, v in pairs(self.cardMap) do
		v.card:SetGray(true)
	end
end

function C:SetQueueCardLightByLastCard()
	local index = 0
	local lastCard
	for k, v in pairs(self.cardMap) do
		if v.index > index then
			lastCard = v
			index = v.index
		end
	end

	local preCard
	local oppCard
	if lastCard.queuePos == QueuePos.front then
		local func = self.cardQueue:values()
		for i = 1, 2 do
			preCard = func()
		end

		oppCard = self.cardQueue:back()
		if oppCard.backNum ~= lastCard.frontNum then
			oppCard = nil
		end
	elseif lastCard.queuePos == QueuePos.back then
		local func = self.cardQueue:rvalues()
		for i = 1, 2 do
			preCard = func()
		end

		oppCard = self.cardQueue:front()

		if oppCard.frontNum ~= lastCard.backNum then
			oppCard = nil
		end
	end

	lastCard.card:SetGray(false)
	preCard.card:SetGray(false)
	if oppCard then
		oppCard.card:SetGray(false)
	end
end

--清空队列中的所有牌
function C:ClearQueueCard()
	if self.cardQueue:empty() then
		return
	end
	for k, v in pairs(self.cardMap) do
		v.card:MyExit()
	end
	self.cardMap = {}
	self.cardQueue:clear()
end

--牌出到桌上，将牌加入到牌队列 cardData = {[1] = 1,[2] = 3} frontOrBack = "front" or "back"
function C:AddCardToQueue(cardData,frontOrBack)
	--没有这张牌
	local cardId = DominoJLLib.GetIdByData(cardData)
	if not cardId then
		return
	end

	if self.cardMap and next(self.cardMap) and self.cardMap[cardId] then
		--桌子上已经加了这张牌
		return
	end

	local card
	if frontOrBack == QueuePos.front then
		card = self:GetCardDirRotPos(cardData,frontOrBack)
		self.cardQueue:push_front(card)
	elseif frontOrBack == QueuePos.back then
		card = self:GetCardDirRotPos(cardData,frontOrBack)
		self.cardQueue:push_back(card)
	end
	card.queuePos = frontOrBack
	card.cardData = cardData
	card.cardId = DominoJLLib.GetIdByData(card.cardData)
	card.index = self.cardQueue:size()

	self:SetCardNum(card)

	local data = {}
	data.parent = self.card_node
	data.cardData = card.cardData
	card.card = DominoJLCard.Create(data)
	card.card.gameObject.name = "desk_" .. card.cardId
	card.card:SetScale(cardScale)
	card.card:SetIsOnDesk(true)
    card.card:SetIsBack(false)
	card.card:SetRotation(card.rot)
	card.card:SetPosition(card.pos)
	if frontOrBack == QueuePos.front then
		card.card.transform:SetAsLastSibling()
	elseif frontOrBack == QueuePos.back then
		card.card.transform:SetAsFirstSibling()
	end

	self.cardMap = self.cardMap or {}
	self.cardMap[card.cardId] = card

	self.chooseQueuePos = nil
	self.canPlayQueuePos = nil
	return card
end

--设置牌的数字队列
function C:SetCardNum(card)
	DominoJLLib.SetCardNum(card)
end

--计算首尾的点数
function C:GetFrontAndBackNumbers()
	DominoJLLib.GetFrontAndBackNumbers(self.cardQueue)
end

--判断一张牌是否可以出 cardDatas = {1,2} 牌的点数
function C:CheckCanPlayCardData(cardData)
	local cd = {[1] = cardData}
	local canCD = self:GetCanPlayCardDatas(cd)
	if not canCD or not next(canCD) then
		return false
	end
	return true
end

--计算出哪些牌可以出 cardDatas = {[1] = {1,2},[2] = {2,3}} 牌的点数
function C:GetCanPlayCardDatas(cardDatas)
	return DominoJLLib.GetCanPlayCardDatas(cardDatas,self.cardQueue)
end

--确定牌在队列中的位置，可能有多个 cardData = {1,2} 牌的点数
function C:GetQueuePos(cardData)
	return DominoJLLib.GetQueuePos(cardData,self.cardQueue)
end

--计算牌在首尾位置时的位置和方向 cardData:当前牌的点数, frontOrBack:首尾
function C:GetCardDirRotPos(cardData,frontOrBack)
	return DominoJLLib.GetCardDirRotPos(cardData,frontOrBack,self.cardQueue,startPos,cardW,cardH,width)
end

--计算出的牌在桌上的信息,可能会有多个位置 cardData = {1,2}
function C:GetCardOnDeskInfo(cardData)
	return DominoJLLib.GetCardOnDeskInfo(cardData,self.cardQueue,startPos,cardW,cardH,width)
end

--检查是否该自己出牌
function C:CheckMePlayCard()
	if DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming then
		return
	end

	if DominoJLModel.data.status ~= DominoJLModel.Status.cp then
		return
	end
	return DominoJLModel.data.seat_num == DominoJLModel.data.cur_p
end

--检查并修正出牌位置，保证位置正确
function C:CheckChoosePos(cardData)
	local b,cqp = DominoJLLib.CheckChoosePos(cardData,self.cardQueue,self.chooseQueuePos,self.canPlayQueuePos)
	if not b then
		self.chooseQueuePos = nil
	else
		self.chooseQueuePos = cqp
	end
	return b
end

function C:me_play_card(card)
	dump(card,"<color=yellow>me_play_card</color>")

	--不到我的权限不用管
	if not self:CheckMePlayCard() then
		return
	end

	--检查下位置
	if not self:CheckChoosePos(card.data.cardData) then
		return
	end

	local m_data = DominoJLModel.data
	self.chooseCard = nil
	local cardDRP = self:GetCardDirRotPos(card.data.cardData,self.chooseQueuePos)
	local pos = cardDRP.pos
	card.transform:SetParent(self.card_node)
	card:SetShakeState(false)
	local rot = Vector3.New(0,0,cardDRP.rot)
	local card_data = card.data.cardData
	local addCard = self:AddCardToQueue(card_data,self.chooseQueuePos)
	if not addCard then
		self:HideCardHint()
		card:MyExit()
		self:MyRefresh()
		return
	end
	addCard.card.gameObject:SetActive(false)
	local position = addCard.card.transform.position
	self:HideCardHint()
	-- local isLast = m_data.remain_pai_amount[m_data.seat_num] < 2
	local isLast = DominoJLCardGroup.Instance:CheckIsLast()
	--当前选中牌飞行动画
	DominoJLAnim.PlayCard(card,pos,rot,cardScale,isLast,position,function ()
		if IsEquals(addCard.card.gameObject) then
			addCard.card.gameObject:SetActive(true)
		end
		card:MyExit()
		self:MyRefresh()
	end)
end

function C:me_recover_card(card)
	dump(card,"<color=yellow>me_recover_card</color>")

	--不到我的权限不用管
	if not self:CheckMePlayCard() then
		return
	end

	self.chooseCard = nil
	self.chooseQueuePos = nil
	self.canPlayQueuePos = nil
end

function C:me_choose_card(card)
	dump(card,"<color=yellow>me_choose_card</color>")
	--不到我的权限不用管
	if not self:CheckMePlayCard() then
		return
	end

	self.chooseCard = card
	self.OnDarging = true

	self.canPlayQueuePos = self:GetQueuePos(self.chooseCard.data.cardData)
end

--其他玩家出牌 data={cardData = {1,2}, queuePos = "front" or "back"}
function C:other_play_card(data)
	dump(data,"<color=yellow>other_play_card</color>")

	--到我的权限不用管
	if self:CheckMePlayCard() then
		return
	end

	--没有这张牌
	local cardId = DominoJLLib.GetIdByData(data.cardData)
	if not cardId then
		return
	end

	local m_data = DominoJLModel.data
	local CSeatNum = m_data.s2cSeatNum[data.seat_num]
	local card = DominoJLCard.Create({parent = self.card_node,cardData = data.cardData})
	card.transform.position = DominoJLGamePanel.Instance.playerList[CSeatNum]:GetCardPosition()[1]
	--当前选中牌飞行动画
	local cardDRP = self:GetCardDirRotPos(data.cardData,data.queuePos)
	local pos = cardDRP.pos
	local rot = Vector3.New(0,0,cardDRP.rot)
	local cardData = card.data.cardData
	local addCard = self:AddCardToQueue(cardData,data.queuePos)
	if not addCard then
		self:HideCardHint()
		card:MyExit()
		self:MyRefresh()
		return
	end
	addCard.card.gameObject:SetActive(false)
	local position = addCard.card.transform.position
	self:HideCardHint()
	local isLast = m_data.remain_pai_amount[data.seat_num] < 1
	DominoJLAnim.PlayCard(card,pos,rot,cardScale,isLast,position,function ()
		if IsEquals(addCard.card.gameObject) then
			addCard.card.gameObject:SetActive(true)
		end
		card:MyExit()
		self:MyRefresh()
	end)
end

function C:clear_choose_card()
	self.OnDarging = false
	self:HideCardHint()
end

function C:RefreshPlayerCard()
	if DominoJLModel.data.model_status == DominoJLModel.Model_Status.gameover then
		return
	end

	local mData = DominoJLModel.data
	if not mData.settlement_info or not next(mData.settlement_info) or not mData.settlement_info.remain_pai then
		self:ClearPlayerCard()
		return
	end

	local same = true
	for i, v in ipairs(mData.settlement_info.remain_pai) do
		if v.seat_num ~= DominoJLModel.data.seat_num then
			if not self.playerCardMap or not next(self.playerCardMap) then
				same = false
				break
			end
			for i1, cardId in ipairs(v.pai) do
				if not self.playerCardMap[cardId] or self.playerCardMap[cardId].cSeatNum ~= DominoJLModel.data.s2cSeatNum[v.seat_num] then
					same = false
					break
				end
			end
		end
	end

	--相同
	if same then
		return
	end

	self:ClearPlayerCard()
	for i, v in ipairs(mData.settlement_info.remain_pai) do
		if v.seat_num ~= DominoJLModel.data.seat_num then
			local cardDatas = {}
			for i1, cardId in ipairs(v.pai) do
				cardDatas[#cardDatas+1] = DominoJLLib.GetDataById(cardId)
			end
			self:CreatePlayerCard(DominoJLModel.data.s2cSeatNum[v.seat_num],cardDatas)
		end
	end
end

-- 创建展示玩家的手牌 seat:玩家客户端上座位号，cardDatas = {[1] = {1,2},[2] = {2,3}} :玩家手牌
function C:CreatePlayerCard(seat,cardDatas)
	local parent = self["player_card_node" .. seat]
	self.playerCardMap = self.playerCardMap or {}
	for i, v in ipairs(cardDatas) do
		local cardId = DominoJLLib.GetIdByData(v)
		self.playerCardMap[cardId] = DominoJLCard.Create({parent = parent,cardData = v})
		self.playerCardMap[cardId].cSeatNum = seat
		self.playerCardMap[cardId]:SetGray(true)
	end
end

--清空玩家展示的手牌
function C:ClearPlayerCard()
	for k, v in pairs(self.playerCardMap or {}) do
		destroy(v.gameObject)
	end
	self.playerCardMap = nil
end