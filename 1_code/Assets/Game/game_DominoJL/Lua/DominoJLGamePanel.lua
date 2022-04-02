-- 创建时间:2021-11-08
-- Panel:DominoJLGamePanel
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

DominoJLGamePanel = basefunc.class()
local C = DominoJLGamePanel
C.name = "DominoJLGamePanel"
local listerRegisterName = "listerRegisterName_DominoJLGamePanel"
local instance
function C.Create()
	if not instance then
		instance = C.New()
		DominoJLGamePanel.Instance = instance
	end
	return instance
end

function C:AddMsgListener()
    DominoJLLogic.setViewMsgRegister(self.lister, listerRegisterName)
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_fg_join_msg"] = basefunc.handler(self, self.on_fg_join_msg)
    self.lister["model_fg_leave_msg"] = basefunc.handler(self, self.on_fg_leave_msg)
    self.lister["model_fg_score_change_msg"] = basefunc.handler(self, self.on_fg_score_change_msg)
    self.lister["model_fg_ready_msg"] = basefunc.handler(self, self.on_fg_ready_msg)

    self.lister["model_fg_enter_room_msg"] = basefunc.handler(self, self.on_fg_enter_room_msg)
    self.lister["model_nor_dmn_nor_pai_msg"] = basefunc.handler(self, self.on_nor_dmn_nor_pai_msg)
    self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_fg_all_info)
    self.lister["model_fg_ready_response"] = basefunc.handler(self, self.on_fg_ready_response)
    self.lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.on_fg_huanzhuo_response)
	self.lister["model_fg_quit_game_response"] = basefunc.handler(self,self.on_fg_quit_game_response)
	
	self.lister["model_nor_dmn_nor_cp_response"] = basefunc.handler(self,self.nor_dmn_nor_cp_response)
	self.lister["model_nor_dmn_nor_begin_msg"] = basefunc.handler(self, self.on_nor_dmn_nor_begin_msg)
	self.lister["model_nor_dmn_nor_ding_zhuang_msg"] = basefunc.handler(self, self.on_nor_dmn_nor_ding_zhuang_msg)
	self.lister["model_nor_dmn_nor_cp_permit"] = basefunc.handler(self, self.on_nor_dmn_nor_cp_permit)
	self.lister["model_nor_dmn_nor_cp_msg"] = basefunc.handler(self, self.on_nor_dmn_nor_cp_msg)

	--分数结算
	self.lister["model_nor_dmn_nor_settlement_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_settlement_msg)
	self.lister["model_nor_dmn_nor_score_change_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_score_change_msg)

	self.lister["model_fg_gameover_msg"] = basefunc.handler(self,self.on_fg_gameover_msg)
	self.lister["model_nor_dmn_nor_auto_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_auto_msg)
	self.lister["model_nor_dmn_nor_auto_response"] = basefunc.handler(self,self.on_nor_dmn_nor_auto_response)
	
	--其他
	self.lister["model_level_score_change"] = basefunc.handler(self,self.on_level_score_change)
	
	
	self.lister["model_AssetChange"] = basefunc.handler(self,self.on_model_AssetChange)
	self.lister["model_reset_data"] = basefunc.handler(self,self.on_model_reset_data)

end

function C:RemoveListener()
    DominoJLLogic.clearViewMsgRegister(listerRegisterName)
end

function C:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	if self.seqSettlement then
		self.seqSettlement:Kill()
	end
	self.seqSettlement = nil
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end

	if self.actDominoTaskEnter then
		self.actDominoTaskEnter:MyExit()
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

	if self.cardGroup then
		self.cardGroup:MyExit()
	end

	if self.cardCount then
		self.cardCount:MyExit()
	end

	CommonAnim.StopCountDown(self.waitCDSeq)
	-- destroy(self.gameObject)
	instance = nil
	DominoJLGamePanel.Instance = nil
	ClearTable(self)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	self.dot_del_obj = true
	ExtPanel.ExtMsg(self)
	DominoJLGamePanel.Instance = self
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	ExtendSoundManager.PlaySceneBGM(audio_config.domino.bgm_duominuo_bj.audio_name)
	self.actDominoTaskEnter = GameManager.GotoUI({gotoui = "act_domino_task", goto_scene_parm = "enter", parent = self.act_domino_task})
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.menu_btn.onClick:AddListener(function ()
		-- if true then
		-- 	DominoJLAnim.PlayHint(self.playerList[1].hint_node)
		-- 	return
		-- end
		self:OnClickMenu()
	end)

	self.quit_btn.onClick:AddListener(function ()
		self:OnClickQuit()
		self.btns_node.gameObject:SetActive(false)
	end)

	self.get_up_btn.onClick:AddListener(function ()
		self:OnClickGetUp()
	end)

	self.change_btn.onClick:AddListener(function ()
		self:OnClickChange()
	end)

	self.help_btn.onClick:AddListener(function ()
		self:OnClickHelp()
	end)

	self.auto_close_btn.onClick:AddListener(function ()
		self:OnClickAuto()
	end)
end

function C:RemoveListenerGameObject()
	self.menu_btn.onClick:RemoveAllListeners()
	self.quit_btn.onClick:RemoveAllListeners()
	self.get_up_btn.onClick:RemoveAllListeners()
	self.change_btn.onClick:RemoveAllListeners()
	self.help_btn.onClick:RemoveAllListeners()
	self.auto_close_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
	self.desk = DominoJLDesk.Create({parent = self.desk_node})
	self.cardGroup = DominoJLCardGroup.Create()
	self.cardCount = DominoJLCardCount.Create()

	self.auto_txt.text = GLL.GetTx(60009)
	

	local btn_map = {}
	btn_map["chat"] = {self.chat_node}
	btn_map["acts"] = {self.act_node1, self.act_node2}
	btn_map["left"] = {self.l_node1, self.l_node2}
	btn_map["top_right"] = {self.tr_node1, self.tr_node2, self.tr_node3}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "dominojl", self.transform)

	self.playerList = {}
	self.playerList[1] = DominoJLPlayerMe.New(self, self.player1, {uiIndex = 1})
	self.playerList[2] = DominoJLPlayerOther.New(self, self.player2, {uiIndex = 2})
	self.playerList[3] = DominoJLPlayerOther.New(self, self.player3, {uiIndex = 3})
	self.playerList[4] = DominoJLPlayerOther.New(self, self.player4, {uiIndex = 4})

	self:MyRefresh()
	GameModuleManager.RunFunExt("sys_interactive", "SetCurGamePanel", nil, self)
end
-- 表情功能调用接口
function C:GetPlayerPosByID(id)
	local m_data = DominoJLModel.data
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
	local m_data = DominoJLModel.data
    if m_data.model_status == DominoJLModel.Model_Status.wait_table
	or m_data.model_status == DominoJLModel.Model_Status.wait_begin
	then
    	self.wait_node.gameObject:SetActive(true)
		CommonAnim.StopCountDown(self.waitCDSeq)
		-- self.waitCDSeq = CommonAnim.PlayCountDown(1000,1,DominoJLGamePanel.Instance.ani_node)
		self:RefreshPlayerInfo()
    else
    	self.wait_node.gameObject:SetActive(false)
		CommonAnim.StopCountDown(self.waitCDSeq)
    	self:RefreshPlayerInfo()
    end

	if self.desk then
		self.desk:MyRefresh()
	end

	if self.cardGroup then
		self.cardGroup:MyRefresh()
	end


	if self.cardCount then
		self.cardCount:MyRefresh()
	end

	self:RefreshBet()
	self:RefreshAuto()
	self:RefreshClear()
end

function C:RefreshClear()
	local m_data = DominoJLModel.data
	if m_data.model_status ~= DominoJLModel.Model_Status.gaming
	or m_data.status ~= DominoJLModel.Status.settlement then
		DominoJLBetClear.Close()
		return
	end
	local game_name = MainLogic.GetGameTypeByGameID(DominoJLModel.data.game_id) 
	if game_name == "domino_bet" then
		DominoJLBetClear.Create(DominoJLModel.data)
	else
		DominoJLClear.Create(DominoJLModel.data)
	end

	self:SettlementCloseState()
end

function C:RefreshPlayerInfo(pSeatNum)
	if pSeatNum then
		self.playerList[pSeatNum]:MyRefresh()
	else
	    for k,v in ipairs(self.playerList) do
			v:MyRefresh()
	    end
	end
end

function C:RefreshScore(CSeatNum)
	if CSeatNum and self.playerList then
		self.playerList[CSeatNum]:RefreshScore()
		return
	end
	for k,v in pairs(self.playerList)  do
		v:RefreshScore()
	end
end

function C:on_fg_enter_room_msg()
	self:MyRefresh()
end
function C:on_nor_dmn_nor_pai_msg()

	print("<color=red> 开始发牌 </color>")
    local data = DominoJLModel.data

	local list = {}
	local zhuang_ui = data.s2cSeatNum[ data.zhuang or 1 ]
	for i = 1, DominoJLModel.maxPlayerNumber do
		if zhuang_ui > DominoJLModel.maxPlayerNumber then
			zhuang_ui = 1
		end
		if DominoJLModel.GetPosToPlayer(zhuang_ui) then
			list[#list + 1] = {posList=self.playerList[zhuang_ui]:GetCardPosition(), i=zhuang_ui}
		end
		zhuang_ui = zhuang_ui + 1
	end
	local paiData = data.my_pai_list
	DominoJLAnim.DealCard(self.transform, list, paiData, function ()
		self:RefreshPlayerInfo()
		self.playerList[1]:PlayShowCardCount()
	end)
end

-- 玩家进入
function C:on_fg_join_msg(seat_num)
    self:RefreshPlayerInfo(DominoJLModel.data.s2cSeatNum[seat_num])
end

-- 玩家离开
function C:on_fg_leave_msg(seat_num)
    self:RefreshPlayerInfo(DominoJLModel.data.s2cSeatNum[seat_num])
end

function C:on_fg_score_change_msg()
    self:RefreshScore()
end

function C:model_fg_ready_response(data)
    self:MyRefresh()
end

function C:on_fg_ready_msg(seat_num)
    self:RefreshPlayerInfo(DominoJLModel.data.s2cSeatNum[seat_num])
end

function C:on_nor_dmn_nor_begin_msg()
	ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_kaishi.audio_name)
end

function C:on_nor_dmn_nor_ding_zhuang_msg()
	for i, v in ipairs(self.playerList) do
		v:PlayZhuangAni()
	end
end

function C:on_nor_dmn_nor_cp_permit()
	self:RefreshPermit()
	self:AutoOutCard()
end

function C:AutoOutCard()
	--是否轮到我出牌
	if DominoJLCardGroup.Instance then
		DominoJLCardGroup.Instance:AutoOutCard()
	end
end

function C:RefreshPermit()
	for i, v in ipairs(self.playerList) do
		v:RefreshPermit()
	end
end

function C:GetChooseQueuePos()
	if not self.desk then
		return
	end
	return self.desk.chooseQueuePos
end

function C:nor_dmn_nor_cp_response(data)
	if data.result == 0 then
		--牌已经出出去了
	else
		self:MyRefresh()
	end
	Event.Brocast("view_nor_dmn_nor_cp_response")
end

function C:on_nor_dmn_nor_cp_msg()
	local d = DominoJLModel.data.table_pai[#DominoJLModel.data.table_pai]
	local data = {}
	data.cardData = DominoJLLib.GetDataById(d.pai)
	data.queuePos = DominoJLModel.S2CQueuePos(d.lr)
	data.seat_num = d.seat_num
	if d.seat_num == DominoJLModel.data.seat_num then
		--自己出的牌
		Event.Brocast("me_auto_play_card",data)
	else
		--其它玩家出的牌
		Event.Brocast("other_play_card",data)
	end
	if self.cardCount then
		self.cardCount:PlayCard()
	end
end

function C:on_nor_dmn_nor_score_change_msg(data)
	dump(data,"<color=red>中途pass</color>")

	ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_pass.audio_name)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.8)
	seq:AppendCallback(function ()
		DominoJLPass.Create(data.data)
	end)
	seq:AppendInterval(2)
	seq:AppendCallback(function ()
		self:RefreshScore()
	end)
	seq:OnForceKill(
		function ()
			self:RefreshScore()
		end
	)
end

function C:on_nor_dmn_nor_settlement_msg(data)
	dump(data,"<color=red>结算数据</color>")
	self:SettlementCloseState()
	self:RefreshPermit()
	self:SetFgGameOver(nil)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.02)
	seq:AppendCallback(function ()
		if self.desk then
			self.desk:SetQueueCardGray()
			--全部pass结束倍率为1倍，不高亮显示最后出的牌
			if data.settlement_info.rate ~= 1 then
				self.desk:SetQueueCardLightByLastCard()
			end
		end
		if DominoJLCardGroup.Instance then
			DominoJLCardGroup.Instance:SetCardGray()
		end
	end)
	seq:AppendInterval(1)
	seq:AppendCallback(function ()
		if self.desk then
			self.desk:ClearQueueCard()
			self.desk:RefreshPlayerCard()
		end
	end)
	seq:AppendInterval(0.02)
	local game_name = MainLogic.GetGameTypeByGameID(DominoJLModel.data.game_id) 
	if game_name == "domino_bet" then
		seq:AppendCallback(function ()
			DominoJLClear.Create(data)
		end)
		seq:AppendInterval(4)
		seq:AppendCallback(function ()
			--加倍的玩法
			DominoJLBetClear.Create(data)
		end)
		seq:AppendInterval(0.4)
		seq:AppendCallback(function ()
			--没有破产或者在托管状态正常结算后执行操作
			if not DominoJLModel.CheckBrokeProcess() or DominoJLModel.CheckMeIsAutoState() then
				
			else
				self:RunBrokeProcess()
			end
		end)
		seq:AppendInterval(5)
		seq:AppendCallback(function ()
			self:RefreshPlayerInfo()
			--没有破产或者在托管状态正常结算后执行操作
			if not DominoJLModel.CheckBrokeProcess() or DominoJLModel.CheckMeIsAutoState() then
				DominoJLBetClear.Close()
				self:ResetFgGameOver()
				self:CallFgGameOver()
			else
				-- self:RunBrokeProcess()
			end
		end)
	else
		seq:AppendCallback(function ()
			DominoJLClear.Create(data)
		end)
		seq:AppendInterval(3)
		seq:AppendCallback(function ()
			self:RefreshPlayerInfo()
			--没有破产或者在托管状态正常结算后执行操作
			if not DominoJLModel.CheckBrokeProcess() or DominoJLModel.CheckMeIsAutoState() then
				self:ResetFgGameOver()
				self:CallFgGameOver()
			else
				self:RunBrokeProcess()
			end
		end)
	end
	self.seqSettlement = seq
