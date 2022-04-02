-- 创建时间:2021-12-10
local cur_path = "Game.game_SlotsLion.Lua."
ext_require(cur_path .. "SlotsLionLib")
ext_require(cur_path .. "SlotsLionModel")
ext_require(cur_path .. "SlotsLionGameMainPanel")
ext_require(cur_path .. "SlotsLionGamePanel")
ext_require(cur_path .. "SlotsLionBetPanel")
ext_require(cur_path .. "SlotsLionWinMoneyPanel")
ext_require(cur_path .. "SlotsLionAwardPoolPanel")
ext_require(cur_path .. "SlotsLionButtonPanel")
ext_require(cur_path .. "SlotsLionGameMini1Panel")
ext_require(cur_path .. "SlotsLionGameMini2Item")
ext_require(cur_path .. "SlotsLionGameMini2Panel")
ext_require(cur_path .. "SlotsLionAutoPanel")
ext_require(cur_path .. "SlotsLionClearPanel")
ext_require(cur_path .. "SlotsLionClearMainPanel")
ext_require(cur_path .. "SlotsLionClearMini1Panel")
ext_require(cur_path .. "SlotsLionClearMini2Panel")
ext_require(cur_path .. "SlotsLionHelpPanel")
ext_require(cur_path .. "SlotsLionItem")
ext_require("Game.CommonPrefab.Lua." .. "ScrollAnimation")
ext_require(cur_path .. "SlotsLionAnimation")
ext_require(cur_path .. "SlotsLionEffect")
ext_require(cur_path .. "SlotsLionHelper")
ext_require(cur_path .. "SlotsLionLinePanel")

SlotsLionLogic = {}
local M = SlotsLionLogic
M.panelNameMap = {
    game = "game",
    hall = "hall"
}

local curPanel

local this
--自己关心的事件
local lister

local isAllowForward = false
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}

    lister["model_slot_wushi_enter_game_response"] = M.slot_wushi_enter_game_response
    lister["model_slot_wushi_quit_game_response"] = M.slot_wushi_quit_game_response
    lister["model_slot_wushi_all_info"] = M.on_slot_wushi_all_info

    -- 网络
    lister["EnterForeGround"] = this.OnEnterForeGround
    lister["EnterBackGround"] = this.OnEnterBackGround
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
        if viewLister and viewLister[registerName] and isAllowForward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and isAllowForward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end

local function CancelViewMsgRegister(registerName)
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
end

local function ClearAllViewMsgRegister()
    CancelViewMsgRegister()
    viewLister = {}
end

local function SendRequestAllInfo()
    --游戏已经退出成功
    if SlotsLionModel.data and SlotsLionModel.data.modelStatus == SlotsLionModel.ModelStatus.gameover then
        M.ChangePanel(M.panelNameMap.hall)
        return
    end

    --限制处理消息  此时只处理指定的消息
    SlotsLionModel.data.limitDealMsg = {slot_wushi_all_info_response = true}
    if M.isTest then
        local data = M.GetTestData()
        Event.Brocast("slot_wushi_all_info_response","slot_wushi_all_info_response",data)
    else
        if not Network.SendRequest("slot_wushi_all_info",nil,"") then
            LittleTips.Create("Network Error")
        end
    end
end

--游戏后台重进入消息
function M.OnEnterForeGround()
    Time.timeScale = 1
end

--游戏后台消息
function M.OnEnterBackGround()
    Time.timeScale = 0
end

function M.SetViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function M.ClearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    CancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function M.Init(parm)
    NetworkManager.SetIsWeakNet(true)
    this = M
    dump(parm, "<color=red>SlotsLionLogic Init parm</color>")
    --初始化model
    local model = SlotsLionModel.Init()
    MakeLister()
    AddMsgListener(lister)

    SendRequestAllInfo()

    M.ChangePanel(M.panelNameMap.game)
end

function M.Exit()
    NetworkManager.SetIsWeakNet(false)
    Time.timeScale = 1
    if this then
        this = nil
        if curPanel then
            curPanel.instance:MyExit()
        end
        curPanel = nil
        RemoveMsgListener(lister)
        ClearAllViewMsgRegister()
        SlotsLionModel.Exit()
    end
end

function M.ChangePanel(panelName)
    if curPanel then
        if curPanel.name == panelName then
            curPanel.instance:MyRefresh()
        elseif panelName == M.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            curPanel.instance:MyExit()
            curPanel = nil
        else
            DOTweenManager.KillAllStopTween()
            curPanel.instance:MyExit()
            curPanel = nil
        end
    end
    if not curPanel then
        if panelName == M.panelNameMap.hall then
            MainLogic.ExitGame()
            GameManager.GotoSceneName("game_SlotsHall")
        elseif panelName == M.panelNameMap.game then
            curPanel = {name = panelName, instance = SlotsLionGamePanel.Create()}
        end
    end
end

--处理 请求收到所有数据消息
function M.on_slot_wushi_all_info(data)
    --消息错误，回到大厅
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,function()
            M.ChangePanel(M.panelNameMap.hall)
        end)
        return
    end

    --取消限制消息
    SlotsLionModel.data.limitDealMsg = nil
    dump(SlotsLionModel.data.modelStatus, "<color=yellow>modelStatus</color>")
    local goTo = M.panelNameMap.game
    --根据状态数据创建相应的panel
    if SlotsLionModel.data.modelStatus == nil or SlotsLionModel.data.modelStatus == SlotsLionModel.ModelStatus.gameover then
        --大厅界面
        goTo = M.panelNameMap.hall
    elseif SlotsLionModel.data.modelStatus == SlotsLionModel.ModelStatus.gaming then
        --游戏界面
        goTo = M.panelNameMap.game
    end
    
    if goTo then
        M.ChangePanel(goTo)
    end

    isAllowForward = true
    --恢复监听
    ViewMsgRegister()
