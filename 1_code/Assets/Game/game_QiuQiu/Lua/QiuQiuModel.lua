-- 创建时间:2021-11-08

QiuQiuModel = {}
local M = QiuQiuModel
M.maxPlayerNumber = 7
M.last_game_id = nil
M.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --在桌子上
    in_table = "in_table",
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
    --第一轮发牌
    fp1 = "fp1",
    --第二轮发牌
    fp2 = "fp2",
    --第一轮说话
    stake1 = "stake1",
    --第二轮说话
    stake2 = "stake2",
    --说话阶段
    speak = "speak",
    --调整阶段
    adjust = "adjust",
    --结算
    settlement = "settlement",
    --结束
    gameover = "gameover",
    --玩家进入托管状态
    auto = "auto",
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
    game_lister["fast_all_info"] = this.on_fast_all_info
    game_lister["fast_enter_room_msg"] = this.on_fast_enter_room_msg
    game_lister["fast_join_msg"] = this.on_fast_join_msg
    game_lister["fast_ready_msg"] = this.on_fast_ready_msg
    game_lister["fast_leave_msg"] = this.on_fast_leave_msg
    game_lister["fast_gameover_msg"] = this.on_fast_gameover_msg
    game_lister["fast_score_change_msg"] = this.on_fast_score_change_msg
    game_lister["fast_auto_cancel_signup_msg"] = this.on_fast_auto_cancel_signup_msg
    game_lister["fast_auto_quit_game_msg"] = this.on_fast_auto_quit_game_msg
    game_lister["fast_player_score_change_msg"] = this.on_fast_player_score_change_msg
    --fg response
    game_lister["fast_signup_response"] = this.on_fast_signup_response
    game_lister["fast_switch_game_response"] = this.on_fast_switch_game_response
    game_lister["fast_cancel_signup_response"] = this.on_fast_cancel_signup_response
    game_lister["fast_replay_game_response"] = this.on_fast_replay_game_response
    game_lister["fast_quit_game_response"] = this.on_fast_quit_game_response
    game_lister["fast_ready_response"] = this.on_fast_ready_response
    game_lister["fast_huanzhuo_response"] = this.on_fast_huanzhuo_response
    game_lister["fast_sitdown_response"] = this.on_fast_sitdown_response

    --玩法
    game_lister["nor_qiuqiu_nor_ready_msg"] = this.on_nor_qiuqiu_nor_ready_msg
    game_lister["nor_qiuqiu_nor_begin_msg"] = this.on_nor_qiuqiu_nor_begin_msg
    game_lister["nor_qiuqiu_nor_pai_msg"] = this.on_nor_qiuqiu_nor_pai_msg
    game_lister["nor_qiuqiu_nor_ding_zhuang_msg"] = this.on_nor_qiuqiu_nor_ding_zhuang_msg
    game_lister["nor_qiuqiu_nor_stake_permit"] = this.on_nor_qiuqiu_nor_stake_permit

    game_lister["nor_qiuqiu_nor_award_msg"] = this.on_nor_qiuqiu_nor_award_msg
    game_lister["nor_qiuqiu_nor_score_change_msg"] = this.on_nor_qiuqiu_nor_score_change_msg
    game_lister["nor_qiuqiu_nor_settlement_msg"] = this.on_nor_qiuqiu_nor_settlement_msg
    game_lister["nor_qiuqiu_nor_new_game_msg"] = this.on_nor_qiuqiu_nor_new_game_msg
    game_lister["nor_qiuqiu_nor_auto_msg"] = this.on_nor_qiuqiu_nor_auto_msg
    game_lister["nor_qiuqiu_nor_stake_msg"] = this.on_nor_qiuqiu_nor_stake_msg
    game_lister["nor_qiuqiu_nor_adjust_msg"] = this.on_nor_qiuqiu_nor_adjust_msg
    game_lister["nor_qiuqiu_nor_adjust_permit"] = this.on_nor_qiuqiu_nor_adjust_permit

    --nor response
    game_lister["nor_qiuqiu_nor_ready_response"] = this.on_nor_qiuqiu_nor_ready_response
    game_lister["nor_qiuqiu_nor_quit_response"] = this.on_nor_qiuqiu_nor_quitresponse
    game_lister["nor_qiuqiu_nor_auto_response"] = this.on_nor_qiuqiu_nor_auto_response

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
        if proto_name ~= "fast_all_info" then
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
        --上一次得投注 
        last_stake = 0,
        --玩家奖励
        award = {},
        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)
        settlement_info = nil,
        settlement_players_info=nil,
    }
    m_data = M.data
    m_data.max_total_stake = 0
