-- 创建时间:2022-03-22
-- Panel:Act_JBZSAssetSlect
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

Act_JBZSAssetSlect = basefunc.class()
local C = Act_JBZSAssetSlect
C.name = "Act_JBZSAssetSlect"

function C.Create(parent, cfg, id, selectFun)
	return C.New(parent, cfg, id, selectFun)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["vip_upgrade_change_msg"] = basefunc.handler(self, self.on_vip_upgrade_change_msg)
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

function C:ctor(parent, cfg, id, selectFun)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.cfg = cfg
	self.id = id
	self.selectFun = selectFun
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.select_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Select()
	end)
end

function C:RemoveListenerGameObject()
	self.select_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.num_txt.text = StringHelper.ToCash(self.cfg.award_num)
	self.select_num_txt.text = StringHelper.ToCash(self.cfg.award_num)
	self.lock_num_txt.text = StringHelper.ToCash(self.cfg.award_num)

	if self.cfg.vip_lv > 0 then
		self.vip_txt.text = "Membuka\nVIP" .. self.cfg.vip_lv
	else
		self.vip_txt.text = ""
	end
	self:RefreshLock()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:Select()

	if self.selectFun then
		self.selectFun(self.id)
	end
end

function C:ViewSelect()
	self.selected.gameObject:SetActive(true)
end

function C:ViewUnSelct()
	self.selected.gameObject:SetActive(false)
end

function C:ViewLock()
	self.lock.gameObject:SetActive(true)
end

function C:ViewUnLock()
	self.lock.gameObject:SetActive(false)
end

function C:RefreshLock()
	local vipLevel = SysVipManager.GetVipData().level or 0
	if vipLevel >= self.cfg.vip_lv then
		self:ViewUnLock()
	else
		self:ViewLock()
	end
end

function C:on_vip_upgrade_change_msg()
	self:RefreshLock()
end
