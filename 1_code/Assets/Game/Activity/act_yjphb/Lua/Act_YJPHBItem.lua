-- 创建时间:2022-03-22
-- Panel:Act_YJPHBItem
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

Act_YJPHBItem = basefunc.class()
local C = Act_YJPHBItem
local M = Act_YJPHBManager
C.name = "Act_YJPHBItem"

function C.Create(parent, data)
	return C.New(parent, data)
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

function C:ctor(parent, data)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI(data)
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

function C:InitUI(data)
	self.num_txt.text = StringHelper.ToCash(data.score)
	self.name_txt.text = data.name
	local rankIndex = data.rank
	self.award_txt.text = StringHelper.ToCash(M.GetAwardFromIndex(rankIndex))
	if rankIndex > 3 then
		self.rank_txt.text = rankIndex
		self.rank_img.gameObject:SetActive(false)
	else
		self.rank_txt.text = ""
		self.rank_img.gameObject:SetActive(true)
		self.rank_img.sprite = GetTexture("ludo_js_icon_0" .. rankIndex)

		if rankIndex ~= 1 then
			self.rank1_gx.gameObject:SetActive(false)
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
end
