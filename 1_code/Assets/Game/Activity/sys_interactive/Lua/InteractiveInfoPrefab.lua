-- 创建时间:2021-12-14
-- Panel:InteractiveInfoPrefab
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

InteractiveInfoPrefab = basefunc.class()
local C = InteractiveInfoPrefab
local M = SysInteractiveManager
C.name = "InteractiveInfoPrefab"

function C.Create(parent, data, selfParent, call)
	return C.New(parent, data, selfParent, call)
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
	if self.timerUpdate then
		self.timerUpdate:Stop()
	end
	self.timerUpdate = nil

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

function C:ctor(parent, data, selfParent, call)
	self.parent = parent
	self.data = data
	self.selfParent = selfParent
	self.call = call

	local obj = newObject(C.name, self.parent)
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
	
end

function C:RemoveListenerGameObject()
	self.lock_btn.onClick:RemoveAllListeners()
	EventTriggerListener.Get(self.icon_img.gameObject).onClick = nil
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	EventTriggerListener.Get(self.icon_img.gameObject).onClick = basefunc.handler(self, function ()
		if SysInteractiveManager.m_data.cd_map[self.data.id] and SysInteractiveManager.m_data.cd_map[self.data.id] > os.time() then
			-- LittleTips.Create("")
		else
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if self.selfParent.data and self.selfParent.data.id then
				Network.SendRequest("send_player_easy_chat", {act_apt_player_id=self.selfParent.data.id, parm=self.data.id.."_"..self.data.sex.."_1", item_key=self.cfg.item_key}, function (data)
					dump(data, "send_player_easy_chat")
					if data.result == 0 then
						SysInteractiveManager.m_data.cd_map[self.data.id] = os.time() + self.max_cd
					end
				end)
			end
			self.call(self.selfParent, self.data)
		end
	end)
	self.max_cd = 6

	-- self.name_txt.text = self.data.name
	self.icon_img.sprite = GetTexture(self.data.icon)
	self.vip.gameObject:SetActive(false)
	-- self.lock.gameObject:SetActive(false)
	self:MyRefresh()
end

function C:MyRefresh()
	self.level_txt.text = ""
	self.cfg = M.GetCfgFromBqId(1, self.data.id)
	dump(self.cfg, "<color=white>self.cfg</color>")
	if GameItemModel.GetItemCount(self.cfg.item_key) > 0 then
		self.lock.gameObject:SetActive(false)
		self.level_txt.text = "x"  .. GameItemModel.GetItemCount(self.cfg.item_key)
	else
		if self.cfg.type == 1 then
			self.level = SysLevelManager.GetLevel()
			if self.level >= self.cfg.perm then
				self.lock.gameObject:SetActive(false)
				self.level_txt.text = ""
			else
				self.level_txt.text = "Lv." .. self.cfg.perm
				self.lock_btn.onClick:RemoveAllListeners()
				self.lock_btn.onClick:AddListener(function()
					local tx = string.format(GLL.GetTx(60026), self.cfg.perm)
					LittleTips.Create(tx)
				end)
			end
		elseif self.cfg.type == 2 then
			self.vipLevel = SysVipManager.GetVipData().level
			if self.vipLevel >= self.cfg.perm then
				self.lock.gameObject:SetActive(false)
			else
				self.lock.gameObject:SetActive(true)
				self.lock_btn.onClick:RemoveAllListeners()
				self.lock_btn.onClick:AddListener(function()
					local tx = string.format(GLL.GetTx(60027), self.cfg.perm)
					LittleTips.Create(tx)
				end)
			end
			self.vip.gameObject:SetActive(true)
			self.vip_txt.text = "VIP " .. self.cfg.perm
		end
	end
	self:RefreshCD()
end

function C:RefreshCD()
	if SysInteractiveManager.m_data.cd_map[self.data.id] and SysInteractiveManager.m_data.cd_map[self.data.id] > os.time() then
		local cd = SysInteractiveManager.m_data.cd_map[self.data.id] - os.time()
		self.cd_txt.text = ""..cd
		if self.timerUpdate then
			self.timerUpdate:Stop()
		end
		self.timerUpdate = Timer.New(function ()
			if SysInteractiveManager.m_data.cd_map[self.data.id] > os.time() then
				self.cd_txt.text = ""..(SysInteractiveManager.m_data.cd_map[self.data.id] - os.time())
			else
				self.cd_txt.text = ""
				self.timerUpdate:Stop()
				self.timerUpdate = nil
			end
		end, 1, -1, false)
    	self.timerUpdate:Start()
	else
		self.cd_txt.text = ""
	end
end
