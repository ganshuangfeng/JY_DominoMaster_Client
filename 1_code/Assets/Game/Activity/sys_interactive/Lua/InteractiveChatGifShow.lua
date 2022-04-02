-- 创建时间:2022-02-07
-- Panel:InteractiveChatGifShow
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

InteractiveChatGifShow = basefunc.class()
local C = InteractiveChatGifShow
C.name = "InteractiveChatGifShow"

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
	ExtPanel.ExtMsg(self)
	local obj = newObject(self.data.config.prefab, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.transform.position = self.data.pos
	self.transform.localScale = Vector3.New(0.6, 0.6, 0.6)
	
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
	if self.data.config.audio then
		self.audio_key = ExtendSoundManager.PlaySound(self.data.config.audio)
	end

    self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(self.data.config.show_time)
    self.seq:OnForceKill(function ()
        self:MyExit()
    end)
end
