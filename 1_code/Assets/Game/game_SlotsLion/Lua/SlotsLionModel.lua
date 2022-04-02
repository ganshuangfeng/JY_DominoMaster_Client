-- 创建时间:2021-12-10
local basefunc = require "Game/Common/basefunc"
SlotsLionModel = {}
local M = SlotsLionModel
local cur_path = "Game.game_SlotsLion.Lua."
local betCfg = ext_require(cur_path .. "slots_lion_bet_config").bet
dump(betCfg,"<color=yellow>betCfg</color>")
local awardPoolRate = {
    [1] = 20 * 9,
    [2] = 50 * 9,
    [3] = 0 * 9,
}

M.SkipAllAni = false

M.size = {
    xMax = 5,
    yMax = 3,
    xSize = 170,
    ySize = 150,
    xSpac = 3,
    ySpac = 5
}

SlotsLionModel.time = {}

SlotsLionModel.time.scrollSpeedUpInterval = 0    --加速滚动间隔
SlotsLionModel.time.scrollSpeedUpTime = 0.2  --加速滚动时间
SlotsLionModel.time.scrollSpeedUniformAllTime = 1.4    --匀速滚动时间
SlotsLionModel.time.scrollSpeedUniformOneTime = 0.02 --每一次匀速滚动到下一个位置时间
SlotsLionModel.time.scrollSpeedDownInterval = 0.2    --减速滚动间隔
SlotsLionModel.time.scrollSpeedDownTime = 0.2    --减速滚动时间
SlotsLionModel.time.scrollSpeedUniformAddTime = 2    --匀速滚动每次额外增加的时间

SlotsLionModel.time.scrollItem = 2         --一个元素转动时间
SlotsLionModel.time.scrollInterval = 0.1    --转动元素的间隔
SlotsLionModel.time.autoLottery = 1        --自动开奖是否开启判定时间
SlotsLionModel.time.autoWait = 0.1        --自动开奖等待时间

SlotsLionModel.time.lottery = 0.2      --转动完成每次开奖的时间
SlotsLionModel.time.effectItemWinConnect = 1.5 --转动完成每次开奖的边框特效显示的时间
SlotsLionModel.time.changeGameMain = 0.1 --元素连线开奖后（如果有）弹出结算的时间
SlotsLionModel.time.changeMoneyDelay = 1.6     --触发5连并且是BIG WIN及以上时候，下方数字延迟两秒


SlotsLionModel.time.effectItemDGoldLightBack = 0.2 --聚宝盆闪光后到拖尾出现的时间
SlotsLionModel.time.effectItemDGoldFlyFront = 0.2 --聚宝盆拖尾出现到开始飞行的时间
SlotsLionModel.time.effectItemDGoldFly = 0.6 --聚宝盆拖尾飞行的时间

SlotsLionModel.time.effectItemARollFront = 2 --鞭炮翻滚特效的前的等待时间
SlotsLionModel.time.effectItemARoll = 4 --鞭炮翻滚特效的时间
--选择界面自动选择时间
SlotsLionModel.time.autoChooseMini = 20 + SlotsLionModel.time.effectItemARollFront + SlotsLionModel.time.effectItemARoll

--免费次数增加时间
SlotsLionModel.time.effectTriggerFree = 3.8
SlotsLionModel.time.effectAddFree = 2

SlotsLionModel.time.effectMiniGame1RateLightBack = 0.2 --小游戏普通结算元素闪光后到拖尾出现的时间
SlotsLionModel.time.effectMiniGame1RateFlyFront = 0.2 --小游戏普通结算元素拖尾出现到开始飞行的时间
SlotsLionModel.time.effectMiniGame1RateFly = 0.6 --小游戏普通结算元素拖尾飞行的时间

SlotsLionModel.time.effectMiniGame1RateClearFly = 0.5 --小游戏1最后结算倍率飞行的时间
SlotsLionModel.time.effectMiniGame1RateClearTxtChange = 0.2 --小游戏1最后结算总的倍率数字变化的时间
SlotsLionModel.time.effectMiniGame1AwardFly = 0.5 --小游戏1倍率飞到中间

