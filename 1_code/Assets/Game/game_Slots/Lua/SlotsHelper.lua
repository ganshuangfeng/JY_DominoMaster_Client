local basefunc = require "Game.Common.basefunc"
SlotsHelper = {}
local M = SlotsHelper
local DoTweens = {}
function M.GetSeq()
    local seq = DoTweenSequence.Create()
    DoTweens[seq] = seq
    return seq
end

function M.KillSeq(seq)
    if not seq then
        return
    end
    DoTweens[seq] = nil
    seq:Kill()
    seq = nil
end

function M.Complete(seq)
    if not seq then
        return
    end
    DoTweens[seq] = nil
    if not seq:IsComplete() then
        seq:Complete()
    end
    seq = nil
end

function M.CheckSeq(seq)
    if not seq or not DoTweens[seq] then
        return false
    end
    return true
end

function M.AddTween(tween)
    DoTweens[tween] = tween
end

function M.SubTween(tween)
    if not M.CheckSeq(tween) then
        return
    end
    DoTweens[tween] = nil
end

local Timers = {}
function M.GetTimer(func, duration, loop, scale, fixdur)
    local timer = Timer.New(func, duration, loop, scale, fixdur)
    Timers[timer] = timer
    return timer
end

function M.StopTimer(timer)
    if not timer then
        return
    end
    Timers[timer] = nil
    timer:Stop()
    timer = nil
end

function M.ExitDelay()
    for k, v in pairs(DoTweens or {}) do
        v:Kill()
    end
    DoTweens = {}

    for k, v in pairs(Timers or {}) do
        v:Stop()
    end
    Timers = {}
end

local TextureEnum = {
    item1 = "fxgz_imgf_q",
    item2 = "fxgz_imgf_k",
    item3 = "fxgz_imgf_a",
    item4 = "fxgz_icon_04",
    item5 = "fxgz_icon_02",
    item6 = "fxgz_icon_05",
    item7 = "fxgz_icon_013",
    item8 = "fxgz_icon_011",
    item9 = "fxgz_icon_09",
    itemA = "fxgz_icon_01",
    itemB = "fxgz_icon_012",
    itemC = "fxgz_icon_010",
    itemD = "fxgz_icon_03",
    itemE = "fxgz_icon_06",
    itemF = "fxgz_icon_07",
    itemG = "fxgz_icon_08",
    itemH = "fxgz_icon_spin",
    itemEgg1 = "fxgz_icon_mini",
    itemEgg2 = "fxgz_icon_minor",
    itemEgg3 = "fxgz_icon_major",
    itemEgg4 = "fxgz_icon_geand",
}
function M.GetTexture(name)
    return GetTexture(TextureEnum[name])
end

function M.Init()
    
end

function M.Exit()
    M.ExitDelay()
    M.ExitTimer()
end

function M.Refresh()
    
end

function M.ExitTimer()
   M.ExitDelay()
end

--开始开奖
function M.LotteryStart()
    M.MainStart()
end

--开奖完成
function M.LotteryComplete()
    --开奖结算后自动开奖
    if M.LotteryAuto() then
        SlotsModel.SetSpeed(2)
        return
    end
    SlotsModel.SetSpeed(1)
    SlotsGamePanel.Instance:MyRefresh()
    return true
end

--跳过开奖
function M.LotteryStop()
    SlotsGamePanel.Instance:MyRefresh()
    SlotsEffect.PlayItemDGold()
end

--自动开奖
function M.LotteryAuto()
    local auto = SlotsModel.GetAuto()
    if not auto then
        return
    end
    SlotsModel.SetAutoNum(SlotsModel.GetAutoNum() - 1)
    local tAutoWait = SlotsModel.GetTime(SlotsModel.time.autoWait)
    local seq = M.GetSeq()
    seq:AppendInterval(tAutoWait)
    seq:AppendCallback(function ()
        SlotsGamePanel.Instance:RefreshMoneyTxtFix()
        SlotsGamePanel.Instance:Lottery()
    end)
    return true
end

