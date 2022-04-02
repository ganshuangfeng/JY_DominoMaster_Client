-- 创建时间:2021-06-02

GameTaskManager = {}
local M = GameTaskManager
local basefunc = require "Game/Common/basefunc"

local this
local lister
local task_server_config = require "Game/CommonPrefab/Lua/task_server"
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

    lister["task_data_init_msg"] = this.on_task_data_init_msg
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["task_change_msg"] = this.on_task_change_msg
end

function M.Init()
	M.Exit()
	print("<color=red>初始化任务系统</color>")
    this = M
    this.data = {}
    MakeLister()
    AddLister()
end
function M.Exit()
	if this then
        RemoveLister()
		this = nil
	end
end
--正常登录成功
function M.OnLoginResponse(result)
    if result == 0 then
        print("<color=red>AAA query_task_data</color>")
        Network.SendRequest("query_task_data", nil)
    end
end
--断线重连后登录成功
function M.OnReConnecteServerSucceed(result)
end

-- 获取任务数据 GameTaskManager.GetTaskDataByID(1)
function M.GetTaskDataByID(id)
    if id then
        if this.data and this.data.task_list and next(this.data.task_list) then
            return this.data.task_list[ id ]
        end
	end
end

-- 单任务多阶段的状态
function M.GetTaskStatusByData(taskData, len)
    local states = basefunc.decode_task_award_status(taskData.award_get_status)
    states = basefunc.decode_all_task_award_status(states, taskData, len)
    return states
end

function M.GetTaskStatusByID(id, len)
    local taskData = M.GetTaskDataByID(id)
    if taskData then
        return M.GetTaskStatusByData(taskData, len)
    end
end

function M.task_process_int_convent_string(task_item)
    if task_item then
        if task_item.task_condition_type and 
            task_item.task_condition_type == "charge_any" or
            task_item.task_condition_type == "freestyle_settle_exchange_hongbao" or 
            task_item.task_condition_type == "pre_charge_any" then
            if task_item.now_total_process then
                if not task_item.m_now_total_process then
                    task_item.now_total_process = tonumber(task_item.now_total_process) / 100
                    task_item.m_now_total_process = task_item.now_total_process
                end
            end
            if task_item.now_process then
                if not task_item.m_now_process then
                    task_item.now_process = tonumber(task_item.now_process) / 100
                    task_item.m_now_process = task_item.now_process
                end
            end
            if task_item.need_process then
                if not task_item.m_need_process then
                    task_item.need_process = tonumber(task_item.need_process) / 100
                    task_item.m_need_process = task_item.need_process
                end
            end
        else
            if task_item.now_total_process then
                task_item.now_total_process = tonumber(task_item.now_total_process)
            end
            if task_item.now_process then
                task_item.now_process = tonumber(task_item.now_process)
            end
            if task_item.need_process then
                task_item.need_process = tonumber(task_item.need_process)
            end
        end
        if task_item.end_valid_time then
            task_item.end_valid_time = tonumber(task_item.end_valid_time)
        end
        if task_item.over_time then
            task_item.over_time = tonumber(task_item.over_time)
        end
        if task_item.start_valid_time then
            task_item.start_valid_time = tonumber(task_item.start_valid_time)
        end
    end
end

function M.on_task_data_init_msg(_,data)
    dump(data,"<color=yellow>任务 on_task_data_init_msg</color>")
    this.data.task_list = this.data.task_list or {}
    for k,v in ipairs(data.task_item) do
        M.task_process_int_convent_string(v)
        this.data.task_list[v.id] = v
    end
    Event.Brocast("model_query_task_data_response")
end

function M.on_query_one_task_data_response(_, data)
    if data.result == 0 and data.task_data then
        M.task_process_int_convent_string(data.task_data)
        this.data.task_list = this.data.task_list or {}
        this.data.task_list[data.task_data.id] = data.task_data
	    Event.Brocast("model_task_data_change_msg", {tag = "add", id = data.task_data.id})
        Event.Brocast("model_query_one_task_data_response_proto_name","model_query_one_task_data_response_proto_name", data.task_data)
    end
end

function M.on_task_change_msg(_, data)
    -- dump(data, "<color=yellow>任务改变</color>")
    M.task_process_int_convent_string( data.task_item)
    this.data.task_list = this.data.task_list or {}
    this.data.task_list[data.task_item.id] = data.task_item
    Event.Brocast("model_task_data_change_msg", {tag = "chg", id = data.task_item.id})
    Event.Brocast("model_task_change_msg",data.task_item)
    Event.Brocast("model_task_change_msg_proto_name","model_task_change_msg_proto_name",data.task_item)
end

function M.task_item_change_msg(_, data)
    if not data or not data.task_item or not next(data.task_item) then return end
    for k,v in pairs(data.task_item) do
        M.task_process_int_convent_string(v)
        if v.change_type == "add" then
            Network.SendRequest("query_one_task_data", {task_id = v.task_id})
        elseif v.change_type == "delete" then
            if this.data.task_list then
                this.data.task_list[v.task_id] = nil
            end
		    Event.Brocast("model_task_data_change_msg", {tag = "del", id = v.task_id})
        end
    end
end

--根据任务ID获取相关信息
function M.GetTaskConfigByTaskID(task_id)
    local data = {}
    data.task = {}
    for k ,v in pairs(task_server_config.task) do
        if v and v.id == task_id then
            data.task = v
            break
        end
    end

    if not next(data.task) then
        print( string.format("<color=red>没有找到这个ID:%s的数据</color>",task_id))
        return
    end
    data.process_data = {}
    for k ,v in pairs(task_server_config.process_data) do
        if v and v.id == task_id then
            data.process_data = v
            break
        end
    end
    data.award_data = {}
    local award_ids = data.process_data.awards
    if type(award_ids) == "number" then
        award_ids = {award_ids}
    end
    for i = 1,#award_ids do
        for k ,v in pairs(task_server_config.award_data) do
            if v and v.award_id == award_ids[i] then
                data.award_data[v.award_id] = v
            end 
        end
    end
    return data
end