SlotsLionModel.time.effectMiniGame2RateClearFly = 0.6 --小游戏2最后结算福绿倍率飞到右上角飞行的时间
SlotsLionModel.time.effectMiniGame2RateClearTxtChange = 0.2 --小游戏2最后结算福绿倍率飞到右上角后的倍率数字变化的时间

SlotsLionModel.time.effectMiniGame2RateInitFly = 0.4 --小游戏2初始化倍率飞行的时间
SlotsLionModel.time.effectMiniGame2RateInitTxtChange = 0.2 --小游戏2初始化倍率数字变化的时间
SlotsLionModel.time.effectMiniGame2AwardFly = 0.5 --小游戏2倍率右上角飞到中间

SlotsLionModel.time.miniGame1WaitScroll = 0.2 --小游戏1等待转动的时间
SlotsLionModel.time.miniGame1WaitLottery = 0.2 --小游戏1转动完成等待开奖的时间
SlotsLionModel.time.miniGame1Lottery = 0.2 --小游戏1转动完成每次开奖的时间（动态？？？）


SlotsLionModel.time.miniGame2InitRateEFlyFront = 0.5 --小游戏2初始化一个福红倍率飞行前等待时间
--小游戏2初始化一个福红倍率飞行时间
SlotsLionModel.time.miniGame2InitRateEFly = SlotsLionModel.time.effectMiniGame2RateInitFly + SlotsLionModel.time.effectMiniGame2RateInitTxtChange
SlotsLionModel.time.miniGame2InitRateEFlyBack = 0.2 --小游戏2初始化所有福红倍率飞行完等待时间

SlotsLionModel.time.miniGame2WaitScroll = 0.05 --小游戏2等待转动的时间
SlotsLionModel.time.miniGame2WaitLottery = 0.05 --小游戏2转动完成等待开奖的时间
SlotsLionModel.time.miniGame2SettlementItemWinConnect = 0.1 --小游戏2元素连线开奖后（如果有）弹出结算的时间
SlotsLionModel.time.miniGame2EffectItemWinConnect = 1.5 --小游戏2转动完成每次开奖的边框特效显示的时间

SlotsLionModel.time.miniGame3OpenAwardPoolFront = 2 --小游戏3开启奖池前等待时间
SlotsLionModel.time.miniGame3OpenAwardPool = 1 --小游戏3开启奖池前时间
SlotsLionModel.time.miniGame3LotteryEndFront = 0.1 --小游戏3结束前等待时间

SlotsLionModel.time.miniGame3ShowEffect = 1 --小游戏3显示特效的时间
SlotsLionModel.time.miniGame3RefreshItem = 2.5 --小游戏3创建蛋的时间
--小游戏3自动开奖的时间
SlotsLionModel.time.miniGame3AutoOpen = 30 + SlotsLionModel.time.miniGame3ShowEffect + SlotsLionModel.time.miniGame3RefreshItem
--小游戏3出一个小奖自动开奖的时间
SlotsLionModel.time.miniGame3AutoOpenMinGold = SlotsLionModel.time.miniGame3ShowEffect + SlotsLionModel.time.miniGame3RefreshItem

SlotsLionModel.time.openAwardPool = 1  --开启奖池用时

SlotsLionModel.time.moneyChangeLine = 2 --连线获得的钱改变的动画时长

