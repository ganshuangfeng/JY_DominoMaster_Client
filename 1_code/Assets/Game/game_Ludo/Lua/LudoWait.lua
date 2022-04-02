-- 创建时间:2021-12-02
-- Panel:LudoWait
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

LudoWait = basefunc.class()
local C = LudoWait
C.name = "LudoWait"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	CommonAnim.StopCountDown(self.waitCDSeq)
	self:RemoveListener()
	ClearTable(self)
	-- destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	self.gameObject = GameObject.Find("Canvas/GUIRoot/LudoGamePanel/@wait_node").gameObject
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.CG = self.transform:GetComponent("CanvasGroup")
	self.CG.alpha = 1
	self:MyRefresh()
end

function C:RefreshLL()
	
end

function C:ShowHideWaitInfo(list,on_off)
	for i = 1,#list do
		self["wait_player"..list[i]].gameObject:SetActive(on_off)
	end
end

function C:SetWaitInfo(CSeatNum,head_link,name)
	local temp_ui = {}
	local obj = self["wait_player"..CSeatNum]
	LuaHelper.GeneratingVar(obj.transform,temp_ui)
	SetHeadImg(head_link, self.head_img)
	temp_ui.wait_name_txt.text = name
end

function C:MyRefresh()
	local m_data = LudoModel.data
    if m_data.model_status == LudoModel.Model_Status.wait_table
	or m_data.model_status == LudoModel.Model_Status.wait_begin
	then
		CommonAnim.StopCountDown(self.waitCDSeq)
		self.waitCDSeq = CommonAnim.PlayCountDown(1000,1,self.transform)
		self:ShowHideWaitInfo({1},true)
		self:ShowHideWaitInfo({2,3,4},false)
		self:SetWaitInfo(1,MainModel.UserInfo.head_image,MainModel.UserInfo.name)
		self.gameObject:SetActive(true)
		self.vs_img.gameObject:SetActive(false)
	elseif m_data.model_status == LudoModel.Model_Status.gaming then
		if m_data.status ~= LudoModel.Status.ready then
			CommonAnim.StopCountDown(self.waitCDSeq)
			self.gameObject:SetActive(false)
		else
			self.vs_img.gameObject:SetActive(false)
			self.gameObject:SetActive(true)
			self:ShowHideWaitInfo({1,2,3,4},false)
			for SSeatNum, playerInfo in pairs(m_data.players_info) do
				local CSeatNum = m_data.s2cSeatNum[SSeatNum]
				if next(playerInfo) then
					self:ShowHideWaitInfo({CSeatNum},true)
					self:SetWaitInfo(CSeatNum,playerInfo.head_link,playerInfo.name)
				else
					self:ShowHideWaitInfo({CSeatNum},false)
				end
			end
		end
    elseif m_data.model_status == LudoModel.Model_Status.gameover then
		CommonAnim.StopCountDown(self.waitCDSeq)
		self.gameObject:SetActive(false)
    end
end

function C:PlayReady(data)
	local CSeatNum = LudoModel.data.s2cSeatNum[data.seat_num]
	local playerInfo = LudoModel.data.players_info[data.seat_num]
	self:SetWaitInfo(CSeatNum,playerInfo.head_link,playerInfo.name)
	self:ShowHideWaitInfo({CSeatNum},true)
end

function C:PlayBegin()
	CommonAnim.StopCountDown(self.waitCDSeq)
	self.vs_img.gameObject:SetActive(true)
	self.mid_award_txt.text = ""
	local seq = DoTweenSequence.Create()
	seq:Append(self.vs_img.transform:DOScale(1,0.3))
	seq:Append(self.vs_img.transform:DOScale(0,0.3))
	seq:AppendCallback(
		function ()
			self.vs_img.gameObject:SetActive(false)
			self.mid_award_img.gameObject:SetActive(true)
			self.mid_award_txt.text = ""
		end
	)
	seq:Append(self.mid_award_img.transform:DOScale(1,0.5))
	seq:Append(self.mid_award_img.transform:DOScale(0.5,0.3))

	local jb_objs = {}
	local curr_jb = 0
	local fly_to = function (obj,each)
		local seq = DoTweenSequence.Create()
		seq:Append(obj.transform:DOMove(self.mid_award_img.gameObject.transform.position,0.4))
		seq:AppendCallback(
			function ()
				obj.gameObject:SetActive(false)
			end
		)
		seq:Append(self.mid_award_img.transform:DOScale(0.6,0.07))
		seq:Append(self.mid_award_img.transform:DOScale(0.5,0.07))

		curr_jb = curr_jb + each

		self.mid_award_txt.text = math.floor(curr_jb)
	end

	local obj_list = {}
	seq:AppendInterval(0.1)
	seq:AppendCallback(
		function ()
			for i = 1,4 do
				local is_on = self["wait_player"..i].gameObject.activeSelf
				if is_on then
					local init_stake = LudoModel.data.init_stake
					--防止网络差的时候崩溃
					init_stake = init_stake or 0
					local each = init_stake / 10
					local seq2 = DoTweenSequence.Create()
					for ii = 1,10 do
						seq2:AppendInterval(0.1)
						seq2:AppendCallback(
							function ()
								local obj = newObject("ldq_jm_jb",self["wait_player"..i].gameObject.transform)
								obj.transform.position = self["wait_player"..i].gameObject.transform:Find("@kuang_img").transform.position
								fly_to(obj,each)
								obj_list[#obj_list+1] = obj
							end
						)
					end
				end
			end
		end
	)
	seq:AppendInterval(1.5)
	seq:Append(self.mid_award_img.transform:DOLocalMove(Vector3.New(-555,80,0),0.6))
	seq:Join(self.mid_award_img.transform:DOScale(0.3,0.6))
	seq:AppendCallback(
		function ()
			self.mid_award_img.gameObject:SetActive(false)
			self.mid_award_img.gameObject.transform.localPosition = Vector3.New(0,44.5,0)
			local obj = newObject("UI_hezi_gx",self.transform)
			obj.transform.localPosition = Vector3.New(-555,80,0)
			GameObject.Destroy(obj,2)
		end
	)
	seq:Append(self.CG:DOFade(0,2))
	seq:AppendCallback(
		function ()
			self.CG.alpha = 1
			self.gameObject:SetActive(false)
			for i = 1,#obj_list do
				GameObject.Destroy(obj_list[i])
			end
		end
	)
end