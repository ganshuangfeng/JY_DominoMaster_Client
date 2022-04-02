-- 创建时间:2021-12-15
-- Panel:SlotsMiniGame1Panel
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

SlotsMiniGame1Panel = basefunc.class()
local M = SlotsMiniGame1Panel
M.name = "SlotsMiniGame1Panel"

local instance
function M.Create(seq,data)
	if instance then
		instance:MyExit()
	end
	instance = M.New(seq,data)
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
	ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_beijing.audio_name)
	SlotsGamePanel.Instance.AwardPoolBg.gameObject:SetActive(true)
	SlotsGamePanel.Instance.AwardPool.gameObject:SetActive(true)
	SlotsDeskPanel.Show(true)
	self:RemoveListener()
	self:ClearItem()
	self:ClearFixedItem()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor(data)
	self:InitUI()
	self:InitLL()

	self:MakeLister()
	self:AddMsgListener()


	self:InitFree()
	self:SetFreeTxt(self.freeAllNum,self.freeCurNum)

	self:StartLottery(data)
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_free_beijing.audio_name)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	SlotsGamePanel.Instance.AwardPoolBg.gameObject:SetActive(false)
	SlotsGamePanel.Instance.AwardPool.gameObject:SetActive(false)
	SlotsDeskPanel.Show(false)
end

function M:MyRefresh()

end

function M:RefreshFixedItem(itemMap,rateMap,fixedIds)
	local fixedMap = SlotsLib.GetFixedMap(itemMap,fixedIds)
	if not fixedMap or not next(fixedMap) then
		self:ClearFixedItem()
		return
	end

	for x, v in pairs(self.fixedItemGOMap or {}) do
		for y, item in pairs(v) do
			if not fixedMap[x] or not fixedMap[x][y] then
				self:RemoveFixedItem(x,y)
			end
		end
	end
	
	for x, v in pairs(fixedMap) do
		for y, id in pairs(v) do
			local rate = SlotsLib.GetMapValue(rateMap,x,y)
			if self.fixedItemGOMap and self.fixedItemGOMap[x] and self.fixedItemGOMap[x][y] then
				if self.fixedItemGOMap[x][y].data.id ~= id then
					--有元素，但是id不同
					self.fixedItemGOMap[x][y]:SetId(id)
					self.fixedItemGOMap[x][y]:SetRate(rate)
				end
			else
				self:AddFixedItem(id,x,y,rate)
			end
		end
	end
end

function M:AddFixedItem(id,x,y,rate)
	if self.fixedItemGOMap and self.fixedItemGOMap[x] and self.fixedItemGOMap[x][y] and self.fixedItemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.fixedItemGOMap = self.fixedItemGOMap or {}
	self.fixedItemGOMap[x] = self.fixedItemGOMap[x] or {}
	self.fixedItemGOMap[x][y] = SlotsItem.Create({id = id,x = x,y = y,rate = rate,parent = self.fixed_item_content})
	self.fixedItemGOMap[x][y]:SetBGActive(true)
end

function M:RemoveFixedItem(x,y)
	if not self.fixedItemGOMap or not self.fixedItemGOMap[x] or not self.fixedItemGOMap[x][y] then
		return
	end
	self.fixedItemGOMap[x][y]:Exit()
	self.fixedItemGOMap[x][y] = nil
end

function M:ClearFixedItem()
	if not self.fixedItemGOMap or not next(self.fixedItemGOMap) then
		return
	end
	for x, value in pairs(self.fixedItemGOMap) do
		for y, item in pairs(value) do
			item:Exit()
		end
	end
	self.fixedItemGOMap = nil
end


--根据当前状态刷新元素
function M:RefreshItem(itemDataMap,rateMap)
	if not itemDataMap or not next(itemDataMap) then
		self:ClearItem()
		return
	end
	for x, v in pairs(self.itemGOMap or {}) do
		for y, item in pairs(v) do
			if not itemDataMap[x] or not itemDataMap[x][y] then
				self:RemoveItem(x,y)
			end
		end
	end
	
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			local rate = SlotsLib.GetMapValue(rateMap,x,y)
			if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] then
				if self.itemGOMap[x][y].data.id ~= id then
					--有元素，但是id不同
					self.itemGOMap[x][y]:SetId(id)
					self.itemGOMap[x][y]:SetRate(rate)
					self:SetItemMat(self.itemGOMap[x][y])
				end
			else
				self:AddItem(id,x,y,rate)
			end
		end
	end
end

function M:AddItem(id,x,y,rate)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsItem.Create({id = id,x = x,y = y,rate = rate,parent = self.item_content})
	self:SetItemMat(self.itemGOMap[x][y])
end

function M:RemoveItem(x,y)
	if not self.itemGOMap or not self.itemGOMap[x] or not self.itemGOMap[x][y] then
		return
	end
	self.itemGOMap[x][y]:Exit()
	self.itemGOMap[x][y] = nil
