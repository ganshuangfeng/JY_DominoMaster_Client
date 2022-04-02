-- 创建时间:2021-12-22
-- Panel:VIPPanel
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

VIPPanel = basefunc.class()
local C = VIPPanel
C.name = "VIPPanel"

local instance
function C.Create()
	if instance then
		return instance
	end
	instance = true
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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	instance = nil
	if self.cur_pre then
		self.cur_pre:OnDestroy()
	end
	self.cur_pre = nil
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
	instance = self
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.back_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	

	self.page_list = {}
	self.page_list[1] = {index=1, cls="VIPTQPrefab", txt=20017}

	self.select_index = 1
	
	self.cell_list = {}
	for k,v in ipairs(self.page_list) do
		local pre = VIPPagePrefab.Create(self.page_node, v, self, self.OnCellClick)
		self.cell_list[v.index] = pre
	end
	if #self.page_list > 1 then
		self.page_node.gameObject:SetActive(true)
	else
		self.page_node.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshSelect()
end

function C:RefreshSelect()
	if self.cur_pre then
		self.cur_pre:OnDestroy()
	end
	self.cur_pre = nil

	local cfg = self.page_list[self.select_index]
	self.cur_pre = _G[cfg.cls].Create(self.center, self)

	for k,v in pairs(self.cell_list) do
		if k == self.select_index then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end
end

function C:OnCellClick(data)
	if self.select_index ~= data.index then
		self.select_index = data.index
		self:RefreshSelect()
	end
end