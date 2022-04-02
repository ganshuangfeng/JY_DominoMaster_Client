local basefunc = require "Game/Common/basefunc"

DominoJLHallGamePanel = basefunc.class()
local C = DominoJLHallGamePanel
C.name = "DominoJLHallGamePanel"

--多米诺加倍和多米诺普通 共用这一个预制体，ludo单独使用一个，可能ludo之后的美术风格会改
function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["fg_get_game_player_num_response"] = basefunc.handler(self,self.on_fg_get_game_player_num_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	print("<color=red>多米诺退出</color>")
	if self.num_timer then
		self.num_timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:RemoveListener()
	self:RemoveListenerGameObject()
	Event.Brocast("domino_hall_panel_exit_msg")
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parm = parm
	LuaHelper.GeneratingVar(self.transform, self)
	local other_img = self.other_bet_title.transform:GetComponent("Image")

	if self.parm.domino_type == 1 then
		self.normal_title.gameObject:SetActive(true)
		self.bet_title.gameObject:SetActive(false) 
		other_img.sprite = GetTexture("cc_bt_dominobet_01")
		self.active_1.gameObject.transform.localPosition = Vector3.New(-244.3,291,0)
		self.active_2.gameObject.transform.localPosition = Vector3.New(79,285,0)
	elseif self.parm.domino_type == 2 then 
		self.normal_title.gameObject:SetActive(false)
		self.bet_title.gameObject:SetActive(true)
		other_img.sprite = GetTexture("cc_bt_dominoclassic_01")
		self.active_2.gameObject.transform.localPosition = Vector3.New(-256,285,0)
		self.active_1.gameObject.transform.localPosition = Vector3.New(102,291.9,0)
	end
	other_img:SetNativeSize()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:SentAsk()
	local btn_map = {}
	btn_map["left_node"] = {self.left_node1,self.left_node2,self.left_node3,self.left_node4}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "dominojl_hall", self.transform)

	
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.other_btn.onClick:AddListener(function ()
		if self.parm.domino_type == 1 then
			DominoJLHallLogic.change_pattern(2)
		else
			DominoJLHallLogic.change_pattern(1)
		end
	end)
	self.back_btn.onClick:AddListener(
		function ()
			GameManager.CommonGotoScence({gotoui = "game_Hall"})
		end
	)
	self.start_btn.onClick:AddListener(
		function ()
			self:StartGame()
		end
	)
	self.add_money_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end
	)
end

