-- 2020年1月5号捕鱼大版本分支
local basefunc = require "Game.Common.basefunc"

MainModel = {}

-- 时间函数重写
local _client_server_time_diff = 0
local _time_zone_diff = 946656000-os.time({year=2000,month=1,day=1,hour=0,min=0,sec=0})

if not os.old_time then

    os.old_time = os.time
    os.old_date = os.date

    function os.time(_t)
        if _t then
            return os.old_time(_t) + _time_zone_diff
        else
            return os.old_time(_t) + _client_server_time_diff
        end
    end

    function os.date(_fmt,_time)
        _time = _time or os.time()
        return os.old_date(_fmt,_time - _time_zone_diff)
    end
end

local this

--当前位置 nil代表无位置 - 服务器标记所在的位置
local Location

--我所在的位置-客户端所在的位置
local myLocation

--我正在游戏中的位置
local GamingLocation

--在某个游戏大厅
local gameHallLocation

--是否开启公益位置
local isPublicWelfareLocation

--是否登录了
local IsLoged

local RoomCardInfo

--网络延迟
local ping

--[[自动登录状态
    第一次到登录页面
    0-ok 要自动登录
    1-other 不要自动登录
]]
local AutoLoginState

--[[个人数据

    UserInfo = {
        name,           --玩家名字，在登录时随user_id一起接收
        user_id,        --玩家唯一标识符，服务器逻辑产生
        login_id,       --登录ID，玩家输入的帐号信息
        head_image,     --玩家头像链接，用于获取玩家微信头像

        diamond $ : integer  		#-- 钻石
        shop_ticket $ : integer 	#-- 抵用券
        cash $ : integer  			#-- 现金
        vip $ : integer  			#-- vip
        million_fuhuo_ticket $ : integer  #--复活卡
        match_ticket $ : integer 	#-- 比赛券
        hammer $ : integer  		#-- 锤子
        bomb $ : integer  			#-- 炸弹
        kiss $ : integer  			#-- 亲吻
        egg $ : integer  			#-- 鸡蛋
        brick $ : integer  			#-- 砖头
        praise $ : integer  		#-- 赞
        
        channel_type,   --渠道

    }

]]
local UserInfo


--[[登陆信息
    login_id
    channel_type
    device_id
    device_os
]]
local LoginInfo

--GPS
local CityName --城市
local Latitude --纬度
local Longitude--经度

---------------------------------------------------私有数据----------------------------------------------------------

--update handle
local UpdateTimer
local UPDATE_INTERVAL = 0.5

-- key: 服务器标记 value:客户端场景
local serverSceneNameMap=
{
    ["freestyle_game_nor_dmn_nor"] = "game_DominoJL",
    ["freestyle_game_nor_fxq_er"] = "game_Ludo",
    ["freestyle_game_nor_fxq_si"] = "game_Ludo",
    ["fast_game_nor_qiuqiu_nor"] = "game_QiuQiu",
    ["slot_jymt_game"] = "game_Slots",
    ["slot_wushi_game"] = "game_SlotsLion",

    --消消乐
    ["xiaoxiaole_game"] = "game_Eliminate",
    --水浒消消乐
    ["xiaoxiaole_shuihu_game"]="game_EliminateSH",
    --财神消消乐
    ["xiaoxiaole_caishen_game"]="game_EliminateCS",
    --西游消消乐
    ["xiaoxiaole_xiyou_game"]="game_EliminateXY",
    --超级消消乐
    ["lianxianxiaoxiaole_game"]="game_EliminateCJ",
    --三国消消乐
    ["xiaoxiaole_sanguo_game"]="game_EliminateSG",
    --宝石迷阵
    ["xiaoxiaole_baoshi"] = "game_EliminateBS",
    --福星高照
    ["xiaoxiaole_fuxing"] = "game_EliminateFX",
}

-- key: 服务器标记 value:客户端场景
-- 服务器上的游戏标记
MainModel.ServerToClientScene = 
{
    ["nor_dmn_nor"] = "game_DominoJL",
    ["nor_fxq_nor"] = "game_Luduo",
    -- ["nor_fxq_nor"] = "game_Luduo",
    ["slot_jymt_game"] = "game_Slots",
    ["slot_wushi_game"] = "game_SlotsLion",

    --消消乐
    ["xiaoxiaole_game"] = "game_Eliminate",
    ["xiaoxiaole_shuihu_game"]="game_EliminateSH",
    ["xiaoxiaole_caishen_game"]="game_EliminateCS",
    ["xiaoxiaole_xiyou_game"]="game_EliminateXY",
    ["lianxianxiaoxiaole_game"]="game_EliminateCJ",
    ["xiaoxiaole_sanguo_game"]="game_EliminateSG",
    ["xiaoxiaole_baoshi"]="game_EliminateBS",
    ["xiaoxiaole_fuxing"]="game_EliminateFX",
}

