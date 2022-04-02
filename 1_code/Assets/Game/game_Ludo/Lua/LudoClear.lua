-- 创建时间:2021-11-11
-- Panel:LudoClear
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

LudoClear = basefunc.class()
local C = LudoClear
C.name = "LudoClear"

local instance
function C.Create(data)
	if instance then
		return instance
	end
	instance = C.New(data)
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
	self.lister["fg_ready_response"] = basefunc.handler(self, self.on_fg_ready_response)
	self.lister["LudoGamePanelExit"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.MainTimer then
		self.MainTimer:Stop()
	end
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	self.data = data
	local winner = self.data.settlement_info.winner
	local my_seat_num = LudoModel.data.seat_num
	local prefab_name = "LudoClear_Lose"

	for i = 1,#winner do
		if my_seat_num == winner[i] then
			prefab_name = "LudoClear_Win"
			break
		end
	end

	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	
	local game_id = LudoModel.data.game_id
	local info = MainModel.GetInfoByGameID(game_id)
	--如果玩家不满足当前场次的条件
	if MainModel.UserInfo.jing_bi < info.limit_min then
		SysBrokeSubsidyManager.RunBrokeProcess()
	else
		-- local left_t = 10
		-- self.MainTimer = Timer.New(
		-- 	function ()
		-- 		left_t = left_t - 1
		-- 		self.back_txt.text = GLL.GetTx(60014).."(" .. left_t .. ")"
		-- 		if left_t <= 0 then
		-- 			Network.SendRequest("fg_quit_game")
		-- 		end
		-- 	end
		-- ,1,10)
		-- self.MainTimer:Start()
	end
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.next_btn.onClick:AddListener(
		function ()

			local info = MainModel.GetInfoByGameID(LudoModel.data.game_id)

			if MainModel.UserInfo.jing_bi >= info.limit_min then
				Network.SendRequest("fg_ready")
				--继续游戏
			else
				SysBrokeSubsidyManager.RunBrokeProcess()
			end
		end
	)

	self.back_btn.onClick:AddListener(function ()
		Network.SendRequest("fg_quit_game")
	end)
end

function C:RemoveListenerGameObject()
    self.next_btn.onClick:RemoveAllListeners()
    self.back_btn.onClick:RemoveAllListeners()
end
function C:InitUI()
	self.language_rank_txt.text = GLL.GetTx(60010)
	self.language_kill_txt.text = GLL.GetTx(60011)
	self.language_be_killed_txt.text = GLL.GetTx(60012)
	self.language_profit_txt.text = GLL.GetTx(60013)
	self.back_txt.text = GLL.GetTx(60014)
	self.next_txt.text = GLL.GetTx(60015)
	

	local m_data = LudoModel.data
	local data = self.data.settlement_info.scores
	dump(m_data.players_info,'<color=red>结算2</color>')
	local player_info = m_data.players_info
	local config = {
		"ludo_js_icon_01","ludo_js_icon_02","ludo_js_icon_03"
	}


	local get_rank_list = function ()
		local re = {}
		local all = {}
		local is_winer = function (seat)
			for i = 1,#self.data.settlement_info.winner do
				if self.data.settlement_info.winner[i] == seat then
					return true
				end
			end
			return false
		end
		for i = 1,#data do
			local seat = i
			local _data = {}
			local rank = i
			local seat_num = self.data.settlement_info.winner[rank]
			all[#all+1] = i
			if seat_num then
				_data.player_info = m_data.players_info[seat_num]
				_data.tread_data = self.data.settlement_info.tread_data[seat_num]
				_data.scores = self.data.settlement_info.scores[rank]
				re[#re+1] = _data
			end
		end
		local lose = {}
		for i = 1,#all do
			if is_winer(all[i]) then
				
			else
				lose[#lose+1] = all[i]
			end
		end

		for i = 1,#lose do
			local _data = {}
			local seat_num = lose[i]
			_data.player_info = m_data.players_info[seat_num]
			_data.tread_data = self.data.settlement_info.tread_data[seat_num]
			_data.scores = self.data.settlement_info.scores[#re + 1]
			re[#re+1] = _data
		end
		return re
	end

	local re = get_rank_list()
	dump(re,"<color=red>结算数据 +++++++++</color>")
	local rank_index = 0
	for i = 1,#re do
		local temp_ui = {}
		if re[i].player_info then
			rank_index = rank_index + 1
			local obj = GameObject.Instantiate(self.item,self.Content)
			LuaHelper.GeneratingVar(obj.transform,temp_ui)
			temp_ui.player_name_txt.text = re[i].player_info.name
			temp_ui.bunuh_txt.text =  re[i].tread_data.tread
			temp_ui.killed_txt.text = re[i].tread_data.treaded
			temp_ui.profit_txt.text = re[i].scores > 0 and "+".. StringHelper.ToCash(re[i].scores) or StringHelper.ToCash(re[i].scores)

			SetHeadImg(re[i].player_info.head_link, self.head_img)
			if rank_index < 3 then
				temp_ui.rank_img.sprite = GetTexture(config[rank_index])
				temp_ui.rank_img.gameObject:SetActive(true)
			else
				temp_ui.rank_img.gameObject:SetActive(false)
				temp_ui.rank_txt.text = 3
			end
			obj.gameObject:SetActive(true)
		end
		
	end
end

function C:MyRefresh()
end

function C:on_fg_ready_response(proto_name, data)
	if data.result == 0 then
		self:MyExit()
	end
end