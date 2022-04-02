-- 创建时间:2021-11-09
-- Panel:LudoPlayerBase

local basefunc = require "Game/Common/basefunc"

LudoPlayerBase = basefunc.class()
local C = LudoPlayerBase
C.name = "LudoPlayerBase"

function C:ctor(panelSelf, obj, data)
	self.panelSelf = panelSelf
	self.data = data
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	local color = LudoLib.GetColor(self.data.uiIndex)
	dump(color)
	self.ui_kuang = self.yes.parent.parent.transform:Find("@UI_biankuang_"..color)
	self.ui_kuang.gameObject:SetActive(false)
	self.ui_kuang.parent = self.kuang_node
	self.ui_kuang.transform.localPosition = Vector3.zero
	self.yesAnim = self.yes.transform:GetComponent("Animator")
	self.yesAnim.enabled = false
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:MyRefresh()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.roll_btn.onClick:AddListener(function ()
		self:OnClickRoll()
	end)
	
	if self.data.uiIndex == 1 then
		self.award_img.gameObject.transform:GetComponent("Button").onClick:AddListener(
		function ()
			LittleTips.Create(GLL.GetTx(80050))
		end
	)
	end

	EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
		local user = LudoModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "my_panel", ext = {pos=self.transform.position + Vector3.New(-150,10,0)}, data = user})
		end
	end)
end

function C:RemoveListenerGameObject()
    self.roll_btn.onClick:RemoveAllListeners()
	if self.data.uiIndex == 1 then
		self.award_img.gameObject.transform:GetComponent("Button").onClick:RemoveAllListeners()
	end
	EventTriggerListener.Get(self.head_img.gameObject).onClick = nil

end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["play_award_start_pos"] = basefunc.handler(self,self.on_play_award_start_pos)
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
	self:ExitUpdatePermitCD()
	if LudoDesk.Instance then
		LudoDesk.Instance:ClearPiece(self.data.uiIndex)
	end
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
	if IsEquals(self.auto_txt) then
		self.auto_txt.text = GLL.GetTx(30002)
	end
	
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshPlayerInfo()
	self:RefreshZhuang()
	self:RefreshPiece()
	self:RefreshPermit()
	self:RefreshAward()
	self:RefreshAuto()
	self:RefreshFlag()
end

function C:RefreshFlag()
	if not LudoModel or not LudoModel.data or not LudoModel.data.seatNum then
		self.win_flag_img.gameObject:SetActive(false)
		return
	end
	local isWin = LudoLib.CheckIsWin(LudoModel.data.seatNum[self.data.uiIndex])
	self.win_flag_img.gameObject:SetActive(isWin)

	local ct = {
		blue = "ludo_qizi_04",
		red = "ludo_qizi_03",
		green = "ludo_qizi_02",
		yellow = "ludo_qizi_01",
	}

	local setColor = function (CSeatNum)
		local color = LudoLib.GetColor(CSeatNum)
		if self.colorFlag == color then
			return
		end
		self.colorFlag = color
		self.win_flag_img.sprite = GetTexture(ct[color])
	end
	setColor(self.data.uiIndex)
end

function C:RefreshPlayerInfo()
	local user = LudoModel.GetPosToPlayer(self.data.uiIndex)
	if user and not user.isLeave then
		self.yes.gameObject:SetActive(true)
		self.no.gameObject:SetActive(false)
		self.name_txt.text = user.name
		self.money_txt.text = StringHelper.ToCash(user.score)
		SetHeadImg(user.head_link, self.head_img)
		Event.Brocast("set_vip_icon_msg", {img=self.vip_img, vip=user.vip_level})
	else
		self.yes.gameObject:SetActive(false)
		self.no.gameObject:SetActive(false)
	end
end

function C:PlayPlayerInfo()
	self:RefreshPlayerInfo()
end

function C:RefreshZhuang()
	if not LudoModel.data.zhuang then
		--还没有定庄
		self.d_node.gameObject:SetActive(false)
		return
	end
	local zj = LudoModel.data.s2cSeatNum[LudoModel.data.zhuang]
	self.d_node.gameObject:SetActive(self.data.uiIndex == zj)
