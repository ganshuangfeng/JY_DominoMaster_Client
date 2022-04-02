-- 创建时间:2021-11-15
-- Panel:LudoPiece
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

LudoPiece = basefunc.class()
local C = LudoPiece
C.name = "LudoPiece"

--[[
	data = {
		parent,
		data = {
			CSeatNum
			id
			place
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
	self.Timer:Stop()
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

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	self.data = data.data
	local parent = data.parent.transform
	local config = {
		blue = "piece_blue",red = "piece_red",green = "piece_green",yellow ="piece_yellow"
	}
	local color = LudoLib.GetColor(self.data.CSeatNum)
	self.gameObject = newObject(config[color], parent)
	self.transform = self.gameObject.transform
	self.gameObject.name = self.data.CSeatNum .. "_" .. self.data.id
	self.animator = self.transform:GetComponent("Animator")
	LuaHelper.GeneratingVar(self.transform, self)
	self.Camera = GameObject.Find("Ludo3DNode/Camera3D"):GetComponent("Camera")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.Timer = Timer.New(
		function()
			self:Update()
		end,0.016,-1
	)
	self.Timer:Start()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	EventTriggerListener.Get(self.transform.gameObject).onClick = basefunc.handler(self,self.OnClickPiece)

end

function C:RemoveListenerGameObject()
	EventTriggerListener.Get(self.transform.gameObject).onClick = nil
end

function C:InitUI()
	self:MyRefresh()
	self:SetPlace(self.data.CSeatNum,self.data.place)
	self:SetChooseState(false)
	self.chessMat = self.model.transform:Find("chess"):GetComponent("MeshRenderer").materials[0]
end

function C:MyRefresh()
end

function C:SetScale(scale)
	self.transform.localScale = Vector3.one * scale
end

function C:SetRotation(rot)
	self.transform.localRotation = Quaternion:SetEuler(0, 0, rot)
	--背景图片替换
end

function C:SetPosition(pos)
	self.transform.position = pos
end

function C:GetDefaultRenderQueue()
	return 2000
end

function C:SetRenderQueue(rq)
	if not IsEquals(self.chessMat) then
		return
	end
	rq = rq or self:GetDefaultRenderQueue()
	if self.chessMat.renderQueue == rq then
		return
	end
	self.chessMat.renderQueue = rq
end

function C:SetPlace(CSeatNum,place)
	local pos = LudoLib.GetPiecePos(CSeatNum,place)
	self:SetPosition(pos)
	self.data.place = place
end

function C:OnClickPiece()
	Network.SendRequest("nor_fxq_nor_piece",{id = self.data.id})
end

function C:Update()
	-- if LudoModel.data.s2cSeatNum and LudoModel.data.cur_p then
	-- 	self.left_time = self.left_time or 0
	-- 	self.left_time = self.left_time - 0.016
	-- 	local CSeatNum = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	-- 	if CSeatNum == self.data.CSeatNum or true then
	-- 		if LudoModel.data.status == LudoModel.Status.piece or true then
	-- 			if UnityEngine.Input.GetMouseButton(0) then
	-- 				local pos = UnityEngine.Input.mousePosition
	-- 				local c_p = self.Camera:WorldToScreenPoint(self.transform.position)
	-- 				local v = Vector3.New(c_p.x,c_p.y,0)
	-- 				local dis = Vector3.Distance(pos, v)
	-- 				if dis < 20 then
	-- 					if self.left_time < 0 then
	-- 						self:OnClickPiece()
	-- 						self.left_time = 1
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	if not LudoModel
	or not LudoModel.data
	or not LudoModel.data.cur_p
	or not LudoModel.data.seat_num
	or not LudoModel.data.seatNum
	or LudoModel.data.seatNum[self.data.CSeatNum] ~= LudoModel.data.seat_num
	or LudoModel.data.cur_p ~= LudoModel.data.seat_num
	or LudoModel.data.status ~= LudoModel.Status.piece
	or LudoModel.data.statusMini ~= LudoModel.StatusMini.waitPiece then
		return
	end
	self.left_time = self.left_time or 0
	self.left_time = self.left_time - 0.016
	if UnityEngine.Input.GetMouseButton(0) then
		local ray = self.Camera:ScreenPointToRay(UnityEngine.Input.mousePosition)
		local hit = nil
		local isCol, hitInfo = UnityEngine.Physics.Raycast(ray,hit)
		if isCol then
			if hitInfo.transform.gameObject.name == self.gameObject.name then
				self:OnClickPiece()
				self.left_time = 1
			end
		end
	end
end

function C:SetChooseState(b)
	self.animator.speed = 1
	if b then
		self.animator:Play("qiziQtanAnimation",0,0)
	else
		self.animator:Play("piece_stop",0,0)
	end

	if self.chooseState == b then
		return
	end
	self.chooseState = b
	self.choose_node.gameObject:SetActive(self.chooseState)
end

function C:PlayLongAnim(use_time)
	self.animator.speed = 1 / use_time
	self.animator:Play("shangtiao01 Animation",0,0)
end

function C:PlayShortAnim(use_time)
	self.animator.speed = 1 / use_time
	self.animator:Play("xiatiao02Animation",0,0)
end

function C:RefreshChooseState()
	if self.data.place == 58 then
		self:SetChooseState(false)
		return
	end

	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
end

function C:GetNumPos()
	return self.num_node.transform.position
end