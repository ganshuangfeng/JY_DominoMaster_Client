-- 创建时间:2021-12-15
-- Panel:SlotsLionBetPanel
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

SlotsLionBetPanel = basefunc.class()
local M = SlotsLionBetPanel
M.name = "SlotsLionBetPanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["BetMoneyChange"] = basefunc.handler(self, self.OnBetMoneyChange)
    self.lister["MaxGoldChange"] = basefunc.handler(self, self.OnMaxGoldChange)
    self.lister["GameStatusChange"] = basefunc.handler(self, self.OnGameStatusChange)
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
	self:MyRefresh()
end

function M:InitLL()
end

function M:RefreshLL()
end

function M:InitUI()
	local tran = SlotsLionGamePanel.Instance.Interaction
	LuaHelper.GeneratingVar(tran, self)
	self.bet_txt = SlotsLionGamePanel.Instance.bet_txt
	self.money_txt = SlotsLionGamePanel.Instance.money_txt
	self.add_btn = SlotsLionGamePanel.Instance.add_btn
	self.add_btn_img = self.add_btn.transform:GetComponent("Image")
	self.reduce_btn = SlotsLionGamePanel.Instance.reduce_btn
	self.reduce_btn_img = self.reduce_btn.transform:GetComponent("Image")
	self.max_bet_btn = SlotsLionGamePanel.Instance.bet_btn
	self.max_bet_img = self.max_bet_btn.transform:GetComponent("Image")
	self.bet_txt_img = SlotsLionGamePanel.Instance.bet_txt_img
	self.max_bet_light_img = SlotsLionGamePanel.Instance.max_bet_light_img
end

function M:MyRefresh()
	self.lockMoney = false
	self:RefreshMoneyTxt()
	self:RefreshBetText()
	self:RefreshBtn()
	self:RefreshBtnInteractable()
end

function M:RefreshMoneyTxt()
	if self.lockMoney then
		return
	end
	local money = SlotsLionModel.GetPlayerMoney()
	self.money_txt.text = StringHelper.ToCash(money)
end

function M:RefreshMoneyTxtFix()
	local money = SlotsLionModel.GetPlayerMoney()
	self.money_txt.text = StringHelper.ToCash(money)
end

function M:RefreshBetText()
	local bet = SlotsLionModel.GetBet()
	--根据bet切换图片
	self.bet_txt.text = StringHelper.ToCash(bet.bet_money)
end

function M:RefreshBtn()
	local bet = SlotsLionModel.GetBet()
	local betCfg = SlotsLionModel.GetBetCfg()
	self.max_bet_light_img.gameObject:SetActive(bet.id == #betCfg)
	if bet.id == #betCfg then
		self.add_btn_img.material = GetMaterial("ImageGray")
	else
		self.add_btn_img.material = nil
	end

	if bet.id == 1 then
		self.reduce_btn_img.material = GetMaterial("ImageGray")
	else
		self.reduce_btn_img.material = nil
	end
end

function M:AddListenerGameObject()
	self.add_btn.onClick:AddListener(function ()
		self:OnClickAdd()
	end)
	self.reduce_btn.onClick:AddListener(function ()
		self:OnClickReduce()
	end)

	self.max_bet_btn.onClick:AddListener(function ()
		self:OnClickMaxBet()
	end)
end

function M:RemoveListenerGameObject()
	self.add_btn.onClick:RemoveAllListeners()
	self.reduce_btn.onClick:RemoveAllListeners()
end

function M:CheckAddBet()
	local bet =  SlotsLionModel.GetBet()
	local betCfg = SlotsLionModel.GetBetCfg()
	if bet.id == #betCfg then
		dump(bet,"<color=yellow>已经是配置中最高押注</color>")
		-- LittleTips.Create("bet max")
		return false
	end
	local maxPBet,errorDesc = SlotsLionLib.GetBetMaxByPermission()
	errorDesc = errorDesc or "error"
	local maxBet = SlotsLionLib.GetBetMaxByMoney()
	if maxBet.id == bet.id then
		if maxBet.id < maxPBet.id then
			dump({bet,maxBet,maxPBet},"<color=yellow>钱不够了</color>")
			SysBrokeSubsidyManager.RunBrokeProcess()
		elseif maxBet.id == maxPBet.id then
			dump({bet,maxBet,maxPBet},"<color=yellow>已经是当前可进行最高押注</color>")
			LittleTips.Create(errorDesc.error_desc)
		end
		return false
	end

	return true
end

function M:CheckRemoveBet()
	local bet =  SlotsLionModel.GetBet()
	if bet.id == 1 then
		dump(bet,"<color=yellow>已经是配置中最低押注</color>")
		-- LittleTips.Create("bet min")
		return false
	end
	return true
end

function M:OnClickAdd()
	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jiajianzhu.audio_name)
	if not self:CheckAddBet() then
		return
	end
	local bet =  SlotsLionModel.GetBet()
	local maxBet = SlotsLionLib.GetBetMaxByMoney()
	if bet.id < maxBet.id then
		SlotsLionModel.SetBet(SlotsLionLib.GetBetById(bet.id + 1))
	else
		SlotsLionModel.SetBet(SlotsLionLib.GetBetById(1))
	end
