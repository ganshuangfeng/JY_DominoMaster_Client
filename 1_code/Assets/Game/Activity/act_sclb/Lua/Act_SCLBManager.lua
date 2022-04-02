-- 创建时间:2022-01-06
-- Act_SCLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_SCLBManager = {}
local M = Act_SCLBManager
M.key = "act_sclb"

GameModuleManager.ExtLoadLua(M.key, "Act_SCLBPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_SCLBEnter")
local config = GameModuleManager.ExtLoadLua(M.key, "act_sclb_config")

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

    if not M.IsActInTime() or not M.IsCanBuySCLB() then
        return false
    end

    -- 对应权限的key
    local _permission_key = "act_sclb_show"
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
        return Act_SCLBEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_SCLBPanel.Create()
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
    lister["AssetChange"] = this.OnAssetChange
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["model_task_data_change_msg"] = this.on_model_task_data_change_msg
end

function M.Init()
	M.Exit()

	this = Act_SCLBManager
	this.m_data = {}
    this.m_data.task_id = 132
    this.m_cfg = {}
    this.m_cfg.care_gifts = {}
    this.m_cfg.gift_id_list = {}
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
        local gift_id = config.config[i].gift_id
        this.m_cfg.care_gifts[gift_id] = 1
        this.m_cfg.gift_id_list[#this.m_cfg.gift_id_list + 1] = gift_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.OnAssetChange(data)
    if data.change_type == "buy_gift_bag_1022" then
        data.desc = GLL.GetTx(81110)
        Event.Brocast("AssetGet", data)
    end
end

function M.GetConfig()
    return config.config[1]
end

function M.GetActEndTime()
    local taskData = GameTaskManager.GetTaskDataByID(this.m_data.task_id)
    dump(taskData, "<color=red>AAAAA SCLB GetActEndTime</color>")
    if taskData then
        return taskData.over_time -- MainModel.FirstLoginTime() + 7 * 24 * 3600
    end
    return 0
end

function M.IsActInTime()
    return os.time() <= M.GetActEndTime()
end

--是否可以购买首充礼包
function M.IsCanBuySCLB()
    for i = 1, #this.m_cfg.gift_id_list do
        local gift_id = this.m_cfg.gift_id_list[i]
        local giftData = GameGiftManager.GetGiftData(gift_id)
        if not giftData then
            return false
        end
        if giftData.status ~= 1 then
            return false
        end
    end
    return true
end

function M.IsCareGiftId(gift_id)
    return this.m_cfg.care_gifts[gift_id]
end

function M.on_model_task_data_change_msg(data)
    if data.id == this.m_data.task_id then
        Event.Brocast("ui_button_data_change_msg", { gotoui = M.key })
    end
end
