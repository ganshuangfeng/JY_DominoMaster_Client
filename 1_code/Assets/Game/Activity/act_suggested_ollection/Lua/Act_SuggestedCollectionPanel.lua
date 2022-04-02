-- 创建时间:2022-03-07
-- Panel:Act_SuggestedCollectionPanel
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

Act_SuggestedCollectionPanel = basefunc.class()
local C = Act_SuggestedCollectionPanel
C.name = "Act_SuggestedCollectionPanel"

local Toogles = {
	question1_1_tge = "A",
	question1_2_tge = "B",
	question2_1_tge = "A",
	question2_2_tge = "B",
	question2_3_tge = "C",
	question2_4_tge = "D",
	question3_1_tge = "A",
	question3_2_tge = "B",
	question3_3_tge = "C",
	question3_4_tge = "D",
	question4_1_tge = "A",
	question4_2_tge = "B",
	question4_3_tge = "C",
	question4_4_tge = "D",
	question5_1_tge = "A",
	question5_2_tge = "B",
	question5_3_tge = "C",
	question5_4_tge = "D",
	question5_5_tge = "E",
	question6_1_tge = "A",
	question6_2_tge = "B",
	question6_3_tge = "C",
	question6_4_tge = "D",
	question7_1_tge = "A",
	question7_2_tge = "B",
	question7_3_tge = "C",
	question7_4_tge = "D",
	question7_5_tge = "E",	
}

local InputFields = {
	question8_ipf = "question8_txt",
	question9_ipf = "question9_txt",
	question10_ipf = "question10_txt",
}

