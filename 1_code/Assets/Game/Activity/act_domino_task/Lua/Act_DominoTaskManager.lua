-- 创建时间:2022-01-10
-- Act_DominoTaskManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_DominoTaskManager = {}
local M = Act_DominoTaskManager
M.key = "act_domino_task"

local config = GameModuleManager.ExtLoadLua(M.key, "act_domino_task_config")
GameModuleManager.ExtLoadLua(M.key, "Act_DominoTaskPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_DominoTaskEnter")

local this
local lister

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
    if parm.goto_scene_parm == "enter" then
        return Act_DominoTaskEnter.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
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
end

function M.Init()
	M.Exit()

	this = Act_DominoTaskManager
	this.m_data = {}
    this.m_cfg = {}
	MakeLister()
    AddLister()
	-- M.InitUIConfig()
    M.InitConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
-- function M.InitUIConfig()
--     this.UIConfig = {}
-- end

function M.InitConfig()
    this.m_cfg.weekday_time_list = {}
    this.m_cfg.weekend_time_list = {}

    local convertToList = function(list, time)
        local makeTime = function(index)
            local t = config.time[index]
            list[#list + 1] = t
        end
        if type(time) == "table" then
            for i = 1, #time do
                makeTime(time[i])
            end
        else
            makeTime(time)
        end
    end

    local weekday_time = config.base.info.weekday_time
    convertToList(this.m_cfg.weekday_time_list, weekday_time)
    local weekend_time = config.base.info.weekend_time
    convertToList(this.m_cfg.weekend_time_list, weekend_time)

    this.m_cfg.task = config.task
    this.m_cfg.game_task = config.game_task


    this.m_cfg.father_task_ids = {}
    for k,v in pairs(config.game_task) do
        this.m_cfg.father_task_ids[v.father_task_id] = v.task_ids
    end
end

function M.GetWeekNum()
    local weekNum = os.date("*t", os.time()).wday - 1
    if weekNum == 0 then
        weekNum = 7
    end
    return weekNum
end

--是否是周一到周五
function M.IsCurrentWeekDay()
	local curWeekNum = M.GetWeekNum()
    if curWeekNum >= 1 and curWeekNum <= 5 then
        return true
    end
end

--是否是周末
function M.IsCurrentWeekend()
    return not M.IsWeekDay()
end

function M.GetWeekDayList()
    return this.m_cfg.weekday_time_list
end

function M.GetWeekendList()
    return this.m_cfg.weekend_time_list
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.FormatTimeStr(start_time, end_time)
    return start_time .. ":00-" ..  end_time .. ":00"
end


function M.GetCurDayNextDoubleTime()
	local week_cfg
	if M.IsCurrentWeekDay() then
        week_cfg = this.m_cfg.weekday_time_list
    else
        week_cfg = this.m_cfg.weekend_time_list
    end
    if #week_cfg < 2 then
        return week_cfg[1]
    else
        local curHour = os.date("%H")
        local index = 1
        for i = 1, #week_cfg do
            if curHour - week_cfg[i].end_time >= 0 then
                index = i + 1
            end
        end
        if index > #week_cfg then
            index = #week_cfg
        end
        return week_cfg[index]
    end
end

function M.GetCurFatherTask()
    if not DominoJLModel then
        return
    end
    local gameId = DominoJLModel.data.game_id
    return this.m_cfg.game_task[gameId].father_task_id
end

--获取当前taskid对应的配置
function M.GetCfgFromTaskId(fatherTaskId, taskId)
    local index = M.GetTaskIndex(fatherTaskId, taskId) or 1
    return this.m_cfg.task[index]
end

function M.GetTaskIndex(fatherTaskId, taskId)
    local task_ids = this.m_cfg.father_task_ids[fatherTaskId]
    for i = 1, #task_ids do
        if task_ids[i] == taskId then
            return i
        end
    end
end

function M.OnReConnecteServerSucceed()
end
