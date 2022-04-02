-- 创建时间:2021-11-11
-- Panel:DominoJLClear
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


-- "is_over"         = 1
-- -     "settlement_info" = {
-- -         "init_stake" = 200
-- -         "rate"       = 1
-- -         "remain_pai" = {
-- -             1 = {
-- -                 "pai" = {
-- -                     1 = 19
-- -                 }
-- -                 "seat_num" = 1
-- -             }
-- -             2 = {
-- -                 "pai" = {
-- -                     1 = 14
-- -                 }
-- -                 "seat_num" = 2
-- -             }
-- -             3 = {
-- -                 "pai" = {
-- -                     1 = 1
-- -                 }
-- -                 "seat_num" = 3
-- -             }
-- -             4 = {
-- -                 "pai" = {
-- -                 }
-- -                 "seat_num" = 4
-- -             }
-- -         }
-- -         "scores" = {
-- -             1 = -200
-- -             2 = -200
-- -             3 = -200
-- -             4 = 600
-- -         }
-- -         "winner"     = 4
-- -     }
-- -     "status_no"       = 81
-- - }

local basefunc = require "Game/Common/basefunc"

DominoJLClear = basefunc.class()
local C = DominoJLClear
C.name = "DominoJLClear"

function C.Create(data)
	if not DominoJLModel.data or not DominoJLModel.data.s2cSeatNum or not next(DominoJLModel.data.s2cSeatNum) then
		return
	end
	return C.New(data)
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
	if self.tx_prefab then
		destroy(self.tx_prefab)
	end
	if self.winNotice then
		destroy(self.winNotice)
	end
	self:RemoveListener()
	destroy(self.gameObject)
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
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	dump(self.data,"<color=red>数据++++++++++++++++++++++++++++++++++</color>")

	self.isWin = DominoJLModel.data.seat_num == self.data.settlement_info.winner
	if self.data.settlement_info.rate < 3 then
		ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_jiesuan1.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_jiesuan2.audio_name)
	end

	self.info_txt.text = GLL.GetTx(40007)

	-- local m_data = DominoJLModel.data
	-- local ui_seat_num = m_data.s2cSeatNum[m_data.seat_num]

	local winner = nil
	local award = nil
	local lose_data = {}
	local data =  self.data.settlement_info.scores 
	for i = 1,#data do
		if data[i] > 0 then
			winner = i
			award = data[i]
		else
			lose_data[i] = data[i]
		end
	end

	winner = winner or self.data.settlement_info.winner

	local str = string.format(GLL.GetTx(40005),winner,award) --"赢家是玩家"..winner.."号,获得了"..award.."金币\n"
	for k , v in pairs(lose_data) do
		str = str .. string.format(GLL.GetTx(40006),k,v)-- "玩家"..k.."输掉"..v.."金币\n"
	end
	self.info_txt.text = self.info_txt.text .. str

	Timer.New(
		function ()
			self:MyExit()

		end,5,1
	):Start()

	local m_data = DominoJLModel.data
	local winner_ui_index = m_data.s2cSeatNum[winner]
	local playerList = DominoJLGamePanel.Instance.playerList
	local winner_ui = playerList[winner_ui_index]

	local winner_tx = {
		"UI_beilv_01","UI_beilv_02","UI_beilv_03","UI_beilv_04","UI_beilv_05",
	}

	local tx_name = winner_tx[self.data.settlement_info.rate]

	self.tx_prefab = newObject(tx_name,winner_ui.transform)
	self.winNotice = newObject("DominoJLWinnerNotice",winner_ui.transform)
	self.tx_prefab.transform.position = Vector3.zero

	local b = true
	--播放飞金币的动画
	for seatNum , v in pairs(lose_data) do
		if DominoJLModel.data.players_info[seatNum] then
			local pos_index = m_data.s2cSeatNum[seatNum]
			local loser_ui = playerList[pos_index]
			local wPos = winner_ui.head_img.transform.position
			local lPos = loser_ui.head_img.transform.position
			CommonAnim.FlyGoldNum(Vector3.New(lPos.x,lPos.y - 50,lPos.z),v)
			DominoJLGamePanel.Instance:RefreshScore(pos_index)
			CommonAnim.FlyGold(lPos,wPos,
			function ()
				if b then
					CommonAnim.FlyGoldNum(Vector3.New(wPos.x,wPos.y - 50,wPos.z),award)
					CommonEffects.PlayAddGold(DominoJLGamePanel.Instance.effect_node,wPos)
					ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_jinbi.audio_name)
					local seq = DoTweenSequence.Create()
					seq:InsertCallback(1,function ()
						DominoJLGamePanel.Instance:RefreshScore(winner_ui_index)
					end)
					b = false
				end
			end
			)
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
end
