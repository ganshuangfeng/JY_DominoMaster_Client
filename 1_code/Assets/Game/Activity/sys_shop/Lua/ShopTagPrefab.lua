-- 创建时间:2022-01-14
-- Panel:ShopTagPrefab
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

ShopTagPrefab = basefunc.class()
local C = ShopTagPrefab
C.name = "ShopTagPrefab"

function C.Create(parent_transform, data, call, panelSelf)
	return C.New(parent_transform, data, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
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

function C:ctor(parent_transform, data, call, panelSelf)
	self.data = data
	self.call = call
	self.panelSelf = panelSelf

	ExtPanel.ExtMsg(self)
	local obj = newObject(C.name, parent_transform)
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
	self.tag_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.data)
	end)
end

function C:RemoveListenerGameObject()
	self.tag_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
	if self.data.give then
		self.give.gameObject:SetActive(true)
		self.give_txt.text = self.data.give
	else
		self.give.gameObject:SetActive(false)
	end

	self.tag_hi_txt.text = self.data.name
	self.tag_no_txt.text = self.data.name
end

function C:SetSelect(tag)
	local b = false
	if self.data.tag == tag then
		b = true
	end
	self.tag_btn.gameObject:SetActive(not b)
	self.tag_no.gameObject:SetActive(b)
end