end

function M:OnClickReduce()
	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_jiajianzhu.audio_name)
	if not self:CheckRemoveBet() then
		return
	end
	local bet =  SlotsLionModel.GetBet()
	local maxBet = SlotsLionLib.GetBetMaxByMoney()
	if bet.id > 1 then
		SlotsLionModel.SetBet(SlotsLionLib.GetBetById(bet.id - 1))
	else
		SlotsLionModel.SetBet(SlotsLionLib.GetBetById(maxBet.id))
	end
end

function M:OnClickMaxBet()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local maxBet = SlotsLionLib.GetBetMaxByMoney()
	SlotsLionModel.SetBet(SlotsLionLib.GetBetById(maxBet.id))
end

--当前押注大于最大押注，调整到当前可进行的最大押注
function M:AdjustmentBet()
	local bet =  SlotsLionModel.GetBet()
	local maxBet = SlotsLionLib.GetBetMaxByMoney()
	if maxBet.id >= bet.id then
		--最大押注满足当前押注
		return
	end
	SlotsLionModel.SetBet(SlotsLionLib.GetBetById(maxBet.id))
end

function M:OnAssetChange(data)
	self:RefreshMoneyTxt()
	-- self:AdjustmentBet()
	if data.change_type == "slot_wushi_game_spend" then
		self.lockMoney = true
	end
end

function M:OnBetMoneyChange(data)
	self:RefreshBetText()
	self:RefreshBtn()
end

function M:OnMaxGoldChange(data)
	dump(data,"<color=yellow>最大奖池改变</color>")
	self:MaxGoldChangePlayEffect(data)
end

function M:RefreshBtnInteractable()
	local isIdle = SlotsLionModel.data.gameStatus == SlotsLionModel.GameStatus.idle
	local auto = SlotsLionModel.GetAuto()
	self.add_btn.interactable = not auto and isIdle
	self.reduce_btn.interactable = not auto and isIdle

	if not auto and isIdle then
		self.max_bet_img.sprite = GetTexture("xs_btn_max")
		self.bet_txt_img.sprite = GetTexture("xs_imgf_max")
		self.max_bet_img.raycastTarget = true
	else
		self.max_bet_img.sprite = GetTexture("xs_btn_maxzh")
		self.bet_txt_img.sprite = GetTexture("xs_imgf_maxzh")
		self.max_bet_img.raycastTarget = false
	end
	-- self.max_bet_btn.interactable = not auto and isIdle
end

function M:OnGameStatusChange()
	self:RefreshBtnInteractable()
end

function M:MaxGoldChangePlayEffect(data)
	if data.newMaxGold <= data.oldMaxGold then
		return
	end
end