-- 创建时间:2021-11-09
-- Panel:DominoJLPlayerBase

local basefunc = require "Game/Common/basefunc"

DominoJLPlayerBase = basefunc.class()
local C = DominoJLPlayerBase
C.name = "DominoJLPlayerBase"

function C:ctor(panelSelf, obj, data)
	self.panelSelf = panelSelf
	self.data = data
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:AddListenerGameObject()
	self:InitUI()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_fg_all_info"] = basefunc.handler(self,self.on_model_fg_all_info)
	self.lister["model_nor_dmn_nor_begin_msg"] = basefunc.handler(self,self.on_model_nor_dmn_nor_begin_msg)
	self.lister["model_nor_dmn_nor_cp_msg"] = basefunc.handler(self,self.on_model_nor_dmn_nor_cp_msg)
	self.lister["model_nor_dmn_nor_ybq_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_ybq_msg)
	self.lister["model_nor_dmn_nor_ready_msg"] = basefunc.handler(self,self.on_nor_dmn_nor_ready_msg)
	self.lister["show_card_finsh"] = basefunc.handler(self,self.on_show_card_finsh)
	self.lister["card_join_grop"] = basefunc.handler(self,self.on_card_join_grop)
	self.lister["model_level_data_change"] = basefunc.handler(self,self.on_model_level_data_change)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:AddListenerGameObject()
    -- EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
	-- 	local user = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
	-- 	if user then
	-- 		GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "my_panel", ext = {pos=self.transform.position + Vector3.New(150,50,0)}, data = user})
	-- 	end
	-- end)
end

function C:RemoveListenerGameObject()
	EventTriggerListener.Get(self.head_img.gameObject).onClick = nil
end

function C:MyExit()
	if self.ClearCard then
		self:ClearCard()
	end
	self:ClearYbqPoint()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	self:ExitUpdatePermitCD()
	--gameObject 是GamePanel上的，还要用，不能销毁，
	--！！！注意清空绑定的点击事件等
	-- destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshInfo()
	self:RefreshCard()
	self:RefreshZhuang()
	self:RefreshPermit()
	self:RefreshCardNum()
	self:RefreshYbqPoint()
	self:RefreshIsReady()
end

function C:RefreshInfo()
	local user = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
	if user then
		self.yes.gameObject:SetActive(true)
		self.no.gameObject:SetActive(false)
		self.name_txt.text = user.name
		if self.data.uiIndex == 1 then
			self.rp_txt.text = StringHelper.ToCash(MainModel.GetHBValue())
			self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		else
			self.money_txt.text = StringHelper.ToCash(user.score)
		end
		if self.head_link ~= user.head_link then
			self.head_link = user.head_link
		end
		SetHeadImg(self.head_link, self.head_img)
		Event.Brocast("set_vip_icon_msg", {img=self.vip_img, vip=user.vip_level})
	else
		if self.data.uiIndex == 1 then
			if self.head_link ~= MainModel.UserInfo.head_image then
				self.head_link = MainModel.UserInfo.head_image
				SetHeadImg(self.head_link, self.head_img)
			end
			self.name_txt.text = MainModel.UserInfo.name
			self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
			self.rp_txt.text = StringHelper.ToCash(MainModel.GetHBValue())
		else
			self.yes.gameObject:SetActive(false)
			self.no.gameObject:SetActive(true)
		end
	end
end

function C:RefreshCard()
end

function C:RefreshZhuang()
	if not DominoJLModel.data.zhuang then
		--还没有定庄
		self.d_node.gameObject:SetActive(false)
		return
	end
	local zj = DominoJLModel.data.s2cSeatNum[DominoJLModel.data.zhuang]
	self.d_node.gameObject:SetActive(self.data.uiIndex == zj)
end

function C:PlayZhuangAni()
	if not DominoJLModel.data.zhuang then
		--还没有定庄
		return
	end
	self:RefreshZhuang()
	self:RefreshIsReady()
end

function C:RefreshPermit()
	if self.data.uiIndex == 1 then
		if DominoJLCardGroup.Instance then
			DominoJLCardGroup.Instance:MyRefresh()
		end
	end

	if not DominoJLModel.data
	or not next(DominoJLModel.data)
	or DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming
	or DominoJLModel.data.status ~= DominoJLModel.Status.cp
	or not DominoJLModel.data.s2cSeatNum
	or not next(DominoJLModel.data.s2cSeatNum) 
	then
		self.cd = -1
		self:UpdatePermitCD()
		self:ExitUpdatePermitCD()
		self.cd_img.gameObject:SetActive(false)
		return
	end

	local state = DominoJLModel.data.model_status == DominoJLModel.Model_Status.gaming and DominoJLModel.data.status == DominoJLModel.Status.cp
	local cur_p = DominoJLModel.data.s2cSeatNum[DominoJLModel.data.cur_p]

	if not DominoJLModel.data.cur_p or not state or self.data.uiIndex ~= cur_p  then
		--没有确定权限
		--权限不在自己
		self.cd = -1
		self:UpdatePermitCD()
		self:ExitUpdatePermitCD()
		self.cd_img.gameObject:SetActive(false)
		return
	end

	--权限在自己
	self.cd = DominoJLModel.data.countdown
	self.maxCD = DominoJLModel.data.countdown
	self:UpdatePermitCD()
	self:InitUpdatePermitCD()
	self.cd_img.gameObject:SetActive(true)
	self:PlayShowNotice()
