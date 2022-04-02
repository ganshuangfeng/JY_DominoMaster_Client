-- 创建时间:2021-11-08
-- Panel:LudoPlayerOther
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

LudoPlayerOther = basefunc.class(LudoPlayerBase)
local C = LudoPlayerOther
C.name = "LudoPlayerOther"

function C:ctor(panelSelf, obj, data)
	LudoPlayerOther.super.ctor(self, panelSelf, obj, data)
end

function C:RefreshPermitRool()
	local cur_p = LudoModel.data.s2cSeatNum[LudoModel.data.cur_p]
	if self.data.uiIndex ~= cur_p then
		self:DestroyDice()
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
	elseif LudoModel.data.statusMini == LudoModel.StatusMini.piece then
		--走棋选棋
		self.piece_node.gameObject:SetActive(true)
		self.piece_txt.text = ""
	end
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
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "panel", ext = {pos=self.transform.position + Vector3.New(-150,10,0)}, data = user})
		end
	end)
end