end
function M.Init()
    this = M
    InitData()
    ResetData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()
    M.InitUpdate()
    QiuQiuExchangeChipPanel.IsFirstInGame = true
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

function M.AssetChange(proto_name, data)
    data = {score = MainModel.UserInfo.jing_bi}
    dump(data, "<color=yellow>AssetChange</color>")
    
    Event.Brocast("model_AssetChange")
end

--模式
function M.on_fast_all_info(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    if data.status_no == -1 then
        ResetData()
        MainLogic.ExitGame()
        QiuQiuLogic.change_panel(QiuQiuLogic.panelNameMap.hall)
        return
    end

    local s = data
    if s then
        m_data.model_status = s.status
        m_data.game_type = s.game_type
        m_data.countdown = s.countdown
        m_data.chip = tonumber(s.chip)
        M.data = M.data or {}
    end

    s = data.room_info
    if s then
        m_data.init_stake = s.init_stake
        m_data.init_rate = s.init_rate
        m_data.game_id = s.game_id
        M.last_game_id = s.game_id
        m_data.chip_min = tonumber(s.chip_min)
        m_data.chip_max = tonumber(s.chip_max)
    end

    s = data.players_info
    m_data.players_info = {}
    if s then
        for k, v in pairs(s) do
            if v.seat_num > 0 then
                m_data.players_info[v.seat_num] = v
            end
            if v.id == MainModel.UserInfo.user_id then
                m_data.seat_num = v.seat_num
                m_data.score = v.score
            end
        end
    end
    s = data.nor_qiuqiu_nor_status_info
    if s then
        m_data.status = s.status
        m_data.countdown = s.countdown
        m_data.cur_p = s.cur_p
        m_data.award = s.award
        m_data.auto_status = s.auto_status or {}
        m_data.seat_num = s.seat_num
        m_data.zhuang = s.zhuang_seat_num
        m_data.is_over = s.is_over
        m_data.init_stake = s.init_stake or m_data.init_stake
        m_data.ready = s.ready
        m_data.cur_race = s.cur_race
        m_data.race_count = s.race_count
        m_data.settlement_info = s.settlement_info
        m_data.last_stake_data = {}
        s.play_info = s.play_info or {}
        m_data.play_info = s.play_info
        --计算好当前的加注
        for k , v in pairs(s.play_info) do
            local value = tonumber(v.stake)
            if value > 0 then
                m_data.last_stake_data[v.seat_num] = tonumber(v.stake) 
            end
        end
        m_data.pai_data = s.my_pai
        --当前押注的金额
        m_data.last_stake = s.cur_stake or 0
    end

    -- 结算界面的player
    m_data.settlement_players_info = data.settlement_players_info

    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    QiuQiuLib.transform_seat(
        m_data.seatNum,
        m_data.s2cSeatNum,
        m_data.seat_num,
        M.maxPlayerNumber
    )

    M.baseData.room_rent = data.room_rent
    dump(m_data, "<color=red>model_fast_all_info :</color>")

    Event.Brocast("model_fast_all_info")
end

function M.on_fast_enter_room_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gaming
    m_data.status = M.Status.ready
    for k, v in pairs(data.players_info) do
        m_data.players_info[v.seat_num] = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end
    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    QiuQiuLib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, M.maxPlayerNumber)
    m_data.my_rate = m_data.init_rate or 1
    m_data.race = 1
    if m_data.seat_num then
        Event.Brocast("model_fast_enter_room_msg")
    end
end

function M.on_fast_join_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_fast_join_msg", data.player_info.seat_num)
end

function M.on_fast_ready_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    local seatno = data.seat_num
    if m_data.players_info[seatno] then
        m_data.players_info[seatno].ready = 1
    end
    Event.Brocast("model_fast_ready_msg", seatno)
end

function M.on_fast_leave_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.players_info[data.seat_num] = nil
    Event.Brocast("model_fast_leave_msg", data.seat_num)
    if data.seat_num == m_data.seat_num then
        if data.reason == 1 then
            --Network.SendRequest("fast_quit_game")
            print("<color=red>筹码不够，但是钱够</color>")
            Event.Brocast("model_player_need_exchange_chip")
        elseif data.reason == 2 then
            print("<color=red>钱也不够了</color>")
            Event.Brocast("model_player_need_broke")
        else
            Event.Brocast("fast_quit_game_response","fast_quit_game_response",{result = 0})
        end
    end
end

function M.on_fast_gameover_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.model_status = M.Model_Status.gameover
    m_data.status = M.Status.gameover
    for k, v in pairs(m_data.players_info) do
        v.ready = 0
    end
    Event.Brocast("model_fast_gameover_msg")