end

function C:RunBrokeProcess()
	local operate = DominoJLModel.data.auto_status[DominoJLModel.data.seat_num]
	if operate == 1 then
		--托管中退出游戏
		Network.SendRequest("fg_quit_game")
		return "fg_quit_game"
	end

	if DominoJLModel.quit then
		--退出游戏
		Network.SendRequest("fg_quit_game")
		return "fg_quit_game"
	end

	if DominoJLModel.CheckBrokeProcess() then
		local game_name = MainLogic.GetGameTypeByGameID(DominoJLModel.data.game_id) 
		local func
		if game_name == "domino_bet" then
			--加倍场由玩家决定下步操作
		else
			--普通场由自动进行下步操作
			func = function ()
				dump(game_name,"<color=white>破产回调？？？？？？？？？？？？？？</color>")
				if not DominoJLGamePanel.Instance then return end
				DominoJLGamePanel.Instance:ResetFgGameOver()
				DominoJLGamePanel.Instance:CallFgGameOver()
			end
		end
		SysBrokeSubsidyManager.RunBrokeProcess({callback = func})
        return "fg_quit_game", true
	end

	--当前资产不满足当前场的条件限制
	if not DominoJLModel.CheckBestGameID() then
		local gameId = DominoJLModel.GetBestGameID()
		if gameId then
			Network.SendRequest("fg_switch_game",{id = gameId})
			return "fg_switch_game"
		else
			Network.SendRequest("fg_quit_game")
			return "fg_quit_game"
		end
	end

	if DominoJLModel.change then
		--换桌游戏
		Network.SendRequest("fg_huanzhuo")
		return "fg_huanzhuo"
	end

	--继续游戏
	Network.SendRequest("fg_ready")
	return "fg_ready"
