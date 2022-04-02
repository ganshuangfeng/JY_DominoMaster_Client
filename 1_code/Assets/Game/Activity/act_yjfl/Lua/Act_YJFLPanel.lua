-- 创建时间:2022-03-08
-- Panel:Act_YJFLPanel
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

Act_YJFLPanel = basefunc.class()
local C = Act_YJFLPanel
C.name = "Act_YJFLPanel"
local M = Act_YJFLManager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_task_data_change_msg"] = basefunc.handler(self, self.on_model_task_data_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then
		self.timer:Stop()
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self.up_time_txt.text = StringHelper.formatTimeDHMS5( 7 * 24 * 3600 - os.time() + MainModel.FirstLoginTime())
	self:InitTimer()
	self:SetNormalizedPos()
end

function C:InitTimer()
	local T = os.time() -MainModel.FirstLoginTime()
	self.timer = Timer.New(
		function ()
			T = T - 1
			if T > 0 then
				self.up_time_txt.text = StringHelper.formatTimeDHMS5(7 * 24 * 3600 - os.time() + MainModel.FirstLoginTime())
			end
		end,1,-1
	)
	self.go_btn.onClick:AddListener(
		function ()
			GameManager.CommonGotoScence({gotoui = "game_Slots",})
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			local b = HintPanel.Create(1,"1,"..GLL.GetTx(81056).."\n".."2,"..GLL.GetTx(81057).."\n".."3,"..GLL.GetTx(81058))
			b:SetDescLeft()
		end
	)
	self.timer:Start()
end

function C:InitLL()
end

function C:RefreshLL()
end

local find_need = function (process,index)
	local total = 0
	for i = 1,index do
		total = total + process[i]
	end
	return total
end

function C:InitUI()
	local config_data = GameTaskManager.GetTaskConfigByTaskID(M.task_id)
	local process = config_data.process_data.process
	local awards = config_data.process_data.awards

	
	self.items = {}
	for i = 1,#process do
		local obj = nil
		local temp_ui = {}
		if i == 1 then
			obj = GameObject.Instantiate(self.first_item,self.Content)
		else
			obj = GameObject.Instantiate(self.item,self.Content)
		end
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		local award_id = awards[i]
		local award_data = config_data.award_data[award_id]
		temp_ui.need_txt.text = StringHelper.ToCash(find_need(process,i))
		temp_ui.need2_txt.text = StringHelper.ToCash(find_need(process,i))
		temp_ui.award_txt.text = StringHelper.ToCash(award_data.asset_count / 100)
		temp_ui.get_award_btn.onClick:AddListener(
			function ()
				Network.SendRequest("get_task_award_new",{id = M.task_id,award_progress_lv = i})
			end
		)
		temp_ui.mask.gameObject:SetActive(false)
		self.items[#self.items+1] = temp_ui
		obj.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local config_data = GameTaskManager.GetTaskConfigByTaskID(M.task_id)
	local process = config_data.process_data.process
    local data = GameTaskManager.GetTaskDataByID(M.task_id)
	dump(data,"任务数据")
	if not data then 
		return
	end
	local s = GameTaskManager.GetTaskStatusByData(data, #self.items)
	dump(s,"任务状态")
	for i = 1,#s do
		
		self.items[i].now_txt.gameObject:SetActive(false)
		local level = data.now_lv
		if i < level then
			if i == 1 then
				self.items[i].pro.sizeDelta = {x = 46.61,y = 22.05}
			else
				self.items[i].pro.sizeDelta = {x = 122.99,y = 22.05}
			end
		elseif i == level then
			self.items[i].now_txt.gameObject:SetActive(true)
			if i == 1 then
				self.items[i].pro.sizeDelta = {x = 46.61 * data.now_process / process[i],y = 22.05}
				self.items[i].now_txt.gameObject.transform.localPosition = Vector3.New(46.61 * data.now_process / process[i] - 25.4,92.8,0)
			else
				self.items[i].pro.sizeDelta = {x = 122.99 * data.now_process  / data.need_process,y = 22.05}
				self.items[i].now_txt.gameObject.transform.localPosition = Vector3.New(122.99 * data.now_process / data.need_process -98.90003 ,92.8,0)
			end
			self.items[i].now_txt.text = StringHelper.ToCash(data.now_total_process)
			if data.now_total_process == 0 or data.now_total_process == find_need(process,#s) then
				self.items[i].now_txt.gameObject:SetActive(false)
			end
		else
			self.items[i].pro.sizeDelta = {x = 0,y = 22.05}
		end

		self.items[i].need_txt.gameObject:SetActive(true)
		self.items[i].need2_txt.gameObject:SetActive(false)
		self.items[i].can.gameObject:SetActive(false)
		if s[i] == 1 then
			self.items[i].can.gameObject:SetActive(true)
			self.items[i].pro_title.gameObject:SetActive(true)
			self.items[i].bg_img.sprite = GetTexture("fbhd_czyk_bg_01")
		elseif s[i] == 2 then
			self.items[i].pro_title.gameObject:SetActive(true)
			self.items[i].mask.gameObject:SetActive(true)
			self.items[i].bg_img.sprite = GetTexture("fbhd_czyk_bg_02")
		else
			self.items[i].need2_txt.gameObject:SetActive(true)
			self.items[i].need_txt.gameObject:SetActive(false)
			self.items[i].pro_title.gameObject:SetActive(false)
		end
	end
end

function C:on_model_task_data_change_msg()
	self:MyRefresh()
end

function C:SetNormalizedPos()
	local data = GameTaskManager.GetTaskDataByID(M.task_id)
	dump(data,"任务数据")
	local s = GameTaskManager.GetTaskStatusByData(data, #self.items)

	local first_can_get = nil
	for i = 1,#s do
		if s[i] == 1 then
			first_can_get = i
			break
		end
	end

	if first_can_get then
		self.SV.horizontalNormalizedPosition = first_can_get / #self.items
	else
		local first_got = nil
		for i = #s,1,-1 do
			if s[i] == 2 then
				first_got = i
				break
			end
		end
		if first_got then
			self.SV.horizontalNormalizedPosition = first_got / #self.items
		else
			self.SV.horizontalNormalizedPosition = 0
		end
	end
end