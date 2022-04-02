-- 创建时间:2022-01-05
-- Panel:InteractiveInfoShow
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

InteractiveInfoShow = basefunc.class()
local C = InteractiveInfoShow
C.name = "InteractiveInfoShow"

function C.Create(parent, data)
	return C.New(parent, data)
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
	ExtendSoundManager.CloseSound(self.audio_key)

	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, data)
	self.data = data
	self.parent = parent
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.data.config.move_prefab then
		if self.data.config.prefab == "BQ_qian" then
			self:RunBQ_qian()
		else
			self:Run2()
		end
	else
		self:Run1()
	end
end

function C:Run1()
	if self.data.config.audio then
		self.audio_key = ExtendSoundManager.PlaySound(self.data.config.audio)
	end

    local obj = GameObject.Instantiate(GetPrefab(self.data.config.prefab), self.parent.transform).gameObject
    obj.transform.position = self.data.pos2
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(self.data.config.show_time)
    seq:OnForceKill(function ()
        destroy(obj)
    end)

end

function C:Run2()
	if self.data.config.audio then
		self.audio_key = ExtendSoundManager.PlaySound(self.data.config.audio)
	end
	
	local prefab1 = self.data.config.move_prefab
	local prefab2 = self.data.config.prefab
	local obj1
	local obj2
	
	obj1 = GameObject.Instantiate(GetPrefab(prefab1), self.parent.transform).gameObject
    obj1.transform.position = self.data.pos1
    local seq = DoTweenSequence.Create()
    seq:Append(obj1.transform:DOMove(self.data.pos2, self.data.mt))
    seq:AppendCallback(function ()
		destroy(obj1)
		obj1 = nil
		obj2 = GameObject.Instantiate(GetPrefab(prefab2), self.parent.transform).gameObject
	    obj2.transform.position = self.data.pos2
    end)
    seq:AppendInterval(self.data.config.show_time)
    seq:OnKill(function ()

    end)
    seq:OnForceKill(function ()
        destroy(obj1)
        destroy(obj2)
    end)
end

local tt = {0, 0.1, 0.2, 0.3}
function C:RunBQ_qian()
	for i = 1, 4 do
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(tt[i])
		seq:AppendCallback(function ()
			local rota = -360 * 8 - math.random(0, 180)
	
	    	local obj = GameObject.Instantiate(GetPrefab("BQ_qian"), self.parent.transform).gameObject
	    	local tran = obj.transform
		    tran.position = self.data.pos1
		    local seq = DoTweenSequence.Create()
			seq:Append(tran:DORotate( Vector3.New(0, 0 , rota), self.data.mt, Enum.RotateMode.FastBeyond360):SetEase(Enum.Ease.InOutCubic))
			seq:Join(tran:DOMove(self.data.pos2, self.data.mt))
			seq:OnForceKill(function ()
		        destroy(obj)
		    end)
		end)
	end

	local obj1
    local seq1 = DoTweenSequence.Create()
    seq1:AppendInterval(self.data.mt)
    seq1:AppendCallback(function ()
    	obj1 = GameObject.Instantiate(GetPrefab("BQ_qian_02"), self.parent.transform).gameObject
	    obj1.transform.position = self.data.pos2
	end)
    seq1:AppendInterval(self.data.config.show_time)
    seq1:OnForceKill(function ()
        destroy(obj1)
    end)
end
