-- 创建时间:2022-03-08
-- Act_YJFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_YJFLManager = {}
local M = Act_YJFLManager
M.key = "act_yjfl"

GameModuleManager.ExtLoadLua(M.key, "Act_YJFLPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_YJFLEnter")
local this
local lister
M.task_id = 92
M.task_data = {}

-- 是否有活动
function M.IsActive()
    -- -- 活动的开始与结束时间
    -- local e_time
    -- local s_time
    -- if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
    --     return false
    -- end

    -- -- 对应权限的key
    -- local _permission_key
    -- if _permission_key then
    --     local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint = true})
    --     if not b then
    --         return false
    --     end
    --     return true
    -- else
    --     return true
    -- end
    local first_time = MainModel.FirstLoginTime()
    if os.time() - first_time < 7 * 3600 * 24 then
        return true
    end
    return false
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
        return Act_YJFLPanel.Create(parm.parent)
    end
    if parm.goto_scene_parm == "enter" then
        return Act_YJFLEnter.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    M.task_data = GameTaskManager.GetTaskDataByID(M.task_id)
    if M.task_data and M.task_data.award_status == 1 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
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
    lister["model_task_data_change_msg"] = this.on_model_task_data_change_msg
end

function M.Init()
	M.Exit()

	this = Act_YJFLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()

    local data = GameTaskManager.GetTaskConfigByTaskID(M.task_id)
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

function M.on_model_task_data_change_msg()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end
