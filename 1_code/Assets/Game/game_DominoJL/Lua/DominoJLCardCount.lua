-- 创建时间:2021-11-10
-- Panel:DominoJLCardCount
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

DominoJLCardCount = basefunc.class()
local C = DominoJLCardCount
C.name = "DominoJLCardCount"

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
	self.lister["model_nor_dmn_nor_cp_msg"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self.show_card_list = self.show_card_list or {}
	for i = 1,#self.show_card_list do
		self.show_card_list[i]:MyExit()
	end
	self.show_card_list = {}
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
	DominoJLCardCount.Instance = nil
end

function C:ctor()
	DominoJLCardCount.Instance = self
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:MyRefresh()
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	
end

function C:RemoveListenerGameObject()
	for k, v in pairs(self.item_list or {}) do
		EventTriggerListener.Get(v.item_click.gameObject).onDown = nil
		EventTriggerListener.Get(v.item_click.gameObject).onUp = nil
		
	end
end

local img_config = {
	[1] = "ty_dot_gp_1_1", 
	[2] = "ty_dot_gp_2_1",
	[3] = "ty_dot_gp_3_1",
	[4] = "ty_dot_gp_4_1",
	[5] = "ty_dot_gp_5_1",
	[6] = "ty_dot_gp_6_1",
}

function C:InitUI()
	self.item_list = {}

	for i = 1,7 do
		local temp_ui = {}
		local obj = GameObject.Instantiate(self.item,self.node)
		obj.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(obj.transform, temp_ui)
		temp_ui.item_img.sprite = GetTexture(img_config[ i - 1])
		if i - 1 == 0 then
			temp_ui.item_img.gameObject:SetActive(false)
		end
		temp_ui.item1_num_txt.text = 7
		temp_ui.item2_num_txt.text = 7
		EventTriggerListener.Get(temp_ui.item_click.gameObject).onDown = basefunc.handler(self,function ()
			self:ShowCard(i - 1)
		end)
		EventTriggerListener.Get(temp_ui.item_click.gameObject).onUp = basefunc.handler(self,self.HideCard)
		self.item_list[#self.item_list+1] = temp_ui
	end
end


function C:MyRefresh()
	local data = DominoJLModel.data
	if data.model_status ~= DominoJLModel.Model_Status.gaming
	or data.status == DominoJLModel.Status.ready
	or data.status == DominoJLModel.Status.begin
	or data.status == DominoJLModel.Status.dz
	then
		self.root.gameObject:SetActive(false)
		return
	end
	self.root.gameObject:SetActive(true)

	self:RefreshCardPoint()
	self:HideCard()
end

function C:GetRemCardCount()
	local myPaiList = DominoJLModel.GetMyPaiList()
	local tb_data = DominoJLModel.GetTablePai()
	local deskPaiList = {}
	for k, v in pairs(tb_data) do
		if v.pai ~= 0 then
			deskPaiList[#deskPaiList+1] = v.pai
		end
	end

	local remCard = DominoJLLib.GetRemCardCount(myPaiList,deskPaiList)
	return remCard
end

function C:GetRemCardByPoint(point)
	local myPaiList = DominoJLModel.GetMyPaiList()
	local tb_data = DominoJLModel.GetTablePai()
	local deskPaiList = {}
	for k, v in pairs(tb_data) do
		if v.pai ~= 0 then
			deskPaiList[#deskPaiList+1] = v.pai
		end
	end

	local remCard = DominoJLLib.GetRemCardByPoint(myPaiList,deskPaiList,point)
	return remCard
end

function C:GetCardByPoint(point)
	local card = DominoJLLib.GetCardByPoint(point)
	return card
end

function C:RefreshCardPoint()
	local remCard = self:GetRemCardCount()
	for i = 1,7 do
		local c = remCard[i - 1]
		self.item_list[i].item1_num_txt.text = c
		self.item_list[i].item2_num_txt.text = c
	end
end

function C:PlayCard()
	local remCard = self:GetRemCardCount()
	for i = 1,#self.item_list do
		local c = remCard[i - 1]
		self.item_list[i].item2_num_txt.text = c
		--如果当前和上一次的不一样
		if self.item_list[i].item2_num_txt.text ~= self.item_list[i].item1_num_txt.text then
			local seq = DoTweenSequence.Create()
			seq:Append(self.item_list[i].item1_num_txt.gameObject.transform:DOLocalMoveY(-40,0.5))
			seq:Join(self.item_list[i].item2_num_txt.gameObject.transform:DOLocalMoveY(0,0.5))
			seq:AppendCallback(
				function ()
					self.item_list[i].item1_num_txt.text = c
					self.item_list[i].item1_num_txt.gameObject.transform.localPosition = Vector3.zero
					self.item_list[i].item2_num_txt.gameObject.transform.localPosition = Vector3.New(0,40,0)
				end
			)
		end
	end
end

function C:ShowCard(point)
	local remCard = self:GetRemCardByPoint(point)
	local cardList = self:GetCardByPoint(point)
	cardList = MathExtend.SortList(cardList)
	self.show_card_list = self.show_card_list or {}
	if #self.show_card_list == 0 then
		for i, pai in ipairs(cardList) do
			local card = DominoJLCard.Create({parent = self.show_node,cardData = DominoJLLib.GetDataById(pai)})
			local b = true
			if remCard[pai] then
				b = false
			end
			card:SetGray(b)
			self.show_card_list[#self.show_card_list + 1] = card
		end
	else
		for i, pai in ipairs(cardList) do
			local card = self.show_card_list[i]
			card:InitPoint(DominoJLLib.GetDataById(pai))
			local b = true
			if remCard[pai] then
				b = false
			end
			card:SetGray(b)
			card.gameObject:SetActive(true)
		end
	end
	self.back_bg.gameObject:SetActive(true)
end

function C:HideCard()
	for k, v in pairs(self.show_card_list or {}) do
		v.gameObject:SetActive(false)
	end
	self.back_bg.gameObject:SetActive(false)
end

function C:PlayShow()
	dump(debug.traceback(),"<color=white>开始出现？？？？？？？？？？？？？？？？？？？</color>")
	self.root.gameObject:SetActive(true)
	local pos = self.root.transform.localPosition
	self.root.transform.localPosition = Vector3.New(pos.x,pos.y - 200,pos.z)
	local seq = DoTweenSequence.Create()
	seq:Append(self.root.transform:DOLocalMove(pos,1):SetEase(Enum.Ease.OutCirc))
	seq:OnForceKill(function ()
		if self.root and IsEquals(self.root.transform) then
			self.root.transform.localPosition = pos
		end
	end)
end