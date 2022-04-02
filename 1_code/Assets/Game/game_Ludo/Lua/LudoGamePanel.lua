-- 创建时间:2021-11-08
-- Panel:LudoGamePanel
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

LudoGamePanel = basefunc.class()
local C = LudoGamePanel
C.name = "LudoGamePanel"
local listerRegisterName = "listerRegisterName_LudoGamePanel"
local instance
function C.Create()
	if not instance then
		instance = C.New()
		LudoGamePanel.Instance = instance
	end
	return instance
end

function C:AddMsgListener()
    LudoLogic.setViewMsgRegister(self.lister, listerRegisterName)
end

function C:MakeLister()
    self.lister = {}
	--all info
	self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_fg_all_info)
	
	--fg msg
    self.lister["model_fg_enter_room_msg"] = basefunc.handler(self, self.on_fg_enter_room_msg)
    self.lister["model_fg_join_msg"] = basefunc.handler(self, self.on_fg_join_msg)
    self.lister["model_fg_ready_msg"] = basefunc.handler(self, self.on_fg_ready_msg)
    self.lister["model_fg_leave_msg"] = basefunc.handler(self, self.on_fg_leave_msg)
	self.lister["model_fg_gameover_msg"] = basefunc.handler(self,self.on_fg_gameover_msg)
    self.lister["model_fg_score_change_msg"] = basefunc.handler(self, self.on_fg_score_change_msg)
	
	--nor msg
    self.lister["nor_fxq_nor_begin_msg"] = basefunc.handler(self, self.on_nor_fxq_nor_begin_msg)
    
	self.lister["model_nor_fxq_nor_ding_zhuang_msg"] = basefunc.handler(self, self.on_nor_fxq_nor_ding_zhuang_msg)
	self.lister["model_nor_fxq_nor_roll_permit"] = basefunc.handler(self, self.on_nor_fxq_nor_roll_permit)
	self.lister["model_nor_fxq_nor_roll_msg"] = basefunc.handler(self, self.on_nor_fxq_nor_roll_msg)
	self.lister["model_nor_fxq_nor_piece_permit"] = basefunc.handler(self, self.on_nor_fxq_nor_piece_permit)
	self.lister["model_nor_fxq_nor_piece_msg"] = basefunc.handler(self, self.on_nor_fxq_nor_piece_msg)
	self.lister["model_nor_fxq_nor_award_msg"] = basefunc.handler(self, self.on_nor_fxq_nor_award_msg)
	self.lister["model_nor_fxq_nor_score_change_msg"] = basefunc.handler(self,self.on_nor_fxq_nor_score_change_msg)
	self.lister["model_nor_fxq_nor_settlement_msg"] = basefunc.handler(self,self.on_nor_fxq_nor_settlement_msg)
	self.lister["model_nor_fxq_nor_auto_msg"] = basefunc.handler(self,self.on_nor_fxq_nor_auto_msg)
	self.lister["model_nor_fxq_nor_ready_msg"] = basefunc.handler(self,self.on_nor_fxq_nor_ready_msg)

	--fg response
	self.lister["model_fg_ready_response"] = basefunc.handler(self, self.on_fg_ready_response)

	--ui
	self.lister["kuoshan_ui"] = basefunc.handler(self,self.on_kuoshan_ui)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    LudoLogic.clearViewMsgRegister(listerRegisterName)
end

