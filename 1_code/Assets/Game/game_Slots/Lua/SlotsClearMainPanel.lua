-- 创建时间:2021-12-15
-- Panel:SlotsClearMainPanel
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

SlotsClearMainPanel = basefunc.class()
local M = SlotsClearMainPanel
M.name = "SlotsClearMainPanel"

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
	if data.game ~= "main" then
		return
	end
	local seq = SlotsHelper.GetSeq()
	self.seq = seq
	-- self:Play5Line(seq)
	self:PlayNormalHas5Line(seq)
	local t = SlotsModel.GetTime(SlotsModel.time.clearHide)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		SlotsClearPanel.Hide()
	end)
end

function M:Check5Line()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemWin = SlotsLib.GetItemWinConnect(gameData.itemDataMap,gameData.itemRate)
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
	local gameData = SlotsModel.GetGameProcessCurData()
	local rate = gameData.rate
	if rate > 5 * 88 and rate <= 10 * 88 then
		return 1,rate
	elseif rate > 10 * 88 and rate <= 30 * 88 then
		return 2,rate
	elseif rate > 30 * 88 then
		return 3,rate
	end
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


function M:HideAllClear()
	SlotsClearPanel.Instance:HideAllClear()
end