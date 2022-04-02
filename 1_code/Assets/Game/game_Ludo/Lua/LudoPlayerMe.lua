-- 创建时间:2021-11-08
-- Panel:LudoPlayerMe
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

LudoPlayerMe = basefunc.class(LudoPlayerBase)
local C = LudoPlayerMe
C.name = "LudoPlayerMe"

function C:ctor(panelSelf, obj, data)
	LudoPlayerMe.super.ctor(self, panelSelf, obj, data)
end

function C:RefreshPermitRool()
	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	if self.data.uiIndex ~= cur_p then
		self.roll_node.gameObject:SetActive(false)
		self:DestroyDice()
	end

	if LudoModel.data.statusMini == LudoModel.StatusMini.waitRoll then
		if self.data.uiIndex == cur_p then
			self.roll_node.gameObject:SetActive(true)
		end
	elseif LudoModel.data.statusMini == LudoModel.StatusMini.roll then
		self.roll_node.gameObject:SetActive(false)
	end

	if (LudoModel.data.status == LudoModel.Status.roll and LudoModel.data.statusMini == LudoModel.StatusMini.roll)
	or (LudoModel.data.status == LudoModel.Status.piece and LudoModel.data.statusMini == LudoModel.StatusMini.waitPiece) then
		--自己投骰子和等待走棋的时候不删除骰子
	else
		self:DestroyDice()
	end
end

function C:RefreshPermitPiece()
	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	if self.data.uiIndex ~= cur_p
	or LudoModel.data.status ~= LudoModel.Status.piece then
		self.piece_node.gameObject:SetActive(false)
		return
	end

	if LudoModel.data.statusMini == LudoModel.StatusMini.waitPiece then
		--等待选棋
		self.piece_node.gameObject:SetActive(true)
		self.piece_txt.text = ""
		
		--自动走棋
		self:AoutPiece()
	elseif LudoModel.data.statusMini == LudoModel.StatusMini.piece then
		--走棋选棋
		self.piece_node.gameObject:SetActive(true)
		self.piece_txt.text = ""
	end
end

function C:AoutPiece()
	if true then
		return
	end
	--如果轮到自己走棋子，并且只能走这颗旗子
	--就帮玩家选择走这颗旗子
	if self.curr_point then
		local can_move_piece = {}
		for i = 1,4 do
			local piece = self.pieceMap[1][i].piece
			--如果这枚旗子处于冲刺路径中
			if piece.data.place < 58 and piece.data.place >= 52 then
				if piece.data.place + self.curr_point < 58 then
					can_move_piece[#can_move_piece + 1] = piece
				end
			end
			--如果这枚旗子在原点，并且摇出的点数为6
			if piece.data.place == 0 and self.curr_point == 6 then
				can_move_piece[#can_move_piece + 1] = piece
			end
			--如果这枚旗子不再原点，并且不再冲刺路线中
			if piece.data.place > 0 and piece.data.place < 0 then
				can_move_piece[#can_move_piece + 1] = piece
			end
		end
		if #can_move_piece == 1 then
			Network.SendRequest("nor_fxq_nor_piece",{id = can_move_piece[1].data.id})
		end
	end
end