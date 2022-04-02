-- 创建时间:2021-12-27
-- Panel:BagPageSelect
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

BagPageSelect = basefunc.class()
local C = BagPageSelect
C.name = "BagPageSelect"

function C.Create(parent, index, selectFun)
	return C.New(parent, index, selectFun)
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
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, index, selectFun)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.index = index
	self.selectFun = selectFun
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.select_btn.onClick:RemoveAllListeners()
	self.select_btn.onClick:AddListener(function()
		if self.isSelected then
			return
		end
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.selectFun then
			self.selectFun(self.index)
		end
	end)
end

function C:RemoveListenerGameObject()
	self.select_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.isSelected = false
	
	self:RefreshSelectView()
end

function C:Refresh(index, cfg)
	self.index = index
	self.cfg = cfg
	self:RefreshView()
	self:RefreshSelectView()
end

function C:RefreshView()
	-- self.page_normal_txt.text =  self.cfg.name
	-- self.page_cur_txt.text = self.cfg.name
	self.page_normal_txt.text = GLL.GetTx(self.cfg.name)
	self.page_cur_txt.text = GLL.GetTx(self.cfg.name)
end

function C:MyRefresh()
end

function C:Select()
	if not self.isSelected then
		self.page_normal.gameObject:SetActive(false)
		self.page_cur.gameObject:SetActive(true)
		self.isSelected = true
	end
end

function C:UnSelect()
	if self.isSelected then
		self.page_normal.gameObject:SetActive(true)
		self.page_cur.gameObject:SetActive(false)
		self.isSelected = false 
	end
end

function C:RefreshSelectView()
	self.page_normal.gameObject:SetActive(not self.isSelected)
	self.page_cur.gameObject:SetActive(self.isSelected)
end