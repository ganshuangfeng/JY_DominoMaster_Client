-- 创建时间:2021-12-15
-- Panel:SlotsLionHelpPanel
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

SlotsLionHelpPanel = basefunc.class()
local M = SlotsLionHelpPanel
M.name = "SlotsLionHelpPanel"

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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.pageAmount = 3
	self.curPageIndex = -1
	self.lastPageIndex = -1
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()

	self:MyRefresh()
end

function M:InitUI()
	self:InitHelpList()
	self:InitPageNumList()
	self.back_btn.onClick:AddListener(function()
		self:BackToGame()
	end)
	self.last_btn.onClick:AddListener(function()
		self:LastPage()
	end)
	self.next_btn.onClick:AddListener(function()
		self:NextPage()
	end)
	self:InitPageShow()
end

function M:InitPageShow()
	self.curPageIndex = 1
	self:ChangePage()
end

function M:InitHelpList()
	self.helpList = {}
	for i = 1, self.pageAmount do
		local help = {}
		help.preName = "SlotsLionHelpItem" .. i
		help.isLoad = false
		help.obj = nil
		self.helpList[#self.helpList + 1] = help
	end
end

--初始化页码
function M:InitPageNumList()
	self.pageNumList = {}
	for i = 1, self.pageAmount do
		local pageNum = {}
		pageNum.isSelected = false
		pageNum.obj = newObject("SlotsLionHelpPageNum", self.pagenums)
		pageNum.dianliangObj = pageNum.obj.transform:Find("dianliang")
		pageNum.select = function()
			pageNum.dianliangObj.gameObject:SetActive(true)
			pageNum.isSelected = true
		end
		pageNum.unSelect = function()
			pageNum.dianliangObj.gameObject:SetActive(false)
			pageNum.isSelected = false
		end
		self.pageNumList[#self.pageNumList + 1] = pageNum
	end
end

function M:ViewHelp(index)
	if not self.helpList[index] then
		if index > 0 then 
			dump("Slot Help Error: ViewHelp index out range")
		end
		return
	end

	local help = self.helpList[index]

	if not help.isLoad then
		help.obj = newObject(help.preName, self.helps)
		help.isLoad = true
	end	

	help.obj.gameObject:SetActive(true)
end

function M:HideHelp(index)
	if not self.helpList[index] then
		if index > 0 then 
			dump("Slot Help Error: HideHelp index out range")
		end
		return
	end

	local help = self.helpList[index]
	
	if help.isLoad then
		help.obj.gameObject:SetActive(false)
	end
end

function M:LastPage()
	if self.curPageIndex > 1 then
		self.lastPageIndex = self.curPageIndex
		self.curPageIndex = self.curPageIndex - 1
	else
		self.lastPageIndex = self.curPageIndex
		self.curPageIndex = self.pageAmount
	end
	self:ChangePage()
end

function M:NextPage()
	if self.curPageIndex < self.pageAmount then
		self.lastPageIndex = self.curPageIndex
		self.curPageIndex = self.curPageIndex + 1
	else
		self.lastPageIndex = self.curPageIndex
		self.curPageIndex = 1
	end
	
	self:ChangePage()
end

function M:BackToGame()
	M.Show(false)
end

function M:ChangePage()
	self:ViewHelp(self.curPageIndex)
	self:HideHelp(self.lastPageIndex)
	self:RefreshBtnView()
	self:RefreshPageNum()
end

function M:RefreshBtnView()
	-- if self.curPageIndex == 1 then
	-- 	self.last_btn.gameObject:SetActive(false)
	-- elseif self.curPageIndex == self.pageAmount then
	-- 	self.next_btn.gameObject:SetActive(false)
	-- end
	-- if self.lastPageIndex == 1 then
	-- 	self.last_btn.gameObject:SetActive(true)
	-- elseif self.lastPageIndex == self.pageAmount then
	-- 	self.next_btn.gameObject:SetActive(true)
	-- end
end

function M:RefreshPageNum()
	if self.pageNumList[self.curPageIndex] then
		local pageNum = self.pageNumList[self.curPageIndex]
		if not pageNum.isSelected then
			pageNum.select()
		end
	end

	if self.pageNumList[self.lastPageIndex] then
		local pageNum = self.pageNumList[self.lastPageIndex]
		if pageNum.isSelected then
			pageNum.unSelect()
		end
	end
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:MyRefresh()
	M.Show(false)
end
