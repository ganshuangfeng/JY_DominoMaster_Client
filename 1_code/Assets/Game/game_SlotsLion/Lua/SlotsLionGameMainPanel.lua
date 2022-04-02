-- 创建时间:2021-12-17
-- Panel:SlotsLionGameMainPanel
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

SlotsLionGameMainPanel = basefunc.class()
local M = SlotsLionGameMainPanel
M.name = "SlotsLionGameMainPanel"

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

function M.Show(b)
	if not instance then
		return
	end
	instance.gameObject:SetActive(b)
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
    if M.scrollAni then
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	ExtPanel.ExtMsg(self)
	local parent = SlotsLionGamePanel.Instance.GameMain
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()

	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	
end

function M:MyRefresh()
	SlotsLionGamePanel.Instance.bg1.gameObject:SetActive(true)
	SlotsLionGamePanel.Instance.bg2.gameObject:SetActive(false)
	self:RefreshItem()
	self:RefreshLion()
end

--根据当前状态刷新元素
function M:RefreshItem()
	if not SlotsLionModel.data or not next(SlotsLionModel.data)
	or not SlotsLionModel.data.baseData or not next(SlotsLionModel.data.baseData)
	or not SlotsLionModel.data.baseData.mainData.itemDataMap or not next(SlotsLionModel.data.baseData.mainData.itemDataMap) then
		self:ClearItem()
		return
	end
	local itemDataMap = SlotsLionModel.data.baseData.mainData.itemDataMap
	local rateMapItemE = SlotsLionModel.data.baseData.mainData.rateMapItemE

	for x, v in pairs(self.itemGOMap or {}) do
		for y, item in pairs(v) do
			if not itemDataMap[x] or not itemDataMap[x][y] then
				self:RemoveItem(x,y)
			end
		end
	end
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			local rate = SlotsLionLib.GetMapValue(rateMapItemE,x,y)
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

function M:AddItem(id,x,y,rate)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsLionItem.Create({id = id,x = x,y = y,rate = rate,parent = self.item_content})
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

function M:GetItemMap()
	return self.itemGOMap
end

function M:StartScroll()
	self:HideLionAll()
	local data = SlotsLionModel.data

    local itemObjMap,itemDataMap,parent = SlotsLionGameMainPanel.Instance:GetItemMap(), basefunc.deepcopy(data.baseData.mainData.itemDataMap),SlotsLionGameMainPanel.Instance.item_content

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

    local function callback()
        local seq = SlotsLionHelper.GetSeq()
        self:ChangeLion(itemDataMap,seq)
        seq:AppendCallback(function ()
            SlotsLionHelper.LotterySettlement({game = "main"})
        end)
    end

    if M.scrollAni then
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
    M.scrollAni = ScrollAnimation.Create()
    
    local seq = SlotsLionHelper.GetSeq()
    --开始转动
    seq:AppendCallback(function ()
        SlotsLionAnimation.StartScroll(itemObjMap,"main",times,parent,M.scrollAni)
    end)
    local t = SlotsLionModel.GetTime(getScrollItemTime())
    seq:AppendInterval(t)
    --停止转动
    seq:AppendCallback(function ()
        SlotsLionAnimation.StopScroll(itemDataMap,nil,"main",callback,times,nil,M.scrollAni)
    end)
    M.mainScrollSeq = seq
end

function M:StopScroll()
	local gameData = SlotsLionModel.GetGameProcessCurData()
    if gameData.game ~= "main" then
        return
    end

    if M.mainScrollSeq then
        if M.mainScrollSeq:IsComplete() then
            return
        else
            M.mainScrollSeq:Kill()
        end
    end
    M.mainScrollSeq = nil

    local data = SlotsLionModel.data
    local itemDataMap = basefunc.deepcopy(data.baseData.mainData.itemDataMap)

    local function callback()
		if self:CheckChangeLion(data.baseData.mainData.itemDataMap) then
			local _xMax = SlotsLionModel.size.xMax
			local _yMax = SlotsLionModel.size.yMax
			for x = 1, _xMax do
				if data.baseData.mainData.itemDataMap[x][_yMax] == "9" then
					self:ShowLion(x,true)
				end
			end
		end
		
        local seq = SlotsLionHelper.GetSeq()
        seq:AppendCallback(function ()
            SlotsLionHelper.LotterySettlement({game = "main"})
        end)
    end

    SlotsLionAnimation.SkipScroll(itemDataMap,nil,"main",callback,M.scrollAni)
end

function M:CheckChangeLion(idm)
	local c = 0
	local _xMax = SlotsLionModel.size.xMax
	local _yMax = SlotsLionModel.size.yMax
    for x = 1, _xMax do
        if idm[x][_yMax] == "9" then
            c = c + 1
        end
    end
	dump({idm,c},"<color=green>变狮子头</color>")
	if c < 2 then
		return
	end
	return true
end

function M:ChangeLion(idm,seq)
	if not self:CheckChangeLion(idm) then
		return
	end

	local _xMax = SlotsLionModel.size.xMax
	local _yMax = SlotsLionModel.size.yMax
    seq:AppendCallback(function ()
		for x = 1, _xMax do
			if idm[x][_yMax] == "9" then
				self:ShowLion(x,true)
			end
		end
    end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.settlementItemWinConnect)
    seq:AppendInterval(t)
end

function M:RefreshLion()
	if not SlotsLionModel.data.baseData then
		return
	end
	local idm = SlotsLionModel.data.baseData.mainData.itemDataMap
	if not idm or not next(idm) then
		return
	end
	local c = 0
	local _xMax = SlotsLionModel.size.xMax
	local _yMax = SlotsLionModel.size.yMax
    for x = 1, _xMax do
        if idm[x][_yMax] == "9" then
            c = c + 1
        end
    end
	dump({idm,c},"<color=green>变狮子头</color>")
	if c < 2 then
		return
	end

	for x = 1, _xMax do
		if idm[x][_yMax] == "9" then
			self:ShowLion(x,true,true)
		end
	end
end

function M:HideLionAll()
	for i = 1, 5 do
		self["lion" .. i .. "_award"].gameObject:SetActive(false)
	end
end

function M:ShowLion(i,b,NotPlayAudio)
	if b then
		if not NotPlayAudio then
			ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_lion_chufa.audio_name)	
		end
	end
	self["lion" .. i .. "_award"].gameObject:SetActive(b)
end