-- 创建时间:2021-12-10
local basefunc = require "Game/Common/basefunc"
SlotsModel = {}
local M = SlotsModel
local cur_path = "Game.game_Slots.Lua."
local betCfg = ext_require(cur_path .. "slots_bet_config").bet
dump(betCfg,"<color=yellow>betCfg</color>")
local awardPoolRate = {
    [1] = 10 * 88,
    [2] = 25 * 88,
    [3] = 50 * 88,
    [4] = 200 * 88,
}

M.SkipAllAni = false

M.size = {
    xMax = 5,
    yMax = 3,
    xSize = 164,
    ySize = 129,
    xSpac = 0,
    ySpac = 0
}

SlotsModel.time = {}

SlotsModel.time.scrollSpeedUpInterval = 0    --加速滚动间隔
SlotsModel.time.scrollSpeedUpTime = 0.2  --加速滚动时间
SlotsModel.time.scrollSpeedUniformAllTime = 1.4    --匀速滚动时间
SlotsModel.time.scrollSpeedUniformOneTime = 0.02 --每一次匀速滚动到下一个位置时间
SlotsModel.time.scrollSpeedDownInterval = 0.2    --减速滚动间隔
SlotsModel.time.scrollSpeedDownTime = 0.2    --减速滚动时间
SlotsModel.time.scrollSpeedUniformAddTime = 2    --匀速滚动每次额外增加的时间

SlotsModel.time.scrollItem = 2         --一个元素转动时间
SlotsModel.time.scrollInterval = 0.1    --转动元素的间隔
SlotsModel.time.autoLottery = 1        --自动开奖是否开启判定时间
SlotsModel.time.autoWait = 0.1        --自动开奖等待时间

SlotsModel.time.lottery = 0.2      --转动完成每次开奖的时间
SlotsModel.time.effectItemWinConnect = 1.5 --转动完成每次开奖的边框特效显示的时间
SlotsModel.time.settlementItemWinConnect = 0.1 --元素连线开奖后（如果有）弹出结算的时间
SlotsModel.time.changeMoneyDelay = 1.6     --触发5连并且是BIG WIN及以上时候，下方数字延迟两秒


SlotsModel.time.effectItemDGoldLightBack = 0.2 --聚宝盆闪光后到拖尾出现的时间
SlotsModel.time.effectItemDGoldFlyFront = 0.2 --聚宝盆拖尾出现到开始飞行的时间
SlotsModel.time.effectItemDGoldFly = 0.6 --聚宝盆拖尾飞行的时间

SlotsModel.time.effectItemERollFront = 2 --红福翻滚特效的前的等待时间
SlotsModel.time.effectItemERoll = 3 --红福翻滚特效的时间
--选择界面自动选择时间
SlotsModel.time.autoChooseMini = 20 + SlotsModel.time.effectItemERollFront + SlotsModel.time.effectItemERoll

SlotsModel.time.effectAddFreeLightBack = 0.2 --聚宝盆闪光后到拖尾出现的时间
SlotsModel.time.effectAddFreeFlyFront = 0.2 --聚宝盆拖尾出现到开始飞行的时间
SlotsModel.time.effectAddFreeFly = 0.6 --聚宝盆拖尾飞行的时间
--免费次数增加时间
SlotsModel.time.effectAddFree = SlotsModel.time.effectAddFreeLightBack + SlotsModel.time.effectAddFreeFlyFront + SlotsModel.time.effectAddFreeFly + 0.02

SlotsModel.time.effectMiniGame1RateLightBack = 0.2 --小游戏普通结算元素闪光后到拖尾出现的时间
SlotsModel.time.effectMiniGame1RateFlyFront = 0.2 --小游戏普通结算元素拖尾出现到开始飞行的时间
SlotsModel.time.effectMiniGame1RateFly = 0.6 --小游戏普通结算元素拖尾飞行的时间

