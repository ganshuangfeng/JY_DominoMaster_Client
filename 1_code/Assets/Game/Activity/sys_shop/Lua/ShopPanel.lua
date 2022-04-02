-- 创建时间:2021-12-06
-- Panel:ShopPanel
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

ShopPanel = basefunc.class()
local C = ShopPanel
C.name = "ShopPanel"

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
    self.lister["AssetChange"] = basefunc.handler(self,self.RefreshAsset)
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.vip_small and self.vip_small.MyExit then
		self.vip_small:MyExit()
		self.vip_small = nil
	end
	self:CloseShopCell()
	self:CloseTagCell()
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.back_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	EventTriggerListener.Get(self.scroll.gameObject).onEndDrag = function()
		local VNP = self.scroll.verticalNormalizedPosition  
		if VNP <= 0 then 
			self.down_jt.gameObject:SetActive(false)
		else
			if #self.shop_list > 6 then
				self.down_jt.gameObject:SetActive(true)
			else
				self.down_jt.gameObject:SetActive(false)
			end		
		end
	end
end

function C:RemoveListenerGameObject()
	if IsEquals(self.gameObject) then
		self.back_btn.onClick:RemoveAllListeners()
		EventTriggerListener.Get(self.scroll.gameObject).onEndDrag = nil
	end
end

function C:InitLL()
	self.hint_txt.text = GLL.GetTx(80063)
end

function C:RefreshLL()
	self:InitLL()
end

function C:InitUI()
	
	self.scroll = self.ScrollView:GetComponent("ScrollRect")
	
	self.select_tag = "google"
	self:MyRefresh()
	self:RefreshDefaultTag()
end

function C:MyRefresh()
	self:RefreshAsset()
	self:RefreshTag()
	self:RefreshSelect()

	self.vip_small = GameManager.GotoUI({gotoui = "sys_vip", goto_scene_parm = "small", parent = self.top, selfParent = self})
end

function C:RefreshAsset()
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.rp_txt.text = StringHelper.ToRedNum(MainModel.UserInfo.shop_gold_sum)
end

function C:RefreshSelect()
	self:RefreshShop()

	for k,v in ipairs(self.tag_cell) do
		v:SetSelect(self.select_tag)
	end

	if self.select_tag == "google" then
		self.pay_hint.gameObject:SetActive(false)
	else
		self.pay_hint.gameObject:SetActive(true)
	end

	if GameGlobalOnOff.TS then
		self.pay_hint.gameObject:SetActive(false)
		self.rp.gameObject:SetActive(true)
	end
end

function C:RefreshDefaultTag()
	if not table_is_null(self.tag_list) then
		self:OnTagClick(self.tag_list[1])
	end
end

function C:RefreshTag()
	self.tag_list = SysShopManager.GetTagList()
	self:CloseTagCell()

	for k,v in ipairs(self.tag_list) do
		local pre = ShopTagPrefab.Create(self.tag, v, self.OnTagClick, self)
		self.tag_cell[#self.tag_cell + 1] = pre

		if #self.tag_list == k then
			pre.bang.gameObject:SetActive(false)
		end
	end
end
function C:CloseTagCell()
	if self.tag_cell then
		for k,v in ipairs(self.tag_cell) do
			v:OnDestroy()
		end
	end
	self.tag_cell = {}
end
function C:OnTagClick(data)
	if data.tag ~= self.select_tag then
		self.select_tag = data.tag
		self:RefreshSelect()
	end
end

function C:RefreshShop()
	self.shop_list = SysShopManager.GetShopByTag(self.select_tag)
	MathExtend.SortList(self.shop_list, "ui_order", true)

	self:CloseShopCell()

	local column_num = math.floor( (#self.shop_list + 2) / 3 )

	self.shop_node_list = {}
	for i = 1, column_num do
		local b = GameObject.Instantiate(GetPrefab("ShopColumnPrefab"), self.column_node)
		b.gameObject.name = "ShopColumnPrefab" .. i
		self.shop_cell_db[#self.shop_cell_db + 1] = b.gameObject

		local ui_t = {}
		LuaHelper.GeneratingVar(b.transform, ui_t)
		self.shop_node_list[3*(i-1) + 1] = ui_t.node1
		self.shop_node_list[3*(i-1) + 2] = ui_t.node2
		self.shop_node_list[3*(i-1) + 3] = ui_t.node3
	end

	for k,v in ipairs(self.shop_list) do
		local pre = ShopPrefab.Create(self.shop_node_list[k], v, self, self.OnCellClick)
		self.shop_cell[#self.shop_cell + 1] = pre
	end	
	self:RefreshScrollPos(0)

	if #self.shop_list > 6 then
		self.down_jt.gameObject:SetActive(true)
	else
		self.down_jt.gameObject:SetActive(false)
	end
end
function C:CloseShopCell()
	if self.shop_cell then
		for k,v in ipairs(self.shop_cell) do
			v:OnDestroy()
		end
	end
	self.shop_cell = {}

	if self.shop_cell_db then
		for k,v in ipairs(self.shop_cell_db) do
			destroy(v)
		end
	end
	self.shop_cell_db = {}
end

function C:OnCellClick(data)
	dump(data, "<color=red>OnCellClick </color>")
	local ext_data = {channel_type = self.select_tag}
	if self.select_tag == "RP" then
		if GameItemModel.GetItemCount("shop_gold_sum") < data.use_count/100 then
			HintPanel.Create(1, GLL.GetTx(80058))
		else
			local cfg = GameItemModel.GetItemToKey(data.type)
	        HintPanel.Create(2, string.format(GLL.GetTx(80059), StringHelper.ToRedNum(data.use_count/100), StringHelper.ToCash(data.num), cfg.name), function ()
                Network.SendRequest("pay_exchange_goods", {goods_type = data.type, goods_id = data.id}, "", function (_data)
	                if _data.result ~= 0 then
	                    HintPanel.ErrorMsg(_data.result)
	                end
	            end)
	        end)
		end
	else
		PayManager.Pay(data, ext_data)
	end
end

function C:RefreshScrollPos(y)
    coroutine.start(function ( )
        Yield(0)
        Yield(0)--间隔一帧不得行
        if IsEquals(self.scroll) then
	        self.scroll:StopMovement()
	        if IsEquals(self.column_node) then
	            self.column_node.transform.localPosition = Vector3.New(0, y, 0)
	        end
        end
    end)
end