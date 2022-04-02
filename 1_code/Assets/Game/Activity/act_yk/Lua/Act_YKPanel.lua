-- 创建时间:2022-03-01
-- Panel:Act_YKPanel
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

Act_YKPanel = basefunc.class()
local C = Act_YKPanel
local M = Act_YKManager
C.name = "Act_YKPanel"

local ui_config = {
	normal = {
		base_award = {"jing_bi",},
		base_award_amount = {500000000,},
		day_award = {"jing_bi",},
		day_award_amount = {6000000,},
	},
	zz = {
		base_award = {"jing_bi", "shop_gold_sum"},
		base_award_amount = {500000000, 1000},
		day_award = {"jing_bi", "shop_gold_sum"},
		day_award_amount = {35000000, 300},
	},
}

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["model_yk_base_info_change"] = basefunc.handler(self, self.on_model_yk_base_info_change)
	-- self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
	-- self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	M.QueryBaseInfo(false)
end

function C:RemoveListenerGameObject()
	self.buy_n_btn.onClick:RemoveAllListeners()
	self.buy_z_btn.onClick:RemoveAllListeners()
	self.get_n_btn.onClick:RemoveAllListeners()
	self.get_z_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	local preName = function(item_key)
		if item_key == "jing_bi" then
			return "item_jb"
		elseif item_key == "shop_gold_sum" then
			return "item_rp"
		end
	end
	local normal_cfg = ui_config.normal
	local MakeAward = function(items, content, award_cfg, award_amount_cfg)
		for i = 1, #award_cfg do
			local b = GameObject.Instantiate(self[preName(award_cfg[i])], content)
			b.gameObject:SetActive(true)
			local ui = {}
			ui.num_txt = b.transform:Find("@num_txt"):GetComponent("Text")
			ui.num_txt.text = StringHelper.ToCash(award_amount_cfg[i])
			ui.geted = b.transform:Find("@geted")
			ui.icon_btn = b.transform:Find("@icon_btn"):GetComponent("Button")
			QPPrefab.AddShowItem(ui.icon_btn, award_cfg[i])
			ui.texiao_kuang = b.transform:Find("YK_bk_lg")
			local property = {}
			property.isGeted = false
			items[#items + 1] = {obj = b, ui = ui, property = property}
		end
	end

	self.normalBaseItems = {}
	self.normalDayItems = {}
	self.zzBaseItems = {}
	self.zzDayItems = {}

	MakeAward(self.normalBaseItems, self.n_base_content, ui_config.normal.base_award, ui_config.normal.base_award_amount)
	MakeAward(self.normalDayItems, self.n_day_content, ui_config.normal.day_award, ui_config.normal.day_award_amount)
	MakeAward(self.zzBaseItems, self.z_base_content, ui_config.zz.base_award, ui_config.zz.base_award_amount)
	MakeAward(self.zzDayItems, self.z_day_content, ui_config.zz.day_award, ui_config.zz.day_award_amount)
	
	local normalShopCfg = GameGiftManager.GetGiftConfig(M.normal_shop_id)
	if normalShopCfg then
		self.buy_n_txt.text = "IDR  " .. StringHelper.ToCash(normalShopCfg.price / 100)
	end

	local zzShopCfg = GameGiftManager.GetGiftConfig(M.zz_shop_id)
	if zzShopCfg then
		self.buy_z_txt.text = "IDR  " .. StringHelper.ToCash(zzShopCfg.price / 100)
	end

	self.buy_n_btn.onClick:AddListener(function()
		GameManager.BuyGift(M.normal_shop_id)
	end)

	self.buy_z_btn.onClick:AddListener(function()
		GameManager.BuyGift(M.zz_shop_id)
	end)

	self.get_n_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award", { id = M.normal_task_id})
	end)

	self.get_z_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award", { id = M.zz_task_id})
	end)

	self.get_n_next_btn.onClick:AddListener(function()
		LittleTips.Create(GLL.GetTx(81061))
	end)
	self.get_z_next_btn.onClick:AddListener(function()
		LittleTips.Create(GLL.GetTx(81061))
	end)

	self.get_n_btn.gameObject:SetActive(false)
	self.get_z_btn.gameObject:SetActive(false)
	-- self:RefreshBuyContent()
	-- self:RefreshGetStatus()
	self:MyRefresh()
