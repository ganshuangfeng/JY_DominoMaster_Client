-- 创建时间:2021-12-06
-- SysShopManager 管理器

local basefunc = require "Game/Common/basefunc"
SysShopManager = {}
local M = SysShopManager
M.key = "sys_shop"
GameModuleManager.ExtLoadLua(M.key, "ShopPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopPrefab")
GameModuleManager.ExtLoadLua(M.key, "PayManager")
GameModuleManager.ExtLoadLua(M.key, "GameGiftManager")
GameModuleManager.ExtLoadLua(M.key, "ShopEnterPrefab")
GameModuleManager.ExtLoadLua(M.key, "ShopTagPrefab")

local config = GameModuleManager.ExtLoadLua(M.key, "shoping_config")

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
    -- GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
    if parm.goto_scene_parm == "panel" then
        return ShopPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return ShopEnterPrefab.Create(parm.parent)
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
    lister["ReceivePayOrderMsg"] = this.on_ReceivePayOrderMsg

end

function M.Init()
	M.Exit()

	this = SysShopManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    PayManager.Init()
    GameGiftManager.Init(config)
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.goods_list = {}
    this.UIConfig.tag_map = {}
    this.UIConfig.tag_list = config.tge
    for k,v in pairs(config.goods) do
        this.UIConfig.goods_list[#this.UIConfig.goods_list + 1] = v
        this.UIConfig.tag_map[v.tag] = this.UIConfig.tag_map[v.tag] or {}
        this.UIConfig.tag_map[v.tag][#this.UIConfig.tag_map[v.tag] + 1] = v
    end

    for k,v in pairs(config.jing_bi) do
        this.UIConfig.tag_map[v.tag] = this.UIConfig.tag_map[v.tag] or {}
        this.UIConfig.tag_map[v.tag][#this.UIConfig.tag_map[v.tag] + 1] = v
    end

    this.UIConfig.gift_list = {}
    for k,v in pairs(config.gift_bag) do
        this.UIConfig.gift_list[#this.UIConfig.gift_list + 1] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetProductIdsToString(fg)
    fg = fg or "#"
    local product_ids_tostring = ""
    for k,v in ipairs(this.UIConfig.goods_list) do
        if v.product_id then
            product_ids_tostring = product_ids_tostring .. v.product_id .. fg
        end
    end

    for k,v in ipairs(this.UIConfig.gift_list) do
        if v.product_id then
            product_ids_tostring = product_ids_tostring .. v.product_id .. fg
        end
    end
    
    return product_ids_tostring
end

function M.GetTagList()
    local data = {}
    for k,v in ipairs(this.UIConfig.tag_list) do
        if v.is_show == 1 then
            local b = SYSQXManager.CheckCondition({_permission_key=v.permission_key, is_on_hint = true})
            if b then
                data[#data + 1] = v
            end
        end
    end
    return data
end

function M.GetShopByTag(tag)
    local list = {}
    for k,v in ipairs(this.UIConfig.tag_map[tag]) do
        if v.is_show == 1 then
            list[#list + 1] = v
        end
    end
    return list
end

function SysShopManager.on_ReceivePayOrderMsg(data)
    if data.result == 0 then
        
    end
end

-- function SysShopManager.GetShopingConfig(data)
    
-- end

-- function SysShopManager.GetGiftShopStatusByID(data)
    
-- end
