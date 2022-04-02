-- 创建时间:2022-02-23
-- Panel:Sys_BannerPanel
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

Sys_BannerPanel = basefunc.class()
local C = Sys_BannerPanel
local M = Sys_BannerManager
C.name = "Sys_BannerPanel"

local instance = nil
function C.Create(parent)
	instance = C.New(parent)
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
    self.lister["EnterForeGround"] = basefunc.handler(self, self.OnEnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ExitTimer()
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
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.banner_btn.onClick:AddListener(function()
		local id = self.curBannerList[self.curIndex]
		local cfg = M.GetCfgFromId(id)
		local gotoUI = cfg.gotoUI
		if type(gotoUI) == "table" then
			GameManager.GotoUI({gotoui = gotoUI[1], goto_scene_parm = gotoUI[2]})
		else
			GameManager.GotoUI({gotoui = gotoUI})
		end
	end)
end

function C:RemoveListenerGameObject()
	self.banner_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

local function NextIndex(curIndex, count)
	if curIndex == count then
		return 1
	else
		return curIndex + 1
	end
end

function C:InitUI()
	self.curBannerList = M.GetCurBannerIdList()
	if table_is_null(self.curBannerList) then
		return
	end
	self.pageNumItems = {}
	for i = 1, #self.curBannerList do
		local pageNum = Sys_BannerPageNum.Create(self.pagenum_content)
		self.pageNumItems[#self.pageNumItems + 1] = pageNum
	end
	--当前展示Banner的索引
	self.curIndex = 1
	--当前展示的Banner数量
	self.listCount = #self.curBannerList

	self.changeTimer = Timer.New(function()
		self:NextItem()
	end, 5, -1)
	self.changeTimer:Start()
	self:RefreshImage()
	self:RefreshPageNumShow()
	self:MyRefresh()
end

function C:RefreshContent()
	self:ExitTimer()
	self:ClearPageNumItems()
	self:InitUI()
end

function C:NextItem()
	if M.IsOutTime() or M.IsInTime() then
		self:RefreshContent()
	end
	self.curIndex = NextIndex(self.curIndex, self.listCount)
	self:RefreshImageWithAnim()
	self:RefreshPageNumShow()
end

function C:ClearPageNumItems()
	for i = #self.pageNumItems, 1, -1 do
		local pageNum = self.pageNumItems[i]
		pageNum:MyExit()
		self.pageNumItems[i] = nil
	end
end

function C:ExitTimer()
	if self.changeTimer then
		self.changeTimer:Stop()
		self.changeTimer = nil
	end
end

function C:RefreshImage()
	local id = self.curBannerList[self.curIndex]
	local cfg = M.GetCfgFromId(id)
	self.banner_img.sprite = GetTexture(cfg.image)
end

function C:RefreshImageWithAnim()
	local id = self.curBannerList[self.curIndex]
	local cfg = M.GetCfgFromId(id)
	local cover = GameObject.Instantiate(self.banner_img.gameObject, self.transform)
	local coverImg = cover:GetComponent("Image")
	self.banner_img.sprite = GetTexture(cfg.image)
	self.DT = DG.Tweening.DOTween.To(
		DG.Tweening.Core.DOGetter_float(function(value)
				return 1 
			end),
		DG.Tweening.Core.DOSetter_float(function(value)
				if IsEquals(self.gameObject) then
					coverImg.fillAmount = value
				end
			end),
		0, 0.25
	):OnComplete(
		function()
			if IsEquals(cover.gameObject) then
				destroy(cover.gameObject)
			end
		end 
	):SetEase(Enum.Ease.OutCubic)
end

function C:RefreshPageNumShow()
	for i = 1, #self.pageNumItems do
		if i == self.curIndex then
			self.pageNumItems[i]:Selected()
		else
			self.pageNumItems[i]:UnSelected()
		end
	end
end

function C:OnEnterForeGround()
	self:RefreshImageWithAnim()
	if self.changeTimer then
		self.changeTimer:Start()
	end
end

function C:OnEnterBackGround()
	if self.DT then
		self.DT:Kill()
		self.DT = nil
	end
	if self.changeTimer then
		self.changeTimer:Stop()
	end
end

function C:OnExitScene()
	self:MyExit()
end

function C:MyRefresh()

end
