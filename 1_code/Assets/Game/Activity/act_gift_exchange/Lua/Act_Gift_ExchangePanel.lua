-- 创建时间:2022-02-08
-- Panel:Act_Gift_ExchangePanel
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

Act_Gift_ExchangePanel = basefunc.class()
local C = Act_Gift_ExchangePanel
local M = Act_Gift_ExchangeManager
C.name = "Act_Gift_ExchangePanel"

local MIN_LENGTH = 6
local MAX_LENGTH = 10

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["use_redeem_code_response"] = basefunc.handler(self, self.use_redeem_code_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	self:ResetCooldownTimer()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

--	@GameManager.GotoUI({gotoui="act_gift_exchange",goto_scene_parm="panel"})
function C:AddListenerGameObject()
	self.exchange_btn.onClick:AddListener(function()
		self:OnClickExchange()
	end)

	-- self.back_btn.onClick:AddListener(function()
	-- 	self:MyExit()
	-- end)
	self.inputField.onValueChanged:AddListener(function (val)
		self:RefreshHint()
	end)
end

function C:RemoveListenerGameObject()
	self.exchange_btn.onClick:RemoveAllListeners()
	-- self.back_btn.onClick:RemoveAllListeners()
	self.inputField.onValueChanged:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.inputField = self.transform:Find("InputField"):GetComponent("InputField")
	
	self.isCoolDown = false
	-- self.inputField.onEndEdit:AddListener(function()
	-- 	self:RefreshHint()
	-- end)

	
	self:MyRefresh()
	self:RefreshHint()
end

function C:MyRefresh()
end

--兑换
function C:OnClickExchange()

	-- self.isCoolDown = M.IsCoolDown()
	-- if self.isCoolDown then
	-- 	dump("冷却中")
	-- 	return
	-- end
	local inputText = self.inputField.text
	if inputText == "" then
		return
	end
	Network.SendRequest("use_redeem_code", {code = self.inputField.text}, "发送兑换请求")
end

function C:use_redeem_code_response(_, data)
	dump(data, "<color=white>+++++use_redeem_code_response+++++</color>")
	if data.result == 0 then
		dump("兑换成功")
	else
		HintPanel.ErrorMsg(data.result)
		local time = data.time or 0
		if time > 0 then
			local expiredTime = os.time() + time
			M.SetExpriedTime(expiredTime)
			self:RefreshHint()
		end
	end
end

function C:RefreshHint()
	if not IsEquals(self.gameObject) then
		return
	end

	self.isCoolDown = M.IsCoolDown()
	-- dump(self.isCoolDown, "<color=white> self.isCoolDown </color>")
	if self.isCoolDown then
		self:ResetCooldownTimer()
		self.cooldownSecond = M.GetExpirdeTime() - os.time() 
		local refreshCoolDownHint = function()
			local stamp = os.date("!*t", self.cooldownSecond)
			self.hint_txt.text = string.format("提示：连续输入错误次数已达上限，请稍后 ( %02d:%02d:%02d )", stamp.hour, stamp.min, stamp.sec)
		end
		self.cooldownTimer = Timer.New(function ()
			self.cooldownSecond = self.cooldownSecond - 1
			if self.cooldownSecond <= 0 then
				self.hint_txt.text = ""
				self:RefreshHint()
				self.isCoolDown = false
				M.DeleteExpriedTimePref()
				self:ResetCooldownTimer()
			else
				refreshCoolDownHint()
			end
		end, 1, -1)
		self.cooldownTimer:Start()
		refreshCoolDownHint()
	else
		local inputText = self.inputField.text
		if inputText == "" then
			self.hint_txt.text = ""
			return
		end
	
		if string.len(inputText) <= MAX_LENGTH and string.len(inputText) >= MIN_LENGTH then
			-- self.hint_txt.color = Color.New(237/255, 136/255, 19/255)
			self.hint_txt.text = "提示：兑换码格式正确"
			disable = false
		else
			-- self.hint_txt.color = Color.New(237/255, 40/255, 19/255)
			self.hint_txt.text = "提示：兑换码格式错误"
		end
	end
end

function C:ResetCooldownTimer()
	if self.cooldownTimer then
		self.cooldownTimer:Stop()
		self.cooldownTimer = nil
	end
	self.cooldownSecond = 0
end

function C:OnExitScene()
	self.MyExit()
end