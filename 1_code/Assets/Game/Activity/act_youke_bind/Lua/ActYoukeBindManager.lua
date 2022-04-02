-- 创建时间:2022-01-12
-- ActYoukeBindManager 管理器

local basefunc = require "Game/Common/basefunc"
ActYoukeBindManager = {}
local M = ActYoukeBindManager
M.key = "act_youke_bind"
GameModuleManager.ExtLoadLua(M.key, "ActYoukeBindPanel")
GameModuleManager.ExtLoadLua(M.key, "ActYoukeBindEnter")

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
        return ActYoukeBindEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return ActYoukeBindPanel.Create()
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

    lister["get_login_channels_response"] = this.on_get_login_channels
end

function M.Init()
	M.Exit()

	this = ActYoukeBindManager
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
        Network.SendRequest("get_login_channels")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_get_login_channels(_, data)
    dump(data, "<color=red>on_get_login_channels</color>")
    if data.result == 0 then
        this.m_data.channel_map = {}
        if data.channel_types then
            for k,v in ipairs(data.channel_types) do
                this.m_data.channel_map[v] = 1
            end
        end
        Event.Brocast("model_login_channels_msg")
    end
end

function M.Bind(tag)
    this.m_data.channel_map = this.m_data.channel_map or {}
    this.m_data.channel_map[tag] = 1
    Event.Brocast("model_login_channels_msg")
end
