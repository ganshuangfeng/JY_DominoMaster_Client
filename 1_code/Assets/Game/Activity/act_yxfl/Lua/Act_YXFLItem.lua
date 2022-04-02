-- 创建时间:2022-03-16
-- Panel:Act_YXFLItem
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

Act_YXFLItem = basefunc.class()
local C = Act_YXFLItem
C.name = "Act_YXFLItem"

function C.Create(parent)
	return C.New(parent)
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
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.cfg = {}
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self.items = {}
	self.get_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award", { id = self.cfg.task_id})
	end)
	self.goto_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local gotoUI = self.cfg.gotoUI
		if type(gotoUI) == "table" then
			GameManager.GotoUI({gotoui = gotoUI[1], goto_scene_parm = gotoUI[2]})
			if gotoUI[2] == "panel" then
				Event.Brocast("ActivityYearPanel_off_msg", "normal")
			end
		else
			GameManager.GotoUI({gotoui = gotoUI})
		end
	end)
	-- self:RefreshView()
	self:MyRefresh()
end

function C:RefreshView(cfg)
	if cfg then
		self.cfg = cfg
	end
	local _cfg = self.cfg
	-- dump(_cfg, "<color=red>_cfg</color>")
	self.tit_txt.text = GLL.GetTx(_cfg.task_content)
	self:ClearAwardItems()
	for i = 1, #_cfg.award_item do
		local obj = GameObject.Instantiate(self.award_item, self.content)
		obj.gameObject:SetActive(true)
		local icon_img = obj.transform:Find("icon_img"):GetComponent("Image")
		local count_txt = obj.transform:Find("count_txt"):GetComponent("Text")
		local item_cfg =  GameItemModel.GetItemToKey(_cfg.award_item[i])
		if _cfg.award_item[i] == "jing_bi" then
			icon_img.sprite = GetTexture("ty_jb")
		elseif _cfg.award_item[i] == "shop_gold_sum" then
			icon_img.sprite = GetTexture("ty_icon_rp_1")
			icon_img:GetComponent("RectTransform").sizeDelta = {x = 80, y = 80}
		else
			icon_img.sprite = GetTexture(item_cfg.image)
		end
		if not _cfg.award_count[i] then
			dump("奖励配置数量未对应")
		end

		local icon_btn = obj.transform:Find("icon_img"):GetComponent("Button")
		QPPrefab.AddShowItem(icon_btn, _cfg.award_item[i])
		count_txt.text = StringHelper.ToCash(_cfg.award_count[i])
		self.items[#self.items + 1] = obj
	end
	local taskData = GameTaskManager.GetTaskDataByID(_cfg.task_id)
	if taskData then
		-- dump(taskData, "<color=white>TTT</color>")
		if not _cfg.task_level then
			local w = (taskData.now_process / taskData.need_process) * 170.58
			self.pg:GetComponent("RectTransform").sizeDelta = {x = w, y = 20}
			self.pg_txt.text = StringHelper.ToCash(taskData.now_process) .. "/" .. StringHelper.ToCash(taskData.need_process)
			self.goto_btn.gameObject:SetActive(taskData.award_status == 0)
			self.get_btn.gameObject:SetActive(taskData.award_status == 1)
			self.geted_btn_.gameObject:SetActive(taskData.award_status == 2)
		end
	end
end

function C:ClearAwardItems()
	if table_is_null(self.items) then
		return
	end
	for i = 1, #self.items do
		destroy(self.items[i].gameObject)
	end
	self.items = {}
end

function C:MyRefresh()
end
