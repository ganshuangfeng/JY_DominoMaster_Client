-- 创建时间:2022-01-13
-- Panel:Sys_SignInWeekAwardGet
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

Sys_SignInWeekAwardGet = basefunc.class()
local C = Sys_SignInWeekAwardGet
C.name = "Sys_SignInWeekAwardGet"

function C.Create(cfg, normalGet)
	return C.New(cfg, normalGet)
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

function C:ctor(cfg, normalGet)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.cfg = cfg
	self.normalGet = normalGet
	self.vipGet = function()
		GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "panel"})
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.normal_get_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.normalGet then
			self.normalGet()
			self:MyExit()
		end
	end)
	self.vip_get_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.vipGet then
			self.vipGet()
			self:MyExit()
		end
	end)
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.normal_get_btn.onClick:RemoveAllListeners()
	self.vip_get_btn.onClick:RemoveAllListeners()
	self.back_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.normal_img.sprite = GetTexture(self.cfg.award_icon)
	self.vip_img.sprite = GetTexture("ty_icon_dj_jbd")
	self.normal_txt.text = StringHelper.ToCash(self.cfg.award_num)
	self.vip_txt.text = StringHelper.ToCash(self.cfg.award_num * 2)
	QPPrefab.AddShowItem(self.normal_img:GetComponent("Button"), self.cfg.award_item_key)
	QPPrefab.AddShowItem(self.vip_img:GetComponent("Button"), self.cfg.award_item_key)

	self.normal_get_txt.text = GLL.GetTx(80015)
	self.vip_get_txt.text = string.format(GLL.GetTx(80016), self.cfg.award_double_vip)
	self.title_txt.text = GLL.GetTx(80014)

	self:MyRefresh()
end

function C:MyRefresh()
end
