-- 创建时间:2022-01-07
-- Panel:Act_RouletteVipWheelPanel
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

Act_RouletteVipWheelPanel = basefunc.class()
local C = Act_RouletteVipWheelPanel
C.name = "Act_RouletteVipWheelPanel"

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
    self.lister["model_vip_base_info_msg"] = basefunc.handler(self, self.AssetChange)
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
	DOTweenManager.KillLayerKeyTween(self.dotweenLayerKey)

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
	self.xh_jb = 100000000
	self.dotweenLayerKey = C.name

	self.wheel_cfg = Act_RouletteManager.GetVipWheelConfig()
	self.max_num = #self.wheel_cfg
	self.zp_list = {}
	for k,v in ipairs(self.wheel_cfg) do
		local pre = RouletteVipWheelCell.Create(self.award, v, -36*(k-1))
		pre.gameObject.name = "RouletteVipWheelCell_"..k
		self.zp_list[#self.zp_list + 1] = pre
	end

	self.fx_obj_1 = GameObject.Instantiate(GetPrefab("LP_VIP_daiji"), self.game)
	self.select.gameObject:SetActive(false)
	
	local fx_obj_cx = GameObject.Instantiate(GetPrefab("LP_VIP_chuxian"), self.game)
	local seqcx = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	seqcx:AppendInterval(2)
	seqcx:OnKill(function ()
		fx_obj_cx.gameObject:SetActive(false)
	end)

	self.item_txt.text = StringHelper.ToCash(self.xh_jb)

	Act_RouletteManager.QueryLuckData("")
end

function C:MyRefresh()
	self:RefreshNum()
end

function C:RefreshNum()
	if _G["SysVipManager"] and MainModel.UserInfo.vip_level < 1 then
		self.go_go_img.transform.localPosition = Vector3.New(0, 0, 0)
		self.item.gameObject:SetActive(false)
	else
		self.go_go_img.transform.localPosition = Vector3.New(0, 27, 0)
		self.item.gameObject:SetActive(true)
	end
end

function C:DoTween(selectIndex)
	if not self.fx_obj_2 then
		self.fx_obj_2 = GameObject.Instantiate(GetPrefab("LP_VIP_zhuandong"), self.game)
	end
	self.fx_obj_1.gameObject:SetActive(false)
	self.fx_obj_2.gameObject:SetActive(true)
	self.select.gameObject:SetActive(true)

	local rota = -360 * 8 + 36 * (selectIndex-1)
	self.seq = DoTweenSequence.Create({dotweenLayerKey=self.dotweenLayerKey})
	self.seq:Append(self.pan:DORotate( Vector3.New(0, 0 , rota), 6, Enum.RotateMode.FastBeyond360):SetEase(Enum.Ease.InOutCubic))
	self.seq:AppendCallback(function ()
		self.pan.localRotation = Quaternion:SetEuler(0, 0, rota)
		self.fx_obj_2.gameObject:SetActive(false)
		if not self.fx_obj_3 then
			self.fx_obj_3 = GameObject.Instantiate(GetPrefab("LP_VIP_xuanzhong"), self.game)
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
			local ss = string.format("%s#%s%s", MainModel.UserInfo.vip_level, a.type, StringHelper.ToCash(a.award))
			self.selfParent.pmd_cont:AddMyPMDData({player_name=MainModel.UserInfo.name, award_data=ss})
		end
	end)
end

function C:OpenBox(n)
	if self.is_lock then
		return
	end

	if Act_RouletteManager.m_data.vip_num <= 0 then
		HintPanel.Create(1, GLL.GetTx(80022))
		return
	end
	if MainModel.UserInfo.jing_bi < self.xh_jb*2 then
		HintPanel.Create(1, GLL.GetTx(80023), function ()
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end)
		return
	end

	self.selfParent:OpenBox(2, n, function (data)		
		self.is_lock = true
		self.selfParent:ManualRefreshAsset(MainModel.UserInfo.jing_bi)

		Act_RouletteManager.m_data.vip_num = Act_RouletteManager.m_data.vip_num - 1
		Event.Brocast("ui_button_data_change_msg", { gotoui = "act_roulette" })
		self:RefreshNum()

		if #data.data == 1 then
			self:DoTween(data.data[1].index)
		else
			
		end
	end)
end