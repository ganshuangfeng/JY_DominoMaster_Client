-- 创建时间:2022-01-12
-- Panel:ActYoukeBindEnter
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

ActYoukeBindEnter = basefunc.class()
local C = ActYoukeBindEnter
C.name = "ActYoukeBindEnter"

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
    self.lister["model_login_channels_msg"] = basefunc.handler(self, self.MyRefresh)
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
	ExtPanel.ExtMsg(self)
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
	self.fb_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "personal_info_3"})
		ActYoukeBindPanel.Create("facebook")
	end)
	self.gg_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("bsds_send_power",{key = "personal_info_3"})
		ActYoukeBindPanel.Create("google")
	end)
end

function C:RemoveListenerGameObject()
	self.fb_btn.onClick:RemoveAllListeners()
	self.gg_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
	if ActYoukeBindManager.m_data.channel_map then
		local data = ActYoukeBindManager.m_data.channel_map
		if data.facebook or data.google then
			self.fb_btn.gameObject:SetActive(false)
			self.gg_btn.gameObject:SetActive(false)
			--self.hint.gameObject:SetActive(false)
			self.bind.gameObject:SetActive(true)
		else
			self.fb_btn.gameObject:SetActive(true)
			self.gg_btn.gameObject:SetActive(true)
			--self.hint.gameObject:SetActive(true)
			self.bind.gameObject:SetActive(false)
		end
	end
end