function C:MyExit()
	Event.Brocast("LudoGamePanelExit")
	self:RemoveListener()
	self:RemoveListenerGameObject()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
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
	if self.wait then
		self.wait:MyExit()
	end
	if self.clear_timer then
		self.clear_timer:Stop()
	end
	if self.show_extra_timer then
		self.show_extra_timer:Stop()
	end
	instance = nil
	LudoGamePanel.Instance = nil

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
	
	self.Animator = GameObject.Find("Canvas/GUIRoot/LudoGamePanel/LudoFlagNode").transform:GetComponent("Animator")
	self.Ludo3DNodeAnimator = GameObject.Find("LudoCanvasBG/root").transform:GetComponent("Animator")
	self.Camera3DAnimator = GameObject.Find("Ludo3DNode/Camera3D").transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	ExtendSoundManager.PlaySceneBGM(audio_config.ludo.ludo_usually_BGM.audio_name)
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.quit_btn.onClick:AddListener(function ()
		self:OnClickQuit()
	end)

	self.auto_btn.onClick:AddListener(function ()
		self:OnClickAuto()
	end)

	self.mvp_btn.onClick:AddListener(function ()
		LudoMvpPanel.Create()
	end)
	self.unauto_btn.onClick:AddListener(function ()
		Network.SendRequest("nor_fxq_nor_auto",{operate = 0})
		self.playerList[1].auto_node.gameObject:SetActive(false)
	end)
end

function C:RemoveListenerGameObject()
    self.quit_btn.onClick:RemoveAllListeners()
    self.auto_btn.onClick:RemoveAllListeners()
    self.mvp_btn.onClick:RemoveAllListeners()
    self.unauto_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
	
	self.playerList = {}
	self.playerList[1] = LudoPlayerMe.New(self, self.player1, {uiIndex = 1})
	self.playerList[2] = LudoPlayerOther.New(self, self.player2, {uiIndex = 2})
	self.playerList[3] = LudoPlayerOther.New(self, self.player3, {uiIndex = 3})
	self.playerList[4] = LudoPlayerOther.New(self, self.player4, {uiIndex = 4})


	self.desk = LudoDesk.Create({parent = GameObject.Find("Ludo3DNode").transform})
	self.wait = LudoWait.Create()
	self:InitUIColor()
	self:InitFlag3D()
	self:MyRefresh()

	self.auto_txt.text = GLL.GetTx(60009)

	local btn_map = {}
	btn_map["chat"] = {self.chat_node}
	btn_map["acts"] = {self.act_node1, act_node2}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "ludo", self.transform)
	GameModuleManager.RunFunExt("sys_interactive", "SetCurGamePanel", nil, self)

end
-- 表情功能调用接口
function C:GetPlayerPosByID(id)
	local m_data = LudoModel.data
    if m_data and m_data.players_info then
        for k, v in pairs(m_data.players_info) do
            if v.id == id then
                local uiPos = m_data.s2cSeatNum[ v.seat_num ]
                return self.playerList[uiPos].head_img.transform.position
            end
        end
    end
end

function C:InitFlag3D()
	self.flag3D = {}
	for i = 1, 4 do
		local flagObj = newObject("LudoFlag",self.desk.FlagNode.transform)
		flagObj.transform.position = LudoLib.Get2DTo3DPoint(self["flag".. i .. "_img"].transform.position)

		self.flag3D[i] = flagObj.transform:GetComponent("SpriteRenderer")
	end
end

--初始化当前的颜色
function C:InitUIColor()
	--初始化等待匹配的UI
	local init_wait_ui_color = function (player_index,color)
		local config = {
			blue = { bg_img = "ludo_pipei_bglan",kuang_img = "ludo_txk_lan"},
			red = { bg_img = "ludo_pipei_bghong",kuang_img = "ludo_txk_hong"},
			green = { bg_img = "ludo_pipei_bglv",kuang_img = "ludo_txk_lv"},
			yellow = { bg_img = "ludo_pipei_bghuang",kuang_img = "ludo_txk_huang"},
		}
		local wait_ui = self["wait_player"..player_index]
		local temp_ui = {}
		LuaHelper.GeneratingVar(wait_ui.transform,temp_ui)
		temp_ui.bg_img.sprite = GetTexture(config[color].bg_img)
		temp_ui.kuang_img.sprite = GetTexture(config[color].kuang_img)
	end
	
	local init_head_ui_color = function (player_index,color)
		local config = {
			blue = { di_img = "ludo_bg_lan",kuang_img = "ludo_txk_lan"},
			red = { di_img = "ludo_bg_hong",kuang_img = "ludo_txk_hong"},
			green = { di_img = "ludo_bg_lv",kuang_img = "ludo_txk_lv"},
			yellow = { di_img = "ludo_bg_huang",kuang_img = "ludo_txk_huang"},
		}
		local wait_ui = self["player"..player_index]
		local temp_ui = {}
		LuaHelper.GeneratingVar(wait_ui.transform,temp_ui)
		temp_ui.di_img.sprite = GetTexture(config[color].di_img)
		temp_ui.kuang_img.sprite = GetTexture(config[color].kuang_img)
	end
	
	for i = 1,4 do
		local color = LudoLib.GetColor(i)
		init_wait_ui_color(i,color)
		init_head_ui_color(i,color)
	end