end

function M:ClearItem()
	if not self.itemGOMap or not next(self.itemGOMap) then
		return
	end
	for x, value in pairs(self.itemGOMap) do
		for y, item in pairs(value) do
			item:Exit()
		end
	end
	self.itemGOMap = nil
end

function M:SetItemMat(item)
	local id = item.data.id
	if not SlotsLib.CheckIdIsEFG(id) then
		item:SetMat("ImageBlue1")
	else
		item:SetMat()
	end
end

local getScrollItemTime = function ()
	local allTime = 0
	local duration = SlotsModel.GetTime(SlotsModel.time.scrollItem)
	local interval = SlotsModel.GetTime(SlotsModel.time.scrollInterval)
	allTime = duration + interval * SlotsModel.size.xMax
	return allTime
end

function M:StartLottery(data)
	local seq = SlotsHelper.GetSeq()
	local miniGame1WaitScroll = SlotsModel.GetTime(SlotsModel.time.miniGame1WaitScroll)
	seq:AppendInterval(miniGame1WaitScroll)
	seq:AppendCallback(function ()
		self:PlayItemScroll(data,1)
	end)
end

function M:PlayItemScroll(data,i)
	local seq = SlotsHelper.GetSeq()
	local itemDataMap = data.baseData.mini1Data.itemDataMapList[i]

	local curItemDataMap = i == 1 and data.baseData.mainData.itemDataMap or data.baseData.mini1Data.itemDataMapList[i - 1]
	local curRateMap = i == 1 and data.baseData.mainData.rateMapItemE or data.baseData.mini1Data.rateMapItemEFGMap
	self:RefreshFixedItem(curItemDataMap,curRateMap,{E = "E",F = "F",G = "G"})
	self:RefreshItem(curItemDataMap,curRateMap)

	local times = {
        scrollSpeedUpInterval = SlotsModel.time.scrollSpeedUpInterval,
        scrollSpeedUpTime = SlotsModel.time.scrollSpeedUpTime,
        scrollSpeedUniformAllTime = SlotsModel.time.scrollSpeedUniformAllTime,
        scrollSpeedUniformOneTime = SlotsModel.time.scrollSpeedUniformOneTime,
        scrollSpeedDownInterval = SlotsModel.time.scrollSpeedDownInterval,
        scrollSpeedDownTime = SlotsModel.time.scrollSpeedDownTime,
        scrollSpeedUniformAddTime = SlotsModel.time.scrollSpeedUniformAddTime,
    }

	local function getScrollItemTime()
        local t = 0
        t = times.scrollSpeedUpTime + times.scrollSpeedUniformAllTime
        return t
    end

	local callback = function ()
		local seq = SlotsHelper.GetSeq()
		local miniGame1WaitLottery = SlotsModel.GetTime(SlotsModel.time.miniGame1WaitLottery)
		seq:AppendInterval(miniGame1WaitLottery)
		local t = SlotsModel.GetTime(SlotsModel.time.miniGame1Lottery)
		seq:AppendInterval(t)
		seq:AppendCallback(function ()
			--弹出结算
			SlotsHelper.LotterySettlement()
		end)
	end

	local endCallback = function (v)
		local id,x,y = v.obj.data.id,v.obj.data.x,v.obj.data.y
		if SlotsLib.CheckIdIsEFG(id) and not SlotsLib.CheckIdIsEFG(curItemDataMap[x][y]) then
			ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_luosheng.audio_name)
		end
	end

	--转动
	seq:AppendCallback(function ()
		self:PlayAddCurFree(i)
		SlotsAnimation.StartScroll(self.itemGOMap,"mini1",times,self.item_content)
	end)
	local t = getScrollItemTime()
	seq:AppendInterval(t)

	--停止转动
    seq:AppendCallback(function ()
        SlotsAnimation.StopScroll(itemDataMap,nil,"mini1",callback,times,endCallback)
    end)
end

function M:PlayLotteryEnd()
	self:MyExit()
	Event.Brocast("CompleteMiniGame",{game = 1})
end

function M.MiniNext()
	if not instance then
		return
	end
	
	local data = SlotsModel.data
	local pro = SlotsModel.GetGameProcess()
	if pro.step > #data.baseData.mini1Data.itemDataMapList then
		instance:PlayLotteryEnd()
		return
	end

	local step = pro.step
	instance:PlayItemScroll(data,step)
end

