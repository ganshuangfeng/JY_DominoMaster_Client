local basefunc = require "Game/Common/basefunc"

QiuQiuExchangeChipPanel = basefunc.class()
local C = QiuQiuExchangeChipPanel
C.name = "QiuQiuExchangeChipPanel"
QiuQiuExchangeChipPanel.Auto = false
QiuQiuExchangeChipPanel.IsFirstInGame = true
local Instance
function C.Create()
	if Instance then
		return Instance
	else
		Instance = C.New()
	end
	return Instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	QiuQiuExchangeChipPanel.Auto = self.main_tge.isOn
	self:RemoveListener()
	self:RemoveListenerGameObject()
	Instance = nil
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Slider = self.transform:Find("Slider"):GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	--进入场次第一次筹码不够时，这个界面就会被系统打开。打开后默认是勾选状态，玩家在勾选状态关闭界面，则之后会自动补充，不会因为筹码不足被系统打开
	--退出场次再次进入又会走上面一样的规则，即每次进入场次第一次筹码不够系统会将窗口打开
	if QiuQiuExchangeChipPanel.IsFirstInGame then
		QiuQiuExchangeChipPanel.Auto = true
		QiuQiuExchangeChipPanel.IsFirstInGame = false
	end
	self.main_tge.isOn = QiuQiuExchangeChipPanel.Auto

	self.main_txt.text = GLL.GetTx(20039)
	self.shop_txt.text = GLL.GetTx(20040)
	self.redeem_txt.text = GLL.GetTx(20041)
	--SysBrokeSubsidyManager.RunBrokeProcess()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.add_chip_btn.onClick:AddListener(
		function ()
			if self.curr_slider_value < 20 then
				self.curr_slider_value = self.curr_slider_value + 1
			end
			self:OnSliderValueChanged()
		end
	)
	
	self.subtract_chip_btn.onClick:AddListener(
		function ()
			if self.curr_slider_value > 1 then
				self.curr_slider_value = self.curr_slider_value - 1
			end
			self:OnSliderValueChanged()
		end
	)

	self.Slider.onValueChanged:AddListener(
		function ()
			self.curr_slider_value = self.Slider.value
			self:OnSliderValueChanged()
		end
	)
	self.main_tge.onValueChanged:AddListener(
		function (isOn)
			QiuQiuExchangeChipPanel.Auto = isOn
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_switch.audio_name)
		end
	)

	self.shop_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
			GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
		end
	)
	self.redeem_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_press_down.audio_name)
			Network.SendRequest("fast_conver_chip",{chip = self.curr_value},nil,function (data)
				dump(data,"<color=red> 兑换筹码 </color>")
				if data.result == 0 then
					Event.Brocast("nor_qiuqiu_nor_score_change_msg","nor_qiuqiu_nor_score_change_msg",{seat_num = QiuQiuModel.data.seat_num,
						score = QiuQiuModel.data.score or 0,
						chip = QiuQiuModel.data.chip,						
					})
					Network.SendRequest("fast_huanzhuo",{force = 1})
				end
				self:MyExit()
			end)
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
end

function C:RemoveListenerGameObject()
	self.add_chip_btn.onClick:RemoveAllListeners()
	
	self.subtract_chip_btn.onClick:RemoveAllListeners()

	self.Slider.onValueChanged:RemoveAllListeners()
	self.main_tge.onValueChanged:RemoveAllListeners()

	self.shop_btn.onClick:RemoveAllListeners()
	self.redeem_btn.onClick:RemoveAllListeners()
	self.close_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()

end

function C:InitUI()
	local info = MainLogic.GetInfoByGameID(QiuQiuModel.data.game_id)
	self.min = info.chip_min
	self.max = math.min(info.chip_max - QiuQiuModel.GetMyChipNum(),MainModel.UserInfo.jing_bi - QiuQiuModel.GetMyChipNum())

	self.subtract_chip_txt.text = "Min "..StringHelper.ToCash(self.min)
	self.add_chip_txt.text = "Max "..StringHelper.ToCash(self.max)
	self.curr_slider_value = 1

	self:MyRefresh()
	self:OnSliderValueChanged()
end

function C:MyRefresh()
	local info = MainLogic.GetInfoByGameID(QiuQiuModel.data.game_id)
	if not info then return end
	self.my_chip_txt.text = StringHelper.AddPoint(MainModel.UserInfo.jing_bi)
	self.max = math.min(info.chip_max - QiuQiuModel.GetMyChipNum(),MainModel.UserInfo.jing_bi - QiuQiuModel.GetMyChipNum())
	self.subtract_chip_txt.text = "Min "..StringHelper.ToCash(self.min)
	self.add_chip_txt.text = "Max "..StringHelper.ToCash(self.max)
	self:OnSliderValueChanged()
end

function C:OnSliderValueChanged()
	self.Slider.value = self.curr_slider_value
	local value = (self.max - self.min) / 19 * (self.curr_slider_value - 1) + self.min
	self.mian_txt.text = StringHelper.ToCash(value)
	self.curr_value = math.floor(value) 
end

--自动兑换  补充数额通常为该场次最低携带筹码的2倍，若不足则取最大值。
function C.AutoExChange()
	local info = MainLogic.GetInfoByGameID(QiuQiuModel.data.game_id)
	local value = math.min(info.chip_min * 2,MainModel.UserInfo.jing_bi - QiuQiuModel.GetMyChipNum())
	Network.SendRequest("fast_conver_chip",{chip = value},nil,function (data)
		dump(data,"<color=red> 兑换筹码 </color>")
		if data.result == 0 then
			Event.Brocast("nor_qiuqiu_nor_score_change_msg","nor_qiuqiu_nor_score_change_msg",{seat_num = QiuQiuModel.data.seat_num,
				score = QiuQiuModel.data.score,
				chip = QiuQiuModel.data.chip,						
			})
			Network.SendRequest("fast_huanzhuo",{force = 1})
		end
	end)
end