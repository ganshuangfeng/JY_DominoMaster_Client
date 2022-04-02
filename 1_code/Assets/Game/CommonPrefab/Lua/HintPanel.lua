
local basefunc = require "Game.Common.basefunc"

HintPanel = basefunc.class()

--[[提示板
    type = 1 - 确认
    type = 2 - 确认 取消
    type = 3 - 确认 取消 关闭
    type = 4 - 关闭
    type = 5 - 确认 关闭
    type = 6 - 确认 取消 关闭 (关闭不触发cancelCbk)
    msg - 显示的消息
    confirmCbk - 确定按钮回调
    cancelCbk - 取消按钮回调

    理论上来说应该只有一个实例，不会有两个提示板同时存在
    但是这里仍然使用类进行，即可以多个实例
    层级应当比菊花还要高
]]
function HintPanel.Create(type, msg, confirmCbk, cancelCbk, prefab_name, level,isSmall,parent)
    return HintPanel.New(type, msg, confirmCbk, cancelCbk, prefab_name, level,isSmall,parent)
end


--[[提示板
    type = 1 - 确认
    type = 2 - 确认 取消
    type = 3 - 确认 取消 关闭
    type = 4 - 关闭
    type = 5 - 确认 关闭
    
    msg - 显示的消息
    confirmCbk - 确定按钮回调
    cancelCbk - 取消按钮回调

    理论上来说应该只有一个实例，不会有两个提示板同时存在
    但是这里仍然使用类进行，即可以多个实例
    层级应当比菊花还要高
]]
function HintPanel.CreateSmall(type, msg, confirmCbk, cancelCbk, prefab_name, level)
    return HintPanel.New(type, msg, confirmCbk, cancelCbk, prefab_name, level,true)
end

--[[错误提示板
    直接提供错误编号即可
]]
function HintPanel.ErrorMsg(errorID, callback)
    local msg = GLL.GetTx(tonumber(errorID))
    print(debug.traceback())
    return HintPanel.New(1, msg, callback)
end


function HintPanel:ctor(type, msg, confirmCbk, cancelCbk, prefab_name, level, isSmall,parent)

	ExtPanel.ExtMsg(self)

    self.type = type
    self.msg = msg
    self.confirmCbk = confirmCbk
    self.cancelCbk = cancelCbk
    if prefab_name then
        self.prefab_name = prefab_name
    elseif isSmall then
        self.prefab_name = "HintPanelSmall"
    else
        self.prefab_name = "HintPanel"
    end

    self.parent = parent or GameObject.Find("Canvas/LayerLv5")

    self.gameObject = newObject(self.prefab_name, self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)


    self:InitUI()


    self.canvas = self.transform:GetComponent("Canvas")
    if level then
        self.canvas.sortingOrder = level
    end

    DOTweenManager.OpenPopupUIAnim(self.root.transform)
    self:AddListenerGameObject()
end

function HintPanel:AddListenerGameObject()
	
end

function HintPanel:RemoveListenerGameObject()
    self.back_btn.onClick:RemoveAllListeners()
    self.no_btn.onClick:RemoveAllListeners()
    self.yes_btn.onClick:RemoveAllListeners()

    self.gou_btn.onClick:RemoveAllListeners()
end

function HintPanel:MyExit()
    if IsEquals(self.transform) then
        self.transform:SetParent(nil)
    end
    self:RemoveListenerGameObject()
    destroy(self.gameObject)
end

-- 参考大厅提示效果
function HintPanel:InitUI()
    self.back_btn.onClick:AddListener(function ()
        self:OnNoClicked()
    end)
    self.no_btn.onClick:AddListener(function ()
        self:OnNoClicked()
    end)
    self.yes_btn.onClick:AddListener(function ()
        self:OnYesClicked()
    end)

    self.gou_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.is_gou = not self.is_gou
        self:SetGou()
    end)

    self.hint_info_txt.text = self.msg

    self.no_txt.text = GLL.GetTx(60007)
    self.yes_txt.text = GLL.GetTx(60008)

    if self.type == 1 then
        self.back_btn.gameObject:SetActive(false)
        self.no_btn.gameObject:SetActive(false)
    elseif self.type == 2 then
        self.back_btn.gameObject:SetActive(false)
    elseif self.type == 3 then

    elseif self.type == 4 then
        self.no_btn.gameObject:SetActive(false)
        self.yes_btn.gameObject:SetActive(false)
    elseif self.type == 5 then
        self.back_btn.gameObject:SetActive(true)
        self.no_btn.gameObject:SetActive(false)
    elseif self.type == 6 then
        self.back_btn.onClick:RemoveAllListeners()
        self.back_btn.onClick:AddListener(
            function ()
                self:MyExit()
            end
        )
    end
end

function HintPanel:OnNoClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.cancelCbk then
        self.cancelCbk()
    end
    self:MyExit()
end

function HintPanel:OnYesClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.confirmCbk then
        self.confirmCbk(self.is_gou)
    end
    self:MyExit()
end

function HintPanel:SetSmallHint(tt)
    if self.small_hint then
        self.small_hint.text = tt
    end
end
function HintPanel:SetButtonText(btn1, btn2)
    if btn1 then
        self.no_txt.text = btn1
    end
    if btn2 then
        self.yes_txt.text = btn2
    end
end

-- 勾选功能
function HintPanel:ShowGou()
    self.is_gou = false
    self.gourect.gameObject:SetActive(true)
    self:SetGou()
end
function HintPanel:SetGou()
    if self.is_gou then
        self.gou.gameObject:SetActive(true)
    else
        self.gou.gameObject:SetActive(false)
    end
    if self.gou_call then
        self.gou_call(self.is_gou)
    end
end
function HintPanel:SetGouCall(gou_call)
    self.gou_call = gou_call
end

function HintPanel:ChangeTitle(txt)
    if txt and IsEquals(self.title_txt) then
        self.title_txt.text = txt
    end
end

function HintPanel:SetDescLeft()
    self.hint_info_txt.alignment = Enum.TextAnchor.MiddleLeft
end

function HintPanel:AddPretoRoot(obj)
    obj.transform:SetParent(self.root)
    obj.transform.localPosition = Vector3.zero
    obj.transform.localScale = Vector3.one
end