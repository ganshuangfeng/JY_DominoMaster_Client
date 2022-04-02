-- 创建时间:2022-01-05
-- Panel:Sys_LoginDisplayView
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

Sys_LoginDisplayView = basefunc.class()
local C = Sys_LoginDisplayView
local M = Sys_LoginDisplayManager
C.name = "Sys_LoginDisplayView"

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
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.panel and self.panelExitFun then
		self.panel["MyExit"] = self.panelExitFun()
	end
	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	self:MakeLister()
	self:AddMsgListener()
	M.InitData()
	self.showData = M.GetShowData()
	self:InitUI()
	self:InitLL()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	M.SetFirstLogin(false)
	if table_is_null(self.showData) then
		self:MyExit()
	end
	self.curShowIndex = 1
	self.allShowIndex = #self.showData
	self:Check()
end

function C:Show()
	local gotoUI = self.showData[self.curShowIndex].gotoUI
	local parm = {}
	SetTempParm(parm, gotoUI)
	self.panel = GameManager.GotoUI(parm)
	if not self.panel then
		self:ShowEnd()
		return
	end
	self.gameObject = self.panel.gameObject
	self.panelExitFun = self.panel["MyExit"]
	self.panel["MyExit"] = function()
		self.panelExitFun()
		self:ShowEnd()
	end
end

function C:ShowEnd()
	if self.panelExitFun then
		self.panel["MyExit"] = self.panelExitFun()
	end
	self.panel = nil
	self.panelExitFun = nil
	self.curShowIndex = self.curShowIndex + 1
	self:Check()
end

function C:Check()
	if self.curShowIndex <= self.allShowIndex then
		coroutine.start(function ( )
			Yield(0)
			self:Show()
		end)
	else
		self:MyExit()
	end
end

function C:OnExitScene()
	self:MyExit()
end