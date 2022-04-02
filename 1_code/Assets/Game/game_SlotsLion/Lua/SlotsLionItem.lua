local basefunc = require "Game.Common.basefunc"
SlotsLionItem = basefunc.class()
local M = SlotsLionItem

M.name = "SlotsLionItem"

function M.Create(data)
    if not data or not data.parent or not IsEquals(data.parent) then return end
	return M.New(data)
end

function M:ctor(data)
    -- dump(data, "<color=data>SlotsLionItem data:</color>")
    self.data = data
    self:InitUI()
    self:Refresh()
end

function M:Exit()
    Destroy(self.gameObject)
    ClearTable(self)
end

function M:SetView(b)
    self.gameObject:SetActive(b)
end

function M:Refresh(data)
    self.data = data ~= nil and data or self.data

    self:SetId(self.data.id)
    self:SetRate(self.data.rate)
    self.gameObject.name = self.data.x .. "_" .. self.data.y
    self.transform.localPosition = SlotsLionLib.GetPositionByPos(self.data.x,self.data.y)
end

function M:InitUI()
    self.gameObject = newObject("SlotsLionItem",self.data.parent)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.animator = self.icon_img.transform:GetComponent("Animator")
    self.mask = self.transform:GetComponent("Mask")
    self.ACT = self.gameObject:GetComponent("AnimationCurveTutor")
end

function M:SetPos(x,y)
    self.data.x = x
    self.data.y = y
    self.gameObject.name = self.data.x .. "_" .. self.data.y
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
    self.data.id = id
    local sp = SlotsLionHelper.GetTexture("item".. self.data.id)
    self:SetIconSprite(sp)
end

function M:GetId()
    return self.data.id
end

function M:SetRateData(rate)
    self.data.rate = rate
end

function M:SetRate(rate)
    self.data.rate = rate
    local txt = self.data.rate or ""
    self:SetRateTxt(txt)
end

function M:GetRate()
    return self.data.rate or 0
end

function M:SetRateTxt(txt)
    self.rate_txt.text = txt
    self.rate_txt.gameObject:SetActive(true)
end

function M:SetMat(mat)
    if not mat then
        self.icon_img.material = nil
        return
    end
    self.icon_img.material = GetMaterial(mat)
end

function M:SetActive(b)
    if not IsEquals(self.gameObject) then
        return
    end
    self.gameObject:SetActive(b)
end

function M:SetBGActive(b)
    if not IsEquals(self.gameObject) then
        return
    end
    self.bg_img.gameObject:SetActive(b)
end

function M:GetAnimationCurveByName(name)
    if not self.ACT then
        return
    end

    return self.ACT:GetAnimationCurve(name)
end


function M:GetAnimationCurveByIndex(i)
    if not self.ACT then
        return
    end

    return self.ACT[i]
end

function M:PlayEffect()
    self.icon_img.gameObject:SetActive(false)
    SlotsLionEffect.PlayScrollItemEffect(SlotsLionLib.GetItemIndexById(self.data.id),self.data.x,self.data.y)
end

function M:StopEffect()
    if not IsEquals(self.gameObject) then
        return
    end
    self.icon_img.gameObject:SetActive(true)
    SlotsLionEffect.StopAllScrollItemEffect()
end