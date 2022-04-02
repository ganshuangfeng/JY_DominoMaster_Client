--ganshuangfeng 手机登录Panel
--2019-12-17

local basefunc = require "Game.Common.basefunc"

LoginPhonePanel = basefunc.class()
local C = LoginPhonePanel
C.name = "LoginPhonePanel"

function C.Create(parent,tips,binding_callback)
    if gameMgr:getMarketPlatform() == "cjj" then return end
    return C.New(parent,tips,binding_callback)
end
function C:MyExit()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    destroy(self.gameObject)

	 
end
function C:ctor(parent,tips,binding_callback)

	ExtPanel.ExtMsg(self)

    self.binding_callback = binding_callback
    parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.tips_txt.text = tips or ""

    self.phone_ipf = self.phone_ipf.transform:GetComponent("InputField")
    self.code_ipf = self.code_ipf.transform:GetComponent("InputField")
   
    self:InitUI()
    self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.phone_ipf.onValueChanged:AddListener(function (val)
    end)
    self.phone_ipf.onEndEdit:AddListener(function (val)
        Event.Brocast("bsds_send_power",{key = "input_phone_num_end"})
    end)
    self.code_ipf.onValueChanged:AddListener(function (val)
    end)
    self.code_ipf.onEndEdit:AddListener(function (val)
        Event.Brocast("bsds_send_power",{key = "input_sms_vcode_end"})
    end)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.get_verification_code_btn.gameObject).onClick = basefunc.handler(self, self.OnClickGetVerificationCode)
    EventTriggerListener.Get(self.sure_binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureBinding)

end

function C:RemoveListenerGameObject()
    self.phone_ipf.onValueChanged:RemoveAllListeners()
    self.phone_ipf.onEndEdit:RemoveAllListeners()
    self.code_ipf.onValueChanged:RemoveAllListeners()
    self.code_ipf.onEndEdit:RemoveAllListeners()
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = nil
    EventTriggerListener.Get(self.get_verification_code_btn.gameObject).onClick = nil
    EventTriggerListener.Get(self.sure_binding_btn.gameObject).onClick = NullMessageListener


    self.back_btn.onClick:RemoveAllListeners()
	
	for i=1,5 do
		self["tgeItem"..i.. "_tge"].onValueChanged:RemoveAllListeners()
	end
end

function C:InitUI()
    self.tips_txt.text = ""--"微信登录游戏并绑定手机后才可以使用手机登录"
    self:SetWaitTime()
end
function C:Update()
    if self.wait_time then
        self.wait_time = self.wait_time - 1
        if self.wait_time <= 0 then
            self.wait_time = nil
        end
        self:SetDJS()
    end
end
function C:SetWaitTime()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    if self.wait_time and self.wait_time > 0 then
        self.updateTimer = Timer.New(basefunc.handler(self,self.Update), 1, -1, true)
        self.updateTimer:Start()
        self.wait_verification.gameObject:SetActive(true)
        self:SetDJS()
    else
        if IsEquals(self.wait_verification) then
            self.wait_verification.gameObject:SetActive(false)
        end
    end
end
function C:SetDJS()
    if self.wait_time then
        self.ImgGetCode_txt.text = self.wait_time .. "s"
    else
        self:SetWaitTime()
    end
end

--[[退出玩家中心，返回到大厅 ]]
function C:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    Event.Brocast("bsds_send_power",{key = "click_close_login_panel"})
    self:CallCloseClick()
end
function C:CallCloseClick()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    self.wait_time = nil
    self.binding_callback = nil
    GameObject.Destroy(self.gameObject)
end

--[[获取验证码]]
function C:OnClickGetVerificationCode(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local phong_number = self.phone_ipf.text
    if not phong_number or phong_number == "" then
        HintPanel.Create(1, "手机号码不能为空")
        return
    end
    local cnt = string.utf8len(phong_number)
    print("<color=red>cnt == " .. cnt .. "</color>")
    if cnt ~= 11 then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end
    Network.SendRequest("send_sms_vcode", {phone_number=phong_number, platform=gameMgr:getMarketPlatform()}, "获取验证码" , function (data)
        dump(data,"<color=white>验证码</color>")
        if data.result == 0 then
            self.new_user = data.new_user or 1
            self.wait_time = 60
            self:SetWaitTime()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
    Event.Brocast("bsds_send_power",{key = "send_sms_vcode"})
end

--[[确认绑定]]
function C:OnClickSureBinding(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local phong_number = self.phone_ipf.text
    if not phong_number or phong_number == "" then
        HintPanel.Create(1, "手机号码不能为空")
        return
    end
    local cnt = string.utf8len(phong_number)
    print("<color=red>cnt == " .. cnt .. "</color>")
    if cnt ~= 11 then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end

    if not self.code_ipf.text or self.code_ipf.text == "" or not tonumber(self.code_ipf.text) then
        HintPanel.Create(1, "输入的验证码格式错误")
        return
    end
    if string.len(self.code_ipf.text) ~= 4 then
        HintPanel.Create(1, "输入的验证码长度不对")
        return
    end

    local call_login = function ()
        Event.Brocast("bsds_send_power",{key = "click_phone_sure_login"})
        LoginHelper.Login("phone_vcode",phong_number, self.code_ipf.text)
        self:MyExit()
    end

    local yk = LoginModel.loginData.youke or ""
    if self.new_user == 1 then
        if yk ~= "" then
            HintPanel.Create(2, "账号将与游客账号信息绑定，是否确认登录", function ()
                call_login()
            end, function ()
                self:MyExit()
            end)
        else
            call_login()
        end
    else
        if yk ~= "" then
            HintPanel.Create(2, "使用账号登录将覆盖游客数据，是否确认登陆", function ()
                call_login()
            end, function ()
                self:MyExit()
            end)
        else
            call_login()
        end
    end
end

