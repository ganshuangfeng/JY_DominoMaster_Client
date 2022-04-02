-- 创建时间:2021-12-15
-- Panel:SlotsBetPanel
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

SlotsBetPanel = basefunc.class()
local M = SlotsBetPanel
M.name = "SlotsBetPanel"

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
	local tran = SlotsGamePanel.Instance.left_element_node
	LuaHelper.GeneratingVar(tran, self)
	tran = SlotsGamePanel.Instance.right_element_node
	LuaHelper.GeneratingVar(tran, self)
	self.bet_txt = SlotsGamePanel.Instance.bet_txt
	self.money_txt = SlotsGamePanel.Instance.money_txt
	self.add_btn = SlotsGamePanel.Instance.add_btn
	self.add_btn_img = self.add_btn.transform:GetComponent("Image")
	self.reduce_btn = SlotsGamePanel.Instance.reduce_btn
	self.reduce_btn_img = self.reduce_btn.transform:GetComponent("Image")
	self.max_bet_btn = SlotsGamePanel.Instance.bet_btn
	self.max_bet_img = self.max_bet_btn.transform:GetComponent("Image")
	self.bet_txt_img = SlotsGamePanel.Instance.bet_txt_img
	self.max_bet_light_img = SlotsGamePanel.Instance.max_bet_light_img
end

function M:MyRefresh()
	self.lockMoney = false
	self:RefreshMoneyTxt()
	self:RefreshBetText()
	self:RefreshItemImg()
	self:RefreshBtn()
	self:RefreshBtnInteractable()
	self:RefreshEffect()
end

function M:RefreshItemImg()
	local bet = SlotsModel.GetBet()
	self.left_item_1_img.sprite = bet.max_gold >= 4 and SlotsHelper.GetTexture("itemC") or SlotsHelper.GetTexture("item8")
	self.left_item_2_img.sprite = bet.max_gold >= 3 and SlotsHelper.GetTexture("itemB") or SlotsHelper.GetTexture("item7")
	self.left_item_3_img.sprite = bet.max_gold >= 2 and SlotsHelper.GetTexture("itemA") or SlotsHelper.GetTexture("item6")
	self.left_item_4_img.sprite = bet.max_gold >= 1 and SlotsHelper.GetTexture("item9") or SlotsHelper.GetTexture("item5")
	self.left_item_5_img.sprite = SlotsHelper.GetTexture("item4")

	self.right_item_1_img.sprite = bet.max_gold >= 4 and SlotsHelper.GetTexture("itemC") or SlotsHelper.GetTexture("item8")
	self.right_item_2_img.sprite = bet.max_gold >= 3 and SlotsHelper.GetTexture("itemB") or SlotsHelper.GetTexture("item7")
	self.right_item_3_img.sprite = bet.max_gold >= 2 and SlotsHelper.GetTexture("itemA") or SlotsHelper.GetTexture("item6")
	self.right_item_4_img.sprite = bet.max_gold >= 1 and SlotsHelper.GetTexture("item9") or SlotsHelper.GetTexture("item5")
	self.right_item_5_img.sprite = SlotsHelper.GetTexture("item4")
end

function M:RefreshMoneyTxt()
	if self.lockMoney then
		return
	end
	local money = SlotsModel.GetPlayerMoney()
	self.money_txt.text = StringHelper.ToCash(money)
end

function M:RefreshMoneyTxtFix()
	local money = SlotsModel.GetPlayerMoney()
	self.money_txt.text = StringHelper.ToCash(money)
end

function M:RefreshBetText()
	local bet = SlotsModel.GetBet()
	--根据bet切换图片
	self.bet_txt.text = StringHelper.ToCash(bet.bet_money)
end

function M:RefreshBtn()
	local bet = SlotsModel.GetBet()
	local betCfg = SlotsModel.GetBetCfg()
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
	local bet =  SlotsModel.GetBet()
	local betCfg = SlotsModel.GetBetCfg()
	if bet.id == #betCfg then
		dump(bet,"<color=yellow>已经是配置中最高押注</color>")
		-- LittleTips.Create("bet max")
		return false
	end
	local maxPBet,errorDesc = SlotsLib.GetBetMaxByPermission()
	errorDesc = errorDesc or "error"
	local maxBet = SlotsLib.GetBetMaxByMoney()
	if maxBet.id == bet.id then
		if maxBet.id < maxPBet.id then
			dump({bet,maxBet,maxPBet},"<color=yellow>钱不够了</color>")
			SysBrokeSubsidyManager.RunBrokeProcess()
		elseif maxBet.id == maxPBet.id then
			dump({bet,maxBet,maxPBet},"<color=yellow>已经是当前可进行最高押注</color>")
			LittleTips.Create(errorDesc)
		end
		return false
	end

	return true