SlotsModel.time.effectMiniGame1RateClearFly = 0.5 --小游戏1最后结算倍率飞行的时间
SlotsModel.time.effectMiniGame1RateClearTxtChange = 0.2 --小游戏1最后结算总的倍率数字变化的时间
SlotsModel.time.effectMiniGame1AwardFly = 0.5 --小游戏1倍率飞到中间

SlotsModel.time.effectMiniGame2RateClearFly = 0.6 --小游戏2最后结算福绿倍率飞到右上角飞行的时间
SlotsModel.time.effectMiniGame2RateClearTxtChange = 0.2 --小游戏2最后结算福绿倍率飞到右上角后的倍率数字变化的时间

SlotsModel.time.effectMiniGame2RateInitFly = 0.4 --小游戏2初始化倍率飞行的时间
SlotsModel.time.effectMiniGame2RateInitTxtChange = 0.2 --小游戏2初始化倍率数字变化的时间
SlotsModel.time.effectMiniGame2AwardFly = 0.5 --小游戏2倍率右上角飞到中间

SlotsModel.time.miniGame1WaitScroll = 0.2 --小游戏1等待转动的时间
SlotsModel.time.miniGame1WaitLottery = 0.2 --小游戏1转动完成等待开奖的时间
SlotsModel.time.miniGame1Lottery = 0.2 --小游戏1转动完成每次开奖的时间（动态？？？）


SlotsModel.time.miniGame2InitRateEFlyFront = 0.5 --小游戏2初始化一个福红倍率飞行前等待时间
--小游戏2初始化一个福红倍率飞行时间
SlotsModel.time.miniGame2InitRateEFly = SlotsModel.time.effectMiniGame2RateInitFly + SlotsModel.time.effectMiniGame2RateInitTxtChange
SlotsModel.time.miniGame2InitRateEFlyBack = 0.2 --小游戏2初始化所有福红倍率飞行完等待时间

SlotsModel.time.miniGame2WaitScroll = 0.05 --小游戏2等待转动的时间
SlotsModel.time.miniGame2WaitLottery = 0.05 --小游戏2转动完成等待开奖的时间
SlotsModel.time.miniGame2SettlementItemWinConnect = 0.1 --小游戏2元素连线开奖后（如果有）弹出结算的时间
SlotsModel.time.miniGame2EffectItemWinConnect = 1.5 --小游戏2转动完成每次开奖的边框特效显示的时间

SlotsModel.time.miniGame3OpenAwardPoolFront = 2 --小游戏3开启奖池前等待时间
SlotsModel.time.miniGame3OpenAwardPool = 1 --小游戏3开启奖池前时间
SlotsModel.time.miniGame3LotteryEndFront = 0.1 --小游戏3结束前等待时间

SlotsModel.time.miniGame3ShowEffect = 1 --小游戏3显示特效的时间
SlotsModel.time.miniGame3RefreshItem = 2.5 --小游戏3创建蛋的时间
--小游戏3自动开奖的时间
SlotsModel.time.miniGame3AutoOpen = 30 + SlotsModel.time.miniGame3ShowEffect + SlotsModel.time.miniGame3RefreshItem
--小游戏3出一个小奖自动开奖的时间
SlotsModel.time.miniGame3AutoOpenMinGold = SlotsModel.time.miniGame3ShowEffect + SlotsModel.time.miniGame3RefreshItem

SlotsModel.time.openAwardPool = 1  --开启奖池用时

SlotsModel.time.moneyChangeLine = 2 --连线获得的钱改变的动画时长

SlotsModel.time.clearHide = 0.4  --结算完成后关闭等待时长
SlotsModel.time.clear5line = 1 --5连线效果时长
SlotsModel.time.clearNormalLv1 = 3 --普通结算等级1效果时长
SlotsModel.time.clearNormalLv2 = 3 --普通结算等级2效果时长
SlotsModel.time.clearNormalLv3 = 3 --普通结算等级3效果时长

