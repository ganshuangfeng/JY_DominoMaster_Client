-- 创建时间:2021-11-08

DominoJLModel = {}
local M = DominoJLModel
M.maxPlayerNumber = 4

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
    -- 准备状态
    ready="ready",
    --开始
    begin = "begin",
    --定庄
    dz = "dz",
    --发牌
    fp = "fp",
    --出牌
    cp = "cp",
    --结算
    settlement = "settlement",
    --结束
    gameover = "gameover",
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
    game_lister["fg_leave_msg"] = this.on_fg_leave_msg
    game_lister["fg_gameover_msg"] = this.on_fg_gameover_msg
    game_lister["fg_score_change_msg"] = this.on_fg_score_change_msg
    game_lister["fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    game_lister["fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    game_lister["fg_ready_msg"] = this.on_fg_ready_msg
    
    --response
    game_lister["fg_signup_response"] = this.on_fg_signup_response
    game_lister["fg_switch_game_response"] = this.on_fg_switch_game_response
    game_lister["fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    game_lister["fg_replay_game_response"] = this.on_fg_replay_game_response
    game_lister["fg_quit_game_response"] = this.on_fg_quit_game_response
    game_lister["fg_ready_response"] = this.on_fg_ready_response
    game_lister["fg_huanzhuo_response"] = this.on_fg_huanzhuo_response


    game_lister["nor_dmn_nor_ready_response"] = this.on_nor_dmn_nor_ready_response
    game_lister["nor_dmn_nor_auto_response"] = this.on_nor_dmn_nor_auto_response
    game_lister["nor_dmn_nor_cp_response"] = this.on_nor_dmn_nor_cp_response

    --玩法
    game_lister["nor_dmn_nor_status_info"] = this.on_nor_dmn_nor_status_info
    game_lister["nor_dmn_nor_ready_msg"] = this.on_nor_dmn_nor_ready_msg
    game_lister["nor_dmn_nor_begin_msg"] = this.on_nor_dmn_nor_begin_msg
    game_lister["nor_dmn_nor_pai_msg"] = this.on_nor_dmn_nor_pai_msg
    game_lister["nor_dmn_nor_cp_permit"] = this.on_nor_dmn_nor_cp_permit
    game_lister["nor_dmn_nor_cp_msg"] = this.on_nor_dmn_nor_cp_msg
    game_lister["nor_dmn_nor_ding_zhuang_msg"] = this.on_nor_dmn_nor_ding_zhuang_msg
    game_lister["nor_dmn_nor_auto_msg"] = this.on_nor_dmn_nor_auto_msg
    game_lister["nor_dmn_nor_new_game_msg"] = this.on_nor_dmn_nor_new_game_msg
    game_lister["nor_dmn_nor_settlement_msg"] = this.on_nor_dmn_nor_settlement_msg
    game_lister["nor_dmn_nor_score_change_msg"] = this.on_nor_dmn_nor_score_change_msg
    game_lister["nor_dmn_nor_ybq_msg"] = this.on_nor_dmn_nor_ybq_msg

    -- 其他
    lister = {}
    lister["AssetChange"] = this.AssetChange
end
local function MsgDispatch(proto_name, data)
    dump(data, "qqqqqqqqqqqqqqqq")
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
        --当前房间中桌子号
        table_num = nil,
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --倒计时
        countdown = 0,
        --当前的权限拥有人
        cur_p = nil,
        --我的牌列表
        my_pai_list = nil,
        --每个人剩余的牌数量
        remain_pai_amount = nil,
        --玩家的托管状态
        auto_status = {},
        --当前局数
        race = nil,
        --我的座位号
        seat_num = nil,
        --庄家座位号
        zhuang = nil,
        --玩家操作列表
        table_pai = {},
        --fg_players_info***
        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)
        settlement_info = nil,
        settlement_players_info=nil,
        --客户端辅助数据***********
        --记牌器
        jipaiqi = nil,
        ybq_data = {},
    }
    m_data = M.data
    Event.Brocast("model_reset_data")
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
    dump(data,"<color=white>AssetChange?????????????</color>")
    if data.change_type == "freestyle_game_settle" then
        return
    end

    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = MainModel.UserInfo.jing_bi
    end

    Event.Brocast("model_AssetChange")
end

