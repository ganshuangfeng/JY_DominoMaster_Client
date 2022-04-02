-- 创建时间:2022-01-12
-- Panel:Act_RouletteRulesPanel
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

Act_RouletteRulesPanel = basefunc.class()
local C = Act_RouletteRulesPanel
C.name = "Act_RouletteRulesPanel"

function C.Create(tag)
	return C.New(tag)
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

function C:ctor(tag)
	self.tag = tag

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
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.dj1_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(1)
	end)
	self.dj2_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select(2)
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.dj1_btn.onClick:RemoveAllListeners()
	self.dj2_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	if Act_RouletteManager.close_whell then
		self.wheel.gameObject:SetActive(false)
		self.vipwheel.gameObject:SetActive(false)
	else
		self.wheel.gameObject:SetActive(true)
		self.vipwheel.gameObject:SetActive(true)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshSelect()
end

function C:RefreshSelect()
	if self.tag == 1 then
		self.rules_txt.text = GLL.GetTx(80027)
	else
		self.rules_txt.text = GLL.GetTx(80028)
	end
	self.dj1_btn.gameObject:SetActive(self.tag ~= 1)
	self.dj2_btn.gameObject:SetActive(self.tag ~= 2)
	self.select1.gameObject:SetActive(self.tag == 1)
	self.select2.gameObject:SetActive(self.tag == 2)
end

function C:Select(tag)
	if self.tag ~= tag then
		self.tag = tag
		self:RefreshSelect()
	end
end
