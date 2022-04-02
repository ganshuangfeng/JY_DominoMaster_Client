local basefunc = require "Game/Common/basefunc"
QiuQiuChip = basefunc.class()
local C = QiuQiuChip
C.name = "QiuQiuChip"
local config = {

}
function C.InitConfig()
	local _c = {1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000,10000000000}
	for i = 1,#_c do
		for ii = 1,9 do
			config[#config+1] = ii * _c[i]
		end
	end
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


local bg_config = {"qiuqiu_cm_8_1","qiuqiu_cm_7_1","qiuqiu_cm_6_1","qiuqiu_cm_5_1","qiuqiu_cm_4_1","qiuqiu_cm_3_1","qiuqiu_cm_2_1","qiuqiu_cm_1_1"}
local color_config = {"#555555","#166210","#0F4793","#95310E","#55209D","#A002B1","#9B0013","#834107"}

C.InitConfig()
function C:ctor(data,parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or QiuQiuDesk.Instance.ChipNode
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
	if self.value <= 200 then
		c_index = 1
	elseif self.value <= 5000 then
		c_index = 2
	elseif self.value <= 100000 then
		c_index = 3
	elseif self.value <= 2000000 then
		c_index = 4
	elseif self.value <= 50000000 then
		c_index = 5
	elseif self.value <= 200000000 then
		c_index = 6
	elseif self.value <= 500000000 then
		c_index = 7
	else
		c_index = 8
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
	local init_lengh = 10
	for i = 1,#config do
		Timer.New(
			function ()
				for ii = 1,init_lengh do
					if QiuQiuDesk.Instance and IsEquals(QiuQiuDesk.Instance.WaitChipNode) then
						local obj = QiuQiuChip.Create({value = config[i]},QiuQiuDesk.Instance.WaitChipNode)
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
		obj.transform:SetParent(QiuQiuDesk.Instance.ChipNode)
		obj.gameObject:SetActive(true)
		return obj
	else
		return QiuQiuChip.Create({value = value},QiuQiuDesk.Instance.ChipNode)
	end
end

--回收一枚筹码到缓冲池子里面
function C.SaveChipToPool(chip)
	local value = chip.value
	local max = 20
	C.ChipPool = C.ChipPool or {}
	C.ChipPool[value] = C.ChipPool[value] or {}
	if #C.ChipPool[value] <= 20 then
		C.ChipPool[value][#C.ChipPool[value]+1] = chip
		chip.transform:SetParent(QiuQiuDesk.Instance.WaitChipNode)
	else
		chip:MyExit()
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
--丢
function C.DropChipAnimation(chip,ui_index)
	C.desk_chip_list = C.desk_chip_list or {}
	C.desk_chip_list[#C.desk_chip_list+1] = chip
	if QiuQiuGamePanel.Instance.playerList[ui_index] then
		chip.transform.position = QiuQiuGamePanel.Instance.playerList[ui_index].head_img.gameObject.transform.position
	else
		chip.transform.position = Vector3.zero
	end
	local target_pos = Vector3.New(math.random(-160,160),math.random(-10,80),0)
	local seq = DoTweenSequence.Create()
	seq:Append(chip.transform:DOMove(target_pos,0.6))
	Event.Brocast("DropChipAnimation_Finish",{value = chip.value})
end

--将桌子上的CHIP 放入缓冲池
function C.DeskChipToPool()
	C.desk_chip_list = C.desk_chip_list or {}
	for i = 1,#C.desk_chip_list do
		C.SaveChipToPool(C.desk_chip_list[i])
	end
	C.desk_chip_list = {}
end

--将桌子上的筹码回收到荷官中,然后重新分池
function C.DivideChips(pool_data,backcall)
	local pos_list = {Vector3.New(-160,100-20,0),Vector3.New(0,100-20,0),Vector3.New(160,100-20,0),Vector3.New(-240,-20,0),Vector3.New(-80,-20,0),Vector3.New(80,-20,0),Vector3.New(240,-20,0),}
	local seq = DoTweenSequence.Create()

	local w_chip = {}
	C.desk_chip_list = C.desk_chip_list or {}
	table.sort( C.desk_chip_list, function (a,b)
		return a.value > b.value
	end )

	for i = 1,#C.desk_chip_list do
		local data = {}
		data.chip = C.desk_chip_list[i]
		data.used = false
		w_chip[#w_chip+1] = data
	end

	local find_chip = function (value)
		local re = {}
		value = tonumber(value)
		for i = 1,#w_chip do
			--（排序是大的在前面）如果目标值比这个大
			if w_chip[i].used == false and value >= w_chip[i].chip.value then
				w_chip[i].used = true
				value = value - w_chip[i].chip.value
				w_chip[i].chip.transform:SetParent(QiuQiuGamePanel.Instance.ChipNode)
				re[#re+1] = w_chip[i].chip
			end
		end

		if #re == 0 then
			local chip_data = C.GetChipValues(value)
			for i = 1,#chip_data do
				local chip = C.GetChip(chip_data[i])
				chip.transform.position = QiuQiuGamePanel.Instance.croupier_node.transform.position
				C.desk_chip_list[#C.desk_chip_list+1] = chip
				chip.transform:SetParent(QiuQiuGamePanel.Instance.ChipNode)
				re[#re+1] = chip
			end
		end
		return re
	end

	if #pool_data == 1 then
		local value = math.floor(tonumber(pool_data[1].stake) / #pool_data[1].player)
		for i = 1,#pool_data[1].player do
			local chips = find_chip(value)
			local ui_pos = QiuQiuModel.data.s2cSeatNum[pool_data[1].player[i]]
			local target_pos = QiuQiuGamePanel.Instance.playerList[ui_pos].money_txt.gameObject.transform.position			
			for ii = 1,#chips do
				seq:Append(chips[ii].transform:DOMove(target_pos,0.6))
				seq:AppendCallback(
					function ()
						chips[ii].gameObject:SetActive(false)
					end
				)
				seq:AppendInterval(-0.59)

				if ii == #chips then
					seq:AppendCallback(
						function ()
							ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
						end
					)
					seq:AppendInterval(0.6)
					seq:AppendCallback(
						function ()
							CommonEffects.PlayAddGold(QiuQiuGamePanel.Instance.playerList[ui_pos].money_txt.gameObject.transform,target_pos)
							QiuQiuGamePanel.Instance.playerList[ui_pos]:AddChip(value)
							CommonAnim.FlyGoldNum(target_pos,value,function ()
							end)
							ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_coin_get.audio_name)
						end
					)
				end
			end
		end

		seq:AppendCallback(
			function ()
				C.DeskChipToPool()
				if backcall then
					backcall()
				end
			end
		)
	else
		for i = 1,#C.desk_chip_list do
			local obj = C.desk_chip_list[i]
			seq:Append(obj.transform:DOMove(QiuQiuGamePanel.Instance.croupier_node.transform.position,0.5))
			seq:AppendCallback(function ()
			end)
			seq:AppendInterval(-0.49)
		end
		ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
		seq:AppendInterval(0.6)
		local space = 2.2
		
		local CP = {}
		for i = 1,#pool_data do
			local chips = find_chip(pool_data[i].stake)
			table.sort(chips,function (a,b)
				return a.value < b.value
			end)
			CP[i] = chips
			for ii = 1,#chips do
				local base_pos = pos_list[i] + Vector3.New(0,(ii - 1) * space,0)
				local obj = chips[ii]
				obj.transform:SetAsLastSibling()
				seq:Append(obj.transform:DOMove(base_pos,0.5))
				seq:AppendInterval(-0.49)
			end
			seq:AppendCallback(function ()
				C.CreateChipTip(pool_data[i].stake,pos_list[i])
			end)
		end
		seq:AppendInterval(1.6)
		for i = 1,#CP do
			local value = math.floor(tonumber(pool_data[i].stake) / #pool_data[i].player)		
			local players = pool_data[i].player
			for ii = 1,#CP[i] do
				local seat = players[(ii % #players) + 1]
				local ui_pos = QiuQiuModel.data.s2cSeatNum[seat]
				local target_pos = QiuQiuGamePanel.Instance.playerList[ui_pos].money_txt.gameObject.transform.position
				seq:AppendCallback(
					function ()
						CP[i][ii].transform.localPosition = CP[i][1].transform.localPosition + Vector3.New(math.random(-20,20),math.random(-20,20),0)
						if IsEquals(C.chip_tips[i].gameObject) then
							C.chip_tips[i].gameObject:SetActive(false)
						end
					end
				)
				--seq:Append(CP[i][ii].transform:DOMove(first_pos,0.5))
				seq:AppendInterval(0.5)
				if ii == 1 then
					seq:AppendCallback(
						function ()
							ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_chip_move.audio_name)
						end
					)
				end
				seq:Append(CP[i][ii].transform:DOMove(target_pos,0.6))
				seq:AppendCallback(
					function ()
						if IsEquals(CP[i][ii].gameObject) then
							CP[i][ii].gameObject:SetActive(false)
						end
					end
				)
				seq:AppendInterval(-1.1)
				if ii == #CP[i] then
					seq:AppendInterval(1.1)
				end				
			end
			
			for ii = 1,#players do
				local seat = players[ii]
				local ui_pos = QiuQiuModel.data.s2cSeatNum[seat]
				local target_pos = QiuQiuGamePanel.Instance.playerList[ui_pos].money_txt.gameObject.transform.position
				seq:AppendInterval(0.02)
				seq:AppendCallback(
					function ()
						CommonEffects.PlayAddGold(QiuQiuGamePanel.Instance.playerList[ui_pos].money_txt.gameObject.transform,target_pos)
						QiuQiuGamePanel.Instance.playerList[ui_pos]:AddChip(value)
						CommonAnim.FlyGoldNum(target_pos,value,function ()
						end)
						ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_coin_get.audio_name)
					end
				)
			end
			
		end
		seq:AppendCallback(
			function ()
				C.DeskChipToPool()
				for i = 1,#C.chip_tips do
					destroy(C.chip_tips[i])
				end
				C.chip_tips = {}
				if backcall then
					backcall()
				end
			end
		)
	end

end

--创建一个显示具体筹码数量的
function C.CreateChipTip(value,position)
	C.chip_tips = C.chip_tips or {}
	local obj = newObject("QiuQiuChipTip",QiuQiuDesk.Instance.ChipNode)
	obj.transform.position = position
	obj.transform:Find("Text"):GetComponent("Text").text = StringHelper.ToCash(value)
	obj.transform:SetAsFirstSibling()
	C.chip_tips[#C.chip_tips+1] = obj
end

--通过断线重连得数据刷新
function C.RefreshByAllInfo()
	if QiuQiuModel.data.model_status == QiuQiuModel.Model_Status.gameover then
		return
	end

	C.InitChipPool()
	local paly_info = QiuQiuModel.data.play_info
	paly_info = paly_info or {}
	for k , v in pairs(paly_info) do
		local stake = tonumber(v.stake) +  tonumber(QiuQiuModel.data.init_stake)
		local each = math.floor(stake / 2)
		local each3 = stake - each
		if stake > 0 then
			for i = 1,2 do
				local chip_data = nil
				if i < 2 then
					chip_data = C.GetChipValues(each)
				else
					chip_data = C.GetChipValues(each3)
				end
				for ii = 1,#chip_data do
					local chip = C.GetChip(chip_data[ii])
					C.desk_chip_list = C.desk_chip_list or {}
					C.desk_chip_list[#C.desk_chip_list+1] = chip
					chip.transform.position = Vector3.New(math.random(-160,160),math.random(-10,80),0)
				end
			end
		end
	end
end