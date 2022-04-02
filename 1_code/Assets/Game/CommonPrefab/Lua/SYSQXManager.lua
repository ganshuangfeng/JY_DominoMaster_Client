-- 创建时间:2019-11-29
-- SYSQXManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSQXManager = {}
local M = SYSQXManager
M.key = "sys_qx"
local cpm = require "Game.CommonPrefab.Lua.common_permission_manager"

local this
local lister

TagVecKey = {
    tag_new_player = "tag_new_player", --- 新人用户
    tag_free_player = "tag_free_player", --- 免费
    tag_stingy_player = "tag_stingy_player", --- 小额用户
    tag_vip_low = "tag_vip_low", --- vip 1-2
    tag_vip_mid = "tag_vip_mid", --- vip 3-6
    tag_vip_high = "tag_vip_high", --- vip 7-10
}

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

    lister["global_sysqx_uichange_msg"] = this.on_global_sysqx_uichange_msg

    -- 权限管理相关消息
    lister["model_query_system_variant_data"] = this.query_system_variant_data
    lister["on_system_variant_data_change_msg"] = this.on_system_variant_data_change_msg
    lister["on_player_permission_error"] = this.on_player_permission_error
end

local tag_name = {
    tag_new_player = "新人用户", --- 新人用户
    tag_free_player = "免费", --- 免费
    tag_stingy_player = "小额用户", --- 小额用户
    tag_vip_low = "vip 1-2", --- vip 1-2
    tag_vip_mid = "vip 3-6", --- vip 3-6
    tag_vip_high = "vip 7-10", --- vip 7-10
}
function M.debug_test()
    if this.m_data.tag_vec_map then
        local desc = ""
        for k,v in pairs(this.m_data.tag_vec_map) do
            if tag_name[k] then
                desc = desc .. "\n" .. tag_name[k]
            end
        end
        return desc
    end
end

function M.Init()
    if not this then
        M.Exit()

        this = SYSQXManager
        cpm.init(true)

        this.m_data = {}
        this.m_data.tag_vec_map = {} -- 标签map
        this.m_data.no_act_permission_map = {} -- 不能玩的活动
        MakeLister()
        AddLister()
        M.InitUIConfig()
    end
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.convert_variant_to_table( _data )
    local ret_vec = {}
    for key,data in pairs(_data) do
        local value_vec = basefunc.string.split( data.variant_value , ",")
        if value_vec then
            for _key,value in pairs(value_vec) do
                if data.variant_type == "string" then
                    value_vec[_key] = tostring( value )
                elseif data.variant_type == "number" then
                    value_vec[_key] = tonumber( value )
                end
            end
        end

        local ret = value_vec
        if data.variant_value_type == "table" then
            if not value_vec or #value_vec == 0 then
                ret = {}
            end
        end
        if data.variant_value_type == "value" then
            ret = value_vec and value_vec[1]
        end
        ret_vec[ data.variant_name ] = ret
  end
  
    -- 转成 map
    ret_vec.diff_act_permission_map = {}
    if ret_vec.diff_act_permission then
        for _,v in ipairs(ret_vec.diff_act_permission) do
            ret_vec.diff_act_permission_map[v] = true
        end
    end

    return ret_vec
end

function M.query_system_variant_data(_, data)
    dump(data, "<color=red>SYS QX query_system_variant_data</color>")
    if data.result == 0 then
        this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
        if this.m_data.permission_data.tag_vec then
            this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
            local ll = {}
            for k,v in pairs(this.m_data.tag_vec_map) do
                ll[#ll + 1] = k
            end
            for k,v in ipairs(ll) do
                this.m_data.tag_vec_map[v] = nil
            end
            for k,v in ipairs(this.m_data.permission_data.tag_vec) do
                this.m_data.tag_vec_map[v] = 1
            end
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = this.m_data.tag_vec_map or {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end

        M.InitQXGlobalVariate()
    end
end
function M.on_system_variant_data_change_msg(_, data)
    dump(data, "<color=red>SYS QX on_system_variant_data_change_msg</color>")
    this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
    if this.m_data.permission_data.tag_vec then
        this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
        local ll = {}
        for k,v in pairs(this.m_data.tag_vec_map) do
            ll[#ll + 1] = k
        end
        for k,v in ipairs(ll) do
            this.m_data.tag_vec_map[v] = nil
        end
        for k,v in ipairs(this.m_data.permission_data.tag_vec) do
            this.m_data.tag_vec_map[v] = 1
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end
    end
    Event.Brocast("client_system_variant_data_change_msg")
end
function M.on_player_permission_error(_, data)
    dump(data, "<color=red>SYS QX on_player_permission_error</color>")
    local err_tab = json2lua(data.error_desc)

    HintPanel.Create(1, err_tab.error_desc, function ()
        -- 门槛相关逻辑
        if MainModel.myLocation == "game_DdzFree"
            or MainModel.myLocation == "game_DdzPDK"
            or MainModel.myLocation == "game_Mj3D"
            or MainModel.myLocation == "game_Gobang"
            or MainModel.myLocation == "game_LHD" then
    
            local huiqu
            if MainModel.lastmyLocation then
                huiqu = MainModel.lastmyLocation
            else
                huiqu = "game_Hall"
            end
            GameManager.GotoSceneName(huiqu)
        end
    end)
end

function M.get_tag_vec_map()
    return M.m_data.tag_vec_map
end

-- 检查条件或权限
function M.CheckCondition(parm)
    local _permission_key
    local is_on_hint
    if type(parm) == "table" then
        _permission_key = parm._permission_key
        is_on_hint = parm.is_on_hint
    end
    if this.m_data.permission_data and _permission_key then
        local a,b = cpm.judge_permission_effect_client(_permission_key, this.m_data.permission_data)
        local error_desc
        local err_tab
        if b then
            -- 是不是 不要提示(调用的地方自己处理)
            err_tab = json2lua(b)
            error_desc = err_tab.error_desc
            if not is_on_hint then
                if err_tab.var == "vip_level" then
                    -- GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc=error_desc}})
	                -- SysBrokeSubsidyManager.RunBrokeProcess()
                else
                    LittleTips.Create(error_desc)
                end
            end
        end
        return a, err_tab
    else
        -- print("<color=red>CheckCondition data nil 检查条件或权限  数据为空</color>")
        return true
    end
end

-- 权限相关界面修改
-- Event.Brocast("global_sysqx_uichange_msg", {key="", panelSelf=self})
-- key
function M.on_global_sysqx_uichange_msg(parm)
    if AdvertisingManager.IsCloseAD() then
        return
    end
end

function M.Debug(key)
    local a,b = cpm.judge_permission_effect_client(key, this.m_data.permission_data)
    dump(this.m_data.permission_data , "xxx-----------------this.m_data.permission_data")
    print("<color=red>++++++++++++ permission_key ++++++++++++</color>")
    dump(a)--结果
    dump(b)--错误码
end

-- 初始化权限相关的全局变量
function M.InitQXGlobalVariate()
    local b = M.CheckCondition({_permission_key="cpl_cjj", is_on_hint=true})
    if b then
        Global_GZH = "彩云新世界"
        Global_GZH_ID = "彩云新世界"
        GameGlobalOnOff.OpenInstall = false
    else
        Global_GZH = "鲸鱼初纪元" -- 公众号
        Global_GZH_ID = "jycjy01" -- 公众号ID
        GameGlobalOnOff.OpenInstall = true
    end
end