end

function M.slot_wushi_enter_game_response(data)
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,function(  )
            M.ChangePanel(M.panelNameMap.hall)
        end)
        return
    end

    SendRequestAllInfo()
end

function M.slot_wushi_quit_game_response(data)
    if data.result ~= 0 then
        if data.result == -1 then
            M.ChangePanel(M.panelNameMap.hall)
        else
            HintPanel.ErrorMsg(data.result)
        end
        return
    end

    M.ChangePanel(M.panelNameMap.hall)
end

function M.GetTestData()
    local data
    data = {
                 award_money        = 12000000,
                 bet_index          = 7,
                 big_award_pool_num = 9718211299,
                 game_data = {
                     bet_grade        = 2,
                     big_jackpot_rate = 0,
                     data             = "22258722287A588",
                     jackpot          = 3,
                     jackpot_rate     = 0,
                     service_time     = "1648344233",
                     total_rate       = 6,
                 }
             }

    data = {
        award_money = 1872000000,
        bet_index = 7,
        big_award_pool_num = 9718246915,
        game_data = {
        bet_grade = 2,
        big_jackpot_rate = 0,
        data = "4A62627641A52A7",
        freegame_data = "13721415A198959763777311318977566735353595579436154467619A914435733812994A4",
        freegame_jackpot = "01000",
        freegame_jackpot_rate = "2F222",
        freegame_jackpot_total_rate = 20,
        jackpot = 1,
        jackpot_rate = 20,
        service_time = "1648346160",
        total_rate = 936,
        }
        }

    data =  {
        award_money = 2200000000,
        bet_index = 7,
        big_award_pool_num = 2518251303,
        game_data = {
        bet_grade = 2,
        big_jackpot_rate = 0,
        data = "8A8A848461A8842",
        freegame_data = "4782841A122539241A36717132526912877126A788932863131867269861478736A78896679",
        freegame_jackpot = "00300",
        freegame_jackpot_rate = "22022",
        freegame_jackpot_total_rate = 0,
        jackpot = 2,
        jackpot_rate = 50,
        service_time = "1648346393",
        total_rate = 1100,
        }
        }

    data = {
        award_money = 1450000000,
        bet_index = 7,
        big_award_pool_num = 2518286604,
        game_data = {
        bet_grade = 2,
        big_jackpot_rate = 0,
        data = "333377871799779",
        jackpot = 0,
        jackpot_rate = 0,
        service_time = "1648348285",
        total_rate = 725,
        }
        }
    data = {
        award_money = 4900000000,
        bet_index = 7,
        big_award_pool_num = 2518282901,
        game_data = {
        bet_grade = 2,
        big_jackpot_rate = 0,
        data = "255752588899999",
        jackpot = 2,
        jackpot_rate = 50,
        service_time = "1648348090",
        total_rate = 2450,
        }
        }

    data = {
        award_money = 164900000,
        bet_index = 1,
        big_award_pool_num = 2518258527,
        game_data = {
        bet_grade = 0,
        big_jackpot_rate = 0,
        data = "A28A78616A89986",
        freegame_data = "3551254213993993387437248494978238871212981994A7447326493299846518A636A1996",
        freegame_jackpot = "00000",
        freegame_jackpot_rate = "22222",
        freegame_jackpot_total_rate = 0,
        jackpot = 0,
        jackpot_rate = 0,
        service_time = "1648346775",
        total_rate = 1649,
        }
        }

    data = {
        award_money = 3452000000,
        bet_index = 7,
        big_award_pool_num = 2518528038,
        game_data = {
        bet_grade = 2,
        big_jackpot_rate = 0,
        data = "85A56A48148989A",
        freegame_data = "81247151189958912322333132396936138616A719A133A1423523893952824111147A96A42",
        freegame_jackpot = "10011",
        freegame_jackpot_rate = "F22FF",
        freegame_jackpot_total_rate = 60,
        jackpot = 1,
        jackpot_rate = 20,
        service_time = "1647843233",
        total_rate = 1726,
        }
        }

    -- data = {
    --     award_money = 7050000000,
    --     bet_index = 12,
    --     big_award_pool_num = 2518738576,
    --     game_data = {
    --     bet_grade = 3,
    --     big_jackpot_rate = 0,
    --     data = "134AA5757799937",
    --     jackpot = 1,
    --     jackpot_rate = 20,
    --     service_time = "1647854615",
    --     total_rate = 705,
    --     }
    --     }

    data = {
            award_money        = 6456000000,
            bet_index          = 8,
            big_award_pool_num = 2518824225,
            game_data = {
            bet_grade                   = 2,
            big_jackpot_rate            = 0,
            data                        = "8788878858A99AA",
            freegame_data               = "56674576A7A766981A5642283994998184462A83918997A745161548391A222A8268579A919",
            freegame_jackpot            = "01000",
            freegame_jackpot_rate       = "2F222",
            freegame_jackpot_total_rate = 20,
            jackpot                     = 0,
            jackpot_rate                = 0,
            service_time                = "1647859283",
            total_rate                  = 2152,
             }
         }

    data = {
            award_money        = 1480000000,
            bet_index          = 12,
            big_award_pool_num = "2523014882",
            game_data = {
            bet_grade        = 3,
            big_jackpot_rate = 0,
            data             = "211653251895299",
            jackpot          = 0,
            jackpot_rate     = 0,
            service_time     = "1648690483",
            total_rate       = 148,
            }
         }

    data.result = 0
    return data
end

--使用测试数据
M.isTest = false

return SlotsLionLogic