local Questions = {
	question1_1_tge = 1,
	question1_2_tge = 1,
	question2_1_tge = 2,
	question2_2_tge = 2,
	question2_3_tge = 2,
	question2_4_tge = 2,
	question3_1_tge = 3,
	question3_2_tge = 3,
	question3_3_tge = 3,
	question3_4_tge = 3,
	question4_1_tge = 4,
	question4_2_tge = 4,
	question4_3_tge = 4,
	question4_4_tge = 4,
	question5_1_tge = 5,
	question5_2_tge = 5,
	question5_3_tge = 5,
	question5_4_tge = 5,
	question5_5_tge = 5,
	question6_1_tge = 6,
	question6_2_tge = 6,
	question6_3_tge = 6,
	question6_4_tge = 6,
	question7_1_tge = 7,
	question7_2_tge = 7,
	question7_3_tge = 7,
	question7_4_tge = 7,
	question7_5_tge = 7,
	question8_ipf = 8,
	question9_ipf = 9,
	question10_ipf = 10,
}

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
    self.lister["Act_SuggestedCollectionManager_StateChange"] = basefunc.handler(self, self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:AddListenerGameObject()
	self.gold_box_btn.onClick:AddListener(function()
		self:OnClickGoldBox()
	end)
	self.push_btn.onClick:AddListener(function()
		self:OnClickPush()
	end)
	for k, v in pairs(Toogles) do
		self[k].onValueChanged:AddListener(
			function(val)
				self:OnValueChangedToogle(val,k,v)
			end
		)
	end

	for k, v in pairs(InputFields) do
		self[k].onValueChanged:AddListener(function (val)
			self:OnValueChangedInputField(val,k,v)
		end)
		self[k].onEndEdit:AddListener(function (val)
			self:OnEndEditInputField(val,k,v)
		end)
	end
end

function C:RemoveListenerGameObject()
	self.gold_box_btn.onClick:RemoveAllListeners()
	self.push_btn.onClick:RemoveAllListeners()
	for k, v in pairs(Toogles) do
		self[k].onValueChanged:RemoveAllListeners()
	end

	for k, v in pairs(InputFields) do
		self[k].onValueChanged:RemoveAllListeners()
		self[k].onEndEdit:RemoveAllListeners()
	end
end

function C:MyExit()
	self:StopCD()
	self:RemoveListener()
	self:RemoveListenerGameObject()
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
	local _parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, _parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()

	self:RefreshLL()
	self:MyRefresh()
	self:StartCD()
	Act_SuggestedCollectionManager.SetHintState()
end

function C:InitLL()
end

function C:RefreshAnswer()
	if self.state == "push" then
		return
	end

	for k, v in pairs(Toogles) do
		self[k].interactable = false
	end
	for k, v in pairs(InputFields) do
		self[k].interactable = false
	end

	local answer = Act_SuggestedCollectionManager.GetAnswer()
	if not answer or not next(answer) then
		return
	end

	for k, v in pairs(Toogles) do
		self[k].isOn = false
	end

	for k, v in pairs(answer) do
		if type(v) == "table" then
            for i, val in ipairs(v) do
				for k1, v1 in pairs(Questions) do
					if v1 == k and Toogles[k1] == val then
						self[k1].isOn = true
					end
				end
            end
        elseif type(v) == "string" then
            for k1, v1 in pairs(Questions) do
				if v1 == k and InputFields[k1] then
					self[k1].text = v
				end
			end
        end
	end

end

function C:RefreshLL()
	self.question1_title_txt.text = "1. " .. GLL.GetTx(81008)
	self.question1_1_txt.text = "A. " .. GLL.GetTx(81009)
	self.question1_2_txt.text = "B. " .. GLL.GetTx(81010)

	self.question2_title_txt.text =  "2. " .. GLL.GetTx(81011)
	self.question2_1_txt.text = "A. " .. GLL.GetTx(81012)
	self.question2_2_txt.text = "B. " .. GLL.GetTx(81013)
	self.question2_3_txt.text = "C. " .. GLL.GetTx(81014)
	self.question2_4_txt.text = "D. " .. GLL.GetTx(81015)

	self.question3_title_txt.text = "3. " .. GLL.GetTx(81016)
	self.question3_1_txt.text = "A. " .. GLL.GetTx(81017)
	self.question3_2_txt.text = "B. " .. GLL.GetTx(81018)
	self.question3_3_txt.text = "C. " .. GLL.GetTx(81019)
	self.question3_4_txt.text = "D. " .. GLL.GetTx(81020)

	self.question4_title_txt.text = "4. " .. GLL.GetTx(81021)
	self.question4_1_txt.text = "A. " .. GLL.GetTx(81022)
	self.question4_2_txt.text = "B. " .. GLL.GetTx(81023)
	self.question4_3_txt.text = "C. " .. GLL.GetTx(81024)
	self.question4_4_txt.text = "D. " .. GLL.GetTx(81025)

	self.question5_title_txt.text = "5. " .. GLL.GetTx(81026)
	self.question5_1_txt.text = "A. " .. GLL.GetTx(81027)
	self.question5_2_txt.text = "B. " .. GLL.GetTx(81028)
	self.question5_3_txt.text = "C. " .. GLL.GetTx(81029)
	self.question5_4_txt.text = "D. " .. GLL.GetTx(81030)
	self.question5_5_txt.text = "E. " .. GLL.GetTx(81031)

	self.question6_title_txt.text = "6. " .. GLL.GetTx(81032)
	self.question6_1_txt.text = "A. " .. GLL.GetTx(81033)
	self.question6_2_txt.text = "B. " .. GLL.GetTx(81034)
	self.question6_3_txt.text = "C. " .. GLL.GetTx(81035)
	self.question6_4_txt.text = "D. " .. GLL.GetTx(81036)

	self.question7_title_txt.text = "7. " .. GLL.GetTx(81037)
	self.question7_1_txt.text = "A. " .. GLL.GetTx(81038)
	self.question7_2_txt.text = "B. " .. GLL.GetTx(81039)
	self.question7_3_txt.text = "C. " .. GLL.GetTx(81040)
	self.question7_4_txt.text = "D. " .. GLL.GetTx(81041)
	self.question7_5_txt.text = "E. " .. GLL.GetTx(81042)

	self.question8_title_txt.text = "8. " .. GLL.GetTx(81043)
	self.question9_title_txt.text = "9. ".. GLL.GetTx(81044)
	self.question10_title_txt.text = "10. " .. GLL.GetTx(81045)

	self.question_title_txt.text = GLL.GetTx(81046)
	self.gold_tips_txt.text = GLL.GetTx(81047)
	self.push_btn_txt.text = GLL.GetTx(81048)
end

function C:InitUI()
	self.push_btn_img = self.push_btn.transform:GetComponent("Image")
	self.gold_box_btn_img = self.gold_box_btn.transform:Find("Image"):GetComponent("Image")
	self.gold_box_btn_ani = self.gold_box_btn.transform:GetComponent("Animator")
end

function C:MyRefresh()
	local state = Act_SuggestedCollectionManager.GetState()
	if self.state == state then
		return
	end
	self.state = state
	self:RefreshPush()
	self:RefreshGoldBox()
	self:RefreshAnswer()
end

function C:OnValueChangedToogle(val,k,v)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:SetToogleValue(Questions[k],v,val)
end

function C:SetToogleValue(q,v,val)
	self.questionSelect = self.questionSelect or {}
	self.questionSelect[q] = self.questionSelect[q] or {}
	self.questionSelect[q][v] = val
end

function C:OnValueChangedInputField(val,k,v)
	-- dump(val,"<color=green>OnValueChangedInputField</color>")
	if not self:CheckInput(val,k,v) then
		return
	end
end

function C:OnEndEditInputField(val,k,v)
	dump(val,"<color=green>OnEndEditInputField</color>")
end

function C:CheckInput(val,k,v)
	local cnt = string.utf8len(val)
    if cnt > 1000 then
		--字数已达上限～
        LittleTips.Create(GLL.GetTx(81050))
		self[k].text = string.sub(val,1,1000)
        return
    end
	return true
end

function C:OnClickPush()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--提交
	self:Push()
end

function C:CheckPush()
	if not self.questionSelect or not next(self.questionSelect) then
		return
	end
	local qn
	for k, v in pairs(Toogles) do
		qn = Questions[k]
		if qn then
			if not self.questionSelect[qn] or not next(self.questionSelect[qn]) then
				--第k个问题没有选择
				return
			else
				local b = false
				for k1, v1 in pairs(self.questionSelect[qn]) do
					if v1 then
						b = true
						break
					end
				end
				if not b then
					--第k个问题没有选择
					return
				end
			end
		end
	end


	for k, v in pairs(InputFields) do
		local str = self[k].text
		if not str or str == "" then
			--第k个问题没有填
			return
		end
	end

	return true
end

function C:GetPushQuestion()
	local q = {}
	for k, v in pairs(self.questionSelect or {}) do
		for k1, v1 in pairs(v) do
			if v1 == true then
				q[k] = q[k] or {}
				q[k][#q[k]+1] = k1
			end
		end
	end

	if not next(q) then
		--一个没选
		return
	end

	for k, v in pairs(Toogles) do
		if Questions[k] and not q[Questions[k]] then
			--第k个问题没有选择
			return
		end
	end

	for k, v in pairs(InputFields) do
		local str = self[k].text
		if not str or str == "" then
			--第k个问题没有填
			return
		end
		local qn = Questions[k]
		q[qn] = str
	end

	return q
end

function C:Push()
	local q = self:GetPushQuestion()
	if not q or not next(q) then
		--请完成所有问题后提交
		LittleTips.Create(GLL.GetTx(81051))
		return
	end
	Act_SuggestedCollectionManager.Push(q)
end

function C:RefreshPush()
	if self.state == "push" then
		self.push_btn_img.material = nil
	else
		self.push_btn.enabled = false
		self.push_btn.onClick:RemoveAllListeners()
		self.push_btn_img.material = GetMaterial("imageGrey")
	end
end

function C:OnClickGoldBox()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not self:CheckGetGold() then
		return
	end
	self:GetGold()
end

function C:CheckGetGold()
	if self.state == "push" then
		--请提交后领取～
		LittleTips.Create(GLL.GetTx(81049))
	elseif self.state == "wait_get" then
		--请提交后领取～
		LittleTips.Create(GLL.GetTx(81049))
	elseif self.state == "get" then
		return true
	elseif self.state == "finish" then
		LittleTips.Create("已领取")
	end
end

function C:GetGold()
	Act_SuggestedCollectionManager.GetGold()	
end

function C:RefreshGoldBox()
	if self.state == "push" then
		self.gold_get_img.gameObject:SetActive(false)
		self.gold_tips.gameObject:SetActive(true)
		self.gold_box_btn_ani.enabled = false
	elseif self.state == "wait_get" then
		self.gold_get_img.gameObject:SetActive(false)
		self.gold_tips.gameObject:SetActive(true)
		self.gold_box_btn_ani.enabled = false
	elseif self.state == "get" then
		self.gold_get_img.gameObject:SetActive(false)
		self.gold_tips.gameObject:SetActive(true)
		self.gold_box_btn_ani.enabled = true
	elseif self.state == "finish" then
		self.gold_box_btn.onClick:RemoveAllListeners()
		self.gold_box_btn.enabled = false
		self.gold_get_img.gameObject:SetActive(true)
		self.gold_tips.gameObject:SetActive(false)
		self.gold_box_btn_img.sprite = GetTexture("fbhd_yjwd_lbyl")
		self.gold_box_btn_ani.enabled = false
	end
end

function C:StartCD()
	self:StopCD()
	local end_time = Act_SuggestedCollectionManager.GetEndTime()
	local endCall = function ()
		self:MyExit()
	end

	local now_t = os.time()
    end_time = end_time - now_t
	local titStr = GLL.GetTx(80043) .. " "
	local refreshTime = function()
        local str = titStr .. StringHelper.formatTimeDHMS5(end_time)
        self.time_txt.text = str
    end
	self.timerCD = Timer.New(function()
        if IsEquals(self.time_txt) then
            end_time = end_time - 1
                if end_time >= 0 then
                    refreshTime()
                else
                    if endCall then
                        endCall()
                    end
                end
        end
    end,1,-1)

	self.timerCD:Start()
	refreshTime()
end

function C:StopCD()
	if self.timerCD then
		self.timerCD:Stop()
	end
	self.timerCD = nil
end