end

function M.on_fast_score_change_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.score = tonumber(data.score)
    m_data.chip = tonumber(data.chip)
    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = tonumber(data.score)
        m_data.players_info[m_data.seat_num].chip = tonumber(data.chip)
    end
    Event.Brocast("model_fast_score_change_msg",data)
end

function M.on_fast_auto_cancel_signup_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_fast_auto_cancel_signup_msg")
end

function M.on_fast_auto_quit_game_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    MainLogic.ExitGame()
    Event.Brocast("model_fast_auto_quit_game_msg")
end

--response
function M.on_fast_signup_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_fast_switch_game_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_fast_cancel_signup_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
        Event.Brocast("model_fast_cancel_signup_response", data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_fast_replay_game_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        M.on_fast_signup_response(proto_name, data)
    else
        HintPanel.ErrorMsg(data.result, function()
            ResetData()
            MainLogic.ExitGame()
            Event.Brocast("model_fast_cancel_signup_response", data.result)
        end)
    end
end

function M.on_fast_quit_game_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        MainLogic.ExitGame()
    end
    if data.result ~= 0 then
        LittleTips.Create(GLL.GetTx(20027))
    end
    Event.Brocast("model_fast_quit_game_response", data.result)
    print("<color=red>退出的消息+</color>")
end

function M.on_fast_ready_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        ResetData()
        m_data.model_status = M.Model_Status.wait_begin
        m_data.status = nil
        if m_data.players_info[m_data.seat_num] then
            m_data.players_info[m_data.seat_num].ready = 1
        end
        Event.Brocast("model_fast_ready_response")
    else
        Network.SendRequest("fast_quit_game")
    end
end

--nor msg
function M.on_nor_qiuqiu_nor_ready_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    Event.Brocast("model_nor_qiuqiu_nor_ready_msg",data)
end

function M.on_nor_qiuqiu_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.last_stake = 0
    Event.Brocast("model_nor_qiuqiu_nor_begin_msg",data)
end

function M.on_nor_qiuqiu_nor_pai_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.pai_data = data.pai_data
    m_data.last_stake = 0
    m_data.last_stake_data = {}
    m_data.max_total_stake = 0
    if #data.pai_data == 3 then
        m_data.status = M.Status.fp1
    else
        m_data.status = M.Status.fp2
    end
    Event.Brocast("model_nor_qiuqiu_nor_pai_msg",data)
end

function M.on_nor_qiuqiu_nor_ding_zhuang_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.dz
    m_data.zhuang = data.zhuang_seat_num
    Event.Brocast("model_nor_qiuqiu_nor_ding_zhuang_msg",data)
end


function M.on_nor_qiuqiu_nor_award_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.award[data.seat_num] = m_data.award[data.seat_num] or 0
    m_data.award[data.seat_num] = m_data.award[data.seat_num] + data.award
    Event.Brocast("model_nor_qiuqiu_nor_award_msg",data)
end
--这个是相对值
function M.on_nor_qiuqiu_nor_score_change_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    local seat_num = data.seat_num

    dump(m_data.players_info)
    m_data.players_info[seat_num] = m_data.players_info[seat_num] or {}
    m_data.players_info[seat_num].score = m_data.players_info[seat_num].score or 0
    m_data.players_info[seat_num].score = m_data.players_info[seat_num].score + tonumber(data.score)
    m_data.players_info[seat_num].chip = m_data.players_info[seat_num].chip or 0
    m_data.players_info[seat_num].chip = tonumber(m_data.players_info[seat_num].chip) + tonumber(data.chip)

    if seat_num == m_data.seat_num then
        m_data.chip = m_data.chip + tonumber(data.chip)
        m_data.score = m_data.score + tonumber(data.score)
    end
    dump(m_data.players_info)
    Event.Brocast("model_nor_qiuqiu_nor_score_change_msg",data)
end
--这个是绝对值
function M.on_fast_player_score_change_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    local seat_num = data.seat_num

    dump(m_data.players_info)
    m_data.players_info[seat_num] = m_data.players_info[seat_num] or {}
    m_data.players_info[seat_num].score = m_data.players_info[seat_num].score or 0
    m_data.players_info[seat_num].score = tonumber(data.score)
    m_data.players_info[seat_num].chip = tonumber(data.chip)

    if seat_num == m_data.seat_num then
        m_data.chip = tonumber(data.chip)
    end
    Event.Brocast("model_nor_qiuqiu_nor_score_change_msg",data)
end

function M.on_nor_qiuqiu_nor_settlement_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.settlement
    --m_data.model_status = M.Model_Status.gameover
    m_data.settlement_info = data.settlement_info

    Event.Brocast("model_nor_qiuqiu_nor_settlement_msg",data)
end

function M.on_nor_qiuqiu_nor_new_game_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    ResetData()
    m_data.status = data.status
    m_data.race = data.cur_race
    m_data.curr_all_player = data.curr_all_player
    Event.Brocast("model_nor_qiuqiu_nor_new_game_msg",data)
end

function M.on_nor_qiuqiu_nor_auto_msg(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.auto_status = m_data.auto_status or {}
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("model_nor_qiuqiu_nor_auto_msg", data)
end

function M.on_fast_huanzhuo_response(proto_name,data)
    dump(data,"<color=red>换桌消息++++++++++++++++++++</color>")
    Event.Brocast("model_fast_huanzhuo_response", data)
    if data.result ~= 0 then
        LittleTips.Create(GLL.GetTx(20027))
    end
end

function M.on_fast_sitdown_response(proto_name,data)
    dump(data,"<color=red>坐下的消息++++++++++++++++++++</color>")
    Event.Brocast("model_fast_sitdown_response", data)
end

function M.on_nor_qiuqiu_nor_stake_msg(proto_name,data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.max_total_stake = M.GetTotalMaxStake()

    m_data.last_stake_data = m_data.last_stake_data or {}
    m_data.last_stake_data[data.seat_num] = m_data.last_stake_data[data.seat_num] or 0
    --  -1是弃牌 不包含弃牌
    if data.stake >= 0 then
        --记录较大的值
        if data.stake >= m_data.last_stake then
            m_data.last_stake = data.stake
        end
    end
    if data.stake > 0 then       
        m_data.last_stake_data[data.seat_num] =  m_data.last_stake_data[data.seat_num] + data.stake 
    end

    if m_data.max_total_stake ~= M.GetTotalMaxStake() then
        m_data.isRaised = true
    else
        m_data.isRaised = false
    end

    m_data.max_total_stake = M.GetTotalMaxStake()
    Event.Brocast("model_nor_qiuqiu_nor_stake_msg",data)
end
--获取我的累计押注
function M.GetMyTotalStake()
    return m_data.last_stake_data[m_data.seat_num] or 0
end

--获取某一位玩家的累计下注,通过UI位置标记
function M.GetTotalStakeByCseat(Cseat)
    local seat = m_data.seatNum[Cseat]
    return m_data.last_stake_data[seat] or 0
end

--获取当前总的押注
function M.GetTotalStake()
    local sum = 0
    m_data.last_stake_data = m_data.last_stake_data or {}
    for K , v in pairs(m_data.last_stake_data) do
        sum = sum + v
    end
    return sum
end

--获取当前最高的累计下注
function M.GetTotalMaxStake()
    m_data.last_stake_data = m_data.last_stake_data or {}
    local sum = 0
    for K , v in pairs(m_data.last_stake_data) do
        if v and v > sum then
            sum = v
        end
    end
    return sum
end
--nor response
function M.on_nor_qiuqiu_nor_ready_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_qiuqiu_nor_quit_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_qiuqiu_nor_auto_response(proto_name, data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
end

function M.on_nor_qiuqiu_nor_stake_permit(proto_name,data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = data.status
    m_data.cur_p = data.cur_p
    m_data.countdown = data.countdown
    Event.Brocast("model_nor_qiuqiu_nor_stake_permit",data)
end

function M.on_nor_qiuqiu_nor_adjust_permit(proto_name,data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = data.status
    m_data.cur_p = data.cur_p
    m_data.countdown = data.countdown
    Event.Brocast("model_nor_qiuqiu_nor_adjust_permit",data)
end

function M.on_nor_qiuqiu_nor_adjust_msg(proto_name,data)
    dump(data, "<color=red>[qiuqiu] msg data proto_name = " .. proto_name .. "</color>")
    m_data.status = M.Status.adjust

    Event.Brocast("model_nor_qiuqiu_nor_adjust_msg",data)
end

--是不是轮到我说话
function M.IsMyTurn()
    if m_data.cur_p == m_data.seat_num then
        return true
    else
        return false
    end
end

--获取当前所剩的筹码
function M.GetMyChipNum()
    return QiuQiuModel.data.chip
end

--如果座位号是0 说明我没有坐下
function M.GetMyState()
    for k , v in pairs(QiuQiuModel.data.playerList) do
        if v.id == MainModel.UserInfo.user_id then
            return v.seat_num > 0
        end
    end
end