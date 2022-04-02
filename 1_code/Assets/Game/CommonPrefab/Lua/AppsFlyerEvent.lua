--[[

参数说明

参数名称    说明  示例值 媒体渠道
af_status   归因类型有效值：自然非自然   非自然 全部
af_message  任意文本    自然激活/错误消息   全部
media_source    媒体渠道名称。这是 AF 归因链接的“pid’”参数  inmobi_inttapjoy_intFacebook 注意代理商带来的激活，媒体渠道信息默认被隐藏，值为“null”。   全部
campaign    广告系列名称（AppsFlyer 归因链接的 ‘C’ 参数或 Facebook 的广告系列名称）    Ad1/camp123 全部
clickid 点击 ID 或交易 ID    123456/xsfd234  全部
af_siteid   子渠道 ID（通常用于优化）  子渠道1    全部
af_sub1 额外参数    一些参数    全部
af_sub2 额外参数        全部
af_sub3 额外参数        全部
af_sub4 额外参数        全部
af_sub5 额外参数        全部
af_keywords 在搜索广告系列中用于搜索的关键字。例如：Google Search 广告系列      全部
click_time  点击日期&时间（毫秒） （UTC）   2014-01-08 00:07:53.233 UTC 全部
install_time    归因转换日期&时间（毫秒）（UTC）  2014-01-08 00:12:51.701 UTC 全部
agency  代理或 PMD带来的激活    nanigans    全部
is_first_launch 首次启动时为 True，之后为 False   true    全部
is_fb   标记表明此安装归因于 Facebook。值：true/false    true    Facebook
ad_id   Facebook 的唯一广告标识号码  6012740800279   Facebook
campaign_id 广告系列活动ID    6012700005123   全部
广告集 Facebook 的广告组名称 US - 18+    Facebook
adset_id    Facebook 广告组 ID 6099800005123   Facebook
orig_cost   安装的成本（可以是任何货币）  1.5 全部
cost_cents_USD  货币换算后，以美分表示的成本值 150（美分） 全部
retargeting_conversion_type 再营销转化类型 再归因（re-attribution） / 再互动（re-engagement）    全部

--]]
AppsFlyerEvent = {}

local event_fun_map = {}
local is_on_off = true -- 开关
local fenge = "#"

local app_dev_key = "93viJ9toj3aNrd5piaGXAR"

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
    lister["game_all_manage_event"] = AppsFlyerEvent.on_apps_flyer_event
end

function AppsFlyerEvent.Init()
	if not is_on_off then return end

	AppsFlyerEvent.Exit()

    this = AppsFlyerEvent
    is_run_start = 0
    MakeLister()
    AddLister()

-- 例子
-- {
--     "retargeting_conversion_type": "none",
--     "is_incentivized": "false",
--     "orig_cost": "0.0",
--     "is_first_launch": false, -- 是否是首次打开
--     "af_click_lookback": "7d",
--     "iscache": true,
--     "click_time": "2022-01-24 03:07:01.782", -- 点击时间
--     "match_type": "gp_referrer",
--     "install_time": "2022-01-24 03:08:35.855", -- 安装时间
--     "media_source": "appsflyer_sdk_test_int", -- 媒体来源
--     "clickid": "7e050a0a-f07a-47e6-b1ce-cee9605c9bf7",
--     "af_status": "Non-organic",
--     "cost_cents_USD": "0",
--     "campaign": "None",
--     "is_retargeting": "false",
--     "cly_game_conversion_type": "Non-Organic",
--     "result": 0
-- }

	sdkMgr:AddOnAFConversionCallback(function (json_data)
        dump(json_data, "<color=red>=== AddOnAFConversionCallback ===</color>")
    end)

    dump(sdkMgr:GetAFConversionJsonData(""), "GetAFConversionJsonData")

    return this
end
function AppsFlyerEvent.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

------------------------------
-- Event function
------------------------------
function AppsFlyerEvent.on_apps_flyer_event(data)
	dump(data, "<color=red><size=15>AAAAA AppsFlyerEvent on_apps_flyer_event AAAAA</size></color>")
    if is_on_off and data.event and event_fun_map[data.event] then
        event_fun_map[data.event](data)
    end
end

-- 事件
local add_parm = function (parm, kk, tt, vv, e)
    e = e or ""
    parm = parm .. kk .. fenge .. tt .. fenge .. vv .. e
end
-- 当用户完成注册过程时
event_fun_map.sign_up = function (data)
    local tab = {}
    tab.event = "af_complete_registration"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_registration_method", "string", data.method)
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 每当用户成功登录时
event_fun_map.login = function (data)
    local tab = {}
    tab.event = "af_login"
    tab.fg = fenge
    tab.parm = ""
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 当用户成功购买后登录到感谢页面时
event_fun_map.pay_finish = function (data)
    local tab = {}
    tab.event = "af_purchase"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_revenue", "int", data.price, fenge)--收入
    add_parm(tab.parm, "af_currency", "string", data.hb, fenge)--货币代码
    add_parm(tab.parm, "af_quantity", "int", data.asset_value, fenge)--道具数量
    add_parm(tab.parm, "af_content_id", "string", data.shop_id, fenge)--item id
    add_parm(tab.parm, "af_order_id", "string", data.order_id, fenge)--订单id
    add_parm(tab.parm, "af_receipt_id", "string", data.transaction_id)--收据id
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 当用户在游戏中升级时触发
event_fun_map.level_up = function (data)
    local tab = {}
    tab.event = "af_level_achieved"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_level", "string", data.level, fenge)--等级
    add_parm(tab.parm, "af_score", "string", data.score)--分数
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 教程
event_fun_map.tutorial = function (data)
    local tab = {}
    tab.event = "af_tutorial_completion"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_success", "string", data.success, fenge)--是否完成
    add_parm(tab.parm, "af_tutorial_id", "string", data.id, fenge)--教程id
    add_parm(tab.parm, "af_content", "string", data.name)--教程名字
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 当用户分享内容时触发
event_fun_map.share = function (data)
    local tab = {}
    tab.event = "af_share"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_description", "string", data.type, fenge)--原因
    add_parm(tab.parm, "platform", "string", data.method)--平台
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end
-- 用户邀请他们的朋友下载和安装应用程序
event_fun_map.invite = function (data)
    local tab = {}
    tab.event = "af_invite"
    tab.fg = fenge
    tab.parm = ""
    add_parm(tab.parm, "af_description", "string", a)--邀请的背景
    sdkMgr:OnAFLogEvent( lua2json(tab) )
end

