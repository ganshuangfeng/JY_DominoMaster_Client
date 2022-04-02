-- 创建时间:2022-03-07
-- Act_SuggestedCollectionManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_SuggestedCollectionManager = {}
local M = Act_SuggestedCollectionManager
M.key = "act_suggested_ollection"

GameModuleManager.ExtLoadLua(M.key, "Act_SuggestedCollectionPanel")

local act_type = "answer_2022_3_15"
local task_id = 93
-- 活动的开始与结束时间
local e_time = 1647878399
local s_time = 1647298800

--push wait_get get finish
local state = "push"

local this
local lister
-- 是否有活动
function M.IsActive()
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
        return Act_SuggestedCollectionPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if state == "get" then
	    return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
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
    lister["common_question_answer_topic_response"] = this.on_common_question_answer_topic_response
    lister["common_question_answer_answer_num_change_msg"] = this.on_common_question_answer_answer_num_change_msg
    lister["common_question_answer_get_player_info_response"] = this.on_common_question_answer_get_player_info_response

    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    
end

function M.Init()
	M.Exit()

	this = Act_SuggestedCollectionManager
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
        Network.SendRequest("common_question_answer_get_player_info",{act_type = act_type})
        Network.SendRequest("query_one_task_data", {task_id = task_id})
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetState()
    return state
end

function M.SetState()
    if not M.now_answer_num or not M.taskData then
        return
    end
    local ns
    if M.now_answer_num >= 1 then
        ns = "push"
    else
        if M.taskData.award_status == 0 or M.taskData.award_status == 3 then
            ns = "wait_get"
        elseif M.taskData.award_status == 1 then
            ns = "get"
        elseif M.taskData.award_status == 2 then
            ns = "finish"
        end
    end
    local change = ns ~= state
    state = ns

    if change then
        Event.Brocast("Act_SuggestedCollectionManager_StateChange")
        M.SetHintState()
    end
end

function M.GetGold()
    Network.SendRequest("get_task_award", { id = task_id})
end

local answer
local save_path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
function M.SaveAnswer()
    save_lua2json(answer,M.key,save_path)
end

function M.GetAnswer()
    return load_json2lua(M.key,save_path)
end

function M.Push(q)
    answer = q
    local data = {
        act_type = act_type,
		is_all_right = 1,
		topic_data = {}
    }

    for qn, v in pairs(q) do
        local topic_data = {}
        topic_data.topic_id = qn
        if type(v) == "table" then
            for i, val in ipairs(v) do
                topic_data.answer_id =  topic_data.answer_id or ""
                topic_data.answer_id = topic_data.answer_id .. val
            end
        elseif type(v) == "string" then
            topic_data.answer_str = v
        end
        data.topic_data[#data.topic_data+1] = topic_data
    end
    Network.SendRequest("common_question_answer_topic",data,"")
end

function M.on_common_question_answer_topic_response(_,data)
    if data.result == 0 then
        --提交成功
        LittleTips.Create(GLL.GetTx(81052))
        M.SaveAnswer()
    else
        LittleTips.Create(GLL.GetTx(data.result))
    end
    answer = nil
end

function M.on_common_question_answer_answer_num_change_msg(_,data)
    if data.act_type ~= act_type then
        return
    end
    M.now_answer_num = data.now_answer_num
    M.SetState()
end

function M.on_common_question_answer_get_player_info_response(_,data)
    if data.act_type ~= act_type then
        return
    end
    if data.result == 0 then
        M.now_answer_num = data.now_answer_num
    else
        M.now_answer_num = nil
        LittleTips.Create(GLL.GetTx(data.result))
    end
    M.SetState()
end

function M.on_model_task_change_msg(data)
	if data.id ~= task_id then
		return
	end
    local taskData = GameTaskManager.GetTaskDataByID(task_id)
    if not taskData or not next(taskData) then
        return
    end
    M.taskData = taskData
    M.SetState()
end

function M.on_model_query_task_data_response()
    local taskData = GameTaskManager.GetTaskDataByID(task_id)
    if not taskData or not next(taskData) then
        return
    end
    M.taskData = taskData
    M.SetState()
end

function M.GetEndTime()
    return e_time
end