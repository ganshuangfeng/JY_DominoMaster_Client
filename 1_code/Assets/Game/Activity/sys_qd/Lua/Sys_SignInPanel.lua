-- 创建时间:2022-01-05
-- Panel:Sys_SignInPanel
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

Sys_SignInPanel = basefunc.class()
local C = Sys_SignInPanel
local M = SYSQDManager
C.name = "Sys_SignInPanel"

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
    self.lister["query_sign_in_data_response"] = basefunc.handler(self, self.on_query_sign_in_data_response)
    self.lister["model_vip_base_info_msg"] = basefunc.handler(self, self.on_model_vip_base_info_msg)
    self.lister["get_sign_in_award_response"] = basefunc.handler(self, self.on_get_sign_in_award_response)
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

	Network.SendRequest("query_sign_in_data")
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.vip_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
		GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "panel"})
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.vip_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.weekItems) do
		v.ui.get_btn.onClick:RemoveAllListeners()
	end
	for k, v in pairs(self.monthItems) do
		v.ui.get_btn.onClick:RemoveAllListeners()
	end
end

function C:InitLL()

end

function C:RefreshLL()
end

function C:InitUI()
	

	self.vipLevel = SysVipManager.GetVipData().level
	-- self.maxMonthDay = M.GetMonthDayCount(tonumber(os.date("%Y", os.time())), tonumber(os.date("%m", os.time())))
	self:InitWeekItems()
	self:InitMonthItems()
	self.sign1_txt.text = string.format(GLL.GetTx(80010), 0)
	self.sign2_txt.text = string.format(GLL.GetTx(80011), 0)
	self:MyRefresh()
	-- self:CreateHintPanelSmall()
	-- self:CreateHintPanel({award_num = 100, award_icon = "ty_icon_dj_jb", award_double_vip = 3 })
end

function C:MyRefresh()
end

--"第%s天"
local strDay = GLL.GetTx(80006)

