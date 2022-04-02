-- 创建时间:2021-05-26
-- Panel:HallGamePanel
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

HallGamePanel = basefunc.class()
local C = HallGamePanel
C.name = "HallGamePanel"

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
    self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
	self.lister["name_changed"] = basefunc.handler(self,self.on_name_changed)
	self.lister["set_head_image_response"] = basefunc.handler(self, self.on_set_head_image)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_vip_base_info_msg"] = basefunc.handler(self, self.on_model_vip_base_info_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	GameManager.GotoUI({gotoui = "sys_banner", goto_scene_parm = "panel_close"})
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
	self.dot_del_obj = true
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

	self:MyRefresh()

	GameManager.CheckCurrGameScene()

	local head_link = MainModel.UserInfo.head_image
	local last_id = MainModel.GetLastGameID()
	local info = self:GetInfoByGameID(last_id)

	local map = {
		domino = "Domino Classic",
		domino_bet = "Domino Bet",
		ludo = "Ludo",
		QiuQiu = "QiuQiu",
		Slots = "Slots",
		game_Eliminate = "Pop Fruits",
		game_EliminateXY = "Pop Perjalanan Barat",
	}

	self.start_txt.text = map[info.game_name]

	SetHeadImg(head_link, self.head_img)
	self.head_info_btn.onClick:AddListener(function ()
		Event.Brocast("bsds_send_power",{key = "btn_1"})
		GameManager.GotoUI({gotoui = "sys_roleinfo", goto_scene_parm = "panel"})
	end)
	ExtendSoundManager.PlaySceneBGM(audio_config.game.BGM_dating.audio_name)
end

function C:InitLL()
end
function C:RefreshLL()
	self:InitLL()
end

function C:InitUI()
	local btn_map = {}
	btn_map["right_top"] = {self.rt_node4,self.rt_node3,self.rt_node2,self.rt_node1}
	btn_map["down"] = {self.d_node1,self.d_node2,self.d_node3,self.d_node4,self.d_node5,self.d_node6}
	btn_map["top"] = {self.t_node1,self.t_node2,self.t_node3,self.t_node4,self.t_node5}
	btn_map["right"] = {self.r_node1,self.r_node2,self.r_node3}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)
	self.name_txt.text = MainModel.UserInfo.name

	self.add_money_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_2"})
		GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
	end)
	self.rp_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_3"})
		MainModel.OpenDH()
	end)

	self.bm_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_11"})
		--1:普通
		--2：加倍
		GameManager.CommonGotoScence({gotoui = "game_DominoJLHall",goto_scene_parm = {domino_type = 1}}, function()
			print("进入多米诺大厅")
		end)
	end)

	self.ludo2_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_15"})
		local g_id = 46
		GameManager.CommonGotoScence({gotoui = "game_LudoHall",nil} , function()
			print("进入ludo大厅")
		end)
	end)

	self.ludo4_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_15"})
		local g_id = 47
		GameManager.CommonGotoScence({gotoui = "game_Ludo",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
			print("进入4人ludo")
		end)
	end)

	self.bm_bet_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_12"})
		--1:普通
		--2：加倍
		GameManager.CommonGotoScence({gotoui = "game_DominoJLHall",goto_scene_parm = {domino_type = 2}}, function()
			print("进入多米诺大厅 - 加倍")
		end)
	end)

	self.qiuqiu_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_13"})
		GameManager.CommonGotoScence({gotoui = "game_QiuQiuHall",} , function()
			print("进入QiuQiu")
		end)
	end)

	self.start_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_22"})
		self:onStartBtn()
	end)

	self.slots_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_14"})

		if MainModel.UserInfo.jing_bi < 20000000 then
			local msg = GLL.GetTx(60028)
			HintPanel.Create(1,msg,function ()
				GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
			end)
			return
		end

		MainModel.SetLastGameID(-1)
		GameManager.CommonGotoScence({gotoui = "game_Slots",}, function()
			Network.SendRequest("slot_jymt_enter_game",nil,nil,function (data)
				dump(data,"<color=yellow>slot_jymt_enter_game</color>")
				if data.result == 0 then
					
				else
					HintPanel.ErrorMsg(data.result)
				end
			end)
		end)
	end)
	
	self.lhd_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_23"})
		GameManager.CommonGotoScence({gotoui = "game_LZHD",}, function()
			
		end)
		print("龙虎斗")
	end)

	self.more_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_24"})
		GameManager.CommonGotoScence({gotoui = "game_MiniGame"}, function()
			print("小游戏大厅")
		end)
	end)

	self:SetVipView()
	self:SetOnOff()
	-- self:DZ()
	GameManager.GotoUI({gotoui = "sys_banner", goto_scene_parm = "panel", parent = self.banner_node})
end
function C:SetOnOff()
end

function C:MyRefresh()
	self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.rp_txt.text = StringHelper.ToRedNum( GameItemModel.GetItemCount("shop_gold_sum") )
end

