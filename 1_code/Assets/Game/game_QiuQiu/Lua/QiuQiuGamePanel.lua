local basefunc = require "Game/Common/basefunc"

QiuQiuGamePanel = basefunc.class()
local C = QiuQiuGamePanel
C.name = "QiuQiuGamePanel"
local listerRegisterName = "listerRegisterName_QiuQiuGamePanel"
local instance

local Test = false
function C.Create()
	if not instance then
		instance = C.New()
		QiuQiuGamePanel.Instance = instance
		QiuQiuGamePanel.instance = instance
	end
	return instance
end

function C:AddMsgListener()
    QiuQiuLogic.setViewMsgRegister(self.lister, listerRegisterName)
end

function C:MakeLister()
    self.lister = {}
	--all info
	self.lister["model_fast_all_info"] = basefunc.handler(self, self.on_fast_all_info)
	self.lister["AssetChange"] = basefunc.handler(self,self.RefreshAsset)
	--fg msg
    self.lister["model_fast_enter_room_msg"] = basefunc.handler(self, self.on_fast_enter_room_msg)
    self.lister["model_fast_join_msg"] = basefunc.handler(self, self.on_fast_join_msg)
    self.lister["model_fast_ready_msg"] = basefunc.handler(self, self.on_fast_ready_msg)
    self.lister["model_fast_leave_msg"] = basefunc.handler(self, self.on_fast_leave_msg)
	self.lister["model_fast_gameover_msg"] = basefunc.handler(self,self.on_fast_gameover_msg)
    self.lister["model_fast_score_change_msg"] = basefunc.handler(self, self.on_fast_score_change_msg)
	
	--nor msg
    self.lister["model_nor_qiuqiu_nor_begin_msg"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_begin_msg)
	self.lister["model_nor_qiuqiu_nor_ding_zhuang_msg"] = basefunc.handler(self, self.on_nor_qiuqiu_nor_ding_zhuang_msg)
	self.lister["model_nor_qiuqiu_nor_award_msg"] = basefunc.handler(self, self.on_nor_qiuqiu_nor_award_msg)
	self.lister["model_nor_qiuqiu_nor_score_change_msg"] = basefunc.handler(self,self.on_nor_qiuqiu_nor_score_change_msg)
	self.lister["model_nor_qiuqiu_nor_settlement_msg"] = basefunc.handler(self,self.on_nor_qiuqiu_nor_settlement_msg)
	self.lister["model_nor_qiuqiu_nor_auto_msg"] = basefunc.handler(self,self.on_nor_qiuqiu_nor_auto_msg)
	self.lister["model_nor_qiuqiu_nor_pai_msg"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_pai_msg)
	self.lister["model_nor_qiuqiu_nor_stake_permit"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_stake_permit)
	self.lister["model_nor_qiuqiu_nor_adjust_msg"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_adjust_msg)
	self.lister["model_nor_qiuqiu_nor_adjust_permit"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_adjust_permit)
	self.lister["model_nor_qiuqiu_nor_stake_msg"] = basefunc.handler(self,self.on_model_nor_qiuqiu_nor_stake_msg)
	self.lister["qiuqiu_my_card_got"] = basefunc.handler(self,self.on_qiuqiu_my_card_got)

	--fg response
	self.lister["model_fast_ready_response"] = basefunc.handler(self, self.on_fast_ready_response)
	self.lister["model_nor_qiuqiu_nor_auto_msg"] = basefunc.handler(self,self.on_nor_qiuqiu_nor_auto_msg)
	self.lister["model_player_need_exchange_chip"] = basefunc.handler(self,self.on_model_player_need_exchange_chip)
	self.lister["model_player_need_broke"] = basefunc.handler(self,self.on_model_player_need_broke)

	self.lister["fast_huanzhuo_response"] = basefunc.handler(self,self.on_fast_huanzhuo_response)
end

function C:RemoveListener()
    QiuQiuLogic.clearViewMsgRegister(listerRegisterName)
end

function C:MyExit()
	self:RemoveListener()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end

	if self.croupier then
		self.croupier:MyExit()
	end

	if self.taskPanel then
		self.taskPanel:MyExit()
	end

	GameModuleManager.RunFunExt("sys_interactive", "SetCurGamePanel", nil, nil)

	if self.playerList then
		for k, v in pairs(self.playerList) do
			v:MyExit()
		end
	end
	if self.desk then
		self.desk:MyExit()
	end

	instance = nil
	QiuQiuGamePanel.Instance = nil
	CommonAnim.StopCountDown(self.waitCDSeq)
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.croupier = QiuQiuCroupier.Create(self.croupier_node,self.main_card_node)
	self.raise_slider = self.chiplong.transform:Find("Slider"):GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.waitCDSeq = CommonAnim.PlayCountDown(1000,1,self.transform)
	ExtendSoundManager.PlaySceneBGM(audio_config.qiuqiu.qiuqiu_usually_BGM.audio_name)
	self.confirm_adjust_txt.text = GLL.GetTx(20037)
	self.confirm_raise_txt.text = GLL.GetTx(20037)
	self.raise1_txt.text = "5x\n"..GLL.GetTx(20042)
	self.raise2_txt.text = "10x\n"..GLL.GetTx(20042)
	self.raise3_txt.text = "20x\n"..GLL.GetTx(20042)
	self.raise4_txt.text = "50x\n"..GLL.GetTx(20042)
	self.MyBeginChip = QiuQiuModel.GetMyChipNum() or 0

	if AppDefine.IsEDITOR() and Test then
		Network.SendRequest("test_qiuqiu_fix_pais",{data = QiuQiuTest},nil,function (data)
			dump(data,"<color=red>测试数据 +++++++</color>")
		end)
	end

end

