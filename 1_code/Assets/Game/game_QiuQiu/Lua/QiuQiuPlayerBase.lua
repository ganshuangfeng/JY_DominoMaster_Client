-- 创建时间:2021-11-09
-- Panel:QiuQiuPlayerBase

local basefunc = require "Game/Common/basefunc"

QiuQiuPlayerBase = basefunc.class()
local C = QiuQiuPlayerBase
C.name = "QiuQiuPlayerBase"

function C:ctor(panelSelf, obj, data)
	self.panelSelf = panelSelf
	self.data = data
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.hint_node.gameObject:SetActive(false)
	self.d_node.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:MyRefresh()
	self.IsFlod = false
	self.LockRefreshScore = false
	self.Cards = {}
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    -- EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
	-- 	local user = QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
	-- 	if user then
	-- 		GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "my_panel", ext = {pos=self.transform.position}, data = user})
	-- 	end
	-- end)
end

function C:RemoveListenerGameObject()
    EventTriggerListener.Get(self.head_img.gameObject).onClick = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_nor_qiuqiu_nor_begin_msg"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_begin_msg)
	self.lister["model_level_data_change"] = basefunc.handler(self,self.on_model_level_data_change)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ExitUpdatePermitCD()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	--gameObject 是GamePanel上的，还要用，不能销毁，
	--！！！注意清空绑定的点击事件等
	-- destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshPermit()
	self:RefreshPlayerInfo()
end

--进入
function C:PlayJoin()
	self:MyRefresh()
end

--托管
function C:PlayAuto()
	
end

--准备
function C:PlayReady()
	self.ad_confirm.gameObject:SetActive(true)
	self:MyRefresh()
end

--离开
function C:PlayLeave()
	self:MyRefresh()
end

--分数改变
function C:PlayScoreChange()
	self:RefreshScore()
end

function C:RefreshScore()
	local user = QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
	if not self.LockRefreshScore then
		self.last_chip = user.chip
		self.money_txt.text = StringHelper.ToCash(user.chip)
		if self.data.uiIndex == 1 then
			self.rp_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("shop_gold_sum"))
		end
	end
end
--用作动画阶段的加钱
function C:AddChip(value)
	if self.last_chip then
		self.last_chip = self.last_chip + value
		self.money_txt.text = StringHelper.ToCash(self.last_chip)
		if self.data.uiIndex == 1 then
			self.rp_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("shop_gold_sum"))
		end
	end
end

--奖励
function C:PlayAward(data)
	dump(data,"<color=red>当前的奖励</color>")
	local m_data = QiuQiuModel.data
	local data = m_data.award[m_data.seat_num] or 0 
	self.award_txt.text = data

	self:RefreshAward()
end

--刷新奖励
function C:RefreshAward()
	local m_data = QiuQiuModel.data
	if not m_data.seatNum then
		self.award_txt.text = 0
		return
	end
	local data = m_data.award[m_data.seatNum[self.data.uiIndex]] or 0 
	self.award_txt.text = data
end

function C:PlayZhuang()

end

function C:RefreshPlayerInfo()
	local user = QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
	--dump({user = user,index = self.data.uiIndex},"<color=red>这个座位的玩家信息</color>")
	if user then
		self.yes.gameObject:SetActive(true)
		self.no.gameObject:SetActive(false)
		self.name_txt.text = user.name
		if not self.LockRefreshScore then
			self.last_chip = user.chip
			self.money_txt.text = StringHelper.ToCash(user.chip)
			if self.data.uiIndex == 1 then
				self.rp_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("shop_gold_sum"))
			end
		end

		SetHeadImg(user.head_link,self.head_img )
		SetHeadImg(user.head_link,self.head2_img )
		Event.Brocast("set_vip_icon_msg", {img=self.vip_img, vip=user.vip_level})
	else
		self.yes.gameObject:SetActive(false)
		self.no.gameObject:SetActive(false)
	end
end

function C:RefreshPermit()
	if not QiuQiuModel.data.cur_p then
		--没有确定权限
		return
	end

	local cur_p = QiuQiuModel.data.s2cSeatNum[QiuQiuModel.data.cur_p]
	if self.data.uiIndex == cur_p then
		--权限在自己
		self.cd = QiuQiuModel.data.countdown
		self.max_time = QiuQiuModel.data.countdown
		self:UpdatePermitCD()
		self:InitUpdatePermitCD()
		dump(QiuQiuModel.data.status)
		if self.cd > 0 and QiuQiuModel.data.status ~= QiuQiuModel.Status.adjust then
			self.cd_node.gameObject:SetActive(true)
		else
			self.cd_node.gameObject:SetActive(false)
		end
	else
		--权限不在自己
		self.cd = -1
		self:UpdatePermitCD()
		self:ExitUpdatePermitCD()
		self.cd_node.gameObject:SetActive(false)
	end
