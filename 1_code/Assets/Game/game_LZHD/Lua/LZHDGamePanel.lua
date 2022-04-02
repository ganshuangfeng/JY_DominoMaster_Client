local basefunc = require "Game/Common/basefunc"

LZHDGamePanel = basefunc.class()
local C = LZHDGamePanel
C.name = "LZHDGamePanel"
local Instance
local skip_time = 11
function C.Create()
	if not Instance then
		Instance = C.New()
	end
	C.instance = Instance
	return Instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["lzhd_jingbi_info_change"] = basefunc.handler(self, self.on_lzhd_jingbi_info_change)
	self.lister["lzhd_my_jingbi_info_change"] = basefunc.handler(self, self.on_lzhd_my_jingbi_info_change)
	self.lister["model_guess_apple_bet_response"] = basefunc.handler(self, self.on_model_guess_apple_bet_response)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["model_guess_apple_all_info"] = basefunc.handler(self,self.on_model_guess_apple_all_info)
	self.lister["model_guess_apple_total_bet_tb"] = basefunc.handler(self,self.on_model_guess_apple_total_bet_tb)
	self.lister["model_guess_apple_game_status_change"] = basefunc.handler(self,self.on_model_guess_apple_game_status_change)
	self.lister["lzhd_add_point"] = basefunc.handler(self,self.on_lzhd_add_point)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.settle_timer then
		self.settle_timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	if self.QuitTimer then
		self.QuitTimer:Stop()
	end
	if self.Mian_Timer then
		self.Mian_Timer:Stop()
	end
	self:RemoveListener()
	self:RemoveListenerGameObject()
	--destroy(self.gameObject)
	GameObject.Destroy(self.gameObject,1)
	Instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.hu_anim = self.hu_skeleton.transform:GetComponent("Animator")
	self.long_anim = self.long_skeleton.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	LZHDChip.InitChipPool()
	self:InitMainTimer()
	self:GetBestBet()
	self:ResetText()
	self:InitBetText()
	ExtendSoundManager.PlaySceneBGM(audio_config.big_battle.big_usually_BGM.audio_name)

	local btn_map = {}
	btn_map["left_top"] = {self.left_top1,self.left_top2,self.left_top3}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "lzhd")
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.left_click = self.left_click:GetComponent("PolygonClick")
	self.mid_click = self.mid_click:GetComponent("PolygonClick")
	self.right_click = self.right_click:GetComponent("PolygonClick")

	self:AddListenerGameObject()
	self:InitAutoBet()
	self:MyRefresh()
end

function C:InitBetText()
	for i = 1,#LZHDBetConfig do
		self["bet"..i.."_txt"].text = StringHelper.ToCash(LZHDBetConfig[i])
	end
end

function C:MyRefresh()
end

