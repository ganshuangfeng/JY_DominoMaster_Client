local basefunc = require "Game/Common/basefunc"

QiuQiuCroupier = basefunc.class()
local C = QiuQiuCroupier
C.name = "QiuQiuCroupier"
local instance
local FaceEnum = {
	KaiXin = "KaiXin",
	XianQi = "XianQi",
	AiXin = "AiXin",
	FaPai= "FaPai",
	Normal = "Normal",
}
function C.Create(parent,card_parent)
	instance = instance or C.New(parent,card_parent)
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
	self.lister["fast_gameover_msg"] = basefunc.handler(self,self.on_fast_gameover_msg)
	self.lister["face_play_xianqi"] = basefunc.handler(self,self.on_face_play_xianqi)
	self.lister["face_play_kaixin"] = basefunc.handler(self,self.on_face_play_kaixin)
	self.lister["face_play_aixin"] = basefunc.handler(self,self.on_face_play_aixin)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for i = 1,#self.card_back_list do
		self.card_back_list[i]:MyExit()
	end
	for i = 1,#self.used_cards do
		self.used_cards[i]:MyExit()
	end
	if self.face_timer then
		self.face_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,card_parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.card_parent = card_parent
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.skeleton = self.node.transform:Find("@HeGuan_Fapai"):GetComponent("SkeletonAnimation")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()

	self:InitCards()
	self:MyRefresh()
end

function C:MyRefresh()

end
-- 当前座位是不是有人
local isSeatAct = function (ui_index)
	if QiuQiuModel.GetPosToPlayer(ui_index) then
		if not QiuQiuGamePanel.Instance.playerList[ui_index].IsFlod then
			return true
		end
	else
		return false
	end
end


