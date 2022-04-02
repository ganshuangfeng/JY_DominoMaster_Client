-- 创建时间:2021-12-10
local cur_path = "Game.game_Slots.Lua."
ext_require("Game.CommonPrefab.Lua.ScrollAnimation")
ext_require(cur_path .. "SlotsLib")
ext_require(cur_path .. "SlotsModel")
ext_require(cur_path .. "SlotsDeskPanel")
ext_require(cur_path .. "SlotsGamePanel")
ext_require(cur_path .. "SlotsBetPanel")
ext_require(cur_path .. "SlotsWinMoneyPanel")
ext_require(cur_path .. "SlotsAwardPoolPanel")
ext_require(cur_path .. "SlotsButtonPanel")
ext_require(cur_path .. "SlotsMiniGameChoosePanel")
ext_require(cur_path .. "SlotsMiniGame1Panel")
ext_require(cur_path .. "SlotsMiniGame2Panel")
ext_require(cur_path .. "SlotsMiniGame3Panel")
ext_require(cur_path .. "SlotsAutoPanel")
ext_require(cur_path .. "SlotsClearPanel")
ext_require(cur_path .. "SlotsClearMainPanel")
ext_require(cur_path .. "SlotsClearMini1Panel")
ext_require(cur_path .. "SlotsClearMini2Panel")
ext_require(cur_path .. "SlotsClearMini3Panel")
ext_require(cur_path .. "SlotsHelpPanel")
ext_require(cur_path .. "SlotsItem")
ext_require(cur_path .. "SlotsEggItem")
ext_require(cur_path .. "SlotsAnimation")
ext_require(cur_path .. "SlotsEffect")
ext_require(cur_path .. "SlotsHelper")
SlotsLogic = {}
local M = SlotsLogic
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

    lister["model_slot_jymt_enter_game_response"] = M.slot_jymt_enter_game_response
    lister["model_slot_jymt_quit_game_response"] = M.slot_jymt_quit_game_response
    lister["model_slot_jymt_all_info"] = M.on_slot_jymt_all_info

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
    if SlotsModel.data and SlotsModel.data.modelStatus == SlotsModel.ModelStatus.gameover then
        M.ChangePanel(M.panelNameMap.hall)
        return
    end

    --限制处理消息  此时只处理指定的消息
    SlotsModel.data.limitDealMsg = {slot_jymt_all_info_response = true}
    if M.isTest then
        local data = M.GetTestData()
        Event.Brocast("slot_jymt_all_info_response","slot_jymt_all_info_response",data)
    else
        if not Network.SendRequest("slot_jymt_all_info",nil,"") then
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
    dump(parm, "<color=red>SlotsLogic Init parm</color>")
    --初始化model
    local model = SlotsModel.Init()
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
        SlotsModel.Exit()
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
            curPanel = {name = panelName, instance = SlotsGamePanel.Create()}
        end
    end
end

--处理 请求收到所有数据消息
function M.on_slot_jymt_all_info(data)
    --消息错误，回到大厅
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,function()
            M.ChangePanel(M.panelNameMap.hall)
        end)
        return
    end

    --取消限制消息
    SlotsModel.data.limitDealMsg = nil
    dump(SlotsModel.data.modelStatus, "<color=yellow>modelStatus</color>")
    local goTo = M.panelNameMap.game
    --根据状态数据创建相应的panel
    if SlotsModel.data.modelStatus == nil or SlotsModel.data.modelStatus == SlotsModel.ModelStatus.gameover then
        --大厅界面
        goTo = M.panelNameMap.hall
    elseif SlotsModel.data.modelStatus == SlotsModel.ModelStatus.gaming then
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

function M.slot_jymt_enter_game_response(data)
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,function(  )
            M.ChangePanel(M.panelNameMap.hall)
        end)
        return
    end

    SendRequestAllInfo()
end

function M.slot_jymt_quit_game_response(data)
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end

    M.ChangePanel(M.panelNameMap.hall)
end

function M.GetTestData()
    local data =  {
        award_money      = 4455000,
        bet_index        = 3,
        game_data ={
            data           = "E8D6E1179318977",
            fu_rate_list   = "12",
            jackpot_data ={
                award_pool_id   = 1,
                kj_list         = "111",
                rate            = 880,
                wild_item_index = 1,
               },
            max_gold       = 1,
            total_rate     = 891,
            wild_item_num  = 1,
            wild_item_rate = 1,
           },
        jjcj_award       = "0",
        jjcj_extra_award = "68000",
        result           = 0,
       }

    local data =    {
        award_money      = 39240000,
        bet_index        = 3,
        game_data = {
            data           = "798EE71E1E1E18E",
            fu_rate_list   = "222221",
            jymt_data = {
                data         = "3F9FF4243321C11GF21CCHC133CGAGH3H3GA3",
                fu_rate_list = {
                      [1] = 98,
                      [2] = 98,
                      [3] = 98,
                      [4] = 490,
                      [5] = 98,
                      [6] = 980,
                      [7] = 1960,
                      [8] = 3920,
                  },
                rate         = 7840,
              },
            max_gold       = 1,
            total_rate     = 7848,
            wild_item_num  = 0,
            wild_item_rate = 0,
            zcjb_data = {
                data             = "4968979686889689999974649844498644474444494F4699944849F9494976499969998994989699969994696F4676666F666966686888987F888878",
                fuhong_init_rate = 98,
                fulv_rate        = 490,
                rate             = 7840,
              },
          },
        jjcj_award       = "0",
        jjcj_extra_award = "158000",
        result           = 0,
      }

      local data = {
        award_money      = 174360000,
        bet_index        = 3,
        game_data = {
            data           = "999EE612EEE9E96",
            fu_rate_list   = "121212",
            jymt_data = {
                data         = "HGGA22C2FG9F2G1F21GHAH9C1",
                fu_rate_list = {
                       [1] = 156,
                       [2] = 312,
                       [3] = 78,
                       [4] = 702,
                       [5] = 78,
                       [6] = 1404,
                       [7] = 78,
                       [8] = 2886,
                   },
                rate         = 5772,
               },
            max_gold       = 1,
            total_rate     = 5812,
            wild_item_num  = 0,
            wild_item_rate = 0,
            zcjb_data = {
                data             = "777444747774777868896866974994969978799979F7948888789F88688899979647998749944994794999894F868888866868886679999448F49949",
                fuhong_init_rate = 78,
                fulv_rate        = 312,
                rate             = 5772,
               }
           },
        jjcj_award       = "0",
        jjcj_extra_award = "1590000",
        result           = 0,
       }
    --    local data = {
    --     award_money      = 13950000,
    --     bet_index        = 3,
    --     game_data = {
    --     data           = "334343D34444347",
    --     fu_rate_list   = "",
    --     max_gold       = 1,
    --     total_rate     = 465,
    --     wild_item_num  = 1,
    --     wild_item_rate = 1,
    --          },
    --     jjcj_award       = "0",
    --     jjcj_extra_award = "1230000",
    --     result           = 0,
    --      }


    local data = {
        award_money      = 50880000,
        bet_index        = 3,
        game_data = {
            data           = "92149E9DD929D74",
            fu_rate_list   = "2",
            jackpot_data = {
                award_pool_id   = 1,
                kj_list         = "2112341",
                rate            = 880,
                wild_item_index = 1,
              },
            max_gold       = 1,
            total_rate     = 1699,
            wild_item_num  = 3,
            wild_item_rate = 3,
          },
        jjcj_award       = "0",
        jjcj_extra_award = "90000",
        result           = 0,
      }

    data.result = 0
    return data
end

--使用测试数据
M.isTest = false

return SlotsLogic