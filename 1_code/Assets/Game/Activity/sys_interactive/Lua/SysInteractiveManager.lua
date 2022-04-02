-- 创建时间:2021-12-13
-- SysInteractiveManager 管理器

local basefunc = require "Game/Common/basefunc"
SysInteractiveManager = {}
local M = SysInteractiveManager
M.key = "sys_interactive"
GameModuleManager.ExtLoadLua(M.key, "InteractiveInfoPanel")
GameModuleManager.ExtLoadLua(M.key, "InteractiveMyInfoPanel")
GameModuleManager.ExtLoadLua(M.key, "InteractiveInfoPrefab")
local config = GameModuleManager.ExtLoadLua(M.key, "interactive_config")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatPanel")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatJifPrefab")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatJifCell")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatTxtPrefab")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatTxtCell")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatTxtShow")
GameModuleManager.ExtLoadLua(M.key, "InteractiveEnterPrefab")
GameModuleManager.ExtLoadLua(M.key, "InteractiveInfoShow")
GameModuleManager.ExtLoadLua(M.key, "InteractiveChatGifShow")

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
        return InteractiveInfoPanel.Create(parm.data, parm.parent, parm.ext)
    elseif parm.goto_scene_parm == "my_panel" then
        return InteractiveMyInfoPanel.Create(parm.data, parm.parent, parm.ext)
    elseif parm.goto_scene_parm == "chat" then
        return InteractiveChatPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return InteractiveEnterPrefab.Create(parm.parent)
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

    lister["recv_player_easy_chat"] = this.on_recv_player_easy_chat
end

function M.Init()
	M.Exit()

	this = SysInteractiveManager
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
    this.UIConfig.show_map = {}
    for k,v in ipairs(config.config) do
        this.UIConfig.show_map[v.show_type] = this.UIConfig.show_map[v.show_type] or {}
        this.UIConfig.show_map[v.show_type][#this.UIConfig.show_map[v.show_type] + 1] = v
    end
    this.UIConfig.bq_map = {}
    for k,v in ipairs(config.bq) do
        this.UIConfig.bq_map[v.id] = this.UIConfig.bq_map[v.id] or {}
        this.UIConfig.bq_map[v.id][v.sex] = v
    end

end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()

end
function M.OnEnterScene()
    
end

function M.GetBQData(tag, sex)
    local cfg = this.UIConfig.show_map[tag]
    local list = {}
    for k,v in ipairs(cfg) do
        list[#list + 1] = this.UIConfig.bq_map[v.bq_id][sex]
    end
    return list
end

function M.GetCfgFromBqId(tag, id)
    local cfg = this.UIConfig.show_map[tag]
    for k,v in ipairs(cfg) do
        if v.bq_id == id then
            return v
        end
    end
end 

function M.SetCurGamePanel(panel)
    M.cur_game_panel = panel
end
function M.on_recv_player_easy_chat(_, data)
    dump(data, "<color=red>on_recv_player_easy_chat ===========</color>")
    if M.cur_game_panel and M.cur_game_panel.GetPlayerPosByID then
        local pos1 = M.cur_game_panel:GetPlayerPosByID(data.player_id)
        local pos2 = M.cur_game_panel:GetPlayerPosByID(data.act_apt_player_id)

        if pos1 and (tag ~= 1 or pos2) then
            local ss = StringHelper.Split(data.parm, "_")
            local bq_id = tonumber(ss[1])
            local sex = tonumber(ss[2])
            local tag = tonumber(ss[3])
            local cfg = this.UIConfig.bq_map[bq_id][sex]

            if tag == 1 then
                local mt = tls.pGetLength(pos1-pos2) / 1500
                InteractiveInfoShow.Create(M.cur_game_panel.transform, {pos1=pos1, pos2=pos2, mt=mt, config=cfg})

            elseif tag == 2 then
                InteractiveChatTxtShow.Create(M.cur_game_panel.transform, {pos=pos1, config=cfg})
            elseif tag == 3 then
                InteractiveChatGifShow.Create(M.cur_game_panel.transform, {pos=pos1, config=cfg})
            else

            end
        end
    end
end