--初始化按钮事件
function C:AddListenerGameObject()
	self.line_road_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LZHDRoadMapPanel.Create()
		end
	)
	self.left_click.PointerDown:AddListener(
		function ()
			print("left_click")
			self.left_on.gameObject:SetActive(true)
		end
	)
	self.mid_click.PointerDown:AddListener(
		function ()
			print("mid_click")
			self.mid_on.gameObject:SetActive(true)
		end
	)
	self.right_click.PointerDown:AddListener(
		function ()
			print("right_click")
			self.right_on.gameObject:SetActive(true)
		end
	)
	self.help_btn.onClick:AddListener(function ()
		self:OnClickHelp()
	end)

	self.left_click.PointerUp:AddListener(
		function ()
			print("left_click")
			local my_jing_bi = MainModel.UserInfo.jing_bi
			if LZHDBetConfig[1] > my_jing_bi then
				HintPanel.Create(1,GLL.GetTx(80049),function ()
					SysBrokeSubsidyManager.RunBrokeProcess()
				end)
			else
				if LZHDModel.gaming_data.status_data.status == "bet" then
					ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_in.audio_name)
				end
			end
			Network.SendRequest("guess_apple_bet",{bet_1 = {self.curr_choose_index},bet_2 = {},bet_3 = {}})
			self.auto_tge.isOn = false
			self.is_auto = false
			self.left_on.gameObject:SetActive(false)
		end
	)
	self.mid_click.PointerUp:AddListener(
		function ()
			local my_jing_bi = MainModel.UserInfo.jing_bi
			if LZHDBetConfig[1] > my_jing_bi then
				HintPanel.Create(1,GLL.GetTx(80049),function ()
					SysBrokeSubsidyManager.RunBrokeProcess()
				end)
			else

				if LZHDModel.gaming_data.status_data.status == "bet" then
					ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_in.audio_name)
				end			end
			print("mid_click")
			Network.SendRequest("guess_apple_bet",{bet_2 = {self.curr_choose_index},bet_1 = {},bet_3 = {}})
			self.auto_tge.isOn = false
			self.is_auto = false
			self.mid_on.gameObject:SetActive(false)
		end
	)
	self.right_click.PointerUp:AddListener(
		function ()
			local my_jing_bi = MainModel.UserInfo.jing_bi
			if LZHDBetConfig[1] > my_jing_bi then
				HintPanel.Create(1,GLL.GetTx(80049),function ()
					SysBrokeSubsidyManager.RunBrokeProcess()
				end)
			else

				if LZHDModel.gaming_data.status_data.status == "bet" then
					ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_in.audio_name)
				end			end
			print("right_click")
			Network.SendRequest("guess_apple_bet",{bet_3 = {self.curr_choose_index},bet_2 = {},bet_1 = {}})
			self.auto_tge.isOn = false
			self.is_auto = false
			self.right_on.gameObject:SetActive(false)
		end
	)
	self.menu_btn.onClick:AddListener(function ()
		self:OnClickMenu()
	end)

	self.help_btn.onClick:AddListener(
		function ()
			print("<color=red> 打开帮助面板 </color>")
		end
	)
	self.quit_btn.onClick:AddListener(
		function ()
			Network.SendRequest("guess_apple_quit_room")
		end
	)
	--破产
	self.broke_btn.onClick:AddListener(function ()
		HintPanel.Create(1,GLL.GetTx(80049),function ()
			SysBrokeSubsidyManager.RunBrokeProcess()
			self.broke_btn.gameObject:SetActive(false)
		end)
	end)

	self.close_infomation_btn.onClick:AddListener(
		function ()
			self.infomation_item.gameObject:SetActive(false)
		end
	)
	self.my_info_btn.onClick:AddListener(
		function ()
			local data = LZHDModel.GetMyInfo()
			self:CreateInfomationPanel(data,Vector3.New(-247,-223,0),true)
		end
	)
	self.rich1_info_btn.onClick:AddListener(
		function ()
			local data = LZHDModel.GetRich1Info()
			self:CreateInfomationPanel(data,Vector3.New(-247,199,0))
		end
	)
	self.rich2_info_btn.onClick:AddListener(
		function ()
			local data = LZHDModel.GetRich2Info()
			self:CreateInfomationPanel(data,Vector3.New(-247,-39,0))
		end
	)
	self.fortunately_info_btn.onClick:AddListener(
		function ()
			local data = LZHDModel.GetFortunateInfo()
			self:CreateInfomationPanel(data,Vector3.New(237,-52,0))
		end
	)
	--点击的时候弹出选中
	self.curr_choose_index = 1
	for i = 1,5 do
		self["bet"..i.."_btn"].onClick:AddListener(
			function ()
				if self.bet_can_click[i] then
					ExtendSoundManager.PlaySound(audio_config.big_battle.big_change.audio_name)
					self:SetBet(i)
				else
					SysBrokeSubsidyManager.RunBrokeProcess()
				end
			end
		)
	end
end

