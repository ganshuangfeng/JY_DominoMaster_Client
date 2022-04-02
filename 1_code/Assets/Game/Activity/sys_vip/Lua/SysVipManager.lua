-- 创建时间:2021-12-21
-- SysVipManager 管理器

local basefunc = require "Game/Common/basefunc"
SysVipManager = {}
local M = SysVipManager
M.key = "sys_vip"
local config = GameModuleManager.ExtLoadLua(M.key, "vip_config")
GameModuleManager.ExtLoadLua(M.key, "VIPPanel")
GameModuleManager.ExtLoadLua(M.key, "VIPSmallPrefab")
GameModuleManager.ExtLoadLua(M.key, "VIPTQPrefab")
GameModuleManager.ExtLoadLua(M.key, "VIPPagePrefab")
GameModuleManager.ExtLoadLua(M.key, "TQDescCell")
GameModuleManager.ExtLoadLua(M.key, "TQAwardCell")
GameModuleManager.ExtLoadLua(M.key, "VIPEnterPrefab")
GameModuleManager.ExtLoadLua(M.key, "VIPOverflowPrefab")


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
        return VIPPanel.Create()
    elseif parm.goto_scene_parm == "small" then
        return VIPSmallPrefab.Create(parm.parent, parm.selfParent)
    elseif parm.goto_scene_parm == "enter" then
        return VIPEnterPrefab.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    return M.IsVipAwardByRange(1, this.UIConfig.max_vip_level)
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

    lister["query_vip_base_info_response"] = this.on_vip_base_info
    lister["vip_upgrade_change_msg"] = this.on_vip_base_info

    lister["on_player_hb_limit_convert"] = this.on_player_hb_limit_convert

    lister["set_vip_icon_msg"] = this.set_vip_icon_msg
    lister["hint_hb_limit_convert_msg"] = this.on_hint_hb_limit_convert_msg
    lister["ExitScene"] = this.OnExitScene
end

function M.Init()
	M.Exit()

	this = SysVipManager
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
    this.UIConfig.max_vip_level = 10

    this.UIConfig.vip_base = {}
    this.UIConfig.vip_task_map = {}
    for k,v in ipairs(config.config) do
        this.UIConfig.vip_base[v.vip] = v
        this.UIConfig.vip_task_map[v.task_id] = 1
    end

    this.UIConfig.vip_info = {}
    for k,v in ipairs(config.info) do
        this.UIConfig.vip_info[v.vip] = this.UIConfig.vip_info[v.vip] or {}
        this.UIConfig.vip_info[v.vip][#this.UIConfig.vip_info[v.vip] + 1] = v
    end

    this.UIConfig.vip_up_award = {}
    for k,v in ipairs(config.award) do
        this.UIConfig.vip_up_award[v.vip] = this.UIConfig.vip_up_award[v.vip] or {}
        this.UIConfig.vip_up_award[v.vip][#this.UIConfig.vip_up_award[v.vip] + 1] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        Network.SendRequest("query_vip_base_info", nil)
        -- 数据初始化
        MainModel.UserInfo.vip_level = MainModel.UserInfo.vip_level or 0
        if MainModel.UserInfo.vip_level > this.UIConfig.max_vip_level then
            MainModel.UserInfo.vip_level = this.UIConfig.max_vip_level
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_vip_base_info(_, data)
    dump(data, "<color=red>AAA on_vip_base_info</color>")
    if not data.result or data.result == 0 then
        MainModel.UserInfo.vip_level = data.vip_level
        this.m_data.vip_data = data
        Event.Brocast("model_vip_base_info_msg")
    end
end

-- DATA
function M.GetVipLevel()
    if this.m_data.vip_data then
        return this.m_data.vip_data.vip_level
    end
    return 0  
end
function M.GetVipRate()
    if this.m_data.vip_data then
        return this.m_data.vip_data.now_charge_sum/100
    end
    return 0
end
function M.GetVipData()
    return {level=M.GetVipLevel(), rate=M.GetVipRate()}
end
function M.GetVipConfigByLevel(level)
    local data = {}
    data.base = this.UIConfig.vip_base[level]
    data.info = this.UIConfig.vip_info[level]
    data.up_award = this.UIConfig.vip_up_award[level]
    return data
end
function M.GetVipInfoByLevel(level)
    return this.UIConfig.vip_info[level]
end
function M.GetVipUpAwardByLevel(level)
    return this.UIConfig.vip_up_award[level]
end

function M.IsVipTaskByID(id)
    if this.UIConfig.vip_task_map[id] then
        return true
    end
    return false
end

function M.IsVipAwardByRange(vip1, vip2)
    for i = vip1, vip2 do
        local cfg = SysVipManager.GetVipConfigByLevel(i)
        local task = GameTaskManager.GetTaskDataByID(cfg.base.task_id)
        if task then
            local task_status = GameTaskManager.GetTaskStatusByData(task, SysVipManager.UIConfig.max_vip_level)
            if task_status[cfg.base.task_lv] == 1 then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Get
            end
        end
    end

    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.GetHBLimit()
    return this.UIConfig.vip_base[M.GetVipLevel()].RP_limit
end

function M.on_player_hb_limit_convert(_, data)
    dump(data, "on_player_hb_limit_convert")
    local hb_limit = M.GetHBLimit()

    this.m_data.hb_limit_data = {}
    this.m_data.hb_limit_data.cur_hb_limit = hb_limit
    this.m_data.hb_limit_data.cur_vip = MainModel.UserInfo.vip_level
    this.m_data.hb_limit_data.shop_gold_change = data.shop_gold_change
    this.m_data.hb_limit_data.jing_bi_change = data.jing_bi_change

    if not this.m_data.tag then
        M.on_hint_hb_limit_convert_msg()
    end
end
function M.SetHbLimitTag(tag)
    if this then
        this.m_data.tag = tag
    end
end
function M.OnExitScene()
    if this then
        this.m_data.tag = false
    end
end
function M.on_hint_hb_limit_convert_msg()
    if this.m_data.hb_limit_data then
        VIPOverflowPrefab.Create(this.m_data.hb_limit_data)
        this.m_data.hb_limit_data = nil
    end
end

function M.set_vip_icon_msg(data)
    if IsEquals(data.img) then
        local vip = data.vip or 0
        if vip < 1 then
            data.img.gameObject:SetActive(false)
        else
            data.img.gameObject:SetActive(true)
            local cfg = SysVipManager.GetVipConfigByLevel(vip)
            data.img.sprite = GetTexture(cfg.base.icon)
        end
    end
end
