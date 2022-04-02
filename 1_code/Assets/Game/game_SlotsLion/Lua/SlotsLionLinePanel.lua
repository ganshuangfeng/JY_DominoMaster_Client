-- 创建时间:2022-03-11
-- Panel:SlotsLionLinePanel
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

SlotsLionLinePanel = basefunc.class()
local C = SlotsLionLinePanel
C.name = "SlotsLionLinePanel"
local instance
function C.Create(parent)
	if instance then
		return instance
	else
		instance = C.New()
	end
	C.Instance = instance
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.showTimer then
		self.showTimer:Stop()
	end
	self.showTimer = nil
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitLines()
	self:InitUI()
	self:InitLL()
	self:HideAllMask()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:ShowLines(line_list)
	self:HideAllLine()
	if type(line_list) == "number" then
		self:ShowLine(line_list)
	else
		for k , v in pairs(line_list) do
			self:ShowLine(v)
		end
	end
end

function C:ShowLine(line_index)
	self.lines[line_index].gameObject:SetActive(true)	
end

function C:HideLine(line_index)
	self.lines[line_index].gameObject:SetActive(false)	
end

function C:HideMoney(line_index)
	self["money"..line_index].gameObject:SetActive(false)	
end

function C:ShowMoney(line_index,money,moneyTime)
	local money = math.floor( money / 9)
	self["money"..line_index].gameObject:SetActive(true)
	self["money"..line_index.."_txt"].text =  StringHelper.ToCash( money)
	Event.Brocast("ItemWinConnect",{money = money,moneyTime = moneyTime})
end

function C:HideAllLine()
	for i = 1,9 do
		self:HideLine(i)
		self:HideMoney(i)
	end
end

function C:InitLines()
	self.lines = {}
	for i = 1,9 do
		self.lines[#self.lines+1] = self["line_"..i].transform:Find("@line").transform
	end
end
--隐藏所有的遮盖
function C:HideAllMask()
	for i = 1,5 do
		for ii = 1,3 do
			self["mask_"..i.."_"..ii].gameObject:SetActive(false)
		end
	end
end

function C:ShowAllMask()
	for i = 1,5 do
		for ii = 1,3 do
			self["mask_"..i.."_"..ii].gameObject:SetActive(true)
		end
	end
end
--隐藏
function C:MaskUnShow(data)
	local line = SlotsLionLib.GetItemLine()
	local line_item = line[data.index]

	local check = function (_pos)
		for k ,v in pairs(data.pos) do
			if v[1] == _pos[1] and v[2] == _pos[2] then
				return true
			end			
		end
		return false
	end
	self:ShowAllMask()
	for k , v in pairs(line_item) do
		if check(v) then
			self["mask_"..v[1].."_"..v[2]].gameObject:SetActive(false)
		end
	end
end

function C:PlayLine(line_data,backcall,isloop)
	local called = false
	if self.showTimer then
		self.showTimer:Stop()
	end
	self.showTimer = nil
	local data = {}
	for k , v in pairs(line_data) do
		data[#data+1] = v
	end
	if #data == 0 then
		if backcall then
			backcall()
		end
		return
	end
	table.sort(data,function (a,b)
		return a.rate < b.rate
	end)
	local loop = #data
	local moneyTime = SlotsLionModel.time.showLineSpace * loop
	if  isloop then
		loop = -1
	end

	local play_func = function (data)
		local index = data.index
		local win_money = data.rate * SlotsLionModel.GetBet().bet_money
		self:ShowLines(index)
		self:HideAllMask()
		self:ShowMoney(index,win_money,moneyTime)
		self:MaskUnShow(data)
	end

	local data_index = 1
	self.showTimer = Timer.New(function ()
		local d = data[data_index]
		play_func(d)
		data_index = data_index + 1
		if data_index > #data then
			local curIndex = data_index
			data_index = 1
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(1)
			seq:AppendCallback(
				function ()
				ExtendSoundManager.PlaySound(audio_config.lion["bgm_lion_lianxian"].audio_name)
				local pro = SlotsLionModel.GetGameProcess()
				local gameData = SlotsLionModel.GetGameProcessCurData()
				--展示元素特效
				local itemDataMap
				local itemGOMap				
				if pro.game == "main" then
					itemDataMap = gameData.itemDataMap
					itemGOMap = SlotsLionGameMainPanel.Instance.itemGOMap
				elseif pro.game == "mini1" then
					itemDataMap = gameData.itemDataMapList[pro.step]
					itemGOMap = SlotsLionGameMini1Panel.Instance.itemGOMap
				end
				self:HideAllLine()
				self.doEffectItems = {}
					for k ,v in pairs(line_data) do
						for kk , vv in pairs(v.pos) do
							local pos = vv
							local item_id = itemDataMap[pos[1]][pos[2]]
							local item_index = SlotsLionLib.GetItemIndexById(item_id)
							local item = itemGOMap[pos[1]][pos[2]]
							self.doEffectItems[#self.doEffectItems + 1] = item
							self["mask_"..pos[1].."_"..pos[2]].gameObject:SetActive(false)
							item:PlayEffect(item_id,pos)
						end
					end
				end
			)
			
			seq:AppendInterval(2)
			seq:AppendCallback(
				function ()
					self:HideAllLine()
					self:HideAllMask()
					for k,v in pairs(self.doEffectItems) do
						v:StopEffect()
					end
					if curIndex >= #data and backcall and called == false then
						backcall()
						called = true
					end		
				end
			)		
		end
		if data_index <= 9 then
			ExtendSoundManager.PlaySound(audio_config.lion["bgm_lion_lianxian"..data_index].audio_name)
		end
	end,SlotsLionModel.time.showLineSpace,loop)
	self.showTimer:Start()
end

--重置所有
function C:ReSetAll()
	if self.showTimer then
		self.showTimer:Stop()
	end
	self.showTimer = nil
	self:HideAllLine()
	self:HideAllMask()
end