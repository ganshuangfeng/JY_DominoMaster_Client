-- 创建时间:2022-03-17
-- Panel:Act_YJCJPanel
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

Act_YJCJPanel = basefunc.class()
local M = Act_YJCJManager
local C = Act_YJCJPanel
C.name = "Act_YJCJPanel"

local sw_asset_id = 10111

local lotteryState = {
	Wait = 1,
	Lottery = 2,
}

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
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
    self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
    self.lister["model_act_yxcj_box_exchange_info"] = basefunc.handler(self, self.on_model_act_yxcj_box_exchange_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if not table_is_null(self.items) then
		for i = #self.items, 1, -1 do
			self.items[i]:MyExit()
			self.items[i] = nil
		end
	end
	if self.playPartTimer then
		self.playPartTimer:Stop()
		self.playPartTimer = nil
	end
	if self.LotteryAnimEndCall then
		self.LotteryAnimEndCall()
		self.LotteryAnimEndCall = nil
	end
	if self.pmd_cont then
		self.pmd_cont:MyExit()
	end
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.way = {}
	for i = 1, 14 do
		self.way[i] = i 
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()

	self.state = lotteryState.Wait
	local endTimeCall = function()
		self:MyExit()
	end
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_txt, nil, endTimeCall)
	self.pmd_cont = CommonPMDManager.Create(self, self.CreatePMD, { send_t = 10, data_type = "yjcj_20220322", time_scale = 0.3, start_pos = 200, end_pos = -200 })
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.lottery_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Lottery()
	end)
	self.cannot_lottery_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.lv > 14 then
			-- LittleTips.Create(GLL.GetTx(81108))
			return
		end
		LittleTips.Create(GLL.GetTx(81105))
	end)
end

