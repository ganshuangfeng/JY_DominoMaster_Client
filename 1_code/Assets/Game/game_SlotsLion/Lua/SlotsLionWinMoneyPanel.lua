-- 创建时间:2021-12-15
-- Panel:SlotsLionWinMoneyPanel
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

SlotsLionWinMoneyPanel = basefunc.class()
local M = SlotsLionWinMoneyPanel
M.name = "SlotsLionWinMoneyPanel"

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
	SlotsLionHelper.KillSeq(self.tween)
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
	self.win_money_txt = SlotsLionGamePanel.Instance.tip_txt
	self.money_txt = SlotsLionGamePanel.Instance.tip_money_txt
end

function M:MyRefresh()
	SlotsLionHelper.KillSeq(self.tween)
	local betMoney = SlotsLionModel.GetBetMoneyOneLine()
	local allRate = self:GetAllRate()
	local allMoney = allRate * betMoney
	dump({betMoney,allRate},"<color=yellow>SlotsLionWinMoneyPanel :</color>")
	self:SetWinMoneyTxt(allMoney)
end

--获取总倍率，只包含连线的倍率
function M:GetAllRate()
	local miniGame = SlotsLionModel.GetMiniGame()
	local allRate = 0
	local baseData = SlotsLionModel.data.baseData
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
			self.win_money_txt.transform.localPosition = Vector3.New(0,-286,0)
		end
		if IsEquals(self.money_txt) then
			self.money_txt.text = StringHelper.AddPoint(money)
			self.money_txt.gameObject:SetActive(true)
		end
	end
end

local allMoney = 0
local i = 1
function M:OnItemWinConnect(data)
	local addMoney = data.money
	allMoney = allMoney + data.money
	-- dump({i,allMoney,data.money,data.moneyTime},"<color=white>钱改变了？？？？？？？？？？？？？？</color>")
	-- dump(debug.traceback(),"<color=white>堆栈？？？？？？？？？？？？？？？</color>")
	-- i = i + 1

	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)

	local lv,rate = self:CheckNormalLv()
	dump({lv,rate})
	if lv then
		local duration1 = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
		local moneyTime = data.moneyTime or duration1
		duration = duration + moneyTime
	end

	local setTxtCall = function (money)
		self:SetWinMoneyTxt(money)
	end
	self.winMoney = self.winMoney or 0
	
	local winMoney = self.winMoney
	self.winMoney = self.winMoney + addMoney

	SlotsLionHelper.KillSeq(self.tween)

	local t = 0
	local seq = SlotsLionHelper.GetSeq()
	if data.t5Line and data.isNormalLV then
		t = SlotsLionModel.GetTime(SlotsLionModel.time.changeMoneyDelay)
	end
	seq:InsertCallback(t,function ()
		self.tween = SlotsLionAnimation.PlayMoneyChange(winMoney,addMoney,setTxtCall,duration,self)
	end)
end

function M:SetWinMoney(money)
	self.winMoney = money
	self:SetWinMoneyTxt(money)
end

function M:OnGameStatusChange(data)
	if SlotsLionModel.data.gameStatus == SlotsLionModel.GameStatus.idle then
		self:MyRefresh()
	elseif SlotsLionModel.data.gameStatus == SlotsLionModel.GameStatus.run then
		self:SetWinMoney(0)
	end
end

function M:CheckNormalLv()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	dump(gameData,"<color=red>当前游戏过程数据</color>")
	local rate = gameData.rate
	if rate > 5 * 9 and rate <= 10 * 9 then
		return 1,rate
	elseif rate > 10 * 9 and rate <= 30 * 9 then
		return 2,rate
	elseif rate > 30 * 9 then
		return 3,rate
	end
end