--模式
function M.on_fg_all_info(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.status_no == -1 then
        ResetData()
        MainLogic.ExitGame()
        DominoJLLogic.change_panel(DominoJLLogic.panelNameMap.hall)
        return
    end

    local s = data
    if s then
        m_data.model_status = s.status
        m_data.game_type = s.game_type
        m_data.jdz_type = s.jdz_type
        m_data.countdown = s.countdown

        M.data = M.data or {}
        
        M.maxPlayerNumber = 4
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
    s = data.nor_dmn_nor_status_info
    if s then
        m_data.cur_p = s.cur_p
        m_data.race = s.cur_race
        m_data.init_stake = s.init_stake
        m_data.my_pai_list = s.my_pai_list
        DominoJLLib.SortPai(m_data.my_pai_list)
        m_data.race_count = s.race_count
        m_data.remain_pai_amount = s.remain_pai_amount
        m_data.seat_num = s.seat_num
        m_data.zhuang = s.zhuang_seat_num
        m_data.status = s.status
        m_data.table_pai = s.table_pai or {}
        m_data.countdown = s.countdown
        m_data.settlement_info = s.settlement_info
        if m_data.settlement_info and next(m_data.settlement_info) then
            for i, v in ipairs(m_data.settlement_info.remain_pai) do
                DominoJLLib.SortPai(v.pai)
            end 
        end

        if s.ybq_data then
            m_data.ybq_data = {}
            for i, v in ipairs(s.ybq_data) do
                m_data.ybq_data[v.seat_num] = v.ds
            end
        end

        if s.ready then
            for i, v in ipairs(s.ready) do
                if m_data.players_info[i] then
                    m_data.players_info[i].ready = v
                end
            end
        else
            for i, v in ipairs( m_data.players_info) do
               v.ready = 1
            end
        end

        m_data.auto_status = s.auto_status or {}
    end

    -- 结算界面的player
    m_data.settlement_players_info = data.settlement_players_info

    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    DominoJLLib.transform_seat(
        m_data.seatNum,
        m_data.s2cSeatNum,
        m_data.seat_num,
        M.maxPlayerNumber
    )

    M.baseData.room_rent = data.room_rent
    Event.Brocast("model_fg_all_info")
end
function M.on_fg_enter_room_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gaming
    m_data.status = M.Status.ready
    for k, v in pairs(data.players_info) do
        m_data.players_info[v.seat_num] = v
    end
    m_data.seat_num = data.seat_num

    m_data.init_stake = data.room_info.init_stake
    m_data.init_rate = data.room_info.init_rate
    m_data.game_id = data.room_info.game_id

    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    DominoJLLib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, M.maxPlayerNumber)
    m_data.race = 1
    Event.Brocast("model_fg_enter_room_msg")
end
function M.on_fg_join_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_fg_join_msg", data.player_info.seat_num)
end
function M.on_fg_leave_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.players_info[data.seat_num] = nil
    Event.Brocast("model_fg_leave_msg", data.seat_num)
end
function M.on_fg_gameover_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gameover
    m_data.status = M.Status.gameover    
    for k, v in pairs(m_data.players_info) do
        v.ready = 0
    end
    Event.Brocast("model_fg_gameover_msg")
end
--中途结算
function M.on_fg_score_change_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
  
    -- Event.Brocast("model_fg_score_change_msg",data)
end
function M.on_fg_auto_cancel_signup_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end
function M.on_fg_auto_quit_game_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end
function M.on_fg_ready_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    local seatno = data.seat_num
    if m_data.players_info[seatno] then
        m_data.players_info[seatno].ready = 1
    end
    Event.Brocast("model_fg_ready_msg", seatno)
end

