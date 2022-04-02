local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.NoticeConfig"] = nil
require "Game.game_Login.Lua.NoticeConfig"

package.loaded["Game.game_Login.Lua.LoginNotice"] = nil
require "Game.game_Login.Lua.LoginNotice"

package.loaded["Game.game_Login.Lua.LoginPhonePanel"] = nil
require "Game.game_Login.Lua.LoginPhonePanel"

LoginPanel = basefunc.class()

LoginPanel.name = "LoginPanel"

local instance
function LoginPanel.Create()
	-- do LoginHelper.Login({type="youke"}) return end
	DSM.PushAct({panel = "LoginPanel"})
	instance = LoginPanel.New()
	return instance
end

function LoginPanel.Close()
	if not instance then return end
	instance:MyExit()
	instance = nil
end

function LoginPanel:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(LoginPanel.name,parent)
	parent = nil
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	--version
	local vf = resMgr.DataPath .. "udf.txt"
	if File.Exists(vf) then
		local luaTbl = json2lua(File.ReadAllText(vf))
		if luaTbl then
			self.Version_txt.text = "Ver:" .. luaTbl.version .. " " .. gameMgr:getMarketChannel()
		end
	end
	self.Version_txt.text = self.Version_txt.text .. " baseVer:" .. MainVersion.baseVersion

	self:OnStart()
	self:OnOff()

	GameSceneManager.SetGameBGScale(self.BG)

	HandleLoadChannelLua("LoginPanel", self)

	-- local ss = PlayerPrefs.GetString("WIN_Environment_ARGS", "NULL");
	-- if AppDefine.PlatformPath == "Windows" then
	-- 	local s = StringHelper.Split(ss, "#")
	-- 	if #s >= 2 then
	-- 		HintPanel.Create(1, ss)
	-- 		LoginModel.loginData.youke = nil
	-- 		MainModel.local_DeviceID = s[2]
	-- 		MainModel.LoginInfo.device_id = s[2]
	-- 		MainModel.GetDeviceID = function ()
	-- 			return MainModel.local_DeviceID
	-- 		end
	-- 		MainModel.RefreshDeviceInfo = function ()			
	-- 			MainModel.LoginInfo.device_id = MainModel.local_DeviceID
	-- 		end
	-- 	end
	-- end
end

function LoginPanel:AddListenerGameObject()
	for i = 1, 6, 1 do
		local btn = self["cbtn_" .. i]:GetComponent("Button")
		btn.onClick:AddListener(function ()
			local img = self["cbtn_" .. i]:GetComponent("Image")
			img.color = Color.red

			self:CheatButtonClick(tostring(i))
		end)
	end
	self.cheat_btn.onClick:AddListener(function ()
		self:CheatCtrlButtonClick()
	end)
	self.delete_visitor_btn.onClick:AddListener(function()
		self:OnBtnDeleteVisitorClick()
	end)
	self.login_wx_close_btn.onClick:AddListener(function()
		self:OnLoginWXCloseClick()
	end)
	self.login_phone_close_btn.onClick:AddListener(function()
		self:OnLoginPhoneCloseClick()
	end)
	self.login_btn.onClick:AddListener(function()
		self:OnLoginYKClick()
	end)
	self.login_fb_btn.onClick:AddListener(function()
		self:OnLoginFBClick()
	end)
	self.login_gg_btn.onClick:AddListener(function()
		self:OnLoginGGClick()
	end)
	self.repair_btn.onClick:AddListener(function()
		self:OnRepairClick()
	end)
	self.service_btn.onClick:AddListener(function()
		self:OnServiceClick()
	end)
end

function LoginPanel:RemoveListenerGameObject()
	for i = 1, 6, 1 do
		local btn = self["cbtn_" .. i]:GetComponent("Button")
		btn.onClick:RemoveAllListeners()
	end
	self.cheat_btn.onClick:RemoveAllListeners()
	self.delete_visitor_btn.onClick:RemoveAllListeners()
	self.login_wx_close_btn.onClick:RemoveAllListeners()
	self.login_phone_close_btn.onClick:RemoveAllListeners()
	self.login_btn.onClick:RemoveAllListeners()
	self.login_fb_btn.onClick:RemoveAllListeners()
	self.login_gg_btn.onClick:RemoveAllListeners()
	self.repair_btn.onClick:RemoveAllListeners()
	self.service_btn.onClick:RemoveAllListeners()
end

function LoginPanel:CheatButtonClick(key)
	self.cheatPwd = self.cheatPwd .. key
	if self.cheatPwd == "264153" then
		self.cheatPwd = ""
		LoginLogic.checkServerStatus = false
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()

		self.login_btn.gameObject:SetActive(true)
	end
end

function LoginPanel:CheatCtrlButtonClick()
	local tran = self.transform

	self.cheatCtrlCount = self.cheatCtrlCount + 1
	if self.cheatCtrlCount >= 6 then
		self.cheatCtrlCount = 0

		for i = 1, 6, 1 do
			local btn = self["cbtn_" .. i]
			btn.gameObject:SetActive(true)
		end
	end

	for i = 1, 6, 1 do
		local img = self["cbtn_" .. i]:GetComponent("Image")
		img.color = Color.New(1, 1, 1, 0.5)
	end
	self.cheatPwd = ""
end

