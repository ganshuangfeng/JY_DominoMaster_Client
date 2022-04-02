-- 创建时间:2022-01-21
-- Act_UnlimitedGiftManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_UnlimitedGiftManager = {}
local M = Act_UnlimitedGiftManager
M.key = "act_unlimited_gift"

local config = GameModuleManager.ExtLoadLua(M.key, "act_unlimited_gift_config")
GameModuleManager.ExtLoadLua(M.key, "Act_UnlimitedGiftEnter")
GameModuleManager.ExtLoadLua(M.key, "Act_UnlimitedGiftPanel")

local this
local lister

--[[
    此礼包只是为了提审，可增加无限个礼包
]]

-- 是否有活动
function M.IsActive()
    return GameGlobalOnOff.TS
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
        return Act_UnlimitedGiftEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_UnlimitedGiftPanel.Create()
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

	this = Act_UnlimitedGiftManager
	this.m_data = {}
    this.m_cfg = {}
    this.m_cfg.care_gifts = {}

	MakeLister()
    AddLister()
	-- M.InitUIConfig()
    M.InitConfig()
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

function M.InitConfig()
    for i = 1, #config.config do
        local gift_id = config.config[i].gift_id
        this.m_cfg.care_gifts[gift_id] = 1
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.IsCareGiftId(gift_id)
    return this.m_cfg.care_gifts[gift_id]
end

function M.GetConfig()
    return config.config
end
