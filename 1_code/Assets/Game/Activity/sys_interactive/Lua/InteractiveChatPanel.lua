-- 创建时间:2021-12-15
-- Panel:InteractiveChatPanel
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

InteractiveChatPanel = basefunc.class()
local C = InteractiveChatPanel
C.name = "InteractiveChatPanel"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
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
	self.jif_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(1)
	end)
	self.txt_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(2)
	end)
	EventTriggerListener.Get(self.Black.gameObject).onClick = basefunc.handler(self, function ()
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.jif_btn.onClick:RemoveAllListeners()
	self.txt_btn.onClick:RemoveAllListeners()
	EventTriggerListener.Get(self.Black.gameObject).onClick = nil
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.tag = 1
	
	

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshSelect()
end

function C:RefreshSelect()
	if self.cur_pre then
		self.cur_pre:OnDestroy()
		self.cur_pre = nil
	end

	if self.tag == 1 then
		self.cur_pre = InteractiveChatJifPrefab.Create(self.pre_node, self)
	else
		self.cur_pre = InteractiveChatTxtPrefab.Create(self.pre_node, self)
	end

	self.gif_sel.gameObject:SetActive(self.tag == 1)
	self.txt_sel.gameObject:SetActive(self.tag == 2)
end

function C:Select(tag)
	if self.tag ~= tag then
		self.tag = tag
		self:RefreshSelect()
	end
end
