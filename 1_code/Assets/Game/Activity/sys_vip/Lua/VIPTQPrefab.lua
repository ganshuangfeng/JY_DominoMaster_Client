-- 创建时间:2021-12-22
-- Panel:VIPTQPrefab
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

VIPTQPrefab = basefunc.class()
local C = VIPTQPrefab
C.name = "VIPTQPrefab"

function C.Create(parent, selfParent)
	return C.New(parent, selfParent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["model_task_data_change_msg"] = basefunc.handler(self, self.on_model_task_data_change_msg)
    self.lister["model_vip_base_info_msg"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent, selfParent)
	self.parent = parent
	self.selfParent = selfParent

	local obj = newObject(C.name, self.parent)
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
	self.goto_pay_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		self.selfParent:MyExit()
	end)
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		print("领取")
		Network.SendRequest("get_task_award_new",{id = self.show_cfg.base.task_id, award_progress_lv = self.show_cfg.base.task_lv}, "")
	end)
	self.get_not_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.cur_status == 0 then
			HintPanel.Create(1, string.format(GLL.GetTx(60027), self.show_cfg.base.vip) )
		elseif self.cur_status == 2 then
			HintPanel.Create(1, GLL.GetTx(60026))
		end
	end)
	
	self.left_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.show_level = self.show_level - 1
		self:RefreshShowVip()
	end)
	self.right_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.show_level = self.show_level + 1
		self:RefreshShowVip()
	end)
end

function C:RemoveListenerGameObject()
	self.goto_pay_btn.onClick:RemoveAllListeners()
	self.get_btn.onClick:RemoveAllListeners()
	self.get_not_btn.onClick:RemoveAllListeners()
	
	self.left_btn.onClick:RemoveAllListeners()
	self.right_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
	self.goto_pay_txt.text = GLL.GetTx(20014)
	self.get_txt.text = GLL.GetTx(20016)
end

function C:RefreshLL()
end

function C:InitUI()
	self.ui_jd_size = 260
	self.vip_jd_rect = self.vip_jd:GetComponent("RectTransform")
	
	
	self.fx_obj_1 = GameObject.Instantiate(GetPrefab("VIP_viPzi_sg"), self.title)
	self:MyRefresh()
end

function C:MyRefresh()
	self.cur_data = SysVipManager.GetVipData()
	self.cur_config = SysVipManager.GetVipConfigByLevel(self.cur_data.level)

	self.fx_obj_1 = GameObject.Instantiate(GetPrefab("VIP_viPzi_sg"), self.title)
	
	destroy(self.fx_obj_2)
	if self.cur_data.level > 0 and self.cur_data.level < 5 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_1-3"), self.show_vip_level_img.transform)
	elseif self.cur_data.level >= 5 and self.cur_data.level < 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_5-7"), self.show_vip_level_img.transform)
	elseif self.cur_data.level >= 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_8-10"), self.show_vip_level_img.transform)
	end

	self.show_vip_level_txt.text = "VIP"..self.cur_data.level
	self.show_vip_level_img.sprite = GetTexture(self.cur_config.base.icon)
	if self.cur_data.level >= SysVipManager.UIConfig.max_vip_level then
		self.is_max_level = true
	else
		self.is_max_level = false
		self.next_level = self.cur_data.level + 1
		self.next_cfg = SysVipManager.GetVipConfigByLevel(self.next_level)
	end

	self.show_level = self.cur_data.level
	if self.show_level == 0 then
		self.show_level = 1
	end

	if self.is_max_level then
		self.hint_pay_txt.text = ""
		self.vip_jd_txt.text = "MAX"
		self.vip_jd_rect.sizeDelta = { x = self.ui_jd_size, y = 20.6 }
	else
		self.hint_pay_txt.text = string.format(GLL.GetTx(20013), StringHelper.ToCash(self.next_cfg.base.total-self.cur_data.rate), "VIP"..self.next_level)
		self.vip_jd_txt.text = StringHelper.ToCash(self.cur_data.rate) .. "/" .. StringHelper.ToCash(self.next_cfg.base.total)
		local bl = self.cur_data.rate / self.next_cfg.base.total
		self.vip_jd_rect.sizeDelta = { x = self.ui_jd_size * bl, y = 20.6 }
	end

	self:RefreshShowVip()

