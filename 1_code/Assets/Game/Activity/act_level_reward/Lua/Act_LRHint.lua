-- 创建时间:2022-03-01
-- Panel:Act_LRHint
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

Act_LRHint = basefunc.class()
local C = Act_LRHint
local M = Act_LRManager
C.name = "Act_LRHint"

local instance

function C.Create(data)
	if instance then
		instance:MyExit()
		instance = nil
	end
	instance = C.New(data)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
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

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.canvasGroup = self.transform:GetComponent("CanvasGroup") 
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
	self.hint.transform.localPosition = Vector3.New(0, 430, 0)
	self.hint_txt.text = "Selamat mencapai level " .. self.data.level .. ",\nbisa ambil hadiah peti harta level."
	self.seqMove = DoTweenSequence.Create({dotweenLayerKey = M.key})
	self.seqMove:Append(self.hint.transform:DOLocalMoveY(300, 0.5))
	self.seqMove:AppendInterval(5)
	self.seqMove:Append(self.canvasGroup:DOFade(0, 0.2))
	self.seqMove:OnKill(function ()
		if IsEquals(self.gameObject) then
			self:MyExit()
		end
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
	instance = nil
end

function C:OnEnterBackGround()
	self:MyExit()
	instance = nil
end
