local basefunc = require "Game/Common/basefunc"

LZHDPoker = basefunc.class()
local C = LZHDPoker
C.name = "LZHDPoker"

function C.Create(card_id,card_pos)
	return C.New(card_id,card_pos)
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

local point_config = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
local color_img_config = {"poker_fk","poker_ht","poker_hth","poker_mh"}
local color_config = {"#AF2B2B","#AF2B2B","#000000","#000000"}

-- ID:0代表这张牌是背面的
function C:ctor(card_id,card_pos)
	ExtPanel.ExtMsg(self)
	local parent = card_pos or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform

	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	if card_id > 0 then
		local card_data = LZHDLib.GetCardInfo(card_id)
		self.main_txt.text = "<color="..color_config[card_data.color]..">"..point_config[card_data.point].."</color>"
		--花色
		self.main2_img.sprite = GetTexture(color_img_config[card_data.color])
		self.main1_img.sprite = GetTexture(color_img_config[card_data.color])
	else
		self.main_bg_img.sprite = GetTexture("poker_pb")
		self.main1_img.gameObject:SetActive(false)
		self.main2_img.gameObject:SetActive(false)
		self.main_txt.gameObject:SetActive(false)
	end
	self.Animator = self.transform:GetComponent("Animator")
	self.Animator.enabled = false
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
end

function C:PlayShow()
	ExtendSoundManager.PlaySound(audio_config.big_battle.big_turn_card.audio_name)
	self.Animator.enabled = true
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end
