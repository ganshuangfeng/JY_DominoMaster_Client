-- 创建时间:2021-12-15
-- Panel:SlotsClearMini1Panel
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

SlotsClearMini1Panel = basefunc.class()
local M = SlotsClearMini1Panel
M.name = "SlotsClearMini1Panel"

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
	dump(data,"<color=yellow>金玉满堂结算data？？？？</color>")
	if data.game ~= "mini1" then
		return
	end
	local seq = SlotsHelper.GetSeq()
	self.seq = seq
	self:PlayAddFree(seq)
	self:PlayNormal(seq)
	self:PlayAwardPoolMax(seq)
	self:PlayMini(seq)
	self:PlayMiniLast(seq)
	local t = SlotsModel.GetTime(SlotsModel.time.clearHide)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		SlotsClearPanel.Hide()
	end)
end

function M:PlayAddFree(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if id == "H" then
				seq:AppendCallback(function ()
					SlotsMiniGame1Panel.Instance:PlayAddFree(x,y)
				end)
				local t = SlotsModel.GetTime(SlotsModel.time.effectAddFree)
				seq:AppendInterval(t)
			end
		end
	end
end

function M:PlayNormal(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local rateEFG = gameData.rateMapItemEFGList[pro.step]
	if not rateEFG or not next(rateEFG) then
		--没有倍率
		return
	end

	local t = SlotsMiniGame1Panel.Instance:GetPlayAwardAniTime()
	seq:AppendCallback(function ()
		self:HideAllClear()
		SlotsMiniGame1Panel.Instance:PlayAwardAni()
	end)
	t = t + SlotsModel.GetTime(SlotsModel.time.clearMiniGame1Normal)
	seq:AppendInterval(t)

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

function M:PlayMini(seq)
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	if pro.step < #gameData.itemDataMapList then
		--不是最后结算
		return
	end
	local rate = gameData.rate
	if not rate or rate == 0 then
		--没有倍率
		return
	end

	--飞倍率动画
	local t = SlotsMiniGame1Panel.Instance:GetPlayRateAniTime()
	seq:AppendCallback(function ()
		self:HideAllClear()
		SlotsMiniGame1Panel.Instance:PlayRateAni()
	end)
	seq:AppendInterval(t)

	seq:AppendCallback(function ()
		self:HideAllClear()
		SlotsMiniGame1Panel.Instance.award.gameObject:SetActive(false)
		SlotsEffect.PlayMiniGame1AwardFly(SlotsMiniGame1Panel.Instance.award.gameObject)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1AwardFly)
	seq:AppendInterval(t)

	local betMoney = SlotsModel.GetBetMoneyOneLine()
	seq:AppendCallback(function ()
		SlotsAnimation.PlayMiniGame1BgShow(self)
		-- self.mini_game_1.gameObject:SetActive(true)
		self.mini_game_1_bonus_txt.text = rate
		self.mini_game_1_play_txt.text = betMoney
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1)
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
		self.mini_game_last.gameObject:SetActive(true)
		self.mini_game_last_txt.text = StringHelper.AddPoint(allMoney)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniLast)
	seq:AppendInterval(t)
end

function M:HideAllClear()
	SlotsClearPanel.Instance:HideAllClear()
end