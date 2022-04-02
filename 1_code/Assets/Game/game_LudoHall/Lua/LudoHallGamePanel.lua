local basefunc = require "Game/Common/basefunc"

LudoHallGamePanel = basefunc.class()
local C = LudoHallGamePanel
C.name = "LudoHallGamePanel"

function C.Create()
	return C.New()
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
	print("<color=red>Ludo退出</color>")
	if self.num_timer then
		self.num_timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end

	self:RemoveListener()
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:SentAsk()
	local btn_map = {}
	btn_map["left_node"] = {self.left_node1,self.left_node2,self.left_node3,self.left_node4}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "ludo_hall", self.transform)
	ExtendSoundManager.PlaySceneBGM(audio_config.game.BGM_dating.audio_name)
	self:InitExchangePanel()
	
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.exchange_btn.onClick:AddListener(
		function ()
			self.exchang_panel.gameObject:SetActive(true)
		end
	)
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
    self.exchange_btn.onClick:RemoveAllListeners()
    self.back_btn.onClick:RemoveAllListeners()
    self.start_btn.onClick:RemoveAllListeners()
    self.add_money_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.items) do
		v.main_btn.onClick:RemoveAllListeners()
	end

	local  config = {
		blue = "ludo_qizi_lanse",
		yellow = "ludo_qizi_huangse",
		green = "ludo_qizi_lvse",
		red = "ludo_qizi_hongse",
	}
	for k ,v in pairs(config) do
		dump(k)
		self["exchange_"..k.."_btn"].onClick:RemoveAllListeners()
	end
	self.exchange_back_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	local config = Game_Hall_Config
	self.items = {}
	
	for i = 1,#config.ludo do
		local temp_ui = {}
		local obj = GameObject.Instantiate( self.item,self.Content )
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.title_txt.text = config.ludo[i].title
		if config.ludo[i].tag then
			temp_ui.tag_img.gameObject:SetActive(true)
			temp_ui.tag_img.sprite = GetTexture(config.ludo[i].tag)
		else
			temp_ui.tag_img.gameObject:SetActive(false)
		end

		temp_ui.init_stake_txt.text = StringHelper.ToCash(config.ludo[i].init_stake)
		if config.ludo[i].limit_max then
			temp_ui.limit_txt.text = StringHelper.ToCash(config.ludo[i].limit_min).. "~"..StringHelper.ToCash(config.ludo[i].limit_max)
		else
			temp_ui.limit_txt.text = StringHelper.ToCash(config.ludo[i].limit_min).. "+"
		end

		if config.ludo[i].game_id < 55 then
			temp_ui.tips_jb.gameObject:SetActive(true)
		else
			temp_ui.tips_rp.gameObject:SetActive(true)
		end

		temp_ui.main_btn.onClick:AddListener(
			function ()
				local max = config.ludo[i].limit_max or 999999999999
				if MainModel.UserInfo.jing_bi >= config.ludo[i].limit_min and MainModel.UserInfo.jing_bi <= max then
					local g_id = config.ludo[i].game_id
					MainModel.SetLastGameID(g_id)
					GameManager.CommonGotoScence({gotoui = "game_Ludo",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
						print("ludo"..g_id)
					end)
				else
					local best_game_id = self:GetBestGameID()
					if best_game_id then
						--钱不够
						if MainModel.UserInfo.jing_bi < config.ludo[i].limit_min then
							-- local p = HintPanel.Create(3,GLL.GetTx(60005),function ()
							-- 	self:StartGame()
							-- end,function ()
							-- 	print(GLL.GetTx(60004))
							-- 	GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
							-- end)
							-- p:SetButtonText(GLL.GetTx(60004), GLL.GetTx(60002))
							--钱不满足最低要求
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
						--钱不满足最低要求
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
		self.items[config.ludo[i].game_id] = temp_ui
	end
	
	
	self:MyRefresh()
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
	for i = 1,#Game_Hall_Config.ludo do
		if best_game_id == Game_Hall_Config.ludo[i].game_id then
			title = Game_Hall_Config.ludo[i].title
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
	for i = 1,#Game_Hall_Config.ludo do
		if gold_num >= Game_Hall_Config.ludo[i].limit_min then
			if Game_Hall_Config.ludo[i].limit_max then
				if gold_num <= Game_Hall_Config.ludo[i].limit_max then
					game_id = Game_Hall_Config.ludo[i].game_id
				end
			else
				game_id = Game_Hall_Config.ludo[i].game_id
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
		GameManager.CommonGotoScence({gotoui = "game_Ludo",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
			print("多米诺"..g_id)
		end)
	else
		SysBrokeSubsidyManager.RunBrokeProcess()
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
			print("<color=red>ludo</color>")
			self:SentAsk()
		end,20,1
	)
	self.num_timer:Start()
end

function C:SentAsk()
	if IsEquals(self.gameObject) then
		for i = 1,#Game_Hall_Config.ludo do
			Network.SendRequest("fg_get_game_player_num",{id = Game_Hall_Config.ludo[i].game_id})
		end
	else
		self:MyExit()
	end
end

function C:InitExchangePanel()
	local  config = {
		blue = "ludo_qizi_lanse",
		yellow = "ludo_qizi_huangse",
		green = "ludo_qizi_lvse",
		red = "ludo_qizi_hongse",
	}
	self.exchang_panel.gameObject:SetActive(false)

	local base_color = PlayerPrefs.GetString(MainModel.UserInfo.user_id.."ludo_color","blue")
	self.chess_img.sprite = GetTexture(config[base_color])


	for k , v in pairs(config) do
		self["choosed_"..k].gameObject:SetActive(false)
	end
	self["choosed_"..base_color  ].gameObject:SetActive(true)
	local click_func = function (color)
		dump(color,"<color=red>1111111111111111</color>")
		self.chess_img.sprite = GetTexture(config[color])
		for k , v in pairs(config) do
			self["choosed_"..k].gameObject:SetActive(false)
		end
		self["choosed_"..color].gameObject:SetActive(true)
		PlayerPrefs.SetString(MainModel.UserInfo.user_id.."ludo_color",color)
	end

	for k ,v in pairs(config) do
		dump(k)
		self["exchange_"..k.."_btn"].onClick:AddListener(
			function ()
				click_func(k)
				self.exchang_panel.gameObject:SetActive(false)
			end
		)
	end
	self.exchange_back_btn.onClick:AddListener(
		function ()
			self.exchang_panel.gameObject:SetActive(false)
		end
	)
end