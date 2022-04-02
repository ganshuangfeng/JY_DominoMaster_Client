-- 创建时间:2021-12-14
-- Panel:InteractiveInfoPanel
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

InteractiveInfoPanel = basefunc.class()
local C = InteractiveInfoPanel
C.name = "InteractiveInfoPanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseBQ()
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
	ExtPanel.ExtMsg(self)
	self.data = data
	self.ext_data = ext
	self.parent = parent

	self.parent = self.parent or GameObject.Find("Canvas/LayerLv3").transform
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
	self.close_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	EventTriggerListener.Get(self.Black.gameObject).onClick = basefunc.handler(self, function ()
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	EventTriggerListener.Get(self.Black.gameObject).onClick = nil
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	SysInteractiveManager.m_data.cd_map = SysInteractiveManager.m_data.cd_map or {}

	self.map = {l=-640, r=640, d=-360, t=360}

	self.size = {w=888, h=500}
	
	
	self.scroll = self.ScrollView:GetComponent("ScrollRect")

	self:SetRootPos(self.ext_data.pos)
	self.id_node.gameObject:SetActive(false)
	self:MyRefresh()
	self:RefreshLevel()
end

function C:SetRootPos(pos)
	if pos then
		local x = pos.x
		local y = pos.y
		local y_1 = y + self.size.h * (self.map.t - y) / (self.map.t - self.map.d)
		local y_2 = y - self.size.h * (y - self.map.d) / (self.map.t - self.map.d)
		local x_1 = x + self.size.w * (self.map.r - x) / (self.map.r - self.map.l)
		local x_2 = x - self.size.w * (x - self.map.l) / (self.map.r - self.map.l)

		self.root.position = Vector3.New(x, y, 0)
		self.show.position = Vector3.New(0.5*(x_1+x_2), 0.5*(y_1+y_2), 0)
		local aa = self.show.position - self.root.position
		self.show.position = self.show.position + aa:Normalize() * 100
	else
		self.root.position = Vector3.New(0, 0, 0)
		self.show.localPosition = Vector3.New(0, 0, 0)
	end	
end

function C:MyRefresh()
	local data = self.data

	self.id_txt.text = "ID:"..data.id
	self.name_txt.text = data.name
	self.money_txt.text = StringHelper.ToCash(data.score)
	self.sign_txt.text = data.introducer or ""
	SetHeadImg(data.head_link, self.head_img)
	self.gender_img.sprite = GetTexture(data.sex == 1 and "tc_img_ns_1" or "tc_img_ns_2")

	self:RefreshBQ()
	self:RefreshVIP()
end

function C:RefreshBQ()
	self.bq_list = SysInteractiveManager.GetBQData(1, MainModel.UserInfo.sex)
	if #self.bq_list > 12 then
		self.scroll.enabled = true
	else
		self.scroll.enabled = false
	end

	self:CloseBQ()
	for k,v in ipairs(self.bq_list) do
		local pre = InteractiveInfoPrefab.Create(self.Content, v, self, self.OnCellClick)
		self.cell_list[#self.cell_list + 1] = pre
	end
end

function C:RefreshVIP()
	-- dump(self.data, "<color=white>dddddddddddddddddddddd</color>")
	self.cur_vip_level = self.data.vip_level or 0
	self.cur_vip_config = SysVipManager.GetVipConfigByLevel(self.cur_vip_level)
	if self.cur_vip_level > 0 and self.cur_vip_level < 4 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_1-3"), self.vip_img.transform)
	elseif self.cur_vip_level >= 4 and self.cur_vip_level < 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_5-7"), self.vip_img.transform)
	elseif self.cur_vip_level >= 8 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("VIP_tubiao_8-10"), self.vip_img.transform)
	end
	if self.fx_obj_2 then
		self.fx_obj_2.transform.localScale = Vector3.New(0.32,0.32,0.32)
	end
	self.vip_img.sprite = GetTexture(self.cur_vip_config.base.icon)
end

function C:RefreshLevel()
	local levelView = self.show.transform:Find("BGNode/center/line3")
	levelView.gameObject:SetActive(false)
	-- local level = self.data.player_level or 1
	-- local score = self.data.level_score or 0
	-- local exp = score - SysLevelManager.GetLastLevelNeed(level)
	-- local pro = exp / SysLevelManager.GetNextLevelNeed(level)
	-- self.level_txt.text = "LV.".. level
	-- self.level_pro_txt.text = math.floor(pro * 100) .. "%"
	-- if level == 20 then
	-- 	self.level_pro_txt.text = "MAX"
	-- end
	-- self.level_pro.sizeDelta = { y = 22,x = pro * 175.79}
end

function C:OnAssetChange()
	if self.cell_list then
		for k,v in ipairs(self.cell_list) do
			v:MyRefresh()
		end	
	end
end

function C:CloseBQ()
	if self.cell_list then
		for k,v in ipairs(self.cell_list) do
			v:OnDestroy()
		end
	end
	self.cell_list = {}
end

function C:OnCellClick(data)
	dump(data)
	self:MyExit()
end