SlotsLionModel.time.clearHide = 0.4  --结算完成后关闭等待时长
SlotsLionModel.time.clear5line = 1 --5连线效果时长
SlotsLionModel.time.clearNormalLv1 = 3 --普通结算等级1效果时长
SlotsLionModel.time.clearNormalLv2 = 3 --普通结算等级2效果时长
SlotsLionModel.time.clearNormalLv3 = 3 --普通结算等级3效果时长
SlotsLionModel.time.clearNormalLv4 = 4 --普通结算等级4效果时长
SlotsLionModel.time.clearNormalLv5 = 3 --普通结算等级5效果时长
--小游戏1普通结算一个元素动画的时长
SlotsLionModel.time.clearMiniGame1NormalItemAni = SlotsLionModel.time.effectMiniGame1RateLightBack + SlotsLionModel.time.effectMiniGame1RateFlyFront + SlotsLionModel.time.effectMiniGame1RateFly + 0.02
--小游戏1结算一个倍率飞行动画的时长
SlotsLionModel.time.clearMiniGame1RateAni = SlotsLionModel.time.effectMiniGame1RateClearFly + SlotsLionModel.time.effectMiniGame1RateClearTxtChange +0.1
SlotsLionModel.time.clearMiniGame1Normal = 1 --小游戏1普通结算动画结束后的时长

SlotsLionModel.time.clearMiniGame1BGChange = 0.2 --小游戏1总结算面板背景放大时长
SlotsLionModel.time.clearMiniGame1BonusChangeMax = 0.3 --小游戏1总结算面板Bonus放大时长
SlotsLionModel.time.clearMiniGame1BonusChangeMin = 0.2 --小游戏1总结算面板Bonus缩小时长
SlotsLionModel.time.clearMiniGame1XShow = 0.6 --小游戏1总结算面板X渐显时间
SlotsLionModel.time.clearMiniGame1PlayShow = 0.6 --小游戏1总结算面板Play渐显时间
SlotsLionModel.time.clearMiniGame1BonusPlayFlyFront = 1.2 --小游戏1总结算面板Bonus和Play飞行时间
SlotsLionModel.time.clearMiniGame1BonusPlayFly = 0.6 --小游戏1总结算面板Bonus和Play飞行时间
--小游戏1总结算时长
SlotsLionModel.time.clearMiniGame1 = SlotsLionModel.time.clearMiniGame1BonusPlayFlyFront + SlotsLionModel.time.clearMiniGame1BGChange + SlotsLionModel.time.clearMiniGame1BonusChangeMin + SlotsLionModel.time.clearMiniGame1XShow + SlotsLionModel.time.clearMiniGame1PlayShow + SlotsLionModel.time.clearMiniGame1BonusPlayFly


--小游戏2结算一个倍率飞行动画的时长
SlotsLionModel.time.clearMiniGame2RateAni = SlotsLionModel.time.effectMiniGame2RateClearFly + SlotsLionModel.time.effectMiniGame2RateClearTxtChange

SlotsLionModel.time.clearMiniGame2BGChange = 0.2 --小游戏2总结算面板背景放大时长
SlotsLionModel.time.clearMiniGame2BonusChangeMax = 0.3 --小游戏2总结算面板Bonus放大时长
SlotsLionModel.time.clearMiniGame2BonusChangeMin = 0.2 --小游戏2总结算面板Bonus缩小时长
SlotsLionModel.time.clearMiniGame2XShow = 0.6 --小游戏2总结算面板X渐显时间
SlotsLionModel.time.clearMiniGame2AddShow = 0.6 --小游戏2总结算面板+渐显时间
SlotsLionModel.time.clearMiniGame2PlayShow = 0.6 --小游戏2总结算面板Play渐显时间
SlotsLionModel.time.clearMiniGame2WinShow = 0.6 --小游戏2总结算面板Win渐显时间
SlotsLionModel.time.clearMiniGame2WinFly = 0.6 --小游戏2总结算面板Win飞行时间
SlotsLionModel.time.clearMiniGame2WinChange = 0.6 --小游戏2总结算面板Win飞行时间
SlotsLionModel.time.clearMiniGame2BonusPlayFlyFront = 1.2 --小游戏2总结算面板Bonus和Play飞行时间
SlotsLionModel.time.clearMiniGame2BonusPlayFly = 0.6 --小游戏2总结算面板Bonus和Play飞行时间
--小游戏2总结算时长
SlotsLionModel.time.clearMiniGame2 = SlotsLionModel.time.clearMiniGame2BGChange 
                        + SlotsLionModel.time.clearMiniGame2BonusChangeMin
                        + SlotsLionModel.time.clearMiniGame2XShow
                        + SlotsLionModel.time.clearMiniGame2AddShow
                        + SlotsLionModel.time.clearMiniGame2PlayShow
                        + SlotsLionModel.time.clearMiniGame2WinShow
                        + SlotsLionModel.time.clearMiniGame2WinFly
                        + SlotsLionModel.time.clearMiniGame2WinChange
                        + SlotsLionModel.time.clearMiniGame2BonusPlayFlyFront
                        + SlotsLionModel.time.clearMiniGame2BonusPlayFly

