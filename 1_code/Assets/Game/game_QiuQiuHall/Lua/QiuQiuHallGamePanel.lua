local basefunc = require "Game/Common/basefunc"

QiuQiuHallGamePanel = basefunc.class()
local C = QiuQiuHallGamePanel
C.name = "QiuQiuHallGamePanel"

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
	print("<color=red>QiuQiu退出</color>")
	if self.num_timer then
		self.num_timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end

	self:RemoveListener()
	self:RemoveListenerGameObject()
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
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "qiuqiu_hall", self.transform)
	ExtendSoundManager.PlaySceneBGM(audio_config.game.BGM_dating.audio_name)
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
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
    self.back_btn.onClick:RemoveAllListeners()
    self.start_btn.onClick:RemoveAllListeners()
    self.add_money_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.items or {}) do
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
	for i = 1,#config.QiuQiu do
		local temp_ui = {}
		local obj = GameObject.Instantiate( self.item,self.Content )
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.title_txt.text = config.QiuQiu[i].title
		if config.QiuQiu[i].tag then
			temp_ui.tag_img.gameObject:SetActive(true)
			temp_ui.tag_img.sprite = GetTexture(config.QiuQiu[i].tag)
		else
			temp_ui.tag_img.gameObject:SetActive(false)
		end

		temp_ui.init_stake_txt.text = StringHelper.ToCash(config.QiuQiu[i].init_stake)
		if config.QiuQiu[i].limit_max then
			temp_ui.limit_txt.text = StringHelper.ToCash(config.QiuQiu[i].limit_min).. "~"..StringHelper.ToCash(config.QiuQiu[i].limit_max)
		else
			temp_ui.limit_txt.text = StringHelper.ToCash(config.QiuQiu[i].limit_min).. "+"
		end

		if config.QiuQiu[i].chip_max then
			temp_ui.chip_limit_txt.text = "("..StringHelper.ToCash(config.QiuQiu[i].chip_min).. "~"..StringHelper.ToCash(config.QiuQiu[i].chip_max)..")"
		else
			temp_ui.chip_limit_txt.text = "("..StringHelper.ToCash(config.QiuQiu[i].chip_min).. "+"..")"
		end

		temp_ui.main_btn.onClick:AddListener(
			function ()
				local max = config.QiuQiu[i].limit_max or 999999999999
				dump(MainModel.UserInfo.jing_bi)
				if MainModel.UserInfo.jing_bi >= config.QiuQiu[i].limit_min and MainModel.UserInfo.jing_bi <= max then
					local g_id = config.QiuQiu[i].game_id
					MainModel.SetLastGameID(g_id)
					GameManager.CommonGotoScence({gotoui = "game_QiuQiu",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
						print("QiuQiu"..g_id)
					end)
				else
					local best_game_id = self:GetBestGameID()
					if best_game_id then
						--钱不够
						if MainModel.UserInfo.jing_bi < config.QiuQiu[i].limit_min then
							-- local p = HintPanel.Create(3,GLL.GetTx(60005),function ()
							-- 	self:StartGame()
							-- end,function ()
							-- 	print(GLL.GetTx(60004))
							-- 	GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
							-- end)
							-- p:SetButtonText(GLL.GetTx(60004), GLL.GetTx(60002))
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
		self.items[config.QiuQiu[i].game_id] = temp_ui
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
	for i = 1,#Game_Hall_Config.QiuQiu do
		if best_game_id == Game_Hall_Config.QiuQiu[i].game_id then
			title = Game_Hall_Config.QiuQiu[i].title
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
	for i = 1,#Game_Hall_Config.QiuQiu do
		if gold_num >= Game_Hall_Config.QiuQiu[i].limit_min then
			if Game_Hall_Config.QiuQiu[i].limit_max then
				if gold_num <= Game_Hall_Config.QiuQiu[i].limit_max then
					game_id = Game_Hall_Config.QiuQiu[i].game_id
				end
			else
				game_id = Game_Hall_Config.QiuQiu[i].game_id
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
		GameManager.CommonGotoScence({gotoui = "game_QiuQiu",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
			print("QIUQIU"..g_id)
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
			print("<color=red>QiuQiu</color>")
			self:SentAsk()
		end,20,1
	)
	self.num_timer:Start()
end

function C:SentAsk()
	-- if IsEquals(self.gameObject) then
	-- 	for i = 1,#Game_Hall_Config.QiuQiu do
	-- 		Network.SendRequest("fg_get_game_player_num",{id = Game_Hall_Config.QiuQiu[i].game_id})
	-- 	end
	-- else
	-- 	self:MyExit()
	-- end
end