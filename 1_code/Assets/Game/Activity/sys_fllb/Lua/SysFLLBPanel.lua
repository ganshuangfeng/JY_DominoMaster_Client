-- 创建时间:2022-01-06
-- Panel:SysFLLBPanel
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

SysFLLBPanel = basefunc.class()
local C = SysFLLBPanel
C.name = "SysFLLBPanel"
local M = SysFLLBManager

local pro_config = {
	[1] = {min = 0,max = 46.04},
	[2] = {min = 78.36,max = 122.49},
	[3] = {min = 155.86,max = 198.94},
	[4] = {min = 233.130,max = 276},
	[5] = {min = 311.1,max = 354},
	[6] = {min = 389.32,max = 431.64},
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
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
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
	self:SetBestBtn()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.buy_wait_btn.onClick:AddListener(
		function ()
			LittleTips.Create(GLL.GetTx(80026))
		end
	)

	self.buy_btn.onClick:AddListener(
		function ()
			self:BuyShopByID(self.curr_lb_id)
		end
	)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.buy_wait_btn.onClick:RemoveAllListeners()
	self.buy_btn.onClick:RemoveAllListeners()
	for i = 1,7 do
		self["pro_item_"..i]:GetComponent("Button").onClick:RemoveAllListeners()
	end
	local temp_ui = {}
	for k, v in pairs(self.task_items) do
		LuaHelper.GeneratingVar(v.transform,temp_ui)
		temp_ui.go_btn.onClick:RemoveAllListeners()
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self.item_ui = {}
	for i = 1,7 do
		local temp_ui = {}
		LuaHelper.GeneratingVar(self["pro_item_"..i].transform,temp_ui)
		self.item_ui[#self.item_ui+1] = temp_ui
		self["pro_item_"..i]:GetComponent("Button").onClick:AddListener(
			function ()
				if self.curr_lb_id == M.GetLBIDs()[i] then
					return
				end
				for ii = 1,7 do
					self.item_ui[ii].chose.gameObject:SetActive(false)
				end
				self.curr_lb_id = M.GetLBIDs()[i]
				self.item_ui[i].chose.gameObject:SetActive(true)
				self:RefreshUI(self.curr_lb_id)
			end
		)
	end
	self:MyRefresh()
	self.desc5_txt.text = GLL.GetTx(80030)
end

function C:MyRefresh()
	local shop_id = M.GetCurrShopID()
	dump(shop_id,"<color=red> 商品的ID </color>")
	for ii = 1,7 do
		self.item_ui[ii].chose.gameObject:SetActive(false)
	end

	self.curr_lb_id = shop_id
	local index = 1

	for i = 1,#M.GetLBIDs() do
		if M.GetLBIDs()[i] == self.curr_lb_id then
			index = i 
		end
	end

	self.item_ui[index].chose.gameObject:SetActive(true)
	
	self:RefreshUI(self.curr_lb_id)

end

--通过商品ID购买商品
function C:BuyShopByID(shop_id)
	GameManager.BuyGift(shop_id)
end
--根据商品ID刷新界面UI
function C:RefreshUI(shop_id)

	local data = GameGiftManager.GetGiftConfig(shop_id)
	if not data then
		return
	end

	local jing_bi = data.buy_asset_count[1]
	self.jing_bi_txt.text = StringHelper.ToCash(jing_bi)
	local task_id = M.GetTaskIDByShopID(shop_id)
	self.curr_task_id = task_id
	dump(data,"<color=red>礼包的配置</color>")
	local task_config = GameTaskManager.GetTaskConfigByTaskID(task_id)
	dump(task_config,"<color=red>任务的配置</color>")
	local get_total_rp = function ()
		local total = 0
		for k , v in pairs(task_config.award_data) do
			total = total + v.asset_count
		end
		return total / 100
	end
	local total = get_total_rp()
	self.rp_txt.text = StringHelper.ToCash(total)
	self.lb_desc_txt.text = string.format( "Dapatkan <color=#ffe614>%s</color> Koin,\nDapatkan total <color=#ffe614>%s</color> RP",StringHelper.ToCash(jing_bi),StringHelper.ToCash(total) ) 

	self.task_items = self.task_items or {}
	for i = 1,#self.task_items do
		destroy(self.task_items[i].gameObject)
	end
	self.task_items = {}

	local get_need = function (index)
		local total = 0
		for i = 1,index do
			total = total + task_config.process_data.process[i]
		end
		return total
	end

	local index = 1
	for i = 1,#M.GetLBIDs() do
		if M.GetLBIDs()[i] == self.curr_lb_id then
			index = i 
		end
	end
		
	self.desc3_txt.text = StringHelper.ToCash(M.GetTotalJingBi(index))

	for i = 1,#task_config.process_data.awards do
		local temp_ui = {}
		local award_id = task_config.process_data.awards[i]
		local award_data = task_config.award_data[award_id]
		local obj = GameObject.Instantiate(self.task_item,self.Content)
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.mask.gameObject:SetActive(false)
		temp_ui.award_txt.text = award_data.asset_count / 100
		temp_ui.award2_txt.text =  StringHelper.ToCash(get_need(i)).." <color=#D15652>Koin</color>"
		temp_ui.go_btn.onClick:AddListener(
			function ()
				GameManager.CommonGotoScence({gotoui = "game_DominoJLHall",goto_scene_parm = {domino_type = 1}}, function()
					print("进入多米诺大厅")
				end)
				self:MyExit()
			end
		)
		temp_ui.get_btn.onClick:AddListener(
			function ()
				Network.SendRequest("get_task_award_new",{id = SysFLLBManager.GetTaskIDByShopID(self.curr_lb_id),award_progress_lv = i})
			end
		)
		obj.gameObject:SetActive(true)
		self.task_items[#self.task_items+1] = obj
	end

	self.buy_mask.gameObject:SetActive(not GameGiftManager.IsCanBuytGift(shop_id))

	if GameGiftManager.IsCanBuytGift(shop_id) then
		self.buy_btn.gameObject:SetActive(true)
		self.buy_wait_btn.gameObject:SetActive(false)
	else

		self.buy_btn.gameObject:SetActive(false)
		if self.buy_mask.gameObject.activeSelf then
			self.buy_wait_btn.gameObject:SetActive(true)
		end	
	end
	--当这个礼包还没有购买过，但是之前的任务还没有完成
	dump(GameGiftManager.IsCanBuytGift(self.curr_lb_id))
	dump(self:IsCanBuy(self.curr_lb_id))
	if GameGiftManager.IsCanBuytGift(self.curr_lb_id) then
		if not self:IsCanBuy(self.curr_lb_id) then
			self.buy_btn.gameObject:SetActive(false)
			self.buy_wait_btn.gameObject:SetActive(true)
		end
	end
	self:RefreshTaskItem()
end

function C:RefreshTaskItem()
	local data = GameTaskManager.GetTaskDataByID(self.curr_task_id)
	self.desc4_node.gameObject:SetActive(true)
	self.desc5_node.gameObject:SetActive(false)
	
	if data then
		if data.now_process >= data.need_process and data.level == 7 then
			self.desc4_node.gameObject:SetActive(false)
			self.desc5_node.gameObject:SetActive(true)
		end
	end
	dump(data,"<color=red>  任务数据 </color>")
	self.pro_width.sizeDelta = {
		x = 0,
		y = 10
	}
	for i = 1,7 do
		local iscanbuy = GameGiftManager.IsCanBuytGift(M.GetLBIDs()[i])
		local obj = self["pro_item_"..i]
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.lock.gameObject:SetActive(iscanbuy)
		temp_ui.buyed.gameObject:SetActive(not iscanbuy)
		temp_ui.price_txt.text = "IDR "..StringHelper.ToCash(GameGiftManager.GetGiftConfig(M.GetLBIDs()[i]).price/100, i == 1)
		--特殊处理，免出框自适应
		if i == 1 then
			-- temp_ui.price_txt.text = "IDR 5K"
			temp_ui.price_txt.alignment = Enum.TextAnchor.MiddleLeft
			temp_ui.price_txt.text = "           " .. temp_ui.price_txt.text
		end
		local task_data = GameTaskManager.GetTaskDataByID(M.GetTaskIDByShopID(M.GetLBIDs()[i]))
		if task_data and task_data.award_status == 2 then
			if i < 7 then
				self.pro_width.sizeDelta = {
					x = pro_config[i].max,
					y = 10
				}
			end
		end
		temp_ui.can_buy.gameObject:SetActive(self:GetShouldBuy() == i)
	end
	local task_id = SysFLLBManager.GetTaskIDByShopID(self.curr_lb_id)
	local task_data = GameTaskManager.GetTaskDataByID(task_id)
	local status
	if task_data then
		status = GameTaskManager.GetTaskStatusByData(task_data,#self.task_items)
	end
	dump(status,"<color=red>任务状态数据</color>")

	for i = 1,#self.task_items do
		local temp_ui = {}
		LuaHelper.GeneratingVar(self.task_items[i],temp_ui)
		temp_ui.wait_btn.onClick:AddListener(
			function ()
				LittleTips.Create(GLL.GetTx(80029))
			end
		)
		if task_data then
			temp_ui.go_btn.gameObject:SetActive(true)
			temp_ui.get_btn.gameObject:SetActive(true)

			if status then
				local b = status[i]
				if b == 1 then
					temp_ui.get_btn.gameObject:SetActive(true)
					temp_ui.go_btn.gameObject:SetActive(false)
				elseif b == 2 then
					temp_ui.mask.gameObject:SetActive(true)
					temp_ui.had_got_btn.gameObject:SetActive(true)
				else
					temp_ui.get_btn.gameObject:SetActive(false)
					temp_ui.go_btn.gameObject:SetActive(true)				
				end
			end
		else
			temp_ui.go_btn.gameObject:SetActive(false)
			temp_ui.get_btn.gameObject:SetActive(false)
		end
	end
	self:SetTaskItemJingDu()
end
--根据ID判断是否可以购买礼包
function C:IsCanBuy(shop_id)
	local index = 0
	for i = 1,#M.GetLBIDs() do
		if M.GetLBIDs()[i] == shop_id then
			index = i
			break
		end
	end
	dump(index,"<color=red> 序列 </color>")
	if index > 1 then
		local ii = index - 1
		local data = GameTaskManager.GetTaskDataByID(M.GetTaskIDs()[ii])
		if data and data.award_status == 2 then
			return true
		end
	else
		local data = GameTaskManager.GetTaskDataByID(M.GetTaskIDs()[1])
		if data == nil then
			return true
		end
	end

	return false
end

--任务改变
function C:on_model_task_change_msg(data)
	dump(data,"<color=red> 任务发生改变 </color>")
	Timer.New(
		function ()
			self:RefreshUI(self.curr_lb_id)
		end,0.2,1
	):Start()
end

--查看一个礼包是否激活过
function C:CheckShopIDIsActived(shop_id)
	local task_id = SysFLLBManager.GetTaskIDByShopID(shop_id)
	local data = GameTaskManager.GetTaskDataByID(task_id)
	if data then
		return false
	end
	return true
end

--得到一个礼包的顺序，如果这个礼包之前的礼包的任务已经完成，并且这个礼包还没有被买过

function C:GetShouldBuy()
	local shop_id = M.GetLBIDs()
	for i = #shop_id,1,-1 do
		local iscanbuy = GameGiftManager.IsCanBuytGift(shop_id[i])
		if iscanbuy then
			if i > 1 then
				local task_id = M.GetTaskIDs()[i - 1]
				local data = GameTaskManager.GetTaskDataByID(task_id)
				if data and data.award_status == 2 then
					return i
				end
			else
				return 1
			end
		end
	end
	return -1
end

--根据当前任务的状况，选择一个进度
function C:SetTaskItemJingDu()
	local task_data = GameTaskManager.GetTaskDataByID(self.curr_task_id)
	--优先找一个可以领取奖励的item
	local index = -1
	for i = 1,#self.task_items do
		local status
		if task_data then
			status = GameTaskManager.GetTaskStatusByData(task_data,#self.task_items)
		end
		if status and status[i] == 1 then
			index = i
			break
		end
	end

	--再找一个最近已经完成的
	if index == -1 then
		for i = 1,#self.task_items do
			local status
			if task_data then
				status = GameTaskManager.GetTaskStatusByData(task_data,#self.task_items)
			end
			if status and status[i] == 2 then
				index = i + 1
			end
		end
	end

	if index == -1 then
		index = 1
	end

	if index < 5 then
		self.Content.transform.localPosition = Vector3.New((-153.7 + 6.83 ) * (index - 1),-116,0)
	else
		self.Content.transform.localPosition = Vector3.New((-153.7 + 6.83 ) * (5 - 1),-116,0)
	end
	dump(self.Content.transform.localPosition,"<color=red>ggggggggg</color>")
end

--根据当前的的奖励情况帮助用户选择按钮

function C:SetBestBtn()
	local index = -1
	for i = 1,#M.GetTaskIDs() do
		local data = GameTaskManager.GetTaskDataByID(M.GetTaskIDs()[i])
		if data and data.award_status == 1 then
			index = i
			break
		end
	end

	if index == -1 then
		for i = #M.GetTaskIDs(),1,-1 do
			local data = GameTaskManager.GetTaskDataByID(M.GetTaskIDs()[i])
			if data and data.award_status == 0 then
				index = i
				break
			end
		end
	end
	
	if index == -1 then
		index = 1
	else
		for ii = 1,7 do
			self.item_ui[ii].chose.gameObject:SetActive(false)
		end
	
		self.curr_lb_id = M.GetLBIDs()[index]
		self.item_ui[index].chose.gameObject:SetActive(true)
		self:RefreshUI(self.curr_lb_id)
	end

end