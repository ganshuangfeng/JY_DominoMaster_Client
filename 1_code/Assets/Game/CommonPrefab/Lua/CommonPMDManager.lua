-- 创建时间:2020-06-22
-- Panel:CommonPMDManager
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
 --]]

local basefunc = require "Game/Common/basefunc"

CommonPMDManager = basefunc.class()
local C = CommonPMDManager
C.name = "CommonPMDManager"
--actvity_mode :1 左滑动,2向上滑动，居中时停止一会
local anim_funcs = {
"Anim1",
"Anim2",
}
local dotweenLayerKey = "CommonPMDManager"

function CommonPMDManager.Create(panelSelf, cell_call, parm)
	return C.New(panelSelf, cell_call, parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.on_query_fake_data)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(self.parm.dotweenLayerKey)

	if self.Loop_Timer then
		self.Loop_Timer:Stop()
	end
	self.Loop_Timer = nil

	self:RemoveListener()
end

function C:ctor(panelSelf, cell_call, parm)
	self.panelSelf = panelSelf
	self.cell_call = cell_call
	self.parm = parm
	self.parm.dotweenLayerKey = self.parm.dotweenLayerKey or dotweenLayerKey

	self:MakeLister()
	self:AddMsgListener()
	self.data_type = parm.data_type
	self.send_t = parm.send_t or 10

	self.pmd_list = self.parm.pmd_list or {}

	self.actvity_mode = parm.actvity_mode or 1
	self.time_scale = self.parm.time_scale or 1
	if self.actvity_mode == 1 then
		self.start_pos = parm.start_pos or 1200
		self.end_pos = parm.end_pos or -1200
	else
		self.start_pos = parm.start_pos or -120
		self.end_pos = parm.end_pos or 120
	end
	self.bw = math.abs( self.start_pos-self.end_pos )
	self.is_can_anim = true
	self:RunPMD()

    self.Loop_Timer = Timer.New(function()
		Network.SendRequest("query_fake_data", { data_type = self.data_type })
	end, self.send_t, -1)
    self.Loop_Timer:Start()
    Network.SendRequest("query_fake_data", { data_type = self.data_type })
end

--当展示区域没有任何一个物体的时,某个物体出现
function C:SetOnStartCall(backcall)
	self.onStartCall = backcall
end

--当展示区域只剩下一个物体,这个物体即将消失时
function C:SetOnEndCall(backcall)
	self.onEndCall = backcall
end

--横着走
function C:Anim1(obj, w)
	w = w or 0
	local tran = obj.transform
	tran.localPosition = Vector3.New(self.start_pos, 0, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=self.parm.dotweenLayerKey})
	seq:Append(tran:DOLocalMoveX(self.end_pos-w, (10 * w/self.bw + 10)*self.time_scale):SetEase(Enum.Ease.Linear))
	seq:OnKill(function ()
		destroy(obj.gameObject)
		self.is_can_anim = true
		self:RunPMD()
		if #self.pmd_list == 0 then
			if self.onEndCall then
				self.onEndCall()
			end
		end
	end)
end

--竖着走
function C:Anim2(obj)
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, self.start_pos, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=self.parm.dotweenLayerKey})
	seq:Append(tran:DOLocalMoveY(0, 1.5*self.time_scale))
	seq:AppendInterval(1*self.time_scale)
	seq:Append(tran:DOLocalMoveY(100, 1.5*self.time_scale))
	seq:OnKill(function ()
		destroy(obj.gameObject)
		self.is_can_anim = true
		self:RunPMD()
		if #self.pmd_list == 0 then
			if self.onEndCall then
				self.onEndCall()
			end
		end
	end)
end

function C:RunPMD()
	if #self.pmd_list > 0 and self.is_can_anim then
		local obj = self.cell_call(self.panelSelf, self.pmd_list[1])
		obj.transform.localPosition = Vector3.New(3000, 3000, 0)
		table.remove(self.pmd_list, 1)
		self.is_can_anim = false

		local rect = obj.transform:GetComponent("RectTransform")
		local w = 0
		
		coroutine.start(function ()
			Yield(0)
			if IsEquals(rect) then
				w = rect.sizeDelta.x
			end
			if IsEquals(obj) then
				if self.actvity_mode == 1 then
					self:Anim1(obj, w)
				else
					self:Anim2(obj)
				end
			end
		end)
	end
end

function C:AddMyPMDData(data)
	-- dump(data, "<color=red>AddMyPMDData</color>")
	self:AddPMDData(data, true)
end

function C:on_query_fake_data(_, data)
	-- dump(data, "<color=red>on_query_fake_data</color>")
	if data and data.result == 0 and data.data_type == self.data_type then
		self:AddPMDData(data)
	end
end

function C:AddPMDData(data, is_top)
	if is_top then
		table.insert(self.pmd_list, 1, data)
	else
		self.pmd_list[#self.pmd_list + 1] = data
	end
	self:RunPMD()
end