--小游戏1普通结算一个元素动画的时长
SlotsModel.time.clearMiniGame1NormalItemAni = SlotsModel.time.effectMiniGame1RateLightBack + SlotsModel.time.effectMiniGame1RateFlyFront + SlotsModel.time.effectMiniGame1RateFly + 0.02
--小游戏1结算一个倍率飞行动画的时长
SlotsModel.time.clearMiniGame1RateAni = SlotsModel.time.effectMiniGame1RateClearFly + SlotsModel.time.effectMiniGame1RateClearTxtChange +0.1
SlotsModel.time.clearMiniGame1Normal = 1 --小游戏1普通结算动画结束后的时长

SlotsModel.time.clearMiniGame1BGChange = 0.2 --小游戏1总结算面板背景放大时长
SlotsModel.time.clearMiniGame1BonusChangeMax = 0.3 --小游戏1总结算面板Bonus放大时长
SlotsModel.time.clearMiniGame1BonusChangeMin = 0.2 --小游戏1总结算面板Bonus缩小时长
SlotsModel.time.clearMiniGame1XShow = 0.6 --小游戏1总结算面板X渐显时间
SlotsModel.time.clearMiniGame1PlayShow = 0.6 --小游戏1总结算面板Play渐显时间
SlotsModel.time.clearMiniGame1BonusPlayFlyFront = 1.2 --小游戏1总结算面板Bonus和Play飞行时间
SlotsModel.time.clearMiniGame1BonusPlayFly = 0.6 --小游戏1总结算面板Bonus和Play飞行时间
--小游戏1总结算时长
SlotsModel.time.clearMiniGame1 = SlotsModel.time.clearMiniGame1BonusPlayFlyFront + SlotsModel.time.clearMiniGame1BGChange + SlotsModel.time.clearMiniGame1BonusChangeMin + SlotsModel.time.clearMiniGame1XShow + SlotsModel.time.clearMiniGame1PlayShow + SlotsModel.time.clearMiniGame1BonusPlayFly


--小游戏2结算一个倍率飞行动画的时长
SlotsModel.time.clearMiniGame2RateAni = SlotsModel.time.effectMiniGame2RateClearFly + SlotsModel.time.effectMiniGame2RateClearTxtChange

SlotsModel.time.clearMiniGame2BGChange = 0.2 --小游戏2总结算面板背景放大时长
SlotsModel.time.clearMiniGame2BonusChangeMax = 0.3 --小游戏2总结算面板Bonus放大时长
SlotsModel.time.clearMiniGame2BonusChangeMin = 0.2 --小游戏2总结算面板Bonus缩小时长
SlotsModel.time.clearMiniGame2XShow = 0.6 --小游戏2总结算面板X渐显时间
SlotsModel.time.clearMiniGame2AddShow = 0.6 --小游戏2总结算面板+渐显时间
SlotsModel.time.clearMiniGame2PlayShow = 0.6 --小游戏2总结算面板Play渐显时间
SlotsModel.time.clearMiniGame2WinShow = 0.6 --小游戏2总结算面板Win渐显时间
SlotsModel.time.clearMiniGame2WinFly = 0.6 --小游戏2总结算面板Win飞行时间
SlotsModel.time.clearMiniGame2WinChange = 0.6 --小游戏2总结算面板Win飞行时间
SlotsModel.time.clearMiniGame2BonusPlayFlyFront = 1.2 --小游戏2总结算面板Bonus和Play飞行时间
SlotsModel.time.clearMiniGame2BonusPlayFly = 0.6 --小游戏2总结算面板Bonus和Play飞行时间
--小游戏2总结算时长
SlotsModel.time.clearMiniGame2 = SlotsModel.time.clearMiniGame2BGChange 
                        + SlotsModel.time.clearMiniGame2BonusChangeMin
                        + SlotsModel.time.clearMiniGame2XShow
                        + SlotsModel.time.clearMiniGame2AddShow
                        + SlotsModel.time.clearMiniGame2PlayShow
                        + SlotsModel.time.clearMiniGame2WinShow
                        + SlotsModel.time.clearMiniGame2WinFly
                        + SlotsModel.time.clearMiniGame2WinChange
                        + SlotsModel.time.clearMiniGame2BonusPlayFlyFront
                        + SlotsModel.time.clearMiniGame2BonusPlayFly

