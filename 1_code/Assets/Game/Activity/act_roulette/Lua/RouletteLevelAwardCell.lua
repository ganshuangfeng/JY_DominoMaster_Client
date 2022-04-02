-- 创建时间:2022-01-07
-- Panel:RouletteLevelAwardCell
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

RouletteLevelAwardCell = basefunc.class()
local C = RouletteLevelAwardCell
C.name = "RouletteLevelAwardCell"

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_roulette_task_data_msg"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent, data)
	self.data = data

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
	self.dj_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Network.SendRequest("get_task_award_new",{id = Act_RouletteManager.m_data.level_task_id, award_progress_lv = self.data.index}, "")
	end)
	EventTriggerListener.Get(self.bg.gameObject).onClick = basefunc.handler(self, function()
		if self.status == 0 then
			HintPanel.Create(1, string.format(GLL.GetTx(80025), self.data.lvl))
		end
	end)
end

function C:RemoveListenerGameObject()
	self.dj_btn.onClick:RemoveAllListeners()
	EventTriggerListener.Get(self.bg.gameObject).onClick = nil
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	
	self:MyRefresh()
end

function C:MyRefresh()
	self.status = Act_RouletteManager.GetLevelAwardStage(self.data.index)
	if self.status == 1 then
		self.tips.gameObject:SetActive(true)
		self.dj_btn.gameObject:SetActive(true)
		self.get.gameObject:SetActive(false)
	else
		self.tips.gameObject:SetActive(false)
		self.dj_btn.gameObject:SetActive(false)
		self.get.gameObject:SetActive(false)
		if self.status == 2 then
			self.get.gameObject:SetActive(true)
		end
	end
	self.lvl_txt.text = "LV"..self.data.lvl
end
