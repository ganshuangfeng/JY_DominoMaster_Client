local basefunc = require "Game.Common.basefunc"

GMPanel = basefunc.class()
GMPanel.name = "GMPanel"

local instance

function GMPanel.Create()
	-- do
	-- 	return
	-- end
	if not instance or not IsEquals(instance.gameObject) then
		instance = GMPanel.New()
	end
	return instance
end

function GMPanel.Close()
	if instance then
		instance:ClearCMDList()
		instance:RemoveListener()
		instance:RemoveListenerGameObject()
		GameObject.Destroy(instance.gameObject)
		instance = nil
	end
end

function GMPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GMPanel:OnExitScene()
	GMPanel.Close()
end

function GMPanel:MakeLister()
	self.lister = {}
	self.lister["gm_command_response"] = basefunc.handler(self, self.gm_command_response)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function GMPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function GMPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(GMPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = self.transform.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitRect()
	--DOTweenManager.OpenPopupUIAnim(self.transform)

	if MainModel.UserInfo and MainModel.UserInfo.user_id then
		self:CreateItem(MainModel.UserInfo.user_id)
	end

	local b = SYSQXManager.debug_test()
    if b then
		self:CreateItem(b)
    end
	self:AddListenerGameObject()
end

function GMPanel:AddListenerGameObject()
	self.inputCMDField.onValueChanged:AddListener(function (val)
		
	end)
	self.inputCMDField.onEndEdit:AddListener(function ()
		if UnityEngine.Input.GetKeyDown(Enum.KeyCode.Return) or UnityEngine.Input.GetKeyDown(Enum.KeyCode.KeypadEnter) then
			self:DoCommand()
		end
	end)

	self.close_btn.onClick:AddListener(function()
		GMPanel.Close()
	end)

	self.send_btn.onClick:AddListener(function()
		self:DoCommand()
	end)

	self.money_btn.onClick:AddListener(function()
		Network.SendRequest("gm_command",{command="money \""..MainModel.UserInfo.user_id.."\",\"jing_bi\",1000000000"})
	end)

	self.task_btn.onClick:AddListener(function()		
		Network.SendRequest("gm_command",{command="add_task_progress \""..MainModel.UserInfo.user_id.."\","..self.taskInput.text..","..self.taskNumInput.text..""})
	end)

	self.lottery_btn.onClick:AddListener(function()		
		Network.SendRequest("gm_command",{command="add_lottery_score \""..MainModel.UserInfo.user_id.."\","..self.lotteryInput.text..","..self.lotteryTypeInput.text..","..self.lotteryNumInput.text..""})
	end)
end

function GMPanel:RemoveListenerGameObject()
	self.inputCMDField.onValueChanged:RemoveAllListeners()
	self.inputCMDField.onEndEdit:RemoveAllListeners()
	self.close_btn.onClick:RemoveAllListeners()
	self.send_btn.onClick:RemoveAllListeners()
	self.money_btn.onClick:RemoveAllListeners()
	self.task_btn.onClick:RemoveAllListeners()
	self.lottery_btn.onClick:RemoveAllListeners()
end

function GMPanel:InitRect()
	local transform = self.transform

	self.scrollRect = transform:Find("Scroll View"):GetComponent("ScrollRect")

	self.inputCMDField = transform:Find("InputCMDField"):GetComponent("InputField")
	self.taskInput = transform:Find("TaskInput"):GetComponent("InputField")
	self.taskNumInput = transform:Find("TaskNumInput"):GetComponent("InputField")
	self.lotteryInput = transform:Find("LotteryInput"):GetComponent("InputField")
	self.lotteryNumInput = transform:Find("LotteryNumInput"):GetComponent("InputField")
	self.lotteryTypeInput = transform:Find("LotteryTypeInput"):GetComponent("InputField")

	

	self.cmdList = {}
end

function GMPanel:DoCommand()
	local cmd = self.inputCMDField.text
	if cmd == "" then
		return
	end

	self:Refresh(cmd)
	print("[Debug] send gm command: " .. cmd)

	if string.sub(cmd, 1, 1) == "@" then
		local ss = string.sub(cmd, 2, -1)
		print("<color=red><size=20>===========================</size></color>")
		xpcall(function ()
			loadstring(ss)()
		end, function (error)
			dump(error, "<color=red>error</color>")
		end)
	else
		Network.SendRequest("gm_command",{command=cmd})
	end

	self.inputCMDField.text = "";
	self.inputCMDField:ActivateInputField();
end

function GMPanel:Refresh(item)
	local cnt = #self.cmdList
	self.cmdList[cnt + 1] = self:CreateItem(item)

	UnityEngine.Canvas.ForceUpdateCanvases()
	self.scrollRect.verticalNormalizedPosition = 0
end

function GMPanel:ClearCMDList()
	for i,v in pairs(self.cmdList) do
		GameObject.Destroy(v.gameObject)
	end
	self.cmdList = {}
end

function GMPanel:CreateItem(item)
	local obj = GameObject.Instantiate(self.cmd_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one
	local cmd_text = obj.transform:GetComponent("Text")
	cmd_text.text = item or ""
	obj.gameObject:SetActive(true)

	EventTriggerListener.Get(obj.gameObject).onClick = basefunc.handler(self, self.OnCopyClick)

	return obj
end
function GMPanel:OnCopyClick(obj)
	local tt = obj.transform:GetComponent("Text")
	self.inputCMDField.text = tt.text;
end

--启动事件--
function GMPanel:Awake()
end

function GMPanel:Start()	
end

function GMPanel:OnDestroy()
end

function GMPanel:gm_command_response(_, result)
	self:Refresh(result.result)
end
