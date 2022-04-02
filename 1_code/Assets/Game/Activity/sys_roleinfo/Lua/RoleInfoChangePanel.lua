-- 创建时间:2021-12-07
-- Panel:RoleInfoChangePanel
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

RoleInfoChangePanel = basefunc.class()
local C = RoleInfoChangePanel
C.name = "RoleInfoChangePanel"
local head_img_type = {
	[1] = "man",
	[2] = "man",
	[3] = "woman",
	[4] = "woman",
	[5] = "animal",
	[6] = "animal",
	[7] = "animal",
	[8] = "animal",
}


function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv2").transform
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
	self.close_btn.onClick:AddListener(
		function ()
			Timer.New(function ()
				RoleInfoPanel.Create()
				self:MyExit()
			end,0.2,1):Start()		
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			Event.Brocast("bsds_send_power",{key = "personal_info_edit_15"})
			self:SetIntroducer()
			self:UpdateName()
			self:SetHeadImage()
			self:UpdatePhone()
			self:SetSex()
			Timer.New(function ()
				RoleInfoPanel.Create()
				self:MyExit()
			end,0.2,1):Start()	
		end
	)
	self.go_next_btn.onClick:AddListener(
		function ()
			local seq = DoTweenSequence.Create()
			seq:Append(self.content.transform:DOLocalMoveX(-478,0.3))
		end
	)
	self.go_last_btn.onClick:AddListener(
		function ()
			local seq = DoTweenSequence.Create()
			seq:Append(self.content.transform:DOLocalMoveX(0,0.3))
		end
	)
	self.head_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_edit_1"})
	end)

	self.sign_input.onValueChanged:AddListener(
		function ()
			self.sign_holder_txt.text = ""
		end
	)
	self.sign_input.onEndEdit:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_edit_14"})
	end)
	self.phone_input.onValueChanged:AddListener(
		function ()
			self.phone_holder_txt.text = ""
		end
	)
	self.phone_input.onEndEdit:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_edit_5"})
	end)
	self.name_input.onValueChanged:AddListener(
		function ()
			self.name_holder_txt.text = ""
		end
	)
	self.name_input.onEndEdit:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_edit_4"})
	end)

	self.toggle_nan.onValueChanged:AddListener(
		function (isOn)
			if isOn then
				self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(false)
				self.item_list[self.curr_choose_id].normal.gameObject:SetActive(true)
				self.curr_choose_id = 1
				self.head_img.sprite = GetTexture("ty_touxiang_0"..self.curr_choose_id)
				self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(true)
				self.item_list[self.curr_choose_id].normal.gameObject:SetActive(false)
				Event.Brocast("bsds_send_power",{key = "personal_info_edit_3"})
				self:RefreshHeadChoose(1)
			else

				self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(false)
				self.item_list[self.curr_choose_id].normal.gameObject:SetActive(true)
				self.curr_choose_id = 3
				self.head_img.sprite = GetTexture("ty_touxiang_0"..self.curr_choose_id)
				self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(true)
				self.item_list[self.curr_choose_id].normal.gameObject:SetActive(false)
				Event.Brocast("bsds_send_power",{key = "personal_info_edit_2"})
				self:RefreshHeadChoose(0)
			end
		end
	)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.confirm_btn.onClick:RemoveAllListeners()
	self.go_next_btn.onClick:RemoveAllListeners()
	self.go_last_btn.onClick:RemoveAllListeners()
	self.head_btn.onClick:RemoveAllListeners()
	self.sign_input.onValueChanged:RemoveAllListeners()
	self.sign_input.onEndEdit:RemoveAllListeners()
	self.phone_input.onValueChanged:RemoveAllListeners()
	self.phone_input.onEndEdit:RemoveAllListeners()
	self.name_input.onValueChanged:RemoveAllListeners()
	self.name_input.onEndEdit:RemoveAllListeners()
	self.toggle_nan.onValueChanged:RemoveAllListeners()
	for k, v in pairs(self.temp_uis) do
		EventTriggerListener.Get(v.head_item_img.gameObject).onClick = nil
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self.item_list = {}
	SetHeadImg(MainModel.UserInfo.head_image, self.head_img)
	if type(MainModel.UserInfo.head_image) == "number" then
		self.curr_choose_id = tonumber(MainModel.UserInfo.head_image)
	else
		self.curr_choose_id = 1
	end
	self.temp_uis = {}
	for i = 1,8 do
		local temp_ui = {}
		local item = GameObject.Instantiate(self.head_item,self.content)
		LuaHelper.GeneratingVar(item.transform,temp_ui)
		temp_ui.head_item_img.sprite = GetTexture("ty_touxiang_0"..i)
		temp_ui.gameObject = item.gameObject
		self.item_list[#self.item_list+1] = temp_ui
		EventTriggerListener.Get(temp_ui.head_item_img.gameObject).onClick = basefunc.handler(self,function ()
			Event.Brocast("bsds_send_power",{key = "personal_info_edit_" .. ( 5 + i)})
			self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(false)
			self.item_list[self.curr_choose_id].normal.gameObject:SetActive(true)
			self.curr_choose_id = i
			self.head_img.sprite = GetTexture("ty_touxiang_0"..self.curr_choose_id)
			self.item_list[self.curr_choose_id].choosing.gameObject:SetActive(true)
			self.item_list[self.curr_choose_id].normal.gameObject:SetActive(false)
		end)
		item.gameObject:SetActive(true)
		self.temp_uis[#self.temp_uis+1] = temp_ui
	end

	self.id_txt.text = "ID:"..MainModel.UserInfo.user_id
	self.toggle_nan = self.toggle_nan.gameObject.transform:GetComponent("Toggle")
	self.toggle_nv = self.toggle_nv.gameObject.transform:GetComponent("Toggle")
	self.sign_input = self.sign_input.gameObject.transform:GetComponent("InputField")
	self.phone_input = self.phone_input.gameObject.transform:GetComponent("InputField")
	self.name_input = self.name_input.gameObject.transform:GetComponent("InputField")
	self.toggle_nan.isOn = MainModel.UserInfo.sex == 1
	self.toggle_nv.isOn = MainModel.UserInfo.sex ~= 1

	self.name_holder_txt.text = MainModel.UserInfo.name
	self.name_input.text = MainModel.UserInfo.name
	
	self.phone_holder_txt.text = MainModel.UserInfo.telPhone
	self.phone_input.text = MainModel.UserInfo.telPhone
	
	self.sign_holder_txt.text = MainModel.UserInfo.introducer
	self.sign_input.text =  MainModel.UserInfo.introducer
	
	self:MyRefresh()
end

function C:MyRefresh()
	for i = 1,8 do
		local temp_ui = self.item_list[i]
		local B = tonumber(MainModel.UserInfo.head_image) == i
		temp_ui.choosing.gameObject:SetActive( B)
		temp_ui.normal.gameObject:SetActive( not B)
	end
	self:RefreshHeadChoose()
end

--设置性别
function C:SetSex()
	dump()

	local sex = self.toggle_nan.isOn == true and 1 or 0
	if MainModel.UserInfo.sex ~= sex then
		Network.SendRequest("set_sex",{sex = sex},nil,function (data)
			dump(data,"<color=red>设置性别</color>")
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(data.result))
			else
				MainModel.UserInfo.sex = sex
			end
		end)
	end
end

--设置简介
function C:SetIntroducer()
	local str = self.sign_input.text
	if MainModel.UserInfo.introducer ~= str then
		Network.SendRequest("set_introducer",{introducer = str},nil,function (data)
			dump(data,"<color=red>设置简介</color>")
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(data.result))
			else
				MainModel.UserInfo.introducer = str
			end
		end)
	end
	self.sign_holder_txt.text = str
	dump(str,"<color=red>输入的简介</color>")
