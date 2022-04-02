local basefunc = require "Game/Common/basefunc"

EliminateBSInfoPanel = basefunc.class()
local M = EliminateBSInfoPanel
M.name = "EliminateBSInfoPanel"
local instance_Info
function M.Create()
    instance_Info = M.New()
    return instance_Info
end

function M:MakeLister()
    self.lister = {}
    self.lister["view_lottery_award"] = basefunc.handler(self, self.view_lottery_award)
    self.lister["eliminate_refresh_yazhu"] = basefunc.handler(self, self.eliminate_refresh_yazhu)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.FreshList)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
	self.lister["view_bshj_lottery_end"] = basefunc.handler(self, self.view_bshj_lottery_end)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

--开奖错误
function M:view_lottery_error()
    --if EliminateBSModel.data.state ~= EliminateBSModel.xc_state.nor then return end
    self:FreshList()
end

--一个一个消灭
function M:view_lottery_award(data)
    if (EliminateBSModel.data.state == EliminateBSModel.xc_state.nor)
    or (EliminateBSModel.data.state == EliminateBSModel.xc_state.null)
    or (EliminateBSModel.data.state == EliminateBSModel.xc_state.bshj) then
     --dump(data,"<color>单次消除的信息</color>")
        if data then
            if data.isBshj then
                self.isBshj = true
            else
                self.isBshj = false
            end

        	self.AllInfoList[#self.AllInfoList + 1] = data
        	--对于当前的游戏规则来说，没有单独对每种元素进行押注。因此所有元素的押注都是一样的
            local rate = 1
            self:AddGold(self.BetList[1] * data.cur_rate * rate)
            data.cur_del_list = data.cur_del_map
            if table_is_null(data.cur_del_list) then return  end 
            local data2 = self:SoringData(data.cur_del_list)
            for k, v in pairs(data2) do
                self:DesPrefabInto(k, v, self.isBshj, false)
            end
        end
    end 
end

--把信息整理成 （类型：个数）的形式
function M:SoringData(cur_del_list)
    local data = {}
    for k, v in pairs(cur_del_list) do
        for m, n in pairs(v) do
            if data[n] then
                data[n] = data[n] + 1
            else
                data[n] = 1
            end
        end
    end
    return data
end

--断线重连获取数据 或者 结束的时候 重新刷新一次数据
function M:view_lottery_end(data)
    self.isBshj = false
    self:MyRefresh(data)
end

function M:DesPrefabInto(id, num, isBsmj, IsReConnect)
    local num = "x" .. num
    EliminateBSDesPrefab.Create(id, num, isBsmj, IsReConnect, self.Content)
end

function M:AddGold(S)
    if self.gold + S > EliminateBSModel.GetAwardMoney() then
        return
    end
    self.gold = self.gold + S
    -- if  self.gold>=EliminateBSModel.GetAwardMoney() then
    -- 	self.gold=EliminateBSModel.GetAwardMoney()
    -- end
    self.goldtext.text = StringHelper.ToCash(self.gold)
end

--重置各种记录数据
function M:FreshList()
    --if EliminateBSModel.data.state ~= EliminateBSModel.xc_state.nor then return end
    self.gold = 0
    self.goldtext.text = 0
    self.AllInfoList = {}
    destroyChildren(self.Content)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    self:RemoveListenerGameObject()
    if self.WS_Timer then
        self.WS_Timer:Stop()
    end
    self.WS_Timer = nil
    destroy(self.gameObject)
    instance_Info=nil
end


function M:ctor()

	ExtPanel.ExtMsg(self)

    self.profablist = {}
    self.gold = 0
    self.BetList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0
    }
    self.parent = GameObject.Find("Canvas1080/LayerLv1").transform
    self.gameObject = newObject(M.name, self.parent)
    self.gold = 0
    self.AllInfoList = {}
    self.goldtext = self.gameObject.transform:Find("bgs/GoldInfo/GoldText"):GetComponent("Text")
    self.goldtext.text = 0
    self.Content = self.gameObject.transform:Find("bgs/Viewport/TaskNode")
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:AddListenerGameObject()
end

function M:AddListenerGameObject()
    self.gameObject.transform:Find("bgs/Help"):GetComponent("Button").onClick:AddListener(
        function()
            EliminateBSHelpPanel.Create()
        end
    )
end

function M:RemoveListenerGameObject()
    self.transform:Find("bgs/Help"):GetComponent("Button").onClick:RemoveAllListeners()

end

function M:InitUI()
    
end

function M:eliminate_refresh_yazhu(data)
    self.BetList[data[1]] = data[2]
    EliminateBSModel.SetBet(self.BetList)
end

function M:MyRefresh(data)
    dump(self.gold, "由每次累计算出的鲸币")
    local sum = 0
    if not table_is_null(self.AllInfoList) then
        for i = 1, #self.AllInfoList do
            sum = sum + self.AllInfoList[i].cur_rate
        end
    end
    dump(sum, "<color=red>由每次累计算出的倍率</color>")

    self:FreshList()
    dump(data, "<color=red>结算数据</color>")
    for i = 1, #data.all_del_list do
        local data2 = self:SoringData(data.all_del_list[i])
        for k, v in pairs(data2) do
            if k < 200 and v > 3 then

            else
                local _id = k
                if k >= 220 then
                    local temp_num_1 = tostring(k)
                    local temp_num_2 = string.sub(temp_num_1,1,3)
                    _id = tonumber(temp_num_2)
                end
                self:DesPrefabInto(_id, v, self.isBshj, true)
            end
        end
    end
    self:AddGold(data.all_money)
end

function M:view_bshj_lottery_end(data)
    if data.add_money > 0 then
        self:AddGold(data.add_money)
    end
end