SlotsLionModel.time.clearMiniLast = 6 --结算等级3效果时长

SlotsLionModel.time.clearAwardPool1 = 6 --奖池1的效果时长
SlotsLionModel.time.clearAwardPool2 = 6 --奖池2的效果时长
SlotsLionModel.time.clearAwardPool3 = 6 --奖池3的效果时长

SlotsLionModel.time.clearAwardPool4 = 6 --奖池4的效果时长
SlotsLionModel.time.clearAwardPool4MoneyRoll = 4 --奖池4获得的钱滚动的效果时长

SlotsLionModel.time.showLineSpace = 0.4 
SlotsLionModel.time.showLineSpaceAuto = 0.25 

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
    game_lister["slot_wushi_all_info_response"] = M.slot_wushi_all_info_response
    game_lister["slot_wushi_enter_game_response"] = M.slot_wushi_enter_game_response
    game_lister["slot_wushi_quit_game_response"] = M.slot_wushi_quit_game_response
    game_lister["slot_wushi_kaijiang_response"] = M.slot_wushi_kaijiang_response
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
        bet = M.data and M.data.bet or SlotsLionLib.GetBetMaxByMoney(),
        GameStatus = M.GameStatus.idle,
        baseData = nil,
        awardPool = M.data and M.data.awardPool or awardPoolRate
    }

    m_data = M.data
end

function M.Init()
    this = M
    SlotsLionLib.Init(M.size,M.GetBetCfg(),M.GetPlayerMoney)
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
function M.slot_wushi_all_info_response(proto_name, data)
    dump(data, "<color=green>[SlotsLion] msg data proto_name = " .. proto_name .. "</color>")
    if data.result ~= 0 then
        Event.Brocast("model_slot_wushi_all_info",data)
        return
    end

    InitData()

    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetAutoNum(0)

    M.SetModelStatus(M.ModelStatus.gaming)
    M.data.baseData = SlotsLionLib.GetBaseData(data)
    M.SetAwardPool3ExtraMoney(M.data.baseData.awardPool3ExtraMoney)
    M.SetBet(basefunc.deepcopy(M.data.baseData.bet))

    dump(M.data, "<color=yellow>Model.data : </color>")

    Event.Brocast("model_slot_wushi_all_info",data)
end

--********************response
--进入游戏
function M.slot_wushi_enter_game_response(proto_name, data)
    dump(data, "<color=green>[SlotsLion] msg data proto_name = " .. proto_name .. "</color>")
    InitData()
    M.SetModelStatus(M.ModelStatus.waitBegin)
    Event.Brocast("model_slot_wushi_enter_game_response", data)
end

--退出游戏
function M.slot_wushi_quit_game_response(proto_name, data)
    dump(data, "<color=green>[SlotsLion] msg data proto_name = " .. proto_name .. "</color>")
    InitData()
    M.SetModelStatus(M.ModelStatus.gameover)
    Event.Brocast("model_slot_wushi_quit_game_response", data)
end

