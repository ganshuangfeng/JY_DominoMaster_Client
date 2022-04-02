-- 创建时间:2022-01-07
-- Panel:Act_RouletteWheelPanel
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

Act_RouletteWheelPanel = basefunc.class()
local C = Act_RouletteWheelPanel
C.name = "Act_RouletteWheelPanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
    self.lister["model_luck_lottery_data_msg"] = basefunc.handler(self, self.MyRefresh)
end
function C:AssetChange(data)
	self:RefreshNum()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
	
	if self.level_cell then
		for k,v in ipairs(self.level_cell) do
			v:OnDestroy()
		end
	end
	if self.vip_cell then
		for k,v in ipairs(self.vip_cell) do
			v:OnDestroy()
		end
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

function C:ctor(parent, selfParent)
	self.selfParent = selfParent

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
	self.go_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OpenBox(1)
	end)
end

function C:RemoveListenerGameObject()
	self.go_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()

	self.wheel_cfg = Act_RouletteManager.GetPtWheelConfig()
	self.max_num = #self.wheel_cfg
	self.zp_list = {}
	for k,v in ipairs(self.wheel_cfg) do
		local pre = RouletteWheelCell.Create(self.award, v, -36*(k-1))
		pre.gameObject.name = "RouletteWheelCell_"..k
		self.zp_list[#self.zp_list + 1] = pre
	end

	self.scroll1 = self.ScrollView1:GetComponent("ScrollRect")
	self.scroll2 = self.ScrollView2:GetComponent("ScrollRect")
	self.select.gameObject:SetActive(false)

	self.fx_obj_1 = GameObject.Instantiate(GetPrefab("LP_daiji_02"), self.game)

	Act_RouletteManager.QueryLuckData("")
end

function C:RefreshNum()
	local item_n = GameItemModel.GetItemCount("prop_xycj_coin")
	local free_n = Act_RouletteManager.m_data.free_num or 0
	if item_n > 0 then
		self.item_txt.text = "x"..item_n
		self.free_txt.text = ""
		self.item.gameObject:SetActive(true)
	else
		self.free_txt.text = "gratis:"..free_n
		self.item.gameObject:SetActive(false)
		if _G["SysVipManager"] and MainModel.UserInfo.vip_level < 1 then
			self.free_txt.text = ""
		end
	end

	self.red.gameObject:SetActive(Act_RouletteManager.IsCanLuck(1))
	Event.Brocast("act_roulette_data_change_msg")
end

function C:MyRefresh()
	self:RefreshLevelAward()
	self:RefreshVipAward()
	self:RefreshNum()

	self:RefreshVipAwardPos()
end

function C:RefreshLevelAward()
	if self.level_cell then
		for k,v in ipairs(self.level_cell) do
			v:OnDestroy()
		end
	end
	self.level_cfg = Act_RouletteManager.GetLevelAwardConfig()

	if #self.level_cfg > 4 then
		self.scroll1.enabled = true
	else
		self.scroll1.enabled = false
	end

	self.level_cell = {}
	for k,v in ipairs(self.level_cfg) do
		local pre = RouletteLevelAwardCell.Create(self.Content1, v)
		self.level_cell[#self.level_cell + 1] = pre
	end
end

function C:RefreshVipAward()
	if not _G["SysVipManager"] then
		return
	end
	if self.vip_cell then
		for k,v in ipairs(self.vip_cell) do
			v:OnDestroy()
		end
	end
	self.vip_cfg = Act_RouletteManager.GetVipAwardConfig()

	if #self.vip_cfg > 4 then
		self.scroll2.enabled = true
	else
		self.scroll2.enabled = false
	end

	self.vip_cell = {}
	for k,v in ipairs(self.vip_cfg) do
		local pre = RouletteVipAwardCell.Create(self.Content2, v, k)
		self.vip_cell[#self.vip_cell + 1] = pre
	end
end

function C:RefreshVipAwardPos()
    coroutine.start(function ( )
        Yield(0)
        Yield(0)--间隔一帧不得行
        if IsEquals(self.Content2) then
        	local x = 0
        	if MainModel.UserInfo.vip_level > 2 then
        		if MainModel.UserInfo.vip_level > 8 then
	        		x = 6
        		else
    	    		x = MainModel.UserInfo.vip_level - 2
        		end
        	end
            self.scroll2:StopMovement()
            self.Content2.transform.localPosition = Vector3.New(-84*x, 0, 0)
        end
    end)
end

function C:DoTween(selectIndex)
	if not self.fx_obj_2 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("LP_zhuandong_01"), self.game)
	end
	self.fx_obj_1.gameObject:SetActive(false)
	self.fx_obj_2.gameObject:SetActive(true)
	self.select.gameObject:SetActive(true)

	local rota = -360 * 8 + 36 * (selectIndex-1)
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.pan:DORotate( Vector3.New(0, 0 , rota), 6, Enum.RotateMode.FastBeyond360):SetEase(Enum.Ease.InOutCubic))
	self.seq:AppendCallback(function ()
		self.pan.localRotation = Quaternion:SetEuler(0, 0, rota)
		self.fx_obj_2.gameObject:SetActive(false)
		if not self.fx_obj_3 then
			self.fx_obj_3 = GameObject.Instantiate(GetPrefab("LP_xuanzhong_01"), self.game)
		end
		self.fx_obj_3.gameObject:SetActive(true)
	end)
	self.seq:AppendInterval(1)
	self.seq:OnForceKill(function ()
		if not IsEquals(self.gameObject) then
			return
		end
		self.pan.localRotation = Quaternion:SetEuler(0, 0, rota)
		if self.fx_obj_3 then
			self.fx_obj_3.gameObject:SetActive(false)
		end
		self.fx_obj_1.gameObject:SetActive(true)
		self.select.gameObject:SetActive(false)
		self.seq = nil
		self.is_lock = false
		self.selfParent:OpenBoxFinish()

		if self.wheel_cfg[selectIndex] then
			local a = self.wheel_cfg[selectIndex]
			local bei = Act_RouletteManager.GetVipBei(MainModel.UserInfo.vip_level)
			local ss = string.format("%s#%s%sx%s=%s %s", MainModel.UserInfo.vip_level, a.type, StringHelper.ToCash(a.award), bei, StringHelper.ToCash(a.award*bei), a.type)
			self.selfParent.pmd_cont:AddMyPMDData({player_name=MainModel.UserInfo.name, award_data=ss})
		end
	end)
end

function C:OpenBox(n)
	if self.is_lock then
		return
	end

	local item_n = GameItemModel.GetItemCount("prop_xycj_coin")
	local free_n = Act_RouletteManager.m_data.free_num or 0
	if item_n <= 0 and free_n <= 0 then
		if MainModel.UserInfo.vip_level == 0 then
			if Act_RouletteManager.IsAllGetLevelAward() then
				HintPanel.Create(1, GLL.GetTx(80017))
			else
				HintPanel.Create(1, GLL.GetTx(80018))
			end
		else
			HintPanel.Create(1, GLL.GetTx(80019))
		end
		return
	end

	-- 本次是否消耗的免费次数
	local dd = 0
	if item_n <= 0 and free_n > 0 then
		dd = 1
	end

	self.selfParent:OpenBox(1, n, function (data)		
		self.is_lock = true

		Act_RouletteManager.m_data.free_num = Act_RouletteManager.m_data.free_num - dd
		self:RefreshNum()

		if #data.data == 1 then
			self:DoTween(data.data[1].index)
		else

		end
	end)
end