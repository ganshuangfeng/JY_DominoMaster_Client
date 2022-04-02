-- 创建时间:2022-03-22
-- Panel:Act_YJPHBPanel
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

Act_YJPHBPanel = basefunc.class()
local C = Act_YJPHBPanel
local M = Act_YJPHBManager
C.name = "Act_YJPHBPanel"

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
    self.lister["query_rank_data_response"] = basefunc.handler(self, self.on_query_rank_data_response)
    self.lister["query_rank_base_info_response"] = basefunc.handler(self, self.on_query_rank_base_info_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:DisposeItems()
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
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
	self.items = {}
	Network.SendRequest("query_rank_data", { page_index = 1, rank_type = M.rank_type })
	Network.SendRequest("query_rank_base_info", { rank_type = M.rank_type })
	local endTimeCall = function()
		self:MyExit()
	end
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_txt, nil, endTimeCall)
end

function C:AddListenerGameObject()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.rule_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OpenRules()
	end)
end

function C:RemoveListenerGameObject()
	self.close_btn.onClick:RemoveAllListeners()
	self.rule_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()

end

function C:InitPHB(data)
	local rankData = data.rank_data
	if table_is_null(rankData) then
		return
	end
	for i = 1, #rankData do
		local item = Act_YJPHBItem.Create(self.content, rankData[i])
		ClipUIParticle(item.transform)
		self.items[#self.items + 1] = item
	end
end

function C:InitBaseInfo(data)
	local baseData = data
	self.my_name_txt.text = MainModel.UserInfo.name
	self.my_num_txt.text = StringHelper.ToCash(data.score)
	local rankIndex = baseData.rank or -1
	if rankIndex == -1 then
		self.my_award_txt.text = "- -"
	else
		self.my_award_txt.text = StringHelper.ToCash(M.GetAwardFromIndex(rankIndex))
	end

	if rankIndex == -1 then
		self.no_rank.gameObject:SetActive(true)
	else
		if rankIndex > 3 then
			self.my_rank_txt.text = rankIndex
		else
			-- self.my_rank_txt.text = ""
			self.my_rank_img.gameObject:SetActive(true)
			self.my_rank_img.sprite = GetTexture("ludo_js_icon_0" .. rankIndex)
		end
	end
end

function C:InitUI()
	self:MyRefresh()
end

function C:on_query_rank_data_response(_, data)
	dump(data, "<color=white>赢金排行榜:on_query_rank_data_response</color>")
	if data and data.result == 0 and data.rank_type == M.rank_type then
		self:InitPHB(data) 
	end
end

function C:on_query_rank_base_info_response(_, data)
	dump(data, "<color=white>赢金排行榜:on_query_rank_base_info_response</color>")
	if data and data.result == 0 then
		self:InitBaseInfo(data)
	end
end

function C:DisposeItems()
	if table_is_null(self.items) then
		return
	end

	for i = #self.items, 1, -1 do
		self.items[i]:MyExit()
		self.items[i] = nil
	end
end

function C:OpenRules()
	local contentStr = ""
	for i = 1, #M.rules do
		contentStr = contentStr .. M.rules[i] .. "\n"
	end
	local b = HintPanel.Create(1, contentStr)
	b:SetDescLeft()
end

function C:MyRefresh()
end
