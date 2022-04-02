-- 玩家持有一个手牌组
-- 手牌组拥有最多4张手牌
-- card_list = { [1] = c1,[2] = c2,... }

local basefunc = require "Game/Common/basefunc"

QiuQiuHandCard = basefunc.class()
local C = QiuQiuHandCard
C.name = "QiuQiuHandCard"
C.pos_config = {
	[1] = Vector3.New(-115,0,0),[2] = Vector3.New(-45,0,0),[3] = Vector3.New(65,0,0),[4] = Vector3.New(135,0,0)
}
function C.Create(owner,card_list)
	return C.New(owner,card_list)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["qiuqiu_nor_adjusted"] = basefunc.handler(self,self.on_qiuqiu_nor_adjusted)
	self.lister["qiuqiu_my_card_got"] = basefunc.handler(self,self.on_qiuqiu_my_card_got)
	self.lister["qiuqiucard_type_change"] = basefunc.handler(self,self.on_qiuqiucard_type_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for k,v in pairs(self.card_list) do
		v:MyExit()
	end
	self.card_list = {}
	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(owner,card_list)
	self.owner = owner
	self.card_list = card_list or {}
	self:MakeLister()
	self:AddMsgListener()
	self.owner.count.gameObject:SetActive(false)
end

function C:MyRefresh()

end
--获取左边手牌的点数
function C:GetLeftPoint()
	
end
--获取右边手牌的点数
function C:GetRightPoint()
	
end
--获取手牌类型
function C:GetHandCardType()
	
end

function C:RefreshCard(card_id_list,Not_CombinationCard)
	for i = 1,#self.card_list do
		self.card_list[i]:MyExit()
	end
	self.card_list = {}
	for i = 1,#card_id_list do
		local card = QiuQiuCard.Create(self.owner.my_card_node or self.owner.card_node,card_id_list[i])
		card:SetReady()
		self.card_list[#self.card_list+1] = card
		card.gameObject.transform:SetParent(self.owner["mynode"..i])
		card.transform.localPosition = Vector3.zero
		card.transform.localScale = Vector3.New(0.9,0.9,0.9)
	end
	if not Not_CombinationCard then
		self.curr_combination_index = 1
		self:CombinationCard()
	end
end

function C:AddCard(card_id)
	local card = QiuQiuCard.Create(self.owner.my_card_node or self.owner.card_node,card_id)
	card:SetReady()
	self.card_list[#self.card_list+1] = card
	card.gameObject.transform:SetParent(self.owner["mynode"..4])
	card.transform.localPosition = Vector3.zero
	card.transform.localScale = Vector3.New(0.9,0.9,0.9)
	self.curr_combination_index = 1
	self:CombinationCard()
end

function C:CombinationCard()
	self.curr_combination = QiuQiuLib.GetCombination(self)
	self.curr_combination = self.curr_combination or {}
	dump(self.curr_combination,"<color=red>所有的组合方式</color>")
	self.curr_combination_index = self.curr_combination_index or 1
	if self.curr_combination_index > #self.curr_combination then
		self.curr_combination_index = 1
	end
	self:RefreshCardPos()
end

function C:on_qiuqiucard_type_change()
	if self.player_confirmed  then return end
	if self.curr_combination_index then
		self.curr_combination_index = self.curr_combination_index + 1
		if self.curr_combination_index > #self.curr_combination then
			self.curr_combination_index = 1
		end
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_change_card.audio_name)
		self:RefreshCardPos()
	end
end

function C:RefreshCardPos()
	self.owner.count.gameObject:SetActive(true)

	local find_card_by_id = function (id)
		for i = 1,#self.card_list do
			if id == self.card_list[i].card_id then
				return self.card_list[i]
			end
		end
	end
	local data = self.curr_combination[self.curr_combination_index]

	for i = 1,#self.curr_combination[self.curr_combination_index] do
		local card = find_card_by_id(self.curr_combination[self.curr_combination_index][i])
		card.transform:SetParent(self.owner["mynode"..i])
	end
	self.curr_card_list = data
	if #data == 4 then
		local card_type = QiuQiuLib.GetCardTypeByID(data)
		local type2prefab = {
			[6] = "QiuQiu_ziti_03",
			[5] = "QiuQiu_ziti_05",
			[4] = "QiuQiu_ziti_04",
			[3] = "QiuQiu_ziti_01",
			[2] = "QiuQiu_ziti_02",
		}
		dump(card_type,"<color=red> 卡牌类型 </color>")
		if card_type == QiuQiuEnum.CardType.kartuBiasa then
			if not self.owner.IsFlod then
				self.owner.count.gameObject:SetActive(true)
			else
				self.owner.count.gameObject:SetActive(false)
			end
			self.owner.evaluate_node.gameObject:SetActive(false)
		else
			self.owner.count.gameObject:SetActive(false)
			if not self.owner.IsFlod then
				self.owner.evaluate_node.gameObject:SetActive(true)
			end
			if self.evaluate_prefab then
				destroy(self.evaluate_prefab)
				self.evaluate_prefab = nil
			end
			self.evaluate_prefab = newObject(type2prefab[card_type],self.owner.evaluate_node.transform)
		end

		self.owner.count1_txt.text = QiuQiuLib.GetPointByID(data[1],data[2])
		self.owner.count2_txt.text = QiuQiuLib.GetPointByID(data[3],data[4])

		if QiuQiuModel.data.status == QiuQiuModel.Status.stake2 or QiuQiuModel.data.status == QiuQiuModel.Status.adjust then
			local order = self:GetOrder()
			dump(order,"<color=red>中途排列</color>")
			Network.SendRequest("nor_qiuqiu_nor_pre_adjust",{data = self:GetOrder()},nil,function (data)
				dump(data,"<color=red>  确认排列 </color>")
			end)
		end
		self.owner.forecast.gameObject:SetActive(true)
		self.owner.forecast_txt.text = "Kliknya utk Mix"
		self.owner.forecast_normal.gameObject:SetActive(true)
	else
		self.owner.count1_txt.text = QiuQiuLib.GetPointByID(data[1],data[2])
		self.owner.count2_txt.text = "?"
		if self.owner.IsFlod then
			self.owner.count.gameObject:SetActive(false)
		else
			self.owner.count.gameObject:SetActive(true)
		end
		local forecast = QiuQiuLib.GetForecast(data)
		dump(forecast,"<color=red>预测数据</color>")
		self.owner.forecast.gameObject:SetActive(true)
		if #forecast == 1 then
			self.owner.forecast_txt.text = "Kliknya utk Mix"
			self.owner.forecast_normal.gameObject:SetActive(true)
		else
			local c = {
				[1] = "Kliknya utk Mix",
				[2] = "QiuQiu",
				[3] = "BigCards",
				[4] = "SmallCards",
				[5] = "TwinCards",
				[6] = "SixDevil",
			}
			local max_index = 1
			local temp = 0
			for k ,v in pairs(forecast) do
				if v > temp and k > 1 then
					temp = v
					max_index = k
				end
			end
			local base_str = c[max_index]
			self.owner.forecast_txt.text = "<color=#FFE23F>"..base_str.." "..(temp*100).."%</color>"
			self.owner.forecast_normal.gameObject:SetActive(false)
		end
	end
	self.owner.nine.gameObject:SetActive(QiuQiuLib.GetPointByID(data[1],data[2]) == 9)
	if QiuQiuLib.GetPointByID(data[1],data[2]) ~= 9 then
		self.owner.count1_txt.color = Color.New(255,255,255,255)
	else
		self.owner.count1_txt.color = Color.New(255/255,255/255,52/255,255/255)
	end

	if self.owner.IsFlod then
		self.owner.forecast.gameObject:SetActive(false)
	end
end

--获取排序编号
function C:GetOrder()
	local original = QiuQiuModel.data.pai_data
	local re = {}
	local find = function (value)
		for i = 1,#original do
			if original[i] == value then
				return i
			end
		end
	end

	if not self.curr_card_list then
		return {1,2,3,4}
	end

	for i = 1,#self.curr_card_list do
		re[i] = find(self.curr_card_list[i])
	end

	return re
end

--清空手牌
function C:ClearHandCard()
	for i = 1,#self.card_list do
		self.card_list[i]:MyExit()
	end
	if self.evaluate_prefab then
		destroy(self.evaluate_prefab)
		self.evaluate_prefab = nil
	end
end

--玩家确认后就不能再次切换牌了
function C:on_qiuqiu_nor_adjusted()
	self.player_confirmed = true
end

function C:on_qiuqiu_my_card_got()
	self.player_confirmed = false
end

function C:ShowMask(mask)
	for i = 1,#self.card_list do
		self.card_list[i]:ShowMask(true)
	end 
end