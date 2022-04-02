-- 创建时间:2022-02-10
-- Panel:MiniGameGamePanel
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

MiniGameGamePanel = basefunc.class()
local C = MiniGameGamePanel
C.name = "MiniGameGamePanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
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
	self:InitLL()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoSceneName("game_Hall")
	end)
end

function C:RemoveListenerGameObject()
    self.back_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.objs or {}) do
		local dj = v.transform:Find("@dj_btn"):GetComponent("Button")
		dj.onClick:RemoveAllListeners()
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	
	self:MyRefresh()
end

function C:MyRefresh()

	local cfg = MiniGameModel.GetLayoutCfg()
	self.objs = {}
	for k,v in ipairs(cfg) do
		local node
		if v.type == 1 then
			node = GameObject.Instantiate(self.big_node, self.Content).transform
		else
			node = GameObject.Instantiate(self.small_node, self.Content).transform
		end
		for kk,vv in ipairs(v.ids) do
			local dd = MiniGameModel.GetIdByCfg(vv)
			local obj = GameObject.Instantiate(GetPrefab(dd.scene_name.."Prefab"..v.type), node)
			local dj = obj.transform:Find("@dj_btn"):GetComponent("Button")
			local lock = obj.transform:Find("@hintlock")
			dj.onClick:AddListener(function ()
				GameManager.CommonGotoScence({gotoui = dd.scene_name}, function()
					print(dd.scene_name)
				end)
			end)
			lock.gameObject:SetActive(dd.is_lock and dd.is_lock == 1)
			self.objs[#self.objs+1] = obj
		end
	end
end
