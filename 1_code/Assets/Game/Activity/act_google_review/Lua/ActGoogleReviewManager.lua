-- 创建时间:2022-01-19
-- ActGoogleReviewManager 管理器

local basefunc = require "Game/Common/basefunc"
ActGoogleReviewManager = {}
local M = ActGoogleReviewManager
M.key = "act_google_review"

local this
local lister

-- 是否有活动
function M.IsActive()
    if true then
        return false
    end
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
    
    lister["EnterScene"] = this.OnEnterScene
    lister["act_google_review_msg"] = this.on_act_google_review_msg
end

function M.Init()
	M.Exit()

	this = ActGoogleReviewManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        if this.update then
            this.update:Stop()
            this.update = nil
        end
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        if M.IsActive() then
            this.update = Timer.New(function ()
                if not this.can_launch_review and os.time() > (this.last_review_t + 90) then
                    this.last_review_t = os.time()
                    sdkMgr:OnGGReview("")
                end
            end, 100, -1)
            this.update:Start()
            this.last_review_t = os.time()
            this.can_launch_review = false
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_act_google_review_msg(tbl)
    dump(tbl, "<color=red>AAAGG on_act_google_review_msg</color>")
    if tbl.msg == "review" then
        if tbl.result == 0 then
            this.can_launch_review = true
        end
    else
        if tbl.result == 0 then
            this.review_finish = true
        else
            this.is_lock = false
            this.can_launch_review = false
            HintPanel.Create(1, "评价失败：" .. tbl.err)
        end
    end
end
-- 拉起评价弹窗
function M.OnLaunchReview()
    sdkMgr:OnGGLaunchReview("")
end

function M.OnEnterScene()
    if not this.is_lock and MainModel.myLocation == "game_Hall" then
        if this.can_launch_review then
            this.is_lock = true
            sdkMgr:OnGGLaunchReview("")
        end
    end
end
