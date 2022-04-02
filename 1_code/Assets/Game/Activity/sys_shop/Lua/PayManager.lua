-- 创建时间:2021-12-07
local TAG = "TrivialDrive(Lua):"
local is_debug = false

PayManager = {}
local this = nil

local lister
local function MakeLister()
    lister={}
end
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

function PayManager.Init()
	PayManager.Exit()

	this = PayManager
	this.data = {}
	MakeLister()
	AddLister()

    PayManager.updateTimer = Timer.New(PayManager.AutoSendOrderToServer, 3, -1, true, true)
    PayManager.updateTimer:Start()

	PayManager.GGInit()
end

function PayManager.Exit()
	if this then
        if PayManager.updateTimer then
            PayManager.updateTimer:Stop()
        end
        PayManager.updateTimer = nil

        if PayManager.connectionTimer then
            PayManager.connectionTimer:Stop()
        end
        PayManager.connectionTimer = nil
		RemoveLister()
	end
end

function PayManager.AutoSendOrderToServer()
    if PayManager.channel_order_id_map and next(PayManager.channel_order_id_map) then
        local a = {}
        for k,v in pairs(PayManager.channel_order_id_map) do
            local b = {}
            b.order_id = k
            b.channel_order_id = v
            a[#a + 1] = b
        end
        PayManager.channel_order_id_map = {}
        Network.SendRequest("modify_order_channel_order_id", {order_data=a}, function (data)
            if data.result ~= 0 then
                for k,v in ipairs(a) do
                    PayManager.channel_order_id_map[a.order_id] = a.channel_order_id
                end
            end
        end)
    end

    if PayManager.cache_google_consume_map and next(PayManager.cache_google_consume_map) then
        for k,v in pairs(PayManager.cache_google_consume_map) do
            PayManager.cache_google_consume_map[k] = nil
            PayManager.GGconsume(v)
            return
        end
        Network.SendRequest("modify_order_channel_order_id", {order_data=a}, function (data)
            if data.result ~= 0 then
                for k,v in ipairs(a) do
                    PayManager.channel_order_id_map[a.order_id] = a.channel_order_id
                end
            end
        end)
    end
end

--[[
支付方式类型：
    indobank 印尼网银
    indoovo  印尼ovo
    google   google
--]]
function PayManager.Pay(config, ext_data)
	ext_data = ext_data or {}
	dump(config, "<color=green>PayTypePopPrefab.Create config </color>")
    dump(ext_data, "<color=green>PayTypePopPrefab.Create ext_data </color>")

    if ext_data.channel_type == "google" then
        PayManager.GGPay(config, ext_data)
    else
        PayManager.WebPay(config, ext_data)
    end
    Event.Brocast("global_pay_msg", config)
end


--################################################################################

-- Google Play

--################################################################################
function PayManager.CacheGGSkus(sku, data)
    PayManager.google_sku_map[sku] = data    
end

function PayManager.SendGGConnection()
    if not sdkMgr:OnGGIsReady() then
        if PayManager.is_gg_send_connection then
            PayManager.is_gg_send_connection = false
            sdkMgr:OnGGConnection()
            PayManager.gg_connection_num = PayManager.gg_connection_num + 1
        end
    else
        if PayManager.connectionTimer then
            PayManager.connectionTimer:Stop()
        end
        PayManager.connectionTimer = nil
        PayManager.is_gg_service_disconnected = false
        HintPanel.Create(1, GLL.GetTx(81064))
        Event.Brocast("bsds_send_power",{key = "google_pay9", param={param1=MainModel.UserInfo.login_id, param2=PayManager.gg_connection_num}})
    end
end

function PayManager.GGInit()
    PayManager.google_sku_map = {}
    PayManager.google_sku_cur = nil
    PayManager.is_gg_service_disconnected = false

	sdkMgr:AddOnGGBuyResultCallback(function (json_data)
		dump(json_data, TAG.."<color=green>AddOnGGBuyResultCallback json_data </color>")
		local tbl = json2lua(json_data)
		dump(tbl, TAG.."<color=green>AddOnGGBuyResultCallback tbl </color>")
		if tbl == 0 then
		else
			HintPanel.Create(1, tbl.errMsg)
		end
	end)
	sdkMgr:AddSkuStateFromPurchaseCallback(function (json_data)
		dump(json_data, TAG.."<color=green>AddSkuStateFromPurchaseCallback json_data </color>")
		local tbl = json2lua(json_data)
        if not tbl then
            print(TAG.."<color=green>AddSkuStateFromPurchaseCallback tbl=null </color>")
            return
        end
        PayManager.CacheGGSkus(tbl.purchase_id, tbl)

		dump(tbl, TAG.."<color=green>AddSkuStateFromPurchaseCallback HHHHH </color>")
		if tonumber(tbl.code) == 2 or tonumber(tbl.code) == 3 then
		    PayManager.GGconsume(tbl)
        else
            -- 同步第三方订单号
            if tbl.order_id and tbl.google_order_id then
                PayManager.channel_order_id_map = PayManager.channel_order_id_map or {}
                PayManager.channel_order_id_map[tbl.order_id] = tbl.google_order_id
            end
		end
	end)

	sdkMgr:AddGoogleComCallback(function (json_data)
		dump(json_data, TAG.."<color=green>AddGoogleComCallback json_data </color>")
		local tbl = json2lua(json_data)
		dump(tbl, TAG.."<color=green>AddGoogleComCallback tbl </color>")
		if tbl and tbl.msg then
			if tbl.msg == "review" or tbl.msg == "launch_review" then
                Event.Brocast("act_google_review_msg", tbl)
			elseif tbl.msg == "onPurchasesUpdated" or tbl.msg == "onSkuDetailsResponse" then
                if PayManager.google_sku_cur then
                    Event.Brocast("bsds_send_power",{key = "google_pay6", param={param1=MainModel.UserInfo.login_id, param2=PayManager.google_sku_cur, param3=tbl.responseCode}})
                end
            elseif tbl.msg == "launchBillingFlow" then
                Event.Brocast("bsds_send_power",{key = "google_pay7", param={param1=MainModel.UserInfo.login_id, param2=tbl.sku, param3=tbl.result}})
            elseif tbl.msg == "startConnection" then
                PayManager.is_gg_send_connection = true
            else
			end
		end
	end)


	local init_data = {}
	init_data.INAPP_SKUS = SysShopManager.GetProductIdsToString("#")
	init_data.AUTO_CONSUME_SKUS = "gas"
	init_data.SUBSCRIPTION_SKUS = "infinite_gas_monthly#infinite_gas_yearly"
	sdkMgr:GGInit( lua2json(init_data) )
end
local consume_map = {}
-- 消费google商品
function PayManager.GGconsume(data)
    if consume_map[data.order_id] then
        return
    end
    consume_map[data.order_id] = 1
    
    Network.SendRequest("deal_google_purchase", data, function(_data)
        dump(_data, TAG.."<color=green>PayTypePopPrefab order</color>")
        if _data.result == 1008 then
            consume_map[data.order_id] = nil
            PayManager.cache_google_consume_map = PayManager.cache_google_consume_map or {}
            PayManager.cache_google_consume_map[data.order_id] = data

            if PayManager.cur_pay_data then
                HintPanel.ErrorMsg(_data.result)
            end
        else
            sdkMgr:OnGGConsumeInappPurchase(data.purchase_id)

            if PayManager.cur_pay_data and data.order_id == PayManager.cur_pay_data.orderId then
                PayManager.cur_pay_data = nil
                Event.Brocast("bsds_send_power",{key = "google_pay4", param={param1=MainModel.UserInfo.login_id, param2=data.purchase_id, param3=data.order_id}})
            else
                Event.Brocast("bsds_send_power",{key = "google_pay4", param={param1=MainModel.UserInfo.login_id, param2=data.purchase_id, param3="补单"}})
            end
        end
    end)
end
-- 购买google商品
function PayManager.GGPay(config, ext_data)
    if not VersionManager.Off.google_md then
        if not sdkMgr:OnGGIsReady() then
            dump(_data, TAG.."OnGGIsReady ")
            if PayManager.is_gg_service_disconnected then
                HintPanel.Create(1, GLL.GetTx(81063))
            else
                Event.Brocast("bsds_send_power",{key = "google_pay8", param={param1=MainModel.UserInfo.login_id}})

                HintPanel.Create(1, GLL.GetTx(81062))
                PayManager.is_gg_service_disconnected = true
                PayManager.is_gg_send_connection = true
                PayManager.gg_connection_num = 1
                PayManager.connectionTimer = Timer.New(PayManager.SendGGConnection, 1, -1, true, true)
                PayManager.connectionTimer:Start()
                PayManager.SendGGConnection()
            end
            return
        end

    end

    PayManager.google_sku_cur = config.product_id
    if PayManager.google_sku_map[config.product_id] and PayManager.google_sku_map[config.product_id].code == 1 then
        dump(_data, TAG.."GGPay AA 11")
        local gg = PayManager.google_sku_map[config.product_id]
        Event.Brocast("bsds_send_power",{key = "google_pay5", param={param1=MainModel.UserInfo.login_id, param2=config.purchase_id, param3=gg.order_id}})
        local lua_tbl = {}
        lua_tbl.productId = config.product_id
        lua_tbl.orderId = gg.order_id
        sdkMgr:GGBuy(lua2json(lua_tbl))
        return
    end
	local request = {}
    request.goods_id = config.id
    request.channel_type = ext_data.channel_type
    request.geturl = "n"
    request.convert = ext_data.convert
    dump(request, TAG.."<color=green>PayManager.Pay GGPay </color>")

    local tt = os.clock()
    Event.Brocast("bsds_send_power",{key = "google_pay1", param={param1=MainModel.UserInfo.login_id, param2=config.product_id}})
    Network.SendRequest(
        "google_create_pay_order",
        request,
        "",
        function(_data)
            Event.Brocast("bsds_send_power",{key = "google_pay2", param={param1=MainModel.UserInfo.login_id, param2=config.product_id, param3="r=".._data.result.."#t="..(os.clock()-tt)}})
            dump(_data, TAG.."<color=green>PayTypePopPrefab order</color>")
            dump(config, TAG.."<color=green>PayTypePopPrefab config</color>")
            if _data.result == 0 then
                Event.Brocast("bsds_send_power",{key = "google_pay3", param={param1=MainModel.UserInfo.login_id, param2=config.product_id, param3=_data.order_id}})
            	MainModel.AddOrderData(_data.order_id, config, {channel_type="Google"})
                local lua_tbl = {}
                lua_tbl.productId = config.product_id
                lua_tbl.orderId = _data.order_id
                PayManager.cur_pay_data = lua_tbl
                sdkMgr:GGBuy(lua2json(lua_tbl))
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end


--################################################################################

-- Web Play

--################################################################################

-- Web方式购买
function PayManager.WebPay(config, ext_data)
	local request = {}
    request.goods_id = config.id
    request.channel_type = ext_data.channel_type
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = ext_data.convert
    dump(request, TAG.."<color=green>PayManager.Pay WebPay </color>")

    Network.SendRequest(
        "create_pay_order",
        request,
        "",
        function(_data)
            dump(_data, TAG.."<color=green>WebPay PayTypePopPrefab order</color>")
            if _data.result == 0 then
                MainModel.AddOrderData(_data.order_id, config, {channel_type=channel_type})

                if ext_data.createcall then
                    ext_data.createcall(_data.result)
                end
                MainModel.pay_url = _data.url or MainModel.pay_url
                MainModel.pay_channel_type = channel_type

                local url = string.gsub(MainModel.pay_url, "@(%g-)@", {
                    order_id=_data.order_id,
                    child_channel=channel_type,
                })
                dump(url, "pay url")
                UnityEngine.Application.OpenURL(url)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end