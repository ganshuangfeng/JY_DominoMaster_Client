local basefunc = require "Game/Common/basefunc"
LZHDChip = basefunc.class()
local C = LZHDChip
C.name = "LZHDChip"

function C.InitConfig()
	config = LZHDBetConfig
end

function C.Create(data,parent)
	return C.New(data,parent)
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
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

local bg_config = {"qiuqiu_cm_3","qiuqiu_cm_7","qiuqiu_cm_2","qiuqiu_cm_6","qiuqiu_cm_5"}
local color_config = {"#9D00AF","#166210","#9B0013","#04408F","#A42C02",}
C.InitConfig()
function C:ctor(data,parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or LZHDGamePanel.instance.ChipNode
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
 	self.value = data.value
	self.main_txt.text = StringHelper.ToCash(self.value)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
end

function C:InitLL()
	
end

function C:RefreshLL()
end

function C:InitUI()
	local c_index = 1
	for i = 1, 5 do
		if self.value == config[i] then
			c_index = i
		end
	end

	self.main_img.sprite = GetTexture(bg_config[c_index])
	self.main_txt.text = "<color="..color_config[c_index]..">"..StringHelper.ToCash(self.value).."</color>"
	self:MyRefresh()
end

function C:MyRefresh()

end

function C.GetChipValues(value)
	local re = {}
	local main_f 
	main_f = function (left_value)
		for i = #config,1,-1 do
			if left_value >= config[i] then
				re[#re+1] = config[i]
				left_value = left_value - config[i]
				if left_value > 0 then
					main_f(left_value)
				end
				break
			end
		end
	end
	main_f(value)
	return re
end

--初始化一个缓冲池
function C.InitChipPool()
	C.ClearChipPool()
	C.ChipPool = {}
	C.desk_chip_list = {}
	C.target_chip = {}
	C.target_chip[1] = {}
	C.target_chip[2] = {}
	C.target_chip[3] = {}
	local init_lengh = 10
	for i = 1,#config do
		Timer.New(
			function ()
				for ii = 1,init_lengh do
					if LZHDGamePanel.instance and IsEquals(LZHDGamePanel.instance.WaitChipNode) then
						local obj = LZHDChip.Create({value = config[i]},LZHDGamePanel.instance.WaitChipNode)
						C.ChipPool[config[i]] = C.ChipPool[config[i]] or {}
						C.ChipPool[config[i]][#C.ChipPool[config[i]] + 1] = obj
					end 
				end
			end,0.02 * i,1
		):Start()
	end
end

--从池子中获得一个筹码
function C.GetChip(value)
	if C.ChipPool and C.ChipPool[value] and #C.ChipPool[value] > 0 then
		local obj = table.remove(C.ChipPool[value])
		if IsEquals(obj.gameObject) then
			obj.transform:SetParent(LZHDGamePanel.instance.ChipNode)
			obj.gameObject:SetActive(true)
			return obj
		else
			return LZHDChip.Create({value = value},LZHDGamePanel.instance.ChipNode)
		end
	else
		return LZHDChip.Create({value = value},LZHDGamePanel.instance.ChipNode)
	end
end

--回收一枚筹码到缓冲池子里面
function C.SaveChipToPool(chip)
	if chip.value then
		local value = chip.value
		local max = 20
		C.ChipPool = C.ChipPool or {}
		C.ChipPool[value] = C.ChipPool[value] or {}
		if #C.ChipPool[value] <= 20 then
			C.ChipPool[value][#C.ChipPool[value]+1] = chip
			chip.transform:SetParent(LZHDGamePanel.instance.WaitChipNode)
		else
			chip:MyExit()
		end
	end
end

--清空回收池子
function C.ClearChipPool()
	C.ChipPool = C.ChipPool or {}
	for k, v in pairs(C.ChipPool) do
		for i = 1,#v do
			v[i]:MyExit()
		end
	end
	C.ChipPool = {}

	C.desk_chip_list = C.desk_chip_list or {}
	for k, v in pairs(C.desk_chip_list) do
		v:MyExit()
	end
	C.desk_chip_list = {}
end

function C.GetTargetPos(pos_index)
	if pos_index == 1 then
		local y = math.random(-120, 119)
		local x = nil
		if y >= -147 and y <= -139 then
			x = math.random(-465,-219)
		elseif y >= -139 and y <= -91 then
			x = math.random(-474,-208)
		elseif y >= -91 and y <= -32 then
			x = math.random(-457,-206)
		elseif y >= -32 and y <= 28 then
			x = math.random(-445,-199)
		elseif y >= 28 and y <= 97 then
			x = math.random(-426,-190)
		else
			x = math.random(-424,-196.8)
		end
		if  y>= - 30 and y <= 30 then
			local r = math.random(0,2)
			if r > 1 then
				x = math.random(-450,-387)
			else
				x = math.random(-285,-199)
			end
		end
		return Vector3.New(x,y,0)
	elseif pos_index == 2 then
		local y = math.random(-120, 119)
		local x = nil
		if y >= -147 and y <= -139 then
			x = math.random(-157.3,-170.2)
		elseif y >= -139 and y <= -91 then
			x = math.random(-158,166)
		elseif y >= -91 and y <= -32 then
			x = math.random(-151,151.1)
		elseif y >= -32 and y <= 28 then
			x = math.random(-135,142.8)
		elseif y >= 28 and y <= 97 then
			x = math.random(-131.5,140.3)
		else
			x = math.random(-129,140.3)
		end
		if  y>= - 30 and y <= 30 then
			local r = math.random(0,2)
			if r > 1 then
				x = math.random(-151,-42)
			else
				x = math.random(55,157)
			end
		end
		return Vector3.New(x,y,0)
	else
		local y = math.random(-120, 119)
		local x = nil
		if y >= -147 and y <= -139 then
			x = math.random(225.7,451.7)
		elseif y >= -139 and y <= -91 then
			x = math.random(218.6,474)
		elseif y >= -91 and y <= -32 then
			x = math.random(211.6,462.4)
		elseif y >= -32 and y <= 28 then
			x = math.random(212,434)
		elseif y >= 28 and y <= 97 then
			x = math.random(198,423)
		else
			x = math.random(194,418)
		end
		if  y>= - 30 and y <= 30 then
			local r = math.random(0,2)
			if r > 1 then
				x = math.random(205,285)
			else
				x = math.random(380,454)
			end
		end
		return Vector3.New(x,y,0)
	end
end

--丢砝码的动画 1,我投注 ；2,富豪1 投注 ；3,富豪2 ；4,幸运星投注；5,其他玩家投注
function C.DropChipAnimation(chip,form_index,target_index)
	C.desk_chip_list = C.desk_chip_list or {}
	C.desk_chip_list[#C.desk_chip_list+1] = chip
	C.target_chip[target_index][#C.target_chip[target_index] + 1] = chip
	chip.transform:SetParent( LZHDGamePanel.instance.ChipNode)
	if form_index == 1 then
		chip.transform.position = LZHDGamePanel.instance.my_node.transform.position
	elseif form_index == 2 then
		chip.transform.position = LZHDGamePanel.instance.rich1.transform.position
	elseif form_index == 3 then
		chip.transform.position = LZHDGamePanel.instance.rich2.transform.position
	elseif form_index == 4 then
		chip.transform.position = LZHDGamePanel.instance.fortunately.transform.position
	else
		chip.transform.position = LZHDGamePanel.instance.other.transform.position
	end

	local seq = DoTweenSequence.Create()
	local pos = C.GetTargetPos(target_index)
	seq:Append(chip.transform:DOLocalMove(pos,math.random(0.4,0.41)))
end

function C.CreateChipInDesk(chip,target_index)
	C.desk_chip_list = C.desk_chip_list or {}
	C.desk_chip_list[#C.desk_chip_list+1] = chip
	C.target_chip[target_index][#C.target_chip[target_index] + 1] = chip
	chip.transform:SetParent( LZHDGamePanel.instance.ChipNode)
	local pos = C.GetTargetPos(target_index)
	chip.transform.localPosition = pos
end

--播放结算的动画
function C.PlaySettlementAnim(settlement_data,game_data)
	dump(settlement_data,"<color=red>结算消息</color>")
	dump(LZHDModel.GetFortunateInfo(),"<color=red>幸运星</color>")
	dump(LZHDModel.GetRich1Info(),"<color=red>1</color>")
	dump(LZHDModel.GetRich2Info(),"<color=red>2</color>")
	ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_move.audio_name)
	local win_info = LZHDLib.WhoWin(game_data.left_pai_id,game_data.right_pai_id)
	local total_1 = nil --需要回收的1
	local total_2 = nil --需要回收的2
	local total_3 = nil --不需要回收的
	local finish_pos = nil
	if win_info == LZHDComparisonEnum.Draw then
		total_1 = C.target_chip[1]
		total_2 = C.target_chip[3]
		total_3 = C.target_chip[2]
		finish_pos = 2
	elseif win_info == LZHDComparisonEnum.LongWin  then
		total_1 = C.target_chip[3]
		total_2 = C.target_chip[2]
		total_3 = C.target_chip[1]
		ExtendSoundManager.PlaySound(audio_config.big_battle.big_dragon.audio_name)
		finish_pos = 1
	else
		total_1 = C.target_chip[1]
		total_2 = C.target_chip[2]
		total_3 = C.target_chip[3]
		ExtendSoundManager.PlaySound(audio_config.big_battle.big_tiger.audio_name)
		finish_pos = 3
	end

	local chip_list = {}
	local seq = DoTweenSequence.Create()
	local t_p = nil
	if win_info == LZHDComparisonEnum.Draw then
		t_p = LZHDGamePanel.instance.long.position
	elseif win_info == LZHDComparisonEnum.HuWin then
		t_p = LZHDGamePanel.instance.hu.position
	else
		t_p = LZHDGamePanel.instance.long.position
	end
	for i = 1,#total_1 do
		local chip = total_1[i]
		
		seq:Append(chip.transform:DOMove(t_p,0.5))
		seq:AppendCallback(function ()
			chip.gameObject:SetActive(false)
		end)
		seq:AppendInterval(-0.5)
	end
	seq:AppendInterval(0.5)
	seq:AppendCallback(
		function ()
			local obj = newObject("LH_js_gx",LZHDGamePanel.instance.transform)
			obj.transform.position = t_p
			GameObject.Destroy(obj,2)
			if win_info == LZHDComparisonEnum.Draw then
				local obj2 = newObject("LH_js_gx",LZHDGamePanel.instance.transform)
				obj2.transform.position = LZHDGamePanel.instance.hu.position
				GameObject.Destroy(obj,3)
			end

			local total = 0
			for i = 1,#total_1 do
				if total_1[1].value then
					total = total + total_1[i].value
				end
			end
			for i = 1,#total_2 do
				if total_2[i].value then
					total = total + total_2[i].value
				end
			end
			for i = 1,#total_3 do
				if total_3[i].value then
					total = total + total_3[i].value
				end
			end

			local award_value_total = 0
			award_value_total = award_value_total + settlement_data.award_value
			for k , v in pairs(settlement_data.player_settle_data) do
				award_value_total = award_value_total + v.award_value
			end

			if award_value_total > total then
				local v = award_value_total - total
				local chip_value = LZHDChip.GetChipValues(v)
				for ii = 1,#chip_value do
					local chip = LZHDChip.GetChip(chip_value[ii])
					chip.transform.position = total_1[1].transform.position
					total_1[#total_1+1] = chip
				end
			end
		end
	)
	seq:AppendInterval(1.5)
	seq:AppendCallback(
		function ()
			local _seq = DoTweenSequence.Create()
			for i = 1,#total_1 do
				local chip = total_1[i]
				chip.gameObject:SetActive(true)
				chip_list[#chip_list + 1] = chip
				local pos = C.GetTargetPos(finish_pos)
				_seq:Append(chip.transform:DOLocalMove(pos,0.6))
				_seq:AppendInterval(-0.6)
			end
			_seq:AppendInterval(0.6)
		end
	)

	local seq2 = DoTweenSequence.Create()
	local t_p1 = nil
	if win_info == LZHDComparisonEnum.Draw then
		t_p1 = LZHDGamePanel.instance.hu.position
	elseif win_info == LZHDComparisonEnum.HuWin then
		t_p1 = LZHDGamePanel.instance.hu.position
	else
		t_p1 = LZHDGamePanel.instance.long.position
	end
	for i = 1,#total_2 do
		local chip = total_2[i]
		seq2:Append(chip.transform:DOMove(t_p1,0.5))
		seq2:AppendCallback(function ()
			for i = 1,#total_2 do
				local chip = total_2[i]
				chip.gameObject:SetActive(false)
			end
		end)
		seq2:AppendInterval(-0.5)
	end
	seq2:AppendInterval(2)
	seq2:AppendCallback(
		function ()
			local _seq = DoTweenSequence.Create()
			for i = 1,#total_2 do
				local chip = total_2[i]
				chip.gameObject:SetActive(true)
				chip_list[#chip_list + 1] = chip
				local pos = C.GetTargetPos(finish_pos)
				_seq:Append(chip.transform:DOLocalMove(pos,0.6))
				_seq:AppendInterval(-0.6)
			end
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_move.audio_name)
			_seq:AppendInterval(0.6)
		end
	)
	seq2:AppendInterval(1)
	seq2:AppendCallback(
		function ()
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_chip_move.audio_name)
			local re = C.OnSignChips(chip_list)
			local chip_my = C.FindChip(re,settlement_data.award_value)
			C.ChipFly(chip_my,settlement_data.award_value,1)

			local rich1_win =  settlement_data.player_settle_data[LZHDModel.GetRich1Info().player_id].award_value
			local chip_rich1 = C.FindChip(re,rich1_win)
			C.ChipFly(chip_rich1,rich1_win,2)

			-- local rich2_win =  settlement_data.player_settle_data[LZHDModel.GetRich2Info().player_id].award_value
			-- local chip_rich2 = C.FindChip(re,rich2_win)
			-- C.ChipFly(chip_rich2,rich2_win,3)

			if settlement_data.player_settle_data[LZHDModel.GetFortunateInfo().player_id] then
				local fortunate_win =  settlement_data.player_settle_data[LZHDModel.GetFortunateInfo().player_id].award_value
				local chip_fortunate = C.FindChip(re,fortunate_win)
				C.ChipFly(chip_fortunate,fortunate_win,4)
				local other = {}
				for i = 1,#re do
					if re[i].isUsed == false then
						other[#other+1] = re[i].chip
					end
				end
				for i = 1,#total_3 do
					other[#other+1] = total_3[i]
				end
				C.ChipFly(other,fortunate_win,5)
			end
			
			C.target_chip[1] = {}
			C.target_chip[2] = {}
			C.target_chip[3] = {}
		end
	)
end

--将桌子上的CHIP 放入缓冲池
function C.DeskChipToPool()
	C.desk_chip_list = C.desk_chip_list or {}
	for i = 1,#C.desk_chip_list do
		C.SaveChipToPool(C.desk_chip_list[i])
	end
	C.desk_chip_list = {}
end

--标注所有的筹码
function C.OnSignChips(chips_list)
	local re = {}
	for k , v in pairs(chips_list) do
		local data = {}
		data.chip = v
		data.isUsed = false
		re[#re+1] = data
	end
	table.sort(re,function (a,b)
		return a.chip.value > b.chip.value
	end)
	return re
end

--冲筹码池子里面分别需要用来做动画的部分
function C.FindChip(chips_list_with_sign,target_value)
	local re = {}
	local curr_value = 0
	local index = 1
	while curr_value < target_value and chips_list_with_sign[index] do
		local data = chips_list_with_sign[index]
		if data.isUsed == false and curr_value + data.chip.value < target_value then
			data.isUsed = true
			re[#re+1] = data.chip
			curr_value = curr_value + data.chip.value
		end
		index = index + 1
	end
	if #re == 0 then
		local chip_data = C.GetChipValues(target_value)
		for i = 1,#chip_data do
			local chip = C.GetChip(chip_data[i])
			chip.transform.position = C.GetTargetPos(finish_pos)
			C.desk_chip_list[#C.desk_chip_list+1] = chip
			chip.transform:SetParent(LZHDGamePanel.instance.ChipNode)
			re[#re+1] = chip
		end
	end
	return re
end

--筹码飞向玩家  1,我投注 ；2,富豪1 投注 ；3,富豪2 ；4,幸运星投注；5,其他玩家投注
function C.ChipFly(chip_lists,chip_value,target_index)
	local seq = DoTweenSequence.Create()
	local target_pos = nil
	for i = 1,#chip_lists do
		local chip = chip_lists[i]
		
		if target_index == 1 then
			target_pos = LZHDGamePanel.instance.my_node.transform.position
		elseif target_index == 2 then
			target_pos = LZHDGamePanel.instance.rich1.transform.position
		elseif target_index == 3 then
			target_pos = LZHDGamePanel.instance.rich2.transform.position
		elseif target_index == 4 then
			target_pos = LZHDGamePanel.instance.fortunately.transform.position
		else
			target_pos = LZHDGamePanel.instance.other.transform.position
		end
		seq:Append(chip.transform:DOMove(target_pos,0.6))
		seq:AppendCallback(function ()
			C.SaveChipToPool(chip)
		end)
		seq:AppendInterval(-0.6)
	end
	seq:AppendInterval(0.7)
	seq:AppendCallback(function ()
		if target_index < 5 and target_pos then
			Event.Brocast("lzhd_jingbi_info_change")
			ExtendSoundManager.PlaySound(audio_config.big_battle.big_coin_get.audio_name)
			CommonEffects.PlayAddGold( LZHDGamePanel.instance.ChipNode,target_pos)
			CommonAnim.FlyGoldNum(target_pos,chip_value,function ()
			end)
		end
	end)
end

--断线刷新
function C.RefreshChips()
	local data = LZHDModel.data.bet_data.total_bet_data
	for i = 1,3 do
		local chip_value = LZHDChip.GetChipValues(data[i])
		for ii = 1,#chip_value do
			local chip = LZHDChip.GetChip(chip_value[ii])
			LZHDChip.CreateChipInDesk(chip,i)
		end
	end
end