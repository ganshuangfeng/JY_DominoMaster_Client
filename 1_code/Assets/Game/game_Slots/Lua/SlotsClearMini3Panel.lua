-- 创建时间:2021-12-15
-- Panel:SlotsClearMini3Panel
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

SlotsClearMini3Panel = basefunc.class()
local M = SlotsClearMini3Panel
M.name = "SlotsClearMini3Panel"

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
	if data.game ~= "mini3" then
		return
	end
	local seq = SlotsHelper.GetSeq()
	self.seq = seq
	self:PlayAwardPool(seq)
	local t = SlotsModel.GetTime(SlotsModel.time.clearHide)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		SlotsClearPanel.Hide()
	end)
end

--这里是开奖池
function M:PlayAwardPool(seq)
	if not seq then
		return
	end
	local gameData = SlotsModel.GetGameProcessCurData()
	dump(gameData,"<color=yellow>Mini3开奖池</color>")
	local awardPoolId = gameData.awardPoolId
	if awardPoolId == 1 then
		self:PlayAwardPoolLV1(seq)
	elseif awardPoolId == 2 then
		self:PlayAwardPoolLV2(seq)
	elseif awardPoolId == 3 then
		self:PlayAwardPoolLV3(seq)
	elseif awardPoolId == 4 then
		self:PlayAwardPoolLV4(seq)
	end
end

function M:PlayAwardPoolLV1(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv1_txt.text = StringHelper.AddPoint(money)
	end

	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = gameData.rate
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local money = betMoney * rate
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv1.gameObject:SetActive(true)

		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearAwardPool1)
	seq:AppendInterval(t)
end

function M:PlayAwardPoolLV2(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv2_txt.text = StringHelper.AddPoint(money)
	end

	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = gameData.rate
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local money = betMoney * rate
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv2.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearAwardPool2)
	seq:AppendInterval(t)
end

function M:PlayAwardPoolLV3(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv3_txt.text = StringHelper.AddPoint(money)
	end

	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = gameData.rate
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	local money = betMoney * rate
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv3.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearAwardPool3)
	seq:AppendInterval(t)
end

function M:PlayAwardPoolLV4(seq)
	local duration = SlotsModel.GetTime(SlotsModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv4_txt.text = StringHelper.AddPoint(money)
	end

	local money = SlotsModel.data.baseData.awardPool4Money
	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = gameData.rate
	local betMoney = SlotsModel.GetBetMoneyOneLine()
	money = money + rate * betMoney
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv4.gameObject:SetActive(true)
		SlotsHelper.KillSeq(self.tween)
		self.tween = SlotsAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearAwardPool4)
	seq:AppendInterval(t)
end

function M:HideAllClear()
	SlotsClearPanel.Instance:HideAllClear()
end