-- 创建时间:2021-11-30
-- SysBroadcastManager 管理器

local basefunc = require "Game/Common/basefunc"
SysBroadcastManager = {}
local M = SysBroadcastManager
M.key = "sys_broadcas"
GameModuleManager.ExtLoadLua(M.key, "GameBroadcastRollPanel")
GameModuleManager.ExtLoadLua(M.key, "GameBroadcastRollPrefab")
GameModuleManager.ExtLoadLua(M.key, "GameBroadcastRollPrefabH")
GameModuleManager.ExtLoadLua(M.key, "BroadcastHelper")

M.dotween_key = "dotween_key_GameBroadcastManager"
local this
local lister
local autoKey = 1
local autoMax = 1000000000
local beginBroadcast

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

    lister["ExitScene"] = this.OnExitScene
    lister["EnterScene"] = this.OnEnterScene
    lister["multicast_msg"] = this.on_multicast_msg
end

function M.Init()
	M.Exit()

	this = SysBroadcastManager
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
    autoKey = 1
    autoMax = 1000000000
    beginBroadcast = true
    this.MulticastMsg = basefunc.queue.New()

    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

local getKey =function (data)
    if autoKey >= autoMax then
        autoKey = 1
    else
        autoKey = autoKey + 1
    end
    return "Broadcast" .. autoKey
end


function M.OnEnterScene()
    beginBroadcast = true
end
function M.OnExitScene()
    beginBroadcast = false
    DOTweenManager.KillAllLayerTween(M.dotween_key)
end
-- 滚动广播消息监听
function M.on_multicast_msg(_, msg)
    if GameGlobalOnOff.TS then
        return
    end
    -- @Event.Brocast("multicast_msg","multicast_msg", { type=1, content = "热烈欢迎热烈欢迎热烈欢迎热烈欢迎热烈欢迎热烈欢迎热烈欢迎" })
    -- @Event.Brocast("multicast_msg","multicast_msg", { type=1, content = "热烈欢迎<img=1></img><vip=22></vip>尊贵的<color=#ff7d1e>VIP%s</color>玩家<color=#f50505>%s</color>登录游戏"})
    local key=getKey(msg) 
    if msg.type == 1 then
        local isContainHead = M.IsContainHead(msg.content)
        -- dump(isContainHead, "<color=white> isContainHead</color>")
        this.MulticastMsg:push_back({key=key, msg=msg, isContainHead = isContainHead, time=os.time()})
        if this.MulticastMsg:size() > 50 then
            this.MulticastMsg:pop_front()
        end
    end
    --登录场景广播条不显示
    if beginBroadcast and MainModel.myLocation ~= "game_Login" and MainModel.myLocation ~= "game_Loding" then
        GameBroadcastRollPanel.PlayRoll()
    end
end

function M.GetRollFront()
    if this.MulticastMsg then
        return this.MulticastMsg:pop_front()
    end
end

function M.RollCount()
    if this.MulticastMsg then
        return this.MulticastMsg:size()
    end
    return 0
end

function M.IsContainHead(str)
    if string.find(str, "</img>") then
        return true
    end
    return false
end