function C:InitUI()
	self.quit_btn.onClick:AddListener(function ()
		self:OnClickQuit()
	end)
	self.menu_btn.onClick:AddListener(function ()
		self:OnClickMenu()
	end)
	self.test_btn.onClick:AddListener(
		function ()
			QiuQiuAnim.HuanZhuoAnim(5)
		end
	)

	self.help_btn.onClick:AddListener(
		function ()
			RulesPanel.Create({game = "QIUQIU"})
		end
	)
	self.auto_close_btn.onClick:AddListener(function ()
		self:OnClickAuto()
	end)

	self.playerList = {}

	for i = 1, 7 do
		if i == 1 then
			self.playerList[i] = QiuQiuPlayerMe.New(self, self.player1, {uiIndex = 1})
		else
			self.playerList[i] = QiuQiuPlayerOther.New(self, self["player"..i], {uiIndex = i})
		end
	end
	self.desk = QiuQiuDesk.Create({parent = self.desk_node})
	self:MyRefresh()

	--测试
	self.huanzhuo_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			--如果回合结束后的标志是打开的，那么点击就取消
			if self.huanzhuo_auto.gameObject.activeSelf then
				self.huanzhuo_auto.gameObject:SetActive(false)
				return
			end
			if QiuQiuModel.data.model_status ~= QiuQiuModel.Model_Status.gaming or self.playerList[1].IsFlod then
				local game_id = QiuQiuModel.data.game_id or QiuQiuModel.last_game_id
				local info = MainLogic.GetInfoByGameID(game_id)
				if QiuQiuModel.GetMyChipNum() >= info.chip_min then
					Network.SendRequest("fast_huanzhuo",{force = 1},nil,function (data)
						if data.result ~= 0 then
							LittleTips.Create(GLL.GetTx(20027))
						else
							--重置期盼状态
							Event.Brocast("fast_huanzhuo_response","fast_huanzhuo_response",{result = 0})
						end
					end)
				else
					Network.SendRequest("fast_quit_game",{force = 1},nil,function (data)
						if data.result ~= 0 then
							LittleTips.Create(GLL.GetTx(20027))
						else
							Event.Brocast("fast_quit_game_response","fast_quit_game_response",{result = 0})
						end
					end)
				end
				return
			end
		
			local hitpanel = HintPanel.Create(6,GLL.GetTx(20023),function ()
				if self.playerList and self.playerList[1].IsAllIn then
					HintPanel.Create(1,GLL.GetTx(20043))
				else
					local game_id = QiuQiuModel.data.game_id
					local info = MainLogic.GetInfoByGameID(game_id)
					if QiuQiuModel.GetMyChipNum() >= info.chip_min then
						Network.SendRequest("fast_huanzhuo",{force = 1})
					else
						Network.SendRequest("fast_quit_game",{force = 1},nil,function (data)
							if data.result ~= 0 then
								LittleTips.Create(GLL.GetTx(20027))
							else
								Event.Brocast("fast_quit_game_response","fast_quit_game_response",{result = 0})
							end
						end)
					end
				end
			end,function ()
				LittleTips.Create(GLL.GetTx(20024))
				self.quit_auto.gameObject:SetActive(false)
				self.stand_auto.gameObject:SetActive(false)
				self.huanzhuo_auto.gameObject:SetActive(true)
			end)
			hitpanel:SetButtonText(GLL.GetTx(20019),GLL.GetTx(20020))
		end
	)

	self.sitdown_btn.onClick:AddListener(
		function ()
			local input = self.sitdown_intput.transform:GetComponent("InputField")
			dump(input.text,"<color=red>输入</color>")
			Network.SendRequest("fast_sitdown",{seat_num = tonumber(input.text) or 1})
		end
	)

	self.stand_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			--如果回合结束后的标志是打开的，那么点击就取消
			if self.stand_auto.gameObject.activeSelf then
				self.stand_auto.gameObject:SetActive(false)
				return
			end
			local hitpanel = HintPanel.Create(6,GLL.GetTx(20025),function ()
				Network.SendRequest("fast_stand")
			end,function ()
				LittleTips.Create(GLL.GetTx(20026))
				self.quit_auto.gameObject:SetActive(false)
				self.stand_auto.gameObject:SetActive(true)
				self.huanzhuo_auto.gameObject:SetActive(false)
			end)
			hitpanel:SetButtonText(GLL.GetTx(20019),GLL.GetTx(20020))
		end
	)

	self.confirm_adjust_btn.onClick:AddListener(
		function ()
			local list = self.playerList[1].HandCard:GetOrder()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
			dump(list,"<color=red>调整结果++++++++</color>")
			Network.SendRequest("nor_qiuqiu_nor_adjust",{data = list},"",function (data)
				dump(data,"<color=red> 调整完毕 </color>")
				if IsEquals(self.gameObject) then
					self.not_adjust = false
					local seq = DoTweenSequence.Create()
					seq:Append(self.confirm_control.transform:DOLocalMove(Vector3.New(0,-800,0),0.3))
					Event.Brocast("qiuqiu_nor_adjusted")
					self.cut_down.gameObject:SetActive(false)
				end
			end)
			CommonAnim.StopCountDown(self.adjustAnim)
		end
	)

	self:InitRaisePanel()
	local btn_map = {}
	btn_map["chat"] = {self.chat_node}
	btn_map["acts"] = {self.act_node1, act_node2}
	btn_map["top_right"] = {self.tr_node1, self.tr_node2, self.tr_node3}
	btn_map["left"] = {self.l_node1, self.l_node2}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "qiuqiu", self.transform)
	GameModuleManager.RunFunExt("sys_interactive", "SetCurGamePanel", nil, self)
end
-- 表情功能调用接口
function C:GetPlayerPosByID(id)
	local m_data = QiuQiuModel.data
    if m_data and m_data.players_info then
        for k, v in pairs(m_data.players_info) do
            if v.id == id then
                local uiPos = m_data.s2cSeatNum[ v.seat_num ]
                return self.playerList[uiPos].head_img.transform.position
            end
        end
    end
end

function C:MyRefresh()
	self:RefreshWait()
	self:RefreshPlayer()
	self:RefreshDesk()
end

function C:RefreshWait()
	local m_data = QiuQiuModel.data
    if m_data.model_status == QiuQiuModel.Model_Status.wait_table then
    	self.wait_node.gameObject:SetActive(true)
    else
    	self.wait_node.gameObject:SetActive(false)
    end
end

function C:RefreshPlayer()
	dump(self.playerList,"打印玩家信息")
	for k,v in ipairs(self.playerList or {}) do
		v:MyRefresh()
	end
end

function C:RefreshDesk()
	if self.desk then
		self.desk:MyRefresh()
	end
end