function LoginPanel:OnOff()
	-- 测试需求 打开
	if AppDefine.IsEDITOR() and AppDefine.IsForceOpenYK then
		self.login_btn.gameObject:SetActive(true)
	end

	self.delete_visitor_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_wx_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_phone_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
end
function LoginPanel:OnStart()
	self.auto_login = true
	local tran = self.transform

	if gameMgr:HasUpdated() and gameMgr:NeedRestart() then
		NetJH.RemoveAll()
		print("Has Update need restart ....")
		HintPanel.Create(1, GLL.GetTx(10005), function ()
			gameMgr:QuitAll()
		end)
		return
	end

	-- 版本更新状态
	if VersionManager.cur_stage == VersionManager.VStage.Force then
		HintPanel.Create(1, GLL.GetTx(81008), function ()
			Application.OpenURL("https://play.google.com/store/apps/details?id=com.changleyou.domino");		
			gameMgr:QuitAll()
		end)
		return
	elseif VersionManager.cur_stage == VersionManager.VStage.Update then
		local hh = "lsi updatean Versi：\n1.Sudah memperbaiki sebagian Bug\n2.Mengoptimalkan pengalaman bermain game"
		local pre = HintPanel.Create(2, hh, function ()
			Application.OpenURL("https://play.google.com/store/apps/details?id=com.changleyou.domino");		
			gameMgr:QuitAll()
		end)
		pre:SetDescLeft()
		pre:ChangeTitle("Perhatian")
		pre:SetButtonText("Batalkan", "Update")
		self.auto_login = false
	end

	self:MakeLister()
	self:AddMsgListener()
	self:AddListenerGameObject()
	self.privacy = true
	self.service = true
	if self.ClauseHintNode then
		ClauseHintPanel.Create(ClauseHintNode)
	end

	--cheatbtn
	self.cheatPwd = ""
	local cheatNode = self.Cheat
	
	self.cheatCtrlCount = 0
	

	--redir server ip:port
	local ip = LoginLogic.TryGetIP()
	if ip and ip ~= "" then
		AppConst.SocketAddress = ip
		print("[Debug] net redir:" .. ip)
	end
	
	if self.auto_login then
		self:AutoLogin()
	end
end

function LoginPanel:AutoLogin()
	
	if MainModel.GetIsAutoLogin() then
		LoginHelper.AutoLogin()
	end

end

--游客登录
function LoginPanel:OnLoginYKClick(go)
	if AppDefine.IsOffLine then
        MainLogic.GotoScene("game_Hall")
		return
	end

	LoginModel.loginData.cur_channel = "youke"
	DSM.PushAct({button = "yk_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_youke"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login({type="youke"})
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--FB登录
function LoginPanel:OnLoginFBClick(go)
	if AppDefine.IsEDITOR() then
		self:OnLoginYKClick()
		return
	end

	LoginModel.loginData.cur_channel = "facebook"
	Event.Brocast("bsds_send_power",{key = "click_login_facebook"})
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login({type="facebook"})
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--Google登录
function LoginPanel:OnLoginGGClick(go)
	if AppDefine.IsEDITOR() then
		self:OnLoginYKClick()
		return
	end

	LoginModel.loginData.cur_channel = "google"
	Event.Brocast("bsds_send_power",{key = "click_login_google"})
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login({type="google"})
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

function LoginPanel:OnBtnDeleteVisitorClick(go)
	PlayerPrefs.SetInt("game_first_run", 0)
	LoginHelper.clearYoukeData()
end

function LoginPanel:OnLoginWXCloseClick(go)
	PlayerPrefs.SetInt("game_first_run", 0)
end

function LoginPanel:OnLoginPhoneCloseClick(go)
	PlayerPrefs.SetInt("game_first_run", 0)
end

function LoginPanel:OnRepairClick()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	local web_caches = {"_shop_"}
	-- for _, v in pairs(web_caches) do
	-- 	gameWeb:ClearCookies(v)
	-- end
	UniWebViewMgr.CleanCookies()
	UniWebViewMgr.CleanCacheAll()
	HintPanel.Create(1, GLL.GetTx(10008), function ()
		--UnityEngine.Application.Quit()
		gameMgr:QuitAll()
	end)
	Event.Brocast("bsds_send_power",{key = "click_repair"})
end

function LoginPanel:OnServiceClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	--self.service_btn.gameObject:SetActive(false)
	-- Event.Brocast("callup_service_center", "400-8882620")
	Event.Brocast("bsds_send_power",{key = "click_service"})
	MainModel.OpenLoginKFFK()
end

function LoginPanel:MyExit()
	if self.spine then
		self.spine:Stop()
	end
	self.spine = nil

	ClauseHintPanel.Close()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	-- destroy(self.gameObject)
end

function LoginPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function LoginPanel:MakeLister()
	self.lister = {}
	self.lister["upd_privacy_setting"] = basefunc.handler(self, self.upd_privacy_setting)
	self.lister["upd_service_setting"] = basefunc.handler(self, self.upd_service_setting)
	self.lister["model_phone_login_ui"] = basefunc.handler(self, self.on_model_phone_login_ui)
end

function LoginPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function LoginPanel:upd_privacy_setting(value)
	self.privacy = value
end
function LoginPanel:upd_service_setting(value)
	self.service = value
end
function LoginPanel:on_model_phone_login_ui()
	if not GameGlobalOnOff.PhoneLogin then return end
	LoginPhonePanel.Create()
end