end

function C:UpdatePermitCD()
	if not self.cd or self.cd < 0 then
		self.cd_img.fillAmount = 0
		self.cd_bg_img.fillAmount = 0
		self.cd_txt.text = 0
		return
	end

	local cd = self.cd / self.maxCD
	self.cd_img.fillAmount = cd
	self.cd_bg_img.fillAmount = cd

	local cdCeil =  math.ceil(self.cd)
	if cdCeil == 3 or cdCeil == 2 or cdCeil == 1  then
		if self.cd_txt.text ~= tostring(cdCeil)  then
			ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_timeout.audio_name)
		end
	end

	self.cd_txt.text = cdCeil

	self:PlayCardShake()

	self.cd = self.cd - 0.02
end

function C:InitUpdatePermitCD()
	self:ExitUpdatePermitCD()
	self.updatePermintCDTimer = Timer.New(function ()
		self:UpdatePermitCD()
	end,0.02,-1,false,false)
	self.updatePermintCDTimer:Start()
end

function C:ExitUpdatePermitCD()
	if self.updatePermintCDTimer then
		self.updatePermintCDTimer:Stop()
	end
	self.updatePermintCDTimer = nil
end

function C:on_model_nor_dmn_nor_cp_msg(data)
	local m_data = DominoJLModel.data
	local ui_seat_num = m_data.s2cSeatNum[data.seat_num]

	if data.pai == 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.2)
		seq:AppendCallback(function ()
			self.cd_img.gameObject:SetActive(false)
		end)
	else
		self.cd_img.gameObject:SetActive(false)
	end

	if self.data.uiIndex ~= ui_seat_num then
		return
	end

	self:RefreshCardNum()
	if data.pai == 0 then
		if self.my_notice_node then
			self.my_notice_node.gameObject:SetActive(true)
			self.notice_txt.text = GLL.GetTx(40003)-- "No cards can be played"
			Timer.New(function ()
				self.my_notice_node.gameObject:SetActive(false)
			end,1.5,1):Start()
		end
		self:ShowHint("Pass")
	elseif self.my_notice_node then
		self.my_notice_node.gameObject:SetActive(false)
	end
end

function C:on_model_fg_all_info()
	self:RefreshYbqPoint()
	self:RefreshCardNum()
end

function C:RefreshCardNum()
	if not IsEquals(self.card_txt)
	or not DominoJLModel.data
	or not DominoJLModel.data.remain_pai_amount
	or not next(DominoJLModel.data.remain_pai_amount) then
		if IsEquals(self.card_txt) then
			self.card_txt.text = ""			
		end
		return
	end
	local curr_pai_num = DominoJLModel.data.remain_pai_amount[DominoJLModel.data.seatNum[self.data.uiIndex]]
	self.card_txt.text = curr_pai_num
end

function C:on_model_nor_dmn_nor_begin_msg()
	--接受到开始消息之后，3S之后关闭准备提示
	Timer.New(
		function ()
			self.zbwb_img.gameObject:SetActive(false)
		end
	,3,1):Start()
end

function C:on_nor_dmn_nor_ybq_msg(data)
	-- self.cd_img.gameObject:SetActive(false)
	self:PlayYbqPoint(data)
	self:RefreshYbqPoint()
end
function C:RefreshIsReady()
	local m_data = DominoJLModel.data

	if m_data.model_status ~= DominoJLModel.Model_Status.gaming
	or m_data.status ~= DominoJLModel.Status.ready
	then
		self.zbwb_img.gameObject:SetActive(false)
		return
	end

	local playerData = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
	if not playerData or playerData.ready ~= 1 then
		self.zbwb_img.gameObject:SetActive(false)
	else
		self.zbwb_img.gameObject:SetActive(true)
	end
end

function C:on_nor_dmn_nor_ready_msg(data)
	local CSeatNum = DominoJLModel.data.s2cSeatNum[data.seat_num]
	if CSeatNum ~= self.data.uiIndex then
		return
	end
	self:RefreshIsReady()
end

function C:RefreshScore()
	if self.data.uiIndex == 1 then
		self.money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	else
		local user = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			self.money_txt.text = StringHelper.ToCash(user.score)
		end
	end
end

function C:ShowHint(desc)
	self.hint_node.gameObject:SetActive(true)
	self.hint_txt.text = GLL.GetTx(40002)
	DominoJLAnim.PlayHint(self.hint_node)
end

function C:on_show_card_finsh()
	
end

function C:on_card_join_grop()
	self:PlayCardShake()
end

function C:PlayShowCardCount()
	
end

function C:PlayShowNotice()
end

function C:on_model_level_data_change(data)
	if data.isLevelUp then
		self:PlayLvUpAnim()
	end
end

function C:OnAssetChange(data)
	if self.data.uiIndex == 1 then
		if not table_is_null(data.data) then
			for k, v in pairs(data.data) do
				if v.asset_type == "shop_gold_sum" then
					CommonAnim.RpAddAnim(self.rp_txt.transform, v.value)
				end
			end
		end
	end
end
--money "107623","shop_gold_sum",200