SlotsModel.time.clearMiniLast = 6 --结算等级3效果时长

SlotsModel.time.clearAwardPool1 = 6 --奖池1的效果时长
SlotsModel.time.clearAwardPool2 = 6 --奖池2的效果时长
SlotsModel.time.clearAwardPool3 = 6 --奖池3的效果时长

SlotsModel.time.clearAwardPool4 = 6 --奖池4的效果时长
SlotsModel.time.clearAwardPool4MoneyRoll = 4 --奖池4获得的钱滚动的效果时长

M.ModelStatus = {
    waitBegin = "waitBegin",
    gaming = "gaming",
    gameover = "gameover"
}

M.GameStatus = {
    idle = "idle",                  --闲置状态,展示结算结果,等待开奖操作
    run = "run",                    --游戏开奖状态
}

local this
local game_lister
local lister
local m_data
local update
local updateDt = 0.1

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=green>proto_name:</color>" .. proto_name)
    local func = game_lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end
    
    func(proto_name, data)
end

function M.MakeLister()
	-- 游戏相关
    game_lister = {}
    game_lister["slot_jymt_all_info_response"] = M.slot_jymt_all_info_response
    game_lister["slot_jymt_enter_game_response"] = M.slot_jymt_enter_game_response
    game_lister["slot_jymt_quit_game_response"] = M.slot_jymt_quit_game_response
    game_lister["slot_jymt_kaijiang_response"] = M.slot_jymt_kaijiang_response
    -- 其他
    lister = {}
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
    M.data = {
        autoNum = M.data and M.data.autoNum or 0,
        auto = M.data and M.data.auto or false,
        speed = M.data and M.data.speed or 1,
        skip = M.data and M.data.skip or false,
        bet = M.data and M.data.bet or SlotsLib.GetBetMaxByMoney(),
        GameStatus = M.GameStatus.idle,
        baseData = nil,
        awardPool = M.data and M.data.awardPool or awardPoolRate
    }

    m_data = M.data
end

function M.Init()
    this = M
    SlotsLib.Init(M.size,M.GetBetCfg(),M.GetPlayerMoney)
    InitData()
    M.InitConfig()
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
        m_data = nil
        M.data = nil
    end
end

function M.InitConfig()
    this.config = {}
end


--***********************all
function M.slot_jymt_all_info_response(proto_name, data)
    dump(data, "<color=green>[Slots] msg data proto_name = " .. proto_name .. "</color>")
    if data.result ~= 0 then
        Event.Brocast("model_slot_jymt_all_info",data)
        return
    end

    InitData()

    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetAutoNum(0)

    M.SetModelStatus(M.ModelStatus.gaming)
    M.data.baseData = SlotsLib.GetBaseData(data)
    M.SetAwardPool4ExtraMoney(M.data.baseData.awardPool4ExtraMoney)
    M.SetBet(basefunc.deepcopy(M.data.baseData.bet))

    dump(M.data, "<color=yellow>Model.data : </color>")

    Event.Brocast("model_slot_jymt_all_info",data)
end

--********************response
--进入游戏
function M.slot_jymt_enter_game_response(proto_name, data)
    dump(data, "<color=green>[Slots] msg data proto_name = " .. proto_name .. "</color>")
    InitData()
    M.SetModelStatus(M.ModelStatus.waitBegin)
    Event.Brocast("model_slot_jymt_enter_game_response", data)
end

--退出游戏
function M.slot_jymt_quit_game_response(proto_name, data)
    dump(data, "<color=green>[Slots] msg data proto_name = " .. proto_name .. "</color>")
    InitData()
    M.SetModelStatus(M.ModelStatus.gameover)
    Event.Brocast("model_slot_jymt_quit_game_response", data)
end

