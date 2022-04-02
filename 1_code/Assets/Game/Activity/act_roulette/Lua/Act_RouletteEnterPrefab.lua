-- 创建时间:2022-01-07
-- Panel:Act_RouletteEnterPrefab
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

Act_RouletteEnterPrefab = basefunc.class()
local C = Act_RouletteEnterPrefab
C.name = "Act_RouletteEnterPrefab"

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
    self.lister["model_roulette_task_data_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["act_roulette_data_change_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent)
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
	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "btn_6"})
		Act_RouletteManager.SetEnterClick()
		Act_RoulettePanel.Create()
	end)
end

function C:RemoveListenerGameObject()
	self.enter_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
	if Act_RouletteManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.tips.gameObject:SetActive(true)
	else
		self.tips.gameObject:SetActive(false)
	end

	self.red.gameObject:SetActive(Act_RouletteManager.IsCanLuck(1))
end
