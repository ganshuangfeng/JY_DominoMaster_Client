-- 创建时间:2021-12-27
-- Panel:BagItem
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

BagItem = basefunc.class()
local C = BagItem
C.name = "BagItem"

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
	self.selectFun = selectFun

	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitState()
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
	self:MyRefresh()
end

function C:InitState()
	self.isSelected = false
	self.isLock = false
	self.isEquip = false

	self.isActiveEquip = true
	self.isActiveAmount = true
	self.isActiveLock = true
end

function C:MyRefresh()
end

function C:RefreshItem(index, item_key)
	self.index = index
	self.item_key = item_key	
	self.itemData = BagModel.GetBagItemDataFromKey(self.item_key)
	self:RefreshView()
end

function C:RefreshView()
	if self.itemData.type == BagModel.BagItemType.Use then
		self:ActiveEquip(false)
		self:ActiveLock(false)
		self:ActiveAmount(true)
	elseif self.itemData.type == BagModel.BagItemType.Show then
		self:ActiveEquip(false)
		self:ActiveLock(false)
		self:ActiveAmount(true)
	elseif self.itemData.type == BagModel.BagItemType.Equip then
		self:ActiveEquip(true)
		self:ActiveLock(true)
		self:ActiveAmount(false)
	end

	self:RefreshIconView()

	if self.isActiveAmount then
		self:RefreshNumView()
	end

	if self.isActiveLock then
		self:RefreshLockView()
	end

	if self.isActiveEquip then
		self:RefreshEquipView()
	end
end

function C:ActiveAmount(isActive)
	self.amount_txt.gameObject:SetActive(isActive)
	self.isActiveAmount = isActive
end

function C:ActiveEquip(isActive)
	self.equip_container.gameObject:SetActive(isActive)
	self.isActiveEquip = isActive
end

function C:ActiveLock(isActive)
	self.lock_container.gameObject:SetActive(isActive)
	self.isActiveLock = isActive
end

function C:RefreshIconView()
	self.icon_img.sprite = GetTexture(self.itemData.baseData.image)
end

function C:RefreshNumView()
	self.amount_txt.text = self.itemData.amount
end

function C:RefreshLockView()
	if self.itemData.isLock then
		self:Lock()
	else
		self:Unlock()
	end
end

function C:RefreshEquipView()
	if self.itemData.isEquip then
		self:Equip()
	else
		self:UnEquip()
	end
end

function C:Select()
	if not self.selectedObj then
		self.selectedObj = newObject("BagItemSelected", self.select_container)
	else
		self.selectedObj.gameObject:SetActive(true)
	end
	self.isSelected = true
end

function C:CancelSelect()
	if self.selectedObj then
		self.selectedObj.gameObject:SetActive(false)
	end
	self.isSelected = false
end

function C:Lock()
	if not self.lockObj then
		self.lockObj = newObject("BagItemLock", self.lock_container)
	else
		self.lockObj.gameObject:SetActive(true)
	end
	self.isLock = true
end

function C:Unlock()
	if self.lockObj then
		self.lockObj.gameObject:SetActive(false)
	end
	self.isLock = false
end

function C:Equip()
	if not self.equipObj then
		self.equipObj = newObject("BagItemEquipTip", self.equip_container)
	else
		self.equipObj.gameObject:SetActive(true)
	end
	self.isEquip = true
end

function C:UnEquip()
	if self.equipObj then
		self.equipObj.gameObject:SetActive(false)
	end
	self.isEquip = false
end