
local basefunc = require "Game.Common.basefunc"

CommonTips = basefunc.class()
local M = CommonTips
M.name = "CommonTips"

local instance
-- parm = {desc = "描述",}
function M.Create(parm)
    if instance then
        instance:MyExit()
    end
    instance = M.New(parm)
    return instance
end

function M.Close()
    if instance then
        instance:PlayHide()
    end
end

function M:ctor(parm)
    self.parm = parm

    local parent = AdaptLayerParent("Canvas/LayerLv50")
    if not IsEquals(parent) then return end
    self.gameObject = newObject(M.name,parent)
    parent = nil
    LuaHelper.GeneratingVar(self.transform, self)
    
    self.desc_txt.text = self.parm.desc
    self:PlayShow()
end

function M:MyExit()
    destroy(self.gameObject)
    ClearTable(self)
end

function M:PlayShow()
    SetSpriteAendererAlpha(self.gameObject,0)
    DOFadeSpriteRender(self.gameObject,1,0.4)
end

function M:PlayHide()
    SetSpriteAendererAlpha(self.gameObject,1)
    DOFadeSpriteRender(self.gameObject,0,0.2,function ()
        self:MyExit()
    end)
end