-- key: 客户端场景 value:服务器标记
-- 客户端上的游戏标记
MainModel.ClientToServerScene = 
{
    ["game_Luduo"] = "nor_fxq_nor",
    ["game_Slots"] = "slot_jymt_game",
    ["game_SlotsLion"] = "slot_wushi_game",

    --消消乐
    ["game_Eliminate"] = "xiaoxiaole_game",
    ["game_EliminateSH"]="xiaoxiaole_shuihu_game",
    ["game_EliminateCS"]="xiaoxiaole_caishen_game",
    ["game_EliminateXY"]="xiaoxiaole_xiyou_game",    
    ["game_EliminateCJ"]="lianxianxiaoxiaole_game",
    ["game_EliminateSG"]="xiaoxiaole_sanguo_game",
    ["game_EliminateBS"]="xiaoxiaole_baoshi",
}
-- 服务器的位置，有可能需要调整，比如天府斗地主
local function getServerLocation(location, gameid)
    return location
end

function MainModel.GetServerToClientScene(parm)
    dump(parm, "<color=red>GetServerToClientScene</color>")
    if type(parm) == "table" then
        local gt
        if MainModel.ClientToServerScene[parm.game_type] then
            gt = parm.game_type
        else
            gt = MainModel.ServerToClientScene[parm.game_type]
        end
        return gt
    else
        return MainModel.ServerToClientScene[parm]
    end
end
---------------------------------------------------私有数据----------------------------------------------------------

function MainModel.getServerToClient(location)
    
    if location then
        return serverSceneNameMap[location]
    end

end


local lister
local function AddLister()
    lister={}
    lister["login_response"] = this.OnLogin
    lister["query_asset_response"] = this.on_query_asset
    lister["query_all_gift_bag_status_response"] = this.on_query_all_gift_bag_status
    lister["query_system_variant_data_response"] = this.query_system_variant_data
    -- lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status

    lister["will_kick_reason"] = this.will_kick_reason
    lister["notify_asset_change_msg"] = this.OnNotifyAssetChangeMsg
    lister["notify_pay_order_msg"] = this.OnNotifyPayOrderMsg
    lister["ping"] = this.OnPing
	lister["callup_service_center"] = this.OnCallupServiceCenter
    --百万大奖赛奖杯
    lister["notify_million_cup_msg"] = this.notify_million_cup_msg
    lister["confirm_million_cup_response"] = this.on_confirm_million_cup_response

    -- 礼包商品
    -- lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    -- lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg
    -- lister["query_gift_bag_status_by_ids_response"] = this.on_query_gift_bag_status_by_ids_response

    --vip下载ip列表
    lister["OnLoginResponse"] = this.on_LoginResponse
    lister["ExitScene"] = this.OnExitScene

    -- 强制客户端热更新
    lister["server_change_notify"] = this.on_server_change_notify
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function MainModel.on_server_change_notify(_, data)
    if table_is_null(data.data) then
        local platform = gameMgr:getMarketPlatform()
        for k,v in ipairs(data.data) do
            if v.platform == platform then
                gameMgr:CheckFilesUpdate("localconfig/" .. v.version .. "/", gameMgr:getLocalPath("localconfig/"), "file_list.txt", v.hash, nil, function(isok)
                    if isok then
                        package.loaded["Game.Framework.GameForceUpdate"] = nil
                        require("Game.Framework.GameForceUpdate")
                        GameForceUpdate.Call(v)
                    end
                end)
                return
            end
        end
    end
end

function MainModel.on_confirm_million_cup_response(_,data)
    Event.Brocast("main_model_confirm_million_cup_response",data.result)
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function MainModel.Init ()
    MainModel.CleanWebViewAllCookies()
    
    MainModel.cur_myLocation = "game_Login"
    MainModel.CleanWebViewAllCookies()
    this = MainModel
    -- 初始化加密字段
    PROTO_TOKEN = nil

    AddLister()

    Screen.sleepTimeout = -1

    this.IsLoged = false
    this.AutoLoginState = this.AutoLoginState or 0

    MainModel.RefreshDeviceInfo()
    dump(this.LoginInfo.device_id, "[Debug] device_id: ")
    dump(gameMgr:getMarketChannel(), "[Debug] market_channel: ")
    dump(gameMgr:getMarketPlatform(), "[Debug] platform: ")

    UpdateTimer = Timer.New(this.Update, UPDATE_INTERVAL, -1, nil, true)
    UpdateTimer:Start()
    --ios订单处理
    IosPayManager.Init()
	--android订单处理
	AndroidPayManager.Init()
    -- gestureMgr:TryAddGesture("GestureCircle")

    return this
end

function MainModel.RefreshDeviceInfo()
    local deivesInfo = Util.getDeviceInfo()
    this.LoginInfo = 
    {
        device_id = deivesInfo[0],
        device_os = deivesInfo[1],
    }
    if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
       this.LoginInfo.device_id = MainModel.GetDeviceID()
    end
end
-- 获取设备信息
function MainModel.GetDeviceID(tt)
    -- if tt then
    --     return sdkMgr:GetDeviceID(tt)
    -- else
    --     return sdkMgr:GetDeviceID("uuid")
    -- end

    local uuid = PlayerPrefs.GetString("DominoDeviceUUID", "")
    if uuid == "" then
        uuid = sdkMgr:GetDeviceID("uuid")
        PlayerPrefs.SetString("DominoDeviceUUID", uuid)
    end
    dump(uuid, "MainModel.GetDeviceID")
    return uuid
