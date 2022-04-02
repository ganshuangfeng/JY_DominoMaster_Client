-- 创建时间:2022-03-01
-- Panel:Act_LREnter
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

Act_LREnter = basefunc.class()
local C = Act_LREnter
local M = Act_LRManager
C.name = "Act_LREnter"

function C.Create(parent)
	return C.New(parent)
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
    self.lister["model_level_data_change"] = basefunc.handler(self, self.on_model_level_data_change)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillSeq()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self.enter_btn.onClick:AddListener(function()
		Act_LRPanel.Create()
	end)
	if MainModel.myLocation ~= "game_Hall" then
		self:PlayLvUpAnim()
	end

	self.lvPg = self.pg:GetComponent("RectTransform")
	self:MyRefresh()
	self:RefreshLvProgress()
end

function C:on_model_task_change_msg(data)
	if data.id == M.task_id then
		if M.IsGetedAllReward() then
			self:MyExit()
		else
			self:MyRefresh()
			self:RefreshLvProgress()
		end
	end
end

function C:on_model_level_data_change(data)
	if MainModel.myLocation ~= "game_Hall" then
		if data.isLevelUp and (data.level == 2 or data.level == 3 or data.level == 4 or data.level == 5) then
			self:MyRefresh()
			self:PlayLvUpAnim()
		end
	end
	self:RefreshLvProgress()
end

function C:OnExitScene()
	self:KillSeq()
end

function C:MyRefresh()
	self.lvIndex, self.state = M.GetCurLvAndState()
	self.cfg = M.GetRewardConfig(self.lvIndex)
	self.tit_txt.text = "Hadiah lv " .. self.cfg.lv
	self.red.gameObject:SetActive(self.state == 1)
	self.fx.gameObject:SetActive(self.state == 1)
	self.rd_1_txt.text = StringHelper.ToCash(self.cfg.award_amount[1])
	self.rd_2_txt.text = StringHelper.ToCash(self.cfg.award_amount[2])
end

function C:PlayLvUpAnim()
	self.lvup.transform.localPosition = Vector3.New(-365, 5.75, 0)
	self.animSeq = DoTweenSequence.Create({dotweenLayerKey = M.key})
	self.animSeq:Append(self.lvup.transform:DOLocalMoveX(-123.6, 0.5))
	self.animSeq:AppendInterval(3)
	self.animSeq:Append(self.lvup.transform:DOLocalMoveX(-365, 0.5))
end

function C:RefreshLvProgress()
	if SysLevelManager and SysLevelManager.GetLevel() < 6 then
		local curLv = SysLevelManager.GetLevel()
		if curLv < self.cfg.lv then
			local pro =  SysLevelManager.GetExperience() / SysLevelManager.GetNextLevelNeed()
			self.lvPg.sizeDelta = { x = 110 * pro, y = 9}
		else
			self.lvPg.sizeDelta = { x = 110, y = 9}
		end
	else
		self.PG.gameObject:SetActive(false)
	end
end

function C:KillSeq()
	if self.animSeq then
		self.animSeq:Kill()
		self.animSeq = nil
	end
end
