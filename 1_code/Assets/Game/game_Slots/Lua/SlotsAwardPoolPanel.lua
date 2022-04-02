-- 创建时间:2021-12-15
-- Panel:SlotsAwardPoolPanel
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

SlotsAwardPoolPanel = basefunc.class()
local M = SlotsAwardPoolPanel
M.name = "SlotsAwardPoolPanel"

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
    self.lister["MaxGoldChange"] = basefunc.handler(self, self.OnMaxGoldChange)
    self.lister["BetMoneyChange"] = basefunc.handler(self, self.OnBetMoneyChange)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	self.award1_txt = SlotsGamePanel.Instance.mini_txt
	self.award2_txt = SlotsGamePanel.Instance.minor_txt
	self.award3_txt = SlotsGamePanel.Instance.major_txt
	self.award4_txt = SlotsGamePanel.Instance.jbp_txt
	for i = 1, 4 do
		self["effect_change_money" .. i] = SlotsGamePanel.Instance["effect_change_money" .. i]
		self["effect_award_pool_".. i] = SlotsGamePanel.Instance["effect_award_pool_" .. i]
	end
	self.award_pool_4_bg = SlotsGamePanel.Instance.award_pool_4_bg
	self.award_pool_4_tregger = SlotsGamePanel.Instance.award_pool_4_tregger
end

function M:MyRefresh()
	self.curItemDNum = nil
	self:RefreshMoney()
	self:RefreshEffectAwardPool()

	self:ResetAwardPool4Trigger()
end

function M:RefreshMoney()
	local awardPoolMoney = SlotsModel.GetAwardPoolMoney()
	for i, v in ipairs(awardPoolMoney) do
		self["award" .. i .. "_txt"].text = StringHelper.AddPoint(v)
	end
end

function M:OnMaxGoldChange(data)
	self.maxGold = data.newMaxGold
	self:MyRefresh()

	self:RefreshEffectChangeMoney()
end

function M:OnBetMoneyChange(data)
	self:RefreshMoney()
end

function M:RefreshEffectChangeMoney()
	self.maxGold = self.maxGold or SlotsModel.GetMaxGold()

	local t = {
		[1] = 4,
		[2] = 3,
		[3] = 2,
		[4] = 1,

	}

	for i = 1, 4 do
		self["effect_change_money".. i].gameObject:SetActive(i <= self.maxGold)
	end
end

function M:RefreshEffectAwardPool()
	self.maxGold = self.maxGold or SlotsModel.GetMaxGold()

	local t = {
		[1] = 4,
		[2] = 3,
		[3] = 2,
		[4] = 1,

	}

	for i = 1, 4 do
		self["effect_award_pool_".. i].gameObject:SetActive(i <= self.maxGold)
	end
end

function M:PlayAwardPool4ExtChange()
	self.curItemDNum = self.curItemDNum or 0
	self.curItemDNum = self.curItemDNum + 1
	local gameData = SlotsModel.data.baseData.mainData
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local c = gameData.itemDNum - self.curItemDNum
	c = c < 0 and 0 or c
	local money = gameData.itemDRate / gameData.itemDNum * betMoney * c
	local awardPool4Money = SlotsModel.data.baseData.awardPool4Money
	local awardPoolMoney = SlotsModel.GetAwardPoolMoney()
	local v = awardPoolMoney[4] + awardPool4Money
	v = v - money
	self["award" .. 4 .. "_txt"].text = StringHelper.AddPoint(v)
end

function M:ResetAwardPool4Trigger()
	self.award_pool_4_bg.gameObject:SetActive(true)
	self.award_pool_4_tregger.gameObject:SetActive(false)
end

function M:PlayAwardPool4Trigger()
	self.award_pool_4_bg.gameObject:SetActive(false)
	self.award_pool_4_tregger.gameObject:SetActive(true)
	local seq = SlotsHelper.GetSeq()
	seq:InsertCallback(4,function ()
		self:ResetAwardPool4Trigger()
	end)
	seq:OnKill(function ()
		self:ResetAwardPool4Trigger()
	end)
end