-- 创建时间:2021-11-15
-- Panel:LudoPieceNum
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

LudoPieceNum = basefunc.class()
local C = LudoPieceNum
C.name = "LudoPieceNum"

--[[
	data = {
		parent,
		data = {
			num,
			pos,
			scale,
			CSeatNum,
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
	destroy(self.gameObject)
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
	self.gameObject = newObject(C.name, data.parent.transform)
	self.transform = self.gameObject.transform
	self.gameObject.name = "pieceNum_" .. self.data.CSeatNum


	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:SetPosition(self.data.pos)
	self:SetScale(self.data.scale)
	self:SetNum(self.data.num)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetScale(scale)
	if not IsEquals(self.transform) then
		return
	end
	self.transform.localScale = Vector3.one * scale
end

function C:SetRotation(rot)
	if not IsEquals(self.transform) then
		return
	end
	self.transform.localRotation = Quaternion:SetEuler(0, 0, rot)
end

function C:SetPosition(pos)
	if not pos then
		 return
	end
	if not IsEquals(self.transform) then
		return
	end
	self.transform.position = pos
end

function C:SetNum(num)
	self.data.num = num
	self.num_txt.text = num
	self.num_txt.gameObject:SetActive(num > 1)
end