function C:OnClickQuit()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--如果回合结束后的标志是打开的，那么点击就取消
	if self.quit_auto.gameObject.activeSelf then
		self.quit_auto.gameObject:SetActive(false)
		return
	end
	if QiuQiuModel.data.model_status ~= QiuQiuModel.Model_Status.gaming or self.playerList[1].IsFlod  then
		Network.SendRequest("fast_quit_game",{force = 1},nil,function (data)
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(20027))
			else
				Event.Brocast("fast_quit_game_response","fast_quit_game_response",{result = 0})
			end
		end)
		return
	end


	local hitpanel = HintPanel.Create(6,GLL.GetTx(20021),function ()
		if self.playerList and self.playerList[1].IsAllIn then
			HintPanel.Create(1,GLL.GetTx(20043))
		else
			Network.SendRequest("fast_quit_game",{force = 1})
		end
	end,function ()
		LittleTips.Create(GLL.GetTx(20022))
		self.quit_auto.gameObject:SetActive(true)
		self.stand_auto.gameObject:SetActive(false)
		self.huanzhuo_auto.gameObject:SetActive(false)
	end)
	hitpanel:SetButtonText(GLL.GetTx(20019),GLL.GetTx(20020))
end

function C:on_fast_all_info()
	self:MyRefresh()
	local m_data = QiuQiuModel.data
    if m_data.model_status == QiuQiuModel.Model_Status.gameover then
		self:on_fast_gameover_msg()
		local game_id = QiuQiuModel.data.game_id
		local info = MainLogic.GetInfoByGameID(game_id)
		--底分
		local min_stake = info.init_stake
		local min_chip_limit = info.chip_min
		if MainModel.UserInfo.jing_bi > min_chip_limit then
			QiuQiuExchangeChipPanel.Create()
		end
	end

	if m_data.model_status == QiuQiuModel.Model_Status.in_table then
		for k , v in pairs(QiuQiuModel.data.players_info) do
			if v.ready == 1 then
				local Cseatnum = QiuQiuModel.data.s2cSeatNum[v.seat_num]
				self.playerList[Cseatnum]:PlayReady()
			end
		end
	end

	if m_data.model_status ~= QiuQiuModel.Model_Status.in_table then
		self:RefreshControl()
		self.croupier:RefreshByAllInfo()
		QiuQiuDesk.Instance:RefreshByAllInfo()
		QiuQiuChip.RefreshByAllInfo()
		CommonAnim.StopCountDown(self.waitCDSeq)
		self:RefreshAuto()
		QiuQiuModel.data.play_info = QiuQiuModel.data.play_info or {}
		for k , v in pairs(QiuQiuModel.data.play_info) do
			local seat = v.seat_num
			local Cseatnum = QiuQiuModel.data.s2cSeatNum[seat]
			self.playerList[Cseatnum]:RefreshByAllInfo(v)
		end
		if QiuQiuModel.IsMyTurn() and self.playerList[1].IsFlod == false and self.playerList[1].IsAllIn == false then
			self:ControlOnOff(true)
		else
			self:ControlOnOff(false)
		end
	end

	self.desk.bet_txt.text = "Bet:"..StringHelper.ToCash(QiuQiuModel.data.init_stake)
	self.taskPanel = QiuQiuTask.Create(self.task_node)
end

function C:on_fast_enter_room_msg()
	self:MyRefresh()
end

function C:on_fast_join_msg(seat_num)
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[seat_num]
    self.playerList[cSeatNum]:PlayJoin()
end

function C:on_fast_ready_msg(seat_num)
	--座位
	dump(seat_num,"<color=red>有人准备了</color>")
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[seat_num]
	if self.playerList[cSeatNum] then
		self.playerList[cSeatNum]:PlayReady()
	end
end

function C:on_fast_leave_msg(seat_num)
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[seat_num]
	if self.playerList[cSeatNum] then
		self.playerList[cSeatNum]:PlayLeave()
	end
end
--游戏马上开始，正在倒计时
function C:on_model_nor_qiuqiu_nor_begin_msg(data)
	print("<color=red>发牌在"..data.countdown.."秒之后</color>")
	--重置期盼状态
	for i = 1,#self.playerList do
		self.playerList[i]:ReSetStatus()
	end
	--记录游戏开始时，我携带的
	self:RefreshRaisePanel()
	QiuQiuChip.DeskChipToPool()

	self.not_adjust = true
	CommonAnim.StopCountDown(self.waitCDSeq)
	local chip_value_list = QiuQiuChip.GetChipValues(QiuQiuModel.data.init_stake)
	local m_data = QiuQiuModel.data
	dump(m_data.players_info)
    if m_data and m_data.players_info then
        for k, v in pairs(m_data.players_info) do
            local uiPos = m_data.s2cSeatNum[ v.seat_num ]
			for i = 1,#chip_value_list do
				local chip = QiuQiuChip.GetChip(chip_value_list[i])
				QiuQiuChip.DropChipAnimation(chip,uiPos)
			end
        end
		self.MyBeginChip = QiuQiuModel.GetMyChipNum()
		dump(self.MyBeginChip,"<color=red>游戏开始时的筹码</color>")
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
    end
end

function C:on_fast_gameover_msg()

	dump(self.quit_auto.gameObject.activeSelf,"<color=red>游戏结束，是否自动退出</color>")
	if self.quit_auto.gameObject.activeSelf or QiuQiuModel.data.auto_status[QiuQiuModel.data.seat_num] == 1 then
		Network.SendRequest("fast_quit_game")
		return
	end
	if self.waitCDSeq then 
		CommonAnim.StopCountDown(self.waitCDSeq)
	end
	self.waitCDSeq = CommonAnim.PlayCountDown(1000,1,self.transform)
	
	self:HideAllControlPanle()
end

function C:on_fast_score_change_msg(data)
	self.playerList[1]:PlayScoreChange(data.score)
	dump(QiuQiuModel.GetMyChipNum(),"<color=red>当前我的钱</color>")
	dump(self.MyBeginChip,"<color=red>比赛开始时候我的钱</color>")
	dump(QiuQiuModel.data.status,"<color=red>当前的游戏状态</color>")
	if QiuQiuModel.Status.settlement == QiuQiuModel.data.status and QiuQiuModel.GetMyChipNum() > self.MyBeginChip then
		Event.Brocast("face_play_aixin")
	end