end

function C:SettlementCloseState()
	--关闭托管界面
	self.auto_node.gameObject:SetActive(false)
end

function C:CallFgGameOver()
	if not self.FgGameOverCallBack or type(self.FgGameOverCallBack) ~= "function" then
		return
	end
	self.FgGameOverCallBack()
end

function C:SetFgGameOver(func)
	self.FgGameOverCallBack = func
end

function C:ResetFgGameOver()
	self.FgGameOverCallBack = function ()
		local operate = DominoJLModel.data.auto_status[DominoJLModel.data.seat_num]
		if operate == 1 then
			--托管中退出游戏
			Network.SendRequest("fg_quit_game")
			return
		end

		if DominoJLModel.quit then
			--退出游戏
			Network.SendRequest("fg_quit_game")
			return
		end

		--当前资产不满足当前场的条件限制
		if not DominoJLModel.CheckBestGameID() then
			local gameId = DominoJLModel.GetBestGameID()
			if gameId then
				Network.SendRequest("fg_switch_game",{id = gameId})
			else
				Network.SendRequest("fg_quit_game")
			end
			return
		end

		if DominoJLModel.change then
			--换桌游戏
			Network.SendRequest("fg_huanzhuo")
			return
		end

		--继续游戏
		Network.SendRequest("fg_ready")
	end
