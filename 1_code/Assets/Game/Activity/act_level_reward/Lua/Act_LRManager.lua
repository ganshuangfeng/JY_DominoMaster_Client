-- 创建时间:2022-03-01
-- Act_LRManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_LRManager = {}
local M = Act_LRManager
M.key = "act_level_reward"
-- local config = GameModuleManager.ExtLoadLua(M.key, "act_level_reward_config")
GameModuleManager.ExtLoadLua(M.key, "Act_LRPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_LRHint")
GameModuleManager.ExtLoadLua(M.key, "Act_LREnter")

M.task_id = 90

local reward_cfg = {
    [1] = 
    {
        lv = 2,
        award_img = {"ty_icon_rp_3", "ty_icon_dj_jb_03",},
        award_amount = {500, 5000000},
    },
    [2] = 
    {
        lv = 3,
        award_img = {"ty_icon_rp_3", "ty_icon_dj_jb_03",},
        award_amount = {600, 6000000},
    },
    [3] = 
    {
        lv = 4,
        award_img = {"ty_icon_rp_3", "ty_icon_dj_jb_03",},
        award_amount = {800, 7000000},
    },
    [4] = 
    {
        lv = 5,
        award_img = {"ty_icon_rp_3", "ty_icon_dj_jb_03",},
        award_amount = {1000, 8000000},
    },
}

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

    if M.IsGetedAllReward() then
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
        return Act_LREnter.Create(parm.parent)
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
    lister["model_level_data_change"] = this.on_model_level_data_change
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["player_lv_up_in_seat"] = this.on_player_lv_up_in_seat
end

function M.Init()
	M.Exit()

	this = Act_LRManager
	this.m_data = {}
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

 
local function GetCurLvAndState(states)
    for i = 1, #states do
        if states[i] == 1 then
            return i, 1
        elseif states[i] == 0 then
            return i, 0
        end
    end
    return #states, 2
end

function M.IsGetedAllReward()
    local lv, state = M.GetCurLvAndState()
    -- dump(lv, "<color=white> AAA lv </color>")
    -- dump(state, "<color=white> AAA state </color>")
    if lv == 4 and state == 2 then
        return true
    end
    return false
end

function M.GetCurLvAndState()
    local taskData = GameTaskManager.GetTaskDataByID(M.task_id)
    -- dump(taskData, "<color=white> AAA taskData </color>")
    if not taskData then
        return 4, 2
    end
	local states = GameTaskManager.GetTaskStatusByData(taskData, 4)
    return GetCurLvAndState(states)
end

function M.GetRewardConfig(index)
    return reward_cfg[index] or reward_cfg[1]
end

function M.on_model_level_data_change(data)
    -- dump(data, "<color=white>AAA on_model_level_data_change</color>")
    if data.isLevelUp and 
    (data.level == 2 or data.level == 3 or data.level == 4 or data.level == 5) then
        Act_LRHint.Create(data)
    end
end

function M.on_model_query_task_data_response()
    local taskData = GameTaskManager.GetTaskDataByID(M.task_id)
    if taskData then
        Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
    end
end

function M.on_player_lv_up_in_seat(trans)
    CommonAnim.LvUpAnim(trans)
end