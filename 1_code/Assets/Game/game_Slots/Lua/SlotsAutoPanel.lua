-- 创建时间:2021-12-15
-- Panel:SlotsAutoPanel
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

SlotsAutoPanel = basefunc.class()
local M = SlotsAutoPanel
M.name = "SlotsAutoPanel"

local instance
function M.Create()
	if instance then
		instance:MyExit()
	end
	instance = M.New()
	M.Instance = instance
	return instance
end

function M.Close()
	if not instance then
		return
	end
	instance:MyExit()
end

function M.Refresh()
	if not instance then
		return
	end
	instance:MyRefresh()
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function M:RemoveListener()
	if not self.lister then
		return
	end
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	self:InitUI()
	self:MakeLister()
	self:AddMsgListener()
	self:InitLL()
	self:AddListenerGameObject()

	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
end

function M:MyRefresh()
	
end

function M:AddListenerGameObject()
	self.bg_btn.onClick:AddListener(function ()
		self:OnClickBg()
	end)
	self.auto_10_btn.onClick:AddListener(function ()
		self:OnClickAuto10()
	end)
	self.auto_30_btn.onClick:AddListener(function ()
		self:OnClickAuto30()
	end)
	self.auto_50_btn.onClick:AddListener(function ()
		self:OnClickAuto50()
	end)
	self.auto_100_btn.onClick:AddListener(function ()
		self:OnClickAuto100()
	end)
	self.auto_max_btn.onClick:AddListener(function ()
		self:OnClickAutoMax()
	end)
end

function M:RemoveListenerGameObject()
	self.bg_btn.onClick:RemoveAllListeners()
	self.auto_10_btn.onClick:RemoveAllListeners()
	self.auto_30_btn.onClick:RemoveAllListeners()
	self.auto_50_btn.onClick:RemoveAllListeners()
	self.auto_100_btn.onClick:RemoveAllListeners()
	self.auto_max_btn.onClick:RemoveAllListeners()
end

function M:OnClickBg()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function M:OnClickAuto10()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetAutoNum(10)
end

function M:OnClickAuto30()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetAutoNum(30)
end

function M:OnClickAuto50()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetAutoNum(50)
end

function M:OnClickAuto100()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetAutoNum(100)
end

function M:OnClickAutoMax()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetAutoNum(-1)
end

function M:SetAutoNum(n)
	SlotsModel.SetAutoNum(n)
	SlotsGamePanel.Instance:Lottery()
	self:MyExit()
end