--发牌
function C:DealCards(pai_data,backcall)
	self.start_index = nil
	self:PlayFace(FaceEnum.FaPai,2)
	--所有的位置，有可能这个位置没有玩家
	local player_card_pos = {
		[1]  = {player = QiuQiuGamePanel.Instance.playerList[1],activate = isSeatAct(1)},
		[2]  = {player = QiuQiuGamePanel.Instance.playerList[2],activate = isSeatAct(2)},
		[3]  = {player = QiuQiuGamePanel.Instance.playerList[3],activate = isSeatAct(3)},
		[4]  = {player = QiuQiuGamePanel.Instance.playerList[4],activate = isSeatAct(4)},
		[5]  = {player = QiuQiuGamePanel.Instance.playerList[5],activate = isSeatAct(5)},
		[6]  = {player = QiuQiuGamePanel.Instance.playerList[6],activate = isSeatAct(6)},
		[7]  = {player = QiuQiuGamePanel.Instance.playerList[7],activate = isSeatAct(7)},
	}
	--庄的编号
	local zhuang =  QiuQiuModel.data.s2cSeatNum[QiuQiuModel.data.zhuang]
	--修正一下，开始发牌的位置，如果zhuang弃牌了，那么发牌的顺序 顺延到下一位
	if isSeatAct(zhuang) then
		
	else
		local r_zhuang = zhuang
		while not isSeatAct(r_zhuang) do
			r_zhuang = r_zhuang + 1
			if r_zhuang > 7 then
				r_zhuang = 1
			end
		end
		zhuang = r_zhuang
	end



	--如果本人处于观战状态

	--如果本人不处于观战状态
	--构建一个表来存储发牌的信息
	local deal_pos_data = {}
	local player_num = 0
	for i = 1,#player_card_pos do
		if player_card_pos[i].activate then
			local index = 1
			local pos_list = {
			}
			if i == 1 then
				pos_list = {
					player_card_pos[i].player["mynode"..1],
					player_card_pos[i].player["mynode"..2],
					player_card_pos[i].player["mynode"..3],
					player_card_pos[i].player["mynode"..4],
				}
			else
				pos_list = {
					player_card_pos[i].player["cardnode"..1],
					player_card_pos[i].player["cardnode"..2],
					player_card_pos[i].player["cardnode"..3],
					player_card_pos[i].player["cardnode"..4],
				}
			end
			local data = {}
			data.isZhuang = i == zhuang
			data.index = #pai_data == 1 and 4 or 1
			data.isMy = i == 1
			data.Cseatnum = i
			data.pos_list = pos_list
			deal_pos_data[#deal_pos_data+1] = data
			player_num = player_num + 1
			--先发庄家
			if i == zhuang then
				self.start_index = #deal_pos_data
			end
		end
	end


	local seq = DoTweenSequence.Create()
	--总的牌数量
	local num = #deal_pos_data * #pai_data
	--这是牌数据得第几张
	local card_index = 1
	self.my_cards = {}
	self.used_cards = self.used_cards or {}
	for i = 1,num do
		seq:AppendInterval(0.2)
		seq:AppendCallback(
			function ()
				local card = table.remove(self.card_back_list,#self.card_back_list)
				if card then
					local index = deal_pos_data[self.start_index].index
					card.transform:SetParent(deal_pos_data[self.start_index].pos_list[index].transform)
					if deal_pos_data[self.start_index].isMy then
						QiuQiuAnim.FlyCard(card,Vector3.New(0.9,0.9,0.9),function ()
							QiuQiuAnim.FanPai(card,pai_data[card_index],function ()
								if card_index == #pai_data then
									if backcall then
										backcall()
									end
									for i = 1,#self.my_cards do
										self.my_cards[i]:MyExit()
									end
									self.my_cards = {}
									Event.Brocast("qiuqiu_my_card_got")
								end
								card_index = card_index + 1
							end)
						end)
						self.my_cards[#self.my_cards+1] = card
					else
						QiuQiuAnim.FlyCard(card,Vector3.New(0.3,0.3,0.3))
						self.used_cards[#self.used_cards+1] = card
						QiuQiuGamePanel.Instance.playerList[deal_pos_data[self.start_index].Cseatnum]:AddCard(card) 
					end
					deal_pos_data[self.start_index].index = deal_pos_data[self.start_index].index + 1
					self.start_index = self.start_index + 1
					if self.start_index > player_num then
						self.start_index = 1
					end
				end
			end
		)
	end	
end
--28张牌
function C:InitCards()
	self.card_back_list = self.card_back_list or {}
	self.used_cards = self.used_cards or {}
	for i = 1,#self.card_back_list do
		self.card_back_list[i]:MyExit()
	end
	for i = 1,#self.used_cards do
		self.used_cards[i]:MyExit()
	end
	self.card_back_list = {}
	self.used_cards = {}
	for i = 1,7 do
		for ii = 1,4 do
			local card_back = QiuQiuCard.Create(self.card_parent,1)
			card_back:SetBack()
			card_back.transform.localScale = Vector3.New(0.2,0.2,0.2)
			card_back.transform.localPosition = Vector3.New(17 * (i - 4),(ii - 1) * 2,0)
			card_back.gameObject.name = i.."-"..ii
			self.card_back_list[#self.card_back_list+1] = card_back
		end
	end
end
--隐藏背面展示的手牌
function C:HideOtherCard()
	self.used_cards  = self.used_cards or {}
	for i = 1,#self.used_cards do
		self.used_cards[i].gameObject:SetActive(false)
	end
end

--获取当前的非弃牌的玩家数量
function C.GetActPlayerNum()
	local sum = 0
	for i = 1,7 do
		if isSeatAct(i) then
			sum = sum + 1
		end
	end
	return sum
end

-- 开始
function C:on_fast_gameover_msg()
	self:InitCards()
end
--通过断线重连得数据刷新
function C:RefreshByAllInfo()
	self:InitCards()
	self.my_cards = self.my_cards or {}
	for i = 1,#self.my_cards do
		self.my_cards[i]:MyExit()
	end
	self.my_cards = {}
	local play_info = QiuQiuModel.data.play_info
	play_info = play_info or {}
	local my_pai = QiuQiuModel.data.pai_data
	for k , v in pairs(play_info) do
		local seat = v.seat_num
		local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
		for i = 1,v.pai_num do
			local card = table.remove(self.card_back_list,#self.card_back_list)
			if card then
			--如果是我
				if Cseat == 1 then
					local parent = QiuQiuGamePanel.Instance.playerList[Cseat]["mynode"..i]
					card:MyExit()
				else
					local parent = QiuQiuGamePanel.Instance.playerList[Cseat]["cardnode"..i]
					card.transform:SetParent(parent)
					card.transform.localPosition = Vector3.zero
					card.transform.localScale = Vector3.New(0.3,0.3,0.3)
					card.transform.localEulerAngles = Vector3.New(0,0,0)
					self.used_cards[#self.used_cards+1] = card
					QiuQiuGamePanel.Instance.playerList[Cseat]:AddCard(card) 
				end
			end
		end
		if Cseat == 1 then
			if #my_pai > 0 then
				QiuQiuGamePanel.Instance.playerList[1]:RefreshHandCard(my_pai)
			end
		end
	end
end

--控制荷官的表情和动作
function C:PlayFace(face_type,normal_time)
	self.HeGuan_Fapai.gameObject:SetActive(false)
	self.HeGuan_Normal.gameObject:SetActive(false)
	self.HeGuan_AiXin.gameObject:SetActive(false)
	self.HeGuan_DiLuo.gameObject:SetActive(false)
	self.HeGuan_GaoXin.gameObject:SetActive(false)
	if face_type == FaceEnum.KaiXin then
		self.HeGuan_GaoXin.gameObject:SetActive(true)
	elseif face_type == FaceEnum.AiXin then
		self.HeGuan_AiXin.gameObject:SetActive(true)
	elseif face_type == FaceEnum.FaPai then
		self.HeGuan_Fapai.gameObject:SetActive(true)
		self.skeleton.AnimationState:SetAnimation(0,"animation",false)
	elseif face_type == FaceEnum.XianQi then
		self.HeGuan_DiLuo.gameObject:SetActive(true)
	elseif face_type == FaceEnum.Normal then
		self.HeGuan_Normal.gameObject:SetActive(true)
	end
	--一定时间后恢复正常
	if normal_time and face_type ~= FaceEnum.Normal then
		if self.face_timer then
			self.face_timer:Stop()
		end
		self.face_timer = Timer.New(
			function ()
				self:PlayFace(FaceEnum.Normal)
			end
		,2,1)
		self.face_timer:Start()
	end
end
--嫌弃
function C:on_face_play_xianqi()
	self:PlayFace(FaceEnum.XianQi,1.4)
end
--开心
function C:on_face_play_kaixin()
	self:PlayFace(FaceEnum.KaiXin,1.4)
end
--爱心
function C:on_face_play_aixin()
	self:PlayFace(FaceEnum.AiXin,5)
end