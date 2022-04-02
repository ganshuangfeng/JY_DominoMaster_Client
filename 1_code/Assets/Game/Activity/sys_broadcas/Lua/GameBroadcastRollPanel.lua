-- 创建时间:2018-11-27

GameBroadcastRollPanel = {}

local basefunc = require "Game.Common.basefunc"

GameBroadcastRollPanel = basefunc.class()

GameBroadcastRollPanel.name = "GameBroadcastRollPanel"

local C = GameBroadcastRollPanel
local instance
local Opacity = 0.01

local RollState =
{
	RS_Null = "RS_Null",-- 空闲
	RS_Begin = "RS_Begin",-- 运行开始
	RS_Ing = "RS_Ing",-- 运行中
	RS_MoveFinish = "RS_MoveFinish",-- 移动完成
	RS_Exiting = "RS_Exiting",-- 结束中
}

-- isfront 重要广播，插入到队列最前面
-- 万一都是重要广播，怎么办 nmg todo
function C.PlayRoll()
	if not instance then
		C.Create()
	end
	instance:PlayEnterAnim()
end
function C.PlayFinish()
	if instance then
		instance.rollState = RollState.RS_MoveFinish
		instance:PlayEnterAnim()
	end
end

function C.PlayEnd(key)
	if instance then
		instance:RemoveRollCellList(key)
	end
end

function C.Create()
	instance = C.New()
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seqMove then
		self.seqMove:Kill()
	end
	self.seqMove = nil
	self:RemoveListener()
	self:CloseRollCellList()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	-- self.show_y = -36
	-- self.hide_y = 36
	-- self.max_len = math.abs(self.hide_y - self.show_y)
	-- self.max_t = 0.5

	self.rollState = RollState.RS_Null
	self.RollCellList = {}
	self.broadcast_count = 0

	-- self.Node = tran:Find("Root/UINode/Node").transform
	-- self.UINode = tran:Find("Root/UINode").transform

	self.Node = tran:Find("Node").transform
	-- self.NodeCanvasGroup = tran:Find("Root/UINode"):GetComponent("CanvasGroup")
	self.NodeCanvasGroup = tran:Find("bg"):GetComponent("CanvasGroup")
	self.NodeCanvasGroup.alpha = Opacity
	self:InitUI()
end

function C:InitUI()
	self:SetShowOrHide(false)
end

function C:on_backgroundReturn_msg()
	self:PlayEnterAnim()
end

function C:on_background_msg()
	if self.seqMove then
		self.seqMove:Kill()
	end
	self.seqMove = nil
	self.rollState = RollState.RS_Null
	self:SetShowOrHide(false)
	self:CloseRollCellList()
end

function C:OnExitScene()
	self:MyExit()
	instance = nil
end

function C:RemoveRollCellList(key)
	if self.RollCellList and self.RollCellList[key] then
		self.RollCellList[key]:Destroy()
		self.RollCellList[key] = nil
		self.broadcast_count = self.broadcast_count - 1
	end
	if self.broadcast_count <= 0 then
		self:PlayExitAnim()
	end
end
function C:CloseRollCellList()
	if self.RollCellList then
		for k,v in pairs(self.RollCellList) do
			v:Destroy()
		end
	end
	self.RollCellList = {}
	self.broadcast_count = 0
end

function C:RunBroadcast()
	if IsEquals(self.NodeCanvasGroup) then
		local data = SysBroadcastManager.GetRollFront()
		if data then
			self:PlayBroadcast(data)
		end		
	end
end

function C:PlayBroadcast(data)
	self:SetShowOrHide(true)
	self.rollState = RollState.RS_Ing
    local obj
	if data.isContainHead then
		obj = GameBroadcastRollPrefabH.Create(data, self.Node)
	else
		obj = GameBroadcastRollPrefab.Create(data, self.Node)
	end
    self.RollCellList[data.key] = obj
    self.broadcast_count = self.broadcast_count + 1