function M:GetPlayAwardAniTime()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1NormalItemAni)
	local c = 0
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	local itemDataMapFront = pro.step == 1 and SlotsModel.data.baseData.mainData.itemDataMap or gameData.itemDataMapList[pro.step - 1]
	local newItemEFGMap = {}
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if SlotsLib.CheckIdIsEFG(id) and not SlotsLib.CheckIdIsEFG(itemDataMapFront[x][y]) then
				newItemEFGMap[x] = newItemEFGMap[x] or {}
				newItemEFGMap[x][y] = id
			end
		end
	end

	for y = 1, SlotsModel.size.yMax do
		for x = 1, SlotsModel.size.xMax do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "E" then
					--红福
					c = c + 1
				end
			end
		end
	end

	for y = 1, SlotsModel.size.yMax do
		for x = 1, SlotsModel.size.xMax do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "F" then
					--绿福
					for y1 = 1, SlotsModel.size.yMax do
						for x1 = 1, SlotsModel.size.xMax do
							if itemDataMap[x1][y1] == "E" then
								--加上红福倍率
								c = c + 1
							end
						end
					end
				end
			end
		end
	end

	for y = 1, SlotsModel.size.yMax do
		for x = 1, SlotsModel.size.xMax do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "G" then
					--金福
					for y1 = 1, SlotsModel.size.yMax do
						for x1 = 1, SlotsModel.size.xMax do
							if itemDataMap[x1][y1] == "E" then
								--加上红福倍率
								c = c + 1
							end
						end
					end

					for y1 = 1, SlotsModel.size.yMax do
						for x1 = 1, SlotsModel.size.xMax do
							if itemDataMap[x1][y1] == "F" then
								--加上绿福倍率
								c = c + 1
							end
						end
					end

					for y1 = 1, SlotsModel.size.yMax do
						for x1 = 1, SlotsModel.size.xMax do
							if itemDataMapFront[x1][y1] == "G" then
								--上一轮的金福
								--加上金福倍率
								c = c + 1
							elseif itemDataMap[x1][y1] == "G" and x ~= x1 and y ~= y1 then
								local ci = SlotsLib.GetIndexByPos({x = x,y = y})
								local oi = SlotsLib.GetIndexByPos({x = x1,y = y1})
								if oi < ci then
									--加上金福倍率
									c = c + 1
								end
							end
						end
					end
				end
			end
		end
	end
	return t * c
end

function M:PlayAwardAni()
	--上一轮的福加到这一轮，红-》绿 -》金
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	local itemDataMapFront = pro.step == 1 and SlotsModel.data.baseData.mainData.itemDataMap or gameData.itemDataMapList[pro.step - 1]
	local itemRateMap = gameData.rateMapItemEFGMap
	local newItemEFGMap = {}
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if SlotsLib.CheckIdIsEFG(id) and not SlotsLib.CheckIdIsEFG(itemDataMapFront[x][y]) then
				newItemEFGMap[x] = newItemEFGMap[x] or {}
				newItemEFGMap[x][y] = id
			end
		end
	end

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1NormalItemAni)

	local AddRate = function (rate,x,y,x1,y1)
		local oldRate = self.itemGOMap[x][y]:GetRate()
		local allRate = oldRate + rate
		self.itemGOMap[x][y]:SetRateData(allRate)
		if not x1 or not y1 then
			self.itemGOMap[x][y]:SetRateTxt(allRate)
		else
			local callback = function ()
				self.itemGOMap[x][y]:SetRateTxt(allRate)
			end
			local endPos = self.itemGOMap[x][y]:GetPosition()
			local startPos = self.itemGOMap[x1][y1]:GetPosition()
			local rate = itemRateMap[x1][y1]
			local id = self.itemGOMap[x1][y1]:GetId()
			SlotsEffect.PlayMiniGame1RateFly(id,rate,startPos,endPos,callback)
		end
	end

	for x = 1,SlotsModel.size.xMax do
		for y = SlotsModel.size.yMax,1,-1 do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "E" then
					--红福
					local rate = itemRateMap[x][y]
					seq:AppendCallback(function ()
						AddRate(rate,x,y)
					end)
					seq:AppendInterval(t)
				end
			end
		end
	end

	for x = 1,SlotsModel.size.xMax do
		for y = SlotsModel.size.yMax,1,-1 do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "F" then
					--绿福
					for x1 = 1, SlotsModel.size.xMax do
						for y1 = SlotsModel.size.yMax,1,-1 do
							if itemDataMap[x1][y1] == "E" then
								--加上红福倍率
								local rate = itemRateMap[x1][y1]
								seq:AppendCallback(function ()
									AddRate(rate,x,y,x1,y1)
								end)
								seq:AppendInterval(t)
							end
						end
					end
				end
			end
		end
	end

	for x = 1,SlotsModel.size.xMax do
		for y = SlotsModel.size.yMax,1,-1 do
			if newItemEFGMap[x] and newItemEFGMap[x][y] then
				local id = newItemEFGMap[x][y]
				if id == "G" then
					--金福
					for x1 = 1, SlotsModel.size.xMax do
						for y1 = SlotsModel.size.yMax,1,-1 do
							if itemDataMap[x1][y1] == "E" then
								--加上红福倍率
								local rate = itemRateMap[x1][y1]
								seq:AppendCallback(function ()
									AddRate(rate,x,y,x1,y1)
								end)
								seq:AppendInterval(t)
							end
						end
					end

					for x1 = 1, SlotsModel.size.xMax do
						for y1 = SlotsModel.size.yMax,1,-1 do
							if itemDataMap[x1][y1] == "F" then
								--加上绿福倍率
								local rate = itemRateMap[x1][y1]
								seq:AppendCallback(function ()
									AddRate(rate,x,y,x1,y1)
								end)
								seq:AppendInterval(t)
							end
						end
					end

					for x1 = 1, SlotsModel.size.xMax do
						for y1 = SlotsModel.size.yMax,1,-1 do
							if itemDataMapFront[x1][y1] == "G" then
								--上一轮的金福
								--加上金福倍率
								local rate = itemRateMap[x1][y1]
								seq:AppendCallback(function ()
									AddRate(rate,x,y,x1,y1)
								end)
								seq:AppendInterval(t)
							elseif itemDataMap[x1][y1] == "G" and (x ~= x1 or y ~= y1) then
								if x > x1 or (x == x1 and y < y1) then
									--加上金福倍率
									local rate = itemRateMap[x1][y1]
									seq:AppendCallback(function ()
										AddRate(rate,x,y,x1,y1)
									end)
									seq:AppendInterval(t)
								end
							end
						end
					end
				end
			end
		end
	end
