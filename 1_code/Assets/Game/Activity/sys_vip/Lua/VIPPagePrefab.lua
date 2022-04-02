-- 创建时间:2021-12-22
-- Panel:VIPPagePrefab
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

VIPPagePrefab = basefunc.class()
local C = VIPPagePrefab
C.name = "VIPPagePrefab"

function C.Create(parent, data, selfParent, call)
	return C.New(parent, data, selfParent, call)
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

function C:ctor(parent, data, selfParent, call)
	self.parent = parent
	self.data = data
	self.selfParent = selfParent
	self.call = call

	local obj = newObject(C.name, self.parent)
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
	EventTriggerListener.Get(self.page_1.gameObject).onClick = basefunc.handler(self, function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.selfParent, self.data)
	end)
end

function C:RemoveListenerGameObject()
	EventTriggerListener.Get(self.page_1.gameObject).onClick = nil
end

function C:InitLL()
	self.page1_txt.text = GLL.GetTx(self.data.txt)
	self.page2_txt.text = GLL.GetTx(self.data.txt)
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetSelect(b)
	self.page_1.gameObject:SetActive(not b)
	self.page_2.gameObject:SetActive(b)
end