--开奖
function M.slot_wushi_kaijiang_response(proto_name, data)
    dump(data, "<color=green>[SlotsLion] msg data proto_name = " .. proto_name .. "</color>")
    if data.result == 0 then
        M.SaveAwardPoolCurMoney()
        InitData()
        M.data.baseData = SlotsLionLib.GetBaseData(data)
        M.SetAwardPool3ExtraMoney(M.data.baseData.awardPool3ExtraMoney)
        M.SetBet(basefunc.deepcopy(M.data.baseData.bet))

        dump(M.data, "<color=yellow>Model.data : </color>")
    else
        M.SetAutoNum(0)
        M.SetAuto(false)
        M.SetSkip(false)

        dump(M.data, "<color=yellow>Model.data : </color>")
    end

    Event.Brocast("model_slot_wushi_kaijiang_response",data)
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
        betMoneyOneLine = allBet.bet_money / 9
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

function M.SetAwardPool3ExtraMoney(v)
    if not v and type(v) ~= "number" then
        return
    end

    local t = {[3] = v}
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
local awardPoolExtraMoneyOld
local awardPoolExtraMoneyCur
function M.SaveAwardPoolCurMoney()
    awardPoolExtraMoneyCur = basefunc.deepcopy(M.data.awardPoolExtraMoney)
    awardPoolExtraMoneyOld = basefunc.deepcopy(M.data.awardPoolExtraMoney)
end

function M.GetAwardPoolCurMoney(i)
    if not awardPoolExtraMoneyCur or not awardPoolExtraMoneyCur[i] then
        return 0
    end
    return awardPoolExtraMoneyCur[i]
end

function M.SetAwardPoolCurMoney(i,m)
    awardPoolExtraMoneyCur[i] = m
end

function M.GetAwardPoolOldMoney(i)
    if not awardPoolExtraMoneyOld or not awardPoolExtraMoneyOld[i] then
        if not awardPoolExtraMoneyCur or not awardPoolExtraMoneyCur[i] then
            return 0
        end
        return awardPoolExtraMoneyCur[i]
    end
    return awardPoolExtraMoneyOld[i]
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
                Event.Brocast("model_slot_wushi_all_info",{result = -1})
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
    local pro = M.GetGameProcess()

    local data
    if not pro or not next(pro) or pro.game == "main" then
        data = M.data.baseData.mainData
    elseif pro.game == "mini1" then
        data = M.data.baseData.mini1Data
    end
    return data
end

--获取当前并行游戏进度数据
function M.SetGameProcessParallel(game,gameType,step)
    M.data.proecess = {
        game = game,
        gameType = gameType,
        step = step,
    }
end

function M.GetGameProcessParallel()
   return M.data.proecess
end

--获取当前并行游戏进度数据
function M.GetGameProcessCurDataParallel(game,gameType,step)
    if game == "mini2" then
        for i, v in ipairs(M.data.baseData.mini2Data) do
            if v.type == gameType and v.index == step then
                return v
            end
        end
    end
end

function M.GetGameProcessCurDataParallelListIndex(game,gameType,step)
    if game == "mini2" then
        for i, v in ipairs(M.data.baseData.mini2Data) do
            if v.type == gameType and v.index == step then
                return i
            end
        end
    end
end

function M.GetGameMini2ItemDataMap(i)
    if not m_data.baseData or not m_data.baseData.mini2Data then
        return
    end
    i = i or #m_data.baseData.mini2Data
    local d = m_data.baseData.mini2Data[i]
    local map = {}
    if d.items and next(d.items) then
        map[1] = d.items
    else
        map[1] = SlotsLionLib.BuildLocalGameMini2Items(d.item)
    end
    return map
end

function M.GetGameMini2Item(i)
    if not m_data.baseData or not m_data.baseData.mini2Data then
        return
    end
    i = i or #m_data.baseData.mini2Data
    local d = m_data.baseData.mini2Data[i]
    return d.item
end

function M.ChangeMainDataItemMap(x,y,id)
    m_data.baseData.mainData.itemDataMap[x][y] = id
end