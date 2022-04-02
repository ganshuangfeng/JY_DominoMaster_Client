-- 创建时间:2021-12-31
-- Act_AccumulateWinManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_AccumulateWinManager = {}
local M = Act_AccumulateWinManager
M.key = "act_accumulate_win"

GameModuleManager.ExtLoadLua(M.key, "Act_AccumulateWinEnter")
GameModuleManager.ExtLoadLua(M.key, "Act_AccumulateWinPanel")
local config = GameModuleManager.ExtLoadLua(M.key, "act_accumulate_win_config")

local this
local lister

--获取奖励所需的场次
local need_process = {1, 3, 5, 7, 10, 15, 25}

--获取奖对应的奖励
local award_image = {"ty_icon_rp_1", 
                        "ty_icon_rp_1", 
                        "ty_icon_rp_1", 
                        "ty_icon_rp_1", 
                        "ty_icon_rp_1",
                        "ty_icon_rp_2",
                        "ty_icon_rp_3",}

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
        return Act_AccumulateWinEnter.Create(parm.parent)
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
end

function M.Init()
	M.Exit()

	this = Act_AccumulateWinManager
	this.m_data = {}
    this.m_cfg = {}
    this.m_cfg.mDictionary = {}
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

function M.InitConfig()
    for i = 1, #config.config do
        local game_id = config.config[i].game_id
        this.m_cfg.mDictionary[game_id] = config.config[i]
        this.m_cfg.mTaskIds[#this.m_cfg.mTaskIds + 1] = config.config[i].task_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetCfgFromGameID(game_id)
    if this.m_cfg.mDictionary[game_id] then
        return this.m_cfg.mDictionary[game_id]
    end
end

function M.GetNeedProgressList()
    return need_process
end

function M.GetAwardImageList()
    return award_image
end

function M.IsCareTaskId(task_id)
    for i = 1, #this.m_cfg.mTaskIds do
        if task_id == this.m_cfg.mTaskIds[i] then
            return true
        end
    end
    return false
end

function M.IsTaskAwardCanGet()
    local game_id = M.GetCurGameId()
    if not game_id then
        return false
    end
    local cfg = M.GetCfgFromGameID(game_id)
    if not cfg then
        return false
    end
    local taskData = GameTaskManager.GetTaskDataByID(cfg.task_id)
    if taskData then
        local status = GameTaskManager.GetTaskStatusByData(taskData, #cfg.award_num_list)
        for i = 1, #status do
            if status[i] == 1 then
                return true
            end
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    dump(data, "<color=red>++++on_model_task_change_msg+++++</color>")
    if M.IsCareTaskId(data.id) then
        Event.Brocast("mode_act_accumulate_win_task_change")
    end
end

function M.GetCurGameId()
    if MainModel.myLocation == "game_DominoJL" then
        if DominoJLModel then
            return DominoJLModel.data.game_id
        end
    elseif MainModel.myLocation == "game_Ludo" then
        if LudoModel then 
            return LudoModel.data.game_id
        end
    elseif MainModel.myLocation == "game_QiuQiu" then
        if QiuQiuModel then
            return QiuQiuModel.data.game_id
        end
    end
end