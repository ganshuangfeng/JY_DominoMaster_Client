-- 创建时间:2022-03-01
-- Panel:QiuQiuTask
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

QiuQiuTask = basefunc.class()
local C = QiuQiuTask
C.name = "QiuQiuTask"

local rp_config = {
	[2001] = {18,19,20,21,22},
	[2002] = {23,24,25,26,27},
	[2003] = {28,29,30,31,32},
	[2004] = {33,34,35,36,37},
	[2005] = {110,111,112,113,114},
	[2006] = {115,116,117,118,119},
}

local ViewState = {
	spread = "spread",
	shrink = "shrink",
}

local task_content = {
	"Six Devil",
	"Twin Cards",
	"Small Cards",
	"Big Cards",
	"Qiu Qiu",
}

local function NextIndex(index)
	if index == 5 then
		return 1
	end
	return index + 1
end

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
	self:KillMoveSeq()
	self:ExitRollTimer()
	self:ExitSpreadTimer()
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

	self.bgRectTrans = self.bg:GetComponent("RectTransform")
	self.vpRectTrans = self.viewport:GetComponent("RectTransform")
	local game_id = QiuQiuModel.data.game_id
	local task_ids = rp_config[game_id]
	self.items = {}
	for i = 1, 5 do
		local b = GameObject.Instantiate(self.item, self.content)
		b.gameObject:SetActive(true)
		local ui = {}
		ui.content_txt = b.transform:Find("content_txt"):GetComponent("Text")
		ui.num_txt = b.transform:Find("num_txt"):GetComponent("Text")
		
		ui.content_txt.text = task_content[i] 
		local info = GameTaskManager.GetTaskConfigByTaskID(task_ids[i])
		ui.num_txt.text = StringHelper.ToCash(info.award_data[info.process_data.awards].asset_count / 100) 

		self.items[#self.items + 1] = { obj = b, ui = ui}
	end

	self.putup_btn.onClick:AddListener(function()
		LittleTips.Create(GLL.GetTx(80060))
		self:PutUp()
	end)

	self.mask_btn.onClick:AddListener(function()
		self:PutAway()
	end)

	self.rollTimer = Timer.New(function()
		if self.state == ViewState.shrink then
			self:RollByItem()
		end
	end, 3.5, -1)
	self.rollTimer:Start()

	self.curIndex = 1
	self:PutAway()
	self:MyRefresh()
end

--滚动
function C:RollByItem()
	dump("RollByItem")
	self.curIndex = NextIndex(self.curIndex)
	-- self:ChangeItemOrder()
	self:PlayRollAnim()
end

function C:PlayRollAnim()
	self.moveSeq = DoTweenSequence.Create()
	self.moveSeq:Append(self.content.transform:DOLocalMoveY(25.59, 0.5))
	self.moveSeq:AppendCallback(function()
		if IsEquals(self.gameObject) then
			self.content.transform.localPosition = Vector3.zero
			self:ChangeItemOrder()
		end
	end)
end

--展开
function C:PutUp()
	self.state = ViewState.spread
	self:KillMoveSeq()
	self.content.transform.localPosition = Vector3.zero
	self:ChangeItemOrder()
	self.bgRectTrans.sizeDelta = { x = 241, y = 184 }
	self.vpRectTrans.sizeDelta = { x = 190, y = 135}
	self.mask_btn.gameObject:SetActive(true)

	self.spreadTimer = Timer.New(function()
		self:PutAway()
	end, 3, 1)
	self.spreadTimer:Start()
end

--收起
function C:PutAway()
	self.state = ViewState.shrink
	self.bgRectTrans.sizeDelta = { x = 241, y = 80 }
	self.vpRectTrans.sizeDelta = { x = 190, y = 31}
	self.mask_btn.gameObject:SetActive(false)
	self:ExitSpreadTimer()
end

function C:ChangeItemOrder()
	local index = self.curIndex
	for i = 1, 5 do
		self.items[index].obj.transform:SetSiblingIndex(i)
		index = NextIndex(index)
	end
end

function C:ExitSpreadTimer()
	if self.spreadTimer then
		self.spreadTimer:Stop()
		self.spreadTimer = nil
	end
end

function C:ExitRollTimer()
	if self.rollTimer then
		self.rollTimer:Stop()
		self.rollTimer = nil
	end
end

function C:KillMoveSeq()
	if self.moveSeq then
		self.moveSeq:Kill()
		self.moveSeq = nil
	end
end

function C:MyRefresh()
end
