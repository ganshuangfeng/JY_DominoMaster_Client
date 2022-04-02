-- 创建时间:2022-03-18
-- Panel:VIPOverflowPrefab
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

VIPOverflowPrefab = basefunc.class()
local C = VIPOverflowPrefab
C.name = "VIPOverflowPrefab"

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

function C:ctor(data)
	self.data = data

	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
		self:MyExit()
	end)
	self.goto_vip_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "panel"})
		self:MyExit()
	end)
	self.goto_dh_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		MainModel.OpenDH()
		self:MyExit()
	end)
end

function C:RemoveListenerGameObject()
	self.goto_vip_btn.onClick:RemoveAllListeners()
	self.goto_dh_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
	self.hint1_txt.text = GLL.GetTx(81085)
	self.hint2_txt.text = GLL.GetTx(81086)
	self.hint3_txt.text = GLL.GetTx(81087)
	self.hint4_txt.text = GLL.GetTx(81090)
	self.goto_vip_txt.text = GLL.GetTx(81088)
	self.goto_dh_txt.text = GLL.GetTx(81089)
	self.cur_rp_limit_txt.text = GLL.GetTx(81082) .. ":" .. StringHelper.ToCash( self.data.cur_hb_limit )
	self.cur_vip_txt.text = GLL.GetTx(81083) .. ":VIP" .. self.data.cur_vip
end

function C:RefreshLL()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.over_rp_txt.text = StringHelper.ToCash( self.data.shop_gold_change / 100 )
	self.over_jb_txt.text = StringHelper.ToCash( self.data.jing_bi_change )
end
