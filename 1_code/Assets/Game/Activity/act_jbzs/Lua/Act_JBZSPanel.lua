-- 创建时间:2022-03-22
-- Panel:Act_JBZSPanel
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

Act_JBZSPanel = basefunc.class()
local C = Act_JBZSPanel
local M = Act_JBZSManager
C.name = "Act_JBZSPanel"

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
    self.lister["vip_upgrade_change_msg"] = basefunc.handler(self, self.on_vip_upgrade_change_msg)
    self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
    self.lister["query_send_asset_for_other_player_base_info_response"] = basefunc.handler(self,self.on_query_send_asset_for_other_player_base_info_response)
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.asset_cfg_id = 1
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
	-- Network.SendRequest("query_send_asset_for_other_player_base_info")
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.give_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Give()
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.give_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:InitGiveAssetSelect()
	self:RefreshCurJingbi()
	self:RefreshCurVipLv()
	self:RefreshRemainTime(0)
	self:MyRefresh()
end

function C:SelectAssetId(id)
	self.asset_cfg_id = id
end

function C:InitGiveAssetSelect()
	local cfg = M.GetConfig()
	self.selects = {}

	local selectFun = function(id)
		self:SelectAsset(id)
	end
	for i = 1, #cfg do
		local select = Act_JBZSAssetSlect.Create(self.content, cfg[i], i, selectFun)
		self.selects[#self.selects + 1] = select
	end
	self:SelectAsset(1)
end
 
function C:SelectAsset(id)
	for i = 1, #self.selects do
		self.selects[i]:ViewUnSelct()
	end
	self.selects[id]:ViewSelect()
	self.asset_cfg_id = id
end

function C:Give()
	if not self.give_player_id or self.asset_cfg_id then
		return
	end
	local data = { player_id = self.give_player_id, asset_cfg_id = self.asset_cfg_id}
	Network.SendRequest("send_asset_for_other_player", data)
end

function C:RefreshCurJingbi()
	self.jb_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("jing_bi"))
end

function C:RefreshCurVipLv()
	self.vip_txt.text = SysVipManager.GetVipData().level
end

function C:RefreshRemainTime(time)
	self.remain_txt.text = time
end

function C:on_vip_upgrade_change_msg()
	self:RefreshCurVipLv()
end

function C:OnAssetChange()
	self:RefreshCurJingbi()
end

function C:on_query_send_asset_for_other_player_base_info_response(_, data)
	if data and data.result == 0 then
		self:RefreshRemainTime(data.remain_num or 0)
	end
end
function C:MyRefresh()
end
