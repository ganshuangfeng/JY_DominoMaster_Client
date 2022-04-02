-- 创建时间:2022-02-22
-- Sys_BannerManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_BannerManager = {}
local M = Sys_BannerManager
M.key = "sys_banner"

local config = GameModuleManager.ExtLoadLua(M.key, "sys_banner_config").hall
GameModuleManager.ExtLoadLua(M.key, "Sys_BannerPanel")
GameModuleManager.ExtLoadLua(M.key, "Sys_BannerPageNum")

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
        return Sys_BannerPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel_close" then
        return Sys_BannerPanel.Close()
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

	this = Sys_BannerManager
    this.m_cfg = {}
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    -- M.InitBannerList()
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

function M.InitBannerList()
    this.m_cfg.bannerList = {}
    for i = 1, #config do
        if config[i].isOnOff and config[i].isOnOff == 1 then
            this.m_cfg.bannerList[#this.m_cfg.bannerList + 1] = config[i]
        end
    end

    for i = 1, #this.m_cfg.bannerList do
        local banner = this.m_cfg.bannerList[i]
        if banner.startTime == -1 and banner.endTime == -1 then
            banner.isForever = true
        else
            banner.isForever = false
        end
    end
    dump(this.m_cfg.bannerList, "<color=white>this.m_cfg.bannerList</color>")
end

local function InitEndTimeList()
    --目前bannerlist中的endTime的列表，用来判断是否超时
    this.m_data.endTimeList = {}
end

local function InitStartTimeList()
    --满足其他条件但是时间还没到的bannerlist中的startTime的列表，用来判断是否到了显示时间
    this.m_data.startTimeList = {}
end

local function AddToEndTimeList(time)
    this.m_data.endTimeList[#this.m_data.endTimeList + 1] = time
end

local function AddToStartTimeList(time)
    this.m_data.startTimeList[#this.m_data.startTimeList + 1] = time
end

function M.GetCurBannerIdList()
    if not this.m_cfg.bannerList then
        M.InitBannerList()
    end
    InitEndTimeList()
    InitStartTimeList()
    this.m_data.curBannerList = {}
    M.UpdateBannerIdList()
    return this.m_data.curBannerList
end

function M.UpdateBannerIdList()
    for i = 1, #this.m_cfg.bannerList do
        --TODO:如果加权限判断就加在这里
        --[]
        local cfg = this.m_cfg.bannerList[i]
        if cfg.isForever then
            this.m_data.curBannerList[#this.m_data.curBannerList + 1] = cfg.id
        elseif os.time() >= cfg.startTime and os.time() <= cfg.endTime then
            this.m_data.curBannerList[#this.m_data.curBannerList + 1] = cfg.id
            AddToEndTimeList(cfg.endTime)
        elseif os.time() < cfg.startTime then
            AddToStartTimeList(cfg.startTime)
        end
    end
end

--是否有新到显示时间的
function M.IsInTime()
    local list = this.m_data.startTimeList
    for i = 1, #list do
        if os.time() > list[i] then
            return true
        end
    end
    return false
end

--当前表里是否有超时的
function M.IsOutTime()
    local list = this.m_data.endTimeList
    for i = 1, #list do
        if os.time() > list[i] then
            return true
        end
    end
    return false
end
function M.GetCfgFromId(id)
    if this.m_cfg.bannerList[id] then
        return this.m_cfg.bannerList[id]
    end
end

