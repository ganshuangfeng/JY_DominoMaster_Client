-- 创建时间:2021-11-08
-- Panel:LudoDesk
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

LudoDesk = basefunc.class()
local C = LudoDesk
C.name = "LudoDesk"
local instance

--[[
	数据
	--棋子
	pieceMap = {
		[CSeatNum] = {
			[id] = {
				id,
				place,
				CSeatNum,
				piece,
			},
			[id] = {
				id,
				place,
				CSeatNum,
				piece,
			},
		}
	}

]]

--[[
	data = {
		parent
	}
]]
function C.Create(data)
	instance = instance or C.New(data)
	LudoDesk.Instance = instance
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self:CloseUpdate()
	for i = 1, 4 do
		self:ClearPiece(i)
	end

	self:ClearPlacePieceNum()
	self:ClearSafetyZone()
	self:ClearPieceNum()

	instance = nil
	LudoDesk.Instance = nil
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	LudoDesk.Instance = self
	ExtPanel.ExtMsg(self)
	local parent = data.parent or GameObject.Find("Ludo3DNode")
	self.gameObject = newObject(C.name, parent)
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitData()
	self:InitUI()
	self:CreateUpdata()

end

function C:InitData()
	
end

function C:InitUI()
	self:InitSafetyZone()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:CreateUpdata()
	self.update = Timer.New(function ()
		self:Update()
	end,0.02,-1,false,false)
	self.update:Start()
end

function C:Update()
end

function C:CloseUpdate()
	if self.update then
		self.update:Stop()
	end
	self.update = nil
end

function C:GetPiece(CSeatNum)
	if not self.pieceMap
	or not next(self.pieceMap)
	or not CSeatNum
	or not self.pieceMap[CSeatNum]
	or not next(self.pieceMap[CSeatNum]) then
		return
	end
	return self.pieceMap[CSeatNum]
end

--清空棋子 CSeatNum：客户端位置
function C:ClearPiece(CSeatNum)
	if not self.pieceMap
	or not next(self.pieceMap)
	or not CSeatNum
	or not self.pieceMap[CSeatNum]
	or not next(self.pieceMap[CSeatNum]) then
		return
	end
	for id, piece in pairs(self.pieceMap[CSeatNum]) do
		piece.piece:MyExit()
	end
	self.pieceMap[CSeatNum] = {}
end

--创建棋子 CSeatNum：客户端座位号,id：棋子id,place：棋子位置
function C:CreatePiece(CSeatNum,id,place)
	local data = {
		CSeatNum = CSeatNum,
		id = id,
		place = place,
	}
	local piece = basefunc.deepcopy(data)
	piece.piece = LudoPiece.Create({parent = self.PieceNode,data = data})
	return piece
end

--刷新棋盘固定位置的棋子的位置和大小
function C:SetDeskIndexPiecePS(index)
	local func = function (CSeatNum,id,playerCount,playerIndex,pieceIndex,pieceNum)
		if not self.pieceMap or not next(self.pieceMap) or not self.pieceMap[CSeatNum] or not self.pieceMap[CSeatNum][id] then
			return
		end
		local piece = self.pieceMap[CSeatNum][id]
		local d = LudoLib.GetPiecePosAndScale(CSeatNum,piece.place,id,playerCount,playerIndex,pieceIndex)
		local _index = LudoLib.GetPiecePosIndex(CSeatNum,piece.place)
		if index[1] == _index[1] and index[2] == _index[2] then
			piece.piece:SetScale(d.scale)
			piece.piece:SetPosition(d.pos)
			piece.piece:SetRenderQueue(piece.piece:GetDefaultRenderQueue())
		end
	end
	self:ErgodicPlacePieceNum(func)
end

