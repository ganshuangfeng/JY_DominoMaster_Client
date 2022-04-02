-- 创建时间:2021-12-15
-- Panel:SlotsMiniGame2Panel
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

SlotsMiniGame2Panel = basefunc.class()
local M = SlotsMiniGame2Panel
M.name = "SlotsMiniGame2Panel"

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
	SlotsGamePanel.Instance.AwardPool.gameObject:SetActive(true)
	SlotsGamePanel.Instance.AwardPoolBg.gameObject:SetActive(true)
	SlotsGamePanel.Instance.MiniGame2Bg.gameObject:SetActive(false)
	SlotsDeskPanel.Show(true)
	self:ClearItem()
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor(data)
	self:InitUI()
	self:MakeLister()
	self:AddMsgListener()
	self:InitLL()

	self:InitFree()
	self:SetFreeTxt(self.freeAllNum,self.freeCurNum)

	self:PlayStart(data)
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
	SlotsGamePanel.Instance.AwardPool.gameObject:SetActive(false)
	SlotsGamePanel.Instance.AwardPoolBg.gameObject:SetActive(false)
	SlotsGamePanel.Instance.MiniGame2Bg.gameObject:SetActive(true)
	SlotsDeskPanel.Show(false)
end

function M:MyRefresh()
	self:RefreshRate()
end

function M:RefreshRate()
	local gameData = SlotsModel.GetGameProcessCurData()
	local pro = SlotsModel.GetGameProcess()
	if gameData.game ~= "mini2" then
		return
	end
	local rate = gameData.rateInitItemE
	local c = 0
	for i = 1, pro.step do
		local itemDataMap = gameData.itemDataMapList[i]
		--绿福
		for y = SlotsModel.size.yMax, 1,-1 do
			for x = 1, SlotsModel.size.xMax do
				if itemDataMap[x][y] == "F" then
					c = c + 1
				end
			end
		end
	end
	rate = rate * c
	self.awardRate = rate
	self.mini_award_txt.text = rate > 0 and rate or ""
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
				end
			else
				self:AddItem(id,x,y,rate)
			end
		end
	end
end

function M:GetItem(x,y)
	if not self.itemGOMap or not next(self.itemGOMap) then
		return
	end
	return self.itemGOMap[x][y]
end

function M:AddItem(id,x,y,rate)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsItem.Create({id = id,x = x,y = y,rate = rate,parent = self.item_content})
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

local getScrollItemTime = function ()
	local allTime = 0
	local duration = SlotsModel.GetTime(SlotsModel.time.scrollItem)
	local interval = SlotsModel.GetTime(SlotsModel.time.scrollInterval)
	allTime = duration + interval * SlotsModel.size.xMax
	return allTime
end

function M:StartLottery(data,seq)
	seq = seq or SlotsHelper.GetSeq()
	local miniGame2WaitScroll = SlotsModel.GetTime(SlotsModel.time.miniGame2WaitScroll)
	seq:AppendInterval(miniGame2WaitScroll)
	seq:AppendCallback(function ()
		self:PlayItemScroll(data,1)
	end)
end

function M:PlayItemScroll(data,i)
	self:PlayAddCurFree(i)
	local seq = SlotsHelper.GetSeq()
	local itemDataMap = data.baseData.mini2Data.itemDataMapList[i]
	local initRate = data.baseData.mini2Data.rateInitItemE
	local rateMap = {}

	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if id == "F" then
				rateMap[x] = rateMap[x] or {}
				rateMap[x][y] = initRate
			end
		end
	end

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
		local miniGame2WaitLottery = SlotsModel.GetTime(SlotsModel.time.miniGame2WaitLottery)
		seq:AppendInterval(miniGame2WaitLottery)
		local t = SlotsModel.GetTime(SlotsModel.time.miniGame2EffectItemWinConnect)
		local t5Line = SlotsClearMini2Panel.Instance:Play5Line(SlotsHelper.GetSeq())
		local tNormal = SlotsClearPanel.Instance:PlayNormalNot5Line(SlotsHelper.GetSeq())
		local isNormalLV = SlotsClearPanel.Instance:CheckNormalLv()
		dump({t5Line,tNormal,isNormalLV},"<color=white>计算关系？？？？？</color>")
		--中奖动画
		seq:AppendCallback(function ()
			self:PlayLotteryAni(data.baseData.mini2Data,i,t5Line,isNormalLV)
		end)

		if t5Line and t5Line > t then
			seq:AppendInterval(t5Line)
		elseif tNormal and tNormal > t then
			seq:AppendInterval(tNormal)
		else
			seq:AppendInterval(t)
		end
		local t = SlotsModel.GetTime(SlotsModel.time.miniGame2SettlementItemWinConnect)
		seq:AppendInterval(t)
		seq:AppendCallback(function ()
			--弹出结算
			SlotsHelper.LotterySettlement()
		end)
	end

	local endCallback = function (v)
		if SlotsLib.CheckIdIsEFG(v.obj.data.id) then
			ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_luosheng.audio_name)
		end
	end

	--转动
	seq:AppendCallback(function ()
		SlotsAnimation.StartScroll(self.itemGOMap,"mini2",times,self.item_content)
	end)
	local t = getScrollItemTime()
	seq:AppendInterval(t)

	--停止转动
    seq:AppendCallback(function ()
        SlotsAnimation.StopScroll(itemDataMap,rateMap,"mini2",callback,times,endCallback)
    end)