function C:DZ()
	local obj1 = CustomUITool.CreateImage({name="obj_img", size={x=200,y=100},pos={x=-460,y=100,z=0},sprite="ty_button_1"}, self.transform)
	local txt1 = CustomUITool.CreateText({name="Text1", size={x=200,y=100},pos={x=-460,y=100,z=0},text="水果"}, obj1.transform)
	EventTriggerListener.Get(txt1.gameObject).onClick = function ()
		GameManager.CommonGotoScence({gotoui = "game_Eliminate"})
	end

	local obj1 = CustomUITool.CreateImage({name="obj_img", size={x=200,y=100},pos={x=-460,y=0,z=0},sprite="ty_button_1"}, self.transform)
	local txt1 = CustomUITool.CreateText({name="Text1", size={x=200,y=100},pos={x=-460,y=0,z=0},text="水浒"}, obj1.transform)
	EventTriggerListener.Get(txt1.gameObject).onClick = function ()
		GameManager.CommonGotoScence({gotoui = "game_EliminateSH"})
	end

	local obj1 = CustomUITool.CreateImage({name="obj_img", size={x=200,y=100},pos={x=-460,y=-100,z=0},sprite="ty_button_1"}, self.transform)
	local txt1 = CustomUITool.CreateText({name="Text1", size={x=200,y=100},pos={x=-460,y=-100,z=0},text="西游"}, obj1.transform)
	EventTriggerListener.Get(txt1.gameObject).onClick = function ()
		GameManager.CommonGotoScence({gotoui = "game_EliminateXY"})
	end

	local obj1 = CustomUITool.CreateImage({name="obj_img", size={x=200,y=100},pos={x=-460,y=-200,z=0},sprite="ty_button_1"}, self.transform)
	local txt1 = CustomUITool.CreateText({name="Text1", size={x=200,y=100},pos={x=-460,y=-200,z=0},text="三国"}, obj1.transform)
	EventTriggerListener.Get(txt1.gameObject).onClick = function ()
		GameManager.CommonGotoScence({gotoui = "game_EliminateSG"})
	end
end


function C:onStartBtn()
	local id = MainModel.GetLastGameID()
	if not id then
		HintPanel.Create(1,GLL.GetTx(60003),function ()
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end)
		return
	end
	local info = self:GetInfoByGameID(id)
	dump(info,"<color=red>当前的信息+++++++++++</color>")
	if MainModel.UserInfo.jing_bi >= (info.limit_min or 0) then
		local g_id = id
		if info.game_name == "ludo" then
			GameManager.CommonGotoScence({gotoui = "game_Ludo",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
				print("ludo"..g_id)
			end)
		elseif info.game_name == "QiuQiu" then
			GameManager.CommonGotoScence({gotoui = "game_QiuQiu",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
				print("ludo"..g_id)
			end)
		elseif info.game_name == "Slots" then
			GameManager.CommonGotoScence({gotoui = "game_Slots",}, function()
				print("Slots 游戏进入")
				MainModel.SetLastGameID(-1)
				Network.SendRequest("slot_jymt_enter_game",nil,nil,function (data)
					dump(data,"<color=yellow>slot_jymt_enter_game</color>")
					if data.result == 0 then
						
					else
						HintPanel.ErrorMsg(data.result)
					end
				end)
			end)
		elseif info.game_name == "game_Eliminate" or info.game_name == "game_EliminateXY" then
			GameManager.CommonGotoScence({gotoui = info.game_name})
		else
			GameManager.CommonGotoScence({gotoui = "game_DominoJL",p_requset = {id = g_id,},goto_scene_parm={game_id = g_id}} , function()
				print("多米诺"..g_id)
			end)
		end
	else
		HintPanel.Create(1,GLL.GetTx(60003),function ()
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end)
	end
end

function C:GetInfoByGameID(id)
	if id == -1 then
		return {game_name = "Slots"}
	elseif id == -2 then
		return {game_name = "game_Eliminate"}
	elseif id == -3 then
		return {game_name = "game_EliminateXY"}
	end

	local keys = MainLogic.GetGameKeys()
	for i = 1,#keys do
		for ii = 1,#Game_Hall_Config[keys[i]] do
			if Game_Hall_Config[keys[i]][ii].game_id == id then
				Game_Hall_Config[keys[i]][ii].game_name = keys[i]
				return Game_Hall_Config[keys[i]][ii]
			end
		end
	end
	return Game_Hall_Config["domino"][1]
end


function C:on_set_head_image()
	local head_link = MainModel.UserInfo.head_image
	SetHeadImg(head_link, self.head_img)
end

function C:on_name_changed()
	self.name_txt.text = MainModel.UserInfo.name
end

function C:on_model_vip_base_info_msg()
	self:SetVipView()
end

function C:SetVipView()
	self.cur_data = SysVipManager.GetVipData()
	self.cur_config = SysVipManager.GetVipConfigByLevel(self.cur_data.level)
	self.vip_txt.text = "VIP"..self.cur_data.level
end