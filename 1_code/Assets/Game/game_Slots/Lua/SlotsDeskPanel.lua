-- 创建时间:2021-12-17
-- Panel:SlotsDeskPanel
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

SlotsDeskPanel = basefunc.class()
local M = SlotsDeskPanel
M.name = "SlotsDeskPanel"

local instance
function M.Create()
	if instance then
		instance:MyExit()
	end
	instance = M.New()
	M.Instance = instance
	return instance
end

function M.Close()
	if not instance then
		return
	end
	instance:MyExit()
end

function M.Refresh()
	if not instance then
		return
	end
	instance:MyRefresh()
end

function M.Show(b)
	if not instance then
		return
	end
	instance.gameObject:SetActive(b)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()

	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	
end

function M:MyRefresh()
	self:RefreshItem()

end

--根据当前状态刷新元素
function M:RefreshItem()
	if not SlotsModel.data or not next(SlotsModel.data)
	or not SlotsModel.data.baseData or not next(SlotsModel.data.baseData)
	or not SlotsModel.data.baseData.mainData.itemDataMap or not next(SlotsModel.data.baseData.mainData.itemDataMap) then
		self:ClearItem()
		return
	end
	local itemDataMap = SlotsModel.data.baseData.mainData.itemDataMap
	local rateMapItemE = SlotsModel.data.baseData.mainData.rateMapItemE

	for x, v in pairs(self.itemGOMap or {}) do
		for y, item in pairs(v) do
			if not itemDataMap[x] or not itemDataMap[x][y] then
				self:RemoveItem(x,y)
			end
		end
	end
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			local rate = SlotsLib.GetMapValue(rateMapItemE,x,y)
			if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] then
				if self.itemGOMap[x][y].data.id ~= id then
					--有元素，但是id不同
					self.itemGOMap[x][y]:SetId(id)
					self.itemGOMap[x][y]:SetRate(rate)
				end
			else
				self:AddItem(id,x,y,rate)
			end
		end
	end
end

function M:AddItem(id,x,y,rate)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsItem.Create({id = id,x = x,y = y,rate = rate,parent = self.item_content})
end

function M:RemoveItem(x,y)
	if not self.itemGOMap or not self.itemGOMap[x] or not self.itemGOMap[x][y] then
		return
	end
	self.itemGOMap[x][y]:Exit()
	self.itemGOMap[x][y] = nil
end

function M:ClearItem()
	if not self.itemGOMap or not next(self.itemGOMap) then
		return
	end
	for x, value in pairs(self.itemGOMap) do
		for y, item in pairs(value) do
			item:Exit()
		end
	end
	self.itemGOMap = nil
end

function M:GetItemMap()
	return self.itemGOMap
end