end
-- 检查是否要自动登录
function MainModel.GetIsAutoLogin()
    if this.AutoLoginState== 0 then
    	if LoginModel.loginData.lastLoginChannel and LoginModel.loginData.lastLoginChannel ~= "youke" then
		return true
	end
    end
    return false
end


--[[登录返回的消息
    result $ : integer # 0 succed ,or error id 
    user_id $ : string # 登录成功返回用户 id （系统唯一 id）
    login_id $ : string # 登录id 快速登录使用 客户端应当保存
    name $ : string     # 玩家名字
    head_image $ : string # 玩家头像连接 可能为空串
    match_ticket $ : integer    #-- 比赛券
    shop_gold $ : integer   #-- 购物金
    room_card $ : integer   #-- 房卡
    cash $ : integer    #-- 现金
    sex $ : integer     # 性别 1男 0女 或者 nil
    introducer $ : string # 简介
    location $ : string #当前玩家所在位置
]]

function MainModel.OnLogin (_,data )
    dump(data, "<color=red>AAA OnLogin登录数据 AAA</color>")

    if data.result == 0 then
        if os.old_time and data.server_time then
            _client_server_time_diff = tonumber(data.server_time) - os.old_time()
        end
        heartBeatLostCurTime = 0
        local instance_id = this.instance_id or 0
        if instance_id ~= 0 and instance_id ~= data.instance_id then
            NetJH.RemoveAll()
    		HintPanel.Create(1, GLL.GetTx(10005), function ()
    			--UnityEngine.Application.Quit()
                gameMgr:QuitAll()
    		end)
	       	return
    	end
        this.instance_id = data.instance_id
        
        this.UserInfo = data
        this.UserInfo.shop_gold_sum = 0
        this.UserInfo.jing_bi = 0
        this.UserInfo.player_asset = nil
        this.UserInfo.GiftShopStatus = {}

        this.LoginInfo.login_id=data.login_id
        this.LoginInfo.channel_type=data.channel_type
        this.LoginInfo.is_test = data.is_test
        if data.refresh_token then
            local tt = {}
            tt.refresh_token = data.refresh_token
            tt.token = data.refresh_token
        	this.LoginInfo.channel_args = lua2json(tt)
        end
        local channelTbl = LoginModel.GetChannelLuaTable(data.channel_type)
        if channelTbl then
        	this.LoginInfo.openid = channelTbl.openid
        end

        this.Location = getServerLocation(data.location, data.game_id)
        this.game_id = data.game_id
    
        if not this.UserInfo.name then
            this.UserInfo.name = ""
        end

    	local player_level = this.UserInfo.player_level or 0
    	if player_level > 0 then
    		--gestureMgr:TryAddGesture("GestureLines")
    		gestureMgr:TryAddGesture("GestureCircle")
    	end
    else
        this.IsLoged = false
    end

    NetworkManager.reLoginOverTimeCbk = nil

    --重连登录完成
    if NetworkManager.reConnectServerState == 2 then
        NetworkManager.reConnectServerState = 0

        print("<color=blue> ReConnecte Succeed </color>")

        NetJH.RemoveAll()
        --重连后登录完成
        if data.result == 0 then
            MainModel.CloseAssetTab()
            this.query_asset_index = 1

            this.UserInfo.is_login = 1
            this.login_query_map = {query_asset = 1, query_all_gift_bag_status = 1,query_system_variant_data=1}
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                Network.SendRequest("query_asset", {index = this.query_asset_index})
            end
            Network.SendRequest("query_all_gift_bag_status", nil)
            Network.SendRequest("query_system_variant_data")
            NetJH.Create(GLL.GetTx(10018), "login")
        else
            Event.Brocast("ReConnecteServerResponse",data.result)
        end
    else
        NetJH.RemoveAll()
        --正常的登陆完成
        if data.result == 0 then
            MainModel.CloseAssetTab()
            this.query_asset_index = 1

            this.UserInfo.is_login = 2
            this.login_query_map = {query_asset = 1, query_all_gift_bag_status = 1,query_system_variant_data=1}
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                Network.SendRequest("query_asset", {index = this.query_asset_index})
            end
            Network.SendRequest("query_all_gift_bag_status", nil)
            Network.SendRequest("query_system_variant_data")
            NetJH.Create(GLL.GetTx(10018), "login")
            LoginLogic.SetGoodIP(AppConst.SocketAddress)

        else
            Event.Brocast("Ext_OnLoginResponse", data.result)
        end
    end
end

function MainModel.CloseAssetTab()
    if this.UserInfo.asset_map then
        for k,v in pairs(this.UserInfo.asset_map) do
            this.UserInfo[k] = nil
        end
    end
    this.UserInfo.ToolMap = {}
end

