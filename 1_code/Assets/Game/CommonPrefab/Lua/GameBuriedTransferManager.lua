-- 创建时间:2022-01-05
-- 埋点事件中转站

GameBuriedTransferManager = {}
local M = GameBuriedTransferManager

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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["model_level_data_change"] = M.model_level_data_change
    lister["model_pay_order_finish_msg"] = M.model_pay_order_finish_msg
    lister["model_share_finish_msg"] = M.model_share_finish_msg
    lister["model_tutorial_msg"] = M.model_tutorial_msg
end

function M.Init()
	M.Exit()

    this = M
    MakeLister()
    AddLister()
    return this
end
function M.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
		if result == 0 then
            if MainModel.UserInfo.first_login == 1 then
                Event.Brocast("game_all_manage_event", {event="sign_up", method=MainModel.UserInfo.channel_type})
            end
            Event.Brocast("game_all_manage_event", {event="login", method=MainModel.UserInfo.channel_type})
        end
	end
end

function M.model_level_data_change(data)
    Event.Brocast("game_all_manage_event", {event="level_up", level=data.level, score=data.score, name=MainModel.UserInfo.name})
end

function M.model_pay_order_finish_msg(data)
    if not data.config then
        return
    end
    dump(data)
    local asset_value = 0
    if type(data.config.buy_asset_count) == "table" then
        asset_value = data.config.buy_asset_count[1]
    else
        asset_value = data.config.buy_asset_count
    end
    local asset_name
    if data.config.type then
        asset_name = data.config.type
    else
        asset_name = data.config.shop_type or "-"
    end
    
    Event.Brocast("game_all_manage_event", {event="pay_finish", 
                                                            price=data.config.price, 
                                                            order_id=data.order_id,
                                                            hb = GLC.HB,
                                                            asset_value=asset_value,
                                                            asset_name=asset_name,
                                                            shop_id=data.config.id,
                                                            transaction_id=data.order_id,})
end

function M.model_share_finish_msg(data)
    Event.Brocast("game_all_manage_event", {event="share", type=data.type, method=data.method})
end

function M.model_tutorial_msg(data)
    if data.id == 1 then
        Event.Brocast("game_all_manage_event", {event="tutorial_begin"})
    elseif data.id == -1 then
        Event.Brocast("game_all_manage_event", {event="tutorial_complete"})
    end
    Event.Brocast("game_all_manage_event", {event="tutorial", success=data.success, id=data.id, name=data.name})
end