function C:RemoveListenerGameObject()
	self.line_road_btn.onClick:RemoveAllListeners()
	self.left_click.PointerDown:RemoveAllListeners()
	self.mid_click.PointerDown:RemoveAllListeners()
	self.right_click.PointerDown:RemoveAllListeners()
	self.left_click.PointerUp:RemoveAllListeners()
	self.mid_click.PointerUp:RemoveAllListeners()
	self.right_click.PointerUp:RemoveAllListeners()
	self.menu_btn.onClick:RemoveAllListeners()
	self.help_btn.onClick:RemoveAllListeners()
	self.quit_btn.onClick:RemoveAllListeners()
	--破产
	self.broke_btn.onClick:RemoveAllListeners()

	self.close_infomation_btn.onClick:RemoveAllListeners()
	self.my_info_btn.onClick:RemoveAllListeners()
	self.rich1_info_btn.onClick:RemoveAllListeners()
	self.rich2_info_btn.onClick:RemoveAllListeners()
	self.fortunately_info_btn.onClick:RemoveAllListeners()
	for i = 1,5 do
		self["bet"..i.."_btn"].onClick:RemoveAllListeners()
	end
end

function C:SetBet(i)
	self.curr_choose_index = i
	for ii = 1,5 do
		local v = self["bet"..ii.."_btn"].gameObject.transform.localPosition
		self["bet"..ii.."_btn"].gameObject.transform.localPosition = Vector3.New(v.x,-14,0)
		self["bet"..ii.."_confirm"].gameObject:SetActive(false)
	end
	self["bet"..i.."_confirm"].gameObject:SetActive(true)
	self["bet"..i.."_btn"].gameObject.transform.localPosition = Vector3.New(self["bet"..i.."_btn"].gameObject.transform.localPosition.x,7,0)
end

function C:GetBestBet()
	local index = 1
	for i = 5,1,-1 do
		if MainModel.UserInfo.jing_bi / 5>= LZHDBetConfig[i] then
			index = i
			break
		end
	end
	self:SetBet(index)
end


--获得了all_info
function C:on_model_guess_apple_all_info()
	self.t1_txt.text = LZHDModel.data.status_data.status
	self.other_txt.text = LZHDModel.data.status_data.player_num
	self:InitHistory()
	self:RefreshAllInfo()
	self:RefreshMain()
	self:RefreshBetNode()
	self:QuitNotice()

	--进入押注
	local cd = LZHDModel.gaming_data.status_data.time_out
	if LZHDModel.gaming_data.status_data.status ~= "settle" then
		LZHDChip.RefreshChips()
	end

	if LZHDModel.gaming_data.status_data.status == "settle" and cd == 12 then
		LZHDChip.RefreshChips()
	end
end