end

function C:MyRefresh()
	self:RefreshWait()
	self:RefreshPlayer()
	self:RefreshDesk()
	self:RefreshBG()
	self:RefreshFlagColor()
	self:RefreshFlagEnd()
	self:RefreshClear()
end

function C:RefreshClear()
	local m_data = LudoModel.data
	if m_data.model_status ~= LudoModel.Model_Status.gameover
	or m_data.status ~= LudoModel.Status.gameover then
		return
	end
	dump(LudoModel.data.settlement_players_info,'<color=red>结算1</color>')
	LudoModel.data.players_info = LudoModel.data.settlement_players_info
	if LudoModel.data.players_info then
		LudoClear.Create(LudoModel.data)
	else
		Network.SendRequest("fg_quit_game")
	end
end

function C:RefreshFlagColor()
	local ct = {
		blue = "ludo_qizi_04",
		red = "ludo_qizi_03",
		green = "ludo_qizi_02",
		yellow = "ludo_qizi_01",
	}

	local setColor = function (CSeatNum)
		local color = LudoLib.GetColor(CSeatNum)
		self.colorFlag = self.colorFlag or {}
		if self.colorFlag[CSeatNum] == color then
			return
		end
		self.colorFlag[CSeatNum] = color
		self["flag" .. CSeatNum .. "_img"].sprite = GetTexture(ct[color])
		self.flag3D[CSeatNum].sprite = GetTexture(ct[color])
		self["flag_end" .. CSeatNum .. "_img"].sprite = GetTexture(ct[color])
	end

	for i = 1, LudoModel.maxPlayerNumber do
		setColor(i)
	end
end

function C:RefreshFlagEnd()
	if not LudoModel or not LudoModel.data or not next(LudoModel.data) or not LudoModel.data.piece or not next(LudoModel.data.piece) then
		return
	end

	local flagActive = {false,false,false,false}
	for seat_num, pieces in pairs(LudoModel.data.piece) do
		local CSeatNum = LudoModel.data.s2cSeatNum[seat_num]
		flagActive[CSeatNum] = true
		for pId, place in pairs(pieces) do
			if LudoLib.GetPiecePosState(CSeatNum,place) ~= "end" then
				flagActive[CSeatNum] = false
				break
			end
		end
	end

	for i = 1, 4 do
		self["flag_end" .. i .. "_img"].gameObject:SetActive(flagActive[i])
	end
end

function C:RefreshBG()
	local color = LudoLib.GetColor(1)
	if self.color == color then
		return
	end
	self.color = color
	local colorImg = GameObject.Find("LudoCanvasBG/root/@qp_color_img"):GetComponent("Image")
	local ct = {
		blue = "ludo_qipan_01",
		red = "ludo_qipan_04",
		green = "ludo_qipan_03",
		yellow = "ludo_qipan_02",
	}
	colorImg.sprite = GetTexture(ct[self.color])
	colorImg = nil
end

function C:RefreshWait()
	if self.wait then
		self.wait:MyRefresh()
	end
end

function C:RefreshPlayer()
	for k,v in ipairs(self.playerList or {}) do
		v:MyRefresh()
	end
