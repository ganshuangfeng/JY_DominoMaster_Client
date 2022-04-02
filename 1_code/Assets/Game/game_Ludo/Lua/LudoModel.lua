-- 创建时间:2021-11-08

LudoModel = {}
local M = LudoModel
M.maxPlayerNumber = 4
M.GameIdToPlayerNumber = {
    nor_fxq_er = 2,
    nor_fxq_si = 4,
}

M.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

M.Status = {
    ready="ready", -- 准备状态
    --定庄
    dz = "dz",
    --摇骰子
    roll = "roll",
    --选棋子
    piece = "piece",
    --结算
    settlement = "settlement",
    --结束
    gameover = "gameover",
    --玩家进入托管状态
    auto = "auto",
}

M.StatusMini = {
    waitRoll = "waitRoll",
    roll = "roll",
    waitPiece = "waitPiece",
    piece = "piece",
}

local this
local game_lister
local lister
local m_data

local updateTimer
local updateDt = 0.1
function M.Update()
    if m_data then
        if m_data.countdown and m_data.countdown > 0 then
            m_data.countdown = m_data.countdown - updateDt
            if m_data.countdown < 0 then
                m_data.countdown = 0
            end
        end
    end
end

function M.InitUpdate()
	M.ExitUpdate()
	updateTimer = Timer.New(function ()
        M.Update()
	end,updateDt,-1,true)
	updateTimer:Start()
end

function M.ExitUpdate()
	if updateTimer then
		updateTimer:Stop()
	end
	updateTimer = nil
end