--初始化历史数据
function C:InitHistory(data)
	if self.history_items then
		for i = 1,#self.history_items do
			destroy(self.history_items[i])
		end
	end

	local data  = data or LZHDModel.GetHistoryData()
	local max = math.min(#data,20)
	self.history_items = {}
	for i = 1,max do
		local obj = self:InitOnePoint(data[#data - i + 1],max - i + 1)
		self.history_items[max - i + 1] = obj
	end
end
--初始化一颗点
function C:InitOnePoint(data,i)
	local obj = GameObject.Instantiate(self.LZHDPoint,self["line_node"..i])
	obj.transform.localPosition = Vector3.zero
	obj.gameObject:SetActive(true)
	local IMG = obj.transform:Find("@main_img"):GetComponent("Image")
	if data == 1 then
		IMG.sprite = GetTexture("img_lz_01")
	elseif data == 2 then
		IMG.sprite = GetTexture("img_lz_03")
	else
		IMG.sprite = GetTexture("img_lz_02")
	end
	return obj.gameObject
end

--游戏过程中的消息
function C:on_model_guess_apple_game_status_change()
	self:RefreshMain()
end

function C:RefreshMain()
	self.t1_txt.text = LZHDModel.gaming_data.status_data.status
	self.other_txt.text = LZHDModel.gaming_data.status_data.player_num
	--处于押注状态的时候
	if LZHDModel.gaming_data.status_data.status == "bet" then
		self.left_txt.text = 0
		self.mid_txt.text = 0
		self.right_txt.text = 0
		if self.left_card then
			self.left_card:MyExit()
			self.left_card = nil
		end
		if self.right_card then
			self.right_card:MyExit()
			self.right_card = nil
		end

		if not self.left_card then
			self.left_card = LZHDPoker.Create(0,self.card1_node)
		end
		if not self.right_card then
			self.right_card = LZHDPoker.Create(0,self.card2_node)
		end
		self:ResetWinTx()
		--进入押注
		local cd = LZHDModel.gaming_data.status_data.time_out
		if cd > 15 then
			self.pk_img.gameObject:SetActive(true)
			local tx_obj = newObject("LH_VS_kaiju",self.transform)
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_star_game.audio_name)
			GameObject.Destroy(tx_obj,4)
			Timer.New(function ()
				if IsEquals(self.gameObject) then
					CommonAnim.PlayCountDown(cd - 1,0,self.pk_node,nil,nil,nil,function (cd)
						if cd == 3 and not self.cd_tx then
							self.cd_tx = newObject("LH_djs_gq",self.pk_node)
						end
						if cd == 0 then
							destroy(self.cd_tx)
							self.cd_tx = nil
						end
					end)
					self.pk_img.gameObject:SetActive(false)
					ExtendSoundManager.PlaySound(audio_config.big_battle.big_star_chip.audio_name)
					local tx_obj2 = newObject("LH_yzks_dx",self.tx_node)
					GameObject.Destroy(tx_obj2,2)
				end
			end,3,1):Start()
			--如果玩家勾选了自动押注
			Timer.New(function ()
				if self.is_auto and IsEquals(self.gameObject) and next(LZHDModel.BetList)  then
					local data = LZHDModel.BetList
					dump(data,"<color=red>数据++++++++++++++++ </color>")
					Network.SendRequest("guess_apple_bet",data)
				else
					self:IsNeedUnAuto()
				end
				LZHDModel.ResetMyBetList()
			end,3.5,1):Start()
		end
	end

	if LZHDModel.gaming_data.status_data.status == "game" then
		if not LZHDModel.ThisBeded then
			LZHDModel.ResetMyBetList()
		end 
		if not self.left_card then
			self.left_card = LZHDPoker.Create(0,self.card1_node)
		end
		if not self.right_card then
			self.right_card = LZHDPoker.Create(0,self.card2_node)
		end
		ExtendSoundManager.PlaySound(audio_config.big_battle.big_over_chip.audio_name)
		local tx_obj = newObject("LH_yzks_dx_2",self.tx_node)
		self.pk_img.gameObject:SetActive(true)
		GameObject.Destroy(tx_obj,2)
		self:RefreshAllInfo()
	end
	--结算状态
	if LZHDModel.gaming_data.status_data.status == "settle" then
		local cd = LZHDModel.gaming_data.status_data.time_out
		if cd ~= skip_time + 1 then
			self:ResetText()
			CommonAnim.PlayCountDown(cd,0,self.transform)
			return
		end
		if not self.left_card then
			self.left_card = LZHDPoker.Create(0,self.card1_node)
		end
		if not self.right_card then
			self.right_card = LZHDPoker.Create(0,self.card2_node)
		end
		local seq = DoTweenSequence.Create()
		seq:Append(self.left_card.transform:DOMove(Vector3.New(0,200,0),0.3))
		seq:Join(self.left_card.transform:DOScale(Vector3.New(0.7,0.7,0.7),0.3))
		seq:AppendCallback(
			function ()
				local pos = self.left_card.transform.position
				local scale = self.left_card.transform.localScale
				if self.left_card then
					self.left_card:MyExit()
				end
				self.left_card = LZHDPoker.Create(LZHDModel.gaming_data.game_data.left_pai_id,self.card1_node)
				self.left_card.transform.position = pos
				self.left_card.transform.localScale = scale
				self.left_card:PlayShow()

				local seq2 = DoTweenSequence.Create()
				seq2:AppendInterval(1)
				seq2:Append(self.left_card.transform:DOLocalMove(Vector3.zero,0.3))
				seq2:Join(self.left_card.transform:DOScale(Vector3.New(0.4,0.4,0.4),0.3))
			end
		)

		Timer.New(function ()
			if IsEquals(self.gameObject) then
				local seq = DoTweenSequence.Create()
				seq:Append(self.right_card.transform:DOMove(Vector3.New(0,200,0),0.3))
				seq:Join(self.right_card.transform:DOScale(Vector3.New(0.7,0.7,0.7),0.3))
				seq:AppendCallback(
					function ()
						local pos = self.right_card.transform.position
						local scale = self.right_card.transform.localScale
						if self.right_card then
							self.right_card:MyExit()
						end
						self.right_card = LZHDPoker.Create(LZHDModel.gaming_data.game_data.right_pai_id,self.card2_node)
						self.right_card.transform.position = pos
						self.right_card.transform.localScale = scale
						self.right_card:PlayShow()

						local seq2 = DoTweenSequence.Create()
						seq2:AppendInterval(1)
						seq2:Append(self.right_card.transform:DOLocalMove(Vector3.zero,0.3))
						seq2:Join(self.right_card.transform:DOScale(Vector3.New(0.4,0.4,0.4),0.3))
					end
				)
			end
		end,2,1):Start()
		if self.settle_timer then
			self.settle_timer:Stop()
		end
		self.settle_timer = Timer.New(function ()
			local win_info = LZHDLib.WhoWin(LZHDModel.gaming_data.game_data.left_pai_id,LZHDModel.gaming_data.game_data.right_pai_id)
			self:PlayWinTX(win_info)
			LZHDChip.PlaySettlementAnim(LZHDModel.gaming_data.settle_data,LZHDModel.gaming_data.game_data)
				if cd > skip_time then
					Timer.New(
						function ()
							if IsEquals(self.gameObject) then
								CommonAnim.PlayCountDown(3,0,self.pk_node)
								self.pk_img.gameObject:SetActive(false)
								self:ResetText()
							end
						end
					,6,1):Start()
				end
			Event.Brocast("lzhd_add_point",win_info)
		end,4,1)
		self.settle_timer:Start()
		Network.SendRequest("guess_query_history_data")
	end
end

function C:on_model_guess_apple_total_bet_tb()
	local data = LZHDModel.BetData
	self.left_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(1))
	self.mid_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(2))
	self.right_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(3))
	if LZHDModel.data.bet_data then
		self.my_left_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(1)) 
		self.my_mid_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(2))
		self.my_right_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(3))
	end
	local do_f = function (v,pos)
		local data = v.total_pos_bet
		local seq = DoTweenSequence.Create()
		for i = 1,3 do
			local chip_value = LZHDChip.GetChipValues(data[i])
			for ii = 1,#chip_value do
				seq:AppendCallback(
					function ()
						local chip = LZHDChip.GetChip(chip_value[ii])
						if pos == 4 then
							local obj = newObject("LH_TW_xinyunx",chip.transform)
							GameObject.Destroy(obj,1.5)
						end
						LZHDChip.DropChipAnimation(chip,pos,i)
						ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_move.audio_name)
					end
				)
				seq:AppendInterval(0.10 * 10/#chip_value)
			end
		end
	end

	for k , v in pairs(data.player_bet_data) do
		--其他人
		if k == "other" then
			do_f(v,5)
		end
		--我自己（我自己是及时做的动画，这边不用做动画）
		if k == LZHDModel.GetMyInfo().player_id  then

		end
		--富豪1
		if k == LZHDModel.GetRich1Info().player_id then
			do_f(v,2)
		end
		--富豪2
		-- if k == LZHDModel.GetRich2Info().player_id then
		-- 	do_f(v,3)
		-- end
		--幸运玩家
		if k == LZHDModel.GetFortunateInfo().player_id then
			do_f(v,4)
		end
	end
	self:RefreshAllInfo()
end
--刷新头像栏的信息
function C:RefreshAllInfo()
	local rich1_info = LZHDModel.GetRich1Info()
	self.rich1_txt.text = rich1_info.player_name
	self.rich1_money_txt.text = StringHelper.ToCash(rich1_info.jing_bi)
	SetHeadImg(rich1_info.head_image,self.rich1_head_img )
	Event.Brocast("set_vip_icon_msg", {img=self.rich1_vip_img, vip=rich1_info.vip_level})

	-- local rich2_info = LZHDModel.GetRich2Info()
	-- self.rich2_txt.text = rich2_info.player_name
	-- self.rich2_money_txt.text = StringHelper.ToCash(rich2_info.jing_bi)
	-- self.rich2_head_img.sprite = GetTexture("ty_touxiang_0"..rich2_info.head_image)
	-- SetHeadImg(rich2_info.head_image,self.rich2_head_img )

	local fortunate_info = LZHDModel.GetFortunateInfo()
	self.fortunately_txt.text = fortunate_info.player_name
	self.fortunately_money_txt.text = StringHelper.ToCash(fortunate_info.jing_bi)
	self.fortunately_head_img.sprite = GetTexture("ty_touxiang_0"..fortunate_info.head_image)
	SetHeadImg(fortunate_info.head_image,self.fortunately_head_img )
	Event.Brocast("set_vip_icon_msg", {img=self.fortunate_vip_img, vip=fortunate_info.vip_level})

	local data = LZHDModel.data.bet_data

	self.left_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(1))
	self.mid_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(2))
	self.right_txt.text = StringHelper.ToCash(LZHDModel.GetTotalBetByIndex(3))
 	self.my_left_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(1))
	self.my_mid_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(2))
	self.my_right_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(3))

	self.my_left_node.gameObject:SetActive(LZHDModel.data.bet_data.my_bet_data[1] > 0)
	self.my_mid_node.gameObject:SetActive(LZHDModel.data.bet_data.my_bet_data[2] > 0)
	self.my_right_node.gameObject:SetActive(LZHDModel.data.bet_data.my_bet_data[3] > 0)
	self:RefreshMyText()
