-- 创建时间:2021-11-08
-- Panel:DominoJLPlayerMe
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

DominoJLPlayerMe = basefunc.class(DominoJLPlayerBase)
local C = DominoJLPlayerMe
C.name = "DominoJLPlayerMe"

function C:ctor(panelSelf, obj, data)
	DominoJLPlayerMe.super.ctor(self, panelSelf, obj, data)
end

function C:AddListenerGameObject()
    EventTriggerListener.Get(self.head_img.gameObject).onClick = basefunc.handler(self, function ()
		local user = DominoJLModel.GetPosToPlayer(self.data.uiIndex)
		if user then
			GameManager.GotoUI({gotoui = "sys_interactive", goto_scene_parm = "my_panel", ext = {pos=self.transform.position + Vector3.New(150,50,0)}, data = user})
		end
	end)
end

function C:RefreshCard()
	if DominoJLCardGroup.Instance then
		DominoJLCardGroup.Instance:MyRefresh()
	end
	if DominoJLCardCount.Instance then
		DominoJLCardCount.Instance:MyRefresh()
	end
end

function C:GetCardPosition()
	local list = {}
	for i = 1, 7 do
		list[#list + 1] = self["card_node"..i].position
	end
	return list
end

function C:PlayCardShake()
	if self.cd > 3 or self.cd < 0.4 then
		return
	end
	if DominoJLModel.data.model_status ~= DominoJLModel.Model_Status.gaming
	or DominoJLModel.data.status ~= DominoJLModel.Status.cp then
		return
	end

	if not DominoJLModel.data.cur_p then
		--没有确定权限
		return
	end
	local cur_p = DominoJLModel.data.s2cSeatNum[DominoJLModel.data.cur_p]
	if self.data.uiIndex ~= cur_p then
		return
	end

	DominoJLCardGroup.Instance:PlayCardShake()
end


function C:ClearYbqPoint()

end

function C:CreateYbqPoint(data)
	
end

function C:RefreshYbqPoint()
	
end

function C:PlayYbqPoint(data)

end

function C:PlayLvUpAnim()
	-- CommonAnim.LvUpAnim(self.transform)
	Event.Brocast("player_lv_up_in_seat", self.transform)
end

function C:PlayShowCardCount()
	if DominoJLCardCount.Instance then
		DominoJLCardCount.Instance:PlayShow()
	end
end

function C:PlayShowNotice()
	local zj = DominoJLModel.data.s2cSeatNum[DominoJLModel.data.zhuang]
	local ui_index = self.data.uiIndex
	local num = DominoJLModel.data.remain_pai_amount[DominoJLModel.data.seatNum[self.data.uiIndex]]
	if zj == 1 and ui_index == 1 and num == 7 then
		self.my_notice_node.gameObject:SetActive(true)
		self.notice_txt.text = GLL.GetTx(40001)
	else
		if self.my_notice_node then
			self.my_notice_node.gameObject:SetActive(false)
		end
	end
end