end

function C:on_nor_qiuqiu_nor_begin_msg()
	for i, v in ipairs(self.playerList) do

	end
end

function C:RefreshAsset()
	self:RefreshRaisePanel()
end

function C:on_nor_qiuqiu_nor_ding_zhuang_msg(data)
	QiuQiuAnim.ConfirmD(data.zhuang_seat_num)
end

function C:on_model_nor_qiuqiu_nor_pai_msg(data)
	if QiuQiuModel.data.status == QiuQiuModel.Status.fp1 then
		self.croupier:DealCards(data.pai_data,function ()
			self.playerList[1]:RefreshHandCard(data.pai_data)
		end)
	elseif QiuQiuModel.data.status == QiuQiuModel.Status.fp2 then
		self.croupier:DealCards({data.pai_data[4]},function ()
			self.playerList[1]:AddCard(data.pai_data[4])
			local com = QiuQiuLib.GetCombination(self.playerList[1].HandCard)
			local card_type = QiuQiuLib.GetCardTypeByID(com[1])
			dump(card_type,"<color=red>出现了牌型</color>")
			if card_type ~= QiuQiuEnum.CardType.kartuBiasa then
				Event.Brocast("face_play_kaixin")
			end
		end)
	end
end

function C:on_model_nor_qiuqiu_nor_stake_permit(data)
	dump(data,"<color=red>权限信息 ++++++</color>")
	dump(QiuQiuModel.IsMyTurn(),"<color=red>是否轮到我</color>")
	self.raise_panel.gameObject:SetActive(false)
	--如果我弃牌了，下移所有的控制面板

	for k , v in pairs(self.playerList) do
		v:RefreshPermit()
	end

	if self.playerList[1].IsFlod or self.playerList[1].IsAllIn then
		self:HideAllControlPanle()
		return
	end
	if QiuQiuModel.data.isRaised and self.adv_control2_tge.isOn == true then	
		self.adv_control1_tge.isOn = false
		self.adv_control2_tge.isOn = false
		self.adv_control3_tge.isOn = false
	end

	self:RefreshControl()

	dump(self.adv_control1_tge.isOn)
	dump(self.adv_control2_tge.isOn)
	dump(self.adv_control3_tge.isOn)
	if self.adv_control1_tge.isOn or self.adv_control2_tge.isOn or self.adv_control3_tge.isOn then
		if QiuQiuModel.IsMyTurn() then
			self.WaitFunc()
			local seq = DoTweenSequence.Create()
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.3)
			seq:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
			seq:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-307,0),0.3))
			return
		end
	end

	if QiuQiuModel.IsMyTurn() then
		self:ControlOnOff(true)
	else
		self:ControlOnOff(false)
	end
end

function C:on_nor_qiuqiu_nor_award_msg(data)
	dump(data,"<color=red>中途奖励</color>")
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[data.seat_num]
	self.playerList[cSeatNum]:PlayAward(data)
end

function C:on_nor_qiuqiu_nor_score_change_msg(data)
	dump(data,"<color=red>分数改变</color>")
	local seat_num = data.seat_num
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[seat_num]
	if self.playerList[cSeatNum] then
		self.playerList[cSeatNum]:PlayScoreChange()
	end
end

function C:on_nor_qiuqiu_nor_settlement_msg(data)
	dump(data,"<color=red>结算数据</color>")
	local remain_pai = QiuQiuModel.data.settlement_info.remain_pai
	for k , v in pairs(QiuQiuModel.data.players_info) do
		local seat = v.seat_num
		local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
		--调整阶段锁定玩家的筹码刷新
		if self.playerList[Cseat] then
			self.playerList[Cseat]:SetLockRefreshScore(true)
		end
	end
	self.show_card_list = {}
	local actPlayerNum = QiuQiuCroupier.GetActPlayerNum()

	if actPlayerNum > 1 then
		for i = 1,#remain_pai do
			local seat = remain_pai[i].seat_num
			local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
			dump(Cseat,"<color=red>当前的座位号</color>")
			dump(self.playerList[Cseat].IsFlod,"<color=red>当前的座位号是否弃牌了</color>")
			local need_paly_audio = false
			if self.playerList[Cseat].IsFlod == false then
				QiuQiuCroupier.Instance:HideOtherCard()
				self.playerList[Cseat]:ShowCard(remain_pai[i].pai)
				need_paly_audio = true
			end
			if need_paly_audio then
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_show_card.audio_name)
			end
		end
	end
	
	Timer.New(function ()
		self:DivideAward(data.settlement_info.pool)
	end,2,1):Start()
end

function C:DivideAward(pool_data)
	
	QiuQiuChip.DivideChips(pool_data,function ()
		--重置期盼状态
		if self.playerList then
			for i = 1,#self.playerList do
				self.playerList[i]:ReSetStatus()
			end
		end
	end)
end

function C:on_nor_qiuqiu_nor_auto_msg(data)
	dump(data,"<color=red>玩家进入托管</color>")
	local cSeatNum = QiuQiuModel.data.s2cSeatNum[data.p]
	self.playerList[cSeatNum]:PlayAuto(data)
	self:RefreshAuto()
end

function C:on_fast_ready_response()
    self:MyRefresh()
end