end

function C:RefreshMyText()
	local my_info = LZHDModel.GetMyInfo()
	self.my_name_txt.text = my_info.player_name
	self.my_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	SetHeadImg(my_info.head_image,self.my_head_img )
	Event.Brocast("set_vip_icon_msg", {img=self.my_vip_img, vip=MainModel.UserInfo.vip_level})
	self:RefreshBetNode()
end

function C:on_model_guess_apple_bet_response(data)
	dump(data,"<color=red>做自己下注的动画</color>")
	if data.result ~= 0 then 
		self.is_auto = false
		self.auto_tge.isOn = false
		return 
	end
	local config = LZHDBetConfig
	self.my_left_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(1))
	self.my_mid_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(2))
	self.my_right_txt.text = StringHelper.ToCash(LZHDModel.GetMyTotalBetByIndex(3))
	local func = function (target_pos,chip_index)
		local chip = LZHDChip.GetChip(config[chip_index])
		LZHDChip.DropChipAnimation(chip,1,target_pos)
		ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_move.audio_name)
	end

	for i = 1,#data.bet_1 do
		func(1,data.bet_1[i])
		self.my_left_node.gameObject:SetActive(true)
	end

	for i = 1,#data.bet_2 do
		func(2,data.bet_2[i])
		self.my_mid_node.gameObject:SetActive(true)
	end

	for i = 1,#data.bet_3 do
		func(3,data.bet_3[i])
		self.my_right_node.gameObject:SetActive(true)
	end

	--当我有所操作的时候，重置
	self.QuitTime = 120

	if MainModel.UserInfo.jing_bi <= LZHDBetConfig[self.curr_choose_index] then
		self:GetBestBet()
	end
