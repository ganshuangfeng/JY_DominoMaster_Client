-- 创建时间:2022-03-22
-- Act_YJPHBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_YJPHBManager = {}
local M = Act_YJPHBManager
M.key = "act_yjphb"

GameModuleManager.ExtLoadLua(M.key, "Act_YJPHBPanel")
GameModuleManager.ExtLoadLua(M.key, "Act_YJPHBEnter")
GameModuleManager.ExtLoadLua(M.key, "Act_YJPHBItem")

local this
local lister

M.endTime = 1649087999
M.rank_type = "yingjin_common_rank"
M.rules = {
    "1.Waktu event:7:00 5 Aprils/d23:59:59 4 April",
    "2.Selama event,Qiu Qiu dan Big battle hanya menghitung data penghasilan bersih, dan game lain akan menghitung data kemenangan",
    "3.Setelah event selesai,hadiah peringk atakan dikirim melalui email,mohon cek waktu tepat.",
}

local awards = {100000, 50000, 20000, 10000, 10000, 
                10000, 5000, 5000, 5000, 5000, 
                3000, 3000, 3000, 3000, 3000, 
                1000, 1000, 1000, 1000, 1000}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if os.time() > M.endTime then
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
        return Act_YJPHBEnter.Create(parm.parent)
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

	this = Act_YJPHBManager
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

function M.GetAwardFromIndex(index)
    if awards[index] then
        return awards[index]
    end
    return 0
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end
