-- 创建时间:2022-02-09
local basefunc = require "Game/Common/basefunc"
LZHDModel = {}
local M = LZHDModel

local this
local game_lister
local lister
local m_data
M.MSG_Lock = true
M.ThisBeded = false
M.BetList = {}
M.MyTotalBetData = {0,0,0}
M.TotalBetData = {0,0,0}
local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>proto_name:</color>" .. proto_name)
    local func = game_lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if M.MSG_Lock and proto_name ~= "guess_apple_all_info_response" then
        return
    end

    if data.status_no then
        -- 断线重连的数据不用判断status_no
        -- "all_info" 根据具体游戏命名
        if proto_name ~= "all_info" then
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

function M.MakeLister()
	-- 游戏相关
    game_lister = {}
    game_lister["guess_apple_all_info_response"] = this.on_guess_apple_all_info
    game_lister["guess_apple_enter_room"] = this.on_guess_apple_enter_room
    game_lister["guess_apple_bet_response"] = this.on_guess_apple_bet_response
    game_lister["guess_apple_game_status_change"] = this.on_guess_apple_game_status_change
    game_lister["guess_apple_total_bet_tb"] = this.on_guess_apple_total_bet_tb
    game_lister["guess_apple_quit_room_response"] = this.on_guess_apple_quit_room
    game_lister["guess_query_history_data_response"] = this.on_guess_query_history_data_response
    -- 其他
    lister = {}
    lister["AssetChange"] = this.OnAssetChange
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
    M.data = M.data or {}
    m_data = M.data
    M.MSG_Lock = true
end
function M.Init()
    this = M
    InitData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        game_lister = nil
        lister = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.on_guess_apple_all_info(_,data)
    dump(data,"<color=red>游戏所有消息</color>")
    if data.result ~= 0 then  
        LZHDLogic.Exit()
        return
    end
    M.data = data
    --保证两份数据一致

    M.MyTotalBetData[1] = M.data.bet_data.my_bet_data[1]
    M.MyTotalBetData[2] = M.data.bet_data.my_bet_data[2]
    M.MyTotalBetData[3] = M.data.bet_data.my_bet_data[3]

    M.TotalBetData[1] = M.data.bet_data.total_bet_data[1]
    M.TotalBetData[2] = M.data.bet_data.total_bet_data[2]
    M.TotalBetData[3] = M.data.bet_data.total_bet_data[3]

    M.gaming_data = M.gaming_data or {}
    M.gaming_data.bet_data = data.bet_data
    M.gaming_data.game_data = data.game_data
    M.gaming_data.settle_data = data.settle_data
    M.gaming_data.status_data = data.status_data
    Event.Brocast("model_guess_apple_all_info")
    M.MSG_Lock = false