end

function C:on_lzhd_jingbi_info_change()
	self:RefreshAllInfo()
end

function C:OnClickMenu()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local activeSelf = not self.btns_node.gameObject.activeSelf
	self.btns_node.gameObject:SetActive(activeSelf)

	if activeSelf then
		--显示的时候动画表现
		CommonAnim.ShowMenuBtns(self.btn_bg_img,self.quit_btn,self.help_btn)
	end
end

--1:龙赢了 2:虎赢了 3:平均
function C:PlayWinTX(win_type)
	if win_type == LZHDComparisonEnum.LongWin then
		self.hu_anim.enabled = false
		self.long_anim.enabled = true
		self.hu_tx.gameObject:SetActive(false)
		self.long_tx.gameObject:SetActive(true)
		self.left_win.gameObject:SetActive(true)
		self.card_tx = newObject("LH_huo",self.card1_node)
		GameObject.Destroy(self.card_tx,5)
	elseif win_type == LZHDComparisonEnum.HuWin then
		self.hu_anim.enabled = true
		self.long_anim.enabled = false
		self.hu_tx.gameObject:SetActive(true)
		self.long_tx.gameObject:SetActive(false)
		self.right_win.gameObject:SetActive(true)
		self.card_tx = newObject("LH_huo",self.card2_node)
		GameObject.Destroy(self.card_tx,5)
	else
		self.hu_anim.enabled = true
		self.long_anim.enabled = true
		self.hu_tx.gameObject:SetActive(true)
		self.long_tx.gameObject:SetActive(true)
		self.mid_win.gameObject:SetActive(true)
		self.card1_tx = newObject("LH_huo",self.card1_node)
		self.card2_tx = newObject("LH_huo",self.card2_node)
		GameObject.Destroy(self.card1_tx,5)
		GameObject.Destroy(self.card2_tx,5)
	end
