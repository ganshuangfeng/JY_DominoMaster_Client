-- 创建时间:2021-12-15
-- Panel:SlotsClearPanel
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

SlotsClearPanel = basefunc.class()
local M = SlotsClearPanel
M.name = "SlotsClearPanel"

local instance
function M.Create()
	if instance then
		instance:MyExit()
	end
	instance = M.New()
	M.Instance = instance
	return instance
end

function M.Close()
	if not instance then
		return
	end
	instance:MyExit()
end

function M.Refresh()
	if not instance then
		return
	end
	instance:MyRefresh()
end

function M.Show()
	if not instance then
		return
	end
	instance:PlaySettlement()
	instance.gameObject:SetActive(true)
end

function M.Hide()
	if not instance then
		return
	end
	SlotsHelper.ExitDelay()
	instance:HideAllClear()
	instance.gameObject:SetActive(false)
	Event.Brocast("CompleteSettlement")
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	self:RemoveListenerGameObject()
	self:ExitChildPanel()
	destroy(self.gameObject)
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	M.Instance = self
	ExtPanel.ExtMsg(self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
	self:InitChildPanel()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.gameObject:SetActive(false)
end

function M:InitChildPanel()
	SlotsClearMainPanel.Create()
	SlotsClearMini1Panel.Create()
	SlotsClearMini2Panel.Create()
	SlotsClearMini3Panel.Create()
end

function M:ExitChildPanel()
	SlotsClearMainPanel.Close()
	SlotsClearMini1Panel.Close()
	SlotsClearMini2Panel.Close()
	SlotsClearMini3Panel.Close()
end

function M:RefreshChildPanel()
	SlotsClearMainPanel.Refresh()
	SlotsClearMini1Panel.Refresh()
	SlotsClearMini2Panel.Refresh()
	SlotsClearMini3Panel.Refresh()
end

function M:MyRefresh()
	self:RefreshChildPanel()
	self:HideAllClear()
	self.gameObject:SetActive(false)
end

function M:AddListenerGameObject()
    self.back_btn.onClick:AddListener(function ()
        self:OnClickBack()
    end)
end

function M:RemoveListenerGameObject()
	self.back_btn.onClick:RemoveAllListeners()
end

function M:OnClickBack()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--结算过程中不能中途退出
	-- M.Hide()
end

function M:PlaySettlement()
	self:HideAllClear()

	local pro = SlotsModel.GetGameProcess()

	if pro.game == "main" then
		SlotsClearMainPanel.Show()
	elseif pro.game == "mini1" then
		SlotsClearMini1Panel.Show()
	elseif pro.game == "mini2" then
		SlotsClearMini2Panel.Show()
	elseif pro.game == "mini3" then
		SlotsClearMini3Panel.Show()
	end
end

function M:Play5Line(seq)
	local pro = SlotsModel.GetGameProcess()
	if pro.game == "main" then
		return SlotsClearMainPanel.Instance:Play5Line(seq)
	elseif pro.game == "mini1" then
	elseif pro.game == "mini2" then
		return SlotsClearMini2Panel.Instance:Play5Line(seq)
	elseif pro.game == "mini3" then
	end
end

function M:PlayNormalNot5Line(seq)
	--有5连的时候放到后面
	local pro = SlotsModel.GetGameProcess()

	if pro.game == "main" then
		return SlotsClearMainPanel.Instance:PlayNormalNot5Line(seq)
	elseif pro.game == "mini1" then
	elseif pro.game == "mini2" then
		return SlotsClearMini2Panel.Instance:PlayNormalNot5Line(seq)
	elseif pro.game == "mini3" then
	end
end

function M:CheckNormalLv()
	local pro = SlotsModel.GetGameProcess()

	if pro.game == "main" then
		return SlotsClearMainPanel.Instance:CheckNormalLv()
	elseif pro.game == "mini1" then
	elseif pro.game == "mini2" then
		return SlotsClearMini2Panel.Instance:CheckNormalLv()
	elseif pro.game == "mini3" then
	end
end

function M:HideAllClear()
	self.back_btn.gameObject:SetActive(false)
	self.line5.gameObject:SetActive(false)
	self.normal_lv1.gameObject:SetActive(false)
	self.normal_lv2.gameObject:SetActive(false)
	self.normal_lv3.gameObject:SetActive(false)
	self.award_pool_lv1.gameObject:SetActive(false)
	self.award_pool_lv2.gameObject:SetActive(false)
	self.award_pool_lv3.gameObject:SetActive(false)
	self.award_pool_lv4.gameObject:SetActive(false)
	self.mini_game_1.gameObject:SetActive(false)
	self.mini_game_2.gameObject:SetActive(false)
	self.mini_game_last.gameObject:SetActive(false)
end