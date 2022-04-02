-- 创建时间:2022-01-07
-- Panel:Act_CZLBPanel
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

Act_CZLBPanel = basefunc.class()
local C = Act_CZLBPanel
local M = Act_CZLBManager
C.name = "Act_CZLBPanel"

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
    self.lister["model_gift_data_change_msg"] = basefunc.handler(self, self.on_model_gift_data_change_msg)
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
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.buy_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.BuyGift(self.gift_id)
	end)

	self.buy_gray_btn.onClick:AddListener(function()
		LittleTips.Create(GLL.GetTx(80005))
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.buy_btn.onClick:RemoveAllListeners()
	self.buy_gray_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.gift_id = M.GiftId()
	self.award_cfg = M.GetGiftAwards()
	self:InitAwardItems()
	self:InitBuyBtn()
	self.fenge_txt.text = GLL.GetTx(80005)
	self:MyRefresh()
	self:RefreshBuyBtn()
end

function C:InitAwardItems()
	self.awrdItems = {}
	for i = 1, #self.award_cfg do
		local cfg = self.award_cfg[i]
		local obj = newObject("Act_CZLBItem", self.Content.transform)
		local ui = {}
		LuaHelper.GeneratingVar(obj.transform, ui)
		self:InitAwardItem(cfg, ui)

		self.awrdItems[#self.awrdItems + 1] = {obj = obj, ui = ui}
	end
	self.awrdItems[#self.awrdItems].ui.add.gameObject:SetActive(false)
end

function C:InitAwardItem(cfg, ui)
	ui.icon_img.sprite = GetTexture(cfg.award_icon)
	ui.num_txt.text = StringHelper.ToCash(cfg.award_num)
	if not cfg.give_rate and not cfg.is_bonus then
		ui.tip.gameObject:SetActive(false)
	end

	if cfg.give_rate then
		ui.give_rate_txt.text = cfg.give_rate .. "%"
	end

	if cfg.is_bonus and cfg.is_bonus == 1 then
		ui.give_rate_txt.text = "Bonus"
	end

	if cfg.award_item_key == "shop_gold_sum" then
		ui.icon_img.transform.localScale = Vector3.New(0.85, 0.85, 0.85)
	end
	ui.icon_tip_btn = ui.icon_img:GetComponent("Button")
	QPPrefab.AddShowItem(ui.icon_tip_btn, cfg.award_item_key)
end

function C:InitBuyBtn()
	local gift_cfg = GameGiftManager.GetGiftConfig(self.gift_id)
	if not gift_cfg then
		dump(self.gift_id, "<color=red>超值礼包:未找到礼包配置</color>")
		return
	end
	self.buy_txt.text =  "IDR " .. StringHelper.ToCash(gift_cfg.price / 100)
	self.buy1_txt.text =  self.buy_txt.text

	
end

function C:RefreshBuyBtn()
	if not M.IsCanBuyCZLB() then
		self.buy_gray.gameObject:SetActive(true)
	else
		self.buy_gray.gameObject:SetActive(false)
	end
end

function C:on_model_gift_data_change_msg(id)
	if id == self.gift_id and not M.IsCanBuyCZLB() then
		self:MyExit()
	end
	-- self:RefreshBuyBtn()
end

function C:MyRefresh()
end
