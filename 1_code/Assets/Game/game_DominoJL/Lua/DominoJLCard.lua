-- 创建时间:2021-11-08
-- Panel:DominoJLCard
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

DominoJLCard = basefunc.class()
local C = DominoJLCard
C.name = "DominoJLCard"
--[[
	data = {
		parent :父节点
		cardData = {0,1} 牌数据
	}
]]

local State = {
	normal = "normal", --普通状态，可以拖动，出牌
	drag = "drag",	--拖动状态
	out = "out",	--出牌状态
	lock = "lock", --不能拖动
}

function C.Create(data)
	if not data or not data.cardData or not next(data.cardData) then
		return
	end
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_nor_dmn_nor_settlement_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_settlement_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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
	self.data = data
	self.data.id = DominoJLLib.GetIdByData(self.data.cardData)
	ExtPanel.ExtMsg(self)
	local parent = data.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.camera = GameObject.Find("Canvas/Camera").transform:GetComponent("Camera")
	self.transform = tran
	self.gameObject = obj
	self.transform.localPosition = Vector3.zero
	LuaHelper.GeneratingVar(self.transform, self)
	self.original_scale = self.transform.localScale
	self.bigger_scale = self.transform.localScale * 1.1

	--1:正面，0：反面
	self.curr_state = 1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	EventTriggerListener.Get(self.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
	EventTriggerListener.Get(self.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	
end

function C:RemoveListenerGameObject()
	EventTriggerListener.Get(self.transform.gameObject).onDown = nil
	EventTriggerListener.Get(self.transform.gameObject).onUp = nil
	EventTriggerListener.Get(self.transform.gameObject).onDrag = nil
end

function C:InitUI()
	self:InitPoint(self.data.cardData)
	self.CG = self.transform:GetComponent("CanvasGroup")
	self:MyRefresh()
end

function C:InitPoint(cardData)
	local img_config = {
		[1] = "ty_dot_gp_1",
		[2] = "ty_dot_gp_2",
		[3] = "ty_dot_gp_3",
		[4] = "ty_dot_gp_4",
		[5] = "ty_dot_gp_5",
		[6] = "ty_dot_gp_6",
	}
	self.up_img.sprite = GetTexture(img_config[cardData[1]])
	self.down_img.sprite = GetTexture(img_config[cardData[2]])
	self.up_img.gameObject:SetActive(cardData[1] > 0)
	self.down_img.gameObject:SetActive(cardData[2] > 0)
end

function C:MyRefresh()

	self:RefreshOnHand()
	self:RefreshOnDesk()
end

function C:RefreshOnHand()
	if not self.isOnHand then
		return
	end
	--是否轮到我出牌
	local isTurnToMe = DominoJLGamePanel.Instance.desk:CheckMePlayCard()

	--状态
	if not isTurnToMe then
		self:SetGray(false)
		self.transform.localScale = self.original_scale
	else
		local isCanOut = self:IsCanOut()
		if isCanOut then
			self:SetGray(false)
			self.transform.localScale = self.original_scale
		else
			self:SetGray(true)
			self.transform.localScale = self.original_scale
		end
	end
end

function C:RefreshOnDesk()
	if not self.isOnDesk then
		return
	end

	local b
	--游戏状态，权限
	if DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming then
		b = false
	end

	if DominoJLModel.data.status ~= DominoJLModel.Status.cp then
		b = false
	end

	self:SetGray(not b)
end

function C:SetAlpha(alpha) 
	if self.alpha == alpha then
		return
	end
	if not IsEquals(self.CG) then
		return
	end

	self.alpha = alpha
	self.CG.alpha = alpha
end

function C:SetScale(scale)
	if self.scale == scale then
		return
	end
	if not IsEquals(self.transform) then
		return
	end
	self.scale = scale
	self.transform.localScale = Vector3.one * scale
end

function C:SetRotation(rot)
	if self.rot == rot then
		return
	end
	if not IsEquals(self.transform) then
		return
	end

	local oRotZ = self.transform.localEulerAngles.z
	if oRotZ < 0 then
		oRotZ = oRotZ + 360
	end

	if math.abs(oRotZ - rot) < 10 then
		return
	end
	self.rot = rot
	self.transform.localRotation = Quaternion:SetEuler(0, 0, rot)
	self:SetUIState()
end

function C:SetIsOnDesk(b)
	if self.isOnDesk == b then
		return
	end
	self.isOnDesk = b
	self:SetUIState()
end

function C:SetIsOnHand(b)
	if self.isOnHand == b then
		return
	end
	self.isOnHand = b
end

function C:SetIsBack(b)
	if self.isBack == b then
		return
	end
	self.isBack = b
	self:SetUIState()
end

function C:SetIsMid(b)
	if self.isMid == b then
		return
	end
	self.isMid = b
	self:SetUIState()
end

function C:SetUIState()
	if self.isMid then
		self.bg_img.sprite = GetTexture("ty_gp_d_cm")
		self.mask_img.sprite = GetTexture("ty_gp_d_cm")
		self.up_img.gameObject:SetActive(false)
		self.down_img.gameObject:SetActive(false)
		self.bg_img.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
		self.mask_img.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
		return
	end

	local oRotZ = self.transform.localEulerAngles.z
	if oRotZ < 0 then
		oRotZ = oRotZ + 360
	end

	local rotZ = 0
	if math.abs(oRotZ - 0) < 10 then
		rotZ = 0
	elseif math.abs(oRotZ - 90) < 10 then
		rotZ = 90
	elseif math.abs(oRotZ - 180) < 10 then
		rotZ = 180
	elseif math.abs(oRotZ - 270) < 10 then
		rotZ = 270
	end
	local bgZ = rotZ == 270 and 180 or 0

	local str = self.isBack and "fm" or "zm"
	if rotZ == 0 then
		if self.isOnDesk then
			str = "ty_gp_x_" .. str .. "_2"
		else
			str = "ty_gp_d_" .. str .. ""
		end
	elseif rotZ == 90 then
		str = "ty_gp_x_" .. str .. "_1"
	elseif rotZ == 180 then
		if self.isOnDesk then
			str = "ty_gp_x_" .. str .. "_2"
		else
			str = "ty_gp_d_" .. str .. ""
		end
		bgZ = 180
	elseif rotZ == 270 then
		str = "ty_gp_x_" .. str .. "_1"
	end

	-- dump({oRotZ = oRotZ,rotZ = rotZ,isBack = self.isBack,isOnDesk = self.isOnDesk,bgZ = bgZ,str = str},"<color=yellow>牌的UI数据?????????????????????????</color>")

	self.up_img.gameObject:SetActive((not self.isBack) and self.data.cardData[1] > 0)
	self.down_img.gameObject:SetActive((not self.isBack) and self.data.cardData[2] > 0)
	self.bg_img.transform.localRotation = Quaternion:SetEuler(0, 0, bgZ)
	self.bg_img.sprite = GetTexture(str)
	self.mask_img.transform.localRotation = Quaternion:SetEuler(0, 0, bgZ)
	self.mask_img.sprite = GetTexture(str)
end

function C:SetPosition(pos)
	if self.pos and self.pos.x == pos.x and self.pos.y == pos.y and self.pos.z == pos.z then
		return
	end
	if not IsEquals(self.transform) then
		return
	end
	self.pos = pos
	self.transform.localPosition = pos
end

function C:CheckDrag()
	if self.isOnDesk then
		return
	end

	--游戏状态，权限
	if DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming then
		return
	end

	if DominoJLModel.data.status ~= DominoJLModel.Status.cp then
		return
	end

	return self.isOnHand
end

function C:OnBeginDrag()
	print("开始拖拽")

	if not self:CheckDrag() then
		return
	end

	if self.seqMove then
		self.seqMove:Kill()
	end

	self.transform.localScale = self.bigger_scale
	--按下的位置和中心点的偏移
	self.offset_pos = self.camera:ScreenToWorldPoint(UnityEngine.Input.mousePosition) - self.transform.position
	self.gameObject.transform.parent.transform:SetAsLastSibling()
	--到我出牌才抛消息
	Event.Brocast("me_choose_card",self)
end

function C:OnEndDrag()
	print("结束拖拽")

	if not self:CheckDrag() then
		return
	end

	if self:IsCardOutHand() then
		local d = {}
		d.id = DominoJLLib.GetIdByData(self.data.cardData)
		d.lr = DominoJLModel.C2SQueuePos(DominoJLGamePanel.Instance:GetChooseQueuePos())
		DominoJLCardGroup.Instance:PlayCard(self)
		--预防网络很差的情况
		Network.SendRequest("nor_dmn_nor_cp",d)
	else
		self.transform.localScale = self.original_scale
		self:JoinGroup()
		Event.Brocast("me_cancel_card")
	end
	Event.Brocast("clear_choose_card",self)
end

function C:OnDrag()
	if not self:CheckDrag() then
		return
	end

	self.offset_pos = self.offset_pos or self.camera:ScreenToWorldPoint(UnityEngine.Input.mousePosition) - self.transform.position
	if not IsEquals(self.transform) then
		return
	end
	self.transform.position = self.camera:ScreenToWorldPoint(UnityEngine.Input.mousePosition) - self.offset_pos
end

--记录这张牌处在手牌中的哪个位置
function C:SetPosIndex(index)
	if not index then
		return
	end

	if not self.pos_index then
		self.pos_index = index
		self.transform:SetParent(DominoJLCardGroup.Instance:GetCardParentByIndex(self.pos_index))
		self.transform.localPosition = Vector3.zero
		return
	end

	self.pos_index = index

	self.transform:SetParent(DominoJLCardGroup.Instance:GetCardParentByIndex(self.pos_index))

	if self.seqMove then
		self.seqMove:Kill()
	end
	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOLocalMove(Vector3.zero,0.2))
	self.seqMove = seq
end

--判断被拖动的牌所处的区域,根据游戏规则决定这张牌的动画
--如果这张牌离开原始位置一定距离，认为这张牌正在抽离手牌，此时卡组会有移动排列的动画
function C:CheckIsLeaving()
	local isOutHand = not self:IsCardInHand()
	return isOutHand
end

function C:JoinGroup()
	local oldIndex = self.pos_index
	local newIndex = DominoJLCardGroup.Instance:GetIndexByX(self)
	DominoJLCardGroup.Instance:OnCardChange(oldIndex,newIndex)
	self:SetPosIndex(newIndex)
end

--当拖动的牌处于手牌区域（插入或者还原）
function C:IsCardInHand()
	if self.transform.localPosition.y >= 50 then
		return false
	else
		return true
	end
end

function C:IsCanOut()
	--游戏状态，权限
	local isMe = DominoJLGamePanel.Instance.desk:CheckMePlayCard()
	local isOut = DominoJLGamePanel.Instance.desk:CheckCanPlayCardData(self.data.cardData)
	local isLock = DominoJLCardGroup.Instance.isLockCardOut
	return isMe and isOut and not isLock
end

--当拖动的牌处于出牌区域（松开就出牌）
function C:IsCardOutHand()
	local isOutHand = not self:IsCardInHand()
	local isCanOut = self:IsCanOut()
	dump({isOutHand,isCanOut},"<color=yellow>是否可以出牌？？？</color>")
	return isOutHand and isCanOut
end

--设置灰色
function C:SetGray(isTrue)
	if not IsEquals(self.transform) then
		return
	end

	self.mask_img.gameObject:SetActive(isTrue)
end

function C:SetShakeState(b)
	if not IsEquals(self.gameObject) then
		return
	end
	if self.shakeState == b then
		return
	end

	if b and self.onDarging then
		return
	end

	if b then
		local seq = DoTweenSequence.Create()
		seq:Append(self.root.transform:DOShakePosition(3, Vector3.New(5,5,0),20))
		seq:OnForceKill(function ()
			if self and IsEquals(self.transform) then
				self.root.transform.localPosition = Vector3.zero
				self.shakeState = false
				self.seqShake = nil
			end
		end)
		seq:OnKill(function ()
			if self and IsEquals(self.transform) then
				self.transform.localPosition = Vector3.zero
				self.shakeState = false
				self.seqShake = nil
			end
		end)
		self.seqShake = seq
		self.shakeState = true
	else
		if self.seqShake then
			self.seqShake:Kill()
		end
		self.shakeState = false
		self.seqShake = nil
		self.root.transform.localPosition = Vector3.zero
	end
end

function C:on_nor_dmn_nor_settlement_msg()
	self.gameObject:SetActive(false)
end