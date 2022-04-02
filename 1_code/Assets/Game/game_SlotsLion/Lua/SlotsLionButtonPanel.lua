-- 创建时间:2021-12-16
-- Panel:SlotsLionButtonPanel
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

SlotsLionButtonPanel = basefunc.class()
local M = SlotsLionButtonPanel
M.name = "SlotsLionButtonPanel"
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

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
    self.lister["AutoChange"] = basefunc.handler(self, self.OnAutoChange)
    self.lister["GameStatusChange"] = basefunc.handler(self, self.OnGameStatusChange)
    self.lister["slot_wushi_kaijiang_response"] = basefunc.handler(self, self.on_slot_wushi_kaijiang_response)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    if self.IsSoundOn ~= nil then
        soundMgr:SetIsSoundOn(self.IsSoundOn, MainModel.sound_pattern)
    end

    if self.IsMusicOn ~= nil then
        soundMgr:SetIsMusicOn(self.IsMusicOn, MainModel.sound_pattern)
    end

	self:RemoveListener()
	self:RemoveListenerGameObject()
	instance = nil
	M.Instance = nil
	ClearTable(self)
end

function M:ctor()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	self:AddListenerGameObject()
    self:InitAudio()

    self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	self.stop_btn = SlotsLionGamePanel.Instance.stop_btn
    self.stop_btn_img = self.stop_btn.transform:GetComponent("Image")
    self.stop_txt = SlotsLionGamePanel.Instance.stop_txt
    self.stop_img = SlotsLionGamePanel.Instance.stop_img
	self.lottery_btn = SlotsLionGamePanel.Instance.lottery_btn
    self.lottery_btn_img = self.lottery_btn.transform:GetComponent("Image")
    self.menu_btn = SlotsLionGamePanel.Instance.menu_btn
    self.menu_cd_txt = SlotsLionGamePanel.Instance.menu_cd_txt
    self.help_btn = SlotsLionGamePanel.Instance.help_btn
    self.quit_btn = SlotsLionGamePanel.Instance.quit_btn
    self.audio_btn = SlotsLionGamePanel.Instance.audio_btn
    self.audio_img = self.audio_btn.transform:GetComponent("Image")
    self.btns_node = SlotsLionGamePanel.Instance.btns_node
    self.shop_btn = SlotsLionGamePanel.Instance.shop_btn


    self.menuOP = false
end

function M:InitAudio()
    self.IsMusicOn = soundMgr:GetIsMusicOn(MainModel.sound_pattern)
    self.IsSoundOn= soundMgr:GetIsSoundOn(MainModel.sound_pattern)
    if self.IsMusicOn or self.IsSoundOn then
        self.audioOn = true
    else
        self.audioOn = false
    end
end

function M:MyRefresh()
    self:RefreshLotteryBtn()
    self:RefreshStopBtn()
    self:RefreshAudio()
end

function M:AddListenerGameObject()
	EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    self.stop_btn.onClick:AddListener(function ()
        self:OnClidkStop()
    end)

    self.menu_btn.onClick:AddListener(function ()
        self:OnClickMenu()
    end)

    self.help_btn.onClick:AddListener(function ()
        self:OnClidkHelp()
    end)

    self.quit_btn.onClick:AddListener(function ()
        self:OnClickQuit()
    end)

    self.audio_btn.onClick:AddListener(function ()
        self:OnClickAudio()
    end)

    self.shop_btn.onClick:AddListener(function ()
        self:OnClickShop()
    end)
end

function M:RemoveListenerGameObject()
	EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = nil
	EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = nil
	self.stop_btn.onClick:RemoveAllListeners()
	self.menu_btn.onClick:RemoveAllListeners()
	self.help_btn.onClick:RemoveAllListeners()
	self.quit_btn.onClick:RemoveAllListeners()
	self.audio_btn.onClick:RemoveAllListeners()
	self.shop_btn.onClick:RemoveAllListeners()
end

function M:OnClickLotteryDown()
    -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.lotteryAct = false
    local autoLottery = SlotsLionModel.GetTime(SlotsLionModel.time.autoLottery)
    local seq = DoTweenSequence.Create()
    seq:InsertCallback(autoLottery,function ()
        if self.lotteryAct then
            return
        end
        self.lotteryAct = true 
        SlotsLionAutoPanel.Create()
    end)
end

function M:OnClickLotteryUp()
    dump(self.lotteryAct,"<color=yellow>开奖按钮抬起？？？？？？</color>")
    if self.lotteryAct then
        return
    end
    ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_kaishi.audio_name)
    self.lotteryAct = true
    self.lottery_btn_img.raycastTarget = false
	--开奖
    SlotsLionGamePanel.Instance:Lottery()
end

