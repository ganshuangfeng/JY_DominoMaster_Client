local basefunc = require "Game.Common.basefunc"
SlotsEggItem = basefunc.class()
local M = SlotsEggItem
M.name = "SlotsEggItem"

function M.Create(data)
    if not data or not data.parent or not IsEquals(data.parent) then return end
	return M.New(data)
end

function M:ctor(data)
    -- dump(data, "<color=data>SlotsEggItem data:</color>")
    self.data = data
    self:InitUI()
    self:AddListenerGameObject()
    self:Refresh()
end

function M:Exit()
    self:RemoveListenerGameObject()
    Destroy(self.gameObject)
    ClearTable(self)
end

function M:SetView(b)
    self.gameObject:SetActive(b)
end

function M:Refresh(data)
    self.data = data ~= nil and data or self.data

    self:SetId()
    self:SetOped()

    self.gameObject.name = self.data.index
end

function M:InitUI()
    self.gameObject = newObject("SlotsEggItem",self.data.parent)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3.zero
    LuaHelper.GeneratingVar(self.transform, self)
    self.ACT = self.gameObject:GetComponent("AnimationCurveTutor").curve
    self.bg_btn = self.bg_img.transform:GetComponent("Button")
    self.animator = self.gameObject:GetComponent("Animator")
    self.animator.enabled = false
end

function M:AddListenerGameObject()
    self.bg_btn.onClick:AddListener(function ()
        self:OnClickBg()
    end)
end

function M:RemoveListenerGameObject()
    self.bg_btn.onClick:RemoveAllListeners()
end

function M:GetPosition()
    if self.transform then
        return self.transform.position
    end
    return Vector3.zero
end

function M:SetIconSprite(sp)
    self.icon_img.sprite = sp
end

function M:SetId(id)
    self.data.id = id ~= nil and id or self.data.id
    if not self.data.id then
        return
    end
    self.icon_img.sprite = SlotsHelper.GetTexture("itemEgg".. self.data.id)
end

function M:SetOped(b)
    self.data.open = b
    -- self.bg_img.gameObject:SetActive(not b)
    self.icon_img.gameObject:SetActive(b)
    self.animator.enabled = b
end

function M:OnClickBg()
    ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_dianji.audio_name)
    local id = SlotsMiniGame3Panel.Instance:GetOpenItemId()
    if not id then
        return
    end
    self:SetId(id)
    self:SetOped(true)
    Event.Brocast("OpenEggItem",{id = self.data.id})
    if id == 1 then
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_mini.audio_name)  
    elseif id == 2 then
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_major.audio_name)  
    elseif id == 3 then
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_minor.audio_name)  
    elseif id == 4 then
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jp_grand.audio_name)  
    end
end