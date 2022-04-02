-- 创建时间:2022-03-17
-- Panel:Act_YJCJItem
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

Act_YJCJItem = basefunc.class()
local C = Act_YJCJItem
C.name = "Act_YJCJItem"

function C.Create(cfg, parent)
	return C.New(cfg, parent)
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

function C:ctor(cfg, parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.cfg = cfg
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
end

function C:RemoveListenerGameObject()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.icon_img.sprite = GetTexture(self.cfg.award_icon)
	self.count_txt.text = self.cfg.award_count
	self:MyRefresh()
end

function C:Select()
	self.select.gameObject:SetActive(true)
end

function C:UnSelect()
	self.select.gameObject:SetActive(false)
end

function C:Geted()
	if self.cfg.id == 14 then
		self.real_geted.gameObject:SetActive(true)
		self.real_btn.onClick:AddListener(function()
			Act_YJCJRealGet.Create()
		end)
		self.real_btn_txt.text = GLL.GetTx(81113)
	else
		self.geted.gameObject:SetActive(true)
	end
end

function C:PlayLotteryPart()
	self.lotteryed_part.gameObject:SetActive(false)
	self.lotteryed_part.gameObject:SetActive(true)
end

function C:MyRefresh()
end
