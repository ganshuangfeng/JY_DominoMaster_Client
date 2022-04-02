-- 创建时间:2022-03-17
-- Act_YJCJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_YJCJManager = {}
local M = Act_YJCJManager
M.key = "act_yjcj"

local config = GameModuleManager.ExtLoadLua(M.key, "act_yjcj_config")
GameModuleManager.ExtLoadLua(M.key, "Act_YJCJPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_YJCJEnter")
GameModuleManager.ExtLoadLua(M.key, "Act_YJCJItem")
GameModuleManager.ExtLoadLua(M.key, "Act_YJCJRealGet")

local this
local lister

M.task_id = 123
M.box_change_id_below5 = 1001
M.box_change_id_5above5 = {1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011}

M.endTime = 1648483199

-- 是否有活动 
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if os.time() > M.endTime then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_yjcj_20220322"
    if _permission_key then
        local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint = true})
        if not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return Act_YJCJEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then

    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanLottery() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["query_box_exchange_info_response"] = this.on_query_box_exchange_info_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_YJCJManager
	this.m_data = {}
    this.m_award_cfg = {}
    this.m_award_view_list = {}
    this.m_asset_ids = {}
    this.m_data.geted_index_below5 = {}
	MakeLister()
    AddLister()
    M.InitConfig()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.InitConfig()
    this.m_award_cfg = config.award
    for i = 1, #this.m_award_cfg do
        local view_index = this.m_award_cfg[i].view_index
        this.m_award_view_list[view_index] = i

        if this.m_award_cfg[i].asset_id then
            local asset_id = this.m_award_cfg[i].asset_id
            this.m_asset_ids[asset_id] = i
        end
    end
end

function M.GetAwardCfgFromId(id)
    if this.m_award_cfg[id] then
        return this.m_award_cfg[id]
    end
    return 5
end

function M.GetAwardViewList()
    return this.m_award_view_list
end

function M.GetCurLv()
    local lv = 1
    local taskData = GameTaskManager.GetTaskDataByID(M.task_id)
    dump(taskData, "<color=white>taskData</color>")
    if taskData then
        local now_total_process = taskData.now_total_process
        lv = now_total_process + 1
    end
    return lv
end

function M.IsCannotGetTask()
    local taskData = GameTaskManager.GetTaskDataByID(M.task_id)
    if not taskData then
        return true
    end
end

function M.IsCanLottery()
    if M.IsCannotGetTask() then
        return false
    end
    local lv = M.GetCurLv()
    if lv > 14 then
        return false
    else
        if this.m_award_cfg[lv] then
            local consume = this.m_award_cfg[lv].consume
            local count = GameItemModel.GetItemCount("prop_point_common") 
            if count >= consume then
                return true
            end
        end
    end
end

function M.GetCurBoxChangeId(lv)
    if lv < 5 then
        return M.box_change_id_below5
    else
        return M.box_change_id_5above5[lv - 4]
    end
end

function M.GetAwardIdFromAssetId(id)
    if this.m_asset_ids[id] then
        return this.m_asset_ids[id]
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.on_query_box_exchange_info_response(_, data)
	dump(data, "<color=white>赢金抽奖:on_query_box_exchange_info_response</color>")
    if data.result == 0 then
        if data.id == M.box_change_id_below5 then
            if not table_is_null(data.exchange_record) then
                for k, v in pairs(data.exchange_record) do
                    this.m_data.geted_index_below5[v.id] = 1
                end
                dump(this.m_data.geted_index_below5, "<color=white> this.m_data.geted_index_below5</color>")
            end
            Event.Brocast("model_act_yxcj_box_exchange_info")
        end
    end
end

function M.on_model_task_change_msg(data)
    if data.id == M.task_id then
		M.SetHintState()
	end
end

function M.GetCurGetedListBelow5()
    return this.m_data.geted_index_below5
end

function M.OnReConnecteServerSucceed()
end
