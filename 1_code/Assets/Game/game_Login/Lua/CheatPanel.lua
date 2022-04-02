local basefunc = require "Game.Common.basefunc"

CheatPanel = basefunc.class()
CheatPanel.name = "CheatPanel"

local instance

function CheatPanel.Create()
	instance = CheatPanel.New()
	return instance
end

function CheatPanel.Close()
	if instance then
		instance:ClearServerList()
		instance:RemoveListenerGameObject()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function CheatPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(CheatPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitRect()
	--DOTweenManager.OpenPopupUIAnim(self.transform)
	self:AddListenerGameObject()
end

function CheatPanel:AddListenerGameObject()
    
end

function CheatPanel:RemoveListenerGameObject()
    self.ok_btn.onClick:RemoveAllListeners()
	self.clear_localconfig_btn.onClick:RemoveAllListeners()
	self.account_btn.onClick:RemoveAllListeners()
	self.inputIPField.onValueChanged:RemoveAllListeners()
	self.inputPortField.onValueChanged:RemoveAllListeners()
	self.inputAccountField.onValueChanged:RemoveAllListeners()
	
	for k, v in pairs(self.serverList or {}) do
		local obj_t = {}
		LuaHelper.GeneratingVar(v.transform, obj_t)
		obj_t.ip_btn.onClick:RemoveAllListeners()
	end
end

function CheatPanel:InitRect()
	local transform = self.transform

	self.ok_btn.onClick:AddListener(function()
		local ip_port = self.setting_txt.text
		dump(ip_port, "<color=red>AAAAAAAA ip_port</color>")
		AppConst.SocketAddress = ip_port

		local version = self.inputVersionField.text
		if version ~= "输入版本号" then
			gameMgr:SetForceVersion(version)
		else
			gameMgr:SetForceVersion("")
		end

		local remoteConfigDir = self.inputRemoteConfigDirField.text
		gameMgr:SetForceConfig(remoteConfigDir)

		local code = self.inputCodeField.text
		PlayerPrefs.SetString("_Test_Code_", code)

		CheatPanel.Close()
	end)

	self.clear_localconfig_btn.onClick:AddListener(function()
		local local_cfgs = {"localconfig"}
		for _, v in pairs(local_cfgs) do
			local dir = gameMgr:getLocalPath(v)
			if Directory.Exists(dir) then
				Directory.Delete(dir, true)
			end
		end
		PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")

		--local web_caches = {"_shop_"}
		-- for _, v in pairs(web_caches) do
		-- 	gameWeb:ClearCookies(v)
		-- end
		if Directory.Exists(AppDefine.LOCAL_DATA_PATH) then
			Directory.Delete(AppDefine.LOCAL_DATA_PATH, true)
		end
		PlayerPrefs.DeleteAll()

		self.inputVersionField.text = ""
		self.inputRemoteConfigDirField.text = ""
		self.inputCodeField.text = ""
	end)

	self.inputIPField = transform:Find("option/InputIPField"):GetComponent("InputField")
	self.inputIPField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = val
	end)

	self.inputPortField = transform:Find("option/InputPortField"):GetComponent("InputField")
	self.inputPortField.gameObject:SetActive(false)
	self.inputPortField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = self.inputIPField.text .. ":" .. val
	end)

	self.inputVersionField = transform:Find("version/InputVersionField"):GetComponent("InputField")
	local version_txt = transform:Find("version/InputVersionField/Placeholder"):GetComponent("Text")
	version_txt.text = PlayerPrefs.GetString("_Cheat_Force_Version_", "输入版本号")
	self.inputVersionField.text = version_txt.text

	self.inputRemoteConfigDirField = transform:Find("version/InputRemoteConfigDirField"):GetComponent("InputField")
	self.inputRemoteConfigDirField.text = PlayerPrefs.GetString("_Cheat_Force_Config_", "")

	self.inputCodeField = transform:Find("option/InputCodeField"):GetComponent("InputField")
	self.inputCodeField.text = PlayerPrefs.GetString("_Test_Code_", "")

	self.accountPwd = 0
	self.inputAccountField = transform:Find("user/InputAccountField"):GetComponent("InputField")
	self.inputAccountField.onValueChanged:AddListener(function (val)
		if LoginModel.loginData then
			LoginModel.loginData.youke = val
		end
	end)

	self.inputAccountField.gameObject:SetActive(false)
	self.account_btn.onClick:AddListener(function()
		self.accountPwd = self.accountPwd + 1
		if self.accountPwd >= 6 then
			self.accountPwd = 0
			self.inputAccountField.gameObject:SetActive(true)
		end
	end)

	local versionNode = transform:Find("version")
	versionNode.gameObject:SetActive(true)
	--[[if MainModel.IsLoged then
		local UserInfo = MainModel.UserInfo or {}
		local player_level = UserInfo.player_level or 0
		if player_level > 0 then
			versionNode.gameObject:SetActive(true)
		end
	else
		versionNode.gameObject:SetActive(false)
	end]]--

	self.serverList = {}

	self:Refresh()
end

function CheatPanel:Refresh()
	local IPTable = {
		"haiwai.domino00.com:5001",
		"server.domino00.com:5001",
		"xiuxian-pre.domino00.com:5001",
		"152.32.155.202:5001",
		"192.168.10.9:5601",
		"192.168.10.12:5005",
		"192.168.10.32:5008",
	}

	self.current_txt.text = AppConst.SocketAddress
	self.version_txt.text = gameMgr:GetVersionNumber() .. " : " .. gameMgr:getConfigVersion()
	self.url_txt.text = gameMgr:GetRootURL()

	self:ClearServerList()
	for k, v in pairs(IPTable) do
		self.serverList[#self.serverList + 1] = self:CreateItem(v)
	end

	local loginData = LoginModel.loginData or {}
	self.inputAccountField.text = loginData.wechat or ""	--(loginData.youke or "") .. "+#+" .. (loginData.wechat or "")
end

function CheatPanel:ClearServerList()
	for i,v in pairs(self.serverList) do
		GameObject.Destroy(v.gameObject)
	end
	self.serverList = {}
end

function CheatPanel:CreateItem(item)
	local obj = GameObject.Instantiate(self.server_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one

	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform, obj_t)
	obj_t.ip_btn.onClick:AddListener(function()
		self.setting_txt.text = item
		self.inputIPField.text = ""
		self.inputPortField.text = ""
	end)
	obj_t.ip_txt.text = item

	obj.gameObject:SetActive(true)

	return obj
end

--Æô¶¯ÊÂ¼þ--
function CheatPanel:Awake()
end

function CheatPanel:Start()	
end

function CheatPanel:OnDestroy()
end