end

function C:PlayZhuang()
	if not LudoModel.data.zhuang then
		--还没有定庄
		return
	end
	self:RefreshZhuang()
end

function C:RefreshPermit()
	self.cd_node.gameObject:SetActive(false)
	if not LudoModel.data.cur_p then
		--没有确定权限
		return
	end

	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	if self.data.uiIndex == cur_p then
		--权限在自己
		self.cd = LudoModel.data.countdown
		self.max_time = LudoModel.data.countdown
		self:UpdatePermitCD()
		self:InitUpdatePermitCD()
		self.cd_node.gameObject:SetActive(true)

		self.ui_kuang.gameObject:SetActive(true)
		if not self.yesAnim.enabled then
			self.yesAnim.enabled = true
			self.yesAnim:Play("bkdz Animation",0,0)
			if self.data.uiIndex == 1 then
				ExtendSoundManager.PlaySound(audio_config.ludo.ludo_round_start.audio_name)
			end
		end
	else
		--权限不在自己
		self.cd = -1
		self:UpdatePermitCD()
		self:ExitUpdatePermitCD()
		self.cd_node.gameObject:SetActive(false)
		self.ui_kuang.gameObject:SetActive(false)
		self.yesAnim.enabled = false
	end

	self:RefreshPermitRool()
	self:RefreshPermitPiece()
end

function C:UpdatePermitCD()
	if not self.cd or self.cd < 0 then
		return
	end
	
	self.cd_img.fillAmount = self.cd / self.max_time
	self.cd_kuang_img.fillAmount = self.cd / self.max_time
	self.cd = self.cd - 0.02

	--如果最大时间大于10秒，并且此时的剩余时间少于4秒，那么每次

	if self.max_time >= 9 and self.cd <= 3  then
		if self.cd_txt.text ~= tostring(math.ceil(self.cd)) and self.cd ~= 0 then
			ExtendSoundManager.PlaySound(audio_config.ludo.ludo_countdown.audio_name)
		end
	end
	self.cd_txt.text = math.ceil(self.cd)
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

--摇骰子权限
function C:PlayRollPermit()
	self:RefreshPermit()
	self:RefreshPieceChooseState()
	self:RefreshRoll()
end

--走棋权限
function C:PlayPiecePermit()
	self:RefreshPermit()
	self:RefreshPieceChooseState()
	self:RefreshPiece()
end

--刷新玩家骰子
function C:RefreshRoll()
	
end

--刷新当前的棋子
function C:RefreshPiece()
	if LudoDesk.Instance then
		LudoDesk.Instance:RefreshPiece(self.data.uiIndex)
	end
end

function C:RefreshPieceChooseState()
	if LudoDesk.Instance then
		LudoDesk.Instance:RefreshPieceChooseState(self.data.uiIndex)
	end
end

function C:SetPieceChooseState(b)
	if LudoDesk.Instance then
		LudoDesk.Instance:SetPieceChooseState(self.data.uiIndex,b)
	end
end

function C:DestroyDice()
	if IsEquals(self.dice) then
		self.dice:MyExit()
	end
	self.dice = nil
	self.curr_point = nil
end

