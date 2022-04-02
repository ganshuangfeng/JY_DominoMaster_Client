-- 创建时间:2022-01-06
-- Panel:Act_SCLBPanel
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

Act_SCLBPanel = basefunc.class()
local C = Act_SCLBPanel
local M = Act_SCLBManager
C.name = "Act_SCLBPanel"

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
	self.cfg = M.GetConfig()
	self:InitUI()
	self:InitLL()
	local endTimeCall = function()
		self:MyExit()
	end
	CommonTimeManager.GetCutDownTimer(M.GetActEndTime(), self.remain_txt, nil, endTimeCall)
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.buy_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.BuyGift(self.cfg.gift_id)
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.buy_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
	self.desc_txt.text = GLL.GetTx(81109)
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:InitItemNodes()
	self:MyRefresh()
end

function C:InitItemNodes()
	
	self.award1_txt.text = StringHelper.ToCash(self.cfg.award1_num)
	self.award2_txt.text = StringHelper.ToCash(self.cfg.award2_num)
	self.award3_txt.text = StringHelper.ToCash(self.cfg.award3_num)

	self.award1_img.sprite = GetTexture(self.cfg.award1_icon)
	self.award2_img.sprite = GetTexture(self.cfg.award2_icon)
	self.award3_img.sprite = GetTexture(self.cfg.award3_icon)

	-- QPPrefab.AddShowItem(self.award1_img:GetComponent("Button"), self.cfg.award1_item_key)
	-- QPPrefab.AddShowItem(self.award2_img:GetComponent("Button"), self.cfg.award2_item_key)
	-- QPPrefab.AddShowItem(self.award3_img:GetComponent("Button"), self.cfg.award3_item_key)
end

function C:on_model_gift_data_change_msg(id)
	if M.IsCareGiftId(id) then
		local giftData = GameGiftManager.GetGiftData(id)
		if not giftData or giftData.status ~= 1 then
			Event.Brocast("ui_button_data_change_msg", {key = M.key})
			self:MyExit()
		end
	end
end

function C:MyRefresh()
end