end

function M:GetPlayRateAniTime()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[#gameData.itemDataMapList]
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1RateAni)
	local c = 0
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if SlotsLib.CheckIdIsEFG(id) then
				c = c + 1
			end
		end
	end
	return t * c
end

function M:PlayRateAni()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[#gameData.itemDataMapList]
	local itemRateMap = gameData.rateMapItemEFGMap
	local allRate = 0

	for x, v in pairs(itemRateMap) do
		for y, rate in pairs(v) do
			allRate = allRate + rate
		end
	end

	self.award.gameObject:SetActive(true)
	local AddRate = function (x,y,id)
		local rate = itemRateMap[x][y]
		self.awardRate = self.awardRate or 0
		self.awardRate = self.awardRate + rate
		local curRate = self.awardRate
		local callback = function ()
			self.award_txt.text = curRate
		end
		local awardTxt = self.award_txt
		if self.itemGOMap[x] and self.itemGOMap[x][y] then
			self.itemGOMap[x][y]:SetRateTxt("")
		end
		
		if self.fixedItemGOMap[x] and self.fixedItemGOMap[x][y] then
			self.fixedItemGOMap[x][y]:SetRateTxt("")
		end
		SlotsEffect.PlayMiniGame1RateClearFly(x,y,id,rate,awardTxt,callback)
	end

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1RateAni)

	--红福
	for y = SlotsModel.size.yMax, 1,-1 do
		for x = 1, SlotsModel.size.xMax do
			if itemDataMap[x][y] == "E" then
				seq:AppendCallback(function ()
					AddRate(x,y,"E")
				end)
				seq:AppendInterval(t)
			end
		end
	end
	--绿福
	for y = SlotsModel.size.yMax, 1,-1 do
		for x = 1, SlotsModel.size.xMax do
			if itemDataMap[x][y] == "F" then
				seq:AppendCallback(function ()
					AddRate(x,y,"F")
				end)
				seq:AppendInterval(t)
			end
		end
	end
	--金福
	for y = SlotsModel.size.yMax, 1,-1 do
		for x = 1, SlotsModel.size.xMax do
			if itemDataMap[x][y] == "G" then
				seq:AppendCallback(function ()
					AddRate(x,y,"G")
				end)
				seq:AppendInterval(t)
			end
		end
	end

	seq:OnKill(function ()
		self.award_txt.text = allRate
	end)
end

function M:InitFree()
	local c = #SlotsModel.data.baseData.mini1Data.itemDataMapList
	c = c - SlotsModel.data.baseData.mini1Data.itemHNum
	self.freeAllNum = 6--c
	self.freeCurNum = 0
end

function M:SetFreeTxt(allNum,curNum)
	self.free_num_txt.text = (allNum - curNum) .. "/" .. allNum
end

function M:PlayAddFree(x,y)
	self.freeAllNum = self.freeAllNum + 1
	local c = self.freeAllNum
	local callback = function ()
		self:SetFreeTxt(c,self.freeCurNum)
	end
	local startPos = self.itemGOMap[x][y]:GetPosition()
	local endPos = self.free.transform.position
	SlotsEffect.PlayAddFree(startPos,endPos,callback)
end

function M:PlayAddCurFree(i)
	self.freeCurNum = i
	self:SetFreeTxt(self.freeAllNum,self.freeCurNum)
end