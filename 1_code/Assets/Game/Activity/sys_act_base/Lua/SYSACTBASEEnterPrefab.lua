-- 创建时间:2019-09-25
-- Panel:JYFLEnterPrefab
--[[ *      ┌─┐       ┌─┐
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
 --]]
local basefunc = require "Game/Common/basefunc"

SYSACTBASEEnterPrefab = basefunc.class()
local C = SYSACTBASEEnterPrefab
C.name = "SYSACTBASEEnterPrefab"

local M = SYSACTBASEManager

function C.Create(parent, goto_type)
    return C.New(parent, goto_type)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["UpdateHallActivityYearRedHint"] = basefunc.handler(self, self.RefreshStatus)
    -- self.lister["fishing_ready_finish"] = basefunc.handler(self,self.on_fishing_ready_finish)
	-- self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
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

function C:ctor(parent, goto_type)
    ExtPanel.ExtMsg(self)

    self.goto_type = goto_type
    self.style_config = M.GetStyleConfig(self.goto_type)
    self.prefab_name = "SYSACTBASEEnterPrefab_" .. self.style_config.style_type
    dump(self.prefab_name,"<color=white>------>>>>>>>>>>>>>>-----></color>")
    -- if not self.style_config.prefab_map[self.prefab_name] or not GetPrefab(self.prefab_name) then
    --     self.prefab_name = "SYSACTBASEEnterPrefab"
    -- end
    local obj = newObject(self.prefab_name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:AddListenerGameObject()
end

function C:AddListenerGameObject()
	self.enter_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
    end)
end

function C:RemoveListenerGameObject()
	self.enter_btn.onClick:RemoveAllListeners()
end

function C:InitUI()
    -- self:CheckOpenPanel()
    -- if self.prefab_name == "SYSACTBASEEnterPrefab" then
        -- local image = self.enter_btn.transform:GetComponent("Image")
        -- image.sprite = GetTexture("lmqx_icon_1" .. self.style_config.style_type)
    -- end
    
    M.CheckIsYearPanelLeftNodeActToRefresh()
    self:MyRefresh()
end

function C:MyRefresh()
    self:RefreshStatus()
end

function C:OnEnterClick()
    local parm = {gotoui = M.key, goto_type = self.goto_type, goto_scene_parm = "panel"}
    Event.Brocast("global_hint_state_set_msg", parm)
    self:RefreshStatus()
    GameManager.GotoUI(parm)
end


function C:global_hint_state_change_msg(parm)
    if parm.gotoui == M.key
        and parm.goto_type == self.goto_type then
        self:RefreshStatus()
    end
end

function C:RefreshStatus()
    local st = M.GetHintState({gotoui = M.key, goto_type = self.goto_type})
    -- self.get_img.gameObject:SetActive(false)
    self.red_img.gameObject:SetActive(false)
    if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red or st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.red_img.gameObject:SetActive(true)
    -- elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
    --     self.get_img.gameObject:SetActive(true)
    end
end
