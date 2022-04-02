local basefunc = require "Game.Common.basefunc"
SlotsLionGameMini2Item = basefunc.class()
local M = SlotsLionGameMini2Item

M.name = "SlotsLionGameMini2Item"

function M.Create(data)
    if not data or not data.parent or not IsEquals(data.parent) then return end
	return M.New(data)
end

function M:ctor(data)
    self.data = data
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:Refresh()
end

function M:Exit()
    self:RemoveListener()
    Destroy(self.gameObject)
    ClearTable(self)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["MaxGoldChange"] = basefunc.handler(self, self.OnMaxGoldChange)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister or {}) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:OnMaxGoldChange(data)
    self:RefreshLock()
end

function M:RefreshLock()
    local mg = SlotsLionModel.GetMaxGold()
    local id = tonumber(self.data.id)
    id = id == 0 and 1 or id
    if id > tonumber(mg) then
        self:SetLock(true)
    else
        self:SetLock(false)
    end
end

function M:SetView(b)
    self.gameObject:SetActive(b)
end

function M:Refresh(data)
    self.data = data ~= nil and data or self.data
    self:SetId(self.data.id)
    self.gameObject.name = self.data.x .. "_" .. self.data.y
    self.transform.localPosition = SlotsLionLib.GetPositionByPos(self.data.x,
                                                                self.data.y,
                                                                SlotsLionGameMini2Panel.size.xSize,
                                                                SlotsLionGameMini2Panel.size.ySize,
                                                                SlotsLionGameMini2Panel.size.xSpac,
                                                                SlotsLionGameMini2Panel.size.ySpac)
end

function M:InitUI()
    self.gameObject = newObject("SlotsLionGameMini2Item",self.data.parent)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
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

function M:SetPosition(p)
    if not p then
        return
    end
    self.transform.position = p
end

function M:GetLocalPosition()
    if self.transform then
        return self.transform.localPosition
    end
    return Vector3.zero
end

function M:SetLocalPosition(p)
    if not p then
        return
    end
    self.transform.localPosition = p
end

function M:SetIconSprite(sp)
    self.icon_img.sprite = sp
end

function M:SetMaskSprite(sp)
    self.mask_img.sprite = sp
end

function M:SetId(id)
    self.data.id = id
    local sp = SlotsLionHelper.GetTexture("itemMini2_".. self.data.id)
    self:SetIconSprite(sp)
    local sp = SlotsLionHelper.GetTexture("itemMask".. self.data.id)
    self:SetMaskSprite(sp)
    self:RefreshLock()
end

function M:GetId()
    return self.data.id
end

function M:SetLock(b)
    if not IsEquals(self.gameObject) then
        return
    end
    self.mask_img.gameObject:SetActive(b)
    self.lock_img.gameObject:SetActive(b)
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