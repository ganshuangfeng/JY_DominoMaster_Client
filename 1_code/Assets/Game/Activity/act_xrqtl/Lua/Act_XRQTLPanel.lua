-- 创建时间:2022-01-04
-- Panel:Act_XRQTLPanel
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

Act_XRQTLPanel = basefunc.class()
local C = Act_XRQTLPanel
local M = Act_XRQTLManager
C.name = "Act_XRQTLPanel"

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
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["mode_act_xrqtl_task_change"] = basefunc.handler(self, self.on_mode_act_xrqtl_task_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.goto_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local gotoUI = self.curCfg.gotoUI
		if type(gotoUI) == "table" then
			GameManager.GotoUI({gotoui = gotoUI[1], goto_scene_parm = gotoUI[2]})
		else
			GameManager.GotoUI({gotoui = gotoUI})
		end
	end)
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)

	self.get_btn.onClick:AddListener(function()
		dump("<color=white>新人七天乐:领取奖励</color>")
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Network.SendRequest("get_task_award", { id = self.curCfg.task_id})
	end)
end

function C:RemoveListenerGameObject()
	self.goto_btn.onClick:RemoveAllListeners()
	self.close_btn.onClick:RemoveAllListeners()
	self.get_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.cfg = M.GetCfg()
	self:InitItems()
	
	self.goto_txt.text = GLL.GetTx(70006)
	self.get_txt.text = GLL.GetTx(70007)
	self.get_gray_txt.text = GLL.GetTx(70007)
	self:MyRefresh()
end

function C:InitItems()
	self.items = {}
	for i = 1, 7 do
		local cfg = self.cfg[i] 
		local obj = newObject("Act_XRQTLItem", self.nodes.transform)
		local item = {obj = obj, ui = {}}
		LuaHelper.GeneratingVar(item.obj.transform, item.ui)
		item.ui.icon_img.sprite = GetTexture(cfg.award_img)
		item.ui.desc_txt.text = string.format(GLL.GetTx(80004), i)
		item.ui.num_txt.text = StringHelper.ToCash(cfg.award_num)
		QPPrefab.AddShowItem(item.ui.icon_img:GetComponent("Button"), cfg.award_item_key)
		self.items[#self.items + 1] = item
	end
end

function C:MyRefresh()
	self.curDay = M.GetCurDay()
	-- self.curDay = 6
	self.curCfg = self.cfg[self.curDay]
	self.curTaskData = GameTaskManager.GetTaskDataByID(self.curCfg.task_id)
	self.cur_day_txt.text = string.format(GLL.GetTx(80004), self.curDay)
	local task_need_progress = StringHelper.ToCash(self.curCfg.task_need_progress)
	self.task_txt.text = string.format(GLL.GetTx(self.curCfg.task_desc), task_need_progress)
	local states = M.GetAllTaskStates()
	-- states = {2,1,2,0,0,0,0}
	self:RefreshItems(states)
	self:RefreshGotoBtn(states)
	self:RefreshProgressUI()
end

function C:RefreshItems(states) 
	for i = 1, #self.items do
		local state = states[i]
		local item = self.items[i]
		item.ui.cur_day.gameObject:SetActive(i == self.curDay and  state ~= 2)
		-- item.ui.other_day.gameObject:SetActive(i ~= self.curDay)
		item.ui.geted.gameObject:SetActive(state == 2)
		item.ui.overtime.gameObject:SetActive(i < self.curDay and state ~= 2)
	end
end

function C:RefreshGotoBtn(states)
	local state =  states[self.curDay]
	self.get_btn.gameObject:SetActive(state == 1)
	self.goto_btn.gameObject:SetActive(state == 0)
	self.get_gray.gameObject:SetActive(state == 2)
end

function C:RefreshProgressUI()
	if not self.curTaskData then
		dump("<color=red>未获取到任务数据</color>")
		return
	end

	local w = (self.curTaskData.now_process / self.curCfg.task_need_progress) * 296.15
	self.pg:GetComponent("RectTransform").sizeDelta = {x = w, y = 20.58}
	self.pg_txt.text = StringHelper.ToCash(self.curTaskData.now_process)
end

function C:on_mode_act_xrqtl_task_change()
	self:MyRefresh()
end