end

function C:RefreshBuyContent()
	self.data = M.GetData()
	if not self.data.isBuyNormal then
		self.buy_normal.gameObject:SetActive(true)
		self.purchased_normal.gameObject:SetActive(false)
	else
		--已购买普通月卡
		self.purchased_normal.gameObject:SetActive(true)
		self.buy_normal.gameObject:SetActive(false)
		self:RefreshNoramlBtn()
	end

	if not self.data.isBuyZZ then
		self.buy_zz.gameObject:SetActive(true)
		self.purchased_zz.gameObject:SetActive(false)
	else
		--已购买至尊月卡
		self.purchased_zz.gameObject:SetActive(true)
		self.buy_zz.gameObject:SetActive(false)
		self:RefreshZZBtn()
	end
end

function C:RefreshNoramlBtn()
	self.normal_status = M.GetAwardStatus("normal")
	-- dump(self.normal_status, "<color=white> normal_status </color>")
	self.get_n_btn.gameObject:SetActive(self.normal_status == 1)
	self.get_n_next_btn.gameObject:SetActive(self.normal_status == 2)
	self.remian_n_txt.text = "Sisa " .. (self.data.remainTimeNormal + 1) .. " hari"
	self.remian_n_n_txt.text = "Sisa " .. self.data.remainTimeNormal .. " hari"
end

function C:RefreshZZBtn()
	self.zz_status = M.GetAwardStatus("zz")
	self.get_z_btn.gameObject:SetActive(self.zz_status == 1)
	self.get_z_next_btn.gameObject:SetActive(self.zz_status == 2)
	self.remian_z_txt.text = "Sisa " .. (self.data.remainTimeZZ + 1) .. " hari"
	self.remian_z_n_txt.text = "Sisa " .. self.data.remainTimeZZ .. " hari"
end

local function RefreshItemGetStatus(items, isGet)
	for i = 1, #items do
		if items[i].property.isGeted ~= isGet then
			items[i].ui.geted.gameObject:SetActive(isGet)
			items[i].ui.texiao_kuang.gameObject:SetActive(not isGet)
			items[i].property.isGeted = isGet
		end
	end
end

function C:RefreshGetStatus()
	self.data = M.GetData()
	self:RefreshNormalGetStatus()
	self:RefreshZZGetStatus()
end

function C:RefreshNormalGetStatus()
	if self.data.isBuyNormal then
		RefreshItemGetStatus(self.normalBaseItems, true)
		self.normal_status = M.GetAwardStatus("normal")
		RefreshItemGetStatus(self.normalDayItems, self.normal_status == 2)
	else
		RefreshItemGetStatus(self.normalBaseItems, false)
	end
end

function C:RefreshZZGetStatus()
	if self.data.isBuyZZ then
		RefreshItemGetStatus(self.zzBaseItems, true)
		self.zz_status = M.GetAwardStatus("zz")
		RefreshItemGetStatus(self.zzDayItems, self.zz_status == 2)
	else
		RefreshItemGetStatus(self.zzBaseItems, false)
	end
end

function C:on_model_yk_base_info_change()
	self:RefreshBuyContent()
	self:RefreshGetStatus()
end

-- function C:on_model_task_change_msg(data)
-- 	dump(data, "<color=white>+++++月卡:on_model_task_change_msg+++++</color>")
-- 	if data.id == M.normal_task_id or data.id == M.zz_task_id then
-- 		M.QueryBaseInfo(true)
-- 		Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
-- 	end

	-- if data.id == M.normal_task_id then
	-- 	self:RefreshNoramlBtn()
	-- 	self:RefreshNormalGetStatus()
	-- elseif data.id == M.zz_task_id then
	-- 	self:RefreshZZBtn()
	-- 	self:RefreshZZGetStatus()
	-- end
-- end

-- function C:on_get_task_award_response(_, data)
-- 	dump(data, "<color=white>+++++月卡:on_get_task_award_response+++++</color>")
-- 	if data.id == M.normal_task_id or data.id == M.zz_task_id then
-- 		M.QueryBaseInfo(true)
-- 	end
-- end

function C:MyRefresh()
end
