-- 创建时间:2019-06-18
-- Panel:ActivityYearLeftPrefab
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
 --]]

local basefunc = require "Game/Common/basefunc"

ActivityYearLeftPrefab = basefunc.class()
local C = ActivityYearLeftPrefab
C.name = "ActivityYearLeftPrefab"
local M = SYSACTBASEManager

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["UpdateHallActivityYearRedHint"] = basefunc.handler(self, self.RefreshRedHint)
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

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index
	self.gotoUI = {}
	self.style_config = M.GetStyleConfig(self.panelSelf.goto_type)
	SetTempParm(self.gotoUI, self.config.gotoUI, "panel")

	self.prefab_name = "ActivityYearLeftPrefab_" .. self.style_config.style_type
    if not self.style_config.prefab_map[self.prefab_name] or not GetPrefab(self.prefab_name) then
        self.prefab_name = "ActivityYearLeftPrefab"
    end
	local obj = newObject(self.prefab_name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.select_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
end

function C:RemoveListenerGameObject()
	self.select_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
	self.Selected.gameObject:SetActive(false)
	self.gameObject.name = "left_pre" .. self.index
	self.title1_txt.text = self.config.title
	self.title2_txt.text = self.config.title

	if self.config.tag then
		if self.config.tag == "hot" then
			self.HotHint.gameObject:SetActive(true)
		end
	else
		self.HotHint.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshRedHint()
end

function C:SetSelect(b)
	self.Normal.gameObject:SetActive(not b)
	self.Selected.gameObject:SetActive(b)
	if b then
		M.CloseActiveRedHint(self.config.ID)
		self:RefreshRedHint()
	end
end

-- 点击
function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.index)
	end
	self:RefreshRedHint()
end

function C:RefreshRedHint()
	local isRed = M.IsActiveRedHint(self.config.ID)
	local isGet = M.IsActiveGetHint(self.config.ID)
	self.RedHint.gameObject:SetActive(isRed or isGet)
	-- self.GetImage.gameObject:SetActive(isGet)
end