--摇骰子
function C:PlayRoll(data)
	local check_is_had_same_place = function(can_move_piece,piece)
		for i = 1,#can_move_piece do
			if can_move_piece[i].data.place == piece.data.place then
				return true
			end
		end
		return false
	end
	self.roll_node.gameObject:SetActive(false)
	self.cd_node.gameObject:SetActive(false)
	self:DestroyDice()
	self.curr_point = data.point
	self.dice = LudoDice.Create(LudoDesk.Instance.DiceNode,self.data.uiIndex,data.point,function ()
		--如果轮到自己走棋子，并且只能走这颗旗子
		--就帮玩家选择走这颗旗子
		if true then
			return
		end
		if self.curr_point and self.data.uiIndex == 1 then
			local can_move_piece = {}
			for i = 1,4 do
				local piece = LudoDesk.Instance.pieceMap[1][i].piece
				--如果这枚旗子处于冲刺路径中
				if piece.data.place < 57 and piece.data.place >= 53 then
					if piece.data.place + self.curr_point <= 57 then
						if not check_is_had_same_place(can_move_piece,piece) then
							can_move_piece[#can_move_piece + 1] = piece
						end
					end
				end
				--如果这枚旗子在原点，并且摇出的点数为6
				if piece.data.place == 0 and self.curr_point == 6 then
					if not check_is_had_same_place(can_move_piece,piece) then
						can_move_piece[#can_move_piece + 1] = piece
					end
				end
				--如果这枚旗子不再原点，并且不再冲刺路线中
				if piece.data.place > 0 and piece.data.place < 53 then
					if not check_is_had_same_place(can_move_piece,piece) then
						can_move_piece[#can_move_piece + 1] = piece
					end
				end
			end
			dump(can_move_piece,"<color=red>可行方案+++++</color>")
			if #can_move_piece == 1 then
				--服务器需要等待2s才允许玩家移动旗子
				Timer.New(function()
					print("自动走棋")
					Network.SendRequest("nor_fxq_nor_piece",{id = can_move_piece[1].data.id})
				end,2,1):Start()
			end
		end
	end)
end

--走棋
function C:PlayPiece(data)
	self:DestroyDice()
	self.roll_node.gameObject:SetActive(false)
	self.cd_node.gameObject:SetActive(false)
	local CSeatNum = LudoModel.data.s2cSeatNum[data.seat_num]
	--依据服务器的数据
	-- local trampleData = LudoDesk.Instance:GetTrampleData(data.place,CSeatNum)
	local trampleData 
	if data.back_id then
		trampleData = {
			CSeatNum = LudoModel.data.s2cSeatNum[data.back_seat_num],
			pieceId = data.back_id,
		}
	end
	local piece = LudoDesk.Instance.pieceMap[CSeatNum][data.id]
	LudoDesk.Instance:RefreshPlacePieceNum()
	LudoDesk.Instance:SetPieceNumOnPlayPiece(CSeatNum,piece.place)
	local index = LudoLib.GetPiecePosIndex(CSeatNum,piece.place)
	local key = index[1] .. "_" .. index[2]
	LudoDesk.Instance:RefreshSafetyByKey(key)
	self:SetPieceChooseState(false)
	LudoDesk.Instance:SetDeskIndexPiecePS(index)
	piece.piece:SetScale(1)
	LudoAnim.PieceRun(CSeatNum,piece.piece,data.place,trampleData)
end

--进入
function C:PlayJoin()
	self:MyRefresh()
end

--准备
function C:PlayReady()
	self:MyRefresh()
end

--离开
function C:PlayLeave()
	local pieces = {}
	local deskPiece = LudoDesk.Instance:GetPiece(self.data.uiIndex)
	for k, v in pairs(deskPiece or {}) do
		pieces[#pieces+1] = v.piece
	end
	if not pieces or not next(pieces) then
		self:MyRefresh()
		return
	end
	LudoAnim.PieceLeave(pieces,function ()
		self:MyRefresh()
	end)
end

--分数改变
function C:PlayScoreChange(score)
	self:RefreshScore(score)
end

function C:RefreshScore(score)
	local user = LudoModel.GetPosToPlayer(self.data.uiIndex)
	self.money_txt.text = StringHelper.ToCash(user.score)
end

--奖励
function C:PlayAward(data)
	dump(data,"<color=red>当前的奖励</color>")
	dump(self.data.uiIndex)
	local m_data = LudoModel.data
	local new_data = m_data.award[m_data.seat_num] or 0
	-- dump(LudoModel.data.s2cSeatNum,"<color=red>1111111111111111111111</color>")
	-- dump(self.data.uiIndex,"<color=red>2222222222222222222222</color>")
	self.fly_prefab_name = "RPPrefab"

	if LudoModel.data and LudoModel.data.game_id and LudoModel.data.game_id < 55 then
		self.fly_prefab_name = "GoldPrefab"
	end
	if  LudoModel.data.s2cSeatNum[data.seat_num] == self.data.uiIndex then
		self.award_num = data.award
		if data.type <= 2 then
			self:TryPlayAnim()
		else
			Timer.New(
				function ()
					Event.Brocast("play_award_start_pos",{start_pos = Vector3.zero,CSeatNum = self.data.uiIndex})                        
				end,1.5,1
			):Start()
		end
	end
end

--刷新奖励
function C:RefreshAward()
	local m_data = LudoModel.data
	if not m_data.seatNum then
		self.award_txt.text = ""
		self.award_img.sprite = GetTexture("ludo_libao_01")
		return
	end
	local data = m_data.award[m_data.seatNum[self.data.uiIndex]] or 0 
	self.award_txt.text = StringHelper.ToCash(data)
	if data == 0 then
		self.award_txt.text = ""
		self.award_img.sprite = GetTexture("ludo_libao_01")
	else
		if LudoModel.data and LudoModel.data.game_id and LudoModel.data.game_id < 55 then
			self.award_img.sprite = GetTexture("ludo_libao_02")
		else
			self.award_img.sprite = GetTexture("ludo_libao_rp")
		end
	end
end

function C:OnClickRoll()
	local point = LudoGamePanel.Instance:GetDicePoint()
	Network.SendRequest("nor_fxq_nor_roll",{point = point})
end

function C:PlayAuto(data)
	local CSeatNum = LudoModel.data.s2cSeatNum[data.p]
	if CSeatNum ~= self.data.uiIndex then
		return
	end
	self.auto_node.gameObject:SetActive(data.auto_status == 1 and LudoModel.data.model_status ~= LudoModel.Model_Status.gameover)
	self:RefreshAuto()
end

function C:RefreshAuto()
	if not LudoModel or not LudoModel.data or not LudoModel.data.auto_status or not next(LudoModel.data.auto_status) then
		self.auto_node.gameObject:SetActive(false)
		return
	end

	local autoStatus = LudoModel.data.auto_status[LudoModel.data.seatNum[self.data.uiIndex]]
	self.auto_node.gameObject:SetActive(autoStatus == 1 and LudoModel.data.model_status ~= LudoModel.Model_Status.gameover)
end

function C:on_play_award_start_pos(data)
	if data.CSeatNum == self.data.uiIndex then
		self.gold_start_pos = data.start_pos
		self:TryPlayAnim()
	end
end

function C:TryPlayAnim()
	-- dump(self.gold_start_pos)
	-- dump(self.award_num)
	if self.gold_start_pos and self.award_num then
		-- print("<color=red>TTTTTTTTTTTTTTTTTTTTTTTTTT</color>")
		local start_pos = self.gold_start_pos
		local award = self.award_num
		self.award_num = nil
		self.gold_start_pos = nil

		local target_pos = nil
		local target_pos2 = nil
		if self.data.uiIndex == 1 then
			target_pos = self.award_img.gameObject.transform.position
			target_pos2 = self.award_img.gameObject.transform.position
		else
			target_pos = self.head_img.gameObject.transform.position
			if self.data.uiIndex >= 3 then
				target_pos2 = self.head_img.gameObject.transform.position + Vector3.New(0,-80,0)
			else
				if self.data.uiIndex == 1 then
					target_pos2 = self.award_img.gameObject.transform.position 
				else
					target_pos2 = self.head_img.gameObject.transform.position
				end
			end
		end
		CommonAnim.FlyGold(start_pos,target_pos,function ()
			self:RefreshAward()
			CommonEffects.PlayAddGold(self.head_img.gameObject.transform,target_pos,2,Vector3.New(6,6,6))
			ExtendSoundManager.PlaySound(audio_config.ludo.ludo_coin_get.audio_name)
			CommonAnim.FlyGoldNum(target_pos2,award)
			local prefab = newObject("UI_hezi_gx",self.head_img.gameObject.transform)
			GameObject.Destroy(prefab,2)
		end,self.fly_prefab_name)
	end
end