--response
function M.on_fg_signup_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
end
function M.on_fg_switch_game_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    DominoJLLogic.SendRequestAllInfo()
end
function M.on_fg_cancel_signup_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
        Event.Brocast("model_fg_cancel_signup_response", data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_fg_replay_game_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        M.on_fg_signup_response(proto_name, data)
    else
        local msg = errorCode[data.result] or ("错误：" .. data.result)
        HintPanel.ErrorMsg(data.result, function()
            ResetData()
            MainLogic.ExitGame()
            Event.Brocast("model_fg_replay_game_response", data.result)
        end)
    end
end
function M.on_fg_quit_game_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
    end
    Event.Brocast("model_fg_quit_game_response", data.result)
end
function M.on_fg_ready_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        m_data.model_status = M.Model_Status.wait_begin
        m_data.status = nil
        if m_data.players_info[m_data.seat_num] then
            m_data.players_info[m_data.seat_num].ready = 1
        end
    end
    Event.Brocast("model_fg_ready_response",data)

    if data.result ~= 0 then
        Network.SendRequest("fg_quit_game")
    end
end

function M.on_fg_huanzhuo_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        m_data.model_status = M.Model_Status.wait_table
        m_data.status = nil
        m_data.players_info = {}
    end
    Event.Brocast("model_fg_huanzhuo_response",data)

    if data.result ~= 0 then
        Network.SendRequest("fg_quit_game")
    end
end

function M.on_nor_dmn_nor_ready_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    
end

function M.on_nor_dmn_nor_auto_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        m_data.auto_status[m_data.seat_num] = data.operate
    end
    Event.Brocast("model_nor_dmn_nor_auto_response",data)
end

function M.on_nor_dmn_nor_cp_response(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_nor_dmn_nor_cp_response",data)
end

--玩法
function M.on_nor_dmn_nor_status_info(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
end
function M.on_nor_dmn_nor_ready_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    if not data.seat_num then
        return
    end
    m_data.players_info = m_data.players_info or {}
    m_data.players_info[data.seat_num].ready = 1
    Event.Brocast("model_nor_dmn_nor_ready_msg",data)
end
function M.on_nor_dmn_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")

    for i, v in ipairs(m_data.players_info or {}) do
        v.ready = 2
    end

    Event.Brocast("model_nor_dmn_nor_begin_msg")
end
function M.on_nor_dmn_nor_pai_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.fp
    m_data.round = data.round
    m_data.race = data.cur_race
    m_data.my_pai_list = data.pai_data
    DominoJLLib.SortPai(m_data.my_pai_list)
    m_data.remain_pai_amount = {}
    for i = 1, M.maxPlayerNumber do
        m_data.remain_pai_amount[i] = 7
    end
    Event.Brocast("model_nor_dmn_nor_pai_msg")
end
function M.on_nor_dmn_nor_cp_permit(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 0.1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p

    Event.Brocast("model_nor_dmn_nor_cp_permit")
end
-- 过程数据
function M.on_nor_dmn_nor_cp_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.table_pai[#m_data.table_pai + 1] = data
    if data.pai ~= 0 then
        m_data.remain_pai_amount[data.seat_num] = m_data.remain_pai_amount[data.seat_num] - 1        
    end

    for i, pai in ipairs(m_data.my_pai_list) do
        if data.pai == pai then
            table.remove(m_data.my_pai_list,i)
            break
        end
    end

    Event.Brocast("model_nor_dmn_nor_cp_msg",data)
end

function M.GetTablePai()
    return m_data.table_pai
end

function M.GetMyPaiList()
    return m_data.my_pai_list
end

function M.on_nor_dmn_nor_ding_zhuang_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.dz
    m_data.zhuang = data.zhuang_seat_num
    Event.Brocast("model_nor_dmn_nor_ding_zhuang_msg")
end
function M.on_nor_dmn_nor_auto_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.auto_status = m_data.auto_status or {}
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("model_nor_dmn_nor_auto_msg", data)
end
function M.on_nor_dmn_nor_new_game_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    m_data.status = data.status
    m_data.race = data.cur_race
    m_data.curr_all_player = data.curr_all_player
    Event.Brocast("model_nor_dmn_nor_new_game_msg")
end
--结算消息
function M.on_nor_dmn_nor_settlement_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.settlement
    m_data.settlement_info = data.settlement_info
    for i, v in ipairs(m_data.settlement_info.remain_pai) do
        DominoJLLib.SortPai(v.pai)
    end
    for i = 1,#data.settlement_info.scores do
        if  m_data.players_info[i] then
            if i == m_data.seat_num then
                m_data.players_info[i].score = MainModel.UserInfo.jing_bi
            else
                m_data.players_info[i].score = m_data.players_info[i].score + data.settlement_info.scores[i]
            end
        end
    end
    Event.Brocast("model_nor_dmn_nor_settlement_msg",data)
end
function M.on_nor_dmn_nor_score_change_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    for i = 1,#data.data do
        if  m_data.players_info[i] then
            if i == m_data.seat_num then
                m_data.players_info[i].score = MainModel.UserInfo.jing_bi
            else
                m_data.players_info[i].score = m_data.players_info[i].score + data.data[i]
            end
        end
    end
    Event.Brocast("model_nor_dmn_nor_score_change_msg",data)
end

function M.on_nor_dmn_nor_ybq_msg(proto_name, data)
    dump(data, "<color=red>[Domino] msg data proto_name = " .. proto_name .. "</color>")
    m_data.ybq_data = m_data.ybq_data or {}
    m_data.ybq_data[data.seat_num] = data.ds
    Event.Brocast("model_nor_dmn_nor_ybq_msg",data)
end

function M.CheckBetType()
    if DominoJLModel.data.jdz_type == "nor" then
        return "nor"
    else
        return "bet"
    end
end

function M.S2CQueuePos(lr)
    if lr == 1 then
        return "front"
    elseif lr == 0 then
        return "back"
    end
end

function M.C2SQueuePos(qp)
    if qp == "front" then
        return 1
    elseif qp == "back" then
        return 0
    end
end

function M.CheckBrokeProcess()
    local game_id = DominoJLModel.data.game_id
	local info = MainModel.GetInfoByGameID(game_id)
    if not info then return end
	--如果玩家不满足当前场次的条件
	if MainModel.UserInfo.jing_bi < info.limit_min then
		return true
	end
end

function M.CheckMeIsAutoState()
    return DominoJLModel.data.auto_status[DominoJLModel.data.seat_num] == 1
end

function M.CheckBestGameID()
    local gameType = MainLogic.GetGameTypeByGameID(DominoJLModel.data.game_id)
    local b = MainModel.CheckBestGameID(gameType,DominoJLModel.data.game_id)
    return b
end

function M.GetBestGameID()
    local gameType = MainLogic.GetGameTypeByGameID(DominoJLModel.data.game_id)
    local gameId = MainModel.GetBestGameID(gameType)
    return gameId
end