--刷新棋子 CSeatNum：玩家客户端座位号
function C:RefreshPiece(CSeatNum)
	if not LodingModel or not LudoModel.data or not LudoModel.data.piece or not next(LudoModel.data.piece) then
		self:RefreshPlacePieceNum()
		self:RefreshPieceByPlacePieceNum()
		self:RefreshSafety()
		self:RefreshPieceChooseState(CSeatNum)
		self:ClearPiece()
		return
	end
	local pieces = LudoModel.data.piece[LudoModel.data.seatNum[CSeatNum]]
	if not pieces then
		return
	end

	local same = true
	if not self.pieceMap
	or not next(self.pieceMap) then
		same = false
	else
		for id, place in ipairs(pieces) do
			if not self.pieceMap[CSeatNum]
			or not next(self.pieceMap[CSeatNum])
			or not self.pieceMap[CSeatNum][id]
			or not self.pieceMap[CSeatNum][id].place ~= place then
				same = false
				break
			end
		end
	end

	--完全相同
	if same then
		return
	end

	self.pieceMap = self.pieceMap or {}
	self.pieceMap[CSeatNum] = self.pieceMap[CSeatNum] or {}
	for id, place in ipairs(pieces) do
		if not self.pieceMap[CSeatNum][id] then
			self.pieceMap[CSeatNum][id] = self:CreatePiece(CSeatNum,id,place)
		else
			self.pieceMap[CSeatNum][id].piece:SetPlace(CSeatNum,place)
			self.pieceMap[CSeatNum][id].place = place
		end
	end
	self:RefreshPlacePieceNum()
	self:RefreshPieceByPlacePieceNum()
	self:RefreshSafety()
	self:RefreshPieceNum()
	self:RefreshPieceChooseState(CSeatNum)
end

--遍历位置上的所有棋子
function C:ErgodicPlacePieceNum(func)
	for index, v in pairs(self.placePieceNum) do
		local playerCount = 0
		local maxCSeatNum = 0
		for CSeatNum, v1 in pairs(v) do
			playerCount = playerCount + 1
			if CSeatNum > maxCSeatNum then
				maxCSeatNum = CSeatNum
			end
		end
		local playerIndex = 0
		for CSeatNum = 1, maxCSeatNum do
			if v[CSeatNum] then
				--位置上有这个玩家
				playerIndex = playerIndex + 1
				local pieceNum = #v[CSeatNum]
				for pieceIndex, id in ipairs(v[CSeatNum]) do
					func(CSeatNum,id,playerCount,playerIndex,pieceIndex,pieceNum)
					-- dump({CSeatNum = CSeatNum, id = id,playerCount = playerCount,playerIndex = playerIndex,pieceIndex = pieceIndex,pieceNum = pieceNum},"<color=yellow>根据当前格子上的棋子设置棋子状态</color>")
				end
			end
		end
	end
end

--根据格子上的棋子个数改变棋子形态
function C:RefreshPieceByPlacePieceNum()
	local func = function (CSeatNum,id,playerCount,playerIndex,pieceIndex,pieceNum)
		if not self.pieceMap or not next(self.pieceMap) or not self.pieceMap[CSeatNum] or not self.pieceMap[CSeatNum][id] then
			return
		end
		local piece = self.pieceMap[CSeatNum][id]
		local d = LudoLib.GetPiecePosAndScale(CSeatNum,piece.place,id,playerCount,playerIndex,pieceIndex)
		piece.piece:SetScale(d.scale)
		piece.piece:SetPosition(d.pos)
		piece.piece:SetRenderQueue(piece.piece:GetDefaultRenderQueue())
	end
	self:ErgodicPlacePieceNum(func)
end

