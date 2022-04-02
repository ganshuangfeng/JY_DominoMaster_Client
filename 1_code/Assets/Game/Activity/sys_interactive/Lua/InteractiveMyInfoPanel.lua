local basefunc = require "Game/Common/basefunc"

InteractiveMyInfoPanel = basefunc.class()
local C = InteractiveMyInfoPanel
C.name = "InteractiveMyInfoPanel"

function C.Create(data, parent, ext)
	return C.New(data, parent, ext)
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

function C:ctor(data, parent, ext)
	self.data = data
	self.ext_data = ext
	self.parent = parent

	ExtPanel.ExtMsg(self)
	local parent = self.parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.position = self.ext_data.pos
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	local pro =  SysLevelManager.GetExperience() / SysLevelManager.GetNextLevelNeed()
	self.level_txt.text = "LV."..SysLevelManager.GetLevel()
	self.level_pro_txt.text = math.floor(pro * 100) .. "%"
	if SysLevelManager.GetLevel() == 20 then
		self.level_pro_txt.text = "MAX"
	end
	self.level_pro.sizeDelta = { y = 22,x = pro * 175.79}
	self.gender_img.sprite = GetTexture(MainModel.UserInfo.sex == 1 and "tc_img_ns_1" or "tc_img_ns_2")
	self.id_txt.text = "ID:"..MainModel.UserInfo.user_id
	self.name_txt.text = MainModel.UserInfo.name
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.rp_txt.text = StringHelper.ToRedNum(MainModel.UserInfo.shop_gold_sum)
	local head_link = MainModel.UserInfo.head_image
	SetHeadImg(head_link, self.head_img)

	self.cur_data = SysVipManager.GetVipData()
	self.cur_config = SysVipManager.GetVipConfigByLevel(self.cur_data.level)
	if self.cur_data.level > 0 and self.cur_data.level < 4 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_1-3"), self.vip_img.transform)
	elseif self.cur_data.level >= 4 and self.cur_data.level < 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_5-7"), self.vip_img.transform)
	elseif self.cur_data.level >= 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_8-10"), self.vip_img.transform)
	end
	if self.fx_obj_2 then
		self.fx_obj_2.gameObject.transform.localScale = Vector3.New(0.32,0.32,0.32)
	end
	self.vip_img.sprite = GetTexture(self.cur_config.base.icon)

	self:MyRefresh()
end

function C:MyRefresh()
end
