-- 创建时间:2021-12-15
-- Panel:SlotsWinMoneyPanel
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

SlotsWinMoneyPanel = basefunc.class()
local M = SlotsWinMoneyPanel
M.name = "SlotsWinMoneyPanel"

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
    self.lister["ItemWinConnect"] = basefunc.handler(self, self.OnItemWinConnect)
    self.lister["GameStatusChange"] = basefunc.handler(self, self.OnGameStatusChange)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	SlotsHelper.KillSeq(self.tween)
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
	self.win_money_txt = SlotsGamePanel.Instance.tip_txt
	self.money_txt = SlotsGamePanel.Instance.tip_money_txt
end

function M:MyRefresh()
	SlotsHelper.KillSeq(self.tween)
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local allRate = self:GetAllRate()
	local allMoney = allRate * betMoney
	dump({betMoney,allRate},"<color=yellow>SlotsWinMoneyPanel :</color>")
	self:SetWinMoneyTxt(allMoney)
end

--获取总倍率，只包含连线的倍率
function M:GetAllRate()
	local miniGame = SlotsModel.GetMiniGame()
	local allRate = 0
	local baseData = SlotsModel.data.baseData
	if not baseData then
		return allRate
	end
	if baseData.mainData.itemRate and next(baseData.mainData.itemRate) then
		for k, v in pairs(baseData.mainData.itemRate) do
			allRate = allRate + v
		end
	end

	if miniGame == 1 then
		--金玉满堂

	elseif miniGame == 2 then
		--招财进宝
		if baseData.mini2Data and baseData.mini2Data.itemRateList and next(baseData.mini2Data.itemRateList) then
			for k, value in pairs(baseData.mini2Data.itemRateList) do
				for key, v in pairs(value) do
					allRate = allRate + v
				end
			end
		end
	elseif miniGame == 3 then
		--Jackpot

	end
	return allRate
end

local str = {
	"Semoga beruntung",
	"Semoga kaya raya selalu",
	"Rejekl mellmpah"
}
function M:SetWinMoneyTxt(money)
	money = math.ceil(money)
	if money == 0 then
		if IsEquals(self.win_money_txt) then
			self.win_money_txt.text = str[math.random(1,3)]
			self.win_money_txt.transform.localPosition = Vector3.New(0,-315,0)
		end
		if IsEquals(self.money_txt) then
			self.money_txt.gameObject:SetActive(false)
		end
	else
		if IsEquals(self.win_money_txt) then
			self.win_money_txt.text = "win"
			self.win_money_txt.transform.localPosition = Vector3.New(0,-297,0)
		end
		if IsEquals(self.money_txt) then
			self.money_txt.text = StringHelper.AddPoint(money)
			self.money_txt.gameObject:SetActive(true)
		end
	end
end

function M:OnItemWinConnect(data)
	local allRate = 0
	for k, v in pairs(data.itemRate) do
		allRate = allRate + v
	end
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local addMoney = betMoney * allRate

	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self:SetWinMoneyTxt(money)
	end
	self.winMoney = self.winMoney or 0
	
	local winMoney = self.winMoney
	self.winMoney = self.winMoney + addMoney

	SlotsHelper.KillSeq(self.tween)

	local t = 0
	local seq = SlotsHelper.GetSeq()
	if data.t5Line and data.isNormalLV then
		t = SlotsModel.GetTime(SlotsModel.time.changeMoneyDelay)
	end
	seq:InsertCallback(t,function ()
		self.tween = SlotsAnimation.PlayMoneyChange(winMoney,addMoney,setTxtCall,duration,self)
	end)
end

function M:SetWinMoney(money)
	self.winMoney = money
	self:SetWinMoneyTxt(money)
end

function M:OnGameStatusChange(data)
	if SlotsModel.data.gameStatus == SlotsModel.GameStatus.idle then
		self:MyRefresh()
	elseif SlotsModel.data.gameStatus == SlotsModel.GameStatus.run then
		self:SetWinMoney(0)
	end
end