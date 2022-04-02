-- 创建时间:2021-12-15
-- Panel:SlotsMiniGameChoosePanel
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

SlotsMiniGameChoosePanel = basefunc.class()
local M = SlotsMiniGameChoosePanel
M.name = "SlotsMiniGameChoosePanel"

local instance
function M.Create()
	if instance then
		instance:MyExit()
	end
	instance = M.New()
	M.Instance = instance
	return instance
end

function M.Close()
	if not instance then
		return
	end
	instance:MyExit()
end

function M.Refresh()
	if not instance then
		return
	end
	instance:MyRefresh()
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	SlotsHelper.KillSeq(self.seq)
	SlotsHelper.KillSeq(self.seqAutoChoose)
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	ExtPanel.ExtMsg(self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()

	self:AddListenerGameObject()

	self:MyRefresh()
	self:AutoChoose()
	self:PlayStart()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	self.gameObject = newObject(M.name, parent)
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self.ani = self.transform:GetComponent("Animator")
	self.seq = SlotsHelper.GetSeq()
	self.seq:InsertCallback(2.2,function ()
		if self.ani then
			self.ani:Play("xiaoyouxi02 Animation",-1,0)
		end
	end)
end

function M:MyRefresh()
end

function M:AddListenerGameObject()
	self.mini_game_1_btn.onClick:AddListener(function ()
		self:OnClickMiniGame1()
	end)
	self.mini_game_2_btn.onClick:AddListener(function ()
		self:OnClickMiniGame2()
	end)
end

function M:RemoveListenerGameObject()
	self.mini_game_1_btn.onClick:RemoveAllListeners()
	self.mini_game_2_btn.onClick:RemoveAllListeners()
end

function M:AutoChoose()
	local seq = SlotsHelper.GetSeq()
	local autoChooseMini = SlotsModel.GetTime(SlotsModel.time.autoChooseMini)
	seq:InsertCallback(autoChooseMini,function ()
		self:ChooseMiniGame(math.random(1,2))
	end)
	self.seqAutoChoose = seq
end

function M:OnClickMiniGame1()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:ChooseMiniGame(1)
end


function M:OnClickMiniGame2()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:ChooseMiniGame(2)
end

function M:ChooseMiniGame(game)
	SlotsModel.SetMinGame(game)
	Event.Brocast("ChooseMiniGame",{game = game})
	self:MyExit()
end

function M:PlayStart()
	self.gameObject:SetActive(false)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_chufa.audio_name)
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectItemERollFront)
	seq:InsertCallback(t,function ()
		SlotsEffect.PlayItemERoll()
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.effectItemERoll + SlotsModel.time.effectItemERollFront)
	seq:InsertCallback(t,function ()
		ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_free_beijing.audio_name)
		self.gameObject:SetActive(true)
	end)
end