function C:InitWeekItems()
	self.weekItems = {}
	self.week_cfg = M.GetWeekConfig()
	for i = 1, #self.week_cfg do
		local itemNode = self.weeknodes.transform:GetChild(i - 1).transform
		local obj = newObject("Sys_SignInWeekItem", itemNode)
		local item = {obj = obj, ui = {}}
		LuaHelper.GeneratingVar(item.obj.transform, item.ui)
		item.ui.icon_img.sprite = GetTexture(self.week_cfg[i].award_icon)
		item.ui.num_txt.text = StringHelper.ToCash(self.week_cfg[i].award_num)
		item.ui.day_txt.text = string.format(strDay, i)
		item.ui.day_get_txt.text = string.format(strDay, i)
		item.ui.get_btn.onClick:AddListener(function()
			self:OnClickWeekItem(self.week_cfg[i])
		end)
		QPPrefab.AddShowItem(item.ui.icon_img:GetComponent("Button"), self.week_cfg[i].award_item_key)
		if self.week_cfg[i].award_double_vip then
			-- item.ui.vip_txt.text = "VIP" .. self.week_cfg[i].award_double_vip .. "\n翻倍"
			item.ui.vip_txt.text = string.format(GLL.GetTx(80007), self.week_cfg[i].award_double_vip)
		else
			item.ui.tip.gameObject:SetActive(false)
		end
		self.weekItems[#self.weekItems + 1] = item
	end

	local obj = newObject("Sys_SignInWeekItem1",  self.weeknodes.transform:GetChild(6).transform)
	local item = {obj = obj, ui = {}}
	LuaHelper.GeneratingVar(item.obj.transform, item.ui)
	item.ui.day_txt.text = string.format(strDay, 7)
	item.ui.day_get_txt.text = string.format(strDay, 7)
	item.ui.num_txt.text = GLL.GetTx(80008)
	item.ui.num2_txt.text = GLL.GetTx(80009)
	item.ui.get_btn.onClick:AddListener(function()
		self:OnClickWeekItem1()
	end)
	QPPrefab.AddShowDesc(item.ui.icon_img:GetComponent("Button"), GLL.GetTx(80024))
	self.weekItems[#self.weekItems + 1] = item
end


function C:InitMonthItems()
	self.monthItems = {}
	self.month_cfg = M.GetMonthConfig()
	for i = 1, #self.month_cfg do
		local itemNode = self.monthnodes.transform:GetChild(i - 1).transform
		local obj = newObject("Sys_SignInMonthItem", itemNode)
		local item = {obj = obj, ui = {}}
		LuaHelper.GeneratingVar(item.obj.transform, item.ui)
		item.ui.icon_img.sprite = GetTexture(self.month_cfg[i].award_icon)
		item.ui.num_txt.text = StringHelper.ToCash(self.month_cfg[i].award_num)
		item.ui.day_txt.text = string.format(strDay, self.month_cfg[i].day)
		item.ui.get_btn.onClick:AddListener(function()
			self:OnClickMonthItem(self.month_cfg[i])
		end)
		QPPrefab.AddShowItem(item.ui.icon_img:GetComponent("Button"), self.month_cfg[i].award_item_key)
		self.monthItems[#self.monthItems + 1] = item
	end
end

function C:RefreshWeekItems()
	if not self.sign_in_day or not self.sign_in_award then
		return
	end
	for i = 1, #self.weekItems do
		if i < self.sign_in_day then
			self.weekItems[i].ui.geted.gameObject:SetActive(true)
		end
	end
	local curWeekItem = self.weekItems[self.sign_in_day]
	if self.sign_in_award == 1 then
		curWeekItem.ui.can_get.gameObject:SetActive(true)
		curWeekItem.ui.geted.gameObject:SetActive(false)
		curWeekItem.ui.icon_img.raycastTarget = false
	else
		curWeekItem.ui.can_get.gameObject:SetActive(false)
		curWeekItem.ui.geted.gameObject:SetActive(true)
		curWeekItem.ui.icon_img.raycastTarget = true
		curWeekItem.ui.gx.gameObject:SetActive(false)
	end
end

function C:RefreshMonthItems()
	if not self.acc_day then
		return
	end
	--本月累计签到%s天
	-- self.sign2_txt.text = "(akumulatif masuk selama " .. self.acc_day .. " hari bulan ini)"
	self.sign2_txt.text = string.format(GLL.GetTx(80011), self.acc_day)

	local curLv = 1
	for i = 1, #self.monthItems do
		-- self.monthItems[i].ui.can_get.gameObject:SetActive(false)
		local cfg= self.month_cfg[i]
		if cfg.day <= self.acc_day then
			self.monthItems[i].ui.can_get.gameObject:SetActive(false)
			self.monthItems[i].ui.geted.gameObject:SetActive(true)
			curLv = i + 1
		end
	end

	curLv = curLv > 5 and 5 or curLv
	local rate = 1
	if curLv > 1 then
		rate = (self.acc_day - self.month_cfg[curLv - 1].day) / (self.month_cfg[curLv].day - self.month_cfg[curLv - 1].day)
	end
	self:RefreshProgressUI(curLv, rate)

	if not table_is_null(self.acc_award) then
		for i = 1, #self.acc_award do
			self.monthItems[self.acc_award[i]].ui.can_get.gameObject:SetActive(true)
			self.monthItems[self.acc_award[i]].ui.geted.gameObject:SetActive(false)
			self.monthItems[self.acc_award[i]].ui.icon_img.raycastTarget = false
		end
	end
end

function C:OnClickWeekItem(cfg)
	local normalGet = function()
		Network.SendRequest("get_sign_in_award",{type = "sign_in", index = cfg.id })
	end
	if cfg.award_double_vip and self.vipLevel < cfg.award_double_vip then
		self:CreateHintPanel(cfg, normalGet)
	else
		normalGet()
	end
end

function C:OnClickWeekItem1()
	Network.SendRequest("get_sign_in_award",{type = "sign_in", index = 7 })
end

function C:CreateHintPanel(cfg, normalGet)
	Sys_SignInWeekAwardGet.Create(cfg, normalGet)
end

function C:OnClickMonthItem(cfg)
	if self.vipLevel < 1 then
		self:CreateHintPanelSmall()
	else
		Network.SendRequest("get_sign_in_award",{type = "acc", index = cfg.id })
	end
end

function C:CreateHintPanelSmall()
	local vipGet = function()
		GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "panel"})
	end

	--Vip1及以上等级可领取该奖励\n是否确认提升VIP等级
	local contentTxt = GLL.GetTx(80013)
	local hintPanel = HintPanel.CreateSmall(3, contentTxt, vipGet) 
	hintPanel:SetButtonText(GLL.GetTx(60007), GLL.GetTx(60008))
end

function C:on_query_sign_in_data_response(_, data)
	dump(data, "<color=white>+++++on_query_sign_in_data_response+++++</color>")
	self.sign_in_day = data.sign_in_day
	self.sign_in_award = data.sign_in_award
	self.acc_day = data.acc_day
	self.acc_award = data.acc_award

	-- self.sign_in_day = 7
	-- self.sign_in_award = 1
	-- self.acc_day = 21
	-- self.acc_award = {2, 3 ,4}
	self:RefreshWeekItems()
	self:RefreshMonthItems()
end

function C:on_model_vip_base_info_msg()
	self.vipLevel = SysVipManager.GetVipData().level
	self:RefreshWeekItems()
	self:RefreshMonthItems()
end

function C:on_get_sign_in_award_response(_, data)
	if data.result == 0 then
		Network.SendRequest("query_sign_in_data")
	end
end

local progressX = 
{
	[1] = {min =0,  max = 15 },
	[2] = {min =15, max = 67 },
	[3] = {min =151,max = 246 },
	[4] = {min =330,max = 456 },
	[5] = {min =542,max = 713 },
}

function C:RefreshProgressUI(lv, rate)
	local offX = progressX[lv].min + rate * (progressX[lv].max - progressX[lv].min)
	self.pg.transform:GetComponent("RectTransform").sizeDelta = { x = offX , y = 15.81}
end