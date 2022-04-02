-- 创建时间:2022-03-01
-- Panel:Act_LRPanel
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

Act_LRPanel = basefunc.class()
local C = Act_LRPanel
local M = Act_LRManager
C.name = "Act_LRPanel"

function C.Create()
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
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
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
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.get_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award_new", { id = M.task_id, award_progress_lv = self.lvIndex })
	end)
	self.cannot_get_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	
	self:MyRefresh()
end

function C:MyRefresh()
	self.lvIndex, self.state = M.GetCurLvAndState()
	self.cfg = M.GetRewardConfig(self.lvIndex)
	self.award_1_img.sprite = GetTexture(self.cfg.award_img[1])
	self.award_2_img.sprite = GetTexture(self.cfg.award_img[2])
	self.award_1_txt.text = StringHelper.ToCash(self.cfg.award_amount[1])
	self.award_2_txt.text = StringHelper.ToCash(self.cfg.award_amount[2])
	self.level_img.sprite = GetTexture("sjjl_bg_0" .. self.cfg.lv)
	self.get_btn.gameObject:SetActive(self.state == 1)
	self.cannot_get_btn.gameObject:SetActive(self.state == 0)
	if self.state == 0 then
		self.hint_txt.text = "Mencapai level " .. self.cfg.lv .." bisa ambil"
	end
end

function C:on_model_task_change_msg(data)
	if data.id == M.task_id then
		if M.IsGetedAllReward() then
			self:MyExit()
		else
			self:MyRefresh()
		end
	end
end
