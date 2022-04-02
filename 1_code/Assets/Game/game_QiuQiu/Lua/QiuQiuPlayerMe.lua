-- 创建时间:2021-11-08
-- Panel:QiuQiuPlayerMe
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

QiuQiuPlayerMe = basefunc.class(QiuQiuPlayerBase)
local C = QiuQiuPlayerMe
C.name = "QiuQiuPlayerMe"

function C:ctor(panelSelf, obj, data)
	QiuQiuPlayerMe.super.ctor(self, panelSelf, obj, data)
	--我的手牌控制器
	self.HandCard = QiuQiuHandCard.Create(self)
	
end

function C:AddListenerGameObject()
    EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
		local user = QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "my_panel", ext = {pos=self.transform.position}, data = user})
		end
	end)
end

function C:RefreshPermitRool()
	local cur_p = QiuQiuModel.data.s2cSeatNum[QiuQiuModel.data.cur_p]
	if self.data.uiIndex ~= cur_p
	or QiuQiuModel.data.status ~= QiuQiuModel.Status.roll then
		self.roll_node.gameObject:SetActive(false)
		self:DestroyDice()
		return
	end

	if QiuQiuModel.data.statusMini == QiuQiuModel.StatusMini.waitRoll then
		self.roll_node.gameObject:SetActive(true)
		self:DestroyDice()
	elseif QiuQiuModel.data.statusMini == QiuQiuModel.StatusMini.roll then
		self.roll_node.gameObject:SetActive(false)
	end
end

--刷新我的手牌
function C:RefreshHandCard(card_id_list)
	self.HandCard:RefreshCard(card_id_list)
end

function C:AddCard(card_id)
	self.HandCard:AddCard(card_id)
end

function C:MyExit()
	self.HandCard:MyExit()
end

function C:PlayLvUpAnim()
	-- CommonAnim.LvUpAnim(self.transform)
	Event.Brocast("player_lv_up_in_seat", self.transform)
end