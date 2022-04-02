-- 创建时间:2022-01-07
-- Act_RouletteManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_RouletteManager = {}
local M = Act_RouletteManager
M.key = "act_roulette"
GameModuleManager.ExtLoadLua(M.key, "Act_RouletteEnterPrefab")
GameModuleManager.ExtLoadLua(M.key, "Act_RoulettePanel")
GameModuleManager.ExtLoadLua(M.key, "Act_RouletteVipWheelPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_RouletteWheelPanel")
GameModuleManager.ExtLoadLua(M.key, "RouletteLevelAwardCell")
GameModuleManager.ExtLoadLua(M.key, "RouletteVipAwardCell")
GameModuleManager.ExtLoadLua(M.key, "RouletteVipWheelCell")
GameModuleManager.ExtLoadLua(M.key, "RouletteWheelCell")
GameModuleManager.ExtLoadLua(M.key, "Act_RouletteRulesPanel")
local config = GameModuleManager.ExtLoadLua(M.key, "act_roulette_config")

-- 关闭普通抽奖
Act_RouletteManager.close_whell = true

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
    local _permission_key = "whell_open_limit"
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
        return Act_RoulettePanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_RouletteEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter_in_game" then
        return Act_RouletteEnterPrefab.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    return M.IsLevelAwardByRange(1, this.m_data.level_task_jd)
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
    lister["query_luck_lottery_data_response"] = this.on_query_luck_lottery_data

    lister["model_vip_base_info_msg"] = this.QueryLuckData
    lister["model_level_data_change"] = this.on_model_level_data_change
    lister["AssetChange"] = this.OnAssetChange

end

function M.Init()
	M.Exit()

	this = Act_RouletteManager
	this.m_data = {}
    this.m_data.vip_cj_hf = 100000000
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

    this.m_data.level_task_id = config.config.level_task_id.value
    this.m_data.level_task_jd = #config.config.level_award.value

    this.UIConfig.level_award = config.config.level_award.value
    this.UIConfig.vip_bei = config.config.vip_bei.value
    this.UIConfig.pt_award = config.pt
    this.UIConfig.vip_award = config.vip
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryLuckData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.OnAssetChange(data)
    Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
end

function M.IsLevelAwardByRange(lvl1, lvl2)
    if not Act_RouletteManager.close_whell then
        local task = GameTaskManager.GetTaskDataByID(this.m_data.level_task_id)
        if task then
            local task_status = GameTaskManager.GetTaskStatusByData(task, #this.UIConfig.level_award)
            for i = lvl1, lvl2 do
                if task_status[i] == 1 then
                    return ACTIVITY_HINT_STATUS_ENUM.AT_Get
                end
            end
        end
    end

    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.GetLevelAwardStage(lvl)
    local task = GameTaskManager.GetTaskDataByID(this.m_data.level_task_id)
    if task then
        local task_status = GameTaskManager.GetTaskStatusByData(task, #this.UIConfig.level_award)
        return task_status[lvl]
    end

    return 0
end

function M.IsAllGetLevelAward()
    if not Act_RouletteManager.close_whell then
        local task = GameTaskManager.GetTaskDataByID(this.m_data.level_task_id)
        dump(task, "<color=red>IsAllGetLevelAward</color>")
        if task and task.award_status == 1 then
            return true
        end
    end
    return false
end

function M.on_model_task_data_change_msg(data)
    if data.id == this.m_data.level_task_id then
        Event.Brocast("model_roulette_task_data_msg")
    end
end

function M.on_query_luck_lottery_data(_, data)
    if data.result == 0 then
        this.m_data.is_lock_data = true
        this.m_data.free_num = data.free_num
        this.m_data.vip_num = data.vip_num
        Event.Brocast("model_luck_lottery_data_msg")
        Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
    end
end
function M.QueryLuckData(jh)
    Network.SendRequest("query_luck_lottery_data", nil, jh)
end

function M.GetPtWheelConfig()
    return this.UIConfig.pt_award
end

function M.GetVipWheelConfig()
    return this.UIConfig.vip_award
end
function M.GetLevelAwardConfig()
    local d = {}
    for i = 1, #this.UIConfig.level_award do
        d[#d + 1] = {index=i, lvl=this.UIConfig.level_award[i], status=M.IsLevelAwardByRange(i, i)}
    end    
    return d
end

function M.GetVipAwardConfig()
    local d = {}
    for i = 1, #this.UIConfig.vip_bei do
        d[#d + 1] = {lvl=i, bei=this.UIConfig.vip_bei[i]}
    end    
    return d
end
function M.GetVipBei(vip)
    if this.UIConfig.vip_bei[vip] then
        return this.UIConfig.vip_bei[vip]
    end
    return 1
end

function M.GetActivityRedKey(tt)
    return M.key.."_red_" .. tt
end
function M.IsCanLuck(tag)
    if not Act_RouletteManager.close_whell then
        if tag == 1 then
            local item_n = GameItemModel.GetItemCount("prop_xycj_coin")
            local free_n = Act_RouletteManager.m_data.free_num or 0
            if item_n <= 0 and free_n <= 0 then
                return false
            end
            return true
        end
    end
    if this.m_data and this.m_data.vip_num and 2*this.m_data.vip_cj_hf <= MainModel.UserInfo.jing_bi and this.m_data.vip_num > 0 then
        if StringHelper.IsSameDay(PlayerPrefs.GetString(M.GetActivityRedKey("enter"), ""), os.time()) then
            return false
        else
            return true
        end
    end
    return false
end

function M.SetEnterClick()
    PlayerPrefs.SetString(M.GetActivityRedKey("enter"), os.time())
    Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
end

function M.on_model_level_data_change(data)
    if data.level == 3 and data.isLevelUp then
        Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
    end
end
