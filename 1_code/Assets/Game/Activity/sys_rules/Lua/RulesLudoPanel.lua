-- 创建时间:2021-12-06
-- Panel:RulesLudoPanel
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

RulesLudoPanel = basefunc.class()
local C = RulesLudoPanel
C.name = "RulesLudoPanel"

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
	self:RemoveListenerGameObject()
	self:RemoveListener()
	destroy(self.gameObject)
	ClearTable(self)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = data and data.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitData()
	self:InitUI()
	self:InitLL()
end

function C:InitData()
	self.gameName = "Ludo"
	self.tagCfg = RulesManager.GetRulesTagGameCfg(self.gameName)
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:InitInfo()
	self:InitTagTge()
	self:AddListenerGameObject()
	self:ChooseTagTge(self.tagCfg[1])
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:AddListenerGameObject()
	for k, v in pairs(self.tagTges) do
		v.tge.onValueChanged:AddListener(
			function(val)
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				v.bg_txt.gameObject:SetActive(not val)
				v.tge_txt.gameObject:SetActive(val)
				if val then
					self:ChooseTagRules(k)
				else
					self:HideTagRules(k)
				end
			end
		)
	end
end

function C:RemoveListenerGameObject()
	for k, v in pairs(self.tagTges) do
		v.tge.onValueChanged:RemoveAllListeners()
	end
end

function C:InitTagTge()
	local TG = self.tag_content:GetComponent("ToggleGroup")
	self.tagTges = {}
	for i, v in ipairs(self.tagCfg) do
		local go = GameObject.Instantiate(self.tag_tge, self.tag_content)
		go.gameObject:SetActive(true)
		go.name = v
		local uiTable = {}
		uiTable.transform = go.transform
		uiTable.gameObject = go.gameObject
		LuaHelper.GeneratingVar(go.transform, uiTable)
		local tn = RulesManager.GetRulesTagGameName(v)
		uiTable.tge_txt.text = tn
		uiTable.bg_txt.text = tn
		uiTable.tge_txt.fontSize = 26
		uiTable.bg_txt.fontSize = 26
		uiTable.tge = go.transform:GetComponent("Toggle")
		uiTable.tge.group = TG
		uiTable.tge.isOn = false
		self.tagTges[v] = uiTable

		-- self:HideTagRules(v)
	end
end

function C:HideTagRules(tag)
	if tag == "Rules" then
		self.SVRules.gameObject:SetActive(false)
	elseif tag == "Winner" then
		self.SVWinner.gameObject:SetActive(false)
	elseif tag == "Settlement" then
		self.SVSettlement.gameObject:SetActive(false)
	end
end

function C:ChooseTagTge(tag)
	if self.chooseTag == tag then
		return
	end
	if not self.tagTges[tag] then
		return
	end
	self.tagTges[tag].tge.isOn = true
	self.chooseTag = tag
end

function C:ChooseTagRules(tag)
	self.SVRules.gameObject:SetActive(tag == "Rules")
	self.SVWinner.gameObject:SetActive(tag == "Winner")
	self.SVSettlement.gameObject:SetActive(tag == "Settlement")
	self:ForceRebuild(tag)
end

function C:InitInfo()
	self.rules_txt.text = RulesManager.GetTxt(self.gameName,"Rules")
	self.winner_txt.text = RulesManager.GetTxt(self.gameName,"Winner")
	self.settlement_txt.text = RulesManager.GetTxt(self.gameName,"Settlement")
	self:ForceRebuild()
end

function C:ForceRebuild(tag)
	if not tag then
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.rules_content)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.winner_content)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.settlement_content)
	else
		if tag == "Rules" then
			UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.rules_content)
		elseif tag == "Winner" then
			UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.winner_content)
		elseif tag == "Settlement" then
			UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.settlement_content)
		end
	end
end