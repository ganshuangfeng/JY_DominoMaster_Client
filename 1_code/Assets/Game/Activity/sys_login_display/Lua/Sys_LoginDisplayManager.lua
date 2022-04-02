-- 创建时间:2022-01-05
-- Sys_LoginDisplayManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_LoginDisplayManager = {}
local M = Sys_LoginDisplayManager
M.key = "sys_login_display"

local config = GameModuleManager.ExtLoadLua(M.key, "sys_login_display_config")
GameModuleManager.ExtLoadLua(M.key, "Sys_LoginDisplayView")

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
    if parm.goto_scene_parm == "panel" then
        if M.IsFirstLogin() then 
            return Sys_LoginDisplayView.Create()
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
end

function M.Init()
	M.Exit()

	this = Sys_LoginDisplayManager
    this.m_cfg = {}
	this.m_cfg.hall_display_list = {}

    this.m_data = {}
    this.m_data.hallDisplayList = {}
    this.m_data.isFirstLogin = true
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

function M.InitConfig()
    for i = 1, #config.hall do
        local cfg = config.hall[i]
        if cfg.isOnOff then
            this.m_cfg.hall_display_list[#this.m_cfg.hall_display_list + 1] = cfg
        end
    end
end

function M.IsInTime(startTime, endTime)
    if not startTime and not endTime then
        return true
    end
    local curTime = os.time()
    if startTime and not endTime then
        return curTime > startTime
    end

    if not startTime and endTime then
        return curTime <= endTime
    end
    
    if startTime and endTime then
        return curTime <= endTime and curTime > startTime
    end
end

function M.IsPermiss(permission)
    if permission then
        local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint = true})
        if not b then
            return false
        end
        return true
    else
        return true
    end
end

function M.IsDisplayActive(gotoUI)
    local key = gotoUI[1]
    local module = GameModuleManager.GetModuleByKey(key)

    if module.lua and _G[module.lua] then
        return _G[module.lua].CheckIsShow()
    end
end

function M.CheckType(type, id)
    if type == "LoginUp" then
        return true
    elseif type == "DailyUp" then
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldTime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("LoginDisplayRunTime" .. id, 0))))
        if oldTime ~= newtime then
            return true
        end
    end
end

function M.InitData()
    this.m_data.hallDisplayList = {}
    for i = 1, #this.m_cfg.hall_display_list do
        local cfg = this.m_cfg.hall_display_list[i]
        if M.IsInTime(cfg.startTime, cfg.endTime) and M.IsPermiss(cfg.condi_key) and M.IsDisplayActive(cfg.gotoUI) and M.CheckType(cfg.type, cfg.id) then
            local data = {gotoUI = cfg.gotoUI, order = cfg.order, id = cfg.id}
            this.m_data.hallDisplayList[#this.m_data.hallDisplayList + 1] = data
        end
    end
    MathExtend.SortList(this.m_data.hallDisplayList, "order", true)
end

function M.GetShowData()
    return this.m_data.hallDisplayList
end

function M.IsFirstLogin()
    return this.m_data.isFirstLogin
end

function M.SetFirstLogin(boolValue)
    this.m_data.isFirstLogin = boolValue
end
