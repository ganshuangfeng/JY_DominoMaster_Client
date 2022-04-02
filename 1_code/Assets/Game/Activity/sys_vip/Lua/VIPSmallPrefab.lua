-- 创建时间:2022-03-15
-- Panel:VIPSmallPrefab
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

VIPSmallPrefab = basefunc.class()
local C = VIPSmallPrefab
C.name = "VIPSmallPrefab"

function C.Create(parent, selfParent)
	return C.New(parent, selfParent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_vip_base_info_msg"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent, selfParent)
	self.selfParent = selfParent

	ExtPanel.ExtMsg(self)
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
	self.goto_pay_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    	GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "panel"})
		self.selfParent:MyExit()
	end)
end
function C:RemoveListenerGameObject()
	self.goto_pay_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.ui_jd_size = 324
	self.vip_jd_rect = self.vip_jd:GetComponent("RectTransform")
	self:MyRefresh()
end

function C:MyRefresh()
	self.cur_data = SysVipManager.GetVipData()
	self.cur_config = SysVipManager.GetVipConfigByLevel(self.cur_data.level)

	self.show_vip_level_img.sprite = GetTexture(self.cur_config.base.icon)
	if self.cur_data.level >= SysVipManager.UIConfig.max_vip_level then
		self.is_max_level = true
	else
		self.is_max_level = false
		self.next_level = self.cur_data.level + 1
		self.next_cfg = SysVipManager.GetVipConfigByLevel(self.next_level)
	end

	if self.is_max_level then
		self.hint.gameObject:SetActive(false)
		self.vip_jd_txt.text = "MAX"
		self.vip_jd_rect.sizeDelta = { x = self.ui_jd_size, y = 28 }
	else
		self.hint.gameObject:SetActive(true)
		self.hint2_txt.text = StringHelper.ToCash(self.next_cfg.base.total - self.cur_data.rate)
		self.hint4_txt.text = "VIP"..self.next_level
		
		self.vip_jd_txt.text = StringHelper.ToCash(self.cur_data.rate) .. "/" .. StringHelper.ToCash(self.next_cfg.base.total)
		local bl = self.cur_data.rate / self.next_cfg.base.total
		self.vip_jd_rect.sizeDelta = { x = self.ui_jd_size * bl, y = 28 }
	end
end
