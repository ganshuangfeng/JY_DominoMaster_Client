-- 创建时间:2022-01-05
-- SYSQDManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSQDManager = {}
local M = SYSQDManager
M.key = "sys_qd"

GameModuleManager.ExtLoadLua(M.key, "Sys_SignInPanel")
GameModuleManager.ExtLoadLua(M.key, "Sys_SignInEnter")
GameModuleManager.ExtLoadLua(M.key, "Sys_SignInWeekAwardGet")
local config = GameModuleManager.ExtLoadLua(M.key, "sys_sign_in_config")

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
        return Sys_SignInEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Sys_SignInPanel.Create()
    elseif parm.goto_scene_parm == "panel_login" then
        if M.IsCanGetAward() then
            return Sys_SignInPanel.Create()
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
    lister["query_sign_in_data_response"] = this.on_query_sign_in_data_response

    lister["EnterScene"] = this.OnEnterScene

end

function M.Init()
	M.Exit()

	this = SYSQDManager
    this.m_cfg = {}
    this.m_cfg.week_cfg = {}
    this.m_cfg.month_cfg = {}
	this.m_data = {}
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
        Network.SendRequest("query_sign_in_data")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitConfig()
    for i = 1, #config.week do
        this.m_cfg.week_cfg[#this.m_cfg.week_cfg + 1] = config.week[i]
    end

    for i = 1, #config.month do
        this.m_cfg.month_cfg[#this.m_cfg.month_cfg + 1] = config.month[i]
    end
end

function M.GetWeekConfig()
    return this.m_cfg.week_cfg
end

function M.GetMonthConfig()
    local curCfg = {}
    for i = 1, #this.m_cfg.month_cfg do
        if this.m_cfg.month_cfg[i].day == "M" then
            local cfg = basefunc.deepcopy(this.m_cfg.month_cfg[i])
            cfg.day = M.GetMonthDayCount(tonumber(os.date("%Y", os.time())), tonumber(os.date("%m", os.time())))
            curCfg[#curCfg + 1] = cfg
        else
            curCfg[#curCfg + 1] = this.m_cfg.month_cfg[i]
        end
    end
    return curCfg
end

function M.on_query_sign_in_data_response(_, data)
	dump(data, "<color=red>签到 on_query_sign_in_data_response</color>")
	if data and data.result == 0 then
		this.m_data = data
		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
	end
end

function M.OnEnterScene()
    -- dump(MainModel.myLocation, "myLocation")
    -- dump(MainModel.lastmyLocation, "lastmyLocation")
    -- if MainModel.myLocation == "game_Hall" and MainModel.lastmyLocation ~= "game_Login" then
    --     if M.IsCanGetAward() then
    --         Sys_SignInPanel.Create()
    --     end
    -- end
end

function M.IsCanGetAward()
    if this.m_data.sign_in_award then
        if this.m_data.sign_in_award == 1 or not table_is_null(this.m_data.acc_award) then
            return true
        end
    end
end

function M.GetMonthDayCount(year, month)
    local t
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then
        t = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    else
        t = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    end
    return t[month]
end