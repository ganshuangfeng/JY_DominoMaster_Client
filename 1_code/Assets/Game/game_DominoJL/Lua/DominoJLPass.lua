-- 创建时间:2021-11-11
-- Panel:DominoJLPass
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

DominoJLPass = basefunc.class()
local C = DominoJLPass
C.name = "DominoJLPass"

function C.Create(data)
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
	-- local m_data = DominoJLModel.data
	-- local ui_seat_num = m_data.s2cSeatNum[m_data.seat_num]
	local winner
	for i = 1,#self.data do
		if self.data[i] > 0 then
			self.win_index = i
			winner = i
			self.win_num = self.data[i]
		elseif self.data[i] < 0 then
			self.lose_index = i
		end
	end

	Timer.New(
		function ()
			self:MyExit()
		end
	,5,1):Start()



	local m_data = DominoJLModel.data
	local winner_ui_index = m_data.s2cSeatNum[winner]
	local playerList = DominoJLGamePanel.Instance.playerList
	local winner_ui = playerList[winner_ui_index]

	local pos_index = m_data.s2cSeatNum[self.lose_index]
	local loser_ui = playerList[pos_index]
	local wPos = winner_ui.head_img.transform.position
	local lPos
	if loser_ui then
		lPos = loser_ui.head_img.transform.position
	else
		lPos = Vector3.zero
	end
	-- CommonAnim.FlyGoldNum(Vector3.New(lPos.x,lPos.y - 50,lPos.z),self.win_num * -1)
	DominoJLGamePanel.Instance:RefreshScore(pos_index)
	CommonAnim.FlyGold(lPos,wPos,function ()
		CommonAnim.FlyGoldNum(Vector3.New(wPos.x,wPos.y - 50,wPos.z),self.win_num)
		CommonEffects.PlayAddGold(DominoJLGamePanel.Instance.effect_node,wPos)
		ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_jinbi.audio_name)
		local seq = DoTweenSequence.Create()
		seq:InsertCallback(1,function ()
			DominoJLGamePanel.Instance:RefreshScore(winner_ui_index)
		end)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end
