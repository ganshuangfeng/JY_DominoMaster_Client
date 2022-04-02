-- 创建时间:2022-01-10
-- Panel:Act_DominoTaskEnter
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

Act_DominoTaskEnter = basefunc.class()
local C = Act_DominoTaskEnter
local M = Act_DominoTaskManager
C.name = "Act_DominoTaskEnter"

local DominoTaskState = {
	hide = 1,
	tasking = 2,
}

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
    self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_fg_all_info)
	self.lister["model_task_data_change_msg"] = basefunc.handler(self, self.on_model_task_data_change_msg)
    self.lister["model_nor_dmn_nor_pai_msg"] = basefunc.handler(self, self.on_nor_dmn_nor_pai_msg)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
	self.lister["EnterForeGround"] = basefunc.handler(self, self.OnEnterForeGround)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(self.dotweenLayerKey)
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
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Act_DominoTaskPanel.Create()
	end)
end

function C:RemoveListenerGameObject()
	self.enter_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.dotweenLayerKey = C.name
	
	self.canvasGroup = self.root:GetComponent("CanvasGroup")
	self.state = DominoTaskState.hide
	self:RefreshMyPos()
	self:RefreshDoubleTime()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:RefreshDoubleTime()
	self.curDay = M.GetWeekNum()
	self.double_cfg = M.GetCurDayNextDoubleTime()
	self.double_time_txt.text = M.FormatTimeStr(self.double_cfg.start_time, self.double_cfg.end_time) .. " Double bonus"
end

