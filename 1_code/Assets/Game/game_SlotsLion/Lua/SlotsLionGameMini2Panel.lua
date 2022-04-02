-- 创建时间:2021-12-15
-- Panel:SlotsLionGameMini2Panel
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

SlotsLionGameMini2Panel = basefunc.class()
local M = SlotsLionGameMini2Panel
M.name = "SlotsLionGameMini2Panel"

M.size = {
    xMax = 1,
    yMax = 4,
    xSize = 125,
    ySize = 125,
    xSpac = 0,
    ySpac = 5,
	yOffset = -55
}

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

function M.Start()
	--小游戏2 Start
	dump("<color=green>小游戏2 Start</color>")
	SlotsLionHelper.LotterySettlement({game = "mini2"})
end

function M.Show(b)
	instance.gameObject:SetActive(b)
end

function M.Next()
	--小游戏2 Next
	if not instance then
		return
	end
	
	local pro = SlotsLionModel.GetGameProcess()
	local gameData = SlotsLionModel.GetGameProcessCurDataParallel("mini2",pro.game,pro.step + 1)
	if not gameData then
		instance:PlayLotteryEnd()
		return
	end

	M.Start()
end

function M:PlayLotteryEnd()
	Event.Brocast("CompleteMiniGameParallel",{game = "mini2"})
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
		M.scrollAni:ClearItemObjMap()
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
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
	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtPanel.ExtMsg(self)
	local parent = SlotsLionGamePanel.Instance.GameMini2
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:MyRefresh()
	local itemDataMap = SlotsLionModel.GetGameMini2ItemDataMap()
	self:RefreshItem(itemDataMap)
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
				if self.itemGOMap[x][y].data and self.itemGOMap[x][y].data.id ~= id then
					--有元素，但是id不同
					self.itemGOMap[x][y]:SetId(id)
				end
			else
				self:AddItem(id,x,y)
			end
		end
	end
	self:SetItemPosOffset(itemDataMap)
end

function M:SetItemPosOffset(itemDataMap)
	if tonumber(itemDataMap[1][2]) ~= 0 then
		return
	end
	local p
	for x, v in ipairs(self.itemGOMap) do
		for y, item in ipairs(v) do
			p = SlotsLionLib.GetPositionByPos(x,y,
			SlotsLionGameMini2Panel.size.xSize,
			SlotsLionGameMini2Panel.size.ySize,
			SlotsLionGameMini2Panel.size.xSpac,
			SlotsLionGameMini2Panel.size.ySpac)
			item:SetLocalPosition({x = p.x,y = p.y + SlotsLionGameMini2Panel.size.yOffset,z = p.z})
		end
	end
end

function M:GetItem(x,y)
	if not self.itemGOMap or not next(self.itemGOMap) then
		return
	end
	return self.itemGOMap[x][y]
end

function M:AddItem(id,x,y)
	if self.itemGOMap and self.itemGOMap[x] and self.itemGOMap[x][y] and self.itemGOMap[x][y].data.id == id then
		--同一个位置相同的元素
		return
	end
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[x] = self.itemGOMap[x] or {}
	self.itemGOMap[x][y] = SlotsLionGameMini2Item.Create({id = id,x = x,y = y,parent = self.item_content})
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

local times = {
	scrollSpeedUpInterval = SlotsLionModel.time.scrollSpeedUpInterval,
	scrollSpeedUpTime = SlotsLionModel.time.scrollSpeedUpTime,
	scrollSpeedUniformAllTime = SlotsLionModel.time.scrollSpeedUniformAllTime,
	scrollSpeedUniformOneTime = SlotsLionModel.time.scrollSpeedUniformOneTime,
	scrollSpeedDownInterval = SlotsLionModel.time.scrollSpeedDownInterval,
	scrollSpeedDownTime = SlotsLionModel.time.scrollSpeedDownTime,
	scrollSpeedUniformAddTime = SlotsLionModel.time.scrollSpeedUniformAddTime,
}

--转动
function M:StartScroll()
	SlotsLionEffect.StopLionEffect()
	if M.scrollAni then
        M.scrollAni:MyExit()
        M.scrollAni = nil
    end
    M.scrollAni = ScrollAnimation.Create()
	SlotsLionAnimation.StartScrollMini2(self.itemGOMap,"mini2",times,self.item_content,M.scrollAni)
end

--停止转动
function M:StopScroll(itemDataMap,id,callback,endCallback)
	SlotsLionAnimation.StopScrollMini2(itemDataMap,id,"mini2",callback,times,endCallback,M.scrollAni)
end

--跳过转动
function M:SkipScroll(itemDataMap,id,callback)
	SlotsLionAnimation.SkipScrollMini2(itemDataMap,id,"mini2",callback,M.scrollAni)
end