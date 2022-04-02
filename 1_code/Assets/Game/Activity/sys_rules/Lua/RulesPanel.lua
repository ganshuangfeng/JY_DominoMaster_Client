-- 创建时间:2021-12-06
-- Panel:RulesPanel
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

RulesPanel = basefunc.class()
local C = RulesPanel
C.name = "RulesPanel"

local instance
function C.Create(parm)
	if instance then
		instance:MyExit()
	end
	instance = C.New(parm)
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListenerGameObject()
	self:ExitChoosePanel()
	self:RemoveListener()
	destroy(self.gameObject)
	ClearTable(self)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parm = parm
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitData()
	self:InitUI()
	self:InitLL()
end

function C:InitData()
	self.tagCfg = RulesManager.GetRulesTagCfg()
	if self.parm then
		self.gameName = self.parm.game
	end
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:InitTagTge()
	self:AddListenerGameObject()
	if self.gameName then
		self:ChooseTagTge(self.gameName)
	else
		self:ChooseTagTge(self.tagCfg[1])
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	for k, v in pairs(self.tagTges) do
		v.tge.onValueChanged:AddListener(
			function(val)
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				v.bg_txt.gameObject:SetActive(not val)
				v.tge_txt.gameObject:SetActive(val)
				if val then
					self:ChooseTagRules(k)
				end
			end
		)
	end
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
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
		uiTable.tge_txt.text = v
		uiTable.bg_txt.text = v
		uiTable.tge = go.transform:GetComponent("Toggle")
		uiTable.tge.group = TG
		self.tagTges[v] = uiTable
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
	if self.chooseRulesTag == tag then
		return
	end
	self:ExitChoosePanel()
	dump(tag)
	self.choosePanel = _G["Rules" .. tag .. 'Panel'].Create({parent = self.rule_node})
	self.chooseRulesTag = tag
end

function C:ExitChoosePanel()
	if self.choosePanel then
		self.choosePanel:MyExit()
	end
	self.choosePanel = nil
end

function C:OnExitScene()
	self:MyExit()
end