--断线重连时,获取数据
function C:on_fg_all_info()
	-- dump("<color=white>奖RP:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
	-- dump(DominoJLModel.data.status, "<color=white>Domino状态</color>")
	if DominoJLModel.data.status == DominoJLModel.Status.cp or DominoJLModel.data.status == DominoJLModel.Status.fp then
		-- dump("<color=white>奖RP:CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC</color>")
		self:ReSet()
		self.fatherTaskId = M.GetCurFatherTask()
		Network.SendRequest("query_one_task_data", {task_id = self.fatherTaskId})
	end
end

--确定牌型,此时数据已获取
function C:on_nor_dmn_nor_pai_msg()
	-- dump("<color=white>奖RP:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB</color>")
	-- dump(DominoJLModel.data.status, "<color=white>Domino状态</color>")
	self:ReSet()
	self.fatherTaskId = M.GetCurFatherTask()
	Network.SendRequest("query_one_task_data", {task_id = self.fatherTaskId})
end

function C:on_model_task_data_change_msg(data)
	if data.tag == "add" then
		if data.id == self.fatherTaskId then
			self:HandleFatherTaskDataGet()
		elseif data.id == self.taskId then
			self:HandleTaskDataGet()
		end
	elseif data.tag == "chg" then
		if data.id == self.taskId then
			self:HandleTaskDataChange()
		end
	end
end

function C:OnAssetChange(data)
	if data.change_type == "task_domino_time_fan_bei_award" then
		self.awardData = {data = data.data}
	end
end

function C:OnEnterBackGround()

end

function C:OnEnterForeGround()
	self:RefreshMyPos()
end

function C:RefreshMyPos()
	if self.state == DominoTaskState.hide then
		self.transform.localPosition = Vector3.New(0, 200, 0)
	elseif self.state == DominoTaskState.tasking then
		self.transform.localPosition = Vector3.New(0, 0, 0)
	end
end
function C:ReSetData()
	self.taskId = nil
	self.awardData = nil
	self.domino_win_pai_id = nil
end

function C:ReSet()
	self.state = DominoTaskState.hide
	self:RefreshMyPos()
	self:ReSetData()
	self.canvasGroup.alpha = 1
	self.complete.gameObject:SetActive(false)
	self.no_complete.gameObject:SetActive(false)
end

--得到父任务的数据
function C:HandleFatherTaskDataGet()
	local taskData = GameTaskManager.GetTaskDataByID(self.fatherTaskId)
	if taskData.other_data_str then
		local d = basefunc.parse_activity_data(taskData.other_data_str)
		self.taskId = d.walking_task_id
		dump(self.fatherTaskId, "<color=white>奖RP:父任务Id</color>")
		dump(self.taskId, "<color=white>奖RP:当前任务Id</color>")
		Network.SendRequest("query_one_task_data", {task_id = self.taskId})
	end
end

--得到当前任务数据
function C:HandleTaskDataGet()
	local taskData = GameTaskManager.GetTaskDataByID(self.taskId)
	if not taskData.other_data_str then
		return
	end
	local d = basefunc.parse_activity_data(taskData.other_data_str)
	if d.domino_win_pai_id then
		self.domino_win_pai_id = d.domino_win_pai_id 
		dump(self.domino_win_pai_id, "<color=white>奖RP:指定牌Id</color>")
	end
	if d.fix_award_data then
		if d.fix_award_data[1].asset_type == "shop_gold_sum" then
			d.fix_award_data[1].value = d.fix_award_data[1].value / 100
		end
		self.awardData = {data = d.fix_award_data}
		dump(self.awardData, "<color=white>奖RP:奖励</color>")
	end
	self:RefreshTask()
	if self.state == DominoTaskState.hide then
		self.state = DominoTaskState.tasking
		self:PlayIntoAnim()
	end
end

--当前任务发生改变
function C:HandleTaskDataChange()
	local taskData = GameTaskManager.GetTaskDataByID(self.taskId)
	if not taskData.other_data_str then
		return
	end
	local d = basefunc.parse_activity_data(taskData.other_data_str)
	if d.is_win_award then
		dump(d.is_win_award, "<color=white>奖RP:任务完成情况</color>")
		if d.is_win_award == 0 then
			self:NoCompleteTask()
		elseif d.is_win_award == 1 then
			self:CompleteTask()
		end
	end
end

function C:RefreshTask()
	self.cfg = M.GetCfgFromTaskId(self.fatherTaskId, self.taskId)
	if self.awardData then
		self.award_num_txt.text = self.awardData.data[1].value
	end

	if self.cfg.is_fix_win_pai and self.cfg.is_fix_win_pai == 1 then
		if self.domino_win_pai_id and DominoJLLib then
			local pai = DominoJLLib.GetDataById(self.domino_win_pai_id)
			local paiTxt = pai[1] .. "|" .. pai[2]
			self.task_desc_txt.text = string.format(GLL.GetTx(self.cfg.task_desc), paiTxt)
		end
	else
		self.task_desc_txt.text = GLL.GetTx(self.cfg.task_desc)
	end
end

function C:PlayIntoAnim()
	self.intoSeq = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	self.transform.localPosition = Vector3.New(0, 200, 0)
	self.intoSeq:Append(self.transform:DOLocalMoveY(0, 1):SetEase(Enum.Ease.InOutElastic))
	self.intoSeq:AppendCallback(function()
		if IsEquals(self.gameObject) then
			self:RefreshMyPos()
		end
	end)
end

function C:CompleteTask()
	self.resultSeq = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	self:ImpressSeq(self.complete)
	self.resultSeq:AppendCallback(function()
		if self.awardData then
			local assetGetPanel = AssetsGetPanel.Create(self.awardData, true)
			self:FadeAssetGet(assetGetPanel)
			self.awardData = nil
		end
	end)
	self:FadeSeq(2)
end

function C:NoCompleteTask()
	self.resultSeq = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	self:ImpressSeq(self.no_complete)
	self:FadeSeq(3)
end

function C:FadeSeq(intervalTime)
	self.resultSeq:AppendInterval(intervalTime)
	self.resultSeq:Append(self.canvasGroup:DOFade(0, 1))
	self.resultSeq:AppendCallback(function()
		if IsEquals(self.gameObject) then
			self:ReSet()
		end
	end)
end

function C:ImpressSeq(obj)
	obj.gameObject:SetActive(true)
	obj.transform.localScale = Vector3.one
	self.resultSeq:Append(obj.transform:DOScale(0.6, 0.3):SetEase(Enum.Ease.InBack))
end

function C:FadeAssetGet(panel)
	local seq = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	panel.confirm_btn.gameObject:SetActive(false)
	panel.title.gameObject:SetActive(false)
	-- local canvasGroup = panel.gameObject:GetComponent("CanvasGroup")
	local canvasGroup = panel.gameObject:AddComponent(typeof(UnityEngine.CanvasGroup))
	canvasGroup.enabled = true
	canvasGroup.alpha = 1
	seq:AppendInterval(2)
	seq:Append(canvasGroup:DOFade(0, 1))
	seq:AppendCallback(function()
		canvasGroup.enabled = true
		panel.confirm_btn.gameObject:SetActive(true)
		panel.title.gameObject:SetActive(true)
		AssetsGetPanel.Close()
	end)
end