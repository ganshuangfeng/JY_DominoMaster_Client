-- 创建时间:2021-12-15
-- Panel:SlotsLionClearMainPanel
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

SlotsLionClearMainPanel = basefunc.class()
local M = SlotsLionClearMainPanel
M.name = "SlotsLionClearMainPanel"

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

	local pro = SlotsLionModel.GetGameProcess()
	local step_index =  SlotsLionModel.GetGameProcess().step
	local gameData = SlotsLionModel.GetGameProcessCurData()
	if gameData and gameData.lineRate and next(gameData.lineRate) then
		if gameData.isTotalRewards then
			instance:PlayTotal()
		else
			SlotsLionLinePanel.Instance:PlayLine(gameData.lineRate,function ()
				instance:PlaySettlement()
			end,false)
		end
	else
		local seq = SlotsLionHelper.GetSeq()
		instance.seq = seq
		-- seq:AppendCallback(function ()
		-- 	instance:HideAllClear()
		-- end)
		-- instance:PlayItemARoll(seq)
		-- instance:PlayTriggerFree(seq)
		seq:AppendCallback(function ()
			SlotsLionClearPanel.Hide({game = "main"})
		end)
	end
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
	self.game_mini1_trigger = SlotsLionClearPanel.Instance.game_mini1_trigger
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:PlaySettlement()
	self:HideAllClear()

	local data = SlotsLionModel.GetGameProcessCurData()
	if data.game ~= "main" then
		return
	end
	local seq = SlotsLionHelper.GetSeq()
	self.seq = seq
	self:PlayNormal(seq)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearHide)
	seq:AppendInterval(t)
	-- seq:AppendCallback(function ()
	-- 	self:HideAllClear()
	-- end)
	-- self:PlayItemARoll(seq)
	-- self:PlayTriggerFree(seq)
	seq:AppendCallback(function ()
		SlotsLionClearPanel.Hide({game = "main"})
	end)
end

function M:Check5Line()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	local itemWin = SlotsLionLib.GetItemWinConnect(gameData.itemDataMap,gameData.itemRate)
	if itemWin[SlotsLionModel.size.xMax] and next(itemWin[SlotsLionModel.size.xMax]) then
		return true
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

function M:PlayNormal(seq)
	if not seq then
		return
	end

	local lv,rate = self:CheckNormalLv()
	dump({lv,rate})
	if not lv then
		return
	end

	local bet = SlotsLionModel.GetBetMoneyOneLine()
	self.winMoney = rate * bet

	SlotsLionClearPanel.Instance.gameObject:SetActive(true)
	if lv == 1 then
		return self:PlayNormalLV1(seq)
	elseif lv == 2 then
		return self:PlayNormalLV2(seq)
	elseif lv == 3 then
		return self:PlayNormalLV3(seq)

	end
end

function M:PlayNormalLV1(seq)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv1_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_bigwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv1.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv1)
	seq:AppendInterval(t)
	return t
end

function M:PlayNormalLV2(seq)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv2_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_megawin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv2.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv2)
	seq:AppendInterval(t)
	return t
end

function M:PlayNormalLV3(seq)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv3_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv3.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv3)
	seq:AppendInterval(t)
	return t
end
--免费游戏的结算
function M:PlayNormalLV4(seq,times)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv4_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	self.free_times_txt.text = times
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv4.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv4)
	seq:AppendInterval(t)
	return t
end
--total结算
function M:PlayNormalLV5(seq)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv5_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv5.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv5)
	seq:AppendInterval(t)
	return t
end

--total结算
function M:PlayTotal()
	local seq = SlotsLionHelper.GetSeq()
	self.seq = seq
	local gameData = SlotsLionModel.GetGameProcessCurData()
	dump(gameData,"<color=red>当前游戏过程数据</color>")
	local rate = gameData.rate
	local bet = SlotsLionModel.GetBetMoneyOneLine()
	self.winMoney = rate * bet
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv5_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv5.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv5)
	seq:AppendInterval(t)	
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearHide)
	seq:AppendInterval(t)
	-- seq:AppendCallback(function ()
	-- 	self:HideAllClear()
	-- end)
	-- self:PlayItemARoll(seq)
	-- self:PlayTriggerFree(seq)
	seq:AppendCallback(function ()
		SlotsLionClearPanel.Hide({game = "main"})
	end)
end

function M:HideAllClear()
	SlotsLionClearPanel.Instance:HideAllClear()
end

function M:PlayItemARoll(seq)
	local pro = SlotsLionModel.GetGameProcess()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	local c = 0
	for x, v in pairs(gameData.itemDataMap) do
		for y, id in pairs(v) do
			if id == "A" then
				c = c + 1
			end
		end
	end
	if c < 3 then
		return
	end

	seq:AppendCallback(function ()
		local gameData = SlotsLionModel.GetGameProcessCurData()
		SlotsLionEffect.PlayItemARoll(gameData.itemDataMap)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemARoll)
	seq:AppendInterval(t)
end

function M:PlayTriggerFree(seq)
	local pro = SlotsLionModel.GetGameProcess()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	local c = 0
	--检查整个Y轴上没有没 “9”
	function is_have_9(x)
		for i = 1,3 do
			if gameData.itemDataMap[x][i] == "9" then
				return true
			end
		end
		return false
	end

	for x, v in pairs(gameData.itemDataMap) do
		for y, id in pairs(v) do
			if id == "A" and not is_have_9(x) then
				c = c + 1
			end
		end
	end
	if c < 3 then
		return
	end

	seq:AppendCallback(function ()
		self:ShowGameMini1Trigger(true)
		SlotsLionGamePanel.Instance.bg2.gameObject:SetActive(true)
		SlotsLionGamePanel.Instance.bg1.gameObject:SetActive(false)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectTriggerFree)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		self:ShowGameMini1Trigger(false)
	end)
	seq:AppendInterval(0.02)
end

function M:ShowGameMini1Trigger(b)
	self.game_mini1_trigger.gameObject:SetActive(b)
end

function M:PlayTotal()
	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_overallreward.audio_name)

	local seq = SlotsLionHelper.GetSeq()
	self.seq = seq

	local _gameData = SlotsLionModel.GetGameProcessCurData().lineRate

	local bet = SlotsLionModel.GetBetMoneyOneLine()
	local rate = 0
	for k,v in pairs(_gameData) do
		rate = rate + v.rate
	end
	if rate == 0 then
		SlotsLionClearPanel.Hide({game = "mini1"})
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
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearNormalLv5)
	seq:AppendInterval(t)	
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearHide)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		SlotsLionClearPanel.Hide({game = "main"})
	end)
end
