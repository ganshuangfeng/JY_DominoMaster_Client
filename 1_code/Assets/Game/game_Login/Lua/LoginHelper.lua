--Author:fk 

local basefunc = require "Game.Common.basefunc"
LoginHelper = {}
local M = LoginHelper

--登录渠道类型
M.ChannelType = {
    youke = "youke",
    wechat = "wechat",
    phone = "phone",
    robot = "robot",
    phone_vcode = "phone_vcode",

}

--登录渠道sdk
M.ChannelSdk = {
    -- youke = LoginYoukeSDK,
    -- wechat = LoginWechatSDK,
}


--登录相关>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local this 
local lister
local connectTimer
local status = 0 -- 0可以登录 1连接tcp 2登录中 3登录完成
local curChannel 

local connectTimeDelay = 3 --每次发起重连的时间间隔
local connectMaxTime = 3 --发起连接的最大次数
local connectCurTime = 0 --当前发起次数
--[[登录菊花的超时
    如果发起了登录请求，很久都没有回应，则应该进行清理操作
]]
local sendLoginRequestOverTime = 8
local sendLoginRequestOverTimer
local setSendLoginOverTimeCBK

local AddLister = function()
    lister = {}
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResult
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local RemoveLister = function()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

function M.Init()
    M.Exit()
    this = M
    AddLister()
    return this
end

function M.Exit()
    if this then
        status = 0
        curChannel = nil
        LoginLogic.SetGoodIP("")
        RemoveLister()
        this = nil
    end
end

-- 登录完成，逻辑处理
function M.OnLoginResult(result)
    status = 3
    if result == 0 then
        Event.Brocast("bsds_send_power",{key = "login_ok", param={param1=MainModel.UserInfo.login_id, param2=MainModel.UserInfo.user_id}})
        status = 0
        --go to hall
        NetJH.RemoveAll()
        -- LoginLogic.Exit()
        MainLogic.GotoScene(GameSceneManager.EnterFirstScene)
        Event.Brocast("bsds_send_power",{key = "login_succes", param={param1=MainModel.UserInfo.login_id}})
    elseif result == 190 then
        sdkMgr:FBLogOut("force", function ()
            HintPanel.Create(1, GLL.GetTx(10009), function ()
                M.ConnectServer(this.cur_login_data)
            end)
        end)
    else
        print("login error : ", result)
        HintPanel.ErrorMsg(result)
        if curChannel == "google" and (result == 2160 or result == 2161) then
            sdkMgr:OnGGSignOut("", function (data)
                dump(data, "Google OnGGSignOut")
            end)
        end
    end

    -- 手机登录失败后清除数据
    if result ~= 0 then
        LoginModel.ClearLoginData("dlbc", LoginModel.loginData.cur_channel)
        this.CancelLogin(result)
    end
end

function M.BeginLogin(data)
    -- 更新设备信息
    MainModel.RefreshDeviceInfo()
    LoginModel.loginData.device_id = MainModel.LoginInfo.device_id
    LoginModel.loginData.device_os = MainModel.LoginInfo.device_os

    -- Ios14以及以上引导设置
    local os = string.gsub(MainModel.LoginInfo.device_os, "%s+", "")
    os = string.lower(os)
    if not MainModel.is_off_guide_set and gameRuntimePlatform == "Ios" 
        and (not MainModel.LoginInfo.device_id or MainModel.LoginInfo.device_id == "")
        and (MainModel.LoginInfo.device_os and string.find(os, "ios14")) then
            MainModel.is_off_guide_set = true
            HintPanel.Create(1, "请在设置-隐私-Tracking中允许App请求跟踪", function ()
                sdkMgr:GotoSetScene("set_device_id")
            end)
            this.CancelLogin(-2000)
            return
    end
    NetJH.RemoveAll()
    PROTO_TOKEN = nil
    ---通过传递的参数 进行选择方法
    if data.type and M[data.type] then
        status = 2
        M[data.type](data)
    else
        dump(data, "<color=red>[Debug] login type 不存在</color>")
        this.CancelLogin(-3000)
    end
end

function M.SendLogin(data)
    setSendLoginOverTimeCBK()
    Network.SendRequest("login", data, GLL.GetTx(10018))
end

