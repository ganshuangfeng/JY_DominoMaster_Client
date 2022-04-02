-- 创建时间:2021-11-15
-- Panel:LudoSafety
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

LudoSafety = basefunc.class()
local C = LudoSafety
C.name = "LudoSafety"
local is2D = true --是否使用2D方式
--[[
	data = {
		parent,
		data = {
			pos = {1,2}
		}
	}
]]
function C.Create(data)
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if is2D then
		if IsEquals(self.gameObject) then
			self.gameObject:SetActive(false)
		end
	else
		destroy(self.gameObject)
	end
	ClearTable(self)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	self.data = data.data
	if is2D then
			--2D预制体
		self.gameObject = GameObject.Find("LudoCanvasBG/root/@SafetyNode/@safety_" .. self.data.pos[1] .. "_" .. self.data.pos[2]).gameObject
		self.transform = self.gameObject.transform
	else
		--3D预制体
		self.gameObject = newObject(C.name, data.parent.transform)
		self.transform = self.gameObject.transform
		self.gameObject.name = self.data.pos[1] .. "_" .. self.data.pos[2]
	end

	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local pos = LudoLib.GetPiecePosByIndex(self.data.pos)
	self:SetPosition(pos)
	self:SetLightState(false)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetScale(scale)
	if is2D then return end
	self.transform.localScale = Vector3.one * scale
end

function C:SetRotation(rot)
	if is2D then return end
	self.transform.localRotation = Quaternion:SetEuler(0, 0, rot)
end

function C:SetPosition(pos)
	if is2D then return end
	self.transform.position = pos
end

function C:SetLightState(b)
	if self.lightState == b then
		return
	end
	self.lightState = b
	if is2D then
		self.gameObject:SetActive(b)
	else
		self.safety_light.gameObject:SetActive(b)
	end
end

function C:GetLightState()
	return self.lightState
end