--弹出或者隐藏底部面板
function C:ControlOnOff(OnOrOff)
	if OnOrOff then
		local seq = DoTweenSequence.Create()
		seq:Append(self.control.transform:DOLocalMove(Vector3.New(0,-307,0),0.3))
	else
		local seq = DoTweenSequence.Create()
		seq:Append(self.control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
	end

	if not OnOrOff then
		local seq = DoTweenSequence.Create()
		seq:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-307,0),0.3))
	else
		local seq = DoTweenSequence.Create()
		seq:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
	end

	local seq3 = DoTweenSequence.Create()
	seq3:Append(self.confirm_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
end

--刷新控制面板
function C:RefreshControl()
	local state = 2
	--没有人加注
	if QiuQiuModel.data.last_stake == 0 then
		state = 1
	end

	-- 当玩家轮到自己操作的时候且没有玩家加注
	if state == 1 then
		self.control1_txt.text = GLL.GetTx(20034)
		self.control2_txt.text = GLL.GetTx(20032)
		--钱多就加注
		if QiuQiuModel.GetMyChipNum() > QiuQiuModel.data.last_stake + QiuQiuModel.data.init_stake * 2 then
			self.control3_txt.text = GLL.GetTx(20036)
		else
			self.control3_txt.text = "ALL IN"
		end

		self.control1_btn.onClick:RemoveAllListeners()
		self.control2_btn.onClick:RemoveAllListeners()
		self.control3_btn.onClick:RemoveAllListeners()

		self.control1_btn.onClick:AddListener(
			function ()
				--ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
				self:Flod()
			end
		)
		self.control2_btn.onClick:AddListener(
			function ()
				--ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
				self:Check()
			end
		)
		self.control3_btn.onClick:AddListener(
			function ()
				--钱多就加注
				--
				if QiuQiuModel.GetMyChipNum() > QiuQiuModel.data.last_stake + QiuQiuModel.data.init_stake * 2 then
					ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
					self.raise_slider.value = 1
					self:RefreshRaisePanel()
					self.raise_panel.gameObject:SetActive(true)
				else
					Network.SendRequest("nor_qiuqiu_nor_stake",{stake = QiuQiuModel.GetMyChipNum()},function (data)
						dump(data,"<color=red>加注</color>")
						if data.result == 0 then
							self.adv_control2_txt.text = GLL.GetTx(20032)
							self.adv_control2_tge.isOn = false
							self:ControlOnOff(false)
						end
					end)
				end
			end
		)
	elseif state == 2 then
	-- 当玩家轮到自己操作的时候且有玩家加注
		self.control1_txt.text = GLL.GetTx(20034)

		if StringHelper.ToCash(self:GetCallValue()) == "0" then
			self.control2_txt.text = GLL.GetTx(20032)
		else
			self.control2_txt.text = GLL.GetTx(20035).."\n" ..StringHelper.ToCash(self:GetCallValue())
		end
		--钱多就加注
		if QiuQiuModel.GetMyChipNum() > QiuQiuModel.data.last_stake + QiuQiuModel.data.init_stake * 2 then
			self.control3_txt.text = GLL.GetTx(20036)
		else
			self.control3_txt.text = "ALL IN"
		end

		self.control1_btn.onClick:RemoveAllListeners()
		self.control2_btn.onClick:RemoveAllListeners()
		self.control3_btn.onClick:RemoveAllListeners()

		self.control1_btn.onClick:AddListener(
			function ()
				--ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
				self:Flod()
			end
		)
		
		self.control2_btn.onClick:AddListener(
			function ()
				--ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
				self:Call()
			end
		)
		self.control3_btn.onClick:AddListener(
			function ()
				--钱多就加注
				--
				if QiuQiuModel.GetMyChipNum() > QiuQiuModel.data.last_stake + QiuQiuModel.data.init_stake * 2 then
					ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
					self.raise_slider.value = 1
					self:RefreshRaisePanel()
					self.raise_panel.gameObject:SetActive(true)
				else
					Network.SendRequest("nor_qiuqiu_nor_stake",{stake = QiuQiuModel.GetMyChipNum()},function (data)
						dump(data,"<color=red>加注</color>")
						if data.result == 0 then
							self.adv_control2_txt.text = GLL.GetTx(20032)
							self.adv_control2_tge.isOn = false
							self:ControlOnOff(false)
						end	
					end)
				end
			end
		)
	end
	
	self.adv_control1_tge.onValueChanged:RemoveAllListeners()
	self.adv_control2_tge.onValueChanged:RemoveAllListeners()
	self.adv_control3_tge.onValueChanged:RemoveAllListeners()

	self.adv_control1_btn.onClick:RemoveAllListeners()
	self.adv_control2_btn.onClick:RemoveAllListeners()
	self.adv_control3_btn.onClick:RemoveAllListeners()


	self.adv_control1_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
			self.adv_control1_tge.isOn = not self.adv_control1_tge.isOn
		end
	)
	self.adv_control2_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
			self.adv_control2_tge.isOn = not self.adv_control2_tge.isOn
		end
	)
	self.adv_control3_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
			self.adv_control3_tge.isOn = not self.adv_control3_tge.isOn
		end
	)

	if state == 1 then
	-- 当其他玩家操作 且没有玩家加注
		self.adv_control1_txt.text = GLL.GetTx(20031)
		self.adv_control2_txt.text = GLL.GetTx(20032)
		self.adv_control3_txt.text = GLL.GetTx(20033)

		self.adv_control1_tge.onValueChanged:AddListener(
			function (isOn)
				if isOn then
					ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
					self.WaitFunc = function ()
						if QiuQiuModel.data.last_stake == 0 then
							self:Check()
						else
							self:Flod()
						end
						self.adv_control1_tge.isOn = false
					end
				end
			end
		)
		self.adv_control2_tge.onValueChanged:AddListener(
			function (isOn)
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
				if isOn then
					self.WaitFunc = function ()
						self:Check()
						self.adv_control2_tge.isOn = false
					end
				end
			end
		)
		self.adv_control3_tge.onValueChanged:AddListener(
			function (isOn)
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
				if isOn then
					self.WaitFunc = function ()
						self:Call()
						local seq = DoTweenSequence.Create()
						self.adv_control3_tge.isOn = false
					end
				end
			end
		)

	elseif state == 2 then
		self.adv_control1_txt.text = GLL.GetTx(20031)
		if StringHelper.ToCash(self:GetCallValue()) == "0" then
			self.adv_control2_txt.text = GLL.GetTx(20032)
		else
			self.adv_control2_txt.text = GLL.GetTx(20035).."\n" ..StringHelper.ToCash(self:GetCallValue())
		end
		self.adv_control3_txt.text = GLL.GetTx(20033)
		self.adv_control1_tge.onValueChanged:RemoveAllListeners()
		self.adv_control2_tge.onValueChanged:RemoveAllListeners()
		self.adv_control3_tge.onValueChanged:RemoveAllListeners()

		self.adv_control1_tge.onValueChanged:AddListener(
			function (isOn)
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
				if isOn then
					self.WaitFunc = function ()
						if QiuQiuModel.data.last_stake == 0 then
							self:Check()
						else
							self:Flod()
						end
						self.adv_control1_tge.isOn = false
					end
				end
			end
		)
		self.adv_control2_tge.onValueChanged:AddListener(
			function (isOn)
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
				if isOn then
					self.WaitFunc = function ()
						self:Call()
						self.adv_control2_tge.isOn = false
					end
				end
			end
		)
		self.adv_control3_tge.onValueChanged:AddListener(
			function (isOn)
				ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
				if isOn then
					self.WaitFunc = function ()
						self:Call()
						self.adv_control3_tge.isOn = false
					end
				end
			end
		)
	end
