-- 创建时间:2022-01-12
-- Panel:ActYoukeBindPanel
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

ActYoukeBindPanel = basefunc.class()
local C = ActYoukeBindPanel
C.name = "ActYoukeBindPanel"

function C.Create(tag)
	return C.New(tag)
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
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(tag)
	self.tag = tag

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
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.fb_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnFBClick()
	end)
	self.gg_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGGClick()
	end)
end

function C:RemoveListenerGameObject()
	self.back_btn.onClick:RemoveAllListeners()
	self.fb_btn.onClick:RemoveAllListeners()
	self.gg_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
	self.line1_txt.text = GLL.GetTx(80039)
	self.line2_txt.text = GLL.GetTx(80040)
	self.line3_txt.text = GLL.GetTx(80041)
	self.hint1_txt.text = GLL.GetTx(80042)
	self.hint2_txt.text = GLL.GetTx(80038)
end

function C:RefreshLL()
end

function C:InitUI()
	if self.tag == "facebook" then
		self.fb_btn.gameObject:SetActive(true)
		self.gg_btn.gameObject:SetActive(false)
	else
		self.fb_btn.gameObject:SetActive(false)
		self.gg_btn.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnFBClick()
	print("<color=white>OnFBClick</color>")
    sdkMgr:FBLogin("", function (json_data)
    	dump(json_data, "[Bind] facebook json_data")
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[Bind] facebook exception: json_data invalid")
            return
        end

        dump(lua_tbl, "[Bind] facebook lua_tbl")

        if lua_tbl.result == 0 then
            local bindData = {
                channel_type = "facebook",
                channel_args = lua2json(lua_tbl)
            }
            self:Bind(bindData)
        else
            HintPanel.Create(1, GLL.GetTx(60007))
	    end
    end)
end

function C:OnGGClick()
	print("<color=white>OnGGClick</color>")
	sdkMgr:OnGGSignOut("", function (data)
	    sdkMgr:OnGGSignIn("", function (json_data)
	    	dump(json_data, "[Bind] google json_data")
	        local lua_tbl = json2lua(json_data)
	        if not lua_tbl then
	            print("[Bind] google exception: json_data invalid")
	            return
	        end

	        dump(lua_tbl, "[Bind] google lua_tbl")

	        if lua_tbl.result == 0 then
	            local bindData = {
	                channel_type = "google",
	                channel_args = lua2json(lua_tbl)
	            }
	            self:Bind(bindData)
	        else
	            HintPanel.Create(1, GLL.GetTx(60007))
		    end
	    end)
    end)
end


function C:Bind(bindData)
	Network.SendRequest("youke_bind_login_channel", bindData, "", function (data)
		if data.result == 0 then
			MainModel.UserInfo.name = data.name
			ActYoukeBindManager.Bind(self.tag)
			self:MyExit()
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