end

function C:on_fg_gameover_msg()
	self:CallFgGameOver()
end

function C:on_fg_quit_game_response()
	self:MyRefresh()
end

function C:on_fg_ready_response()
	self:MyRefresh()
end

function C:on_fg_huanzhuo_response()
	self:MyRefresh()
end

function C:on_nor_dmn_nor_auto_msg(data)
	self:RefreshAuto()
end

function C:on_nor_dmn_nor_auto_response(data)
	self:RefreshAuto()
end

function C:on_fg_all_info()
	self:MyRefresh()
	local m_data = DominoJLModel.data
    if m_data.model_status == DominoJLModel.Model_Status.gameover then
		self:ResetFgGameOver()
		self:CallFgGameOver()
	elseif m_data.model_status == DominoJLModel.Model_Status.gaming then
		if m_data.status == DominoJLModel.Status.settlement then
			self:ResetFgGameOver()
		end
	end
end

function C:RefreshAuto()
	if not DominoJLModel or not DominoJLModel.data or not DominoJLModel.data.seat_num then
		self.auto_node.gameObject:SetActive(false)
		return
	end
	local operate = DominoJLModel.data.auto_status[DominoJLModel.data.seat_num]
	if not operate or operate == 0 then
		self.auto_node.gameObject:SetActive(false)
		return
	end
	self.auto_node.gameObject:SetActive(true)
