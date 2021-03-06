local basefunc = require "Game.Common.basefunc"
SlotsLionHelper = {}
local M = SlotsLionHelper
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
    item1 = "xs_icon_j",
    item2 = "xs_icon_q",
    item3 = "xs_icon_k",
    item4 = "xs_icon_a",
    item5 = "xs_icon_1",
    item6 = "xs_icon_2",
    item7 = "xs_icon_3",
    item8 = "xs_icon_4",
    item9 = "xs_icon_6",
    itemA = "xs_icon_7",
    itemMini2_0 = "xs_icon_szma",
    itemMini2_1 = "xs_icon_szma",
    itemMini2_2 = "xs_icon_szmi",
    itemMini2_3 = "xs_icon_szra",
    itemMask1 = "xs_bg_szmi",
    itemMask2 = "xs_bg_szma",
    itemMask3 = "xs_bg_szra",
}
function M.GetTexture(name)
    return GetTexture(TextureEnum[name])
end

function M.GetTextureNameById(id,str)
    str = str or ""
    return GetTexture(TextureEnum["item" .. str .. id])
end

function M.Init()
    
end

function M.Exit()
    M.ExitDelay()
end

function M.Refresh()
    
end

function M.ExitTimer()
   M.ExitDelay()
end

--????????????
function M.LotteryStart()
    M.StartMain()
    M.StartMini2Scroll()
end

--????????????
function M.LotterySettlement(data)

    if data.game == "main" then
        SlotsLionClearPanel.Show({game = "main"})
        -- SlotsLionClearPanel.Show({game = "main"})
    elseif data.game == "mini1" then
        SlotsLionClearPanel.Show({game = "mini1"})
        -- SlotsLionClearPanel.Show({game = "mini1"})
    elseif data.game == "mini2" then
        SlotsLionClearPanel.Show({game = "mini2"})
        -- SlotsLionClearPanel.Show({game = "mini2"})
    end
end

--????????????
function M.LotteryComplete()
    --???????????????????????????
    if M.LotteryAuto() then
        SlotsLionModel.SetSpeed(2)
        return
    end
    SlotsLionModel.SetSpeed(1)
    SlotsLionGamePanel.Instance:MyRefresh()
    return true
end

--????????????
function M.LotteryStop()
    SlotsLionGamePanel.Instance:MyRefresh()
end

--????????????
function M.LotteryAuto()
    local auto = SlotsLionModel.GetAuto()
    if not auto then
        return
    end
    local autoNum = SlotsLionModel.GetAutoNum()
    SlotsLionGamePanel.Instance:MyRefresh()
    SlotsLionModel.SetAutoNum(autoNum - 1)
    local tAutoWait = SlotsLionModel.GetTime(SlotsLionModel.time.autoWait)
    local seq = M.GetSeq()
    seq:AppendInterval(tAutoWait)
    seq:AppendCallback(function ()
        SlotsLionGamePanel.Instance:RefreshMoneyTxtFix()
        SlotsLionGamePanel.Instance:Lottery()
    end)
    return true
end

--?????????????????????
function M.StartMain()
    SlotsLionModel.SetGameProcess("main",1)
    SlotsLionGameMainPanel.Instance:StartScroll()
end

--?????????????????????
function M.StopMainScroll()
    SlotsLionGameMainPanel.Instance:StopScroll()
end

--?????????????????????
function M.CompleteMain()
    if M.StartMiniParallel() then
        return
    end

    if M.StartMini() then
        return
    end

    M.LotteryComplete()
end

--?????????????????????
function M.StartMiniParallel()
    local pro = SlotsLionModel.GetGameProcess()
    if not pro or not next(pro) then
        return
    end

    local data = SlotsLionModel.GetGameProcessCurDataParallel("mini2",pro.game,pro.step)
    if not data or not next(data) then
        return
    end

    SlotsLionModel.SetSpeed(1)

    SlotsLionModel.SetGameProcessParallel("mini2",pro.game,pro.step)

    --??????????????????????????????
    M.ChooseMiniGameParallel({game = "mini2"})

    return true
end

--?????????2????????????
function M.StartMini2Scroll()
    SlotsLionGameMini2Panel.Instance:StartScroll()
end

