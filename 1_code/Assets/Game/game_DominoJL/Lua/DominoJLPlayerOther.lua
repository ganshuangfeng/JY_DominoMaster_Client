-- 创建时间:2021-11-08
-- Panel:DominoJLPlayerOther
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

DominoJLPlayerOther = basefunc.class(DominoJLPlayerBase)
local C = DominoJLPlayerOther
C.name = "DominoJLPlayerOther"

function C:ctor(panelSelf, obj, data)
	DominoJLPlayerOther.super.ctor(self, panelSelf, obj, data)
end

function C:AddListenerGameObject()
    EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
		local user = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "panel", ext = {pos=self.transform.position + Vector3.New(150,50,0)}, data = user})
		end
	end)
end

function C:GetCardPosition()
	local list = {}
	for i = 1, 7 do
		list[#list + 1] = self.card_node.position
	end
	return list
end

function C:PlayCardShake()
	
end

function C:PlayLvUpAnim()
	
end

function C:ClearYbqPoint()
	if not self.ybqPointList or not next(self.ybqPointList) then
		return
	end
	for i, v in pairs(self.ybqPointList) do
		v:MyExit()
	end
	self.ybqPointList = nil
end

function C:CreateYbqPoint(data)
	if not data or not next(data) then
		return
	end
	table.sort(data,function (a,b)
		return a > b
	end)

	self.ybqPointList = self.ybqPointList or {}
	for i, v in ipairs(data) do
		if not self.ybqPointList[v] then
			self.ybqPointList[v] = DominoJLYbqPoint.Create({parent = self.ybq_node,point = v})
		end
	end
end

function C:RefreshYbqPoint()
	if not DominoJLModel.data
	or not DominoJLModel.data.ybq_data
	or not next(DominoJLModel.data.ybq_data)
	then
		self:ClearYbqPoint()
		return
	end

	local SSeatNum = DominoJLModel.data.seatNum[self.data.uiIndex]
	if not DominoJLModel.data.ybq_data[SSeatNum] or not next(DominoJLModel.data.ybq_data[SSeatNum]) then
		self:ClearYbqPoint()
	else
		-- self:ClearYbqPoint()
		self:CreateYbqPoint(DominoJLModel.data.ybq_data[SSeatNum])
	end
end

function C:PlayYbqPoint(data)
	if DominoJLModel.data.s2cSeatNum[data.seat_num] ~= self.data.uiIndex then
		return
	end

	self:CreateYbqPoint(data.ds)
end

