-- 创建时间:2021-12-31
-- Panel:Act_AccumulateWinPanel
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

Act_AccumulateWinPanel = basefunc.class()
local C = Act_AccumulateWinPanel
local M = Act_AccumulateWinManager
C.name = "Act_AccumulateWinPanel"

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
    self.lister["mode_act_accumulate_win_task_change"] = basefunc.handler(self, self.on_mode_act_accumulate_win_task_change)
    self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_fg_all_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.exchange_btn:MyExit()
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
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	-- for k, v in pairs(self.items) do
	-- 	v.ui.get_btn.onClick:RemoveAllListeners()
	-- end
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	for i, v in ipairs(self.items or {}) do
		v.ui.get_btn.onClick:RemoveAllListeners()
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.scroll = self.transform:Find("ScrollView1"):GetComponent("ScrollRect")
	self.scroll.enabled = false

	self.game_id = M.GetCurGameId()
	if not self.game_id then
		dump("<color=white>累胜:未获取到game_id</color>")
		return
	end
	self:InitItems()
	self.exchange_btn = GameManager.GotoUI({gotoui = "sys_dh", goto_scene_parm = "enter", parent = self.exchange_node})
	self.exchange_btn.gameObject:GetComponent("Canvas").sortingOrder = 4
	ChangeOrderInLayer(self.exchange_btn, 3, true)
	self:MyRefresh()
end

function C:InitItems()
	self.cfg = M.GetCfgFromGameID(self.game_id)
	self.pg_cfg = M.GetNeedProgressList()
	self.award_img_cfg = M.GetAwardImageList()
	self:InitItemPre()
	self:InitPgNodePre()
	self:InitNodeBgPre()
	self:MyRefresh()
end

function C:InitItemPre()
	self.items = {}
	local task_id = self.cfg.task_id
	for i = 1, #self.pg_cfg do
		local obj = newObject("Act_AccumulateWinItem", self.Content2)
		local item = {obj = obj, ui = {}}
		LuaHelper.GeneratingVar(item.obj.transform, item.ui)
		item.ui.icon_img.sprite = GetTexture(self.award_img_cfg[i])
		item.ui.need_num_txt.text = self.cfg.award_num_list[i]
		item.ui.get_btn.onClick:AddListener(function()
			dump("<color=white>累胜:领取奖励" .. i .."</color>")
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("get_task_award_new", { id = task_id, award_progress_lv = i })
		end)
		self.items[#self.items + 1] = item
	end
end

function C:InitPgNodePre()
	self.pgNodes = {}
	for i = 1, #self.pg_cfg do
		local obj = newObject("Act_AccumulateWinPgNode", self.Content3)
		local pgNode = {obj = obj}
		pgNode.obj.transform:Find("NodeTxt"):GetComponent("Text").text = self.pg_cfg[i]
		pgNode.obj.gameObject:SetActive(false)
		self.pgNodes[#self.pgNodes + 1] = pgNode
	end
end

function C:InitNodeBgPre()
	self.pgNodeBgs = {}
	for i = 1, #self.pg_cfg do
		local obj = newObject("Act_AccumulateWinPgNodeBg", self.Content1)
		local pgNodeBg = {obj = obj, ui = {}}
		LuaHelper.GeneratingVar(pgNodeBg.obj.transform, pgNodeBg.ui)
		pgNodeBg.ui.node_bg_txt.text = self.pg_cfg[i]
		self.pgNodeBgs[#self.pgNodeBgs + 1] = pgNodeBg

	end
	self.pgNodeBgs[1].ui.begin_node.gameObject:SetActive(true)
	self.pgNodeBgs[1].ui.behind.gameObject:SetActive(false)
	self.pgNodeBgs[#self.pgNodeBgs].ui.end_node.gameObject:SetActive(true)
end


function C:MyRefresh()
	-- self:RefreshProgressUI(22)
	-- self:RefreshItems({2,2,1,1,1,1,0})

	if not self.game_id then
		return
	end

	self.taskData = GameTaskManager.GetTaskDataByID(self.cfg.task_id)
	if not self.taskData then
		dump("<color=red>累胜:未获取到任务数据</color>")
		return
	end
	dump(self.taskData, "aaa")

	local states = GameTaskManager.GetTaskStatusByData(self.taskData, #self.pg_cfg)
	-- local states = basefunc.decode_task_award_status(self.taskData.award_get_status)
	-- states = basefunc.decode_all_task_award_status(states, self.taskData, #self.pg_cfg)

	self:RefreshProgressUI(self.taskData.now_total_process)
	self:RefreshItems(states)
end

local pgWidths = {0, 92.5, 234.5, 377.5, 520.5, 662.5, 805.5}
local wDStart = 30
local wDEnd = 153
local wD = 78

function C:RefreshProgressUI(total)
	-- total = 24
	local processLv = 1
	self.total_txt.text = total
	for i = 1, #self.pg_cfg do
		if self.pg_cfg[i] < total then
			self.pgNodes[i].obj.gameObject:SetActive(true)
		elseif self.pg_cfg[i] > total then
			self.pgNodes[i].obj.gameObject:SetActive(false)
		else
			self.pgNodes[i].obj.gameObject:SetActive(true)
		end

		if i > 1 and self.pg_cfg[i - 1] <= total then
			if i == #self.pg_cfg or self.pg_cfg[i] > total then
				processLv = i
			end
		end
	end
	-- dump(processLv)
	local wStart = pgWidths[processLv]
	local d = wD
	if processLv == 1 then d = wDStart end
	if total >= self.pg_cfg[#self.pg_cfg] then d = wDEnd end
	local w
	if processLv == 1 then
		w = wStart + (total / self.pg_cfg[processLv]) * d
	else
		local lastNeedPg = self.pg_cfg[processLv - 1]
		local curNeedPg = self.pg_cfg[processLv]
		w = wStart + ((total - lastNeedPg) / (curNeedPg - lastNeedPg)) * d
	end
	self.pg:GetComponent("RectTransform").sizeDelta = {x = w, y = 20}
end

function C:RefreshItems(states)
	for i = 1, #self.items do
		local state = states[i]
		local item = self.items[i]
		item.ui.cannot_get.gameObject:SetActive(state == 0)
		item.ui.can_get.gameObject:SetActive(state == 1)
		item.ui.geted.gameObject:SetActive(state == 2)
	end
end

function C:on_mode_act_accumulate_win_task_change()
	self:MyRefresh()
end

function C:on_fg_all_info()
	if not self.game_id then
		self.game_id = M.GetCurGameId()
		self:InitItems()
		self:MyRefresh()
	end
end