--???????????????
function M.StopMini2Scroll(data)
    if data.game == "main" then
        local itemDataMap = SlotsLionModel.GetGameMini2ItemDataMap(1)
        local id = SlotsLionModel.GetGameMini2Item(1)
        SlotsLionGameMini2Panel.Instance:SkipScroll(itemDataMap,id)  
    elseif data.game == "mini1" then
        local pro = SlotsLionModel.GetGameProcess()
        if not pro then
            return
        end
        local itemDataMap = SlotsLionModel.GetGameMini2ItemDataMap(1 + pro.step)
        local id = SlotsLionModel.GetGameMini2Item(1 + pro.step)
        SlotsLionGameMini2Panel.Instance:SkipScroll(itemDataMap,id)
    end
end

--?????????????????????
function M.RefreshMiniParallel(data)
    if data.game == "mini2" then
        SlotsLionGameMini2Panel.Refresh(data)
    end
end

--?????????????????????
function M.NextMiniParallel(data)
    dump(data,"<color=yellow>Next Data</color>")
    --?????????????????????
    if data.game == "mini2" then
        SlotsLionGameMini2Panel.Next(data)
    end
end

--?????????????????????
function M.CompleteMiniGameParallel(data)
    if data.game == "mini2" then
        local pro = SlotsLionModel.GetGameProcess()
        if pro.game == "main" then 
            if M.StartMini() then
                return
            end
        elseif pro.game == "mini1" then
            if M.NextMini({game = "mini1"}) then
                return
            end
        end
    
        M.LotteryComplete() 
    end
end

--?????????????????????
function M.ChooseMiniGameParallel(data)
    local miniGame = data.game
    if miniGame == "mini2" then
        M.StartMini2()
    end
end

--?????????2??????
function M.StartMini2()
    SlotsLionGameMini2Panel.Start()
end

--?????????????????????
function M.StartMini()
    local pro = SlotsLionModel.GetGameProcess()
    if pro.game ~= "main" then
        return
    end
    SlotsLionModel.SetSpeed(1)

    --??????????????????????????????
    M.ChooseMiniGame({game = "mini1"})
    return true
end

--???????????????
function M.RefreshMini(data)
    if data.game == "mini1" then
        SlotsLionGameMini1Panel.Refresh(data)
    end
end

--???????????????
function M.NextMini(data)
    dump(data,"<color=yellow>NextMini Data</color>")
    --?????????????????????
    if data.game == "mini1" then
        local pro = SlotsLionModel.GetGameProcess()
        SlotsLionModel.SetGameProcess(pro.game,pro.step + 1)
        SlotsLionGameMini1Panel.Next(data)
    end
    return true
end

--?????????????????????
function M.ChooseMiniGame(data)
    local modelData = SlotsLionModel.data
    local miniGame = data.game
    if miniGame == "mini1" then
        M.StartMini1(modelData)
    end
end

--???????????????
function M.CompleteMiniGame(data)
    dump(data,"<color=green>???????????????</color>")
    if data.game == "mini1" then
        M.LotteryComplete()
    end
end

--?????????1??????
function M.StartMini1(data)
    SlotsLionModel.SetGameProcess("mini1",1)
    SlotsLionGameMini1Panel.Start(data)
end

local c = 0
--?????????????????????
function M.CompleteSettlement(data)
    dump(data,"<color=white>????????????????????????????????????????????????????????????????????????</color>")
    if data.game == "main" then
        M.CompleteMain()
    elseif data.game == "mini1" then
        if M.StartMiniParallel() then
            return
        end
        local pd = SlotsLionModel.GetGameProcess()
        M.RefreshMini(pd)
        M.NextMini(pd)
    elseif data.game == "mini2" then        
        local pp = SlotsLionModel.GetGameProcessParallel()
        local p = SlotsLionModel.GetGameProcess()
        local pd = SlotsLionModel.GetGameProcessCurDataParallel(data.game,p.game,p.step)
        M.RefreshMiniParallel(pd)

        if pp.gameType == p.game and pp.step == p.step then
            if p.game == "main" then
                M.NextMiniParallel(pd)
            elseif p.game == "mini1" then
                local pd = SlotsLionModel.GetGameProcess()
                M.RefreshMini(pd)
                M.NextMini(pd)
            end
        end
    end
end