end

function C:UpdatePermitCD()
	if not self.cd or self.cd < 0 then
		return
	end
	
	self.cd_img.fillAmount = self.cd / self.max_time
	self.cd_bg_img.fillAmount = self.cd / self.max_time
	self.cd = self.cd - 0.02

	--如果最大时间大于10秒，并且此时的剩余时间少于4秒，那么每次

	if self.max_time >= 9 and self.cd <= 3  then
		if self.cd_txt.text ~= tostring(math.ceil(self.cd)) and self.cd ~= 0 and QiuQiuModel.data.status ~= QiuQiuModel.Status.adjust then
			if self.data.uiIndex == 1 and not self.IsAllIn and not self.IsFlod then
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_countdown.audio_name)
			end
		end
	end
	self.cd_txt.text = math.ceil(self.cd)

	if self.cd <= 0 or QiuQiuModel.data.status == QiuQiuModel.Status.adjust then
		self.cd_node.gameObject:SetActive(false)
	end
end

function C:InitUpdatePermitCD()
	self:ExitUpdatePermitCD()
	self.updatePermintCDTimer = Timer.New(function ()
		if IsEquals(self.gameObject) then
			self:UpdatePermitCD()
		end
	end,0.02,-1,false,false)
	self.updatePermintCDTimer:Start()
end

function C:ExitUpdatePermitCD()
	if self.updatePermintCDTimer then
		self.updatePermintCDTimer:Stop()
	end
	self.updatePermintCDTimer = nil
end

function C:ShowCard(card_id_list)
	--如果是我的
	self.all_in_node.gameObject:SetActive(false)
	local show_count = function ()
		local card_type = QiuQiuLib.GetCardTypeByID(card_id_list)
		local type2prefab = {
			[6] = "QiuQiu_ziti_03",
			[5] = "QiuQiu_ziti_05",
			[4] = "QiuQiu_ziti_04",
			[3] = "QiuQiu_ziti_01",
			[2] = "QiuQiu_ziti_02",
		}
		dump(card_type,"<color=red> 卡牌类型 </color>")
		if card_type == QiuQiuEnum.CardType.kartuBiasa then
			if not self.IsFlod then
				self.count.gameObject:SetActive(true)
			end
			self.evaluate_node.gameObject:SetActive(false)
		else
			self.count.gameObject:SetActive(false)
			if not self.IsFlod then
				self.evaluate_node.gameObject:SetActive(true)
			end
			if self.evaluate_prefab then
				destroy(self.evaluate_prefab)
				self.evaluate_prefab = nil
			end
			self.evaluate_prefab = newObject(type2prefab[card_type],self.evaluate_node.transform)
		end
		self.count1_txt.text = QiuQiuLib.GetPointByID(card_id_list[1] , card_id_list[2])
		self.count2_txt.text = QiuQiuLib.GetPointByID(card_id_list[3] , card_id_list[4])
		self.nine.gameObject:SetActive(QiuQiuLib.GetPointByID(card_id_list[1] , card_id_list[2]) == 9)
		if QiuQiuLib.GetPointByID(card_id_list[1] , card_id_list[2]) ~= 9 then
			self.count1_txt.color = Color.New(1,1,1,1)
		else
			self.count1_txt.color = Color.New(255/255,255/255,52/255,255/255)
		end
	end

	self.ad_wait.gameObject:SetActive(false)
	self.ad_confirm.gameObject:SetActive(false)
	if self.data.uiIndex == 1 then
		show_count()
		self.HandCard:RefreshCard(card_id_list,true)
	else
		self.show_card_node.gameObject:SetActive(true)
		self.show_card_list = {}
		for i = 1,#card_id_list do
			local card = QiuQiuCard.Create(self["cardnode"..i],card_id_list[i])
			card:SetBack()
			card.transform.localPosition = Vector3.zero
			card.transform.localEulerAngles = Vector3.zero
			card.transform.localScale = Vector3.New(0.3,0.3,0.3)
			self.show_card_list[#self.show_card_list+1] = card
		end
		local seq = DoTweenSequence.Create()
		for i = 1,#self.show_card_list do
			local card = self.show_card_list[i]
			card:SetBack("ty_gp_d_fm")
			card.transform:SetParent(self["shownode"..i])
			seq:Append(card.transform:DOLocalMove(Vector3.zero,0.3))
			seq:Join(card.transform:DOLocalRotate(Vector3.zero,0.3))
			seq:Join(card.transform:DOScale(Vector3.New(0.5,0.5,0.5),0.3))
			seq:AppendInterval(-0.29)
			if i == #self.show_card_list then
				seq:AppendInterval(0.3)
			end
		end

		for i = 1,#self.show_card_list do
			local card = self.show_card_list[i]
			seq:AppendInterval(0.1)
			seq:AppendCallback(
				function ()
					card:SetMid()
				end
			)
			seq:AppendInterval(0.1)
			seq:AppendCallback(
				function ()
					card:SetNormal()
				end
			)
			if i == #self.show_card_list then
				seq:AppendCallback(
					function ()
						show_count()
					end
				)
			end
		end
	end
end
--重置显示状态
function C:ReSetStatus()
	if self.data.uiIndex == 1 then
		self.HandCard:ClearHandCard()
		self.forecast.gameObject:SetActive(false)
	else
		self.show_card_node.gameObject:SetActive(false)
		self.show_card_list = self.show_card_list or {}
		for i = 1,#self.show_card_list do
			self.show_card_list[i]:MyExit()
		end
		self.show_card_list = {}
	end
	self.count.gameObject:SetActive(false)
	self.d_node.gameObject:SetActive(false)
	self.cd_node.gameObject:SetActive(false)
	self.all_in_node.gameObject:SetActive(false)
	self.ad_wait.gameObject:SetActive(false)
	self.ad_confirm.gameObject:SetActive(false)
	self.evaluate_node.gameObject:SetActive(false)
	self.flod_node.gameObject:SetActive(false)
	self.IsFlod = false
	self.IsAllIn = false
	self.LockRefreshScore = false
	self.Cards = {}
	if self.evaluate_prefab then
		destroy(self.evaluate_prefab)
		self.evaluate_prefab = nil
	end
end

function C:AllIn()
	self.IsAllIn = true
	self.all_in_node.gameObject:SetActive(true)

	local user =  QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
	if user then
		if user.sex == 1 then
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_ALL_IN_boy.audio_name)
		else
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_ALL_IN_girl .audio_name)
		end
	end
