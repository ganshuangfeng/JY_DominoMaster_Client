-- 创建时间:2018-12-10
local basefunc = require "Game.Common.basefunc"
local item_config = require "Game.CommonPrefab.Lua.item_config"

GameItemModel = {}

local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["AssetChange"] = GameItemModel.OnAssetChange
    lister["OnLoginResponse"] = GameItemModel.OnLoginResponse
end
function GameItemModel.OnLoginResponse(result)
    if result == 0 then
        GameItemModel.InitRedData()
    end
end
-- 初始化Data
local function InitMatchData()
    GameItemModel.data={
    }
    m_data = GameItemModel.data
end

function GameItemModel.Init()
    this = GameItemModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function GameItemModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function GameItemModel.InitUIConfig()
    this.UIConfig={}

    local cfg_map = {}
    local cfg_bag = {}
    for k,v in ipairs(item_config.config) do
        v.id = nil -- 与服务器obj道具id重复
        cfg_map[v.item_key] = v
        if v.is_show_bag and v.is_show_bag == 1 then
            if v.bag_page_key then
                cfg_bag[v.bag_page_key] = cfg_bag[v.bag_page_key] or {}
                cfg_bag[v.bag_page_key] [#cfg_bag[v.bag_page_key] + 1] = v.item_key
            end
        end
    end
    -- 道具key为key
    this.UIConfig.config_map = cfg_map
    -- 道具ID为key
    this.UIConfig.config_bag = cfg_bag

    dump(this.UIConfig.config_bag, "<color=white>this.UIConfig.config_bag </color>")
end

-- tag
-- 1 大厅背包 
-- 2 捕鱼自由场背包
-- 4 捕鱼比赛场背包
-- 8 捕鱼3D自由场背包
-- 16 水族馆背包

-- 是否包含
-- function GameItemModel.IsInclude(cfg_tag, tag)
--     cfg_tag = cfg_tag or 1
--     if basefunc.bit_and(cfg_tag, tag) > 0 then
--         return true
--     end
-- end

-- 是否包含
-- function GameItemModel.GetIncludeByTag(tag)
--     if tag then
--         local list = {}
--         for k,v in pairs(this.UIConfig.config_bag) do
--             if GameItemModel.IsInclude(v.tag, tag) then
--                 list[#list + 1] = v
--             end
--         end
--         return list
--     else
--         return this.UIConfig.config_bag
--     end
-- end

-- 请求所有道具数据
function GameItemModel.ReqAllItem()
end

-- 根据道具Key获取道具tag
-- function GameItemModel.GetItemTagToKey(key)
--     local tag = 1
--     local item = GameItemModel.GetItemToKey(key)
--     if item then
--         tag = item.tag or 1
--     elseif key == "obj_fishbowl_fish" then -- 水族馆里鱼缸的鱼
--         tag = 16
--     end
--     return tag
-- end

--根据道具类型获取item的list,背包用
function GameItemModel.GetItemListFromPageKey(pageKey)
    if this.UIConfig.config_bag[pageKey] then
        return this.UIConfig.config_bag[pageKey] 
    end
end

-- 根据道具Key获取道具
function GameItemModel.GetItemToKey(key)
    if this.UIConfig.config_map[key] then
        return this.UIConfig.config_map[key] 
    end
end

-- local callSort = function (v1, v2)
--     if v1.order > v2.order then
--         return true
--     elseif v1.order < v2.order then
--         return false        
--     end
--     if v1.num < v2.num then
--         return true
--     else
--         return false
--     end
-- end


-- 根据背包道具数据
-- function GameItemModel.GetBagItem(tag)
--     local data = {}
--     local list = GameItemModel.GetIncludeByTag(tag or 1)

--     for k,v in pairs(list) do
--         if MainModel.UserInfo[v.item_key] then
--             local vv = {}
--             for k1, v1 in pairs(v) do
--                 vv[k1] = v1
--             end
--             vv.num = MainModel.UserInfo[v.item_key]
--             if vv.num > 0 then
--                 data[#data + 1] = vv
--             end
--         else
--             if not MainModel.UserInfo.ToolMap then
--                 MainModel.UserInfo.ToolMap = {}
--             end
--             for k1,v1 in pairs(MainModel.UserInfo.ToolMap) do
--                 if v1.asset_type == v.item_key and (not v1.valid_time or v1.valid_time > os.time()) then
--                     local vv = {}
--                     for k1, v1 in pairs(v) do
--                         vv[k1] = v1
--                     end
--                     if v1.valid_time then
--                         local nn = v1.valid_time
--                         local days = math.ceil((tonumber(nn) - os.time()) / 3600)
--                         vv.date = days
--                     end
--                     vv.num = v1.num or -1
--                     data[#data + 1] = vv
--                     for k2, v2 in pairs(v1) do
--                         vv[k2] = v2
--                     end
--                 end
--             end
--         end
--     end
--     MathExtend.SortListCom(data, callSort)
--     return data
-- end

function GameItemModel.GetItemCount(itemKey)
    if not itemKey then
        return 0
    end
    local n = MainModel.UserInfo[itemKey] or -1
    if n < 0 and MainModel.UserInfo.ToolMap then
        local curT = os.time()
        for k, v in pairs(MainModel.UserInfo.ToolMap) do
            if v.asset_type == itemKey and (v.valid_time and tonumber(v.valid_time) > curT) then
                n = math.max(0, n) + (v.num or 1)
            end
        end
    end
    if n < 0 then
        n = 0
    end
    return n
end

function GameItemModel.IsTimeLimitedItem(itemKey)
    local ret = false
    if itemKey and MainModel.UserInfo.ToolMap then
        for _, v in pairs(MainModel.UserInfo.ToolMap) do
            if v.asset_type == itemKey then
                ret = true
                break
            end
        end
    end
    return ret
end

-- 根据道具ID获取道具
function GameItemModel.GetToolDataByID(id)
    local ret
    if id and MainModel.UserInfo.ToolMap and MainModel.UserInfo.ToolMap[id] then
        local v = MainModel.UserInfo.ToolMap[id]
        ret = {}
        local cfg = GameItemModel.GetItemToKey(v.asset_type)
        for k1, v1 in pairs(cfg) do
            ret[k1] = v1
        end
        for k1, v1 in pairs(v) do
            ret[k1] = v1
        end
    end
    return ret
end


function GameItemModel.GetUseToolCount(tarKey, itemKeys, itemCount)
    local cost = 0
    if tarKey and itemKeys and itemCount and #itemKeys <= #itemCount then
        for i, k in ipairs(itemKeys) do
            if k == tarKey then
                cost = itemCount[i]
                break
            end
        end
    end
    return cost
end

-- 背包道具红点功能
local function getRedDataPath()
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return path
end
local function getRedDataToDescPath()
    return getRedDataPath() .. "/bag_item_red.txt"
end
-- 加载
local function LoadRedData()
    local ok, _data = xpcall(function ()
        local path = getRedDataPath()
        if not Directory.Exists(path) then
            Directory.CreateDirectory(path)
        end
        path = getRedDataToDescPath()
        if not File.Exists(path) then
            return
        end
        local data = File.ReadAllText(path)
        if not data or data == "" then
            return
        end
        local list = {}
        local ns = StringHelper.Split(data, ",")
        for _,v in ipairs(ns) do
            list[#list + 1] = v
        end
        return list
    end
    ,function (err)
        print(err)
    end)

    return _data
end
-- 保存
local function SaveRedData(list)
    -- 最快30秒保存一次(非重要功能无需浪费太多资源)
    -- if not m_data.last_save_time or ( os.time()-m_data.last_save_time ) > 30 then
        m_data.last_save_time = os.time()

        local ok = xpcall(function ()
            local path = getRedDataPath()
            if not Directory.Exists(path) then
                Directory.CreateDirectory(path)
            end

            path = getRedDataToDescPath()
            local idstr = ""
            for i,v in ipairs(list) do
                idstr = idstr .. v .. ","
            end
            File.WriteAllText(path, idstr)
        end
        ,function (err)
            print(err)
        end)
    -- end
end
function GameItemModel.AddOrDelRedItem(id, is_add)
    m_data.item_red_data = m_data.item_red_data or {}
    m_data.item_red_data.red_map = m_data.item_red_data.red_map or {}
    m_data.item_red_data.red_list = m_data.item_red_data.red_list or {}

    if is_add then
        m_data.item_red_data.red_map[id] = 1
        m_data.item_red_data.red_list[#m_data.item_red_data.red_list + 1] = id
    else
        m_data.item_red_data.red_map[id] = nil
        for k,v in ipairs(m_data.item_red_data.red_list) do
            if v == id then
                table.remove(m_data.item_red_data.red_list, k)
                break
            end
        end
    end
end

function GameItemModel.InitRedData()
    m_data.item_red_data = {}
    m_data.item_red_data.red_list = {}
    m_data.item_red_data.red_map = {}

    local list = LoadRedData()
    local b = false
    if list then
        for i = #list, 1, -1 do
            local n = GameItemModel.GetItemCount(list[i])
            if n > 0 then
                m_data.item_red_data.red_list[#m_data.item_red_data.red_list + 1] = list[i]
                m_data.item_red_data.red_map[ list[i] ] = 1
            else
                b = true
                table.remove(list, i)
            end
        end
    end
    if b then
        SaveRedData(list)
    end

    Event.Brocast("UpdateHallBagRedHint")
end
function GameItemModel.OnAssetChange(data)
    local b = false
    if data.prop_assets_list then
        for k,v in ipairs(data.prop_assets_list) do
            if v.type == "add" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if not m_data.item_red_data or not m_data.item_red_data.red_map or not m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, true)
                    end
                end
            elseif v.type == "del" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, false)
                    end
                end
            end
        end
    end
    if data.obj_assets_list then
        for k,v in ipairs(data.obj_assets_list) do
            if v.type == "add" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if not m_data.item_red_data or not m_data.item_red_data.red_map or not m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, true)
                    end
                end
            elseif v.type == "del" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, false)
                    end
                end
            end
        end
    end

    if b then
        SaveRedData(m_data.item_red_data.red_list)
        Event.Brocast("UpdateHallBagRedHint")
    end
end

-- 背包红点
function GameItemModel.IsBagRadByTag(tag)
    -- local _tag = tag or 1
    -- if m_data.item_red_data and m_data.item_red_data.red_list then
    --     for k,v in ipairs(m_data.item_red_data.red_list) do
    --         local t
    --         if MainModel.UserInfo.ToolMap[v] then
    --             t = GameItemModel.GetItemTagToKey( MainModel.UserInfo.ToolMap[v].asset_type )
    --         else
    --             t = GameItemModel.GetItemTagToKey( v )
    --         end
    --         if basefunc.bit_and(_tag, t) > 0 then
    --             return true
    --         end
    --     end
    -- end
    return false
end
-- 某个道具的红点状态
function GameItemModel.GetItemRadByKey(key)
    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[key] then
        return true
    end
    return false
end

-- 某个道具的红点状态
function GameItemModel.SetItemRadByKey(key, b)
    GameItemModel.AddOrDelRedItem(key, b)

    SaveRedData(m_data.item_red_data.red_list)
    Event.Brocast("UpdateHallBagRedHint")
end
