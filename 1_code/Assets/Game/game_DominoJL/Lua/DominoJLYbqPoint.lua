-- 创建时间:2021-11-08
-- Panel:DominoJLYbqPoint
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

DominoJLYbqPoint = basefunc.class()
local C = DominoJLYbqPoint
C.name = "DominoJLYbqPoint"
--[[
	data = {
		parent :父节点
		point : 1~6
	}
]]
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
	local parent = data.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.camera = GameObject.Find("Canvas/Camera").transform:GetComponent("Camera")
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.ybq_img.sprite = GetTexture("ty_dot_gp_" .. self.data.point .. "_1")
	self.ybq_img.gameObject:SetActive(self.data.point ~= 0)
	self:MyRefresh()
	self:PlayShow()
end

function C:MyRefresh()

end

function C:PlayShow()
	local seq = DoTweenSequence.Create()
	local CG  = self.transform:GetComponent("CanvasGroup")
	CG.alpha = 0
	seq:AppendInterval(1)
	seq:Append(CG:DOFade(1,2))
	seq:OnForceKill(function ()
		if IsEquals(CG) then
			CG.alpha = 1
		end
	end)
end