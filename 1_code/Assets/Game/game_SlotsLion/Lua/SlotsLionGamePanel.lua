-- 创建时间:2021-12-10
-- Panel:SlotsLionGamePanel
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

SlotsLionGamePanel = basefunc.class()
local M = SlotsLionGamePanel
M.name = "SlotsLionGamePanel"
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
    self.lister["model_slot_wushi_kaijiang_response"] = basefunc.handler(self, self.on_slot_wushi_kaijiang_response)
    self.lister["CompleteMiniGame"] = basefunc.handler(self, self.OnCompleteMiniGame)
    self.lister["CompleteMiniGameParallel"] = basefunc.handler(self, self.OnCompleteMiniGameParallel)
    self.lister["CompleteSettlement"] = basefunc.handler(self, self.OnCompleteSettlement)
end

function M:RemoveListener()
	LudoLogic.ClearViewMsgRegister(listerRegisterName)
    self.lister = {}
end

function M:MyExit()
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

	self:MyRefresh()
	self.Line = SlotsLionLinePanel.Create(self.line_node)
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.lion.bgm_lion_beijing.audio_name)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	local btn_map = {}
	btn_map["right"] = {self.r_node1, self.r_node2, self.r_node3}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "slots_lion", self.transform)
end

--弱网游戏，忽略网络的影响和程序前后台的影响，进入游戏只在需要用到网络的时候才考虑网络问题
function M:MyRefresh()
	dump(SlotsLionModel.data,"<color=yellow>界面刷新</color>")
	SlotsLionModel.SetGameProcess()
	SlotsLionModel.SetGameStatus(SlotsLionModel.GameStatus.idle)
	SlotsLionModel.SetAutoNum(0)
    SlotsLionModel.SetAuto(false)
	self:ExitTimer()

	self:RefreshLL()

	self:RefreshPanel()
	self:RefreshManager()
	self:RefreshTools()
	SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(false)
end

function M:StartAutoTimer()
	self:StopAutoTimer()
    M.autoTimer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,SlotsLionModel.GetTime(SlotsLionModel.time.xc_zdkj),1)
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
    SlotsLionAnimation.ExitTimer()
    SlotsLionEffect.ExitTimer()
	SlotsLionHelper.ExitTimer()
end

function M:AddListenerGameObject()
end

function M:RemoveListenerGameObject()
end

function M:InitPanel()
	SlotsLionGameMainPanel.Create()
	SlotsLionButtonPanel.Create()
	SlotsLionAwardPoolPanel.Create()
	SlotsLionBetPanel.Create()
	SlotsLionWinMoneyPanel.Create()
    SlotsLionHelpPanel.Create()
    SlotsLionClearPanel.Create()
    SlotsLionAutoPanel.Create()
	SlotsLionGameMini1Panel.Create()
	SlotsLionGameMini2Panel.Create()
end

function M:RefreshPanel()
	SlotsLionGameMainPanel.Refresh()
	SlotsLionButtonPanel.Refresh()
	SlotsLionAwardPoolPanel.Refresh()
	SlotsLionBetPanel.Refresh()
	SlotsLionWinMoneyPanel.Refresh()
    SlotsLionHelpPanel.Refresh()
    SlotsLionClearPanel.Refresh()
	SlotsLionAutoPanel.Close()
	SlotsLionGameMini1Panel.Refresh()
	SlotsLionGameMini2Panel.Refresh()
end

function M:ExitPanel()
	SlotsLionGameMainPanel.Close()
	SlotsLionButtonPanel.Close()
	SlotsLionAwardPoolPanel.Close()
	SlotsLionBetPanel.Close()
	SlotsLionWinMoneyPanel.Close()
    SlotsLionHelpPanel.Close()
    SlotsLionClearPanel.Close()
	SlotsLionAutoPanel.Close()
	SlotsLionGameMini1Panel.Close()
	SlotsLionGameMini2Panel.Close()
end

function M:InitManager()
end

function M:RefreshManager()
end

function M:ExitManager()
end

function M:InitTools()
	SlotsLionHelper.Init()
	SlotsLionAnimation.Init()
	SlotsLionEffect.Init()
end

function M:RefreshTools()
	SlotsLionHelper.Refresh()
	SlotsLionAnimation.Refresh()
	SlotsLionEffect.Refresh()
end

function M:ExitTools()
	SlotsLionHelper.Exit()
	SlotsLionAnimation.Exit()
	SlotsLionEffect.Exit()
end

function M:on_slot_wushi_kaijiang_response(data)
	if data.result == 0 then
		self:LotterySuccess()
	else
		self:LotteryError(data)
	end
end

function M:QuitGame()
	if not Network.SendRequest("slot_wushi_quit_game") then
		LittleTips.Create("Network Error")
		self:MyRefresh()
	end
end

--玩家开奖
function M:Lottery()
	if SlotsLionLogic.isTest then
		local data = SlotsLionLogic.GetTestData()
		Event.Brocast("slot_wushi_kaijiang_response","slot_wushi_kaijiang_response",data)
		return
	end
	if not Network.SendRequest("slot_wushi_kaijiang",{bet_index = SlotsLionModel.data.bet.id}) then
		LittleTips.Create("Network Error")
		self:MyRefresh()
	end
end

--开奖失败
function M:LotteryError(data)
	SlotsLionModel.SetGameStatus(SlotsLionModel.GameStatus.idle)
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
	SlotsLionModel.SetGameStatus(SlotsLionModel.GameStatus.run)
	if SlotsLionModel.GetSkip() then
		self:LotteryStop()
	else
		SlotsLionHelper.LotteryStart()
	end
end

--停止开奖，直接出结果
function M:LotteryStop()
	SlotsLionModel.SetGameStatus(SlotsLionModel.GameStatus.idle)
	SlotsLionHelper.LotteryStop()
end

function M:OnCompleteMiniGame(data)
	dump(data,"<color=yellow>串行小游戏完成CompleteMiniGame？？？</color>")
	SlotsLionHelper.CompleteMiniGame(data)
end

function M:OnCompleteMiniGameParallel(data)
	dump(data,"<color=yellow>并行小游戏完成CompleteMiniGame？？？</color>")
	SlotsLionHelper.CompleteMiniGameParallel(data)
end

function M:OnCompleteSettlement(data)
	dump(data,"<color=yellow>完成结算？？？</color>")
	SlotsLionHelper.CompleteSettlement(data)
end

function M:StopMainScroll()
	SlotsLionHelper.StopMainScroll()
end

function M:RefreshMoneyTxtFix()
	SlotsLionBetPanel.Instance:RefreshMoneyTxtFix()
end