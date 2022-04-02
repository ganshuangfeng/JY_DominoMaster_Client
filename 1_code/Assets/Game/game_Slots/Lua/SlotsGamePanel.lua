-- 创建时间:2021-12-10
-- Panel:SlotsGamePanel
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

SlotsGamePanel = basefunc.class()
local M = SlotsGamePanel
M.name = "SlotsGamePanel"
local listerRegisterName = M.name .. "ListerRegister"
local instance
function M.Create()
	if instance then
		instance:MyRefresh()
	else
		instance = M.New()
		M.Instance = instance
	end
	return instance
end

function M:AddMsgListener()
    LudoLogic.SetViewMsgRegister(self.lister, listerRegisterName)
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["model_slot_jymt_kaijiang_response"] = basefunc.handler(self, self.on_slot_jymt_kaijiang_response)
    self.lister["ChooseMiniGame"] = basefunc.handler(self, self.OnChooseMiniGame)
    self.lister["CompleteMiniGame"] = basefunc.handler(self, self.OnCompleteMiniGame)
    self.lister["CompleteSettlement"] = basefunc.handler(self, self.OnCompleteSettlement)
end

function M:RemoveListener()
	LudoLogic.ClearViewMsgRegister(listerRegisterName)
    self.lister = {}
end

function M:MyExit()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
	self:RemoveListener()
	self:RemoveListenerGameObject()
	self:ExitPanel()
	self:ExitManager()
	self:ExitTools()
	-- destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	M.Instance = self
	self.dot_del_obj = true
	ExtPanel.ExtMsg(self)
	self:InitUI()
	self:InitLL()

	self:MakeLister()
	self:AddMsgListener()
	self:AddListenerGameObject()

	self:InitTools()
	self:InitManager()
	self:InitPanel()
    local btn_map = {}
	btn_map["right_top"] = {self.right_top}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "slots_fxgz")
	self:MyRefresh()

end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_beijing.audio_name)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
end

--弱网游戏，忽略网络的影响和程序前后台的影响，进入游戏只在需要用到网络的时候才考虑网络问题
function M:MyRefresh()
	dump(SlotsModel.data,"<color=yellow>界面刷新</color>")
	SlotsModel.SetGameProcess()
	SlotsModel.SetGameStatus(SlotsModel.GameStatus.idle)
	SlotsModel.SetAutoNum(0)
    SlotsModel.SetAuto(false)
	self:ExitTimer()

	self:RefreshLL()

	self:RefreshPanel()
	self:RefreshManager()
	self:RefreshTools()
end

function M:StartAutoTimer()
	self:StopAutoTimer()
    M.autoTimer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,SlotsModel.GetTime(SlotsModel.time.xc_zdkj),1)
    M.autoTimer:Start()
end

function M:StopAutoTimer()
	if M.autoTimer then
        M.autoTimer:Stop()
    end
	M.autoTimer = nil
end

function M:ExitTimer()
	self:StopAutoTimer()
    SlotsAnimation.ExitTimer()
    SlotsEffect.ExitTimer()
	SlotsHelper.ExitTimer()
end

function M:AddListenerGameObject()
end

function M:RemoveListenerGameObject()
end

function M:InitPanel()
	SlotsDeskPanel.Create()
	SlotsButtonPanel.Create()
	SlotsAwardPoolPanel.Create()
	SlotsBetPanel.Create()
	SlotsWinMoneyPanel.Create()
    SlotsHelpPanel.Create()
    SlotsClearPanel.Create()
    SlotsAutoPanel.Create()
end

function M:RefreshPanel()
	SlotsDeskPanel.Refresh()
	SlotsButtonPanel.Refresh()
	SlotsAwardPoolPanel.Refresh()
	SlotsBetPanel.Refresh()
	SlotsWinMoneyPanel.Refresh()
    SlotsHelpPanel.Refresh()
    SlotsClearPanel.Refresh()

	SlotsAutoPanel.Close()
	SlotsMiniGameChoosePanel.Close()
	SlotsMiniGame1Panel.Close()
	SlotsMiniGame2Panel.Close()
	SlotsMiniGame3Panel.Close()
end

function M:ExitPanel()
	SlotsDeskPanel.Close()
	SlotsButtonPanel.Close()
	SlotsAwardPoolPanel.Close()
	SlotsBetPanel.Close()
	SlotsWinMoneyPanel.Close()
    SlotsHelpPanel.Close()
    SlotsClearPanel.Close()
	SlotsAutoPanel.Close()

	SlotsMiniGameChoosePanel.Close()
	SlotsMiniGame1Panel.Close()
	SlotsMiniGame2Panel.Close()
	SlotsMiniGame3Panel.Close()
end

function M:InitManager()
end

function M:RefreshManager()
end

function M:ExitManager()
end

function M:InitTools()
	SlotsHelper.Init()
	SlotsAnimation.Init()
	SlotsEffect.Init()
end

function M:RefreshTools()
	SlotsHelper.Refresh()
	SlotsAnimation.Refresh()
	SlotsEffect.Refresh()
end

function M:ExitTools()
	SlotsHelper.Exit()
	SlotsAnimation.Exit()
	SlotsEffect.Exit()
end

function M:on_slot_jymt_kaijiang_response(data)
	if data.result == 0 then
		self:LotterySuccess()
	else
		self:LotteryError(data)
	end
end

function M:QuitGame()
	if not Network.SendRequest("slot_jymt_quit_game") then
		LittleTips.Create("Network Error")
		self:MyRefresh()
	end
end

--玩家开奖
function M:Lottery()
	if SlotsLogic.isTest then
		local data = SlotsLogic.GetTestData()
		Event.Brocast("slot_jymt_kaijiang_response","slot_jymt_kaijiang_response",data)
		return
	end
	if not Network.SendRequest("slot_jymt_kaijiang",{bet_index = SlotsModel.data.bet.id}) then
		LittleTips.Create("Network Error")
		self:MyRefresh()
	end
end

--开奖失败
function M:LotteryError(data)
	SlotsModel.SetGameStatus(SlotsModel.GameStatus.idle)
	self:ExitTimer()
	if data.result == 1012 then
		--如果是[需要的数量有异常]就弹出充值面板
		-- LittleTips.Create("你开奖的钱不够，请充值")

		SysBrokeSubsidyManager.RunBrokeProcess()
	else
		HintPanel.ErrorMsg(data.result)
	end
end

--开奖成功
function M:LotterySuccess()
    print("<color=yellow>开奖成功</color>")
	SlotsModel.SetGameStatus(SlotsModel.GameStatus.run)
	if SlotsModel.GetSkip() then
		self:LotteryStop()
	else
		SlotsHelper.LotteryStart()
	end
end

--停止开奖，直接出结果
function M:LotteryStop()
	SlotsModel.SetGameStatus(SlotsModel.GameStatus.idle)
	SlotsHelper.LotteryStop()
end

function M:OnChooseMiniGame(data)
	dump(data,"<color=yellow>选择小游戏？？？</color>")
	SlotsHelper.ChooseMiniGame(data)
end

function M:OnCompleteMiniGame(data)
	dump(data,"<color=yellow>退出小游戏？？？</color>")
	SlotsHelper.CompleteMiniGame()
end

function M:OnCompleteSettlement()
	dump("<color=yellow>完成结算？？？</color>")
	SlotsHelper.CompleteSettlement()
end

function M:MainScrollItemMapStop()
	SlotsHelper.MainScrollItemMapStop()
end

function M:RefreshMoneyTxtFix()
	SlotsBetPanel.Instance:RefreshMoneyTxtFix()
end