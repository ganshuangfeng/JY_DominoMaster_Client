-- 创建时间:2022-01-22
-- Panel:Act_UnlimitedGiftPanel
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

Act_UnlimitedGiftPanel = basefunc.class()
local C = Act_UnlimitedGiftPanel
local M = Act_UnlimitedGiftManager
C.name = "Act_UnlimitedGiftPanel"

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.cfg = M.GetConfig()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.items or {}) do
		v.ui.buy_btn.onClick:RemoveAllListeners()
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:InitItems()
	self:MyRefresh()
end

function C:InitItems()
	self.items = {}
	for i = 1, #self.cfg do
		local obj = newObject("Act_UnlimitedGiftItem", self.Content)
		local item = { obj = obj, ui = {}}
		LuaHelper.GeneratingVar(item.obj.transform, item.ui)
		self:InitItem(self.cfg[i], item.ui)
		self.items[#self.items + 1] = item
	end
end

function C:InitItem(cfg, ui)
	ui.icon_img.sprite = GetTexture(cfg.award_icon)
	ui.num_txt.text = StringHelper.ToCash(cfg.award_num)
	ui.buy_btn.onClick:AddListener(function()
		dump(cfg.gift_id)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.BuyGift(cfg.gift_id)
	end)
	local gift_cfg = GameGiftManager.GetGiftConfig(cfg.gift_id)
	if not gift_cfg then
		dump(cfg.gift_id, "<color=red>无限礼包:未找到礼包配置</color>")
		return
	end
	ui.price_txt.text = GLL.GetTx(70004) .. " " .. StringHelper.ToCash(gift_cfg.price / 100)
end

function C:MyRefresh()
end