end

--弃牌
function C:Flod()
	Network.SendRequest("nor_qiuqiu_nor_stake",{stake = -1},"",function (data)
		dump(data,"<color=red>弃牌</color>")
		if IsEquals(self.gameObject) then
			local seq = DoTweenSequence.Create()
			seq:Append(self.control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
			local seq2 = DoTweenSequence.Create()
			seq2:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
		end
	end)
end

--过牌
function C:Check()
	Network.SendRequest("nor_qiuqiu_nor_stake",{stake = 0},"",function (data)
		dump(data,"<color=red>过牌</color>")
		if data.result == 0 and IsEquals(self.gameObject) then
			self.adv_control2_txt.text = GLL.GetTx(20032)
			self.adv_control2_tge.isOn = false
			self:ControlOnOff(false)
		end	
	end)
end

--跟注
function C:Call()
	dump(self:GetCallValue(),"<color=red> 当前使用的金额 </color>")
	Network.SendRequest("nor_qiuqiu_nor_stake",{stake = self:GetCallValue()},"",function (data)
		dump(data,"<color=red>跟注</color>")
		if data.result == 0 then
			if IsEquals(self.gameObject) then
				self.adv_control2_txt.text = GLL.GetTx(20032)
				self.adv_control2_tge.isOn = false
				self:ControlOnOff(false)
			end
		end	
	end)
end

--发牌完成
function C:on_qiuqiu_my_card_got()
	self:RefreshControl()
end


function C:on_model_nor_qiuqiu_nor_adjust_msg(data)
	dump(data,"<color=red>确认消息</color>")
	local seat = data.seat_num
	local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
	self.playerList[Cseat]:PlayConfirmAdjust()
	self.playerList[Cseat]:SetLockRefreshScore(true)

	if seat == QiuQiuModel.data.seat_num then
		self:HideAllControlPanle()
	end
end

--开始调整牌 然后准备比大小
function C:on_model_nor_qiuqiu_nor_adjust_permit(data)
	dump(data,"<color=red>调整牌的阶段</color>")

	for k , v in pairs(QiuQiuModel.data.players_info) do
		local seat = v.seat_num
		local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
		if self.playerList[Cseat] then
			self.playerList[Cseat]:PlayWaitAdjust()
			--调整阶段锁定玩家的筹码刷新
			self.playerList[Cseat]:SetLockRefreshScore(true)
		end
	end
	local seq = DoTweenSequence.Create()
	seq:Append(self.control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
	local seq2 = DoTweenSequence.Create()
	seq2:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
	local seq3 = DoTweenSequence.Create()
	seq3:Append(self.confirm_control.transform:DOLocalMove(Vector3.New(0,-307,0),0.3))

	if not (QiuQiuModel.data.auto_status[QiuQiuModel.data.seat_num] == 1) then
		self.cut_down.gameObject:SetActive(true)
		self.adjustAnim = CommonAnim.PlayCountDown(data.countdown - 1,0,self.cut_down_node,function ()
		if self.not_adjust then
			local list = self.playerList[1].HandCard:GetOrder()
			dump(list,"<color=red>调整结果++++++++</color>")
				Network.SendRequest("nor_qiuqiu_nor_adjust",{data = list},"",function (data)
					dump(data,"<color=red> 调整完毕 </color>")
					if IsEquals(self.gameObject) then
						local seq = DoTweenSequence.Create()
						seq:Append(self.confirm_control.transform:DOLocalMove(Vector3.New(0,-800,0),0.3))
						Event.Brocast("qiuqiu_nor_adjusted")
						self.cut_down.gameObject:SetActive(false)
					end					
				end)
			end
		end,"CommonCD_QiuQiu",audio_config.qiuqiu.qiuqiu_countdown.audio_name)
	end
end
--有人说话
function C:on_model_nor_qiuqiu_nor_stake_msg(data)
	dump(data,"<color=red>有人说话</color>")
	local seat = data.seat_num
	local Cseat = QiuQiuModel.data.s2cSeatNum[seat]
	local stake = data.stake
	self.raise_panel.gameObject:SetActive(false)
	local chip_value_list = QiuQiuChip.GetChipValues(stake)
	local chip_list = {}
	for i = 1,#chip_value_list do
		local chip = QiuQiuChip.GetChip(chip_value_list[i])
		QiuQiuChip.DropChipAnimation(chip,Cseat)
	end
	self:RefreshRaisePanel()

	if data.all_in > 0 then
		self.playerList[Cseat]:Speak(StringHelper.ToCash(QiuQiuModel.GetTotalStakeByCseat(Cseat)))
		self.playerList[Cseat]:AllIn()
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
		return
	end

	if data.stake == -1 then
		self.playerList[Cseat]:Speak( GLL.GetTx(20034))
		self.playerList[Cseat]:ShowFlod()
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_flod.audio_name)
	end

	if data.stake == 0 then
		self.playerList[Cseat]:Speak(GLL.GetTx(20032))
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_check.audio_name)
	end

	if data.stake > 0 then
		if QiuQiuModel.data.isRaised == false then
			self.playerList[Cseat]:Speak(GLL.GetTx(20035)..": "..StringHelper.ToCash(QiuQiuModel.GetTotalStakeByCseat(Cseat)))
		else
			self.playerList[Cseat]:Speak(GLL.GetTx(20036)..": "..StringHelper.ToCash(QiuQiuModel.GetTotalStakeByCseat(Cseat)))
		end
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
	end
end

function C:OnClickMenu()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local activeSelf = not self.btns_node.gameObject.activeSelf
	self.btns_node.gameObject:SetActive(activeSelf)

	if activeSelf then
		--显示的时候动画表现
		QiuQiuAnim.ShowMenuBtns(self.btn_bg_img,self.quit_btn,self.stand_btn,self.huanzhuo_btn,self.help_btn)
	end
