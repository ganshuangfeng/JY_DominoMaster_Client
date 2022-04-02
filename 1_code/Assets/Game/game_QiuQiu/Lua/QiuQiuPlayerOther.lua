-- 创建时间:2021-11-08
-- Panel:QiuQiuPlayerOther
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

QiuQiuPlayerOther = basefunc.class(QiuQiuPlayerBase)
local C = QiuQiuPlayerOther
C.name = "QiuQiuPlayerOther"

function C:ctor(panelSelf, obj, data)
	QiuQiuPlayerOther.super.ctor(self, panelSelf, obj, data)
end

function C:AddListenerGameObject()
    EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
		local user = QiuQiuModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "panel", ext = {pos=self.transform.position}, data = user})
		end
	end)
end