function M.MakeLister()
	-- 游戏相关
    game_lister = {}
    --模式
    game_lister["fg_all_info"] = this.on_fg_all_info
    game_lister["fg_enter_room_msg"] = this.on_fg_enter_room_msg
    game_lister["fg_join_msg"] = this.on_fg_join_msg
    game_lister["fg_ready_msg"] = this.on_fg_ready_msg
    game_lister["fg_leave_msg"] = this.on_fg_leave_msg
    game_lister["fg_gameover_msg"] = this.on_fg_gameover_msg
    game_lister["fg_score_change_msg"] = this.on_fg_score_change_msg
    game_lister["fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    game_lister["fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    
    --fg response
    game_lister["fg_signup_response"] = this.on_fg_signup_response
    game_lister["fg_switch_game_response"] = this.on_fg_switch_game_response
    game_lister["fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    game_lister["fg_replay_game_response"] = this.on_fg_replay_game_response
    game_lister["fg_quit_game_response"] = this.on_fg_quit_game_response
    game_lister["fg_ready_response"] = this.on_fg_ready_response

    --玩法
    game_lister["nor_fxq_nor_ready_msg"] = this.on_nor_fxq_nor_ready_msg
    game_lister["nor_fxq_nor_begin_msg"] = this.on_nor_fxq_nor_begin_msg
    game_lister["nor_fxq_nor_ding_zhuang_msg"] = this.on_nor_fxq_nor_ding_zhuang_msg
    game_lister["nor_fxq_nor_roll_permit"] = this.on_nor_fxq_nor_roll_permit
    game_lister["nor_fxq_nor_roll_msg"] = this.on_nor_fxq_nor_roll_msg
    game_lister["nor_fxq_nor_piece_permit"] = this.on_nor_fxq_nor_piece_permit
    game_lister["nor_fxq_nor_piece_msg"] = this.on_nor_fxq_nor_piece_msg
    game_lister["nor_fxq_nor_award_msg"] = this.on_nor_fxq_nor_award_msg
    game_lister["nor_fxq_nor_score_change_msg"] = this.on_nor_fxq_nor_score_change_msg
    game_lister["nor_fxq_nor_settlement_msg"] = this.on_nor_fxq_nor_settlement_msg
    game_lister["nor_fxq_nor_new_game_msg"] = this.on_nor_fxq_nor_new_game_msg
    game_lister["nor_fxq_nor_auto_msg"] = this.on_nor_fxq_nor_auto_msg

    --nor response
    game_lister["nor_fxq_nor_ready_response"] = this.on_nor_fxq_nor_ready_response
    game_lister["nor_fxq_nor_quit_response"] = this.on_nor_fxq_nor_quitresponse
    game_lister["nor_fxq_nor_auto_response"] = this.on_nor_fxq_nor_auto_response
    game_lister["nor_fxq_nor_piece_response"] = this.on_nor_fxq_nor_piece_response
    game_lister["nor_fxq_nor_roll_response"] = this.on_nor_fxq_nor_roll_response

    -- 其他
    lister = {}
    lister["AssetChange"] = this.AssetChange
end
local function MsgDispatch(proto_name, data)
    local func = game_lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end

    if data.status_no then
        -- 断线重连的数据不用判断status_no
        if proto_name ~= "fg_all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                dump(data)
                --发送状态编码错误事件
                Event.Brocast("model_status_no_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

local function InitData()
    M.data = {}
    M.baseData = {}
    m_data = M.data
end
local function ResetData(gameID)
    M.baseData = M.baseData or {}
    M.data = {
        --游戏名
        name = nil,
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        statusMini = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --倒计时
        countdown = 0,
        --当前的权限拥有人
        cur_p = nil,
        --玩家的托管状态
        auto_status = {},
        --当前局数
        race = nil,
        --我的座位号
        seat_num = nil,
        --庄家座位号
        zhuang = nil,
        --玩家骰子
        roll = {},
        --玩家棋子
        piece = {},
        --玩家奖励
        award = {},
        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)
        settlement_info = nil,
        settlement_players_info=nil,
    }
    m_data = M.data
end
function M.Init()
    this = M
    InitData()
    ResetData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()
    M.InitUpdate()
    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        M.ExitUpdate()
        this = nil
        game_lister = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.GetPosToPlayer(uiPos)
    if m_data.seatNum and m_data.players_info then
        local seatno = m_data.seatNum[uiPos]
        return m_data.players_info[seatno]
    end
end

function M.AssetChange(data)
    dump(data, "<color=white>AssetChange</color>")
    m_data.score = MainModel.UserInfo.jing_bi
    if  m_data.players_info and m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = MainModel.UserInfo.jing_bi
    end
    Event.Brocast("model_AssetChange")
end

--模式
function M.on_fg_all_info(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    if data.status_no == -1 then
        ResetData()
        MainLogic.ExitGame()
        LudoLogic.change_panel(LudoLogic.panelNameMap.hall)
        return
    end

    local s = data
    if s then
        m_data.model_status = s.status
        m_data.game_type = s.game_type
        m_data.countdown = s.countdown

        M.data = M.data or {}
    end

    s = data.room_info
    if s then
        m_data.init_stake = s.init_stake
        m_data.init_rate = s.init_rate
        m_data.game_id = s.game_id
    end

    s = data.players_info
    if s then
        for k, v in pairs(s) do
            m_data.players_info[v.seat_num] = v
            if v.id == MainModel.UserInfo.user_id then
                m_data.seat_num = v.seat_num
            end
        end
    end
    s = data.nor_fxq_nor_status_info
    if s then
        m_data.status = s.status
        m_data.countdown = s.countdown
        m_data.cur_p = s.cur_p
        m_data.roll = {
            seat_num = s.cur_p,
            point = s.roll_point
        }
        m_data.piece = {}
        for i, v in ipairs(s.piece_data) do
            if next(v) then
                m_data.piece[v.seat_num] = v.piece
            end
        end
        m_data.award = s.award
        m_data.auto_status = s.auto_status or {}
        m_data.seat_num = s.seat_num
        m_data.zhuang = s.zhuang_seat_num

        m_data.is_over = s.is_over
        m_data.init_stake = s.init_stake
        m_data.ready = s.ready
        m_data.cur_race = s.cur_race
        m_data.race_count = s.race_count
        m_data.settlement_info = s.settlement_info

        m_data.statusMini = nil
        if m_data.status == M.Status.roll then
            m_data.statusMini = M.StatusMini.waitRoll
        elseif m_data.status == M.Status.piece then
            m_data.statusMini = M.StatusMini.waitPiece
        end
    end

    -- 结算界面的player
    m_data.settlement_players_info = data.settlement_players_info

    M.maxPlayerNumber = M.GameIdToPlayerNumber[m_data.game_type]
    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    LudoLib.transform_seat(
        m_data.seatNum,
        m_data.s2cSeatNum,
        m_data.seat_num,
        M.maxPlayerNumber
    )

    M.baseData.room_rent = data.room_rent
    dump(m_data, "<color=red>model_fg_all_info :</color>")

    Event.Brocast("model_fg_all_info")
end

function M.on_fg_enter_room_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gaming
    m_data.status = M.Status.ready
    m_data.statusMini = nil
    for k, v in pairs(data.players_info) do
        m_data.players_info[v.seat_num] = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end
    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    LudoLib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, M.maxPlayerNumber)
    m_data.my_rate = m_data.init_rate or 1
    m_data.race = 1
    if m_data.seat_num then
        Event.Brocast("model_fg_enter_room_msg")
    end
end

function M.on_fg_join_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_fg_join_msg", data.player_info.seat_num)
end

function M.on_fg_ready_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    local seatno = data.seat_num
    if m_data.players_info[seatno] then
        m_data.players_info[seatno].ready = 1
    end
    Event.Brocast("model_fg_ready_msg", seatno)
end

function M.on_fg_leave_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    -- m_data.players_info[data.seat_num] = nil
    -- Event.Brocast("model_fg_leave_msg", data.seat_num)

    --应为随时可以退出，这里需要标记好等到切换权限的时候客户端再真正离开
    if m_data.players_info and m_data.players_info[data.seat_num] then
        m_data.players_info[data.seat_num].isLeave = true
    end
end

function M.CheckPlayerLeave()
    for seat_num = 1, M.maxPlayerNumber do
        if m_data.players_info[seat_num] and m_data.players_info[seat_num].isLeave == true then
            --不能删除玩家，否则结算会出错
            m_data.players_info[seat_num] = nil
            m_data.piece[seat_num] = nil
            Event.Brocast("model_fg_leave_msg", seat_num)
        end
    end
end

function M.on_fg_gameover_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gameover
    m_data.status = M.Status.gameover
    m_data.statusMini = nil
    for k, v in pairs(m_data.players_info) do
        v.ready = 0
    end
    Event.Brocast("model_fg_gameover_msg")
end

function M.on_fg_score_change_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_fg_score_change_msg",data)
end

function M.on_fg_auto_cancel_signup_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end

function M.on_fg_auto_quit_game_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end

--response
function M.on_fg_signup_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_fg_switch_game_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_fg_cancel_signup_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
        Event.Brocast("model_fg_cancel_signup_response", data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_fg_replay_game_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        M.on_fg_signup_response(proto_name, data)
    else
        HintPanel.ErrorMsg(data.result, function()
            ResetData()
            MainLogic.ExitGame()
            Event.Brocast("model_fg_cancel_signup_response", data.result)
        end)
    end
end

function M.on_fg_quit_game_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
    end
    Event.Brocast("model_fg_quit_game_response", data.result)
end

function M.on_fg_ready_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        m_data.model_status = M.Model_Status.wait_begin
        m_data.status = nil
        m_data.statusMini = nil
        if m_data.players_info[m_data.seat_num] then
            m_data.players_info[m_data.seat_num].ready = 1
        end
        Event.Brocast("model_fg_ready_response")
    else
        Network.SendRequest("fg_quit_game")
    end
end

--nor msg
function M.on_nor_fxq_nor_ready_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_nor_fxq_nor_ready_msg",data)
end

function M.on_nor_fxq_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.race = data.cur_race

    --棋子初始化
    for i, v in pairs(m_data.players_info) do
        if next(v) then
            m_data.piece[i] = m_data.piece[i] or {}
            for j = 1, data.piece_num do
                m_data.piece[i][j] = 0
            end
        end
    end
    
    Event.Brocast("model_nor_fxq_nor_begin_msg",data)
end

function M.on_nor_fxq_nor_ding_zhuang_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.dz
    m_data.statusMini = nil
    m_data.zhuang = data.zhuang_seat_num
    Event.Brocast("model_nor_fxq_nor_ding_zhuang_msg",data)
end

function M.on_nor_fxq_nor_roll_permit(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = data.status
    m_data.statusMini = M.StatusMini.waitRoll
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 0.1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p

    Event.Brocast("model_nor_fxq_nor_roll_permit",data)

    M.CheckPlayerLeave()
end

function M.on_nor_fxq_nor_roll_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.roll
    m_data.statusMini = M.StatusMini.roll
    m_data.roll = data

    Event.Brocast("model_nor_fxq_nor_roll_msg",data)
end

function M.on_nor_fxq_nor_piece_permit(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = data.status
    m_data.statusMini = M.StatusMini.waitPiece
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 0.1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p
    Event.Brocast("model_nor_fxq_nor_piece_permit",data)

    M.CheckPlayerLeave()
end

function M.on_nor_fxq_nor_piece_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.piece
    m_data.statusMini = M.StatusMini.piece
    m_data.piece[data.seat_num] = m_data.piece[data.seat_num] or {}
    m_data.piece[data.seat_num][data.id] = data.place
    if data.back_seat_num and data.back_id then
        m_data.piece[data.back_seat_num][data.back_id] = 0        
    end
    Event.Brocast("model_nor_fxq_nor_piece_msg",data)
end

function M.on_nor_fxq_nor_award_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.award[data.seat_num] = m_data.award[data.seat_num] or 0
    m_data.award[data.seat_num] = m_data.award[data.seat_num] + data.award
    Event.Brocast("model_nor_fxq_nor_award_msg",data)
end

function M.on_nor_fxq_nor_score_change_msg(proto_name, data)

    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    for seat_num, score in ipairs(data.data) do
		m_data.players_info[seat_num].score = m_data.players_info[seat_num].score + score
	end
    Event.Brocast("model_nor_fxq_nor_score_change_msg",data)
end

function M.on_nor_fxq_nor_settlement_msg(proto_name, data)

    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.settlement
    m_data.statusMini = nil
    m_data.settlement_info = data.settlement_info

    Event.Brocast("model_nor_fxq_nor_settlement_msg",data)

    M.CheckPlayerLeave()
end

function M.on_nor_fxq_nor_new_game_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    m_data.status = data.status
    m_data.statusMini = nil
    m_data.race = data.cur_race
    m_data.curr_all_player = data.curr_all_player
    Event.Brocast("model_nor_fxq_nor_new_game_msg",data)
end

function M.on_nor_fxq_nor_auto_msg(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
    m_data.auto_status = m_data.auto_status or {}
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("model_nor_fxq_nor_auto_msg", data)
end

--nor response
function M.on_nor_fxq_nor_ready_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_fxq_nor_quit_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_fxq_nor_auto_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_fxq_nor_roll_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_fxq_nor_piece_response(proto_name, data)
    dump(data, "<color=red>[Ludo] msg data proto_name = " .. proto_name .. "</color>")
end