end


--加注功能
function C:InitRaisePanel()
	self.curr_raise_value = 1
	self.raise_slider.onValueChanged:AddListener(
		function ()
			local value = self.raise_slider.value
			for i = 1,20 do
				self["chip"..i].gameObject:SetActive(i <= value)
			end
			self.curr_raise_value = value
			local min = QiuQiuModel.data.init_stake * 2 + QiuQiuModel.data.last_stake
			local max = QiuQiuModel.GetMyChipNum()

			dump(min)
			dump(max,"<color=red>最大值+++++++</color>")
			if self.curr_raise_value == 1 then
				self.raise_all_in.gameObject:SetActive(false)
				self.curr_raise_txt.gameObject:SetActive(true)
				self.curr_raise_txt.text = StringHelper.ToCash(min)
				self.raise_value = min
			elseif self.curr_raise_value == 20 then
				self.raise_all_in.gameObject:SetActive(true)
				self.curr_raise_txt.gameObject:SetActive(false)
				self.raise_value = max
			else
				self.raise_all_in.gameObject:SetActive(false)
				self.curr_raise_txt.gameObject:SetActive(true)
				local value = math.floor( (max - min) / (20 - 1) * (self.curr_raise_value  - 1) + min)	
				self.curr_raise_txt.text = StringHelper.ToCash(value)
				self.raise_value = value
			end
		end
	)
	self.raise1_btn.onClick:AddListener(
		function ()
			local stake = 5 * QiuQiuModel.data.init_stake
			Network.SendRequest("nor_qiuqiu_nor_stake",{stake = stake},function (data)
				dump(data,"<color=red>加注</color>")
				if data.result == 0 then
					self.adv_control2_txt.text = GLL.GetTx(20032)
					self.adv_control2_tge.isOn = false
					self:ControlOnOff(false)
				end	
			end)
			self.raise_panel.gameObject:SetActive(false)
		end
	)
	self.raise2_btn.onClick:AddListener(
		function ()
			local stake = 10 * QiuQiuModel.data.init_stake
			Network.SendRequest("nor_qiuqiu_nor_stake",{stake = stake},function (data)
				dump(data,"<color=red>加注</color>")
				if data.result == 0 then
					self.adv_control2_txt.text = GLL.GetTx(20032)
					self.adv_control2_tge.isOn = false
					self:ControlOnOff(false)
				end	
			end)
			self.raise_panel.gameObject:SetActive(false)
		end
	)
	self.raise3_btn.onClick:AddListener(
		function ()
			local stake = 20 * QiuQiuModel.data.init_stake
			Network.SendRequest("nor_qiuqiu_nor_stake",{stake = stake},function (data)
				dump(data,"<color=red>加注</color>")
				if data.result == 0 then
					self.adv_control2_txt.text = GLL.GetTx(20032)
					self.adv_control2_tge.isOn = false
					self:ControlOnOff(false)
				end	
			end)
			self.raise_panel.gameObject:SetActive(false)
		end
	)
	self.raise4_btn.onClick:AddListener(
		function ()
			local stake = 50 * QiuQiuModel.data.init_stake
			Network.SendRequest("nor_qiuqiu_nor_stake",{stake = stake},function (data)
				dump(data,"<color=red>加注</color>")
				if data.result == 0 then
					self.adv_control2_txt.text = GLL.GetTx(20032)
					self.adv_control2_tge.isOn = false
					self:ControlOnOff(false)
				end	
			end)
			self.raise_panel.gameObject:SetActive(false)
		end
	)
	self.close_raise_btn.onClick:AddListener(
		function ()
			self.raise_panel.gameObject:SetActive(false)
		end
	)
	self.confirm_raise_btn.onClick:AddListener(
		function ()
			self.raise_panel.gameObject:SetActive(false)
			Network.SendRequest("nor_qiuqiu_nor_stake",{stake = self.raise_value},function (data)
				dump(data,"<color=red>加注</color>")
				if data.result == 0 then
					self.adv_control2_txt.text = GLL.GetTx(20032)
					self.adv_control2_tge.isOn = false
					self:ControlOnOff(false)
				end	
			end)
		end
	)
end

--资产改变后刷新一下这个面板
function C:RefreshRaisePanel()
	
	if not QiuQiuModel.data.init_stake then return end

	local stake = 5 * QiuQiuModel.data.init_stake
	if QiuQiuModel.GetMyChipNum() >= stake and stake >= QiuQiuModel.data.last_stake + 2 * QiuQiuModel.data.init_stake then
		self.raise1_mask.gameObject:SetActive(false)
	else
		self.raise1_mask.gameObject:SetActive(true)
	end
	local stake = 10 * QiuQiuModel.data.init_stake
	if QiuQiuModel.GetMyChipNum() >= stake and stake >= QiuQiuModel.data.last_stake + 2 * QiuQiuModel.data.init_stake then
		self.raise2_mask.gameObject:SetActive(false)
	else
		self.raise2_mask.gameObject:SetActive(true)
	end
	local stake = 20 * QiuQiuModel.data.init_stake
	if QiuQiuModel.GetMyChipNum() >= stake and stake >= QiuQiuModel.data.last_stake + 2 * QiuQiuModel.data.init_stake then
		self.raise3_mask.gameObject:SetActive(false)
	else
		self.raise3_mask.gameObject:SetActive(true)
	end
	local stake = 50 * QiuQiuModel.data.init_stake
	if QiuQiuModel.GetMyChipNum() >= stake and stake >= QiuQiuModel.data.last_stake + 2 * QiuQiuModel.data.init_stake then
		self.raise4_mask.gameObject:SetActive(false)
	else
		self.raise4_mask.gameObject:SetActive(true)
	end

	self.top_value_txt.text = StringHelper.ToCash(QiuQiuModel.GetMyChipNum())
	local min = QiuQiuModel.data.init_stake * 2 + QiuQiuModel.data.last_stake
	local max = QiuQiuModel.GetMyChipNum()
	self.curr_raise_value = self.curr_raise_value or 1
	self.raise_slider.value = self.curr_raise_value
	if self.curr_raise_value == 1 then
		self.raise_all_in.gameObject:SetActive(false)
		self.curr_raise_txt.gameObject:SetActive(true)
		self.curr_raise_txt.text = StringHelper.ToCash(min)
		self.raise_value = min
	elseif self.curr_raise_value == 20 then
		self.raise_all_in.gameObject:SetActive(true)
		self.curr_raise_txt.gameObject:SetActive(false)
		self.raise_value = max
	else
		self.raise_all_in.gameObject:SetActive(false)
		self.curr_raise_txt.gameObject:SetActive(true)
		local value = math.floor( (max - min) / (20 - 1) * (self.curr_raise_value  - 1) + min)
		self.curr_raise_txt.text = StringHelper.ToCash(value)
		self.raise_value = value
	end
