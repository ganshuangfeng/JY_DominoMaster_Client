local basefunc = require "Game/Common/basefunc"

--控制自己手牌的组行为（左右滑动之类的）

DominoJLCardGroup = basefunc.class()
local C = DominoJLCardGroup
C.name = "DominoJLCardGroup"
local instance
function C.Create(DominoJLCards)
	if not instance then
		instance = C.New(DominoJLCards)
	else
		instance:MyRefresh()
	end
	DominoJLCardGroup.Instance = instance
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["me_auto_play_card"] = basefunc.handler(self,self.on_me_auto_play_card)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.cardMap = {}
	self.original_pos_list = {}
	instance = nil
	DominoJLCardGroup.Instance = nil
	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
end

--按照顺序从左至右排列
function C:ctor()
	DominoJLCardGroup.Instance = self
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.original_pos_list = {}
	for i = 1, 7 do
		self.original_pos_list[#self.original_pos_list+1] = DominoJLGamePanel.Instance["card_node" .. i]
	end
end

function C:MyRefresh()
	self.isLockCardOut = false
	self.isLockCardShake = nil

	self:RefreshCard()
	self:PlayCardCanOut()
end

function C:RefreshCard()
	if not DominoJLModel or not DominoJLModel.data or not DominoJLModel.data.my_pai_list or not next(DominoJLModel.data.my_pai_list) then
		--桌面上没有牌，清空当前桌上的牌
		self:ClearCard()
		return
	end

	local tablePai = DominoJLModel.data.my_pai_list
	local same = true
	for i, id in ipairs(tablePai) do
		if not self.cardMap or not next(self.cardMap) or not self.cardMap[id] then
			same = false
			break
		end
	end

	for pai, card in pairs(self.cardMap or {}) do
		local b = false
		for i, id in ipairs(tablePai) do
			if id == pai then
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
		for pai, card in pairs(self.cardMap or {}) do
			card:MyRefresh()
		end
		return
	end

	self:ClearCard()
	for i, id in ipairs(tablePai) do
		self:AddCard(id)
	end
end

function C:AddCard(id)
	self.cardMap = self.cardMap or {}
	if self.cardMap[id] then
		return
	end
	local i = 1
	for id, card in pairs(self.cardMap or {}) do
		i = i + 1
	end
	self.cardMap[id] = DominoJLCard.Create( {parent=self:GetCardParentByIndex(i), cardData=DominoJLLib.GetDataById(id)} )
	self.cardMap[id]:SetPosIndex(i)
	self.cardMap[id]:SetIsOnHand(true)
end

function C:RemoveCard(id)
	if not self.cardMap or not next(self.cardMap) or not self.cardMap[id] then
		return
	end
	self.cardMap[id]:MyExit()
	self.cardMap[id] = nil
end

function C:ClearCard()
	if not self.cardMap or not next(self.cardMap) then
		return
	end
	for id, card in pairs(self.cardMap) do
		card:MyExit()
	end
	self.cardMap = {}
end

function C:GetCardParentByIndex(i)
	return self.original_pos_list[i].transform
end

--获取一个离自己最近的位置
function C:GetIndexByX(card)
	local xList = {}
	for id, _card in pairs(self.cardMap or {}) do
		xList[#xList+1] = {x = _card.transform.position.x,index = _card.pos_index,id = id}
	end
	
	xList = MathExtend.SortList(xList,"x",true)
	for i, v in ipairs(xList) do
		if v.id == card.data.id then
			return i
		end
	end
end

--当卡牌离开当前所处的位置,后面的牌前移
function C:OnCardLeave(index)
	for id, card in pairs(self.cardMap) do
		if card.pos_index > index then
			card:SetPosIndex(card.pos_index - 1)
		end
	end
end

--当卡牌插入当前最近的位置
function C:OnCardJoin(index)
	for id, card in pairs(self.cardMap) do
		if card.pos_index >= index then
			card:SetPosIndex(card.pos_index + 1)
		end
	end
end

--当牌的位置改变时
function C:OnCardChange(oldIndex,newIndex)
	for id, card in pairs(self.cardMap) do
		if oldIndex < newIndex then
			if card.pos_index > oldIndex and card.pos_index <= newIndex then
				card:SetPosIndex(card.pos_index - 1)
			end
		elseif oldIndex == newIndex then
			-- card:SetPosIndex(card.pos_index)
		elseif oldIndex > newIndex then
			if card.pos_index < oldIndex and card.pos_index >= newIndex then
				card:SetPosIndex(card.pos_index + 1)
			end
		end
	end
end

--出牌
function C:PlayCard(card)
	card:SetIsOnHand(false)
	self.cardMap[card.data.id] = nil
	self:OnCardLeave(card.pos_index)
	self:OnPlayCard()
	--到我出牌才抛消息
	Event.Brocast("me_play_card",card)
	self.isLockCardOut = true
end

function C:AutoOutCard()
	--是否轮到我出牌
	local isTurnToMe = DominoJLGamePanel.Instance.desk:CheckMePlayCard()
	if not isTurnToMe then
		return
	end
	local card = {}
	for id, _card in pairs(self.cardMap) do
		card[#card+1] = _card.data.cardData
	end
	local re = DominoJLGamePanel.Instance.desk:GetCanPlayCardDatas(card)
	re = re or {}
	--没有可以出的牌
	if not next(re) then
		local d = {
			id = 0,
			lr = 0,
		}
		Network.SendRequest("nor_dmn_nor_cp",d)
	end
end

function C:PlayCardShake()
	if self.isLockCardShake then
		return
	end
	local Desk = DominoJLGamePanel.Instance.desk
	local isTurnToMe = Desk:CheckMePlayCard()
	if not isTurnToMe then
		return
	end

	for id, card in pairs(self.cardMap) do
		if card:IsCanOut() then
			if not card.shake then
				card:SetShakeState(true)
			end
		end
	end
end

function C:LockCardShake(t)
	self.isLockCardShake = true
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		self.isLockCardShake = nil
	end)
end

function C:PlayCardCanOut()
	local isTurnToMe = DominoJLGamePanel.Instance.desk:CheckMePlayCard()
	if not isTurnToMe then
		return
	end

	for id, card in pairs(self.cardMap) do
		if card:IsCanOut() then
			DominoJLAnim.PlayCardCanOut(card)
		end
	end
end

--其他玩家出牌 data={cardData = {1,2}, queuePos = "front" or "back"}
function C:on_me_auto_play_card(data)
	dump(data,"<color=yellow>on_me_auto_play_card</color>")
	--没有这张牌
	local cardId = DominoJLLib.GetIdByData(data.cardData)
	if not cardId then
		return
	end

	local card

	for id, v in pairs(self.cardMap) do
		if v.data.cardData[1] == data.cardData[1] and v.data.cardData[2] == data.cardData[2] then
			card = v
			break
		end
	end

	--手上没有这张牌
	if not card then
		DominoJLDesk.Instance:AddCardToQueue(data.cardData,data.queuePos)
		return
	else
		DominoJLDesk.Instance.chooseQueuePos = data.queuePos
		self:PlayCard(card)
	end
end

function C:OnPlayCard()
	for id, card in pairs(self.cardMap or {}) do
		card:SetGray(false)
		card:SetShakeState(false)
	end
	self:LockCardShake(3)
end

function C:SetCardGray()
	for id, card in pairs(self.cardMap or {}) do
		card:SetGray(true)
		card:SetShakeState(false)
	end
end

function C:CheckIsLast()
	local c = 0
	for id, v in pairs(self.cardMap or {}) do
		c = c + 1
	end
	return c < 1
end