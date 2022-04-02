-- 创建时间:2022-03-18
-- Panel:SlotsHallItemPrefab
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

SlotsHallItemPrefab = basefunc.class()
local C = SlotsHallItemPrefab
C.name = "SlotsHallItemPrefab"

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
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
	if self.update_t then
		self.update_t:Stop()
	end
	self.update_t = nil

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

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index

	ExtPanel.ExtMsg(self)
	local obj = newObject(self.config.prefab_name, parent_transform)
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
	self.dj_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.config.line)
	end)
end

function C:RemoveListenerGameObject()
	self.dj_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	if self.config.scene_name then
		self.step = 2
		self.update_t = Timer.New(function ()
			self:Update()
		end, 0.2, -1, true, true)
		self:Update()
		self.update_t:Start()
		
		if self.config.scene_name == "game_Slots" then
			self.min_num = 17600000000
			self.max_num = 18000000000
		elseif self.config.scene_name == "game_SlotsLion" then
			self.min_num = 18000000000
			self.max_num = 18000000000
		end
		self.cur_num = self.min_num
		self.step_num = math.floor( (self.max_num - self.min_num) / (5*60 / 0.2) )
		self.show_txt.text = StringHelper.AddPoint(self.cur_num)
	end

	self:MyRefresh()
end

function C:MyRefresh()

end

function C:Update()
	self:AwardShow()
	self:FalseOnline()
end
function C:AwardShow()
	if self.cur_num ~= self.max_num then
		self.cur_num = self.cur_num + self.step_num
		if self.cur_num > self.max_num then
			self.cur_num = self.max_num
		end
		self.show_txt.text = StringHelper.AddPoint(self.cur_num)
	end
end


local false_min = 50
local false_max = 100
function C:FalseOnline()
	if self.step < 2 then
		self.step = self.step + 0.2
		return
	end
	self.step = 0

	if not self.false_num then
		self.false_num = math.random(1000, 3000)
	end
	if not self.false_a then
		self.false_a = 5
	end
	
	if math.random(10) < self.false_a then
		self.false_a = self.false_a - 1
		self.false_num = self.false_num + math.random(false_min, false_max)
	else
		self.false_a = self.false_a + 1
		self.false_num = self.false_num - math.random(false_min, false_max)
	end

	if self.false_num < 1000 then
		self.false_num = 1000 + math.random(false_min, false_max)
	end
	if self.false_a < 1 then
		self.false_a = 1
	end
	if self.false_a > 10 then
		self.false_a = 10
	end

	self.online_txt.text = StringHelper.AddPoint(self.false_num)
end
