-- 创建时间:2021-12-06
-- RulesManager 管理器

local basefunc = require "Game/Common/basefunc"
RulesManager = {}
local M = RulesManager
M.key = "sys_rules"
local rulesCfg = GameModuleManager.ExtLoadLua(M.key, "rules_config")
GameModuleManager.ExtLoadLua(M.key, "RulesPanel")
GameModuleManager.ExtLoadLua(M.key, "RulesEnterPrefab")
GameModuleManager.ExtLoadLua(M.key, "RulesDominoPanel")
GameModuleManager.ExtLoadLua(M.key, "RulesDominoBetPanel")
GameModuleManager.ExtLoadLua(M.key, "RulesLudoPanel")
GameModuleManager.ExtLoadLua(M.key, "RulesBigBattlePanel")
GameModuleManager.ExtLoadLua(M.key, "RulesQIUQIUPanel")
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
        return RulesPanel.Create(parm)
    elseif parm.goto_scene_parm == "enter" then
        return RulesEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

	this = RulesManager
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

function M.GetRulesCfg()
    return rulesCfg
end

function M.GetRulesTagCfg()
    local tagCfg = {}
    for i, v in ipairs(rulesCfg) do
        tagCfg[i] = v.tag
    end
    return tagCfg
end

function M.GetRulesTagGameCfg(game)
    for i, v in ipairs(rulesCfg) do
        if game == v.tag then
            return v.rules
        end
    end
end

local tagName = {
    Rules = "Peraturan",
    Winner = "Pemenang",
    Settlement = "Pembayaran",
}

function M.GetRulesTagGameName(s)
    return tagName[s]
end

function M.GetTxt(game,tag)
    for i, v in ipairs(rulesCfg) do
        if game == v.tag then
            for k, txt in pairs(v.txt) do
                if k == tag then
                    return GLL.GetTx(txt)
                end
            end
        end
    end
end