--停止
function M:OnClidkStop()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not self.stopState or self.stopState ~= "red" then
        return
    end
    SlotsLionModel.SetAutoNum(0)
    SlotsLionModel.SetAuto(false)
	-- SlotsLionGamePanel.Instance:LotteryStop()

    --只取消main游戏的元素转动
    SlotsLionGamePanel.Instance:StopMainScroll()

    self.stopState = nil
    self:RefreshStopBtn()
end

function M:RefreshStopBtn()
    self.stop_btn_img.raycastTarget = true
    local auto = SlotsLionModel.GetAuto()
    local isShow = auto or SlotsLionModel.data.gameStatus == SlotsLionModel.GameStatus.run
    self.stop_btn.gameObject:SetActive(isShow)
    local autoNum = SlotsLionModel.GetAutoNum()

    if self.stopState and self.stopState == "red" and not auto and autoNum == 0 and SlotsLionModel.data.gameStatus ~= SlotsLionModel.GameStatus.run then
        self.stopState = nil
    end

    if autoNum == 0 then
        self.stop_txt.text = ""
        self.stop_img.transform.localPosition = Vector3(3.5,0,0)
    elseif autoNum < 0 then
        self.stop_txt.text = "OO"
        self.stop_img.transform.localPosition = Vector3(3.5,10,0)
    else
        self.stop_txt.text = autoNum
        self.stop_img.transform.localPosition = Vector3(3.5,10,0)
    end

    if self.stopState and self.stopState == "red" then
        self.stop_btn_img.sprite = GetTexture("xs_btn_spinh")
        self.stop_img.sprite = GetTexture("xs_imgf_spinh")
    else
        self.stop_btn_img.sprite = GetTexture("xs_btn_spinzh")
        self.stop_img.sprite = GetTexture("xs_imgf_stopzh")
    end
end

function M:RefreshLotteryBtn()
    local auto = SlotsLionModel.GetAuto()
    if auto then
        self.lottery_btn.gameObject:SetActive(false)
        return
    end
    self.lottery_btn_img.raycastTarget = true
    self.lottery_btn.gameObject:SetActive(SlotsLionModel.data.gameStatus == SlotsLionModel.GameStatus.idle)
end

function M:RefreshMenu()
    if not self.menuCD or self.menuCD <= 0 then
        self.menuOP = false
        self.menu_cd_txt.text = ""
    else
        self.menu_cd_txt.text = self.menuCD
    end
    self.btns_node.gameObject:SetActive(self.menuOP)
end

function M:OnAutoChange(data)
    if not data.newAuto then
        self.stopState = nil
    end
    self:MyRefresh()
end

function M:OnGameStatusChange(data)
    self:MyRefresh()
end

function M:on_slot_wushi_kaijiang_response(proto_name,data)
    self.lottery_btn_img.raycastTarget = true
    if data.result == 0 then
        self.stopState = "red"
        self.stop_btn_img.raycastTarget = false
        local seq = SlotsLionHelper.GetSeq()
        seq:InsertCallback(0.4,function ()
            self:RefreshStopBtn()
        end)
    else
        self.stop_btn_img.raycastTarget = true
    end
end

--********************onClick
function M:OnClickMenu()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.menuOP = not self.menuOP

    if self.menuOP then
        self.menuCD = 3
        self:RefreshMenu()
        SlotsLionEffect.ShowMenuBtns(self.audio_btn,self.quit_btn)
        self:MenuAutoHide(self.menuOP)
    else
        self.menuCD = -1
        self:RefreshMenu()
        if self.seqMenuHide then
            self.seqMenuHide:Kill()
        end
    end
end

function M:MenuAutoHide(activeSelf)
    --自动关闭
    if not activeSelf then
        return
    end

    if self.seqMenuHide then
        self.seqMenuHide:Kill()
    end
    local cd = self.menuCD
    self.seqMenuHide = DoTweenSequence.Create()
    for i = 1, cd + 1 do
        self.seqMenuHide:InsertCallback(i,function ()
            self.menuCD = self.menuCD - 1
            self:RefreshMenu()
        end)
    end
end

function M:OnClidkHelp()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    SlotsLionHelpPanel.Show(true)
end

function M:OnClickQuit()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SlotsLionGamePanel.Instance:QuitGame()
end

function M:OnClickAudio()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.audioOn = not self.audioOn

	soundMgr:SetIsMusicOn(self.audioOn, MainModel.sound_pattern)
    soundMgr:SetIsSoundOn(self.audioOn, MainModel.sound_pattern)

    self:RefreshAudio()
end

function M:RefreshAudio()
    if self.audioOn == false then
        self.audio_img.sprite = GetTexture("xs_btn_jy")
    else
        self.audio_img.sprite = GetTexture("xs_btn_yxg")
    end
end

function M:OnClickShop()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
end