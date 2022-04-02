local basefunc = require "Game/Common/basefunc"

Act_YJFLEnter = basefunc.class()
local C = Act_YJFLEnter
C.name = "Act_YJFLEnter"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
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
	self.enter_btn.onClick:AddListener(function()
		local parm = {gotoui ="sys_act_base", goto_type = "normal", goto_scene_parm = "panel",ID = 5}
		Event.Brocast("global_hint_state_set_msg", parm)
		GameManager.GotoUI(parm)
	end)
end

function C:RemoveListenerGameObject()
	self.enter_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()
	self.Red.gameObject:SetActive(Act_YJFLManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Red)
end