--主游戏开始开奖
function M.MainStart()
    local data = SlotsModel.data
    SlotsModel.SetGameProcess("main",1)

    local itemObjMap,itemDataMap,rateMap,itemRate,parent = SlotsDeskPanel.Instance:GetItemMap(), basefunc.deepcopy(data.baseData.mainData.itemDataMap),data.baseData.mainData.rateMapItemE,data.baseData.mainData.itemRate,SlotsDeskPanel.Instance.item_content

    local times = {
        scrollSpeedUpInterval = SlotsModel.time.scrollSpeedUpInterval,
        scrollSpeedUpTime = SlotsModel.time.scrollSpeedUpTime,
        scrollSpeedUniformAllTime = SlotsModel.time.scrollSpeedUniformAllTime,
        scrollSpeedUniformOneTime = SlotsModel.time.scrollSpeedUniformOneTime,
        scrollSpeedDownInterval = SlotsModel.time.scrollSpeedDownInterval,
        scrollSpeedDownTime = SlotsModel.time.scrollSpeedDownTime,
        scrollSpeedUniformAddTime = SlotsModel.time.scrollSpeedUniformAddTime,
    }

    local function getScrollItemTime()
        local t = 0
        t = times.scrollSpeedUpTime + times.scrollSpeedUniformAllTime
        return t
    end

    local function callback()
        local seq = M.GetSeq()
        --开奖
        if itemRate and next(itemRate) then
            --有中奖
            local t = SlotsModel.GetTime(SlotsModel.time.effectItemWinConnect)
            local t5Line = SlotsClearPanel.Instance:Play5Line(SlotsHelper.GetSeq())
            local tNormal = SlotsClearPanel.Instance:PlayNormalNot5Line(SlotsHelper.GetSeq())
            local isNormalLV = SlotsClearPanel.Instance:CheckNormalLv()
            seq:AppendCallback(function ()
                local itemWimMap = SlotsLib.GetItemWinConnect(itemDataMap,itemRate)
                SlotsEffect.PlayItemWinConnect(itemWimMap,t,itemObjMap,t5Line)
                Event.Brocast("ItemWinConnect",{itemRate = itemRate,t5Line = t5Line,isNormalLV = isNormalLV})
            end)
            if t5Line and t5Line > t then
                seq:AppendInterval(t5Line)
            elseif tNormal and tNormal > t then
                seq:AppendInterval(tNormal)
            else
                seq:AppendInterval(t)
            end
            local t = SlotsModel.GetTime(SlotsModel.time.settlementItemWinConnect)
            seq:AppendInterval(t)
        end

        seq:AppendCallback(function ()
            M.LotterySettlement()
        end)
    end


    local seq = M.GetSeq()
    --开始转动
    seq:AppendCallback(function ()
        SlotsAnimation.StartScroll(itemObjMap,"main",times,parent)
    end)
    local t = SlotsModel.GetTime(getScrollItemTime())
    seq:AppendInterval(t)
    --停止转动
    seq:AppendCallback(function ()
        SlotsAnimation.StopScroll(itemDataMap,rateMap,"main",callback,times)
    end)
    M.mainScrollSeq = seq
end

--主游戏跳过转动
function M.MainScrollItemMapStop()
    local gameData = SlotsModel.GetGameProcessCurData()
    if gameData.game ~= "main" then
        return
    end

    if M.mainScrollSeq then
        if M.mainScrollSeq:IsComplete() then
            return
        else
            M.mainScrollSeq:Kill()
        end
        -- local duration = M.mainScrollSeq:Duration()
        -- local elapsed = M.mainScrollSeq:Elapsed()
        -- local Delay = M.mainScrollSeq:Delay()
        -- dump(duration,"<color=yellow>duration ???????</color>")
        -- dump(elapsed,"<color=yellow>elapsed ???????</color>")
        -- dump(Delay,"<color=yellow>Delay ???????</color>")


        -- M.mainScrollSeq:Complete(true)
    end
    M.mainScrollSeq = nil

    local data = SlotsModel.data
    local itemObjMap,itemDataMap,rateMap,itemRate,parent = SlotsDeskPanel.Instance:GetItemMap(), basefunc.deepcopy(data.baseData.mainData.itemDataMap),data.baseData.mainData.rateMapItemE,data.baseData.mainData.itemRate,SlotsDeskPanel.Instance.item_content

    local function callback()
        local seq = M.GetSeq()
        --开奖
        if itemRate and next(itemRate) then
            --有中奖
            local t = SlotsModel.GetTime(SlotsModel.time.effectItemWinConnect)
            local t5Line = SlotsClearPanel.Instance:Play5Line(SlotsHelper.GetSeq())
            local tNormal = SlotsClearPanel.Instance:PlayNormalNot5Line(SlotsHelper.GetSeq())
            local isNormalLV = SlotsClearPanel.Instance:CheckNormalLv()
            seq:AppendCallback(function ()
                local itemWimMap = SlotsLib.GetItemWinConnect(itemDataMap,itemRate)
                SlotsEffect.PlayItemWinConnect(itemWimMap,t,itemObjMap,t5Line)
                Event.Brocast("ItemWinConnect",{itemRate = itemRate,t5Line = t5Line,isNormalLV = isNormalLV})
            end)
            if t5Line and t5Line > t then
                seq:AppendInterval(t5Line)
            elseif tNormal and tNormal > t then
                seq:AppendInterval(tNormal)
            else
                seq:AppendInterval(t)
            end
            local t = SlotsModel.GetTime(SlotsModel.time.settlementItemWinConnect)
            seq:AppendInterval(t)
        end

        seq:AppendCallback(function ()
            M.LotterySettlement()
        end)
    end

    SlotsAnimation.SkipScroll(itemDataMap,rateMap,"main",callback)