end

function C:CloseAuto()
	local data = {}
	data.operate = 0
	Network.SendRequest("nor_dmn_nor_auto",data)
end

function C:OnClickAuto()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not DominoJLModel or not DominoJLModel.data or not DominoJLModel.data.seat_num then
		return
	end
	local operate = DominoJLModel.data.auto_status[DominoJLModel.data.seat_num]
	if not operate then
		operate = 0
	end
	local data = {}
	if operate == 0 then
		data.operate = 1
	elseif operate == 1 then
		data.operate = 0
	end

	Network.SendRequest("nor_dmn_nor_auto",data)
end

function C:OnClickMenu()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local activeSelf = not self.btns_node.gameObject.activeSelf
	self.btns_node.gameObject:SetActive(activeSelf)

	if activeSelf then
		--显示的时候动画表现
		DominoJLAnim.ShowMenuBtns(self.btn_bg_img,self.quit_btn,self.get_up_btn,self.change_btn,self.help_btn)
	end
end

function C:OnClickQuit()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not DominoJLModel then
		return
	end

	if DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming then
		dump(DominoJLModel.data.model_status,"<color=yellow>没有在游戏中退出</color>")
		Network.SendRequest("fg_quit_game")
		return
	end

	if not DominoJLModel.quit then
		DominoJLModel.quit = false
	end

	self:SetQuit(not DominoJLModel.quit)
end

function C:SetQuit(b)
	DominoJLModel.quit = b
	self.quit_img.gameObject:SetActive(DominoJLModel.quit)

	if DominoJLModel.quit then
		DominoJLModel.change = false
		self.change_img.gameObject:SetActive(DominoJLModel.change)
		LittleTips.Create(GLL.GetTx(60023))
	end
end

function C:OnClickChange()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not DominoJLModel then
		return
	end

	if not DominoJLModel.change then
		DominoJLModel.change = false
	end
	self:SetChange(not DominoJLModel.change)
end

function C:SetChange(b)
	DominoJLModel.change = b
	self.change_img.gameObject:SetActive(DominoJLModel.change)

	if DominoJLModel.change then
		DominoJLModel.quit = false
		self.quit_img.gameObject:SetActive(DominoJLModel.quit)
		LittleTips.Create(GLL.GetTx(60024))
	end
end

function C:OnClickGetUp()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	LittleTips.Create("暂未开放")
end

function C:OnClickHelp()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	local betType = DominoJLModel.CheckBetType()
	if betType == "nor" then
		GameManager.GotoUI({gotoui = "sys_rules",goto_scene_parm = "panel",game = "Domino"})
	elseif betType == "bet" then
		GameManager.GotoUI({gotoui = "sys_rules",goto_scene_parm = "panel",game = "DominoBet"})
	end
end

function C:RefreshBet()
	if not DominoJLModel
	or not DominoJLModel.data
	or not next(DominoJLModel.data)
	or not DominoJLModel.data.init_stake
	then
		self.bet_txt.text = ""
		return
	end

	self.bet_txt.text = GLL.GetTx(40004) .. StringHelper.ToCash(DominoJLModel.data.init_stake)
end

--等级分数改变
function C:on_level_score_change(data)
	dump(data,"<color=white>data??????</color>")
	local pos = self.playerList[1].head_img.transform.position
	CommonAnim.FlyLevelScore(pos,data.addScore)
end

function C:on_model_AssetChange(data)
	self.playerList[1]:RefreshInfo()
end

function C:on_model_reset_data()
	if self.seqSettlement then
		self.seqSettlement:Kill()
	end
	self.seqSettlement = nil
end