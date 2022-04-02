-- 创建时间:2021-12-15
-- Panel:InteractiveChatTxtShow
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

InteractiveChatTxtShow = basefunc.class()
local C = InteractiveChatTxtShow
C.name = "InteractiveChatTxtShow"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	ExtendSoundManager.CloseSound(self.audio_key)
	
	self:RemoveListener()
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
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.transform.position = self.data.pos

	if self.data.pos.x <= 0 and self.data.pos.y <= 0 then
		self.node.transform.localScale = Vector3.New(1, 1, 1)
		self.desc_txt.transform.localScale = Vector3.New(1, 1, 1)
	elseif self.data.pos.x >= 0 and self.data.pos.y <= 0 then
		self.node.transform.localScale = Vector3.New(-1, 1, 1)
		self.desc_txt.transform.localScale = Vector3.New(-1, 1, 1)
	elseif self.data.pos.x <= 0 and self.data.pos.y >= 0 then
		self.node.transform.localScale = Vector3.New(1, -1, 1)
		self.desc_txt.transform.localScale = Vector3.New(1, -1, 1)
	else
		self.node.transform.localScale = Vector3.New(-1, -1, 1)
		self.desc_txt.transform.localScale = Vector3.New(-1, -1, 1)
	end

	if self.data.config.audio then
		self.audio_key = ExtendSoundManager.PlaySound(self.data.config.audio)
	end

	self.desc_txt.text = self.data.config.desc
	self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(self.data.config.show_time)
    self.seq:OnForceKill(function ()
		self:MyExit()
    end)
end
