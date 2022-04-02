-- 创建时间:2021-12-15
-- Panel:SlotsLionClearMini2Panel
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

SlotsLionClearMini2Panel = basefunc.class()
local M = SlotsLionClearMini2Panel
M.name = "SlotsLionClearMini2Panel"

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
	dump(pro,"<color=red>PP</color>")

	local gameData = SlotsLionModel.GetGameProcessCurDataParallel("mini2",pro.game,pro.step)
	dump(gameData,"<color=red>当前游戏过程数据</color>")
	if not gameData then
		return
	end
	local seq = SlotsLionHelper.GetSeq()
	M.Instance.seq = seq
	local id = tonumber(gameData.item)
	if gameData.rate > 0 then
		if id == 1 then
			instance:PlayAwardPoolLV1(seq,gameData.rate)
		elseif id == 2 then
			instance:PlayAwardPoolLV2(seq,gameData.rate)
		elseif id == 3 then
			instance:PlayAwardPoolLV3(seq,gameData.rate)
		end
	else
		seq:AppendCallback(function ()
			instance:HideAllClear()
		end)
		instance:PlayItemARoll(seq)
		instance:PlayTriggerFree(seq)
		seq:AppendCallback(function ()
			SlotsLionClearPanel.Hide({game = "mini2"})
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
	SlotsLionEffect.StopLionEffect()
end

function M:InitUI()
	self.transform = SlotsLionClearPanel.Instance.transform
	self.gameObject = SlotsLionClearPanel.Instance.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:PlayAwardPoolLV1(seq,rate)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv1_txt.text = StringHelper.AddPoint(money)
	end

	local money = SlotsLionModel.GetAwardPoolMoney()[1]
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv1.gameObject:SetActive(true)

		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
		Event.Brocast("ItemWinConnect",{money = money})
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearAwardPool1)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		instance:HideAllClear()
	end)
	instance:PlayItemARoll(seq)
	instance:PlayTriggerFree(seq)
	seq:AppendCallback(
		function ()
			SlotsLionEffect.StopLionEffect()
			SlotsLionClearPanel.Hide({game = "mini2"})
		end
	)
	seq:AppendInterval(0.02)
end

function M:PlayAwardPoolLV2(seq,rate)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv2_txt.text = StringHelper.AddPoint(money)
	end

	local money = SlotsLionModel.GetAwardPoolMoney()[2]
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv2.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
		Event.Brocast("ItemWinConnect",{money = money})
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearAwardPool2)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		instance:HideAllClear()
	end)
	instance:PlayItemARoll(seq)
	instance:PlayTriggerFree(seq)
	seq:AppendCallback(
		function ()
			SlotsLionEffect.StopLionEffect()
			SlotsLionClearPanel.Hide({game = "mini2"})
		end
	)
	seq:AppendInterval(0.02)
end

function M:PlayAwardPoolLV3(seq,rate)
	local duration = SlotsLionModel.GetTime(SlotsLionModel.time.moneyChangeLine)
	local setTxtCall = function (money)
		self.award_pool_lv3_txt.text = StringHelper.AddPoint(money)
	end

	local money = SlotsLionModel.GetAwardPoolMoney()[3]
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jp_jiesuan.audio_name)
		self:HideAllClear()
		self.award_pool_lv3.gameObject:SetActive(true)
		SlotsLionHelper.KillSeq(self.tween)
		self.tween = SlotsLionAnimation.PlayMoneyChange(0,money,setTxtCall,duration,self)
		SlotsLionAwardPoolPanel.Instance:PlayAwardPool3ExtChange(rate)
		Event.Brocast("ItemWinConnect",{money = money})
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearAwardPool3)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		instance:HideAllClear()
	end)
	instance:PlayItemARoll(seq)
	instance:PlayTriggerFree(seq)
	seq:AppendCallback(
		function ()
			SlotsLionEffect.StopLionEffect()
			SlotsLionClearPanel.Hide({game = "mini2"})
		end
	)
	seq:AppendInterval(0.02)
end

function M:HideAllClear()
	SlotsLionClearPanel.Instance:HideAllClear()
end

function M:PlayItemARoll(seq)
	local pro = SlotsLionModel.GetGameProcess()
	if pro.game == "main" then
		SlotsLionClearMainPanel.Instance:PlayItemARoll(seq)
	elseif pro.game == "mini1" then
		-- local pp = SlotsLionModel.GetGameProcessParallel()
        -- local p = SlotsLionModel.GetGameProcess()
		-- if pp.gameType == p.game and pp.step == p.step then
		-- 	SlotsLionClearMini1Panel.Instance:PlayAddFree(seq)
		-- end
	end
end

function M:PlayTriggerFree(seq)
	local pro = SlotsLionModel.GetGameProcess()
	if pro.game == "main" then
		SlotsLionClearMainPanel.Instance:PlayTriggerFree(seq)
	elseif pro.game == "mini1" then
		-- local pp = SlotsLionModel.GetGameProcessParallel()
        -- local p = SlotsLionModel.GetGameProcess()
		-- if pp.gameType == p.game and pp.step == p.step then
		-- 	SlotsLionClearMini1Panel.Instance:PlayAddFree(seq)
		-- end
	end
end