end

--主游戏完成开奖
function M.MainComplete()
    if M.MiniStart() then
        return
    end

    M.LotteryComplete()
end

--小游戏开始开奖
function M.MiniStart()
    local pro = SlotsModel.GetGameProcess()
    if pro.game ~= "main" then
        return
    end
    SlotsModel.SetSpeed(1)

    local data = SlotsModel.data
    --mini 1,2,3 只会出现一个，不会同时出现
    if data.baseData.mini1Data
    or data.baseData.mini2Data
    then
        SlotsMiniGameChoosePanel.Create()
        return true
    elseif data.baseData.mini3Data then
        M.ChooseMiniGame({game = 3})
        return true
    end
end

function M.RefreshMini(data)
     --继续下一轮开奖
     if data.game == "mini1" then
        SlotsMiniGame1Panel.Refresh(data)
    elseif data.game == "mini2" then
        SlotsMiniGame2Panel.Refresh(data)
    elseif data.game == "mini3" then
        SlotsMiniGame3Panel.Refresh(data)
    end
end

--继续小游戏
function M.MiniNext(data)
    dump(data,"<color=yellow>MiniNext Data</color>")
    local pro = SlotsModel.GetGameProcess()
    SlotsModel.SetGameProcess(pro.game,pro.step + 1)
    --继续下一轮开奖
    if data.game == "mini1" then
        SlotsMiniGame1Panel.MiniNext(data)
    elseif data.game == "mini2" then
        SlotsMiniGame2Panel.MiniNext(data)
    elseif data.game == "mini3" then
        SlotsMiniGame3Panel.MiniNext(data)
    end
end

--开始小游戏开奖
function M.ChooseMiniGame(data)
    local modelData = SlotsModel.data
    local miniGame = data.game
    if miniGame == 1 then
        M.Mini1Start(modelData)
    elseif miniGame == 2 then
        M.Mini2Start(modelData)
    elseif miniGame == 3 then
        M.Mini3Start(modelData)
    end
end

--完成小游戏
function M.CompleteMiniGame()
    M.LotteryComplete()
end

--小游戏1开始
function M.Mini1Start(data)
    SlotsModel.SetGameProcess("mini1",1)
    SlotsMiniGame1Panel.Create(data)
end

--小游戏2开始
function M.Mini2Start(data)
    SlotsModel.SetGameProcess("mini2",1)
    SlotsMiniGame2Panel.Create(data)
end

--小游戏3开始
function M.Mini3Start(data)
    SlotsModel.SetGameProcess("mini3",1)
    SlotsMiniGame3Panel.Create(data)
end

--完成了各种结算
function M.CompleteSettlement()
    local data = SlotsModel.GetGameProcess()
    if data.game == "main" then
        M.MainComplete()
    else
        M.RefreshMini(data)
        M.MiniNext(data)
    end
end

--结算
function M.LotterySettlement()
    SlotsClearPanel.Show()
end

--奖池
function M.LotteryAwardPool()
    local pro = SlotsModel.GetGameProcess()
    -- SlotsAwardPoolPanel.Show({game = pro.game,step = pro.step,data = SlotsModel.data.baseData})
end

--完成了各种奖池
function M.CompleteAwardPool(data)
    if data.game == "main" then
        M.MainComplete()
    else
        M.MiniNext(data)
    end
end