-- 创建时间:2018-07-23

GuideModel = {}

local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["task_change_msg"] = this.on_task_change_msg
    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["ExitScene"] = this.on_ExitScene
    lister["AssetChange"] = this.AssetChange

end
GuideModel.guide_ver_time = 1647913958
-- 初始化Data
local function InitMatchData()
    GuideModel.data={}
    m_data = GuideModel.data
end

function GuideModel.Init()
    if not GameGlobalOnOff.IsOpenGuide then
        return
    end
    this = GuideModel
    InitMatchData()
    MakeLister()
    AddLister()

    m_data.currGuideId = this.GetRunGuideID()
    m_data.currGuideStep = 1
    this.is_guide_ing = false

    if tonumber(MainModel.UserInfo.first_login_time) < GuideModel.guide_ver_time then
        if m_data.currGuideId == 1 then
            m_data.currGuideId = m_data.currGuideId + 1
        elseif m_data.currGuideId == 2 then
            GuideModel.GuideSavePos(m_data.currGuideId)
            m_data.currGuideId = m_data.currGuideId + 1
        end
    end

    return this
end
function GuideModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

-- 第一个引导的ID
local OneGuideId = 1
function GuideModel.GetRunGuideID()
    if MainModel.UserInfo.xsyd_status >= 0 then
        return (MainModel.UserInfo.xsyd_status + 1)
    else
        return -1
    end
end

function GuideModel.GetCurStepConfig()
    local cfg = GuideConfig[GuideModel.data.currGuideId]
    if cfg then
        local index = cfg.stepList[GuideModel.trigger_pos].step[GuideModel.data.currGuideStep]
        return GuideNorStepConfig[index]
    end
end

function GuideModel.GetCurStepList()
    local cfg = GuideConfig[GuideModel.data.currGuideId]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        return cfg.stepList[GuideModel.trigger_pos].step
    end
    return {}
end
-- 引导保存点
function GuideModel.GuideSavePos(id)
    dump(m_data, "<color=white><size=20>[Debug] AAAA GuideSavePos</size></color>")
    if GuideConfig[id] and GuideConfig[id].next > 0 then
        Network.SendRequest("set_xsyd_status", {status = id, xsyd_type="xsyd"})
    else
        Network.SendRequest("set_xsyd_status", {status = -1, xsyd_type="xsyd"})
    end
end
-- 引导完成或点击跳过
function GuideModel.GuideFinishOrSkip()
    GuideModel.is_guide_ing = false
    m_data.currGuideId = GuideConfig[m_data.currGuideId].next
    if m_data.currGuideId == -1 then
        MainModel.UserInfo.xsyd_status = -1
        Event.Brocast("newplayer_guide_finish")
    end
    m_data.currGuideStep = 1
end

function GuideModel.StepFinish()
    local cfg = GuideModel.GetCurStepConfig()
    GuideLogic.Print(cfg)
    if cfg and cfg.isSave then
        GuideModel.GuideSavePos(m_data.currGuideId)
    end
    m_data.currGuideStep = m_data.currGuideStep + 1
    local stepList = GuideModel.GetCurStepList()
    if m_data.currGuideId > 0 and GuideConfig[m_data.currGuideId] and m_data.currGuideStep > #stepList then
        GuideModel.GuideFinishOrSkip()
    end
end

function GuideModel.Trigger(id, cfPos)
    if GuideConfig[id] then
        for k,v in ipairs(GuideConfig[id].stepList) do
            if v.cfPos == cfPos then
                GuideModel.trigger_pos = k
                GuideModel.data.currGuideStep = 1
                return true
            end
        end
    end
end
-- 条件是否满足
function GuideModel.CheckCondition(id)
    -- 登录到大厅提示在某某游戏中，屏蔽引导
    if MainModel.myLocation == "game_Hall" and MainModel.Location then
        return false
    end

    if id == 1 then
        if tonumber(MainModel.UserInfo.first_login_time) > GuideModel.guide_ver_time then
            return true
        end
        return false
    end
    if id == 2 then
        if SysLevelManager and SysLevelManager.GetLevel() >= 3 then
            return true
        end
        return false
    end

    return true
end
-- 条件是否满足
function GuideModel.IsMeetCondition()
    return GuideModel.CheckCondition(m_data.currGuideId)
end

function GuideModel.GetGuide3Condition()
    
end

function GuideModel.on_task_change_msg(_,data)
end

function GuideModel.on_get_task_award_response(_,data)
end

function GuideModel.on_ExitScene()
end

function GuideModel.AssetChange(data)
end
