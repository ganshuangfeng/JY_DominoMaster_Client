-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"

EmailCellPrefab = basefunc.class()

EmailCellPrefab.name = "EmailCellPrefab"

local colorXZ = "<color=#854033>"
local colorZC = "<color=#854033>"
local colorTimeXZ = "<color=#9C6E5B>"
local colorTimeZC = "<color=#9C6E5B>"
local colorEnd = "</color>"
function EmailCellPrefab.Create(parent_transform, emailId, call, panelSelf)
	return EmailCellPrefab.New(parent_transform, emailId, call, panelSelf)
end

function EmailCellPrefab:ctor(parent_transform, emailId, call, panelSelf)
	self.emailId = emailId
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject("EmailCellPrefab", parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	

	self.AwardHintImage = self.AwardHintImage.gameObject
	self.AwardHintImage:SetActive(false)


	self.fj_txt.text = GLL.GetTx(20010)
	self:UpdateEmailState()

	local loseTime = EmailModel.GetLoseTime(self.emailId)
	if loseTime > 0 then
		self.timerUpdate = Timer.New(function ()
			self:UpdateEmailState()
		end, loseTime, 1, false)
    	self.timerUpdate:Start()
	end

	self:AddListenerGameObject()
end

function EmailCellPrefab:AddListenerGameObject()
	self.open_btn.onClick:AddListener(function ()
		self:OnOpenEmail()
	end)
end

function EmailCellPrefab:RemoveListenerGameObject()
	self.open_btn.onClick:RemoveAllListeners()
end

-- 设置选中
function EmailCellPrefab:SetSelectEmail(b)
	self.SelectEmail.gameObject:SetActive(b)
	local data = EmailModel.Emails[self.emailId]
	local desc,title = EmailModel.GetEmailDesc(data)
	if b or EmailModel.IsReadState(self.emailId) then
		self.title_txt.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.title_txt.text= "<size=28>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.time_txt.text = colorTimeXZ .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	else
		self.title_txt.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.title_txt.text= "<size=28>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.time_txt.text = colorTimeZC .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	end
	self.open_btn.gameObject:SetActive(not b)
end
function EmailCellPrefab:UpdateEmailState()
	self.EmailState,self.EmailStateName = EmailModel.GetState(self.emailId)
	local data = EmailModel.Emails[self.emailId]
	local desc,title = EmailModel.GetEmailDesc(data)

	if EmailModel.IsReadState(self.emailId) then
		self.AwardHintImage:SetActive(false)
		self.read.gameObject:SetActive(true)
		self.noread.gameObject:SetActive(false)
		self.title_txt.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.title_txt.text= "<size=28>"..colorXZ .. title .. colorEnd.."</size>"
		end
	else
		local ise = EmailModel.IsExistAward(self.emailId)
		self.AwardHintImage:SetActive(ise)
		self.read.gameObject:SetActive(false)
		self.noread.gameObject:SetActive(true)
		self.title_txt.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.title_txt.text= "<size=28>"..colorXZ .. title .. colorEnd.."</size>"
		end
	end
end
function EmailCellPrefab:OnOpenEmail()
	self.call(self.panelSelf, self.emailId)
end
function EmailCellPrefab:OnDestroy()
	if self.timerUpdate then
		self.timerUpdate:Stop()
	end
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

