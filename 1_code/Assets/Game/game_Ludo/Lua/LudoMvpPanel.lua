-- 创建时间:2022-01-13
-- Panel:LudoMvpPanel
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

LudoMvpPanel = basefunc.class()
local C = LudoMvpPanel
C.name = "LudoMvpPanel"

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
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["nor_fxq_nor_rank_response"] = basefunc.handler(self, self.on_nor_fxq_nor_rank_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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
	Network.SendRequest("nor_fxq_nor_rank")
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
end

function C:RemoveListenerGameObject()
    self.close_btn.onClick:RemoveAllListeners()
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

function C:on_nor_fxq_nor_rank_response(_,data)
	dump(data,"<color=red>当前数据</color>")
	local init_stake = LudoModel.data.init_stake
	if data.result == 0 then
		if #data.player_infos > 2 then
			data.first_award = 3 * init_stake
			data.second_award = 1 * init_stake
		else
			data.first_award = 2 * init_stake
			data.second_award = nil
		end
	end

	self.top_items = {}
	self.main_items = {}
	if data.result == 0 then
		if data.first_award then
			local temp = {}
			local obj = GameObject.Instantiate(self.top_item,self.top_node)
			LuaHelper.GeneratingVar(obj.transform,temp)
			temp.top_img.sprite = GetTexture("MVP_1")
			temp.top_txt.text = StringHelper.AddPoint(data.first_award)
			obj.gameObject:SetActive(true)
			self.top_items[#self.top_items + 1] = obj
		end
		if data.second_award then
			local temp = {}
			local obj = GameObject.Instantiate(self.top_item,self.top_node)
			LuaHelper.GeneratingVar(obj.transform,temp)
			temp.top_img.sprite = GetTexture("MVP_2")
			temp.top_txt.text = StringHelper.AddPoint(data.second_award)
			obj.gameObject:SetActive(true)
			self.top_items[#self.top_items + 1] = obj
		end
		local s2cSeatNum = LudoModel.data.s2cSeatNum
		local img_config = {
			yellow = "ludo_qizi_huangse",
			blue = "ludo_qizi_lanse",
			red = "ludo_qizi_hongse",
			green = "ludo_qizi_lvse",
		}
		for i = 1,#data.player_infos do
			local temp = {}
			local obj = GameObject.Instantiate(self.main_item,self.mian_node)
			LuaHelper.GeneratingVar(obj.transform,temp)
			temp.rank_txt.text = i
			local Cseat = s2cSeatNum[data.player_infos[i].seat]
			local sprite = img_config[LudoLib.GetColor(Cseat)]
			temp.rank_chess_img.sprite = GetTexture(sprite)
			temp.rank_name_txt.text = data.player_infos[i].name
			temp.t1_txt.text = data.player_infos[i].kill
			temp.t2_txt.text = data.player_infos[i].bekill
			temp.t3_txt.text = data.player_infos[i].six
			obj.gameObject:SetActive(true)
			self.top_items[#self.top_items + 1] = obj
		end
	end
end