end

--更新自己名字
function C:UpdateName()
	local str = self.name_input.text
	dump(str,"<color=red>输入的名字</color>")
	if str ~= MainModel.UserInfo.name then
		Network.SendRequest("update_player_name",{name = str},nil,function (data)
			dump(data,"<color=red>设置名字</color>")
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(data.result))
			else
				MainModel.UserInfo.name = str
				Event.Brocast("name_changed")
			end
		end)
	end
	self.name_holder_txt.text = str
end

--设置头像
function C:SetHeadImage(id)
	local id = id or self.curr_choose_id
	if MainModel.UserInfo.head_image ~= id then
		Network.SendRequest("set_head_image",{img_type = id or self.curr_choose_id},nil,function (data)
			dump(data,"<color=red>设置头像</color>")
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(data.result))
			else
				MainModel.UserInfo.head_image = id
			end
			Event.Brocast("set_head_image_response","set_head_image_response",{data = data})
		end)
	end
end

--设置自己的电话号码
function C:UpdatePhone()
	local str = self.phone_input.text
	if MainModel.UserInfo.telPhone ~= str then
		Network.SendRequest("update_bind_phone",{phone_no = str},nil,function (data)
			dump(data,"<color=red>设置电话号码</color>")
			if data.result ~= 0 then
				LittleTips.Create(GLL.GetTx(data.result))
			else
				MainModel.UserInfo.telPhone = str
			end
		end)
	end
	self.phone_holder_txt.text = str
	dump(str,"<color=red>输入的电话</color>")
end

--刷新头像
function C:RefreshHeadChoose(sex,head_id)
	local sex = sex or MainModel.UserInfo.sex
	local head_id = head_id or MainModel.UserInfo.head_image
	for i = 1,#self.item_list do
		if head_img_type[i] == "man" then
			if sex == 1 then
				self.item_list[i].gameObject:SetActive(true)
			else
				self.item_list[i].gameObject:SetActive(false)
			end
		end

		if head_img_type[i] == "woman"  then
			if sex == 0 then
				self.item_list[i].gameObject:SetActive(true)
			else
				self.item_list[i].gameObject:SetActive(false)
			end
		end
	end
end