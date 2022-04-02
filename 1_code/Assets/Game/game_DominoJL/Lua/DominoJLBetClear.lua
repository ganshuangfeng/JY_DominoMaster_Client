-- 创建时间:2021-11-24
-- Panel:DominoJLBetClear
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

DominoJLBetClear = basefunc.class()
local C = DominoJLBetClear
C.name = "DominoJLBetClear"
local instance

function C.Create(data)
	if not DominoJLModel.data or not DominoJLModel.data.s2cSeatNum or not next(DominoJLModel.data.s2cSeatNum) then
		return
	end
	if instance then
		instance:MyExit()
	end
	instance = C.New(data)
	C.Instance = instance
	return instance
end

function C.Close()
	if not instance then
		return
	end
	instance:MyExit()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_fg_ready_response"] = basefunc.handler(self, self.on_fg_ready_response)
    self.lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.on_fg_huanzhuo_response)
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
	instance = nil
	C.Instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	self.data = data
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local prefab_name
	self.isWin = DominoJLModel.data.seat_num == self.data.settlement_info.winner
	if self.isWin then
		ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_win.audio_name)
		prefab_name = "DominoJLBetClear_Win"
	else
		ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_lose.audio_name)
		prefab_name = "DominoJLBetClear_Lose"
	end

	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:PlayCD()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.next_btn.onClick:AddListener(
		function ()
			if DominoJLModel.CheckBrokeProcess() then
				DominoJLGamePanel.Instance:RunBrokeProcess()
				return
			end
			Network.SendRequest("fg_ready")
		end
	)

	self.change_btn.onClick:AddListener(
		function ()
			if DominoJLModel.CheckBrokeProcess() then
				DominoJLGamePanel.Instance:RunBrokeProcess()
				return
			end
			Network.SendRequest("fg_huanzhuo")
		end
	)

	self.quit_btn.onClick:AddListener(
		function ()
			Network.SendRequest("fg_quit_game")
		end
	)
end

function C:RemoveListenerGameObject()
	self.next_btn.onClick:RemoveAllListeners()
	self.change_btn.onClick:RemoveAllListeners()
	self.quit_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
	self:SetCDTxt("")
	self.language_player_txt.text = GLL.GetTx(60016)
	self.language_point_txt.text = GLL.GetTx(60017)
	self.language_multiple_txt.text = GLL.GetTx(60018)
	self.language_bet_txt.text = GLL.GetTx(60019)
	self.language_profit_txt.text = GLL.GetTx(60020)
	self.change_txt.text = GLL.GetTx(60022)
	self.next_txt.text = GLL.GetTx(60015)
	

	local find_point_by_seat = function (seat_num)
		for i = 1,#self.data.settlement_info.remain_pai do
			if self.data.settlement_info.remain_pai[i].seat_num == seat_num then
				local pai = self.data.settlement_info.remain_pai[i].pai
				local point = 0
				for ii = 1,#pai do
					local p = DominoJLLib.GetDataById(pai[ii])
					point = point + p[1] + p[2]
				end
				return point
			end
		end
	end

	local rateStr = {
		"Single","Double","Triple","Quatra","Penta"
	}

	local setPlayerInfo = function (playerInfo,i)
		if playerInfo and next(playerInfo) then
			local temp_ui = {}
			local obj = GameObject.Instantiate(self.item,self.Content)
			obj.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.player_name_txt.text = OmitName(playerInfo.name) 
			SetHeadImg(playerInfo.head_link, temp_ui.head_img)

			temp_ui.point_txt.text = find_point_by_seat(i)
			local rateTxt = rateStr[self.data.settlement_info.rate] or self.data.settlement_info.rate
			temp_ui.rate_txt.text = rateTxt
			temp_ui.init_stake_txt.text =  StringHelper.ToCash(self.data.settlement_info.init_stake) 

			local score = StringHelper.ToCash(self.data.settlement_info.scores[i])
			if DominoJLModel.data.seat_num == self.data.settlement_info.winner then
				if self.data.settlement_info.scores[i] > 0 then
					temp_ui.earnings_txt.text = string.format("<color=#fc401bff>+%s</color>",score)
				else
					temp_ui.earnings_txt.text = string.format("<color=#d66c21ff>-%s</color>",score)
				end
			else
				if self.data.settlement_info.scores[i] > 0 then
					temp_ui.earnings_txt.text = string.format("<color=#ef9420ff>+%s</color>",score)
				else
					temp_ui.earnings_txt.text = string.format("<color=#4960a1ff>-%s</color>",score)
				end
			end

			local pai = self.data.settlement_info.remain_pai[i].pai
			for ii = 1,#pai do
				local cardData = DominoJLLib.GetDataById(pai[ii])
				local card = DominoJLCard.Create({cardData = cardData,parent = temp_ui.card_node})
				card.transform.localScale = Vector3.New(0.3,0.3,0.3)
			end
		end
	end

	Network.SendRequest("fg_get_settlement_players_info",nil,"",function (data)
		if not IsEquals(self.gameObject) then
			return
		end
		if data.result == 0 then
			if data.settlement_players_info then
				for i = 1,#data.settlement_players_info do
					if i == DominoJLModel.data.seat_num then
						local playerInfo = data.settlement_players_info[i]
						setPlayerInfo(playerInfo,i)
					end
				end
	
				
				for i = 1,#data.settlement_players_info do
					if i ~= DominoJLModel.data.seat_num then
						local playerInfo = data.settlement_players_info[i]
						setPlayerInfo(playerInfo,i)
					end
				end
			end
		end
		self:MyRefresh()
	end)
end

function C:MyRefresh()
end

function C:on_fg_ready_response(data)
	if data.result == 0 then
		self:MyExit()
	end
end

function C:on_fg_huanzhuo_response(data)
	if data.result == 0 then
		self:MyExit()
	end
end

function C:PlayCD()
	--没有破产或者在托管状态正常结算倒计时
	if not DominoJLModel.CheckBrokeProcess() or DominoJLModel.CheckMeIsAutoState() then
		local seq = DoTweenSequence.Create()
		local t = 5
		for i = 0, 4 do
			seq:InsertCallback(i,function ()
				self:SetCDTxt(t)
				t = t -1
			end)
		end
	end
end

function C:SetCDTxt(cd)
	if not cd then
		return
	end
	if IsEquals(self.cd_txt) then
		self.cd_txt.text = cd
	end
end