function C:RemoveListenerGameObject()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitNodes()
	self.nodes = {}
	for i = 1, 14 do
		local node = self["node" .. i]
		self.nodes[#self.nodes + 1] = node
	end
end

function C:InitItems()
	self.view_list = M.GetAwardViewList()

	self.items = {}
	for i = 1, 14 do
		local cfg = M.GetAwardCfgFromId(self.view_list[i])
		local item = Act_YJCJItem.Create(cfg, self.nodes[i].transform)
		self.items[#self.items + 1] = item
	end
end

function C:SelectItem(item, pos)
	if self.items then
		for i = 1,#self.items do
			self.items[i]:UnSelect()
		end
	end
	if item then
		item:Select()
	end
end

function C:StratWink()
	self.anim = CommonLotteryAnim.Create(self.items, function(item, pos)
		self:SelectItem(item, pos)
	end, self.way)
end

function C:InitUI()
	self:InitNodes()
	self:InitItems()
	self:UpdateData()
	self:RrfreshJf()

	if self.lv > 14 then
		self:RefreshGeted()
		self.cannot_lottery_btn.gameObject:SetActive(true)
		self.consume = M.GetAwardCfgFromId(14).consume
		self.consume_txt.text = "Konsumsi " .. StringHelper.ToCash(self.consume) .. " poin"
		return
	end
	self:RefreshLotteryBtn()
	self:RefreshConsume()
	if self.lv < 5 then
		Network.SendRequest("query_box_exchange_info",{id = M.box_change_id_below5})
		self.isInitInfo = false
	else
		self.isInitInfo = true
		self:RefreshGeted()
		self:StratWink()
	end
end

function C:CheckAndUpdateData()
	if self.isTaskChange and self.isBoxChangeResponse and (self.isAssetChange or self.lv == 14) then
		self:UpdateData()
		if self.lv > 14 then
			if self.LotteryAnimEndCall then
				self.LotteryAnimEndCall()
				self.LotteryAnimEndCall = nil
			end
			self:RefreshGeted()
		else
			self:RefreshConsume()
		end
		self:RrfreshJf()
		self:RefreshLotteryBtn()
	end
end

function C:UpdateData()
	self.lv = M.GetCurLv()
	dump(self.lv, "<color=white>self.lv</color>")
	self.curBoxChangeId = M.GetCurBoxChangeId(self.lv)
	dump(self.curBoxChangeId, "<color=white>self.curBoxChangeId</color>")
	self.isTaskChange = false
	self.isBoxChangeResponse = false
	self.isAssetChange = false
end

function C:Lottery()
	if self.state == lotteryState.Wait then
		Network.SendRequest("box_exchange",{id = self.curBoxChangeId,num = 1})
		self.isTaskChange = false
		self.isBoxChangeResponse = false
		self.isAssetChange = false
	end
end

function C:PlayAnim(index)
	self.anim:StartLottery(index, function ()
		local playPartEndCall = function()
			if IsEquals(self.gameObject) then
				if self.LotteryAnimEndCall then
					self.LotteryAnimEndCall()
					self.LotteryAnimEndCall = nil
				end
				self:RefreshGeted()
			end
		end
		if self.indexView and self.items[self.indexView] then
			self.items[self.indexView]:PlayLotteryPart()
		end
		self:PlayLotteryPartTimer(playPartEndCall)
	end, self.way)
end


function C:PlayLotteryPartTimer(backcall)
	self.playPartTimer = Timer.New(function()
		if backcall then
			backcall()
		end
	end, 0.9, 1)
	self.playPartTimer:Start()
end

function C:RrfreshJf()
	local count = GameItemModel.GetItemCount("prop_point_common") 
	self.num_txt.text = StringHelper.ToCash(count)
end

function C:RefreshLotteryBtn()
	local count = GameItemModel.GetItemCount("prop_point_common") 
	if self.lv > 14 then
		self.cannot_lottery_btn.gameObject:SetActive(true)
		self.red.gameObject:SetActive(false)
	else
		if count < M.GetAwardCfgFromId(self.lv).consume then
			self.cannot_lottery_btn.gameObject:SetActive(true)
			self.red.gameObject:SetActive(false)
		else
			self.cannot_lottery_btn.gameObject:SetActive(false)
			self.red.gameObject:SetActive(true)
		end
	end
end

function C:RefreshConsume()
	self.consume = M.GetAwardCfgFromId(self.lv).consume
	self.consume_txt.text = "Konsumsi " .. StringHelper.ToCash(self.consume) .. " poin"
end

function C:UpdateMyWay(removeWay)
	for i = 1, #self.way do
		if self.way[i] == removeWay then
			table.remove(self.way, i)
		end
	end
end

function C:RefreshGeted()
	local geted = function(id)
		local index = M.GetAwardCfgFromId(id).view_index
		self.items[index]:Geted()
		self:UpdateMyWay(index)
	end

	if self.lv < 5 then
		local list = M.GetCurGetedListBelow5()
		for k, v in pairs(list) do
			geted(k)
		end
	else
		local j = self.lv - 1
		for i = 1, j do
			geted(i)
		end
	end

	dump(self.way ,"<color=white> 刷新已获取 </color>")
end

function C:on_model_act_yxcj_box_exchange_info()
	if not self.isInitInfo then
		self:RefreshGeted()
		self:StratWink()
		self.isInitInfo = true
	end
end

function C:on_box_exchange_response(_, data)
	dump(data, "<color=white>赢金抽奖:on_box_exchange_response</color>")
	if data.result ~= 0 then
		return
	end

	local asset_id = data.award_id[1]
	if asset_id == sw_asset_id then
		self.LotteryAnimEndCall = function()
			-- LittleTips.Create(GLL.GetTx(81108))
			Act_YJCJRealGet.Create()
			self:AddPmdOppo()
			self.state = lotteryState.Wait
		end
	else
		self.LotteryAnimEndCall = function()
			self.state = lotteryState.Wait
			if self.curAwardData then
				AssetsGetPanel.Create(self.curAwardData, true)
				self:AddPMD(self.curAwardData)
			end
		end
	end
	self.curAwardId = M.GetAwardIdFromAssetId(asset_id)
	dump(self.curAwardId, "self.curAwardId")
	self.indexView = M.GetAwardCfgFromId(self.curAwardId).view_index
	dump(self.indexView, "<color=red>self.indexView</color>")
	if self.lv < 14 then
		self:PlayAnim(self.indexView)
	end

	if data.id == self.curBoxChangeId then
		self:MyRefresh()
	end

	if self.lv < 5 then
		Network.SendRequest("query_box_exchange_info",{id = M.box_change_id_below5})
	end

	self.isBoxChangeResponse = true
	self:CheckAndUpdateData()

	self.state = lotteryState.Lottery
end

function C:on_model_task_change_msg(data)
	dump(data, "<color=white>赢金抽奖:on_model_task_change_msg</color>")
	if data.id == M.task_id then
		self.isTaskChange = true
		self:CheckAndUpdateData()
	end
end

function C:AssetChange(data)
	if data.change_type and data.change_type == "box_exchange_active_award_" .. self.curBoxChangeId and not table_is_null(data.data) then
		dump(data, "<color=white> 赢金抽奖：AssetChange</color>")
		self.curAwardData = {data = data.data}
		self.isAssetChange = true
		self:CheckAndUpdateData()
	end
	self:RrfreshJf()
	self:RefreshLotteryBtn()
end

function C:AddPMD(data)
	local asset_type = data.data[1].asset_type
	local value = data.data[1].value
	
	local assetName = ""
	if asset_type == "jing_bi" then
		assetName = " Koin"
	elseif asset_type == "shop_gold_sum" then
		assetName = " RP"
	end

	local assetCount = StringHelper.ToCash(value)
	local _data = {player_name = MainModel.UserInfo.name, award_data = assetCount .. assetName}
	self.pmd_cont:AddMyPMDData(_data)
	-- self:CreatePMD(_data)
end

function C:AddPmdOppo()
	local data = {player_name = MainModel.UserInfo.name, award_data = "OPPO A16"}
	self.pmd_cont:AddMyPMDData(data)
	-- self:CreatePMD(data)
end

function C:CreatePMD(data)
	dump(data, "<color=red> PMD </color>")
	local obj = GameObject.Instantiate(GetPrefab("YJCJBroadcastCell"), self.pmd_node)
	local ui_t = {}
	LuaHelper.GeneratingVar(obj.transform, ui_t)
	ui_t.gb2_txt.text = data.player_name
	ui_t.gb4_txt.text = data.award_data
	return obj
end

function C:MyRefresh()
end