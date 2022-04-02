-- 创建时间:2021-11-16
-- Panel:LudoDice
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

LudoDice = basefunc.class()
local C = LudoDice
C.name = "LudoDice"

function C.Create(parent,start_player_index,target_point,backcall)
	return C.New(parent,start_player_index,target_point,backcall)
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
	if self.MainTimer then
		self.MainTimer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,start_player_index,target_point,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Ludo3DNode").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject:SetActive(false)
	self.start_player_index = start_player_index
	self.target_point = target_point

	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	if self.target_point > 6 then
		self.backcall()
	else
		self:InitUI()
	end	
end

local PointToRotation = {
	[1] = {Vector3.New(45,90,270),Vector3.New(135,90,270),Vector3.New(225,90,270),Vector3.New(315,90,270)},
	[2] = {Vector3.New(45,90,0),Vector3.New(135,90,0),Vector3.New(225,90,0),Vector3.New(315,90,0)},
	[3] = {Vector3.New(180,180,45),Vector3.New(180,180,135),Vector3.New(180,180,225),Vector3.New(180,180,315)},
	[4] = {Vector3.New(180,0,45),Vector3.New(180,0,135),Vector3.New(180,0,225),Vector3.New(180,0,315)},
	[5] = {Vector3.New(45,90,180),Vector3.New(135,90,180),Vector3.New(225,90,180),Vector3.New(315,90,180)},
	[6] = {Vector3.New(45,90,90),Vector3.New(135,90,90),Vector3.New(225,90,90),Vector3.New(315,90,90)},
}

local getRandomVec = function (num)
	return Vector3.New(math.random(1,num),math.random(1,num),math.random(1,num))
end

function C:InitUI()
	self:DoAnim()
end

function C:MyRefresh()

end

function C:DoAnim()
	local d = PointToRotation[self.target_point]
	local targetRot = d[math.random(1,#d)]
	local targetPos = LudoLib.GetDicePosEnd()
	local startPos = LudoLib.GetDicePos(self.start_player_index)
	local startRot = getRandomVec(360)

	startPos.z = -100
	self.transform.localPosition = startPos
	self.transform.localEulerAngles = startRot
	self.gameObject:SetActive(true)
	local seq = DoTweenSequence.Create()
	seq:Insert(0,self.transform:DOLocalMoveX(targetPos.x,0.6))
	seq:Insert(0,self.transform:DOLocalMoveY(targetPos.y,0.6))

	seq:Insert(0,self.transform:DORotate(getRandomVec(360),0.15))
	seq:Insert(0.15,self.transform:DORotate(getRandomVec(360),0.2))
	seq:Insert(0.15 + 0.2,self.transform:DORotate(targetRot,0.25))


	seq:Insert(0,self.transform:DOLocalMoveZ(0,0.2))
	seq:Insert(0.2,self.transform:DOLocalMoveZ(startPos.z/4,0.15))
	seq:Insert(0.2 + 0.15,self.transform:DOLocalMoveZ(0,0.1))
	seq:Insert(0.2 + 0.15 + 0.1,self.transform:DOLocalMoveZ(startPos.z/16,0.08))
	seq:Insert(0.2 + 0.15 + 0.1 + 0.08,self.transform:DOLocalMoveZ(0,0.07))
	seq:InsertCallback(0.6,function ()
		self.transform.localPosition = targetPos
		self.transform.localEulerAngles = targetRot
	end)
	seq:InsertCallback(0.2,function ()
		ExtendSoundManager.PlaySound(audio_config.ludo.ludo_throw_dice.audio_name)
	end)
	seq:OnForceKill(function ()
		if IsEquals(self.transform) then
			self.transform.localPosition = targetPos
			self.transform.localEulerAngles = targetRot
		end
	end)
end