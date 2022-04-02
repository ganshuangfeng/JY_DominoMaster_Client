-- 创建时间:2021-12-15
-- Panel:SlotsMiniGame3Panel
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

SlotsMiniGame3Panel = basefunc.class()
local M = SlotsMiniGame3Panel
M.name = "SlotsMiniGame3Panel"

local itemCount = 12
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

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["OpenEggItem"] = basefunc.handler(self, self.OnOpenEggItem)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_beijing.audio_name)
	SlotsHelper.KillSeq(self.seq)
	self:ClearItem()
	self:RemoveListener()
	instance = nil
	M.Instance = nil
	destroy(self.gameObject)
	ClearTable(self)
end

function M:ctor()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()

	self:PlayStart()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:MyRefresh()
	self:RefreshItem()
end

function M:RefreshItem()
	self:ClearItem()
	for i = 1, itemCount do
		self:AddItem(i)
	end
end

function M:AddItem(i)
	self.itemGOMap = self.itemGOMap or {}
	self.itemGOMap[i] = SlotsEggItem.Create({index = i,parent = self["pos" .. i]})
end

function M:RemoveItem(i)
	self.itemGOMap[i]:Exit()
	self.itemGOMap[i] = nil
end

function M:ClearItem()
	if not self.itemGOMap or not next(self.itemGOMap) then
		return
	end
	for i, item in pairs(self.itemGOMap) do
		item:Exit()
	end
	self.itemGOMap = nil
end

function M:OnOpenEggItem(data)
	self.openList = self.openList or {}
	self.openList[#self.openList+1] = data.id

	if self:CheckLotteryEnd() then
		self:LotteryEnd()
	end
end

function M:CheckLotteryEnd()
	if not self.openList or not next(self.openList) then
		return false
	end

	local itemDataList = SlotsModel.data.baseData.mini3Data.itemDataList
	if #itemDataList < #self.openList then
		dump({itemDataList,self.openList},"<color=yellow>小游戏3开奖错误</color>")
		return false
	elseif #itemDataList > #self.openList then
		return false
	end

	for i = 1, #itemDataList do
		if itemDataList[i] ~= self.openList[i] then
			dump({itemDataList,self.openList},"<color=yellow>小游戏3开奖错误</color>")
			return false
		end
	end

	return true
end

function M:LotteryEnd()
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_sanlian.audio_name)
	print("<color=yellow>小游戏3开奖结束</color>")
	local seq = SlotsHelper.GetSeq()

	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3OpenAwardPoolFront)
	seq:AppendInterval(t)
	--中奖动画
	seq:AppendCallback(function ()
		self:PlayAwardPool()
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3OpenAwardPool)
	seq:AppendInterval(t)
end

function M:PlayAwardPool()
	--这里可能已经自动退出了
	if IsEquals(self.gameObject) then
		self.gameObject:SetActive(false)
	end
	--弹出结算
	SlotsHelper.LotterySettlement()
end

function M:GetOpenItemId()
	local index = self.openList == nil and 0 or #self.openList
	index = index + 1
	return SlotsModel.data.baseData.mini3Data.itemDataList[index]
end

function M:PlayLotteryEndAni()
	--结算
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3LotteryEndFront)
	seq:InsertCallback(t,function ()
		self:PlayLotteryEnd()
	end)
end

function M:PlayLotteryEnd()
	self:MyExit()
	Event.Brocast("CompleteMiniGame",{game = 3})
end

function M:MiniNext()
	if not instance then
		return
	end
	
	instance:PlayLotteryEndAni()
end

function M:PlayStart()
	local maxGold = SlotsModel.GetMaxGold()
	if maxGold < 2 then
		local seq = SlotsHelper.GetSeq()
		SlotsAwardPoolPanel.Instance:PlayAwardPool4Trigger()
		self:LotteryEnd()
		self.seq = seq
		return
	end

	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_chufa.audio_name)
	local seq = SlotsHelper.GetSeq()
	SlotsAwardPoolPanel.Instance:PlayAwardPool4Trigger()
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3ShowEffect)
	seq:InsertCallback(t,function ()
		ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_jp_beijing.audio_name)
		self.effect_start.gameObject:SetActive(true)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3RefreshItem)
	seq:InsertCallback(t,function ()
		self:RefreshItem()
		for i = 1, 12 do
			self["effect_" .. i .. "_img"].enabled = false
		end
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.miniGame3AutoOpen)
	if maxGold < 2 then
		t = SlotsModel.GetTime(SlotsModel.time.miniGame3AutoOpenMinGold)
	else
		t = SlotsModel.GetTime(SlotsModel.time.miniGame3AutoOpen)
	end
	seq:InsertCallback(t,function ()
		self:AutoOpen()
	end)
	self.seq = seq
end

function M:AutoOpen()
	local openAllNum = #SlotsModel.data.baseData.mini3Data.itemDataList
	local openNum = self.openList == nil and 0 or #self.openList
	local c = openAllNum - openNum
	if c == 0 then
		return
	end

	local hideEggItem ={}
	for k, eggItem in pairs(self.itemGOMap or {}) do
		if not eggItem.data.open then
			hideEggItem[#hideEggItem+1] = k
		end
	end

	local openIndexMap = {}
	local curNum = 0
	local randomOpenIndex
	randomOpenIndex = function ()
		local index = math.random(1,#hideEggItem)
		if openIndexMap[hideEggItem[index]] then
			randomOpenIndex()
		else
			openIndexMap[hideEggItem[index]] = hideEggItem[index]
			curNum = curNum + 1
			if curNum == c then
				return
			else
				randomOpenIndex()
			end
		end
	end
	randomOpenIndex()

	for k, v in pairs(openIndexMap) do
		self.itemGOMap[k]:OnClickBg()
	end

end