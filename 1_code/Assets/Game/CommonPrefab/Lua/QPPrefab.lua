local basefunc = require "Game/Common/basefunc"

QPPrefab = basefunc.class()
local C = QPPrefab
C.name = "QPPrefab"
local instance
function C.Create()
	if instance then 
		return instance
	else
		instance = C.New()
		return instance
	end 
end

local QPType = {
	RT = 1,		--显示在右上
	LT = 2,		--显示在左上
	LB = 3,		--显示在左下
	RB = 4,		--显示在右下
}

local border = 0.25

--描述类
function C.AddShowDesc(btn, desc)
	btn.onClick:AddListener(function()
		C.ShowDesc(desc, btn.transform)
	end)
end

--物品类
function C.AddShowItem(btn, item_key)
	btn.onClick:AddListener(function()
		C.ShowItem(item_key, btn.transform)	
	end)
end

function C.Hide()
	if instance then
		instance:MyExit()
	end
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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
	instance = nil
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
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
	self.hide_btn.onClick:AddListener(function()
		self.hide_btn.gameObject:SetActive(false)
		C.Hide()
	end)
end

function C:RemoveListenerGameObject()
    self.hide_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
end


function C.ShowItem(item_key, trans)
	if not instance then
		C.Create()
	end
	instance:RefreshQPType(trans)
	local cfg = GameItemModel.GetItemToKey(item_key)
	local name = cfg.name or ""
	local desc = cfg.desc or ""
	instance:RefreshDesc(desc)
	instance.name_txt.gameObject:SetActive(true)
	instance.line.gameObject:SetActive(true)
	instance:RefreshName(name)
	instance.hide_btn.gameObject:SetActive(true)
end

function C.ShowDesc(desc, trans)
	if not instance then
		C.Create()
	end
	instance:RefreshQPType(trans)
	instance.name_txt.gameObject:SetActive(false)
	instance.line.gameObject:SetActive(false)
	instance:RefreshDesc(desc)
	instance.hide_btn.gameObject:SetActive(true)
end

function C:RefreshDesc(name)
	self.desc_txt.text = name
end

function C:RefreshName(desc)
	self.name_txt.text = desc
end

function C:RefreshQPType(trans)
	local type = QPType.RT
	local pos = trans.position or UnityEngine.Input.mousePosition
	local width = Screen.width
	local height = Screen.height
	local borderW = width * (0.5 - border)
	local borderH = height * (0.5 - border)
	if pos.x > borderW then
		if pos.y > borderH then
			type = QPType.LB
		else
			type = QPType.LT
		end
	elseif pos.y > borderH then
		type = QPType.RB
	end

	local rotation = Vector3.zero
	local isChangeChildSibling = false

	if type == QPType.LT then
		rotation = Vector3.New(0, 180, 0)
	elseif type == QPType.LB then
		rotation = Vector3.New(0, 0, -180)
		isChangeChildSibling = true
	elseif type == QPType.RB then
		rotation = Vector3.New(180, 0, 0)
		isChangeChildSibling = true
	end

	if type == QPType.LB or type == QPType.LT then
		self.layout.transform.localPosition = Vector3.New(25, 0, 0)
	else
		self.layout.transform.localPosition = Vector3.New(-25, 0, 0)
	end

	self.layout.transform.localRotation = rotation
	self.name_txt.transform.localRotation = rotation
	-- self.line.transform.localRotation = rotation
	self.desc_txt.transform.localRotation = rotation

	if isChangeChildSibling then
		self.desc_txt.transform:SetSiblingIndex(1)
		self.line.transform:SetSiblingIndex(2)
		self.name_txt.transform:SetSiblingIndex(3)
	else
		self.name_txt.transform:SetSiblingIndex(1)
		self.line.transform:SetSiblingIndex(2)
		self.desc_txt.transform:SetSiblingIndex(3)
	end

	self.layout_node.transform.position = pos
end