-- 创建时间:2022-01-07
-- Panel:Act_RoulettePanel
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

Act_RoulettePanel = basefunc.class()
local C = Act_RoulettePanel
C.name = "Act_RoulettePanel"

function C.Create(parent, backcall)
	return C.New(parent, backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["AssetChange"] = basefunc.handler(self,self.AssetChange)
    self.lister["model_roulette_task_data_msg"] = basefunc.handler(self, self.RefreshRed)
    self.lister["act_roulette_data_change_msg"] = basefunc.handler(self, self.RefreshRed)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.cur_pre then
		self.cur_pre:OnDestroy()
		self.cur_pre = nil
	end
	if self.pmd_cont then
		self.pmd_cont:MyExit()
	end

	if self.backcall then
		self.backcall()
	end
	self.backcall = nil
	
	if self.box_award then
		Event.Brocast("AssetGet", self.box_award)
	end
	GameModuleManager.RunFunExt("sys_vip", "SetHbLimitTag", nil, nil)	
	self.box_award = nil

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

function C:ctor(parent, backcall)
	ExtPanel.ExtMsg(self)
	self.backcall = backcall

	parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.is_close_gb = true
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.rp_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		print("rp")
	end)
	self.jb_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
	end)
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Act_RouletteRulesPanel.Create(self.tag)
	end)
	self.wheel_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(1)
	end)
	self.vipwheel_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(2)
	end)
end

function C:RemoveListenerGameObject()
	self.rp_btn.onClick:RemoveAllListeners()
	self.jb_btn.onClick:RemoveAllListeners()
	self.back_btn.onClick:RemoveAllListeners()
	self.help_btn.onClick:RemoveAllListeners()
	self.wheel_btn.onClick:RemoveAllListeners()
	self.vipwheel_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	if Act_RouletteManager.close_whell then
		self.tag = 2
		self.tag_obj.gameObject:SetActive(false)
	else
		self.tag = 1
		self.tag_obj.gameObject:SetActive(true)
	end

	if _G["SysVipManager"] and MainModel.UserInfo.vip_level > 0 then
		local item_n = GameItemModel.GetItemCount("prop_xycj_coin")
		local free_n = Act_RouletteManager.m_data.free_num or 0
		if item_n <= 0 and free_n <= 0 then
			self.tag = 2
		end
	end

	self:MyRefresh()

	GameModuleManager.RunFunExt("sys_vip", "SetHbLimitTag", nil, true)
end

function C:MyRefresh()
	if self.is_close_gb then
		self.gb.gameObject:SetActive(false)
	else
		self.gb.gameObject:SetActive(true)
		self.pmd_cont = CommonPMDManager.Create(self, self.CreatePMD, { send_t = 10, data_type = "xydzp", start_pos = 400, end_pos = -400 })
	end
	self:RefreshAsset()
	self:RefreshSelect()
	self:RefreshRed()
end

function C:RefreshRed()
	if Act_RouletteManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get or Act_RouletteManager.IsCanLuck(1) then
		self.wheel_red.gameObject:SetActive(true)
	else
		self.wheel_red.gameObject:SetActive(false)
	end
end

function C:AssetChange(data)
	if data.change_type == "lottery_luck_box" then
		self.box_award = {data = data.data, change_type = data.change_type, callback = function ()
			Event.Brocast("hint_hb_limit_convert_msg")
		end}
	else
		if not self.isLock then
			self:RefreshAsset()
		end	
	end
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(GetPrefab("RouletteBroadcastCell"), self.pmd_node)
	local ui_t = {}
	LuaHelper.GeneratingVar(obj.transform, ui_t)
	local ss = StringHelper.Split(data.award_data, "#")
	if tonumber(ss[1]) > 0 then
		ui_t.vip.gameObject:SetActive(true)
		ui_t.vip_txt.text = "VIP"..ss[1]
	else
		ui_t.vip.gameObject:SetActive(false)
	end
	ui_t.gb2_txt.text = data.player_name
	ui_t.gb4_txt.text = ss[2]
	return obj
end

function C:RefreshAsset()
	self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.rp_txt.text = StringHelper.ToRedNum( GameItemModel.GetItemCount("shop_gold_sum") )
end

function C:ManualRefreshAsset(jb, rp)
	self.money_txt.text = StringHelper.ToCash(jb)
	if rp then
		self.rp_txt.text = StringHelper.ToRedNum(rp)
	end
end

function C:RefreshSelect()
	if self.cur_pre then
		self.cur_pre:OnDestroy()
		self.cur_pre = nil
	end

	if self.tag == 1 then
		self.cur_pre = Act_RouletteWheelPanel.Create(self.center, self)
	else
		self.cur_pre = Act_RouletteVipWheelPanel.Create(self.center, self)
	end

	self.wheel_btn.gameObject:SetActive(self.tag ~= 1)
	self.vipwheel_btn.gameObject:SetActive(self.tag ~= 2)
	self.wheel_hi.gameObject:SetActive(self.tag == 1)
	self.vipwheel_hi.gameObject:SetActive(self.tag == 2)

	self.isLock = false
	self:RefreshAsset()
end

function C:Select(tag)
	if self.tag ~= tag then
		self.tag = tag
		self:RefreshSelect()
	end
end

function C:OpenBox(tag, n, call)
	Network.SendRequest("pay_luck_lottery", { id = tag, num = n }, "", function (data)
		self.isLock = true
		dump(data, "pay_luck_lottery")
		if data.result == 0 then
			call(data)
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:OpenBoxFinish()
	if self.box_award then
		Event.Brocast("AssetGet", self.box_award)
	end
	self.box_award = nil
	self.isLock = false
	self:RefreshAsset()
end
