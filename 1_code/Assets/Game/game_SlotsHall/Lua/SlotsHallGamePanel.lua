-- 创建时间:2022-03-16
-- Panel:SlotsHallGamePanel
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

SlotsHallGamePanel = basefunc.class()
local C = SlotsHallGamePanel
C.name = "SlotsHallGamePanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshInfo)
	self.lister["set_head_image_response"] = basefunc.handler(self, self.RefreshInfo)
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
		GameManager.CommonGotoScence({gotoui = "game_Hall"})
	end)
	self.head_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_roleinfo", goto_scene_parm = "panel"})
	end)
	self.jb_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
	end)
	self.start_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnDJClick( PlayerPrefs.GetInt("slots_hall_start_id", 1) )
	end)
	self.buy_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
	end)
end

function C:RemoveListenerGameObject()
	self.back_btn.onClick:RemoveAllListeners()
	self.head_btn.onClick:RemoveAllListeners()
	self.jb_btn.onClick:RemoveAllListeners()
	self.start_btn.onClick:RemoveAllListeners()
	self.buy_btn.onClick:RemoveAllListeners()
	for k, v in pairs(self.objs or {}) do
		v:MyExit()
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
	local id = PlayerPrefs.GetInt("slots_hall_start_id", 1)
	local start_cfg = SlotsHallModel.GetIdByCfg(id)
	self.start_txt.text = start_cfg.name

	local cfg = SlotsHallModel.GetLayoutCfg()
	self.objs = {}
	for k,v in ipairs(cfg) do
		local pre = SlotsHallItemPrefab.Create(self.Content, v, self.OnDJClick, self, k)
		self.objs[#self.objs+1] = pre
	end

	self:RefreshInfo()
end

function C:RefreshInfo()
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	SetHeadImg(MainModel.UserInfo.head_image, self.head_img)
end

function C:OnDJClick(id)
	local v = SlotsHallModel.GetIdByCfg(id)
	if v.scene_name then
		if v.jb_limit and MainModel.UserInfo.jing_bi < v.jb_limit then
			local msg = string.format(GLL.GetTx(60028), StringHelper.ToCash(v.jb_limit))
			HintPanel.Create(2, msg, function ()
				GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
			end)
			return
		end

		GameManager.CommonGotoScence({gotoui = v.scene_name, enter_scene_call=function ()
			dump(v, "<color=red>AAAAA Slots Enter</color>")
			PlayerPrefs.SetInt("slots_hall_start_id", v.line)
		end})
	else

	end
end
