-- 创建时间:2018-11-28

local basefunc = require "Game.Common.basefunc"

GameBroadcastRollPrefabH = basefunc.class()
local C = GameBroadcastRollPrefabH
local instance = nil
function C.Create(data, parent)
	instance = C.New(data, parent)
	return instance
end
function C:ctor(data, parent)

	local showw = 810
	self.data = data
    self.gameObject = newObject("GameBroadcastRollPrefabH", parent)
    self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
    local tran = self.transform
    tran.localPosition = Vector3.New(showw*0.5, 0, 0)

	local tab = BroadcastHelper.EncodeText(data.msg.content)
	self.front_txt.text = tab.front_txt
	self.back_txt.text = tab.back_txt
	SetHeadImg(tab.head_img, self.head_img)
	self.vip_txt.text = "VIP" .. tab.vip_lv
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.front_txt.transform)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.vip_txt.transform)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.back_txt.transform)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.group)
	local ww = self.group:GetComponent("RectTransform").sizeDelta.x
	self.seqMove = DoTweenSequence.Create({dotweenLayerKey=SysBroadcastManager.dotween_key})
	-- 移动速度固定 计算移动时间
	local tt1 = (showw + ww)/showw * 6
	-- 400是两条滚动广播的距离
	local tt2 = (200 + ww)/showw * 6
	local pos1 = Vector3.New(-showw*0.5-ww, 0, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		GameBroadcastRollPanel.PlayFinish()
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(tran:DOLocalMoveX(pos1.x, tt1):SetEase(Enum.Ease.Linear))
	self.seqMove:OnForceKill(function (force_kill)
		self.seqMove = nil
		if not force_kill then
			GameBroadcastRollPanel.PlayEnd(data.key)
		end
	end)
end

function C:Destroy()
	if IsEquals(self.gameObject) then
		if self.seqMove then
			self.seqMove:Kill()
		end
		destroy(self.gameObject)
	end
end
