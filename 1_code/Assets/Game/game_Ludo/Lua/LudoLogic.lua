-- 创建时间:2021-11-08
local cur_path = "Game.game_Ludo.Lua."
ext_require(cur_path .. "LudoModel")
ext_require(cur_path .. "LudoGamePanel")
ext_require(cur_path .. "LudoLib")
ext_require(cur_path .. "LudoAnim")
ext_require(cur_path .. "LudoPlayerBase")
ext_require(cur_path .. "LudoPlayerMe")
ext_require(cur_path .. "LudoPlayerOther")
ext_require(cur_path .. "LudoDesk")
ext_require(cur_path .. "LudoPiece")
ext_require(cur_path .. "LudoSafety")
ext_require(cur_path .. "LudoPieceNum")
ext_require(cur_path .. "LudoDice")
ext_require(cur_path .. "LudoClear")
ext_require(cur_path .. "LudoWait")
ext_require(cur_path .. "LudoMvpPanel")
LudoLogic = {}
local L = LudoLogic
L.panelNameMap = {
    game = "game",
    hall = "hall"
}

local cur_panel

local this
local is_allow_forward
--自己关心的事件
local lister
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}

    lister["model_status_no_error_msg"] = this.on_status_error_msg
    -- 网络
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["model_fg_all_info"] = this.on_fg_all_info
    lister["model_fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    lister["model_fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    lister["model_fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    lister["model_fg_quit_game_response"] = this.on_fg_quit_game_response
end

-- Logic
local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end
-- View 的消息处理相关方法
local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end
local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

local function SendRequestAllInfo()
    dump(LudoModel.data)
    if LudoModel.data and LudoModel.data.model_status == LudoModel.Model_Status.gameover then
        L.on_fg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        NetJH.RemoveAll()
        NetJH.Create("-", 666)
        LudoModel.data.limitDealMsg = {fg_all_info = true}
        Network.SendRequest("fg_req_info_by_send", {type = "all"}, function (data)
            NetJH.RemoveByID(666)
        end)
    end

end

--状态错误处理
function L.on_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function L.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function L.on_background_msg()
    cancelViewMsgRegister()
end
--游戏重新连接消息
function L.on_reconnect_msg()
    SendRequestAllInfo()
end
--游戏网络破损消息
function L.on_network_error_msg()
    cancelViewMsgRegister()
end
function L.on_fg_all_info()
    --取消限制消息
    LudoModel.data.limitDealMsg = nil

    --根据状态数据创建相应的panel
    if not LudoModel.data.model_status then
        L.change_panel(L.panelNameMap.hall)
        return
    end

    L.change_panel(L.panelNameMap.game)
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end

function L.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function L.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function L.Init(parm)
    newObject("LudoCanvasBG")
	newObject("Ludo3DNode")
	LudoLib.InitPos()
    LudoLib.InitDicePos()
    this = L
    dump(parm, "<color=red>LudoLogic Init parm</color>")
    --初始化model
    local model = LudoModel.Init()
    MakeLister()
    AddMsgListener(lister)

    SendRequestAllInfo()

    L.change_panel(L.panelNameMap.game)
end

function L.Exit()
    if this then
        print("<color=green>Exit  LudoLogic</color>")
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        LudoModel.Exit()
    end
end

function L.change_panel(panelName)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == L.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == L.panelNameMap.hall then
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == L.panelNameMap.game then
            cur_panel = {name = panelName, instance = LudoGamePanel.Create()}
        end
    end
end

function L.on_fg_auto_cancel_signup_msg()
    L.change_panel(L.panelNameMap.hall)
end

function L.on_fg_auto_quit_game_msg()
    L.change_panel(L.panelNameMap.hall)
end

function L.on_fg_cancel_signup_response(result)
    if result == 0 then
        L.change_panel(L.panelNameMap.hall)
    end
end

function L.on_fg_quit_game_response(result)
    if result == 0 then
        L.change_panel(L.panelNameMap.hall)
    end
end

return LudoLogic