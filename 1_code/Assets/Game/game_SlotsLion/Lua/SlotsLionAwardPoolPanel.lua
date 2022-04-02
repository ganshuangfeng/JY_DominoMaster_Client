-- 创建时间:2021-12-15
-- Panel:SlotsLionAwardPoolPanel
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

SlotsLionAwardPoolPanel = basefunc.class()
local M = SlotsLionAwardPoolPanel
M.name = "SlotsLionAwardPoolPanel"

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
	if self.update_t then
		self.update_t:Stop()
	end
	self.update_t = nil

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

	-- self:AwardInit()

	self.update_t = Timer.New(function ()
		self:Update()
	end, 0.4, -1, true, true)
	self:Update()
	self.update_t:Start()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	self.award1_txt = SlotsLionGamePanel.Instance.minor_txt
	self.award2_txt = SlotsLionGamePanel.Instance.major_txt
	self.award3_txt = SlotsLionGamePanel.Instance.jbp_txt
end

function M:Update()
	self:AwardShow()
end

function M:AwardInit()
	local awardPoolMoney = SlotsLionModel.GetAwardPoolMoney()
	self.max_num = awardPoolMoney[3]
	-- dump({self.min_num,self.max_num},"<color=white>钱？？？？？？</color>")
	self.min_num = self.cur_num or 0
	self.cur_num = self.min_num
	self.step_num = math.floor( (self.max_num - self.min_num) / (60*60 / 0.2) )
	self.award3_txt.text = StringHelper.AddPoint(self.cur_num)
end

function M:AwardShow()
	if not self.max_num or not self.min_num or not self.cur_num then
		return
	end
	if self.cur_num ~= self.max_num then
		self.cur_num = self.cur_num + math.random(math.floor(self.step_num /2),self.step_num)
		if self.cur_num > self.max_num then
			self.cur_num = self.max_num
		end
		self.award3_txt.text = StringHelper.AddPoint(self.cur_num)
	end
end

function M:MyRefresh()
	self:RefreshMoney()
	self:RefreshEffectAwardPool()
end

function M:RefreshMoney()
	local awardPoolMoney = SlotsLionModel.GetAwardPoolMoney()
	for i, v in ipairs(awardPoolMoney) do
		if i ~= 3 then
			self["award" .. i .. "_txt"].text = StringHelper.AddPoint(v)
		end
	end
	self:AwardInit()
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
	self.maxGold = self.maxGold or SlotsLionModel.GetMaxGold()
end

function M:RefreshEffectAwardPool()
	self.maxGold = self.maxGold or SlotsLionModel.GetMaxGold()
end

function M:PlayAwardPool3ExtChange(rate)
	local moneyCur = SlotsLionModel.GetAwardPoolCurMoney(3)
	local betMoney = SlotsLionModel.GetBetMoneyOneLine()
	local moneyAdd = betMoney * rate
	local v = moneyCur + moneyAdd
	SlotsLionModel.SetAwardPoolCurMoney(3,v)
	-- self["award" .. 3 .. "_txt"].text = StringHelper.AddPoint(v)
	self.max_num = v
end