end

function C:RefreshDesk()
	if self.desk then
		self.desk:MyRefresh()
	end
end

function C:OnClickAuto()
	--测试代码
	-- if true then
	-- 	LudoDice.Create(nil,math.random(4),math.random(6))
	-- 	return
	-- end

	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not LudoModel or not LudoModel.data or not LudoModel.data.seat_num then
		return
	end
	local operate = LudoModel.data.auto_status[LudoModel.data.seat_num]
	if not operate then
		operate = 0
	end
	local data = {}
	if operate == 0 then
		data.operate = 1
	elseif operate == 1 then
		data.operate = 0
	end

	Network.SendRequest("nor_fxq_nor_auto",data)
end

function C:OnClickQuit()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--当游戏已经结束处于结算界面了
	if LudoModel.data.model_status == LudoModel.Model_Status.gameover then
		Network.SendRequest("fg_quit_game")
		return
	end

	--当玩家处于游戏过程中
	local game_id = LudoModel.data.game_id
	local str = MainLogic.GetInitStakeByGameID(game_id)
	str = StringHelper.AddPoint(str)
	dump(GLL.GetTx(60006))
	local p = HintPanel.CreateSmall(2,string.format(GLL.GetTx(60006),str),function ()
		Network.SendRequest("fg_quit_game")
	end)
	p.no_txt.text = GLL.GetTx(60007)
	p.yes_txt.text = GLL.GetTx(60008)
end

function C:on_fg_all_info()
	self:MyRefresh()
	local m_data = LudoModel.data
    if m_data.model_status == LudoModel.Model_Status.gameover then
		self:on_fg_gameover_msg()
	end

	if m_data.status == LudoModel.Status.roll or m_data.status == LudoModel.Status.piece then
		self.quit_btn.gameObject:SetActive(true) 
	else
		self.quit_btn.gameObject:SetActive(false) 
	end
end

function C:on_fg_enter_room_msg()
	self:MyRefresh()
end

function C:on_fg_join_msg(seat_num)
	local cSeatNum = LudoModel.data.s2cSeatNum[seat_num]
    self.playerList[cSeatNum]:PlayJoin()
end

function C:on_fg_ready_msg(seat_num)
    local cSeatNum = LudoModel.data.s2cSeatNum[seat_num]
    self.playerList[cSeatNum]:PlayReady()
end

function C:on_fg_leave_msg(seat_num)
	local cSeatNum = LudoModel.data.s2cSeatNum[seat_num]
    self.playerList[cSeatNum]:PlayLeave()
end

function C:on_fg_gameover_msg()
	
end

function C:on_fg_score_change_msg(data)
	self.playerList[1]:PlayScoreChange(data.score)
end

function C:on_nor_fxq_nor_ready_msg(data)
	if self.wait then
		self.wait:PlayReady(data)
	end
end

function C:on_nor_fxq_nor_begin_msg()
	self.quit_btn.gameObject:SetActive(false)
	local obj = self.playerList[1].award_img.gameObject
	obj.transform:GetComponent("Canvas").sortingOrder = -2
	obj.gameObject:SetActive(true)
	obj.transform.localPosition = Vector3.New(-210.9,-6.6,0)
	for i, v in ipairs(self.playerList) do
		v:RefreshPiece()
	end
	if self.wait then
		self.wait:PlayBegin()
	end
	self:RefreshFlagEnd()
end

function C:on_nor_fxq_nor_ding_zhuang_msg(data)
	for i, v in ipairs(self.playerList) do
		v:PlayZhuang()
	end
end

function C:on_nor_fxq_nor_roll_permit(data)
	dump(data,"<color=red>摇骰子权限</color>")
	for i, v in ipairs(self.playerList) do
		v:PlayRollPermit()
	end
	self.quit_btn.gameObject:SetActive(true)
end