function MainModel.GetObjInfoByKey(key)
    if not this.UserInfo or not this.UserInfo.ToolMap then
        return
    end
    local list = {}
    for k,v in pairs(this.UserInfo.ToolMap) do
        if v.asset_type == key then
            list[#list + 1] = v
        end
    end
    return list
end

function MainModel.on_query_asset(_, data)
    dump(data, "<color=red>on_query_asset</color>")
    if not table_is_null(data.player_asset) then
        for k,v in ipairs(data.player_asset) do
            if not v.attribute or v.asset_type == "jipaiqi" then
                if v.asset_type == "jipaiqi" then
                    this.UserInfo[v.asset_type] = tonumber(v.attribute[1].value)
                elseif v.asset_type == "shop_gold_sum" then
                    this.UserInfo[v.asset_type] = tonumber(v.asset_value) / 100
                else
                    this.UserInfo[v.asset_type] = tonumber(v.asset_value)
                end
                this.UserInfo.asset_map = this.UserInfo.asset_map or {}
                this.UserInfo.asset_map[v.asset_type] = 1
            else
                local vv = {}
                this.UserInfo.ToolMap[v.asset_value] = vv
                vv.id = v.asset_value
                vv.asset_type = v.asset_type
                for k1,v1 in pairs(v.attribute) do
                    if tonumber(v1.value) then
                        vv[v1.name] = tonumber(v1.value)
                    else
                        vv[v1.name] = v1.value
                    end
                end
            end
        end
    end
    MainModel.ADD_JB_Log({jb=this.UserInfo.jing_bi})

    if this.reset_query_asset then
        MainModel.CloseAssetTab()
        this.query_asset_index = 1
        this.reset_query_asset = false

        Network.SendRequest("query_asset", {index = this.query_asset_index})
        return
    end

    MainModel.check_asset_change_no(data.no)

    if not data.player_asset or (#data.player_asset < 100 and #data.player_asset >= 0) then
        this.is_on_query_asset = false
        Event.Brocast("AssetChange", {data={}})
        MainModel.finish_login_query("query_asset")
    else
        this.query_asset_index = this.query_asset_index + 1
        Network.SendRequest("query_asset", {index = this.query_asset_index})
    end
end
function MainModel.on_query_all_gift_bag_status(_,data)
    dump(data, "<color=red>初始化礼包:on_query_all_gift_bag_status</color>")
    for k,v in ipairs(data.gift_bag_data) do
        this.UserInfo.GiftShopStatus[v.gift_bag_id]={}
        this.UserInfo.GiftShopStatus[v.gift_bag_id].status = v.status
    end
    MainModel.finish_login_query("query_all_gift_bag_status")
end
function MainModel.query_system_variant_data(_,data)
    MainModel.finish_login_query("query_system_variant_data")
    Event.Brocast("model_query_system_variant_data", "query_system_variant_data", data)
end
function MainModel.finish_login_query(key)
    this.login_query_map[key] = nil

    if not this.login_query_map or not next(this.login_query_map) then
        MainModel.finish_login_flow()
    end
end
-- 完成登录流程
function MainModel.finish_login_flow()
    this.IsLoged = true
    NetJH.RemoveByID("login")

    -- 启动网络消息发送管理器
    Event.Brocast("main_model_finish_login_msg")

    if this.UserInfo.is_login then
        if this.UserInfo.is_login == 1 then
            Event.Brocast("ReConnecteServerResponse", 0)
        elseif this.UserInfo.is_login == 2 then
            Event.Brocast("Ext_OnLoginResponse", 0)
        end
    end

    this.UserInfo.is_login = 0    
    Event.Brocast("main_model_query_all_gift_bag_status")    
end

------------------------ping------------------
function MainModel.OnPing(ping)
    LuaHelper.OnPing(ping)
end

function MainModel.OnCallupServiceCenter(phoneNumber)
	print("OnCallupServiceCenter:" .. phoneNumber)
	if gameMgr:getMarketChannel() == "hw_wqp" then
		UniClipboard.SetText(phoneNumber)
		LittleTips.Create("已复制客服电话:" .. phoneNumber)
	else
		sdkMgr:CallUp(phoneNumber)
	end
end

-----------------------------------------被踢下线-------------------------------------------
function MainModel.will_kick_reason(proto_name,data)

    if data.reason == "logout" then
        --由于后台很久了，服务器已经把代理杀了 将会自动重连登陆
        print("<color=red> server wait over time  </color>")

    elseif data.reason == "relogin" then
        MainModel.IsLoged = false
        --有人用我的login_id在其他地方登陆
        print("<color=red> other is logining </color>")
        Event.Brocast("bsds_send_power",{key = "relogin", param={param1=MainModel.UserInfo.login_id}})

        HintPanel.Create(1,GLL.GetTx(10006),function ()
            LoginModel.ClearLoginData("dh")

            MainLogic.Exit()
            networkMgr:Init()
            Network.Start()
            MainLogic.Init()
            
        end)

    else

        print("<color=red> error </color>")
        dump(data,proto_name)

    end

end

-----------------------------------------百万大奖赛奖杯------------------
function MainModel.notify_million_cup_msg (proto_name,data)
    this.UserInfo.million_cup_status = data.million_cup_status
    if this.UserInfo.million_cup_status then
        Event.Brocast("on_notify_million_cup_msg")
    end
end
-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------
function MainModel.IsShowAward(a_type)
    if not a_type then
        return false
    end
    if NO_TIPS_ASSET_CHANGE_TYPE and NO_TIPS_ASSET_CHANGE_TYPE[a_type] then
        return false
    end

    for i = 1001, 1014 do
        local str = "box_exchange_active_award_"..i--抽奖奖励弹窗
        if a_type == str then
            return false
        end
    end

    return true
end

function MainModel.IsShowAwardGet(type)
    if type == "prop_point_common" then
        return false
    end
    return true
end

function MainModel.OnNotifyAssetChangeMsg(proto_name,data)
    dump(data, "<color=white>资产改变改变</color>")

    this.UserInfo = this.UserInfo or {}
    this.UserInfo.ToolMap = this.UserInfo.ToolMap or {}

    --改变的资产处理
    local change_assets = {}
    --改变的Obj资产列表
    local obj_assets_list = {}
    --改变的prop资产列表
    local prop_assets_list = {}

    --改变的资产 获得的
    local change_assets_get = {}
    local change_bag_tag = 0 -- 那些背包有变化
    local chg_jing_bi = 0
    if data.change_asset then
        local item
        for k,v in pairs(data.change_asset) do
            if v.asset_type == "jing_bi" then
                chg_jing_bi = v.asset_value
            end
            if v.asset_type == "jing_bi" and tonumber(v.asset_value) < 0 then
                DSM.Consume(data)
            end
        
            local is_add_bag = false
            if basefunc.is_object_asset(v.asset_type) then
                if not v.attribute then
                    this.UserInfo.ToolMap[v.asset_value] = nil
                    obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="del"}
                else
                    local change_attribute = false -- 只是修改属性
                    if this.UserInfo.ToolMap[v.asset_value] then
                        change_attribute = true
                        obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="chg"}
                    else
                        obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="add"}
                    end
                    local vv = {}
                    this.UserInfo.ToolMap[v.asset_value] = vv
                    vv.id = v.asset_value
                    vv.asset_type = v.asset_type
                    for k1,v1 in ipairs(v.attribute) do
                        if tonumber(v1.value) then
                            vv[v1.name] = tonumber(v1.value)
                        else
                            vv[v1.name] = v1.value
                        end
                    end
                    if not change_attribute then
                        change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = 1}
                        change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = 1}
                    end
                end
            else
                if tonumber(v.asset_value) then
                    local num = tonumber(v.asset_value)
                    --RP 前端显示除以100
                    if v.asset_type == "shop_gold_sum" then
                        num = tonumber(v.asset_value) / 100
                    end
                    if not this.UserInfo[v.asset_type] then
                        this.UserInfo[v.asset_type] = 0
                    end
                    this.UserInfo[v.asset_type] = this.UserInfo[v.asset_type] + num

                    change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = num}
                    if num > 0 then
                        change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = num}
                        prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="add"}
                    else
                        if this.UserInfo[v.asset_type] > 0 then
                            prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="chg"}
                        else
                            prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="del"}
                        end
                    end
                else
                    dump(v, "<color=red>非限时道具asset_value不能转成number</color>")
                end 
            end
        end
    end
    MainModel.ADD_JB_Log({no=data.no, jb=chg_jing_bi})
    if not table_is_null(change_assets_get) then
        for i = #change_assets_get, 1, -1 do
            if not MainModel.IsShowAwardGet(change_assets_get[i].asset_type) then
                table.remove(change_assets_get, i)
            end
        end
    end
    Event.Brocast("AssetChange", {data = change_assets_get, change_type = data.type, 
                                  prop_assets_list = prop_assets_list, obj_assets_list = obj_assets_list, tag = change_bag_tag})

    if MainModel.IsShowAward(data.type) and #change_assets_get > 0 then
        Event.Brocast("AssetGet",{data = change_assets_get, change_type = data.type})
    end

    MainModel.check_asset_change_no(data.no)