function M.youke(data)
    local loginData = {
        channel_type = "youke",
        login_id = data.loginId,
        device_id = LoginModel.loginData.device_id,
        device_os = LoginModel.loginData.device_os,
        market_channel = gameMgr:getMarketChannel(),
        platform = gameMgr:getMarketPlatform(),
        channel_args = '{"test_code":"' .. UnityEngine.PlayerPrefs.GetString("_Test_Code_", "") .. '"}',
    }
    -- 创建账号用设备ID，如果本地存有ID就用本地的
    if not loginData.login_id or loginData.login_id == "" then
        loginData.login_id = MainModel.GetDeviceID()
    end
    dump(LoginModel.loginData, "LoginModel.loginData")
    dump(MainModel.LoginInfo, "MainModel.LoginInfo")
    M.SendLogin(loginData)
    Event.Brocast("bsds_send_power",{key = "login_youke", param={param1=loginData.login_id}})
end

function M.facebookTokenToLogin()
    local function callback(json_data)
        dump(json_data, "[LOGIN] facebookTokenToLogin json_data")
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] facebookTokenToLogin exception: json_data invalid")
            HintPanel.Create(1, "data invalid")
            this.CancelLogin(-100)
            return
        end

        lua_tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        dump(lua_tbl, "[LOGIN] facebookTokenToLogin")

        if lua_tbl.result == 0 then

            local loginData = {
                channel_type = "facebook",
                channel_args = lua2json(lua_tbl),
                device_id = LoginModel.loginData.device_id,
                device_os = LoginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            Event.Brocast("bsds_send_power",{key = "login_facebook", param={param1=lua_tbl.fb_id}})

            M.SendLogin(loginData)
        else
            NetJH.RemoveAll()
            if lua_tbl.result == 1 then
                HintPanel.Create(1, GLL.GetTx(20011).."(" .. lua_tbl.err .. ")")
            else
                HintPanel.Create(1, GLL.GetTx(20012))
            end

            this.CancelLogin(-100+lua_tbl.result)
        end
    end

    print("<color=white>sdkMgr login</color>")
    sdkMgr:FBLogin("", callback)
end
function M.facebook(data)
   local fb_id = UnityEngine.PlayerPrefs.GetString("_FBID_", "")
    dump({loginId = data.loginId,refresh_token = data.refresh_token},"<color=white>======= facebook 请求登录</color>")
    if false and data.loginId and fb_id ~= "" and data.refresh_token and data.refresh_token ~= "" then
        local tbl = {}
        tbl.fb_id = fb_id
        tbl.token = data.refresh_token
        tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        local loginData = {
            channel_type = "facebook",
            login_id = data.loginId,
            channel_args = lua2json(tbl),
            device_id = LoginModel.loginData.device_id,
            device_os = LoginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform()
        }

        dump(loginData, "[Debug] loginData")
        M.SendLogin(loginData)
        Event.Brocast("bsds_send_power",{key = "login_facebook", param={param1=tbl.fb_id}})
    else
        this.facebookTokenToLogin()
    end
end


function M.googleTokenToLogin()
    local function callback(json_data)
        dump(json_data, "[LOGIN] googleTokenToLogin json_data")
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] googleTokenToLogin exception: json_data invalid")
            HintPanel.Create(1, "data invalid")
            this.CancelLogin(-200)
            return
        end

        lua_tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        dump(lua_tbl, "[LOGIN] googleTokenToLogin")

        if lua_tbl.result == 0 then

            local loginData = {
                channel_type = "google",
                channel_args = lua2json(lua_tbl),
                device_id = LoginModel.loginData.device_id,
                device_os = LoginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            Event.Brocast("bsds_send_power",{key = "login_google", param={param1=lua_tbl.fb_id}})

            M.SendLogin(loginData)
        else
            NetJH.RemoveAll()
            if lua_tbl.result == 1 then
                HintPanel.Create(1, GLL.GetTx(81060).."(" .. lua_tbl.err .. ")")
            else
                HintPanel.Create(1, GLL.GetTx(20012))
            end

            this.CancelLogin(-200+lua_tbl.result)
        end
    end

    print("<color=white>sdkMgr login</color>")
    sdkMgr:OnGGSignIn("", callback)
end
function M.google(data)
   local fb_id = UnityEngine.PlayerPrefs.GetString("_FBID_", "")
    dump({loginId = data.loginId,refresh_token = data.refresh_token},"<color=white>======= google 请求登录</color>")
    if false and data.loginId and fb_id ~= "" and data.refresh_token and data.refresh_token ~= "" then
        local tbl = {}
        tbl.fb_id = fb_id
        tbl.token = data.refresh_token
        tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        local loginData = {
            channel_type = "google",
            login_id = data.loginId,
            channel_args = lua2json(tbl),
            device_id = LoginModel.loginData.device_id,
            device_os = LoginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform()
        }

        dump(loginData, "[Debug] loginData")
        M.SendLogin(loginData)
        Event.Brocast("bsds_send_power",{key = "login_facebook", param={param1=tbl.fb_id}})
    else
        this.googleTokenToLogin()
    end
end

-- 登陆方式
local login_type_map = {
    youke=1,
    facebook=1,
    google=1,
}
function M.AutoLogin() 
    local last_type = LoginModel.loginData.lastLoginChannel
    if last_type and login_type_map[last_type] then
        this.Login({type=last_type})
    else
        dump(LoginModel.loginData, "<color=red>LoginModel.loginData</color>")
    end 
end

function M.OnConnecteServerSucceed()
    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    this.Login(this.cur_login_data)
end

function M.CancelLogin(result)
    local old_curChannel = curChannel
    print("<color=red>AAAAAAAAAAAAAAAA 555</color>")
    print(debug.traceback())
    status = 0
    curChannel = nil
    LoginLogic.SetGoodIP("")

    connectCurTime = 0
    wechatErrorStatus = 0

    NetJH.RemoveAll()

    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    if sendLoginRequestOverTimer then
        sendLoginRequestOverTimer:Stop()
        sendLoginRequestOverTimer = nil
    end

    Network.DestroyConnect()
    print("<color=red> login is cancel or error </color>")

    Event.Brocast("bsds_send_power",{key = "login_fail", param={param1=result}})
end
setSendLoginOverTimeCBK = function ()
    if sendLoginRequestOverTimer then
        sendLoginRequestOverTimer:Stop()
        sendLoginRequestOverTimer = nil
    end

    local function cbk()
        dump({status=status,}, "AAAAAAAAAAAAAA 1111")
        if MainModel.myLocation ~= "game_Login" then
            return
        end
        if status == 2 then

            Event.Brocast("cancel_login", {"timeout"})
            this.CancelLogin(-600)

            HintPanel.Create(1, GLL.GetTx(10010))
        end
    end
    sendLoginRequestOverTimer = Timer.New(cbk, sendLoginRequestOverTime, 1, nil, true)
    sendLoginRequestOverTimer:Start()
end

function M.ConnectServer(data)
    if MainModel.IsConnectedServer then
        this.BeginLogin(data)
    else
        status = 1
        NetJH.Create("--", 1)
        --断网情况下，每3秒尝试一次重新连接
        local sendConnect = function()
            if not MainModel.IsConnectedServer then
                print("<color=red>SendConnect</color> use ip: " .. AppConst.SocketAddress)
                -- networkMgr:DestroyConnect()
                networkMgr:SendConnect()
            end
            connectCurTime = connectCurTime + 1
            if connectCurTime >= connectMaxTime then
                local ip = LoginLogic.TryGetIP()
                if ip and ip ~= "" then
                    AppConst.SocketAddress = ip
                    connectCurTime = 0
                    print("reconnect server use ip: " .. ip)
                else
                    Event.Brocast("cancel_login", {"connectout"})
                    this.CancelLogin(-800)
                    HintPanel.Create(1, GLL.GetTx(10011))
                end
            end
        end

        connectTimer = Timer.New(sendConnect, connectTimeDelay, -1, nil, true)
        connectTimer:Start()
        sendConnect()
    end
end
function M.Login(data)
    if not this then
        return
    end

    if status == 2 then
        print("<color=red>AAAAA Login ing </color>")
        print(debug.traceback())
        return
    end
    data.loginId = LoginModel.loginData[data.type]
    this.cur_login_data = data

    dump(data, "<color=red>====== Login Data </color>")

    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    --登录
    this.ConnectServer(data)
end

--清除游客数据
function M.clearYoukeData()
    LoginModel.ClearChannelData("youke")
    PlayerPrefs.DeleteKey("SGE_SALE_DAY_3")
    PlayerPrefs.DeleteKey("SGE_SALE_DAY_4")
    PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")
end