function C:on_nor_fxq_nor_roll_msg(data)
	dump(data,"<color=red>摇骰子</color>")
	local cSeatNum = LudoModel.data.s2cSeatNum[data.seat_num]
	self.playerList[cSeatNum]:PlayRoll(data)
end

function C:on_nor_fxq_nor_piece_permit(data)
	dump(data,"<color=red>走棋权限pass</color>")
	for i, v in ipairs(self.playerList) do
		v:PlayPiecePermit()
	end
end

function C:on_nor_fxq_nor_piece_msg(data)
	dump(data,"<color=red>走棋</color>")
	local cSeatNum = LudoModel.data.s2cSeatNum[data.seat_num]
	self.playerList[cSeatNum]:PlayPiece(data)
end

function C:on_nor_fxq_nor_award_msg(data)
	dump(data,"<color=red>中途奖励</color>")
	local cSeatNum = LudoModel.data.s2cSeatNum[data.seat_num]
	self.playerList[cSeatNum]:PlayAward(data)
end

function C:on_nor_fxq_nor_score_change_msg(data)
	dump(data,"<color=red>分数改变</color>")
	for seat_num, score in ipairs(data.data) do
		local cSeatNum = LudoModel.data.s2cSeatNum[seat_num]
		self.playerList[cSeatNum]:PlayScoreChange(score)
	end
end

function C:on_nor_fxq_nor_settlement_msg(data)
	dump(data,"<color=red>结算数据</color>")

	if self.clear_timer then
		self.clear_timer:Stop()
	end

	self.clear_timer = Timer.New(function ()
		if MainModel.myLocation == "game_Ludo" then
			LudoClear.Create(data)
		end
	end,2,1)
	self.clear_timer:Start()
end

function C:on_nor_fxq_nor_auto_msg(data)
	dump(data,"<color=red>玩家进入托管</color>")
	local cSeatNum = LudoModel.data.s2cSeatNum[data.p]
	self.playerList[cSeatNum]:PlayAuto(data)
end

function C:on_fg_ready_response()
    self:MyRefresh()
end

--test---------------------------------
function C:GetDicePoint()
	if not self.PointInputField.gameObject.activeSelf then
		return
	end
	local num = self.dice_txt.text
	if not num or num == "" then
		return 6
	end

	num = tonumber(num)
	if not num then
		return 6
	end
	return num
end

function C:on_kuoshan_ui()
	self.Animator.enabled = true
	self.Camera3DAnimator.enabled = true
	self.Ludo3DNodeAnimator.enabled = true

	self.Animator.speed = 2
	self.Camera3DAnimator.speed = 2
	self.Ludo3DNodeAnimator.speed = 2

	self.Animator:Play("LudoFlagNode",-1,0)
	self.Camera3DAnimator:Play("camera3d",-1,0)
	self.Ludo3DNodeAnimator:Play("root_gamepanel",-1,0)
end
--展示额外奖励
function C:ShowExtraAward(data,change_type)
	local obj = self.playerList[1].award_img.gameObject
	obj.transform:GetComponent("Canvas").sortingOrder = 0
	local base_pos = obj.transform.position
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOMove(Vector3.zero,1.2))
	seq:AppendCallback(function ()
		obj.transform.position = base_pos
		Event.Brocast("AssetGet",{data = data, change_type = data.type})
		obj.gameObject:SetActive(false)
	end)
	seq:OnForceKill(
		function ()
			obj.transform.position = base_pos
			obj.gameObject:SetActive(false)
		end
	)
end

--资产改变
function C:OnAssetChange(data)
	if data.change_type == "fxq_game_extra_award" then
		if self.show_extra_timer then
			self.show_extra_timer:Stop()
		end

		self.show_extra_timer = Timer.New(function ()
			self:ShowExtraAward(data.data,data.change_type)
		end,2.5,1)
		self.show_extra_timer:Start()
	end
end
-- if MainModel.IsShowAward(data.type) and #change_assets_get > 0 then
-- 	Event.Brocast("AssetGet",{data = change_assets_get, change_type = data.type})
-- end