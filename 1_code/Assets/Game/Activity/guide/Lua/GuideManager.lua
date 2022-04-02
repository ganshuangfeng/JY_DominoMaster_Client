-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
GuideManager = {}

local M = GuideManager
M.key = "guide"
GameModuleManager.ExtLoadLua(M.key, "GuideModel")
GameModuleManager.ExtLoadLua(M.key, "GuidePanel")
GameModuleManager.ExtLoadLua(M.key, "GuideLogic")
GameModuleManager.ExtLoadLua(M.key, "GuideAwardHintPanel")
GameModuleManager.ExtLoadLua(M.key, "GuideRecharge")

local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
function M.SetHintState()
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
    lister["hall_panel_init_msg"] = M.on_hall_panel_init_msg
    lister["hall_panel_exit_msg"] = M.on_hall_panel_exit_msg
    lister["domino_hall_panel_init_msg"] = M.on_domino_hall_panel_init_msg
    lister["domino_hall_panel_exit_msg"] = M.on_domino_hall_panel_exit_msg
    lister["EnterScene"] = M.OnEnterScene
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    -- 放后面
    GuideLogic.Init()
end
function M.Exit()
	if M then
		RemoveLister()
        GuideLogic.Exit()
		M.m_data = nil
	end
end
function M.InitUIConfig()
    GameModuleManager.ExtLoadLua(M.key, "GuideConfig")
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

local szTimer
function M.MakeGuideTimer(parent)
    if SysLevelManager and SysLevelManager.GetLevel() > 2 then
        return
    end
    szTimer = Timer.New(function()
        if IsEquals(parent) then
            local sz = newObject("GuideSZ", parent.transform)
        end
    end, 3, 1)
    szTimer:Start()
end

function M.DisposeGuideTimer()
    if szTimer then
        szTimer:Stop()
        szTimer = nil
    end
end

function M.on_hall_panel_init_msg(panelSelf)
    M.MakeGuideTimer(panelSelf.bm_btn)
end

function M.on_hall_panel_exit_msg(panelSelf)
    M.DisposeGuideTimer()
end

function M.on_domino_hall_panel_init_msg(panelSelf)
    M.MakeGuideTimer(panelSelf.start_btn)
end

function M.on_domino_hall_panel_exit_msg(panelSelf)
    M.DisposeGuideTimer()
end

function M.GetRechargeGuideCreateNum(_permission_key)
    return PlayerPrefs.GetInt("Recharge_Guide_" .. _permission_key, 0)
end

function M.SetRechargeGuideCreateNum(_permission_key, num)
    PlayerPrefs.SetInt("Recharge_Guide_" .. _permission_key, num)
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" and MainModel.lastmyLocation ~= "game_Login" then
        local isRechargePermission = function(_permission_key)
            local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint = true})
            if not b then
                return false
            end
            return true
        end

        --充值5k并且持有大于等于5KRP的玩家 
        local condi1 = "player_recharge_5k"
        --0充值且持有大于等于5KRP的玩家
        local condi2 = "player_recharge_0"
        
        if isRechargePermission(condi1) then
            local num = M.GetRechargeGuideCreateNum(condi1)
            if num < 3 then
                GuideRecharge.Create(1)
                M.SetRechargeGuideCreateNum(condi1, num + 1)
            end
        elseif isRechargePermission(condi2) then
            local num = M.GetRechargeGuideCreateNum(condi2)
            if num < 3 then
                GuideRecharge.Create(2)
                M.SetRechargeGuideCreateNum(condi2, num + 1)
            end
        end
    end
end

