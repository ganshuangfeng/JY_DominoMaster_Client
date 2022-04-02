-- 创建时间:2021-12-02
-- Panel:RoleInfoPanel
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

RoleInfoPanel = basefunc.class()
local C = RoleInfoPanel
C.name = "RoleInfoPanel"

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
	self.lister["query_bind_phone_response"] = basefunc.handler(self,self.on_query_bind_phone)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.bind_pre then
		self.bind_pre:MyExit()
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
	Network.SendRequest("query_bind_phone")
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
		self.fx_obj_2.transform.localScale = Vector3.New(0.32,0.32,0.32)
	end
	self.vip_img.sprite = GetTexture(self.cur_config.base.icon)
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.chg_head_btn.onClick:AddListener(
		function ()
			Event.Brocast("bsds_send_power",{key = "personal_info_1"})
			self:MyExit()
			RoleInfoChangePanel.Create()
		end
	)
	self.lv_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_2"})
	end)
	self.name_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_4"})
	end)
	self.phone_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_5"})
	end)
	self.rp_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_6"})
	end)
	self.jingbi_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_7"})
	end)
	self.sign_btn.onClick:AddListener(function()
		Event.Brocast("bsds_send_power",{key = "personal_info_8"})
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.chg_head_btn.onClick:RemoveAllListeners()
	self.lv_btn.onClick:RemoveAllListeners()
	self.name_btn.onClick:RemoveAllListeners()
	self.phone_btn.onClick:RemoveAllListeners()
	self.rp_btn.onClick:RemoveAllListeners()
	self.jingbi_btn.onClick:RemoveAllListeners()
	self.sign_btn.onClick:RemoveAllListeners()
end


function C:InitLL()
end

function C:RefreshLL()

end

function C:InitUI()
	
	local pro =  SysLevelManager.GetExperience() / SysLevelManager.GetNextLevelNeed()
	self.id_txt.text = "ID:"..MainModel.UserInfo.user_id
	self.name_txt.text = MainModel.UserInfo.name
	self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.asset_txt.text = "..."
	self.phone_txt.text = MainModel.UserInfo.telPhone or "..."
	self.sign_txt.text = MainModel.UserInfo.introducer
	self.level_txt.text = "LV."..SysLevelManager.GetLevel()
	self.level_pro_txt.text = math.floor(pro * 100) .. "%"
	if SysLevelManager.GetLevel() == 20 then
		self.level_pro_txt.text = "MAX"
	end
	self.level_pro.sizeDelta = { y = 22,x = pro * 175.79}
	SetHeadImg(MainModel.UserInfo.head_image, self.head_img)
	self.asset_txt.text = GameItemModel.GetItemCount("shop_gold_sum")
	self.gender_img.sprite = GetTexture(MainModel.UserInfo.sex == 1 and "tc_img_ns_1" or "tc_img_ns_2")

	self.bind_pre = GameManager.GotoUI({gotoui = "act_youke_bind", goto_scene_parm = "enter", parent=self.bind_node})
	
	
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_query_bind_phone(_,data)
	if data.result == 0 then
		MainModel.UserInfo.telPhone = data.phone_no
		self.phone_txt.text = MainModel.UserInfo.telPhone
	end
end