end

function M:CheckRemoveBet()
	local bet =  SlotsModel.GetBet()
	if bet.id == 1 then
		dump(bet,"<color=yellow>已经是配置中最低押注</color>")
		-- LittleTips.Create("bet min")
		return false
	end
	return true
end

function M:OnClickAdd()
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jiajianzhu.audio_name)
	if not self:CheckAddBet() then
		return
	end
	local bet =  SlotsModel.GetBet()
	local maxBet = SlotsLib.GetBetMaxByMoney()
	if bet.id < maxBet.id then
		SlotsModel.SetBet(SlotsLib.GetBetById(bet.id + 1))
	else
		SlotsModel.SetBet(SlotsLib.GetBetById(1))
	end
end

function M:OnClickReduce()
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jiajianzhu.audio_name)
	if not self:CheckRemoveBet() then
		return
	end
	local bet =  SlotsModel.GetBet()
	local maxBet = SlotsLib.GetBetMaxByMoney()
	if bet.id > 1 then
		SlotsModel.SetBet(SlotsLib.GetBetById(bet.id - 1))
	else
		SlotsModel.SetBet(SlotsLib.GetBetById(maxBet.id))
	end
end

function M:OnClickMaxBet()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local maxBet = SlotsLib.GetBetMaxByMoney()
	SlotsModel.SetBet(SlotsLib.GetBetById(maxBet.id))
end

--当前押注大于最大押注，调整到当前可进行的最大押注
function M:AdjustmentBet()
	local bet =  SlotsModel.GetBet()
	local maxBet = SlotsLib.GetBetMaxByMoney()
	if maxBet.id >= bet.id then
		--最大押注满足当前押注
		return
	end
	SlotsModel.SetBet(SlotsLib.GetBetById(maxBet.id))
end

function M:OnAssetChange(data)
	self:RefreshMoneyTxt()
	-- self:AdjustmentBet()
	if data.change_type == "slot_jymt_game_spend" then
		self.lockMoney = true
	end
end

function M:OnBetMoneyChange(data)
	self:RefreshBetText()
	self:RefreshBtn()
end

function M:OnMaxGoldChange(data)
	dump(data,"<color=yellow>最大奖池改变</color>")
	self:RefreshItemImg()
	self:MaxGoldChangePlayEffect(data)
end

function M:RefreshBtnInteractable()
	local isIdle = SlotsModel.data.gameStatus == SlotsModel.GameStatus.idle
	local auto = SlotsModel.GetAuto()
	self.add_btn.interactable = not auto and isIdle
	self.reduce_btn.interactable = not auto and isIdle

	if not auto and isIdle then
		self.max_bet_img.sprite = GetTexture("fxgz_btn_fs")
		self.bet_txt_img.sprite = GetTexture("fxgz_imgf_max")
		self.max_bet_img.raycastTarget = true
	else
		self.max_bet_img.sprite = GetTexture("fxgz_btn_maxzh1")
		self.bet_txt_img.sprite = GetTexture("fxgz_imgf_maxh")
		self.max_bet_img.raycastTarget = false
	end
	-- self.max_bet_btn.interactable = not auto and isIdle
end

function M:OnGameStatusChange()
	self:RefreshBtnInteractable()
end

function M:RefreshEffect()
	for i = 1, 5 do
		self["left_item_".. 1  .."_effect"].gameObject:SetActive(false)
		self["right_item_".. 1  .."_effect"].gameObject:SetActive(false)
	end
end

function M:MaxGoldChangePlayEffect(data)
	if data.newMaxGold <= data.oldMaxGold then
		return
	end

	local t = {
		[1] = 4,
		[2] = 3,
		[3] = 2,
		[4] = 1,

	}

	self["left_item_".. t[data.newMaxGold]  .."_effect"].gameObject:SetActive(false)
	self["right_item_".. t[data.newMaxGold]  .."_effect"].gameObject:SetActive(false)

	self["left_item_".. t[data.newMaxGold]  .."_effect"].gameObject:SetActive(true)
	self["right_item_".. t[data.newMaxGold]  .."_effect"].gameObject:SetActive(true)
end