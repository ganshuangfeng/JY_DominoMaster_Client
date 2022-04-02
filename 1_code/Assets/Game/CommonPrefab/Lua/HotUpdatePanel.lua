-- 创建时间:2018-07-04

local basefunc = require "Game.Common.basefunc"

HotUpdatePanel = basefunc.class()
HotUpdatePanel.name = "HotUpdatePanel"

local RateWidth = 960
local RateHeight = 50

HotUpdatePanel.instance = nil
function HotUpdatePanel.Create(gameName, stateCallback, down_style)
	if HotUpdatePanel.instance then
		HotUpdatePanel.instance:OnBackClick()
	end
	if down_style then
		HotUpdatePanel.instance = HotUpdateSmallPanel.New(gameName, stateCallback, down_style)
		return HotUpdatePanel.instance
	else
		HotUpdatePanel.instance = HotUpdatePanel.New(gameName, stateCallback)
		return HotUpdatePanel.instance
	end
end
function HotUpdatePanel.Close()
	if HotUpdatePanel.instance then
		HotUpdatePanel.instance:OnBackClick()
	end
end
function HotUpdatePanel:ctor(gameName, stateCallback)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(HotUpdatePanel.name, parent)
	local tran = obj.transform
	self.gameName = gameName
	self.stateCallback = stateCallback
	self.transform = tran
	self.gameObject = obj
	self.gameScene = GameConfigToSceneCfg[gameName].SceneName
	self.gameTitle = GameConfigToSceneCfg[gameName].GameName
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.Progress = self.progress_bar:GetComponent("RectTransform")
	
	self:InitRect()
end
function HotUpdatePanel:InitRect()
	self.progress_title_txt.text = string.format(GLL.GetTx(1), self.gameTitle)
	self.Progress.sizeDelta = {x = 0, y = RateHeight}
	self.RateNode.localPosition = Vector3.New(0, 0, 0)
	
	self:UpdateAssetAsync()
end

function HotUpdatePanel:UpdateAssetAsync()
	gameMgr:DownloadUpdate(self.gameScene,
		function (state)
			self:DownloadState(state)
		end,
		function (val)
			self:DownloadProgress(val)
		end)
end
function HotUpdatePanel:DownloadState(state)
	print("<color=red>state = " .. state .. "</color>")
	if self.stateCallback then
		self.stateCallback(state)
	end
end
function HotUpdatePanel:DownloadProgress(val)
	if not IsEquals(self.Progress) then return end

	self.Progress.sizeDelta = {x = RateWidth * val, y = RateHeight}
	self.RateNode.localPosition = Vector3.New(RateWidth * val, 0, 0)

	self.progress_title_txt.text = string.format(GLL.GetTx(2), self.gameTitle, math.floor(val * 100))
end

-- 关闭
function HotUpdatePanel:MyExit()
	destroy(self.gameObject)
end
function HotUpdatePanel:OnBackClick()
	print("<color=red>关闭界面 HotUpdatePanel</color>")
	self:MyExit()
	HotUpdatePanel.instance = nil
end
