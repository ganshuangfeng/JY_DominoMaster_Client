-- 创建时间:2021-12-28
-- Panel:BagItemInfo
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

BagItemInfo = basefunc.class()
local C = BagItemInfo
C.name = "BagItemInfo"

function C.Create(parent, parentSelf)
	return C.New(parent, parentSelf)
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

function C:ctor(parent, parentSelf)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parentSelf = parentSelf
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
	self.name_txt.text = ""
	self.amount_txt.text = ""
	self.desc_txt.text = ""
	self.info_btn.gameObject:SetActive(false)
	self.icon_img.gameObject:SetActive(false)
	self:InitState()
	-- self:ActiveInfoImg(false)
	-- self:ActiveInfoBtn(false)
	self:MyRefresh()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	
end

function C:RemoveListenerGameObject()
	self.info_btn.onClick:RemoveAllListeners()
end

function C:InitState()
	self.isActiveGet = false
	self.isActiveUse = false
	self.isActiveEquip = false

	self.isActiveIconImg = false
	self.isActiveInfoBtn = false
end

function C:MyRefresh()
end

function C:RefreshInfo(item_key)
	dump("item_key = " .. item_key)
	self.item_key = item_key
	self.itemData = BagModel.GetBagItemDataFromKey(self.item_key)
	self:RefreshView()
end

function C:RefreshView()
	self.isActiveUse, self.isActiveLock, self.isActiveEquip = false, false, false
	self:ActiveInfoBtn(false)
	if self.itemData.type == BagModel.BagItemType.Use then
		self.isActiveUse = true
	elseif self.itemData.type == BagModel.BagItemType.Show then
	elseif self.itemData.type == BagModel.BagItemType.Equip then
		self.isActiveLock = self.itemData.isLock
		self.isActiveEquip = self.itemData.isEquip
	end

	self:RefreshIconView()
	self:RefreshNameView()
	self:RefreshDescView()
	self:RefreshAmountView()

	if self.isActiveUse then
		self:ActiveInfoBtn(true)
		self:RefreshUseBtnView()
	end

	if self.isActiveGet then
		self:ActiveInfoBtn(true)
		self:RefreshGetBtnView()
	end

	if self.isActiveEquip then
		self:ActiveInfoBtn(true)
		self:RefreshEquipBtnView()
	end
end

function C:ActiveInfoBtn(isActive)
	if not isActive then
		self.info_btn.onClick:RemoveAllListeners()
	end

	if self.isActiveInfoBtn == not isActive then
		self.info_btn.gameObject:SetActive(isActive)
		self.isActiveInfoBtn = isActive
	end
end

function C:ActiveInfoImg(isActive)
	if self.isActiveIconImg == not isActive then
		self.icon_img.gameObject:SetActive(isActive)
		self.isActiveIconImg = isActive
	end
end

function C:RefreshUseBtnView()
	-- self.info_btn_txt.text = "使用"
	self.info_btn_txt.text = GLL.GetTx(70005)
	self.info_btn.onClick:RemoveAllListeners()
	self.info_btn.onClick:AddListener(function()
		dump("使用")
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local gotoUI = self.itemData.baseData.use_parm 
		if not gotoUI then
			return
		end
		if type(gotoUI) == "table" then
			GameManager.GotoUI({gotoui = gotoUI[1], goto_scene_parm = gotoUI[2]})
		else
			GameManager.GotoUI({gotoui = gotoUI})
		end
		self.parentSelf:MyExit()
	end)
	self.get_way_txt.gameObject:SetActive(false)
end

function C:RefreshGetBtnView()
	-- self.info_btn_txt.text = "获取"
	self.info_btn_txt.text = GLL.GetTx(20032)
	self.info_btn.onClick:RemoveAllListeners()
	self.info_btn.onClick:AddListener(function()
		dump("获取")
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	end)
end

function C:RefreshEquipBtnView()
	-- self.info_btn_txt.text = "穿戴"
	self.info_btn_txt.text = GLL.GetTx(20033)
	self.info_btn.onClick:RemoveAllListeners()
	self.info_btn.onClick:AddListener(function()
		dump("穿戴")
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	end)
	self.get_way_txt.gameObject:SetActive(true)
end

function C:RefreshIconView()
	self:ActiveInfoImg(true)
	self.icon_img.sprite = GetTexture(self.itemData.baseData.image)
end

function C:RefreshNameView()
	self.name_txt.text = self.itemData.baseData.name
	-- self.name_txt.text = GLL.GetTx(self.itemData.baseData.name)
end

function C:RefreshDescView()
	self.desc_txt.text = self.itemData.baseData.desc
	-- self.desc_txt.text = GLL.GetTx(self.itemData.baseData.desc)
end

function C:RefreshAmountView()
	self.amount_txt.text = GLL.GetTx(80051) .. ":" .. self.itemData.amount
end