end

function M:PlayLotteryAni(mini2Data,i,t5Line,isNormalLV)
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame2EffectItemWinConnect)
	local itemWinMap = SlotsLib.GetItemWinConnect(mini2Data.itemDataMapList[i],mini2Data.itemRateList[i])
	SlotsEffect.PlayItemWinConnect(itemWinMap,t,self.itemGOMap,t5Line)
	Event.Brocast("ItemWinConnect",{itemRate = mini2Data.itemRateList[i],t5Line = t5Line,isNormalLV = isNormalLV})
end

function M:PlayLotteryEnd()
	self:MyExit()
	Event.Brocast("CompleteMiniGame",{game = 2})
end

function M.MiniNext()
	if not instance then
		return
	end
	
	local data = SlotsModel.data
	local pro = SlotsModel.GetGameProcess()
	if pro.step > #data.baseData.mini2Data.itemDataMapList then
		instance:PlayLotteryEnd()
		return
	end

	local step = pro.step
	instance:PlayItemScroll(data,step)
end

function M:PlayStart(data)
	local seq = SlotsHelper.GetSeq()

	seq:AppendCallback(function ()
		--初始化桌面
		self:RefreshItem(data.baseData.mainData.itemDataMap,data.baseData.mainData.rateMapItemE)
	end)

	self:PlayItemEInitRate(seq)

	self:StartLottery(data,seq)
end

function M:PlayItemEInitRate(seq)
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame2InitRateEFlyFront)
	seq:AppendInterval(t)
	local rateMap = SlotsModel.data.baseData.mainData.rateMapItemE
	for x = 1, SlotsModel.size.xMax do
		for y = SlotsModel.size.yMax, 1,-1 do
			if rateMap[x] and rateMap[x][y] then
				local rate = rateMap[x][y]
				local awardTxt = self.grand_award_txt
				self.initRate = self.initRate or 0
				self.initRate = self.initRate + rate
				local allRate = self.initRate
				local callback = function ()
					self.grand_award_txt.text = allRate
				end
				seq:AppendCallback(function ()
					SlotsEffect.PlayMiniGame2RateInitFly(x,y,"E",rate,awardTxt,callback)
				end)
				local t = SlotsModel.GetTime(SlotsModel.time.miniGame2InitRateEFly)
				seq:AppendInterval(t)
			end
		end
	end
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame2InitRateEFlyBack)
	seq:AppendInterval(t)
end

function M:InitFree()
	self.freeAllNum = 8--#SlotsModel.data.baseData.mini2Data.itemDataMapList
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

function M:GetPlayRateAniTime()
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2RateAni)
	local c = 0
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if id == "F" then
				c = c + 1
			end
		end
	end
	return t * c
end

function M:PlayRateAni()
	local pro = SlotsModel.GetGameProcess()
	local gameData = SlotsModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	local rate = gameData.rateInitItemE
	local AddRate = function (x,y,id)
		self.awardRate = self.awardRate or 0
		self.awardRate = self.awardRate + rate
		local curRate = self.awardRate
		local callback = function ()
			self.mini_award_txt.text = curRate
		end
		local awardTxt = self.mini_award_txt
		SlotsEffect.PlayMiniGame2RateClearFly(x,y,id,rate,awardTxt,callback)
	end

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2RateAni)

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
end