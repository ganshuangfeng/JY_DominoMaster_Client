-- 创建时间:2021-12-28
-- Panel:BagItemPageNumGroup
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

BagItemPageNumGroup = basefunc.class()
local C = BagItemPageNumGroup
C.name = "BagItemPageNumGroup"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.pageNumList = {}
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshBagItemAllPageNum(list)
	self:ClearAllPageNum()
	self.curPageIndex = -1
	self.lastPageIndex = -1

	self.list = list
	for i = 1, #self.list do
		local pageNum = {}
		pageNum.obj = newObject("BagItemPageNum", self.transform)
		pageNum.dianliangObj = pageNum.obj.transform:Find("dianliang")
		pageNum.dianliang = function()
			pageNum.dianliangObj.gameObject:SetActive(true)
		end
		pageNum.cancelDianliang = function()
			pageNum.dianliangObj.gameObject:SetActive(false)
		end
		self.pageNumList[#self.pageNumList + 1] = pageNum
	end
	self:RefreshBagItemPageNum(1)
end

function C:RefreshBagItemPageNum(index)
	self.lastPageIndex = self.curPageIndex
	self.curPageIndex = index

	local lastItem = self.pageNumList[self.lastPageIndex]
	if lastItem then
		lastItem.cancelDianliang()
	end
	local curItem = self.pageNumList[self.curPageIndex]
	if curItem then
		curItem.dianliang()
	end
end

function C:ClearAllPageNum()
	local len = #self.pageNumList
	if len > 0 then
		for i = 1, len do
			destroy(self.pageNumList[#self.pageNumList].obj.gameObject)
			self.pageNumList[#self.pageNumList] = nil
		end
	end
end
