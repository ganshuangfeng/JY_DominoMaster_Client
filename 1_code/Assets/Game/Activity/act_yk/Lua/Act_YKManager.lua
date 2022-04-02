-- 创建时间:2022-03-01
-- Act_YKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_YKManager = {}
local M = Act_YKManager
M.key = "act_yk"
GameModuleManager.ExtLoadLua(M.key, "Act_YKPanel")

local this
local lister

M.normal_task_id = 88
M.zz_task_id = 89

M.normal_shop_id   = 1031
M.zz_shop_id = 1032

local isQueryBaseInfo = false

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
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

    if parm.goto_scene_parm == "panel" then
        return Act_YKPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return  ACTIVITY_HINT_STATUS_ENUM.AT_Red
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
    lister["query_yueka_base_info_response"] = this.on_query_yueka_base_info_response
    lister["yueka_base_info_change_msg"] = this.on_yueka_base_info_change_msg
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_YKManager
	this.m_data = {}
    isQueryBaseInfo = false
	MakeLister()
    AddLister()
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

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryBaseInfo(isReset)
    if isReset then
        isQueryBaseInfo = false
    end
    if isQueryBaseInfo then
        Event.Brocast("model_yk_base_info_change")
    else
        Network.SendRequest("query_yueka_base_info")
        isQueryBaseInfo = true
    end
end

function M.InitData()
    this.m_data.isBuyNormal = false
    this.m_data.isBuyZZ = false
    this.m_data.remainTimeNormal = 0
    this.m_data.remainTimeZZ = 0
end

function M.HandleData(data)
    if data.is_buy_yueka1 then
        this.m_data.isBuyNormal = (data.is_buy_yueka1 == 1)
    end
    if data.is_buy_yueka2 then
        this.m_data.isBuyZZ = (data.is_buy_yueka2 == 1)
    end
    if data.task_over_time then
        this.m_data.remainTimeNormal = basefunc.get_today_id(data.task_over_time, os.time() + 5)
    end
    if data.task_over_time2 then
        this.m_data.remainTimeZZ = basefunc.get_today_id(data.task_over_time2, os.time() + 5)
    end
    -- dump(this.m_data.remainTimeNormal, "remainTimeNormal")
    -- dump(this.m_data.remainTimeZZ, "remainTimeZZ")
    if this.m_data.remainTimeNormal < 0 then
        this.m_data.isBuyNormal = false
        this.m_data.remainTimeNormal = 0
    end
    if this.m_data.remainTimeZZ < 0 then
        this.m_data.isBuyZZ = false
        this.m_data.remainTimeZZ = 0
    end
    Event.Brocast("model_yk_base_info_change")
end

function M.on_query_yueka_base_info_response(_, data)
    dump(data, "<color=white>+++++月卡:on_query_yueka_base_info_response+++++</color>")
    if data.result == 0 then
        M.HandleData(data)
    end
end

function M.on_yueka_base_info_change_msg(_, data)
    dump(data, "<color=white>+++++月卡:on_yueka_base_info_change_msg+++++</color>")
    M.HandleData(data)
end

function M.on_model_task_change_msg(data)
	-- dump(data, "<color=white>+++++月卡:on_model_task_change_msg+++++</color>")
    if data.id == M.normal_task_id or data.id == M.zz_task_id then
        M.QueryBaseInfo(true)
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.GetAwardStatus(key)
    local task_id
    if key == "normal" then
        task_id = M.normal_task_id
    elseif key == "zz" then
        task_id = M.zz_task_id
    end
    local taskData = GameTaskManager.GetTaskDataByID(task_id)
    -- dump(taskData, "<color=white>taskData</color>")
    if taskData then
        return taskData.award_status
    end
    return 0
end

function M.IsCanGetAward()
    if M.GetAwardStatus("normal") == 1 then
        return true
    end
    if M.GetAwardStatus("zz") == 1 then
        return true
    end
    return false
end

function M.GetData()
    return this.m_data
end