end

function C:SetShowOrHide(b)
	if b then
		-- self.UINode.transform.localPosition = Vector3.New(0, self.show_y, 0)
		if IsEquals(self.NodeCanvasGroup) then
			self.NodeCanvasGroup.alpha = 1
		end
	else
		-- self.UINode.transform.localPosition = Vector3.New(0, self.hide_y, 0)
		if IsEquals(self.NodeCanvasGroup) then
			self.NodeCanvasGroup.alpha = Opacity
		end
	end
end


function C:PlayEnterAnim()
	if self.rollState == RollState.RS_Begin or self.rollState == RollState.RS_Ing then
		return
	end
	if SysBroadcastManager.RollCount() == 1 then
		return
	end
	self.rollState = RollState.RS_Begin
	self.seqMove = nil
	self.seqMove = DoTweenSequence.Create({dotweenLayerKey=SysBroadcastManager.dotween_key})
	self.seqMove:Append(self.NodeCanvasGroup:DOFade(1, 0.2))
	-- self.seqMove:Join(self.UINode:DOLocalMoveY(self.show_y, t))
	self.seqMove:OnKill(function ()
		self:RunBroadcast()
	end)
end


function C:PlayExitAnim()
	if self.rollState == RollState.RS_Exiting then
		return
	end
	self.rollState = RollState.RS_Exiting
	self.seqMove = nil
	self.seqMove = DoTweenSequence.Create({dotweenLayerKey=SysBroadcastManager.dotween_key})
	self.seqMove:Append(self.NodeCanvasGroup:DOFade(Opacity, 0.2))
	-- self.seqMove:Join(self.UINode:DOLocalMoveY(self.hide_y, t))
	self.seqMove:OnKill(function ()
		self.rollState = RollState.RS_Null
		self:SetShowOrHide(false)
	end)
end


-- function C:PlayEnterAnim()
-- 	if self.rollState == RollState.RS_Begin or self.rollState == RollState.RS_Ing then
-- 		return
-- 	end

-- 	local y = self.UINode.transform.localPosition.y
-- 	local t = 0.1
-- 	if self.seqMove then
-- 		self.seqMove:Kill()
-- 	end
-- 	local len = math.abs(y - self.show_y)
-- 	t = self.max_t * (len / self.max_len)

-- 	if t < 0.001 then
-- 		self:RunBroadcast()
-- 	else
-- 		self.rollState = RollState.RS_Begin
-- 		self.seqMove = nil
-- 		self.seqMove = DoTweenSequence.Create()
-- 		self.seqMove:Append(self.NodeCanvasGroup:DOFade(1, t))
-- 		self.seqMove:Join(self.UINode:DOLocalMoveY(self.show_y, t))
-- 		self.seqMove:OnKill(function ()
-- 			self:RunBroadcast()
-- 		end)
-- 	end
-- end

-- function C:PlayExitAnim()
-- 	if self.rollState == RollState.RS_Exiting then
-- 		return
-- 	end

-- 	local y = self.UINode.transform.localPosition.y
-- 	local t = 0.1
-- 	local len = math.abs(y - self.hide_y)
-- 	t = self.max_t * (len / self.max_len)

-- 	if t < 0.001 then
-- 		self.rollState = RollState.RS_Null
-- 		self:SetShowOrHide(false)
-- 	else
-- 		self.rollState = RollState.RS_Exiting
-- 		self.seqMove = nil
-- 		self.seqMove = DoTweenSequence.Create()
-- 		self.seqMove:Append(self.NodeCanvasGroup:DOFade(Opacity, t))
-- 		self.seqMove:Join(self.UINode:DOLocalMoveY(self.hide_y, t))
-- 		self.seqMove:OnKill(function ()
-- 			self.rollState = RollState.RS_Null
-- 			self:SetShowOrHide(false)
-- 		end)
-- 	end
-- end