end
--原本第一个索引是最新的开奖，这个地方转换一下
function M.GetHistoryData()
    local data = {}
    for i = #M.data.history_data,1,-1 do
        data[#data+1] = basefunc.deepcopy(M.data.history_data[i])
    end
    return data
end

function M.on_guess_apple_enter_room(_,data)
    dump(data,"<color=red>进入房间</color>")
end

function M.on_guess_apple_bet_response(_,data)
    --- "<color=red>下注返回的数据！！！！！！！</color>" = {
        -- -     "bet_1" = {
        -- -         1 = 1
        -- -         2 = 1
        -- -         3 = 1
        -- -         4 = 1
        -- -         5 = 1
        -- -     }
        -- -     "bet_2" = {
        -- -         1 = 1
        -- -     }
        -- -     "bet_3" = {
        -- -     }
        -- -     "result" = 0
        -- - }
    --
    dump(data,"<color=red>下注返回的数据！！！！！！！</color>")
    if data.result ~= 0 then
        Event.Brocast("model_guess_apple_bet_response",data)
        return  
    end
    M.ThisBeded = true
    for i = 1,#data.bet_1 do 
        M.gaming_data.bet_data.my_bet_data[1] = M.gaming_data.bet_data.my_bet_data[1] + LZHDBetConfig[data.bet_1[i]]
        M.MyTotalBetData[1] = M.MyTotalBetData[1] + LZHDBetConfig[data.bet_1[i]]
    end

    for i = 1,#data.bet_2 do 
        M.gaming_data.bet_data.my_bet_data[2] = M.gaming_data.bet_data.my_bet_data[2] + LZHDBetConfig[data.bet_2[i]]
        M.MyTotalBetData[2] = M.MyTotalBetData[2] + LZHDBetConfig[data.bet_2[i]]
    end

    for i = 1,#data.bet_3 do 
        M.gaming_data.bet_data.my_bet_data[3] = M.gaming_data.bet_data.my_bet_data[3] + LZHDBetConfig[data.bet_3[i]]
        M.MyTotalBetData[3] = M.MyTotalBetData[3] + LZHDBetConfig[data.bet_3[i]]
    end

    M.AddMyBetList(data)
    
    Event.Brocast("model_guess_apple_bet_response",data)
end
--状态改变
function M.on_guess_apple_game_status_change(_,data)
    dump(data)
    M.gaming_data = data
    --保证两份数据一致
    M.data.bet_data = M.gaming_data.bet_data
    M.MyTotalBetData[1] = M.data.bet_data.my_bet_data[1]
    M.MyTotalBetData[2] = M.data.bet_data.my_bet_data[2]
    M.MyTotalBetData[3] = M.data.bet_data.my_bet_data[3]

    M.TotalBetData[1] = M.data.bet_data.total_bet_data[1]
    M.TotalBetData[2] = M.data.bet_data.total_bet_data[2]
    M.TotalBetData[3] = M.data.bet_data.total_bet_data[3]

    M.data.game_data = M.gaming_data.game_data
    M.data.settle_data = M.gaming_data.settle_data
    M.data.status_data = M.gaming_data.status_data
    M.data.player_info = M.gaming_data.player_info
    --下注阶段会同步一次幸运星和富豪榜
    if M.data.status_data.status == "bet" then
        M.data.rich_player_list[1] = M.gaming_data.rich_player_list[1].player_id
        --M.data.rich_player_list[2] = M.gaming_data.rich_player_list[2].player_id
        M.data.lucky_player_id =     M.gaming_data.luck_player_info.player_id
        --游戏开始的时候清空数据
        dump(M.BetList,"<color=red> 我的押注信息+++++ </color>")
    end

    if M.data.status_data.status == "settle" then
        M.ThisBeded = false
    end
    dump(data,"<color=red> 游戏状态数据发生了改变 </color>")
    Event.Brocast("model_guess_apple_game_status_change")
end
--有人下注
function M.on_guess_apple_total_bet_tb(_,data)
    dump(data,"<color=red>+++投注+++ </color>")
    M.BetData = data
    if M.data.bet_data then
        M.data.bet_data.total_bet_data = data.total_bet_data
    end
    M.TotalBetData[1] = M.BetData.total_bet_data[1]
    M.TotalBetData[2] = M.BetData.total_bet_data[2]
    M.TotalBetData[3] = M.BetData.total_bet_data[3]
    M.SetJingBi(player_id,jing_bi)
    local player_bet_data = data.player_bet_data
    for k , v in pairs(player_bet_data) do
        if v ~= "other" then
            M.SetJingBi(k,-v.total_bet_value)
        end
    end
    Event.Brocast("model_guess_apple_total_bet_tb")
end

--获取富豪榜第一
function M.GetRich1Info()
    local id = M.data.rich_player_list[1]
    return  M.data.player_info[id]
end

--获取富豪榜第二
function M.GetRich2Info()
    local id = M.data.rich_player_list[2]
    return  M.data.player_info[id]
end

--获取幸运星
function M.GetFortunateInfo()
    local id = M.data.lucky_player_id
    return  M.data.player_info[id]
end

--获取我的信息
function M.GetMyInfo()
    local id = MainModel.UserInfo.user_id
    return  M.data.player_info[id]
end

--资产改变
function M.OnAssetChange(data)
    local id = MainModel.UserInfo.user_id
    --数据同步一下
    if not M.data.player_info then return end
    M.data.player_info[id].jing_bi = MainModel.UserInfo.jing_bi
    if M.data.status_data.status == "bet" then
        Event.Brocast("lzhd_my_jingbi_info_change")
    end
end

--增减的方式来同步玩家的金币
function M.SetJingBi(player_id,jing_bi)
    if M.data.player_info and M.data.player_info[player_id] then
        M.data.player_info[player_id].jing_bi = M.data.player_info[player_id].jing_bi + jing_bi
        if M.data.status_data.status == "bet" then
            Event.Brocast("lzhd_jingbi_info_change")
        end
    end
end
--退出游戏
function M.on_guess_apple_quit_room(_,data)
    dump(data,"<color=red>退出消息++++</color>")
    if data.result == 0 then
        MainLogic.ExitGame()
        Event.Brocast("model_guess_apple_quit_room")
    else
        HintPanel.Create(1,GLL.GetTx(81005))
    end
end

--记录当前我自己的下注
function M.AddMyBetList(data)
    M.BetList = M.BetList or {}
    M.BetList.bet_1 = M.BetList.bet_1 or {}
    M.BetList.bet_2 = M.BetList.bet_2 or {}
    M.BetList.bet_3 = M.BetList.bet_3 or {}

    for i = 1,3 do
        for ii = 1,#data["bet_"..i] do
            M.BetList["bet_"..i][#M.BetList["bet_"..i]+1] = data["bet_"..i][ii]
        end
    end
end

function M.ResetMyBetList()
    M.BetList = {}
end

--历史数据
function M.on_guess_query_history_data_response(_,data)
    dump(data,"<color=red>请求历史数据</color>")
    if data.result == 0 then
        M.data.history_data = data.history_data
    end
end

--根据区域获取总的押注数量
function M.GetTotalBetByIndex(index)
    return M.TotalBetData[index] or 0
end

--根据我的区域获取总的押注数量
function M.GetMyTotalBetByIndex(index)
    return M.MyTotalBetData[index] or 0
end