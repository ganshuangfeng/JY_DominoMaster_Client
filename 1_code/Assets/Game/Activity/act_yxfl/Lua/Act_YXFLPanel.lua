-- 创建时间:2022-03-16
-- Panel:Act_YXFLPanel
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

Act_YXFLPanel = basefunc.class()
local C = Act_YXFLPanel
local M = Act_YXFLManager
C.name = "Act_YXFLPanel"

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
    self.lister["mode_act_yxfl_task_change"] = basefunc.handler(self, self.on_mode_act_yxfl_task_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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
	self.key = key
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.taskCfg = M.GetTaskCfg()
    dump(self.taskCfg, "<color=white>self.taskCfg</color>")
	self:InitUI()
	self:InitLL()
	local overTime = M.GetOverTime()
	if overTime then
		local endTimeCall = function()
			self:MyExit()
			Event.Brocast("ui_button_data_change_msg",{ gotoui = M.key})
		end
		CommonTimeManager.GetCutDownTimer(overTime, self.remain_txt, nil, endTimeCall)
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:InitItems()
	self:MyRefresh()
end

local function SortCfg(cfg)
	local rCfg = basefunc.deepcopy(cfg)
	table.sort(rCfg, function(a, b)
		local dataA = GameTaskManager.GetTaskDataByID(a.task_id) or { award_status = 0}
		local dataB = GameTaskManager.GetTaskDataByID(b.task_id) or { award_status = 0}
		local stateA = dataA.award_status or 0
		local stateB = dataB.award_status or 0

        if stateA == 1 then
            stateA = -1
        end

        if stateB == 1 then
            stateB = -1
        end

        if stateA < stateB then
            return true
        elseif stateA > stateB then
            return false
        elseif a.id < b.id then
            return true
        elseif a.id > b.id then
            return false
        end
        return false
    end)
    return rCfg
end

function C:InitItems()
	self:CreateItems()
	self:RefreshItems()
end

function C:CreateItems()
	self.items = {}
	for i = 1, #self.taskCfg do
		local b = Act_YXFLItem.Create(self.Content)
		self.items[#self.items + 1] = b
	end
end

function C:RefreshItems()
	self.taskCfg = SortCfg(self.taskCfg) 
	for i = 1, #self.taskCfg do
		self.items[i]:RefreshView(self.taskCfg[i])
	end
end

function C:on_mode_act_yxfl_task_change()
	self:RefreshItems()
end

function C:MyRefresh()
end

