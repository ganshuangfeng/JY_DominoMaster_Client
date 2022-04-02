-- 创建时间:2021-12-15
-- Panel:SlotsLionGameMini1Panel
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

SlotsLionGameMini1Panel = basefunc.class()
local M = SlotsLionGameMini1Panel
M.name = "SlotsLionGameMini1Panel"

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

function M.Show(b)
	instance.gameObject:SetActive(b)
	SlotsLionGameMainPanel.Instance.gameObject:SetActive(not b)
	SlotsLionGamePanel.Instance.bg1.gameObject:SetActive(not b)
	SlotsLionGamePanel.Instance.bg2.gameObject:SetActive(b)
	if b then
		ExtendSoundManager.PlaySceneBGM(audio_config.lion.bgm_lion_free_beijing.audio_name,false)
	end
end

function M.Start(data)
	if not instance then
		return
	end

	if not SlotsLionModel.data.baseData.mini1Data or not next(SlotsLionModel.data.baseData.mini1Data) then
		instance:PlayLotteryEnd()
		return
	end
	SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(false)
	-- ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jp_chufa.audio_name)
	instance:InitFree()
	instance:SetFreeTxt(instance.freeAllNum,instance.freeCurNum)
	M.Show(true)
	instance:StartLottery()
end
	
function M.Next(data)
	if not instance then
		return
	end
	M.Show(true)
	SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(false)
	local data = SlotsLionModel.data
	local pro = SlotsLionModel.GetGameProcess()
	if pro.step > #data.baseData.mini1Data.itemDataMapList then
		instance:PlayLotteryEnd()
		return
	end

	local step = pro.step
	instance:PlayItemScroll(step)
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
	ExtendSoundManager.PlaySceneBGM(audio_config.lion.bgm_lion_beijing.audio_name)
	if M.scrollAni then
		M.scrollAni:ClearItemObjMap()
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
	self:RemoveListener()
	self:ClearItem()
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
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtPanel.ExtMsg(self)
	local parent = SlotsLionGamePanel.Instance.GameMini1
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:MyRefresh()
	M.Show(false)
end

--根据当前状态刷新元素
function M:RefreshItem(itemDataMap)
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
			if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] then
				if self.itemGOMap[x][y].data.id ~= id then
					--有元素，但是id不同
					self.itemGOMap[x][y]:SetId(id)
				end
			else
				self:AddItem(id,x,y)
			end
		end
	end
end

function M:AddItem(id,x,y)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsLionItem.Create({id = id,x = x,y = y,parent = self.item_content})
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

function M:StartLottery()
	local seq = SlotsLionHelper.GetSeq()
	local miniGame1WaitScroll = SlotsLionModel.GetTime(SlotsLionModel.time.miniGame1WaitScroll)
	seq:AppendInterval(miniGame1WaitScroll)
	seq:AppendCallback(function ()
		self:PlayItemScroll(1)
	end)
end

function M:PlayItemScroll(i)
	if M.scrollAni then
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
	M.scrollAni = ScrollAnimation.Create()
	local data = SlotsLionModel.data
	local seq = SlotsLionHelper.GetSeq()

	local itemDataMap = data.baseData.mini1Data.itemDataMapList[i]

	local curItemDataMap = i == 1 and data.baseData.mainData.itemDataMap or data.baseData.mini1Data.itemDataMapList[i - 1]
	self:RefreshItem(curItemDataMap)
	self:HideLionAll()
	local times = {
        scrollSpeedUpInterval = SlotsLionModel.time.scrollSpeedUpInterval,
        scrollSpeedUpTime = SlotsLionModel.time.scrollSpeedUpTime,
        scrollSpeedUniformAllTime = SlotsLionModel.time.scrollSpeedUniformAllTime,
        scrollSpeedUniformOneTime = SlotsLionModel.time.scrollSpeedUniformOneTime,
        scrollSpeedDownInterval = SlotsLionModel.time.scrollSpeedDownInterval,
        scrollSpeedDownTime = SlotsLionModel.time.scrollSpeedDownTime,
        scrollSpeedUniformAddTime = SlotsLionModel.time.scrollSpeedUniformAddTime,
    }

	local function getScrollItemTime()
        local t = 0
        t = times.scrollSpeedUpTime + times.scrollSpeedUniformAllTime
        return t
    end

	local callback = function ()
		local seq = SlotsLionHelper.GetSeq()
		local miniGame1WaitLottery = SlotsLionModel.GetTime(SlotsLionModel.time.miniGame1WaitLottery)
		seq:AppendInterval(miniGame1WaitLottery)
		local t = SlotsLionModel.GetTime(SlotsLionModel.time.miniGame1Lottery)
		seq:AppendInterval(t)
		seq:AppendCallback(function ()
			--弹出结算
			SlotsLionHelper.LotterySettlement({game = "mini1"})
		end)
	end

	local endCallback = function (v)
		local id,x,y = v.obj.data.id,v.obj.data.x,v.obj.data.y
	end

	--转动
	seq:AppendCallback(function ()
		self:PlayAddCurFree(i)
		self:HideLionAll()
		for x, v in pairs(itemDataMap) do
			for y, id in pairs(v) do
				if id == "9" then
					self:ShowLion(x,true)
				end
			end
		end
		SlotsLionAnimation.StartScroll(self.itemGOMap,"mini1",times,self.item_content,M.scrollAni)
		SlotsLionHelper.StartMini2Scroll()
	end)
	local t = getScrollItemTime()
	seq:AppendInterval(t)

	--停止转动
    seq:AppendCallback(function ()
        SlotsLionAnimation.StopScroll(itemDataMap,nil,"mini1",callback,times,endCallback,M.scrollAni)
    end)
end

function M:PlayLotteryEnd()
	M.Show(false)
	self:HideLionAll()
	Event.Brocast("CompleteMiniGame",{game = "mini1"})
	ExtendSoundManager.PlaySceneBGM(audio_config.lion.bgm_lion_beijing.audio_name,false)
end

function M:HideLionAll()
	for i = 1, 5 do
		self["lion" .. i .. "_award"].gameObject:SetActive(false)
	end
end

function M:ShowLion(i,b)
	if b then
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_lion_chufa.audio_name)
	end
	self["lion" .. i .. "_award"].gameObject:SetActive(b)
end

function M:GetPlayAwardAniTime()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1NormalItemAni)
	return t
end

function M:PlayAwardAni()
	
end

function M:GetPlayRateAniTime()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1RateAni)
	return t
end

function M:PlayRateAni()
	
end

function M:InitFree()
	self.freeAllNum = SlotsLionModel.data.baseData.mini1Data.freeCount[1].all
	self.freeCurNum = 0
end

function M:SetFreeTxt(allNum,curNum)
	self.free_num_txt.text = (allNum - curNum) .. "/" .. allNum
end

function M:PlayAddFree(freeCount)
	self.freeAllNum = freeCount.all
	local c = self.freeAllNum
	local callback = function ()
		self:SetFreeTxt(c,self.freeCurNum)
	end
	local pro = SlotsLionModel.GetGameProcess()
	local gameData = SlotsLionModel.GetGameProcessCurData()
	local itemDataMap = gameData.itemDataMapList[pro.step]
	SlotsLionEffect.PlayItemARoll(itemDataMap,callback)
end

function M:PlayAddCurFree(i)
	self.freeCurNum = i
	self:SetFreeTxt(self.freeAllNum,self.freeCurNum)
end