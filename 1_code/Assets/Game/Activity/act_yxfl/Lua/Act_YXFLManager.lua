-- 创建时间:2022-03-16
-- Act_YXFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_YXFLManager = {}
local M = Act_YXFLManager
M.key = "act_yxfl"

local config = GameModuleManager.ExtLoadLua(M.key, "act_yxfl_config")
GameModuleManager.ExtLoadLua(M.key, "Act_YXFLPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_YXFLItem")

local this
local lister

local overTime

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if M.IsTaskClose() then
        return false
    else
        if overtime then
            if os.time() > overTime then
                return false
            end
        end
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
    dump(parm, "<color=white> Act_YXFLManager GotoUI</color>")
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return Act_YXFLPanel.Create(parm.parent) 
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState()
    dump(M.IsHint(), "<color=red>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
    if M.IsHint() then
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
end

function M.Init()
	M.Exit()

	this = Act_YXFLManager
	this.m_data = {}
    this.m_cfg = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitConfig()
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
    this.m_cfg.all_task_cfg = {}
    this.m_cfg.care_tasks = {}
    for i = 1, #config.task do
        this.m_cfg.all_task_cfg[i] = config.task[i]
        local task_id = config.task[i].task_id
        if not this.m_cfg.care_tasks[task_id] then
            this.m_cfg.care_tasks[task_id] = 1
        end
    end
    dump(this.m_cfg.all_task_cfg, "<color=white>this.m_cfg.all_task_cfg</color>")
    dump(this.m_cfg.care_tasks, "<color=white>this.m_cfg.care_tasks</color>")
end

function M.IsHint()
    local tasks = this.m_cfg.care_tasks
    if not table_is_null(tasks) then
        for k, v in pairs(tasks) do
            local taskData = GameTaskManager.GetTaskDataByID(k) or { award_status = 0 }
            if taskData.award_status == 1 then
                return true
            end
            if taskData.over_time then
                overTime = taskData.over_time
            end
        end
    end
    return false
end

function M.GetTaskCfg()
    return this.m_cfg.all_task_cfg
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.on_model_query_task_data_response()
    Event.Brocast("global_hint_state_change_msg", {key = M.key})
end

function M.on_model_task_change_msg(data)
    dump(data, "<color=white>游戏福利 on_model_task_change_msg</color>")
    if table_is_null(this.m_cfg.care_tasks) then
        return
    end
    if this.m_cfg.care_tasks[data.id] then
        Event.Brocast("mode_act_yxfl_task_change")
        Event.Brocast("global_hint_state_change_msg", {key = M.key})
    end
end

function M.GetOverTime()
    if not overTime then
        local taskData = GameTaskManager.GetTaskDataByID(this.m_cfg.all_task_cfg[1].task_id)
        dump(taskData, "<color=white> taskData </color>")
        if taskData and taskData.over_time then
            overTime = taskData.over_time
        end
    end
    return overTime
end

function M.IsTaskClose()
    local taskData = GameTaskManager.GetTaskDataByID(this.m_cfg.all_task_cfg[1].task_id)
    if not taskData then
        return true
    else
        if not taskData.over_time or taskData.over_time < os.time() then
            return true
        end
    end
end

function M.OnReConnecteServerSucceed()
end
