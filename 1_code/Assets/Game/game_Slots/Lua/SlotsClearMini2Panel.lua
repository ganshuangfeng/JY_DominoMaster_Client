-- 创建时间:2021-12-15
-- Panel:SlotsClearMini2Panel
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

SlotsClearMini2Panel = basefunc.class()
local M = SlotsClearMini2Panel
M.name = "SlotsClearMini2Panel"

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
	instance:PlaySettlement()
end

function M:MyExit()
	SlotsHelper.KillSeq(self.tween)
	SlotsHelper.KillSeq(self.seq)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	ExtPanel.ExtMsg(self)
	self:InitUI()
end

function M:MyRefresh()
	SlotsHelper.KillSeq(self.tween)
	SlotsHelper.KillSeq(self.seq)
	self:HideAllClear()
end

function M:InitUI()
	self.transform = SlotsClearPanel.Instance.transform
	self.gameObject = SlotsClearPanel.Instance.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:PlaySettlement()
	self:HideAllClear()
	local data = SlotsModel.GetGameProcessCurData()
	if data.game ~= "mini2" then
		return
	end
	local seq = SlotsHelper.GetSeq()
	self.seq = seq
	-- self:Play5Line(seq)
	self:PlayNormal(seq)
	self:PlayAwardPoolMax(seq)
	self:PlayRate(seq)
	self:PlayMini(seq)
	self:PlayMiniLast(seq)
	local t = SlotsModel.GetTime(SlotsModel.time.clearHide)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		SlotsClearPanel.Hide()
	end)
end

function M:Check5Line()
	local gamePro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local step = gamePro.step
	local itemWin = SlotsLib.GetItemWinConnect(gameData.itemDataMapList[step],gameData.itemRateList[step])
	if itemWin[SlotsModel.size.xMax] and next(itemWin[SlotsModel.size.xMax]) then
		return true
	end
end

function M:Play5Line(seq)
	if not seq then
		return
	end

	if not self:Check5Line() then
		return
	end

	seq:AppendCallback(function ()
		self:HideAllClear()   
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_5lianxian.audio_name)
		self.gameObject:SetActive(true)
		self.line5.gameObject:SetActive(true)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clear5line)
	seq:AppendInterval(t)
	return t
end

function M:CheckNormalLv()
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = 0
	local allRate = gameData.itemRateList[pro.step]
	if not allRate or not next(allRate) then
		return
	end

	for k, v in pairs(allRate) do
		rate = rate + v
	end

	if rate > 10 then
		return 1, rate
	elseif rate > 20 then
		return 2, rate
	elseif rate > 30 then
		return 3, rate
	end
end


function M:PlayNormal(seq)
	if not seq then
		return
	end

	local lv,rate = self:CheckNormalLv()
	if not lv then
		return
	end

	local bet = SlotsModel.GetBetMoneyOneLine()
	self.winMoney = rate * bet
	SlotsClearPanel.Instance.gameObject:SetActive(true)
	if lv == 1 then
		return self:PlayNormalLV1(seq)
	elseif lv == 2 then
		return self:PlayNormalLV2(seq)
	elseif lv == 3 then
		return self:PlayNormalLV3(seq)
	end
end

function M:PlayNormalLV1(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv1_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_bigwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv1.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearNormalLv1)
	seq:AppendInterval(t)
	return t
end

function M:PlayNormalLV2(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv2_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_megawin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv2.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearNormalLv2)
	seq:AppendInterval(t)
	return t
end

function M:PlayNormalLV3(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.normal_lv3_txt.text = StringHelper.AddPoint(money)
	end
	local addMoney = self.winMoney
	seq:AppendCallback(function ()
		self:HideAllClear()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_superwin.audio_name)
		self.back_btn.gameObject:SetActive(true)
		self.normal_lv3.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,addMoney,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearNormalLv3)
	seq:AppendInterval(t)
	return t
end

function M:PlayAwardPoolMax(seq)
	local gameData = SlotsModel.GetGameProcessCurData()
	if not gameData.awardPoolMaxId or not gameData.awardPoolMaxIndex or not next(gameData.awardPoolMaxIndex) then
		return
	end
	local pro = SlotsModel.GetGameProcess()
	if pro.step ~= gameData.awardPoolMaxIndex.i then
		return
	end

	local money = SlotsModel.data.baseData.awardPool4Money
	local rate = SlotsModel.GetAwardPool()
	rate = rate[4]
	local bet = SlotsModel.GetBetMoneyOneLine()
	money = money + rate * bet

	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.back_btn.gameObject:SetActive(true)
		self.award_pool_lv4.gameObject:SetActive(true)
		local callback = function (m)
			self.award_pool_lv4_txt.text = StringHelper.AddPoint(m)
		end
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,money,callback,SlotsModel.time.clearAwardPool4MoneyRoll,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearAwardPool4)
	seq:AppendInterval(t)
end

function M:PlayRate(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	local itemFMap = {}
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if id == "F" then
				itemFMap[x] = itemFMap[x] or {}
				itemFMap[x][y] = id
			end
		end
	end

	--没有福绿
	if not next(itemFMap) then
		return
	end

	--飞倍率动画
	local t = SlotsMiniGame2Panel.Instance:GetPlayRateAniTime()
	seq:AppendCallback(function ()
		self:HideAllClear()
		SlotsMiniGame2Panel.Instance:PlayRateAni()
	end)
	seq:AppendInterval(t)
	seq:OnKill(function ()
		SlotsMiniGame2Panel.Instance:RefreshRate()
	end)
end

function M:PlayMini(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	if pro.step < #gameData.itemDataMapList then
		--不是最后结算
		return
	end
	local rateItemF = gameData.rateItemF
	if not rateItemF or rateItemF == 0 then
		--没有倍率
		return
	end

	seq:AppendCallback(function ()
		self:HideAllClear()
		SlotsMiniGame2Panel.Instance.mini_award_txt.gameObject:SetActive(false)
		SlotsEffect.PlayMiniGame2AwardFly(SlotsMiniGame2Panel.Instance.mini_award_txt.gameObject)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2AwardFly)
	seq:AppendInterval(t)

	local betMoney = SlotsModel.GetBetMoneyOneLine()
	seq:AppendCallback(function ()
		SlotsAnimation.PlayMiniGame2BgShow(self)
		-- self:HideAllClear()
		-- self.back_btn.gameObject:SetActive(true)
		-- self.mini_game_2.gameObject:SetActive(true)
		self.mini_game_2_bonus_txt.text = rateItemF
		self.mini_game_2_play_txt.text = betMoney
		-- self.mini_game_2_win_txt.text = rateItemF * betMoney
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2)
	seq:AppendInterval(t)
end

function M:PlayMiniLast(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	if pro.step < #gameData.itemDataMapList then
		--不是最后结算
		return
	end
	local rate = gameData.rate
	if not rate or rate == 0 then
		return
	end
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local allMoney = rate * betMoney
	allMoney = SlotsModel.data.baseData.totalMoney
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_jiesuan.audio_name)
		self:HideAllClear()
		self.back_btn.gameObject:SetActive(true)
		self.mini_game_last.gameObject:SetActive(true)
		self.mini_game_last_txt.text =  StringHelper.AddPoint(allMoney)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniLast)
	seq:AppendInterval(t)
end

function M:HideAllClear()
	SlotsClearPanel.Instance:HideAllClear()
end

function M:PlayNormalNot5Line(seq)
	if self:Check5Line() then
		return
	end
	return self:PlayNormal(seq)
end

function M:PlayNormalHas5Line(seq)
	if not self:Check5Line() then
		return
	end
	return self:PlayNormal(seq)
end