end

function C:on_model_nor_qiuqiu_nor_begin_msg()
	if IsEquals(self.ad_confirm) then
		self.ad_confirm.gameObject:SetActive(false)
	end
end

function C:Speak(str)
	self.hint_node.gameObject:SetActive(true)
	self.hint_txt.text = str

	Timer.New(function ()
		if IsEquals(self.hint_node) then
			self.hint_node.gameObject:SetActive(false)
		end
	end,2,1):Start()
	self.cd_node.gameObject:SetActive(false)
end

function C:PlayWaitAdjust()
	if self.IsFlod then
		self.ad_wait.gameObject:SetActive(false)
		self.ad_confirm.gameObject:SetActive(false)
	else
		self.ad_wait.gameObject:SetActive(true)
		self.ad_confirm.gameObject:SetActive(false)
	end
end

function C:PlayConfirmAdjust()
	self.ad_wait.gameObject:SetActive(false)
	self.ad_confirm.gameObject:SetActive(true)
end

function C:AddCard(card)
	if self.data.uiIndex ~= 1 then
		self.Cards = self.Cards or {}
		self.Cards[#self.Cards + 1] = card
	end
end

function C:PlayLvUpAnim()

end

function C:ShowFlod()
	self.flod_node.gameObject:SetActive(true)
	self.IsFlod = true
	if self.data.uiIndex == 1 then
		self.HandCard:ShowMask(true)
		self.forecast.gameObject:SetActive(false)
		Event.Brocast("face_play_xianqi")
	else
		for i = 1,#self.Cards do
			self.Cards[i]:ShowMask(true)
		end
	end
	self.cd_node.gameObject:SetActive(false)
	self.count.gameObject:SetActive(false)
	self.evaluate_node.gameObject:SetActive(false)
end

function C:SetLockRefreshScore(Bool)
	self.LockRefreshScore = Bool
end

--刷新断线重来的数据
function C:RefreshByAllInfo(data)
	local state = tonumber(data.state)
	if state > 0 then
		self.flod_node.gameObject:SetActive(false)
	else
		if QiuQiuModel.data.model_status == QiuQiuModel.Model_Status.gaming then
			self:ShowFlod()
		else
			self.flod_node.gameObject:SetActive(false)
		end
	end

	local all_in = data.all_in
	self.all_in_node.gameObject:SetActive(all_in > 0 and QiuQiuModel.data.model_status == QiuQiuModel.Model_Status.gaming)
	self.IsAllIn = all_in > 0 and QiuQiuModel.data.model_status == QiuQiuModel.Model_Status.gaming
end

function C:on_model_level_data_change(data)
	if data.isLevelUp then
		self:PlayLvUpAnim()
	end
end

function C:OnAssetChange(data)
	if self.data.uiIndex == 1 then
		if not table_is_null(data.data) then
			for k, v in pairs(data.data) do
				if v.asset_type == "shop_gold_sum" then
					if IsEquals(self.rp_txt) then
						CommonAnim.RpAddAnim(self.rp_txt.transform, v.value)
					end
				end
			end
		end
	end
end
