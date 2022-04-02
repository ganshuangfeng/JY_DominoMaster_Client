-- 创建时间:2021-12-06
-- Panel:ShopPrefab
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

ShopPrefab = basefunc.class()
local C = ShopPrefab
C.name = "ShopPrefab"

function C.Create(parent, data, selfParent, call)
	return C.New(parent, data, selfParent, call)
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

function C:ctor(parent, data, selfParent, call)
	self.parent = parent
	self.data = data
	self.selfParent = selfParent
	self.call = call

	local obj = newObject(C.name, self.parent)
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
	self.buy_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.selfParent, self.data)
	end)
end

function C:RemoveListenerGameObject()
	self.buy_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
	self.title_txt.text = self.data.ui_title
	self.price_txt.text = self.data.ui_price
	self.icon_img.sprite = GetTexture(self.data.ui_icon)

	local s = self.data.scale or 1
	self.icon_img.transform.localScale = Vector3.New(s, s, 1)

	if self.data.old_ui_title then
		self.old_title_txt.gameObject:SetActive(true)
		self.old_title_txt.text = self.data.old_ui_title
	else
		self.old_title_txt.gameObject:SetActive(false)
	end
	if self.data.give then
		self.give.gameObject:SetActive(true)
		self.give_txt.text = self.data.give
	else
		self.give.gameObject:SetActive(false)
	end
	
	self.hint2_txt.text = StringHelper.ToCash(self.data.VIP_point)
end
