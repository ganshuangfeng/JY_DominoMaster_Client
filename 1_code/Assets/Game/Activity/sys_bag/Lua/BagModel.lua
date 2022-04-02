-- 创建时间:2021-12-27
-- BagModel 管理器

local basefunc = require "Game/Common/basefunc"
BagModel = {}
local M = BagModel
local bag_config = GameModuleManager.ExtLoadLua(SysBagManager.key, "bag_config")
local this
local lister

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
    lister["AssetChange"] = this.AssetChange
end

function M.Init()
	M.Exit()
	this = BagModel
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
        M.InitData()
	end
end
function M.OnReConnecteServerSucceed()
end

BagModel.BagItemType = {
    Use = 0,
    Show = 1,
    Equip = 2,
    UnDefined = 3,
}

function M.InitData()
    this.m_data.pageList = {}
    if table_is_null(bag_config.page) then
        return
    end

    for i = 1, #bag_config.page do
        local page = {}
        page.cfg = bag_config.page[i]
        page.itemList = BagModel.GetItemListDataFromPageKey(page.cfg.key) or {}
        if #page.itemList > 0 then
            table.sort(page.itemList, BagHelper.SortBagItem)
        end
        this.m_data.pageList[#this.m_data.pageList + 1] = page
    end
    dump(this.m_data.pageList, "<color=white>pageList</color>")
end

function M.UpdatePageListData(pageKey)
    if table_is_null(bag_config.page) then
        return
    end

    local cfg = GameItemModel.GetItemToKey(key)
    for i = 1, #this.m_data.pageList do
        local page = this.m_data.pageList[i]
        if page.cfg.key == pageKey then
            page.itemList = BagModel.GetItemListDataFromPageKey(page.cfg.key) or {}
        end
    end
end

function M.GetPageSelectList()
    return this.m_data.pageList
end

function M.GetPageSelectShowList()
    local pageShowList = basefunc.deepcopy(this.m_data.pageList)
    for i = #this.m_data.pageList, 1, -1 do
        local page = this.m_data.pageList[i]
        if table_is_null(page.itemList) then
            table.remove(pageShowList, i)
        end
    end
    dump(pageShowList, "<color=white>pageShowList</color>")
    return pageShowList
end

function M.GetItemListDataFromPageKey(pageKey)
    local itemList = {}
    local itemListCfg = GameItemModel.GetItemListFromPageKey(pageKey)
    if table_is_null(itemListCfg) then
        return itemList
    end
    local toolMap = MainModel.UserInfo.ToolMap or {}
    for i = 1, #itemListCfg do
        local item_key = itemListCfg[i]
        local item_type = GameItemModel.GetItemToKey(item_key).item_type

        --装备类会一定显示
        if item_type and M.GetBagItemType(item_type) == BagModel.BagItemType.Equip then
            itemList[#itemList + 1] = item_key
        elseif MainModel.UserInfo[item_key] then
            if MainModel.UserInfo[item_key] > 0 then
                itemList[#itemList + 1] = item_key
            end
        elseif #toolMap > 0 then
            for k1,v1 in pairs(toolMap) do
                if v1.asset_type == item_key and (not v1.valid_time or v1.valid_time > os.time()) then
                    itemList[#itemList + 1] = item_key
                end
            end
        end
    end
    return itemList
end

function M.GetBagItemDataFromKey(itemKey)
    local bagItemData = {}
    bagItemData.baseData = GameItemModel.GetItemToKey(itemKey)
    bagItemData.amount = GameItemModel.GetItemCount(itemKey)
    bagItemData.type = M.GetBagItemType(bagItemData.baseData.item_type)
    bagItemData.isLock = false
    bagItemData.isEquip = false
    return bagItemData
end

function M.GetBagItemType(type)
    if type == "use" then
        return BagModel.BagItemType.Use
    elseif type == "show" then
        return BagModel.BagItemType.Show
    elseif type == "equip" then
        return BagModel.BagItemType.Equip
    end
    return BagModel.BagItemType.UnDefined
end

function M.AssetChange(data)
    local updatePageList = {}
    local checkIsBagUpdate = function(key)
        local cfg = GameItemModel.GetItemToKey(key)
        if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
            if not updatePageList[cfg.bag_page_key] then
                updatePageList[cfg.bag_page_key] = 1
            end
        end
    end
    if data.prop_assets_list then
        for k,v in ipairs(data.prop_assets_list) do
            checkIsBagUpdate(v.key)
        end
    end

    if data.obj_assets_list then
        for k,v in ipairs(data.obj_assets_list) do
            checkIsBagUpdate(v.key)
        end
    end

    if not table_is_null(updatePageList) then
        for k,v in pairs(updatePageList) do
            M.UpdatePageListData(k)
        end
        Event.Brocast("model_bag_asset_change")
    end
end

-- function M.Test()
--     MainModel.UserInfo["shop_gold_sum4"] = 10
--     local updatePageList = {}
--     local checkIsBagUpdate = function(key)
--         local cfg = GameItemModel.GetItemToKey(key)
--         if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
--             if not updatePageList[cfg.bag_page_key] then
--                 updatePageList[cfg.bag_page_key] = 1
--             end
--         end
--     end
--     checkIsBagUpdate("shop_gold_sum4")
--     if not table_is_null(updatePageList) then
--         for k,v in pairs(updatePageList) do
--             M.UpdatePageListData(k)
--         end
--         Event.Brocast("model_bag_asset_change")
--     end
-- end