end
local is_on_off_JB_Log = false
local log_jing_bi = {}
function MainModel.ADD_JB_Log(log)
    if not is_on_off_JB_Log then return end
    log_jing_bi[#log_jing_bi + 1] = log
end
function MainModel.BC_JB_Log()
    if not is_on_off_JB_Log then return end
    local st = ""
    for k,v in ipairs(log_jing_bi) do
        st = st .. "no:" .. (v.no or "nil") .. "    jb=" .. v.jb .. "\n"
    end
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    path = path .. "/jing_bi.txt"
    File.WriteAllText(path, st)
end
function MainModel.check_asset_change_no(_no)
    if _no and this.UserInfo.asset_change_no then
        local no = this.UserInfo.asset_change_no + 1
        if no > 65000 then
            no = 1
        end
        if _no ~= no then
            this.UserInfo.asset_change_no = nil
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                MainModel.CloseAssetTab()
                this.query_asset_index = 1

                Network.SendRequest("query_asset", {index = this.query_asset_index}, "")
            end
        end
    end
    this.UserInfo.asset_change_no = no
end

function MainModel.GetHBValue()
    if MainModel.UserInfo.shop_gold_sum then
        return MainModel.UserInfo.shop_gold_sum
    else
        return 0
    end
end

-- 获取区域
function MainModel.GetAreaID()
    MainModel.UserInfo.AreaID = 1-- 成都
    return MainModel.UserInfo.AreaID
end
-- 设置区域
function MainModel.SetAreaID(area)
    MainModel.UserInfo.AreaID = area
    Event.Brocast("update_player_area_id")
end

-- 返回收货地址
function MainModel.GetAddress()
    if MainModel.UserInfo.shipping_address and MainModel.UserInfo.shipping_address.address then
        return StringHelper.Split(MainModel.UserInfo.shipping_address.address, "#")
    end
end

-- 返回收货地址
function MainModel.CacheShop()
    local pp = GameObject.Find("WebView__shop_")
    if IsEquals(pp) then
        return
    end
    local shop_url
    Network.SendRequest(
        "create_shoping_token",
        {geturl = shop_url and "n" or "y"},
        function(_data)
            if _data.result == 0 then
                shop_url = _data.url or shop_url
                if not shop_url then return end
                local url = string.gsub(shop_url, "@token@", _data.token)
                --UniWebViewMgr.CreateUniWebView("shop")
                --UniWebViewMgr.SetWebContentsDebuggingEnabled("shop")
                -- print("gameWeb:OnShopClick() : ", url)
                -- gameWeb:OnShopClick(url, true)
				-- gameWeb:EvaluateJS("_shop_", "webviewWillAppear()")

                -- local webObj = GameObject.Find("WebView__shop_")
                -- if IsEquals(webObj) then
                --     print("<color=red>EEEEEEEEEEEEEEEEEEEEE</color>")
                --     dump(webObj)
                --     GameObject.DontDestroyOnLoad(webObj)
                -- end
            else
                print("<color=red>result = " .. _data.result .. "</color>")
            end
        end
    )
end
-- 是否需要绑定
function MainModel.IsNeedBindPhone()
    if MainModel.UserInfo then
        local is_not_bind = (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
        return is_not_bind
    end
    return false
end
function MainModel.OpenDH(parm)
    if GameGlobalOnOff.TS then
        return
    end
    local can_do = false
    can_do = true

    if can_do then
        Network.SendRequest("create_shoping_token", {geturl=shop_url and "n" or "y"},function(_data)
            if _data.result == 0 then
                if MainModel.GetHBValue() >= 10 then
                    PlayerPrefs.SetString("HallDHHintTime" .. MainModel.UserInfo.user_id, os.time())
                end
                shop_url = _data.url or shop_url
                if not shop_url then
                    HintPanel.Create(1, "测试服没有兑换商城")
                    return
                end

                local url = string.gsub(shop_url,"@token@",_data.token)
                if parm then
                    url = url .. parm
                end
                dump(url, "<color=white> <<<<<<<< OpenDH >>>>>>>> </color>")
                UniWebViewMgr.OpenUrl("shop",url)
            end
        end )
    end
end
-- 客服反馈
function MainModel.OpenKFFK()
    local url = string.format("http://kfapp.domino00.com/jyhd/jyddz/#/userfeedback?playerid=%s", MainModel.UserInfo.user_id)
    if AppDefine.IsEDITOR() then
		Application.OpenURL(url);
		return
	end
    dump(url, "<color=white> <<<<<<<< Open KFFK >>>>>>>> </color>")
    UniWebViewMgr.OpenUrl("kffk",url)
    --gameWeb:OnShopClickLoadURL(url)
	--gameWeb:EvaluateJS("_shop_", "`webviewWillAppear()")
end

function MainModel.OpenLoginKFFK()
    local url = "http://kfapp.domino00.com/jyhd/jyddz/#/login-userfeedback"
    if AppDefine.IsEDITOR() then
		Application.OpenURL(url);
		return
	end
    dump(url, "<color=white> <<<<<<<< Open KFFK Login >>>>>>>> </color>")
    UniWebViewMgr.OpenUrl("kffk_login",url)
end

-- 设置礼包的status
-- function MainModel.SetItemStatus(id, status)
--     if MainModel.UserInfo.GiftShopStatus[id] then
--         MainModel.UserInfo.GiftShopStatus[id].status = status
--     end
-- end
-- 礼包数据改变
-- function MainModel.on_gift_bag_status_change_msg(pName, data)
--     if not this.UserInfo or not this.UserInfo.GiftShopStatus then
--         return
--     end
--     MainModel.SetGiftData(data)
--     Event.Brocast("main_change_gift_bag_data_msg", data.gift_bag_id)
-- end
-- function MainModel.on_query_gift_bag_status(_, data)
--     if data.result == 0 then
--         MainModel.SetGiftData(data)
--         Event.Brocast("main_query_gift_bag_data_msg", data.gift_bag_id)    
--     end
-- end
-- function MainModel.on_query_gift_bag_status_by_ids_response(_, data)
--     if data.result == 0 then
--         if not this.UserInfo or not this.UserInfo.GiftShopStatus then
--             return
--         end
--         local list = {}       
--         for i = 1,#data.gift_bag_data do
--             local id = data.gift_bag_data[i].gift_bag_id
--             list[#list + 1] = id
--             if not this.UserInfo.GiftShopStatus[id] then
--                 this.UserInfo.GiftShopStatus[id] = {}
--             end
--             this.UserInfo.GiftShopStatus[id].status = data.gift_bag_data[i].status
--             this.UserInfo.GiftShopStatus[id].remain_time = data.gift_bag_data[i].remain_time or 0
--         end
--         Event.Brocast("shop_info_get", list)
--     end
-- end

-- function MainModel.SetGiftData(data)
--     local id = data.gift_bag_id
--     if not this.UserInfo.GiftShopStatus[id] then
--         this.UserInfo.GiftShopStatus[id] = {}
--     end
--     this.UserInfo.GiftShopStatus[id].status = data.status
--     this.UserInfo.GiftShopStatus[id].permit_time = data.permit_time --权限持续时间
--     this.UserInfo.GiftShopStatus[id].permit_start_time = data.permit_start_time --权限开始时间
--     this.UserInfo.GiftShopStatus[id].time = data.time --上次购买时间
--     this.UserInfo.GiftShopStatus[id].remain_time = data.remain_time --剩余数量
-- end
-- -- 是否需要请求剩余次数
-- function MainModel.IsNeedQueryRemainTimeByShopID(id)
--     if not this.UserInfo or not this.UserInfo.GiftShopStatus then
--         return true
--     end
--     if not this.UserInfo.GiftShopStatus[id] or not this.UserInfo.GiftShopStatus[id].remain_time then
--         return true
--     end
--     return false
-- end

-- -- 获取礼包数据
-- function MainModel.GetGiftDataByID(id)
--     if MainModel.UserInfo and MainModel.UserInfo.GiftShopStatus and MainModel.UserInfo.GiftShopStatus[id] then
--         return MainModel.UserInfo.GiftShopStatus[id]
--     end
-- end
-- -- 获取礼包剩余次数
-- function MainModel.GetRemainTimeByShopID(id)
--     if not this.UserInfo or not this.UserInfo.GiftShopStatus then
--         return 0
--     end
--     if not this.UserInfo.GiftShopStatus[id] then
--         this.UserInfo.GiftShopStatus[id] = {}
--     end
--     return this.UserInfo.GiftShopStatus[id].remain_time or 0
-- end
-- -- 获取礼包结束时间
-- function MainModel.GetGiftEndTimeByID(id)
--     local data = MainModel.GetGiftDataByID(id)
--     if data then
--         local permit_time = tonumber(data.permit_time) or 0
--         local permit_start_time = tonumber(data.permit_start_time) or 0
--         local permit_end_time = permit_time + permit_start_time
--         return math.max( 0, permit_end_time)
--     else
--         return 0
--     end
-- end
-- -- 礼包能不能购买
-- function MainModel.IsCanBuyGiftByID(id)
--     local data = MainModel.GetGiftDataByID(id)
--     if data then
--         local permit_time = tonumber(data.permit_time) or 0
--         local permit_start_time = tonumber(data.permit_start_time) or 0
--         local permit_end_time = permit_time + permit_start_time
--         local cur_t = os.time()
--         if data.status == 1 and (permit_start_time == 0 or (cur_t <= permit_end_time) ) then  --(permit_start_time - 60) <= cur_t   权限礼包展示开始时间
--             return true
--         end
--     end
-- end
-- -- 礼包是否购买过 true:买过  false:没有买过
-- function MainModel.IsHadBuyGiftByID(id)
--     local data = MainModel.GetGiftDataByID(id)
--     if data then
--         local permit_time = tonumber(data.permit_time) or 0
--         local permit_start_time = tonumber(data.permit_start_time) or 0
--         local permit_end_time = permit_time + permit_start_time
--         local cur_t = os.time()
--         if data.status == 1 and (permit_start_time == 0 or (cur_t <= permit_end_time) ) then  --(permit_start_time - 60) <= cur_t   权限礼包展示开始时间
--             return false
--         end
--         if data.status == 0 and data.remain_time > 0 then
--             return false
--         end
--         return true
--     end
--     return true
-- end

-- function MainModel.on_query_gift_bag_num_response(_,data)
--     dump(data, "<color=red>on_query_gift_bag_num_response</color>")
--     if data.result==1008 then 
--         print("<color=red> 获取礼包数量返回码 1008<color>")
--             return 
--     end 
--     if not data.result or data.result ~= 0 then
--         return
--     end
--     if not MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] then
--         MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] = {}
--     end
--     MainModel.UserInfo.GiftShopStatus[data.gift_bag_id].count = data.num
--     Event.Brocast("model_query_gift_bag_num_shopid_"..data.gift_bag_id, {shopid=data.gift_bag_id, count=data.num})    
-- end


-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------


-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------
function MainModel.AddOrderData(order_id, config, data)
    MainModel.pay_order_map = MainModel.pay_order_map or {}
    MainModel.pay_order_map[order_id] = {order_id=order_id,config=config, data=data}
end
function MainModel.OnNotifyPayOrderMsg(proto_name,msg)
    Event.Brocast("ReceivePayOrderMsg",msg)
    if msg.result == 0 then
        MainModel.pay_order_map = MainModel.pay_order_map or {}
        if MainModel.pay_order_map[msg.order_id] then
            MainModel.pay_order_map[msg.order_id].msg = msg
            Event.Brocast("model_pay_order_finish_msg", MainModel.pay_order_map[msg.order_id])
        end
    end
end
-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------

-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.OnForeGround ()
    Event.Brocast("EnterForeGround")
    local deeplink = sdkMgr:GetDeeplink()
    if deeplink and deeplink ~= "" then
        print("<color=red>deeplink = " .. deeplink .. "</color>")
	    MainLogic.HandleOpenURL(deeplink)
    end
end
function MainModel.OnBackGround ()
    Event.Brocast("EnterBackGround")
end


-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.Update ()
    if MainModel.UserInfo and MainModel.UserInfo.first_login_time and MainModel.UserInfo.ui_config_id and MainModel.UserInfo.ui_config_id == 2 then
        local c_t = os.time()
        if c_t > tonumber(MainModel.UserInfo.first_login_time) + 7 * 86400 then
            MainModel.UserInfo.ui_config_id = 1
            Event.Brocast("player_new_change_to_old")
        end
    end
end

function MainModel.Exit ()
    if this then
        UpdateTimer:Stop()

        RemoveLister()

        this.Location = nil
        this.IsLoged = nil
        this.UserInfo = nil
        this.LoginInfo = nil
        this.RoomCardInfo = nil
        this = nil

        IosPayManager.Exit()
		AndroidPayManager.Exit()
    end
    
end

function MainModel.OnGestureCircle()
    Event.Brocast("GMPanel")
end
function MainModel.OnGestureLines()
    Event.Brocast("GMPanel")
end

function MainModel.GetMarketChannel()
    if MainModel.UserInfo and MainModel.UserInfo.market_channel then
        return MainModel.UserInfo.market_channel
    end
    return "normal"
end

function MainModel.FirstLoginTime()
    if MainModel.UserInfo and MainModel.UserInfo.first_login_time then
        return tonumber(MainModel.UserInfo.first_login_time)
    end
    return os.time()
end

function MainModel.on_LoginResponse(result)
    if result ~= 0 then return end
end

function MainModel.OnExitScene()
    MainModel.asset_change_list = {}
end

local function ClearDir(dir)
	if not Directory.Exists(dir) then return end

	local files = Directory.GetFiles(dir)
	for i = 0, files.Length - 1 do
		if not string.find(files[i], "com.android.opengl.shaders_cache") then
			print("delete file:" .. files[i])
			File.Delete(files[i])
		end
	end

	local dirs = Directory.GetDirectories(dir)
	for i = 0, dirs.Length - 1 do
		Directory.Delete(dirs[i],true)
	end
end
local package_table = {
    normal = "com.changleyou.domino",
}
function MainModel.CleanWebViewAllCookies()
    if gameRuntimePlatform ~= "Android" then return end
    if PlayerPrefs.GetInt("Clean_WebView_Cookies", 0) == 0 then
        local platform = gameMgr:getMarketPlatform()
        local package_name = package_table[platform]
        if not package_name then return end
        local dir = "/data/data/" .. package_name
        if Directory.Exists(dir) then
			local cache = dir .. "/" .. "cache"
			if Directory.Exists(cache) then
				ClearDir(cache)
			end

			local databases = dir .. "/" .. "databases"
			if Directory.Exists(databases) then
				print("delete dir:" .. databases)
				Directory.Delete(databases,true)
			end
        end
        PlayerPrefs.SetInt("Clean_WebView_Cookies", 1)
    end
end

function MainModel.SetLastGameID(id)
    PlayerPrefs.SetInt("last_game_id"..MainModel.UserInfo.user_id,id)
end
--根据上一次玩的游戏类型，然后在这个游戏类型中挑选一个最适合的场次
function MainModel.GetLastGameID()
    local id = PlayerPrefs.GetInt("last_game_id"..MainModel.UserInfo.user_id,45)
    -- -1 是slots
    -- if id == -1 then
    if id < 0 then
        return id
    end
    local game_type = MainModel.GetInfoByGameID(id).game_name
    local best_id = MainModel.GetBestGameID(game_type)
    return best_id
end

function MainModel.GetInfoByGameID(id)
	local keys = MainLogic.GetGameKeys()
	for i = 1,#keys do
		for ii = 1,#Game_Hall_Config[keys[i]] do
			if Game_Hall_Config[keys[i]][ii].game_id == id then
				Game_Hall_Config[keys[i]][ii].game_name = keys[i]
				return Game_Hall_Config[keys[i]][ii]
			end
		end
	end
end

function MainModel.GetBestGameID(game_type)
	local gold_num = MainModel.UserInfo.jing_bi
	local game_id = nil
	for i = 1,#Game_Hall_Config[game_type] do
		if gold_num >= Game_Hall_Config[game_type][i].limit_min then
			if Game_Hall_Config[game_type][i].limit_max then
				if gold_num <= Game_Hall_Config[game_type][i].limit_max then
					game_id = Game_Hall_Config[game_type][i].game_id
				end
			else
				game_id = Game_Hall_Config[game_type][i].game_id
			end
		end
	end
	return game_id
end

function MainModel.CheckBestGameID(game_type,game_id)
    local gold_num = MainModel.UserInfo.jing_bi
	for i = 1,#Game_Hall_Config[game_type] do
		if game_id == Game_Hall_Config[game_type][i].game_id then
			if gold_num >= Game_Hall_Config[game_type][i].limit_min then
                if Game_Hall_Config[game_type][i].limit_max then
                    if gold_num <= Game_Hall_Config[game_type][i].limit_max then
                        return true
                    end
                else
                    return true
                end
            end
		end
	end
end

function MainModel.GetCurVersion()
    local cur_ver = MainVersion.baseVersion
    local vf = resMgr.DataPath .. "udf.txt"
    if File.Exists(vf) then
        local luaTbl = json2lua(File.ReadAllText(vf))
        if luaTbl then
            cur_ver = luaTbl.version
        end
    end
    return cur_ver
end
