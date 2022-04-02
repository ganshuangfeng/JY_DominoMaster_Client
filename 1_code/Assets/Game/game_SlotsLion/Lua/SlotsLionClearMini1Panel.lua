-- 创建时间:2021-12-15
-- Panel:SlotsLionClearMini1Panel
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

SlotsLionClearMini1Panel = basefunc.class()
local M = SlotsLionClearMini1Panel
M.name = "SlotsLionClearMini1Panel"

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

function M.Show()
	if not instance then
		return
	end

	local gameData = SlotsLionModel.GetGameProcessCurData()
	local step_index = SlotsLionModel.GetGameProcess().step

	--免费游戏
	--如果不是全盘奖励，就只展示线。如果是全盘奖励，那么展示单独展示全盘奖励后继续下一轮
	local func = function ()
		if gameData.isTotalRewardsList[step_index] then
			SlotsLionClearMini1Panel.Instance:PlayTotal()
		else
			local _gameData = gameData.lineRateList[step_index]
			SlotsLionLinePanel.Instance:PlayLine(_gameData,function ()
				SlotsLionLinePanel.Instance:ReSetAll()
				local seq = SlotsLionHelper.GetSeq()
				instance:PlayAddFree(seq)
				seq:AppendCallback(function ()
					if step_index == #gameData.lineRateList then
						SlotsLionClearMini1Panel.Instance:PlayFinal(#gameData.lineRateList)			
					else
						SlotsLionClearPanel.Hide({game = "mini1"})
					end
				end)
			end)
		end
	end

	local seq = DoTweenSequence.Create()
	seq:AppendCallback(
		function ()
			func()
		end
	)
end

function M:MyExit()
	SlotsLionHelper.KillSeq(self.tween)
	SlotsLionHelper.KillSeq(self.seq)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	ExtPanel.ExtMsg(self)
	self:InitUI()
end

function M:MyRefresh()
	SlotsLionHelper.KillSeq(self.tween)
	SlotsLionHelper.KillSeq(self.seq)
	self:HideAllClear()
end

function M:InitUI()
	self.transform = SlotsLionClearPanel.Instance.transform
	self.gameObject = SlotsLionClearPanel.Instance.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
end

--total结算
function M:PlayTotal()
	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_overallreward.audio_name)

	local seq = SlotsLionHelper.GetSeq()
	self.seq = seq
	local _gameData = SlotsLionModel.GetGameProcessCurData().lineRateList
	local step_index =  SlotsLionModel.GetGameProcess().step
	dump(_gameData)
	dump(step_index)

	local gameData = _gameData[step_index]
	dump(gameData)
	local bet = SlotsLionModel.GetBetMoneyOneLine()
	local rate = gameData[1].rate
	-- for k,v in pairs(gameData) do
	-- 	rate = rate + v.rate
	-- 	break
	-- end
	if rate == 0 then
		self:PlayAddFree(seq)
		seq:AppendCallback(function ()
			if gameData.liner and step_index == #gameData.lineRateList then
				SlotsLionClearMini1Panel.Instance:PlayFinal(#gameData.lineRateList)			
			else
				SlotsLionClearPanel.Hide({game = "mini1"})
			end
		end)
		return
	end
	self.winMoney = rate * bet
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv5_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv5.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
		Event.Brocast("ItemWinConnect",{money = addMoney})
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv5)
	seq:AppendInterval(t)	
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearHide)
	seq:AppendInterval(t)
	self:PlayAddFree(seq)
	local gd = SlotsLionModel.GetGameProcessCurData()
	seq:AppendCallback(function ()

		if step_index == #gd.lineRateList then
			SlotsLionClearMini1Panel.Instance:PlayFinal(#gd.lineRateList)			
		else
			SlotsLionClearPanel.Hide({game = "mini1"})
		end
		-- SlotsLionClearPanel.Hide({game = "mini1"})
	end)
end

function M:HideAllClear()
	SlotsLionClearPanel.Instance:HideAllClear()
end

function M:PlayFinal(times)
	-- ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free.audio_name)

	local seq = SlotsLionHelper.GetSeq()
	self.seq = seq
	local _gameData = SlotsLionModel.GetGameProcessCurData().lineRateList
	dump(_gameData)
	local rate = SlotsLionModel.data.baseData.totalRate
	if rate == 0 then
		self:PlayAddFree(seq)
		SlotsLionClearPanel.Hide({game = "mini1"})
		return
	end
	self.winMoney =  SlotsLionModel.data.baseData.totalMoney

	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv4_txt.text = StringHelper.AddPoint(money)
	end
	self.free_times_txt.text = times
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv4.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv4)
	seq:AppendInterval(t)	
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearHide)
	seq:AppendInterval(t)
	self:PlayAddFree(seq)
	seq:AppendCallback(function ()
		SlotsLionClearPanel.Hide({game = "mini1"})
	end)
end

function M:PlayAddFree(seq)
	dump(debug.traceback(),"<color=white>小游戏1增加免费游戏</color>")
	local pro = SlotsLionModel.GetGameProcess()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	local freeCount = gameData.freeCount[pro.step + 1]
	dump(freeCount,"<color=green>免费游戏次数？？？？？</color>")
	if not freeCount or not next(freeCount) then
		return
	end
	if freeCount.add < 3 then
		return
	end

	seq:AppendCallback(function ()
		SlotsLionGameMini1Panel.Instance:PlayAddFree(freeCount)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemARoll)
	seq:AppendInterval(t)
end