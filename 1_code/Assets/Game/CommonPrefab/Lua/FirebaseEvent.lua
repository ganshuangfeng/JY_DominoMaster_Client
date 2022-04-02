-- 创建时间:2021-12-23

FirebaseEvent = {}
local TAG = "Firebase "

local event_fun_map = {}
local is_on_off = true -- 开关
local fenge = "#"

local this
local lister
local function AddLister()
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
local function MakeLister()
    lister={}
    lister["game_all_manage_event"] = FirebaseEvent.on_fire_base_event
    lister["EnterScene"] = FirebaseEvent.OnEnterScene
end

function FirebaseEvent.Init()
	FirebaseEvent.Exit()

    this = FirebaseEvent

    MakeLister()
    AddLister()
    if not VersionManager.Off.firebase_ts then
	    FirebaseEvent.InitMessaging()
    end
    return this
end
function FirebaseEvent.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function FirebaseEvent.OnEnterScene()
	if not VersionManager.Off.firebase_ts then
		if MainModel.myLocation == "game_Hall" and not FirebaseEvent.is_send_token then
			FirebaseEvent.SetMessagingData()
	    end
	end
end

--[[

--]]
-- 初始化sdk
function FirebaseEvent.InitMessaging()
	sdkMgr:AddFirebaseComCallback(function (json_data)
		local tbl = json2lua(json_data)
		dump(tbl, TAG.."<color=green>AddFirebaseComCallback tbl </color>")
		if tbl and tbl.msg then
			if tbl.msg == "subscribe" then
			elseif tbl.msg == "unsubscribe" then
			end
		end
	end)
end
-- 获取Token
function FirebaseEvent.SetMessagingData()
	sdkMgr:GetMessagingData("get", function (json_data)
		dump(json_data, TAG.."<color=green>Firebase GetMessagingData json_data </color>")
		local tbl = json2lua(json_data)
		if tbl then
	        Network.SendRequest("google_firebase_inform_set_token", { register_token = tbl.token}, function (_data)
	        	if _data.result == 0 then
	        		FirebaseEvent.is_send_token = true
	        	end
	        end)
		else
			-- HintPanel.Create(1, json_data)
		end
	end)
end
-- 发送上行消息
function FirebaseEvent.SendUpstream()
	FirebaseEvent.messageId = FirebaseEvent.messageId or 0
	FirebaseEvent.SENDER_ID = "SENDER_ID"

	local tbl = {}
	tbl.SENDER_URL = FirebaseEvent.SENDER_ID .. "@fcm.googleapis.com"
	tbl.messageId = FirebaseEvent.messageId
	tbl.message = "Hello World"
	tbl.action = "SAY_HELLO"
	sdkMgr:SendUpstream(lua2json(tbl))

	FirebaseEvent.messageId = FirebaseEvent.messageId + 1	
end
-- 订阅主题
function FirebaseEvent.OnSubscribeToTopic()
	sdkMgr:OnSubscribeToTopic("weather")

end
-- 退订主题
function FirebaseEvent.OnUnsubscribeFromTopic()
	sdkMgr:OnUnsubscribeFromTopic("weather")
end



function FirebaseEvent.on_fire_base_event(data)
	dump(data, "<color=red><size=15>AAAAA on_fire_base_event AAAAA</size></color>")
	if is_on_off and data.event and event_fun_map[data.event] then
		event_fun_map[data.event](data)
	end
end

local add_parm = function (parm, kk, tt, vv, e)
	e = e or ""
	parm = parm .. kk .. fenge .. tt .. fenge .. vv .. e
end

-- 当用户注册时触发，以衡量每种注册方法的受欢迎程度 (注册时所用的方法 示例值="Google")
event_fun_map.sign_up = function (data)
	local tab = {}
	tab.event = "sign_up"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "method", "string", data.method)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户登录时触发 (登录时所用的方法 示例值="Google")
event_fun_map.login = function (data)
	local tab = {}
	tab.event = "login"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "method", "string", data.method)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户分享内容时触发 (共享内容的方法, 共享内容的类型, 共享内容的 ID)
event_fun_map.share = function (data)
	local tab = {}
	tab.event = "share"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "method", "string", data.method, fenge)
	add_parm(tab.parm, "content_type", "string", data.type, e)
	add_parm(tab.parm, "item_id", "string", data.id)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户搜索您的内容时触发 (搜索的字词 可用于统计各游戏类型的热门程度)
event_fun_map.search = function (data)
	local tab = {}
	tab.event = "search"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "search_term", "string", data.search)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户在游戏中升级时触发 (升级的角色, 角色的等级)
event_fun_map.level_up = function (data)
	local tab = {}
	tab.event = "level_up"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "character", "string", data.name, fenge)
	add_parm(tab.parm, "level", "long", data.level)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户获得虚拟货币（金币、宝石、代币等）时触发 (虚拟货币的名称, 虚拟货币的价值)
event_fun_map.pay_finish = function (data)
	local tab = {}
	tab.event = "earn_virtual_currency"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "virtual_currency_name", "string", data.asset_name, fenge)
	add_parm(tab.parm, "value", "double", data.asset_value)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户支出虚拟货币（金币、宝石、代币等）时触发 (使用虚拟货币的商品的名称, 虚拟货币的价值, 虚拟货币的名称)
event_fun_map.spend_virtual_currency = function (data)
	local tab = {}
	tab.event = "spend_virtual_currency"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "virtual_currency_name", "string", data.shop_id, fenge)
	add_parm(tab.parm, "item_name", "string", data.asset_name, fenge)
	add_parm(tab.parm, "value", "double", data.asset_value)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 用户发布得分时触发 (获得相应得分的角色, 得分对应的关卡, 要发布的得分)
event_fun_map.post_score = function (data)
	local tab = {}
	tab.event = "post_score"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "character", "string", data.name, fenge)
	add_parm(tab.parm, "level", "long", data.level, fenge)
	add_parm(tab.parm, "score", "long", data.score)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户开始学习教程时触发
event_fun_map.tutorial_begin = function (data)
	local tab = {}
	tab.event = "tutorial_begin"
	tab.fg = fenge
	tab.parm = ""
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户学完教程时触发
event_fun_map.tutorial_complete = function (data)
	local tab = {}
	tab.event = "tutorial_complete"
	tab.fg = fenge
	tab.parm = ""
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户达成成就时触发 (已解锁成就的 ID)
event_fun_map.unlock_achievement = function (data)
	local tab = {}
	tab.event = "unlock_achievement"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "achievement_id", "string", data.id)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户选择内容时触发 (所选内容的类型, 所选商品的标识符) 参与的游戏类型+游戏场次id
event_fun_map.select_content = function (data)
	local tab = {}
	tab.event = "select_content"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "content_type", "string", data.type, fenge)
	add_parm(tab.parm, "item_id", "string", data.id)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户在游戏中开始新关卡时触发 (关卡的名称)
event_fun_map.level_start = function (data)
	local tab = {}
	tab.event = "level_start"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "level_name", "string", data.name)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 当用户在游戏中通关时触 (关卡的名称, 是否通关)
event_fun_map.level_end = function (data)
	local tab = {}
	tab.event = "level_end"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "level_name", "string", data.name, fenge)
	add_parm(tab.parm, "success", "bool", data.success)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

-- 在用户加入群组（例如公会、团队或家庭）时记录此事件 (群组的 ID)
event_fun_map.join_group = function (data)
	local tab = {}
	tab.event = "join_group"
	tab.fg = fenge
	tab.parm = ""
	add_parm(tab.parm, "group_id", "string", data.id)
	sdkMgr:OnGGLogEvent( lua2json(tab) )
end

