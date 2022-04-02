-- 创建时间:2021-12-27
-- Panel:BagPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

BagPanel = basefunc.class()
local C = BagPanel
C.name = "BagPanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["model_bag_asset_change"] = basefunc.handler(self, self.on_model_bag_asset_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	EventTriggerListener.Get(self.bagItemScroll.gameObject).onEndDrag = function()
		self:OnBagItemScrollEnd()
	end
	EventTriggerListener.Get(self.bagItemScroll.gameObject).onBeginDrag = function()
		self:OnBagItemScrollBegin()
	end
end

function C:RemoveListenerGameObject()
    self.close_btn.onClick:RemoveAllListeners()
	EventTriggerListener.Get(self.bagItemScroll.gameObject).onEndDrag = nil
	EventTriggerListener.Get(self.bagItemScroll.gameObject).onBeginDrag = nil
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:on_model_bag_asset_change()
	--资产改变时，刷新背包显示
	self:RefreshPageSelects()
end

function C:InitUI()
	self.curPageIndex = -1
	self.lastPageIndex = -1
	self.curBagItemIndex = -1
	self.lastBagItemIndex = -1
	self.pageSelectItems = {}
	self.groupItems = {}
	self.bagItems = {}
	self.bagItemMap = {}
	
	self:InitBagItemPageNum()
	self:InitBagItemInfo()
	self.pageSelectScroll = self.transform:Find("ScrollView1"):GetComponent("ScrollRect")
	self.bagItemScroll = self.transform:Find("ScrollView2"):GetComponent("ScrollRect")

	self:RefreshPageSelects()
	self.bagItemScroll.horizontal = false
	-- self:AddGroupItem(1)
	if #self.pageSelectList > 0 then
		self:SelectPage(1)
	else
		self.info_node.gameObject:SetActive(false)
		self.empty.gameObject:SetActive(true)
	end
	
	

	self.test_btn.gameObject:SetActive(false)
	-- self.test_btn.onClick:AddListener(function()
	-- 	BagModel.Test()
	-- end)
	
	self.pageSelectScroll = self.transform:Find("ScrollView1"):GetComponent("ScrollRect")
	self.bagItemScroll = self.transform:Find("ScrollView2"):GetComponent("ScrollRect")
	
	self:MyRefresh()
end

function C:InitBagItemPageNum()
	self.bagItemPageNumGroup = BagItemPageNumGroup.Create(self.page_num_node)
end

function C:InitBagItemInfo()
	self.bagItemInfo = BagItemInfo.Create(self.info_node, self)
end

function C:MyRefresh()

end

function C:SelectPage(index)
	dump("SelectPage " .. index)
	self.lastPageIndex = self.curPageIndex
	self.curPageIndex = index
	local lastPageItem = self.pageSelectItems[self.lastPageIndex]
	if lastPageItem then
		lastPageItem:UnSelect()
	end
	local curPageItem = self.pageSelectItems[self.curPageIndex]
	if curPageItem then
		curPageItem:Select()
	end
	lastPageItem, curPageItem = nil
	self:RefreshBagItems()
	self:RefreshBagItemAllPageNum()
	self:SelectBagItem(1)
end