--更新每一个格子上的棋子数量
function C:RefreshPlacePieceNum()
	if not LudoModel.data or not LudoModel.data.piece or not next(LudoModel.data.piece) then
		self.placePieceNum = {}
		return
	end
	self.placePieceNum = {}
	local t
	for seat_num, v in pairs(LudoModel.data.piece) do
		local CSeatNum = LudoModel.data.s2cSeatNum[seat_num]
		for id, place in pairs(v) do
			t = LudoLib.GetPiecePosIndex(CSeatNum,place)
			local index = t[1] .. "_" .. t[2]
			self.placePieceNum[index] = self.placePieceNum[index] or {}
			self.placePieceNum[index][CSeatNum] = self.placePieceNum[index][CSeatNum] or {}
			self.placePieceNum[index][CSeatNum][#self.placePieceNum[index][CSeatNum]+1] = id
		end
	end
end

--清空格子上的棋子数量
function C:ClearPlacePieceNum()
	self.placePieceNum = nil
end

--刷新棋子的选择状态 CSeatNum：客户端座位号,
function C:RefreshPieceChooseState(CSeatNum)
	if not CSeatNum 
	or not self.pieceMap
	or not next(self.pieceMap)
	or not self.pieceMap[CSeatNum]
	or not next(self.pieceMap[CSeatNum])  
	or not LudoModel.data.s2cSeatNum
	or not LudoModel.data.cur_p
	then
		return
	end

	--玩家自己，权限不在，状态不在，不是自己摇的骰子，棋子在终点起点和普通位置，摇到6和1-5，
	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	local roll = LudoModel.data.roll
	if LudoModel.data.cur_p ~= LudoModel.data.seat_num
	or cur_p ~= CSeatNum
	or LudoModel.data.status ~= LudoModel.Status.piece
	or LudoModel.data.statusMini ~= LudoModel.StatusMini.waitPiece
	or roll.seat_num ~= LudoModel.data.cur_p then
		for id, piece in pairs(self.pieceMap[CSeatNum]) do
			piece.piece:SetChooseState(false)
		end
		return
	end

	local endCount = 0
	local startCount = 0
	local runCount = 0
	local sprintCount = 0
	local canSprintCount = 0

	for id, piece in pairs(self.pieceMap[CSeatNum]) do
		local posState = LudoLib.GetPiecePosState(CSeatNum,piece.place)
		if posState == "start" then
			startCount = startCount + 1
		elseif posState == "run" then
			runCount = runCount + 1
		elseif posState == "sprint" then
			sprintCount = sprintCount + 1
			if LudoLib.GetPieceSprintNum(CSeatNum,piece.place) >= roll.point then
				canSprintCount = canSprintCount + 1
			end
		elseif posState == "end" then
			endCount = endCount + 1
		end
	end

	local is_some_one_can_choose = false
	for id, piece in pairs(self.pieceMap[CSeatNum]) do
		local b = LudoLib.GetPieceChooseState(CSeatNum,piece.place,roll.point,startCount, runCount, canSprintCount)
		if b then
			is_some_one_can_choose = true
		end
		piece.piece:SetChooseState(b)
	end

	if is_some_one_can_choose then
		local is_all_in_start = true
		for id, piece in pairs(self.pieceMap[CSeatNum]) do
			if piece.piece.data.place > 1 then
				is_all_in_start = false
			end
		end
		if not is_all_in_start then
			ExtendSoundManager.PlaySound(audio_config.ludo.ludo_chess_chose.audio_name)
		end
	end
end

--设置棋子的选择状态 CSeatNum：客户端座位号,b = true or false
function C:SetPieceChooseState(CSeatNum,b)
	if not CSeatNum
	or not self.pieceMap
	or not next(self.pieceMap)
	or not self.pieceMap[CSeatNum]
	or not next(self.pieceMap[CSeatNum]) then
		return
	end
	for id, piece in pairs(self.pieceMap[CSeatNum]) do
		piece.piece:SetChooseState(b)
	end
end

function C:RefreshSafetyByKey(key)
	if not self.SafetyMap or not next(self.SafetyMap) or not self.SafetyMap[key] then
		return
	end

	if not self.placePieceNum or not next(self.placePieceNum) or not self.placePieceNum[key] then
		self.SafetyMap[key]:SetLightState(false)
		return
	end

	self.SafetyMap[key]:SetLightState(true)
end

--刷新安全区状态
function C:RefreshSafety()
	if not self.SafetyMap or not next(self.SafetyMap) then
		return
	end
	if not self.placePieceNum or not next(self.placePieceNum) then
		for k, v in pairs(self.SafetyMap) do
			v:SetLightState(false)
		end
		return
	end

	for k, v in pairs(self.SafetyMap) do
		if self.placePieceNum[k] then
			v:SetLightState(true)
		else
			v:SetLightState(false)
		end
	end
end

--初始化安全区
function C:InitSafetyZone()
	local safetyPos = LudoLib.GetSafetyPosIndex()
	self:ClearSafetyZone()
	self.SafetyMap = {}
	for i, v in ipairs(safetyPos) do
		local data = {
			parent = self.SafetyNode,
			data = {
				pos = v,
			}
		}

		local k = v[1] .. "_" .. v[2]
		self.SafetyMap[k] = LudoSafety.Create(data)
	end
end

--清空安全区
function C:ClearSafetyZone()
	if not self.SafetyMap or not next(self.SafetyMap) then
		return
	end

	for k, v in pairs(self.SafetyMap) do
		v:MyExit()
	end
	self.SafetyMap = nil
end

--设置棋子数量在棋子移动时 CSeatNum：客户端座位号,place：棋子位置
function C:SetPieceNumOnPlayPiece(CSeatNum,place)
	local t = LudoLib.GetPiecePosIndex(CSeatNum,place)
	local k = t[1] .. "_" .. t[2]
	local pieceNum = self:GetPieceNum(k,CSeatNum)
	if pieceNum and next(pieceNum) then
		self:SetPieceNum(k,CSeatNum,pieceNum.num - 1)
	end
	self:SetPieceNumByKey(k)
end

--获取棋子数量 key：pieceNumMap的key,CSeatNum：客户端座位号
function C:GetPieceNum(key,CSeatNum)
	if not self.pieceNumMap or not next(self.pieceNumMap) then
		return
	end

	if not self.pieceNumMap[key] or not next(self.pieceNumMap[key]) or not self.pieceNumMap[key][CSeatNum] or not next(self.pieceNumMap[key][CSeatNum]) then
		return
	end

	return self.pieceNumMap[key][CSeatNum]
end

--设置棋子数量 key：pieceNumMap的key,CSeatNum：客户端座位号,num：数量
function C:SetPieceNum(key,CSeatNum,num)
	local pieceNum = self:GetPieceNum(key,CSeatNum)
	if not pieceNum then
		return
	end

	if num > 1 then
		pieceNum.num = num
		pieceNum.pieceNum:SetNum(num)
	else
		pieceNum.pieceNum:MyExit()
		self.pieceNumMap[key][CSeatNum] = {}
	end
end

--设置棋子数量通过key  k：pieceNumMap的key
function C:SetPieceNumByKey(k)
	local posState = LudoLib.GetPiecePosStateByKey(k)
	if posState == "start" or posState == "end" then
		return
	end
	local playerCount = 0
	local maxCSeatNum = 0
	local v = self.placePieceNum[k]
	if not v then
		return
	end
	for CSeatNum, v1 in pairs(v) do
		playerCount = playerCount + 1
		if CSeatNum > maxCSeatNum then
			maxCSeatNum = CSeatNum
		end
	end

	local playerIndex = 0
	for CSeatNum = 1, maxCSeatNum do
		if v[CSeatNum] and self.pieceMap[CSeatNum] then
			--位置上有这个玩家
			playerIndex = playerIndex + 1
			local num = #v[CSeatNum]
			if num > 1 then
				local d = LudoLib.GetPieceRunSprintPosAndScale(k,playerCount,playerIndex)
				local place = LudoLib.GetPlaceByKey(k,CSeatNum)
				local pos
				for key, value in pairs(self.pieceMap[CSeatNum]) do
					if value.place == place then
						pos = value.piece:GetNumPos()
					end
				end
				d.pos = pos
				if not self.pieceNumMap[k]
				or not next(self.pieceNumMap[k])
				or not self.pieceNumMap[k][CSeatNum]
				or not next(self.pieceNumMap[k][CSeatNum]) then
					self.pieceNumMap[k] = self.pieceNumMap[k] or {}
					self.pieceNumMap[k][CSeatNum] = self.pieceNumMap[k][CSeatNum] or {}
					local data = {
						parent = self.NumNode,
						data = {
							num = num,
							pos = d.pos,
							scale = d.scale,
							CSeatNum = CSeatNum,
						}
					}
					self.pieceNumMap[k][CSeatNum].pieceNum = LudoPieceNum.Create(data)
				end
				self.pieceNumMap[k][CSeatNum].num = num
				self.pieceNumMap[k][CSeatNum].pieceNum:SetNum(num)
				self.pieceNumMap[k][CSeatNum].pieceNum:SetPosition(d.pos)
				self.pieceNumMap[k][CSeatNum].pieceNum:SetScale(d.scale)
			else
				if self.pieceNumMap[k]
				and next(self.pieceNumMap[k])
				and self.pieceNumMap[k][CSeatNum]
				and next(self.pieceNumMap[k][CSeatNum]) then
					self.pieceNumMap[k][CSeatNum].pieceNum:MyExit()
					self.pieceNumMap[k][CSeatNum] = {}
				end
			end
		end
	end
end

--刷新棋子数量
function C:RefreshPieceNum()
	-- dump(self.placePieceNum,"<color=yellow>self.placePieceNum ?????????????</color>")
	-- dump(self.pieceNumMap,"<color=yellow>self.pieceNumMap ?????????????</color>")
	if not self.placePieceNum or not next(self.placePieceNum) then
		self:ClearPieceNum()
		return
	end

	local checkIsSame = function()
		if not self.pieceNumMap or not next(self.pieceNumMap) then
			return false
		else
			for k, v in pairs(self.placePieceNum) do
				if not self.pieceNumMap[k] then
					return false
				else
					for CSeatNum, pieces in pairs(v) do
						if not self.pieceNumMap[CSeatNum]
						or self.pieceNumMap[CSeatNum].num ~= #pieces then
							return false
						end
					end
				end
			end
		end
		return true
	end

	--完全相同
	if checkIsSame() then return end

	self.pieceNumMap = self.pieceNumMap or {}
	for k, v in pairs(self.pieceNumMap) do
		local posState = LudoLib.GetPiecePosStateByKey(k)
		if posState == "start" or posState == "end" then
			for CSeatNum, pieceNum in ipairs(v) do
				if next(pieceNum) and pieceNum.pieceNum then
					pieceNum.pieceNum:MyExit()
				end
				pieceNum = {}
			end
			self.pieceNumMap[k] = {}
		else
			if not self.placePieceNum[k] then
				for CSeatNum, pieceNum in ipairs(v) do
					if next(pieceNum) and pieceNum.pieceNum then
						pieceNum.pieceNum:MyExit()
					end
					pieceNum = {}
				end
				self.pieceNumMap[k] = {}
			else
				for CSeatNum, pieceNum in ipairs(v) do
					if not self.placePieceNum[k][CSeatNum] or #self.placePieceNum[k][CSeatNum] == 1 then
						if next(pieceNum) and pieceNum.pieceNum then
							pieceNum.pieceNum:MyExit()
						end
						pieceNum = {}
					end
				end
			end
		end
	end

	self.placePieceNum = self.placePieceNum or {}
	for k, v in pairs(self.placePieceNum) do
		local posState = LudoLib.GetPiecePosStateByKey(k)
		if posState == "start" or posState == "end" then
			if self.pieceNumMap[k] and next(self.pieceNumMap[k]) then
				for CSeatNum, pieceNum in pairs(self.pieceNumMap[k]) do
					if next(pieceNum) and pieceNum.pieceNum then
						pieceNum.pieceNum:MyExit()
					end
					pieceNum = {}
				end
			end
			self.pieceNumMap[k] = nil
		else
			self:SetPieceNumByKey(k)
		end
	end
end

--清空棋子数量
function C:ClearPieceNum()
	if not self.pieceNumMap or not next(self.pieceNumMap) then
		return
	end

	for k, v in pairs(self.pieceNumMap) do
		for CSeatNum, pieceNum in pairs(v) do
			if pieceNum and next(pieceNum) then
				pieceNum.pieceNum:MyExit()
			end
		end
	end
	self.pieceNumMap = nil
end

--是否踩到了其他旗子 target_place：目标位置, CSeatNum：客户端座位号
function C:GetTrampleData(target_place,CSeatNum)
	local other_num = 0
	local other_seatNum = nil
	local other_piece_id = nil
	local t = LudoLib.GetPiecePosIndex(CSeatNum,target_place)
	--安全点 安全点不检测踩棋子得机制
	local safe_map = LudoLib.GetSafetyPosIndex()
	for i = 1,#safe_map do
		if safe_map[i][1] == t[1] and safe_map[i][2] == t[2] then
			return 
		end
	end
	local index = t[1] .. "_" .. t[2]
	if self.placePieceNum and self.placePieceNum[index] then
		for k , v in pairs(self.placePieceNum[index]) do
			if k ~= CSeatNum then
				other_num = other_num + 1
				other_seatNum = k
				other_piece_id = v[1]
			end
		end
	end
	if other_num == 1 then
		return {CSeatNum = other_seatNum,pieceId = other_piece_id}
	end
end
