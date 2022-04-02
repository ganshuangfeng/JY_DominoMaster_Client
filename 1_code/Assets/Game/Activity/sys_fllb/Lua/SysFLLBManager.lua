-- 创建时间:2022-01-06
-- SysFLLBManager 管理器

local basefunc = require "Game/Common/basefunc"
SysFLLBManager = {}
local M = SysFLLBManager
M.key = "sys_fllb"
GameModuleManager.ExtLoadLua(M.key, "SysFLLBEnter")
GameModuleManager.ExtLoadLua(M.key, "SysFLLBPanel")
local this
local lister

local shop_id_config = {1001,1002,1003,1004,1005,1006,1007}
local task_id_config = {53,54,55,56,57,58,59}

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
        return true and not M.IsAllFinsh()
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
        return SysFLLBEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return SysFLLBPanel.Create()
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    for i = 1,#task_id_config do
        local task_data = GameTaskManager.GetTaskDataByID(task_id_config[i])
        if task_data and task_data.award_status == 1 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
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
end

function M.Init()
	M.Exit()

	this = SysFLLBManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    local data = GameTaskManager.GetTaskConfigByTaskID(53)
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

--获取当前的商品ID
function M.GetCurrShopID()
	-- for i = 1,#shop_id_config do
    --     local isCanBy = GameGiftManager.IsCanBuytGift(shop_id_config[i])
    --     if isCanBy then
    --         return shop_id_config[i]
    --     end
    -- end

    local index = -1
    for i = 1,#task_id_config do
        local data = GameTaskManager.GetTaskDataByID(task_id_config[i])
        if data and (data.award_status == 1 or data.award_status == 0) then
            index = i
            break
        end
    end

    if index == -1 then
        for i = 1,#shop_id_config do
            local isCanBy = GameGiftManager.IsCanBuytGift(shop_id_config[i])
            if isCanBy then
                index = i
                break
            end
        end
    end

    return shop_id_config[index]
end
--根据商品ID获取对应的任务ID
function M.GetTaskIDByShopID(shop_id)
    local index = 0
    for i = 1,#shop_id_config do
        if shop_id_config[i] == shop_id then
            index = i
            break
        end
    end

    return task_id_config[index]
end

function M.GetLBIDs()
    return shop_id_config
end

function M.GetTaskIDs()
    return task_id_config
end

function M.GetTotalJingBi(index)
    if not index then
        local total = 0
        for i = 1,#task_id_config do
            local data = GameTaskManager.GetTaskDataByID(task_id_config[i])
            dump(data,"<color=red>任务数据 </color>")
            if data then
                total = total + data.now_total_process
            end
        end
        return total
    else
        local total = 0
        local data = GameTaskManager.GetTaskDataByID(task_id_config[index])
        dump(data,"<color=red>任务数据 </color>")
        if data then
            total = total + data.now_total_process
        end
        return total
    end
end
--是不是所有的商品已经购买，并且所有的任务都已经完成了
function M.IsAllFinsh()
    local all_buy = true
    for i = 1,#shop_id_config do
        local b = GameGiftManager.IsCanBuytGift(shop_id_config[i])
        if b then
            all_buy = false
            break
        end
    end

    --当有的礼包没有完成
    if not all_buy then
        return false
    else
        local all_task_get = true
        for i = 1,#task_id_config do
            local task_data = GameTaskManager.GetTaskDataByID(task_id_config[i])
            if not task_data or (not (task_data.award_status == 2)) then
                all_task_get = false
                break
            end
        end
        if all_task_get then
            return true
        end
    end
    return false
end