--开奖
function M.slot_jymt_kaijiang_response(proto_name, data)
    dump(data, "<color=green>[Slots] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        InitData()
        M.data.baseData = SlotsLib.GetBaseData(data)
        M.SetAwardPool4ExtraMoney(M.data.baseData.awardPool4ExtraMoney)
        M.SetBet(basefunc.deepcopy(M.data.baseData.bet))

        dump(M.data, "<color=yellow>Model.data : </color>")
    else
        M.SetAutoNum(0)
        M.SetAuto(false)
        M.SetSkip(false)

        dump(M.data, "<color=yellow>Model.data : </color>")
    end

    Event.Brocast("model_slot_jymt_kaijiang_response",data)
end

--*******************************方法
function M.SetModelStatus(s)
    if not M.data then
        M.data = {}
    end

    M.data.modelStatus = s
end

function M.SetGameStatus(s)
    if not M.data then
        M.data = {}
    end
    local oldGameStatus = M.data.gameStatus
    M.data.gameStatus = M.GameStatus[s]
    if oldGameStatus ~= M.data.gameStatus then
        Event.Brocast("GameStatusChange",{oldGameStatus = oldGameStatus,newGameStatus = M.data.gameStatus})
    end
end

function M.SetAutoNum(v)
    if not v and type(v) ~= "number" then
        return
    end
    M.data.autoNum = v
    M.SetAuto(M.data.autoNum ~= 0)
end

function M.GetAutoNum()
    if M.data and M.data.autoNum then
        return M.data.autoNum
    end
end

function M.SetAuto(v)
    if not v and type(v) ~= "boolean" then
        return
    end
    if M.data.auto ~= nil and M.data.auto == v then
        return
    end
    local oldAuto = M.data.auto
    M.data.auto = v
    if oldAuto ~= v then
        Event.Brocast("AutoChange",{oldAuto = oldAuto,newAuto = v})
    end
    if v then
        M.SetSpeed(2)
    else
        M.SetSpeed(1)
    end
end

function M.GetAuto()
    if M.data and M.data.auto then
        return M.data.auto
    end
end

function M.SetSpeed(v)
    if not v and type(v) ~= "number" then
        return
    end
    M.data.speed = v
end

function M.GetSpeed()
    if M.data and M.data.speed then
        return M.data.speed
    end
    return 1
end

function M.SetSkip(v)
    if not v and type(v) ~= "boolean" then
        return
    end
    M.data.skip = v
end

function M.GetSkip()
    if M.data and M.data.skip then
        return M.data.skip
    end
end

function M.SetBet(v)
    if not v and type(v) ~= "table" then
        return
    end
    local oldBet = basefunc.deepcopy(M.data.bet)
    M.data.bet = v
    M.CheckMaxGoldChange(oldBet,M.data.bet)
    M.CheckBetMoneyChange(oldBet,M.data.bet)
end

function M.GetBet()
    if M.data and M.data.bet then
        return M.data.bet
    end
end

function M.GetBetMoneyOneLine()
    local allBet = M.GetBet()
    local betMoneyOneLine
    if not allBet or not next(allBet) then
        betMoneyOneLine = 0
    else
        betMoneyOneLine = allBet.bet_money / 88
    end
    return betMoneyOneLine
end

function M.GetMaxGold()
    if M.data and M.data.bet and M.data.bet.max_gold then
        return M.data.bet.max_gold
    end
    return 0
end

function M.CheckMaxGoldChange(oldBet,newBet)
    local oldMaxGold = oldBet == nil and 0 or oldBet.max_gold
    local newMaxGold = newBet == nil and 0 or newBet.max_gold
    if oldMaxGold == newMaxGold then
        return
    end
    return
    Event.Brocast("MaxGoldChange",{oldMaxGold = oldMaxGold,newMaxGold = newMaxGold})
end

--奖池钱根据押注的钱变化而变化
function M.CheckBetMoneyChange(oldBet,newBet)
    local oldBetMoney = oldBet == nil and 0 or oldBet.bet_money
    local newBetMoney = newBet == nil and 0 or newBet.bet_money
    if oldBetMoney == newBetMoney then
        return
    end

    Event.Brocast("BetMoneyChange",{oldBetMoney = oldBetMoney,newBetMoney = newBetMoney})
end

--奖池额外的钱
function M.GetAwardPoolExtraMoney()
    if M.data and M.data.awardPoolExtraMoney then
        return M.data.awardPoolExtraMoney
    end
end

--奖池额外的钱
function M.SetAwardPoolExtraMoney(v)
    if not v and type(v) ~= "table" then
        return
    end
    M.data.awardPoolExtraMoney = M.data.awardPoolExtraMoney or {}
    for pool, rate in pairs(v) do
        M.data.awardPoolExtraMoney[pool] = rate
    end
    return M.data.awardPoolExtraMoney
end

function M.SetAwardPool4ExtraMoney(v)
    if not v and type(v) ~= "number" then
        return
    end

    local t = {[4] = v}
    M.SetAwardPoolExtraMoney(t)
end

function M.SetAwardPool(v)
    dump(v,"<color=yellow>设置奖池？？？？？？</color>")
    if not v and type(v) ~= "table" then
        return
    end
    M.data.awardPool = M.data.awardPool or {}
    for pool, rate in pairs(v) do
        M.data.awardPool[pool] = rate
    end
end

function M.GetAwardPool()
    if M.data and M.data.awardPool then
        return M.data.awardPool
    end
end

function M.GetAwardPoolMoney()
    local betMoney = M.GetBetMoneyOneLine()
    local t = {}
    if M.data and M.data.awardPool then
        for k, v in pairs(M.data.awardPool) do
            t[k] = v * betMoney
        end
    end

    if M.data and M.data.awardPoolExtraMoney then
        for k, v in pairs(M.data.awardPoolExtraMoney) do
            t[k] = t[k] + v
        end
    end
    return t
end

function M.GetTime(t,speed)
    t = t or 1
    if speed then
        return t / speed
    end
    if M and M.data and M.data.speed then
        M.data.speed = M.data.speed or 1
        return t / M.data.speed
    else
        return 0.02
    end
end

function M.GetTotalMoney()
    return M.data.totalMoney or 0
end

function M.GetTotalRate()
    return M.data.totalRate or 0
end

function M.DataDamage()
    if not M or not M.data or table_is_null(M.data) then
        HintPanel.Create(1,
            "数据异常",
            function()
                Event.Brocast("model_slot_jymt_all_info",{result = -1})
            end
        )
        return true
    end
end

function M.GetBetCfg()
    return betCfg
end

function M.GetPlayerMoney()
    return MainModel.UserInfo.jing_bi
end

local miniGameKey = "slotsMiniGame"
function M.SetMinGame(v)
    M.data.miniGame = v
    UnityEngine.PlayerPrefs.SetInt(miniGameKey,v)
end

function M.GetMiniGame()
    if M.data and M.data.miniGame then
        return M.data.miniGame
    end
    M.data.miniGame = UnityEngine.PlayerPrefs.GetInt(miniGameKey,1)
    return M.data.miniGame
end

--设置游戏过程，game:当前在哪个游戏，step:游戏中的第几步
function M.SetGameProcess(game,step)
    M.data.precess = {
        game = game,
        step = step,
    }
end

--设置游戏过程，game:当前在哪个游戏，step:游戏中的第几步
function M.GetGameProcess()
    return M.data.precess
end

--获取当前游戏进度数据
function M.GetGameProcessCurData()
    if not M.data or not M.data.baseData then
        return
    end
    local pro = M.GetGameProcess()

    local data
    if not pro or not next(pro) or pro.game == "main" then
        data = M.data.baseData.mainData
    elseif pro.game == "mini1" then
        data = M.data.baseData.mini1Data
    elseif pro.game == "mini2" then
        data = M.data.baseData.mini2Data
    elseif pro.game == "mini3" then
        data = M.data.baseData.mini3Data
    end
    return data
end