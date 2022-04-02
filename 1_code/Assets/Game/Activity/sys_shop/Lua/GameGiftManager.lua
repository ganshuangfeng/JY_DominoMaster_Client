-- 创建时间:2022-01-06
-- GameGiftManager 管理器

GameGiftManager = {}
local M = GameGiftManager
local basefunc = require "Game/Common/basefunc"

local this
local lister

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    --请求单个礼包状态
    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status
    --请求所有礼包状态
    -- lister["query_all_gift_bag_status_response"] = this.on_query_all_gift_bag_status
    --礼包数量，针对那种全服礼包有数量限制的
    lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    --礼包权限发生改变时
    lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg
    --请求一个列表的礼包状态
    lister["query_gift_bag_status_by_ids_response"] = this.on_query_gift_bag_status_by_ids_response
    --购买完成
    lister["ReceivePayOrderMsg"] = this.OnReceivePayOrderMsg
end

function M.Init(config)
	M.Exit()

	this = GameGiftManager
    this.m_cfg = {}
    this.m_cfg.mDictionary = {}
	this.m_data = {}
    this.m_data.mDictionary = {}
	MakeLister()
    AddLister()
    M.InitConfig(config)
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        this.m_data.mDictionary = MainModel.UserInfo.GiftShopStatus
        dump(this.m_data.mDictionary, "<color=white>GameGiftManager.m_data.mDictionary</color>")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitConfig(config)
    if table_is_null(config.gift_bag) then
        return
    end 
    for i = 1, #config.gift_bag do
        local gift = config.gift_bag[i]
        if gift.on_off == 1 then
            this.m_cfg.mDictionary[gift.id] = gift
        end
    end
end

--获取礼包配置
function M.GetGiftConfig(gift_id)
    if this.m_cfg.mDictionary[gift_id] then
        return this.m_cfg.mDictionary[gift_id]
    end
end

--获取礼包数据
function M.GetGiftData(gift_id)
    if this.m_data.mDictionary[gift_id] then
        return this.m_data.mDictionary[gift_id]
    end
end

--获取礼包剩余次数
function M.GetGidftRemainTime(gift_id)
    if this.m_data.mDictionary[gift_id] then
        return  this.m_data.mDictionary[gift_id].remain_time or 0
    end
    return 0
end

--获取礼包结束时间
function M.GetGiftEndTime(gift_id)
    if this.m_data.mDictionary[gift_id] then
        local data = this.m_data.mDictionary[gift_id]
        local permit_time = tonumber(data.permit_time) or 0
        local permit_start_time = tonumber(data.permit_start_time) or 0
        local permit_end_time = permit_time + permit_start_time
        return math.max(0, permit_end_time)
    end
    return 0 
end

--礼包是否可以购买
function M.IsCanBuytGift(gift_id)
    if not this.m_data.mDictionary[gift_id] then
        return false
    end
    local data = this.m_data.mDictionary[gift_id]
    if data.status == 1 then
        if data.permit_start_time then
            local endTime = M.GetGiftEndTime(gift_id)
            return os.time() <= endTime
        else
            return true
        end
    end
end

function M.SetGiftData(data)
    local id = data.gift_bag_id
    if not this.m_data.mDictionary[id] then
        this.m_data.mDictionary[id] = {}
    end
    -- dump("<color=white>00000000000000000000</color>")
    -- dump(debug.traceback())
    --0 不可购买 1 可购买
    if data.status then
        -- dump("<color=white>11111111111111111111111111</color>")
        this.m_data.mDictionary[id].status = data.status
    end
    if data.permit_time then
        this.m_data.mDictionary[id].permit_time = data.permit_time --权限持续时间
    end
    if data.permit_start_time then
        this.m_data.mDictionary[id].permit_start_time = data.permit_start_time --权限开始时间
    end
    if data.time then
        this.m_data.mDictionary[id].time = data.time --上次购买时间
    end
    if data.remain_time then
        this.m_data.mDictionary[id].remain_time = data.remain_time --剩余数量
    end
    if data.num then
        this.m_data.mDictionary[id].num = v.num
    end
    Event.Brocast("model_gift_data_change_msg", id)    
end

function M.on_query_gift_bag_status(_, data)
    if data.result == 0 then
        M.SetGiftData(data)
    end
end

-- function M.on_query_all_gift_bag_status(_, data)
--     dump(data, "<color=red>+++++初始化的礼包:on_query_all_gift_bag_status+++++</color>")
--     for k,v in ipairs(data.gift_bag_data) do
--         M.SetGiftData(v)
--     end
-- end

function M.on_query_gift_bag_num_response(_, data)
    if data.result == 0 then
        M.SetGiftData(data)
    end
end

function M.on_gift_bag_status_change_msg(_, data)
    dump(data, "<color=white>+++++on_gift_bag_status_change_msg++++++</color>")
    M.SetGiftData(data)
end

function M.on_query_gift_bag_status_by_ids_response(_, data)
    if data.result == 0 then  
        for i = 1,#data.gift_bag_data do
            M.SetGiftData(data.gift_bag_data[i])
        end
    end
end

function M.OnReceivePayOrderMsg(data)
    dump(data, "<color=white>+++++OnReceivePayOrderMsg++++++</color>")
    if data.result == 0 then
        if this.m_data.mDictionary[data.goods_id] then
            Network.SendRequest("query_gift_bag_status",{gift_bag_id = data.goods_id})
        end
    end
end