end

function C:ResetWinTx()
	self.hu_anim.enabled = false
	self.long_anim.enabled = false
	self.hu_tx.gameObject:SetActive(false)
	self.long_tx.gameObject:SetActive(false)
	self.right_win.gameObject:SetActive(false)
	self.left_win.gameObject:SetActive(false)
	self.mid_win.gameObject:SetActive(false)
end

--刷新筹码押注
function C:RefreshBetNode()
	local my_jing_bi = MainModel.UserInfo.jing_bi
	self.bet_can_click = self.bet_can_click or {}
	for i = 1,5 do
		self["bet"..i.."_mask"].gameObject:SetActive(LZHDBetConfig[i] > my_jing_bi)
		self.bet_can_click[i] = LZHDBetConfig[i] <= my_jing_bi
		if i == 1 and LZHDBetConfig[i] > my_jing_bi then
			self:SetBet(1) 
		end
	end
end
--资产改变消息
function C:OnAssetChange(data)
	--self:RefreshBetNode()
	if data.change_type == "guess_bet_spend" or data.change_type == "guess_apple_award" then
		
	else
		self:RefreshMyText()
	end
end
--退出提示
function C:QuitNotice()
	self.QuitTime = self.QuitTime or 60
	if self.QuitTimer then
		self.QuitTimer:Stop()
	end
	self.QuitTimer = Timer.New(
		function ()
			self.QuitTime = self.QuitTime - 1
			if self.QuitTime == 0 then
				local b = HintPanel.Create(2,GLL.GetTx(81003),function ()
					self.QuitTime = 120
				end,function ()
					Network.SendRequest("guess_apple_quit_room")
				end)
				b:SetButtonText(GLL.GetTx(80052),GLL.GetTx(81004))
			end
		end,1,-1
	)
	self.QuitTimer:Start()