end
--获取当前跟注所需要的值
function C:GetCallValue()
	local v =  QiuQiuModel.GetTotalMaxStake() - QiuQiuModel.GetMyTotalStake()
	if QiuQiuModel.GetMyChipNum() < v then
		v = QiuQiuModel.GetMyChipNum()
	end
	return v
end

--下移所有的面板
function C:HideAllControlPanle()
	local seq = DoTweenSequence.Create()
	seq:Append(self.control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))

	local seq2 = DoTweenSequence.Create()
	seq2:Append(self.advance_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))

	local seq3 = DoTweenSequence.Create()
	seq3:Append(self.confirm_control.transform:DOLocalMove(Vector3.New(0,-415,0),0.3))
end

function C:OnClickAuto()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not QiuQiuModel or not QiuQiuModel.data or not QiuQiuModel.data.seat_num then
		return
	end
	local operate = QiuQiuModel.data.auto_status[QiuQiuModel.data.seat_num]
	if not operate then
		operate = 0
	end
	local data = {}
	if operate == 0 then
		data.operate = 1
	elseif operate == 1 then
		data.operate = 0
	end

	Network.SendRequest("nor_qiuqiu_nor_auto",data)
end

function C:RefreshAuto()
	if not QiuQiuModel or not QiuQiuModel.data or not QiuQiuModel.data.seat_num then
		self.auto_node.gameObject:SetActive(false)
		return
	end
	local operate = QiuQiuModel.data.auto_status[QiuQiuModel.data.seat_num]
	if not operate or operate == 0 then
		self.auto_node.gameObject:SetActive(false)
		return
	end
	self.auto_node.gameObject:SetActive(true)
end

function C:on_model_player_need_exchange_chip()
	self:OpenExchangePanel()
end

function C:OpenExchangePanel()
	local game_id = QiuQiuModel.data.game_id
	local info = MainLogic.GetInfoByGameID(game_id)
	--底分
	local min_stake = info.init_stake
	local min_chip_limit = info.chip_min
	dump(min_stake)
	dump(QiuQiuModel.GetMyChipNum(),"<color=red>当前我的筹码</color>")
	dump(min_chip_limit,"<color=red>最小限制</color>")
	dump(MainModel.UserInfo.jing_bi,"<color=red>我的总金额</color>")

	--当所携带的筹码在对局中输掉，使得当前携带筹码数低于场次的底分时，玩家会自动起身
	if QiuQiuModel.GetMyChipNum() < min_chip_limit then
		--Network.SendRequest("fast_stand")		
		--若玩家的总金额数大于场次最低携带筹码，则会弹出筹码兑换界面；若玩家的总金额数小于最低携带筹码，则会将玩家踢出当前场次
		if MainModel.UserInfo.jing_bi > min_chip_limit then
			if QiuQiuExchangeChipPanel.Auto then
				QiuQiuExchangeChipPanel.AutoExChange()
			else
				QiuQiuExchangeChipPanel.Create()
			end
		else
			--Network.SendRequest("fast_quit_game")
		end
	end
	-- --临时弥补一下
	-- if MainModel.UserInfo.jing_bi > min_chip_limit then
	-- 	QiuQiuExchangeChipPanel.Create()
	-- end
end

function C:on_fast_huanzhuo_response()
	for i = 1,#self.playerList do
		self.playerList[i]:ReSetStatus()
	end
	QiuQiuChip.DeskChipToPool()
end

function C:on_model_player_need_broke()
	self:TryToBroke()
end

--尝试走破产流程
function C:TryToBroke()
	local game_id = QiuQiuModel.data.game_id
	local info = MainModel.GetInfoByGameID(game_id)
	--如果玩家不满足当前场次的条件
	if MainModel.UserInfo.jing_bi < info.limit_min then
		local create_hintpanel = nil
		create_hintpanel = function ()
			local b = HintPanel.Create(2,GLL.GetTx(80054),function ()
				--换桌
				local game_id = QiuQiuModel.data.game_id
				local info = MainModel.GetInfoByGameID(game_id)
	
				if MainModel.UserInfo.jing_bi < info.limit_min then
					SysBrokeSubsidyManager.RunBrokeProcess()
					create_hintpanel()
				else
					QiuQiuExchangeChipPanel.AutoExChange()
					Network.SendRequest("fast_huanzhuo",{force = 1},nil,function (data)
						if data.result ~= 0 then
							LittleTips.Create(GLL.GetTx(20027))
							create_hintpanel()
						else
							--重置期盼状态
							Event.Brocast("fast_huanzhuo_response","fast_huanzhuo_response",{result = 0})
						end
					end)
				end
			end,function ()
				-- local game_id = QiuQiuModel.data.game_id
				-- local info = MainModel.GetInfoByGameID(game_id)
				-- if MainModel.UserInfo.jing_bi < info.limit_min then
				-- 	SysBrokeSubsidyManager.RunBrokeProcess()
				-- end
				Network.SendRequest("fast_quit_game",{force = 1},nil,function (data)
					if data.result ~= 0 then
						LittleTips.Create(GLL.GetTx(20027))
					else
						Event.Brocast("fast_quit_game_response","fast_quit_game_response",{result = 0})
					end
				end)
	
			end,nil,nil,nil,GameObject.Find("Canvas/LayerLv3"))
	
			b.transform:GetComponent("Canvas").sortingOrder = 2	
			b:SetButtonText(GLL.GetTx(60014),GLL.GetTx(60015))
		end
		SysBrokeSubsidyManager.RunBrokeProcess()
		create_hintpanel()
	end
	
end