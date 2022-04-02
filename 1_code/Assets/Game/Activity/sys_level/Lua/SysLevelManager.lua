-- 创建时间:2021-12-08
-- SysLevelManager 管理器

local basefunc = require "Game/Common/basefunc"
SysLevelManager = {}
local M = SysLevelManager
M.key = "sys_level"
M.config = GameModuleManager.ExtLoadLua(M.key, "level_server")
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
    lister["notify_level_data_msg"] = this.on_notify_level_data_msg
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = SysLevelManager
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
	end
end

function M.OnReConnecteServerSucceed()

end

--获取当前的等级
function M.GetLevel()
    return MainModel.UserInfo.level_data.level
end

--获取当前的经验值
function M.GetExperience()
    return MainModel.UserInfo.level_data.score - M.GetLastLevelNeed()
end

--获取当前等级所需要的经验值
function M.GetNextLevelNeed(level)
    local _level = level or M.GetLevel()
    return M.config.level_data[_level].score - M.GetLastLevelNeed(_level)
end

function M.GetLastLevelNeed(level)
    -- local fun = function (level)
    --     local sum = 0
    --     for i = 1,level do
    --         local s = M.config.level_data[i].score
    --         sum = sum + s
    --     end
    --     return sum
    -- end
    local _level = level or M.GetLevel()
    if _level > 1 then
        return M.config.level_data[_level - 1].score
    else
        return 0
    end
end


function M.on_notify_level_data_msg(_,data)
    dump(data,"<color=red>等级信息改变+</color>")
    local oldScore = MainModel.UserInfo.level_data.score or 0
    local addScore = data.score - oldScore
    local newScore = data.score
    Event.Brocast("model_level_score_change", {oldScore = oldScore,addScore = addScore,newScore = newScore})

    local oldLevel = MainModel.UserInfo.level_data.level
    MainModel.UserInfo.level_data.level = data.level
    MainModel.UserInfo.level_data.score = data.score
    local isLevelUp = (MainModel.UserInfo.level_data.level ~= oldLevel)
    data.isLevelUp = isLevelUp
    Event.Brocast("model_level_data_change", data)
    --GameItemModel.GetItemCount(itemKey)
end

-- @Event.Brocast("model_level_data_change", {level = 5, score = 100,  isLevelUp = true})