function C:AddPageSelectItem(addNum)
	local selectPageFun = function(index)
		self:SelectPage(index)
	end

	for i = 1, addNum do
		local pageItem = BagPageSelect.Create(self.page_content, 0, selectPageFun)	
		self.pageSelectItems[#self.pageSelectItems + 1] = pageItem
	end
end

function C:DelPageSelectItem(delNum)
	for i = 1, delNum do
		self.pageSelectItems[#self.pageSelectItems]:MyExit()
		self.pageSelectItems[#self.pageSelectItems] =  nil
	end
end

function C:RefreshPageSelects()
	-- self.pageSelectList = BagModel.GetPageSelectList()
	self.pageSelectList = BagModel.GetPageSelectShowList()
	if table_is_null(self.pageSelectList) then
		return
	end
	if #self.pageSelectItems < #self.pageSelectList then
		self:AddPageSelectItem(#self.pageSelectList - #self.pageSelectItems)
	elseif #self.pageSelectItems > #self.pageSelectList then
		self:DelPageSelectItem(#self.pageSelectItems - #self.pageSelectList)
	end
	for i = 1, #self.pageSelectList do
		self.pageSelectItems[i]:Refresh(i, self.pageSelectList[i].cfg)
	end

	self.page_content.gameObject:SetActive(#self.pageSelectList > 1)
end

function C:SelectBagItem(index)
	self.lastBagItemIndex = self.curBagItemIndex
	self.curBagItemIndex = index
	local lastBagItem = self.bagItems[self.lastBagItemIndex]
	if lastBagItem then
		lastBagItem:CancelSelect()
	end
	local curBagItem = self.bagItems[self.curBagItemIndex]
	if curBagItem then
		curBagItem:Select()
	end
	local itemKey = self.bagItemList[self.curBagItemIndex]
	if itemKey then
		self:RefreshBagItemInfo(itemKey)
	end
	lastBagItem, curBagItem = nil
end

function C:AddGroupItem(addGroupNum)
	for i = 1, addGroupNum do
		local b = newObject("BagItemGridGrop", self.group_content)
		self.groupItems[#self.groupItems + 1] = b
	end
end

function C:DelGroupItem(delGroupNum)
	for i = 1, delGroupNum do
		destroy(self.groupItems[#self.groupItems].gameObject)
		self.groupItems[#self.groupItems] = nil
	end
end

function C:AddBagItem(addNum)
	self.bagItemMap = BagHelper.AddNumToGridGroupMap(self.bagItemMap, addNum)
	local addGroupNum = #self.bagItemMap - #self.groupItems
	if addGroupNum > 0 then
		self:AddGroupItem(addGroupNum)
	end
	local selectBagItemFun = function(index)
		self:SelectBagItem(index)
	end

	for i = 1, #self.bagItemMap do
		for j = 1, #self.bagItemMap[i] do
			if self.bagItemMap[i][j] > #self.bagItems then
				local bagitems = self.groupItems[i].transform:Find("bagitems")
				local bagItem = BagItem.Create(bagitems.transform, 0, selectBagItemFun)	
				self.bagItems[#self.bagItems + 1] = bagItem
			end
		end
	end
end

function C:DelBagItem(delNum)
	for i = 1, delNum do
		self.bagItems[#self.bagItems]:MyExit()
		self.bagItems[#self.bagItems] = nil
	end
	
	self.bagItemMap = BagHelper.DelNumToGridGroupMap(self.bagItemMap, delNum)
	local delGroupNum = #self.groupItems - #self.bagItemMap
	if delGroupNum > 0 then
		self:DelGroupItem(delGroupNum)
	end
end

function C:RefreshBagItems()
	self.bagItemScroll.horizontalNormalizedPosition = 0
	self.bagItemList = self.pageSelectList[self.curPageIndex].itemList
	if table_is_null(self.bagItemList) then
		return
	end
	-- dump(#self.bagItems .. "--->" .. #self.bagItemList)
	if #self.bagItems < #self.bagItemList then
		self:AddBagItem(#self.bagItemList - #self.bagItems)
	elseif #self.bagItems > #self.bagItemList then
		self:DelBagItem(#self.bagItems - #self.bagItemList)
	end

	for i = 1, #self.bagItemMap do
		for j = 1, #self.bagItemMap[i] do
			local itemIndex = self.bagItemMap[i][j]
			if self.bagItemList[itemIndex] then
				self.bagItems[itemIndex]:RefreshItem(itemIndex, self.bagItemList[itemIndex])
			end
		end
	end

	self.bagItemScroll.horizontal = (#self.bagItemMap > 1)
end

function C:OnBagItemScrollBegin()
	if table_is_null(self.bagItemPagePosList) then
		return
	end
	self.startHNormalized = self.bagItemScroll.horizontalNormalizedPosition
end

function C:OnBagItemScrollEnd()
	if table_is_null(self.bagItemPagePosList) then
		return
	end
	local hNormalized = self.bagItemScroll.horizontalNormalizedPosition  
	--1为向右移动，-1为向左移动
	local scrollDirect = hNormalized - self.startHNormalized > 0 and 1 or -1 
	self.bagItemPageIndex = BagHelper.NearIndexInNormalizedList(self.bagItemPagePosList, hNormalized, scrollDirect)
	self.DT = DG.Tweening.DOTween.To(
		DG.Tweening.Core.DOGetter_float(function(value)
				return hNormalized 
			end),
		DG.Tweening.Core.DOSetter_float(function(value)
				if IsEquals(self.gameObject) then
					self.bagItemScroll.horizontalNormalizedPosition = value
				end
			end),
		self.bagItemPagePosList[self.bagItemPageIndex], 0.35
	):OnComplete(
		function()
			self:RefreshBagItemPageNum()
		end 
	):SetEase(Enum.Ease.OutCubic)
end
function C:RefreshBagItemAllPageNum()
	self.bagItemPagePosList = BagHelper.BagItemPagePosListFromMap(self.bagItemMap)
	self.bagItemPageNumGroup:RefreshBagItemAllPageNum(self.bagItemPagePosList)
end

function C:RefreshBagItemPageNum()
	self.bagItemPageNumGroup:RefreshBagItemPageNum(self.bagItemPageIndex)
end

function C:RefreshBagItemInfo(itemKey)
	self.bagItemInfo:RefreshInfo(itemKey)
end