function C:RemoveListenerGameObject()
	self.other_btn.onClick:RemoveAllListeners()
	self.back_btn.onClick:RemoveAllListeners()
	self.start_btn.onClick:RemoveAllListeners()
	self.add_money_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.items) do
		v.main_btn.onClick:RemoveAllListeners()
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	local config = Game_Hall_Config
	self.items = {}
	self.key_name = nil
	if self.parm.domino_type == 1 then
		self.key_name = "domino"
	elseif self.parm.domino_type == 2 then 
		self.key_name = "domino_bet"
	end

	for i = 1,#config[self.key_name] do
		local temp_ui = {}
		local obj = GameObject.Instantiate( self.item,self.Content )
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.title_txt.text = config[self.key_name][i].title
		if config[self.key_name][i].tag then
			temp_ui.tag_img.gameObject:SetActive(true)
			temp_ui.tag_img.sprite = GetTexture(config[self.key_name][i].tag)
		else
			temp_ui.tag_img.gameObject:SetActive(false)
		end

		temp_ui.init_stake_txt.text = StringHelper.ToCash(config[self.key_name][i].init_stake)
		if config[self.key_name][i].limit_max then
			temp_ui.limit_txt.text = StringHelper.ToCash(config[self.key_name][i].limit_min).. "~"..StringHelper.ToCash(config[self.key_name][i].limit_max)
		else
			temp_ui.limit_txt.text = StringHelper.ToCash(config[self.key_name][i].limit_min).. "+"
		end		temp_ui.main_btn.onClick:AddListener(
			function ()
				local max = config[self.key_name][i].limit_max or -1
				--是否在范围
				local isInRange = false
				if max == -1 then
					if MainModel.UserInfo.jing_bi >= config[self.key_name][i].limit_min then
						isInRange = true
					end
				else
					if MainModel.UserInfo.jing_bi >= config[self.key_name][i].limit_min and MainModel.UserInfo.jing_bi <= max then
						isInRange = true
					end
				end

				if isInRange then
					local g_id = config[self.key_name][i].game_id
					MainModel.SetLastGameID(g_id)
					GameManager.CommonGotoScence({gotoui = "game_DominoJL",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
						print("多米诺"..g_id)
					end)
				else
					local best_game_id = self:GetBestGameID()
					if best_game_id then
						--钱不够
						if MainModel.UserInfo.jing_bi < config[self.key_name][i].limit_min then
							local p = HintPanel.Create(5,GLL.GetTx(60003),function ()
								print(GLL.GetTx(60004))
								--GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
								SysBrokeSubsidyManager.RunBrokeProcess()
							end)
							p:SetButtonText("", GLL.GetTx(60004))
						--钱太多	
						else
							local p = HintPanel.Create(5,GLL.GetTx(60001),function ()
								self:StartGame()
							end)
							p:SetButtonText("",GLL.GetTx(60002))
						end
					else		
						local p = HintPanel.Create(5,GLL.GetTx(60003),function ()
							print(GLL.GetTx(60004))
							--GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
							SysBrokeSubsidyManager.RunBrokeProcess()
						end)
						p:SetButtonText("", GLL.GetTx(60004))
					end					
				end
			end
		)
		obj.gameObject:SetActive(true)
		self.items[config[self.key_name][i].game_id] = temp_ui
	end
	
	
	self:MyRefresh()

	Event.Brocast("domino_hall_panel_init_msg", self)
end

function C:MyRefresh()
	self:RefreshAssetChange()
end

--刷新资产相关
function C:OnAssetChange()
	self:RefreshAssetChange()
end

function C:RefreshAssetChange()
	self.add_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.add_rp_txt.text = GameItemModel.GetItemCount("shop_gold_sum")

	local best_game_id = self:GetBestGameID()
	local title = ""
	for i = 1,#Game_Hall_Config[self.key_name] do
		if best_game_id == Game_Hall_Config[self.key_name][i].game_id then
			title = Game_Hall_Config[self.key_name][i].title
			break
		end
	end
	self.start_txt.text = title
	if title == ""  then
		self.start.gameObject.transform.localPosition = Vector3.zero
	else
		self.start.gameObject.transform.localPosition = Vector3.New(0,21,0)
	end
end
--得到一个合适游戏ID
function C:GetBestGameID()
	local gold_num = MainModel.UserInfo.jing_bi
	local game_id = nil
	for i = 1,#Game_Hall_Config[self.key_name] do
		if gold_num >= Game_Hall_Config[self.key_name][i].limit_min then
			if Game_Hall_Config[self.key_name][i].limit_max then
				if gold_num <= Game_Hall_Config[self.key_name][i].limit_max then
					game_id = Game_Hall_Config[self.key_name][i].game_id
				end
			else
				game_id = Game_Hall_Config[self.key_name][i].game_id
			end
		end
	end
	return game_id
end

--快速开始
function C:StartGame()
	local best_game_id = self:GetBestGameID()
	if best_game_id then
		local g_id = best_game_id
		MainModel.SetLastGameID(g_id)
		GameManager.CommonGotoScence({gotoui = "game_DominoJL",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
			print("多米诺"..g_id)
		end)
	else
		local p = HintPanel.Create(5,GLL.GetTx(60003),function ()
			print(GLL.GetTx(60004))
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end)
		p:SetButtonText("", GLL.GetTx(60004))
	end
end

function C:on_fg_get_game_player_num_response(_,data)
	if data and data.result == 0 then
		self:RefreshPlayNum(data)
	end
end

--每隔20秒刷新一下人数
function C:RefreshPlayNum(data)
	if self.items[data.id] then
		self.items[data.id].player_num_txt.text = data.num
	end
	if self.num_timer then
		self.num_timer:Stop()
	end

	self.num_timer = Timer.New(
		function ()
			print("<color=red>domino</color>")
			self:SentAsk()
		end,20,1
	)
	self.num_timer:Start()
end

function C:SentAsk()
	if IsEquals(self.gameObject) then
		for i = 1,#Game_Hall_Config[self.key_name] do
			Network.SendRequest("fg_get_game_player_num",{id = Game_Hall_Config[self.key_name][i].game_id})
		end
	else
		self:MyExit()
	end
end