end

--打开一个信息页
function C:CreateInfomationPanel(data,pos,me)
	self.infomation_item.gameObject:SetActive(true)
	self.infomation_item.localPosition = pos
	dump(data,"<color=red> 数据++++++++++++++ </color>")

	SetHeadImg(data.head_image,self.infomation_head_img )

	self.infomation_vip_txt.text = "VIP"..data.vip_level
	self.infomation_jingbi_txt.text = StringHelper.ToCash(data.jing_bi)
	self.infomation_top_txt.text = StringHelper.ToCash(data.his_max_win)
	self.infomation_bet_txt.text = StringHelper.ToCash(data.his_max_bet)
	self.infomation_name_txt.text = data.player_name

	if me then
		self.infomation_vip_txt.text = "VIP"..MainModel.UserInfo.vip_level
	end
end

--初始化自动下注的功能
function C:InitAutoBet(is_auto)
	self.is_auto = false
	self.auto_tge.isOn = self.is_auto
	self.auto_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_AUTO.audio_name)
			self.is_auto = not self.is_auto
			self.auto_tge.isOn = self.is_auto
		end
	)
	self.auto_tge.onValueChanged:AddListener(
		function (isOn)
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_AUTO.audio_name)
			self.is_auto = isOn
		end
	)
end

function C:on_lzhd_add_point(d)
	local win_info = d
	if win_info == LZHDComparisonEnum.Draw then
		win_info = 2
	elseif win_info == LZHDComparisonEnum.HuWin then
		win_info = 3
	else
		win_info = 1
	end
	local data = LZHDModel.GetHistoryData()
	local func = function (pos)
		local obj = self:InitOnePoint(win_info,#self.history_items)
		obj.transform.position = pos
		local tx = newObject("LH_TW_gx",obj.transform)
		GameObject.Destroy(obj,2)
		local target_pos = self.line_node20.transform.position
		local seq = DoTweenSequence.Create()
		seq:Append(obj.transform:DOMoveBezier(target_pos,-20,1)):SetEase(Enum.Ease.OutSine)
		seq:AppendCallback(
			function ()
				local data = LZHDModel.GetHistoryData()
				self:InitHistory(data)
				local tx = newObject("LH_TW_shouji",self.history_items[#self.history_items].transform)
				GameObject.Destroy(tx,2)
			end
		)
	end

	local pos = nil
	if win_info == 2 then
		pos = self.mid_chip_node.transform.position
	elseif win_info == 3 then
		pos = self.right_chip_node.transform.position
	else
		pos = self.left_chip_node.transform.position
	end
	func(pos)
end

function C:InitMainTimer()
	if self.Mian_Timer then
		self.Mian_Timer:Stop()
	end
	self.Mian_Timer = Timer.New(
		function ()
			if UnityEngine.Input.GetMouseButton(0) then

				self.QuitTime = 120
			end
		end,0.02,-1
	)
	self.Mian_Timer:Start()
end

function C:ResetText()
	self.my_left_node.gameObject:SetActive(false)
	self.my_right_node.gameObject:SetActive(false)
	self.my_mid_node.gameObject:SetActive(false)

	self.my_left_txt.text = "0"
	self.my_right_txt.text = "0"
	self.my_mid_txt.text = "0"

	self.left_txt.text = 0
	self.right_txt.text = 0
	self.mid_txt.text = 0

	self.left_win.gameObject:SetActive(false)
	self.right_win.gameObject:SetActive(false)
	self.mid_win.gameObject:SetActive(false)

end
--
function C:IsNeedUnAuto()
	if not next(LZHDModel.BetList) and IsEquals(self.gameObject) then
		self.is_auto = false
		self.auto_tge.isOn = false
	end
end

function C:OnClickHelp()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "sys_rules",goto_scene_parm = "panel",game = "BigBattle"})
end

function C:on_lzhd_my_jingbi_info_change()
	self:RefreshMyText()
end