end

function C:RefreshShowVip()
	self.show_cfg = SysVipManager.GetVipConfigByLevel(self.show_level)
	self.top_vip_txt.text = "VIP"..self.show_level

	self.r1.gameObject:SetActive(true)
	self.r2.gameObject:SetActive(true)
	self.r3.gameObject:SetActive(true)
	if self.show_level < 4 then
		self.r2.gameObject:SetActive(false)
	end
	if self.show_level < 8 then
		self.r3.gameObject:SetActive(false)
	end

	if self.show_level == 1 then
		self.left_btn.gameObject:SetActive(false)
		self.vip_left_txt.text = ""
	else
		self.left_btn.gameObject:SetActive(true)
		self.vip_left_txt.text = "VIP"..(self.show_level-1)
		if SysVipManager.IsVipAwardByRange(1, self.show_level-1) == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
			self.red_left.gameObject:SetActive(false)
		else
			self.red_left.gameObject:SetActive(true)
		end
	end
	if self.show_level >= SysVipManager.UIConfig.max_vip_level then
		self.right_btn.gameObject:SetActive(false)
		self.vip_right_txt.text = ""
	else
		self.right_btn.gameObject:SetActive(true)
		self.vip_right_txt.text = "VIP"..(self.show_level+1)

		if SysVipManager.IsVipAwardByRange(self.show_level+1, SysVipManager.UIConfig.max_vip_level) == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
			self.red_right.gameObject:SetActive(false)
		else
			self.red_right.gameObject:SetActive(true)
		end
	end

	self:RefreshInfo()
	self:RefreshAward()
end

function C:RefreshInfo()
	if self.info_cell then
		for k,v in ipairs(self.info_cell) do
			v:OnDestroy()
		end
	end
	self.info_cell = {}
	for k,v in ipairs(self.show_cfg.info) do
		local pre = TQDescCell.Create(self.Content1, v)
		ClipUIParticle(pre.transform)
		self.info_cell[#self.info_cell + 1] = pre
	end
end

function C:RefreshAward()
	if self.award_cell then
		for k,v in ipairs(self.award_cell) do
			v:OnDestroy()
		end
	end
	self.award_cell = {}
	for k,v in ipairs(self.show_cfg.up_award) do
		local pre = TQAwardCell.Create(self.Content2, v)
		self.award_cell[#self.award_cell + 1] = pre
	end

	local task = GameTaskManager.GetTaskDataByID(self.show_cfg.base.task_id)
	if task then
		local task_status = GameTaskManager.GetTaskStatusByData(task, SysVipManager.UIConfig.max_vip_level)
		dump(task_status, "<color=red>AAA task_status</color>")
		self.cur_status = task_status[self.show_cfg.base.task_lv]
		self.award_received.gameObject:SetActive(false)
		if self.cur_status == 0 then
			self.get_btn.gameObject:SetActive(false)
			self.get_not_btn.gameObject:SetActive(true)
			self.get_not_txt.text = GLL.GetTx(20016)			
		elseif self.cur_status == 1 then
			self.get_btn.gameObject:SetActive(true)
			self.get_not_btn.gameObject:SetActive(false)
			self.get_not_txt.text = GLL.GetTx(20016)
		else
			self.get_btn.gameObject:SetActive(false)
			self.get_not_btn.gameObject:SetActive(false)
			self.award_received.gameObject:SetActive(true)
			self.get_not_txt.text = GLL.GetTx(20018)
		end
	else
		self.get_btn.gameObject:SetActive(false)
		self.get_not_btn.gameObject:SetActive(true)
		self.get_not_txt.text = GLL.GetTx(20016)
	end
end

function C:on_model_task_data_change_msg(data)
	if data.id == self.show_cfg.base.task_id then
		self:RefreshAward()
	end
end