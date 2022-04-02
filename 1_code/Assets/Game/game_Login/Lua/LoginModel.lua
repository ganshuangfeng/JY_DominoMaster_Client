
LoginModel={}

local this

--[[
    youke
    wechat
    device_id
    device_os
]]
local loginData
local lastLoginChannel

local tokenKey = "refresh_token"
local lastLoginChannelKey = "last_login_channel"
local appidKey = "appid"

local function SaveLocalLoginData(channel,_id,_token)
    if not channel then
        return
    end
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    File.WriteAllText(path .. "/" .. channel .. ".txt", _id)
    File.WriteAllText(path .. "/" .. tokenKey .. ".txt", _token)
    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", channel)
end
local function CloseLastLoginData()
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", "")
end
local function GetLocalLoginData(name)
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath .. "/" .. name .. ".txt"
    else
        path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
    end
    if File.Exists(path) then
        return File.ReadAllText(path)
    else
        return ""
    end
end

local function SetChannelData(channel, _id, _token)
    SaveLocalLoginData(channel, _id, _token)
end

--初始化登录数据
local function InitLoginData( )
    -- 游客 微信 手机号
    local appid = GetLocalLoginData(appidKey)
    if appid and appid ~= "" then
        UnityEngine.PlayerPrefs.SetString("_APPID_", appid)
    end
    local login_qd = {"youke", "wechat", "phone"}
    this.loginData={
        refresh_token=GetLocalLoginData(tokenKey),
        lastLoginChannel=GetLocalLoginData(lastLoginChannelKey),
    }
    for k,v in pairs(login_qd) do
        this.loginData[v] = GetLocalLoginData(v)
        if this.loginData[v] and this.loginData[v] == "" then
            this.loginData[v] = nil
        end
    end

    if this.loginData.lastLoginChannel == "" then
        this.loginData.lastLoginChannel = nil
    end

    this.loginData.device_id = MainModel.LoginInfo.device_id
    this.loginData.device_os = MainModel.LoginInfo.device_os

    dump(this.loginData, "<color=white>loginData</color>")
end

local lister
local function AddLister()
    lister={}
    lister["OnLoginResponse"] = this.OnLoginResult
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function LoginModel.Init()
    this = LoginModel
    AddLister()
    InitLoginData()
    return this
end

function LoginModel.OnLoginResult(result)
    if result == 0 then
        dump(MainModel.LoginInfo, "<color=red>|||||||||||| save login data </color>")
        local channel = MainModel.LoginInfo.channel_type
        local loginId = MainModel.LoginInfo.login_id
        local token = MainModel.LoginInfo.refresh_token
        SetChannelData(channel, loginId, token)
    end
end

function LoginModel.GetChannelLuaTable(channel)
	return nil
end

function LoginModel.ClearChannelData(channel)
    if not channel then
        print(debug.traceback())
        dump(this)
        return
    end
    SaveLocalLoginData(channel, "", "")
    if this and this.loginData then
        this.loginData[channel] = nil
        this.loginData.channel = nil
    end
end


function LoginModel.ClearLastLoginData()
    CloseLastLoginData()
    if this then
        this.loginData.lastLoginChannel=nil
    end
end

function LoginModel.Exit()
    if this then
        RemoveLister()
    	this.loginData = {}
        this.loginData.device_id = MainModel.LoginInfo.device_id
        this.loginData.device_os = MainModel.LoginInfo.device_os
        this = nil
    end
end

-- 修改登录方式和数据
function LoginModel.SetLoginData(parm)
    SetChannelData(parm.channel, parm.id, parm.token)
end

-- 获取最近的登陆方式
function LoginModel.GetLastLoginWay()
    if this and this.loginData then 
        return this.loginData.lastLoginChannel
    end
end

-- 各种情况的清除登陆数据
-- dh顶号 dc登出 dlbc登录报错
function LoginModel.ClearLoginData(reason, channel)
    local ct = channel or LoginModel.GetLastLoginWay()
    if not ct then
        ct = GetLocalLoginData(lastLoginChannelKey)
    end
    if reason == "dlbc" then
        LoginModel.ClearChannelData(ct)
        LoginModel.ClearLastLoginData()
    end
    if reason == "dc" then
        if ct ~= "youke" then
            LoginModel.ClearChannelData(ct)
        end
        LoginModel.ClearLastLoginData()
    end
    if reason == "dh" then
        -- local ct = MainModel.LoginInfo.channel_type
        -- LoginModel.ClearChannelData(ct)
        -- LoginModel.ClearLastLoginData()
    end
end