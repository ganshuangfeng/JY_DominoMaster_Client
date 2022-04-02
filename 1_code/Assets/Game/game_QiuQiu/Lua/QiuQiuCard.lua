-- card_data = {[1] = ,[2] = }
local basefunc = require "Game/Common/basefunc"

QiuQiuCard = basefunc.class()
local C = QiuQiuCard
C.name = "QiuQiuCard"

function C.Create(parent,card_id)
	return C.New(parent,card_id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_nor_qiuqiu_nor_settlement_msg"] = basefunc.handler(self,self.on_nor_qiuqiu_nor_settlement_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.Timer then
		self.Timer:Stop()
	end
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

function C:ctor(parent,card_id)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.transform.localPosition = Vector3.zero
	LuaHelper.GeneratingVar(self.transform, self)
	self:RefreshData(card_id)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.Timer = Timer.New(
		function ()
			self:MyUpDate()
		end,0.02,-1
	)
	self.Timer:Start()
	self:SetNormal()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    EventTriggerListener.Get(self.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
	
end

function C:RemoveListenerGameObject()
	EventTriggerListener.Get(self.transform.gameObject).onDown = nil
	EventTriggerListener.Get(self.transform.gameObject).onUp = nil
	
end

--刷新数据
function C:RefreshData(card_id)
	local ponit2img = {
		"ty_dot_gp_1","ty_dot_gp_2","ty_dot_gp_3","ty_dot_gp_4","ty_dot_gp_5","ty_dot_gp_6"
	}
	self.card_id = card_id or self.card_id

	self.card_data = QiuQiuLib.GetDataById(card_id)

	self.card_total_point = self.card_data[1] + self.card_data[2]
	if self.card_data[1] > 0 then
		self.up_img.sprite = GetTexture(ponit2img[self.card_data[1]])
		self.up_img.gameObject:SetActive(true)
	else
		self.up_img.gameObject:SetActive(false)
	end
	if self.card_data[2] > 0 then
		self.down_img.sprite = GetTexture(ponit2img[self.card_data[2]])
		self.down_img.gameObject:SetActive(true)
	else
		self.down_img.gameObject:SetActive(false)
	end
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:SetIndex(index)
	self.index = index
end

function C:OnBeginDrag()
	print("开始拖拽")
	self.onDarging = true
end

function C:OnEndDrag()
	print("结束拖拽")
	self.onDarging = false
	if self.ReadyToControl then
		Event.Brocast("qiuqiucard_type_change")
	end
end

function C:MyUpDate()
	if not self.ReadyToControl then
		return
	end
	if self.onDarging then

	else
		self.transform.localPosition = Vector3.MoveTowards(self.transform.localPosition,Vector3.zero,14)
	end
end

function C:SetReady(isReady)
	isReady = isReady == nil and true or false
	self.ReadyToControl = isReady
end

function C:SetBack(imgname)
	if not IsEquals(self.gameObject) then return end
	self.bg_img.sprite = GetTexture(imgname or "ty_gp_x_fm_2")
	self.up_img.gameObject:SetActive(false)
	self.down_img.gameObject:SetActive(false)
end

function C:SetNormal()
	if not IsEquals(self.gameObject) then return end
	self.bg_img.sprite = GetTexture("ty_gp_d_zm")
	self.up_img.gameObject:SetActive(true)
	self.down_img.gameObject:SetActive(true)

	if self.card_data[1] > 0 then
		self.up_img.gameObject:SetActive(true)
	else
		self.up_img.gameObject:SetActive(false)
	end
	if self.card_data[2] > 0 then
		self.down_img.gameObject:SetActive(true)
	else
		self.down_img.gameObject:SetActive(false)
	end
end

function C:SetMid()
	if not IsEquals(self.gameObject) then return end
	if IsEquals(self.gameObject) then
		self.bg_img.sprite = GetTexture("ty_gp_d_cm")
		self.up_img.gameObject:SetActive(false)
		self.down_img.gameObject:SetActive(false)
	end
end

function C:ShowMask(isMask)
	if IsEquals(self.mask_img) then
		self.mask_img.gameObject:SetActive(isMask == true)
	end
end

function C:on_nor_qiuqiu_nor_settlement_msg()
	self.gameObject:SetActive(false)
end