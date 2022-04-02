-- 创建时间:2022-01-04
-- Act_XRQTLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_XRQTLManager = {}
local M = Act_XRQTLManager
M.key = "act_xrqtl"

local config = GameModuleManager.ExtLoadLua(M.key, "act_xrqtl_config")
GameModuleManager.ExtLoadLua(M.key, "Act_XRQTLPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_XRQTLEnter")

local this
local lister

local isFirstLogin = true

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
        -- return true
    end
    return M.GetDayIndex() + 1 <= 7 
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
        return Act_XRQTLEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_XRQTLPanel.Create()
    elseif parm.goto_scene_parm == "panel_login" then
        if not M.IsFirstLogin() then
            return Act_XRQTLPanel.Create()
        else
            if isFirstLogin then
                M.SetFirstLogin()
            end
        end
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
end

function M.Init()
	M.Exit()

	this = Act_XRQTLManager
	this.m_data = {}
    this.m_cfg = {}
    this.m_cfg.mTaskIds = {}
	MakeLister()
    AddLister()
    M.InitConfig()

	-- M.InitUIConfig()
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
        if M.GetFirstLogin() == 1 then
            isFirstLogin = false
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitConfig()
    for i = 1, #config.config do
        local task_id = config.config[i].task_id
        if not this.m_cfg.mTaskIds[task_id] then
            this.m_cfg.mTaskIds[task_id] = 1
        end
    end
end

function M.GetCfg()
    return config.config
end

function M.GetCurDay()
    return M.GetDayIndex() + 1
end

function M.GetAllTaskStates()
    local states = {}
	local taskState = {}
	for i = 1, 7 do
		local task_id = config.config[i].task_id
		local taskData = GameTaskManager.GetTaskDataByID(task_id)
		if not taskData then
			states[i] = 0
		else
			states[i] = taskData.award_status
		end
	end
    return states
end

--从零开始
function M.GetDayIndex()
    local first_login_time = MainModel.FirstLoginTime()
    local t1 = basefunc.get_today_id(first_login_time)
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1 < 0 and 0 or t2 - t1
end

function M.IsCareTaskId(task_id)
    if this.m_cfg.mTaskIds[task_id] then
        return true
    end
end

function M.IsAwardCanGet()
    local states = M.GetAllTaskStates()
    local curDay = M.GetCurDay()
    if states and states[curDay] and states[curDay] == 1 then
        return true
    end
    return false
end

function M.SetFirstLogin()
    isFirstLogin = false
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id .. "_FIRST_LOGIN", 1)
end

function M.GetFirstLogin()
    return PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. "_FIRST_LOGIN", 0)
end

function M.IsFirstLogin()
    return isFirstLogin
end

function M.on_model_task_change_msg(data)
    if M.IsCareTaskId(data.id) then
        Event.Brocast("mode_act_xrqtl_task_change")
    end
end

function M.on_model_query_task_data_response()
    Event.Brocast("mode_act_xrqtl_task_change")
end
