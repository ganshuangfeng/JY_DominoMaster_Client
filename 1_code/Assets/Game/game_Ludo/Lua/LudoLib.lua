-- 创建时间:2021-11-08
local basefunc = require "Game/Common/basefunc"
LudoLib = {}

function LudoLib.transform_seat(seatNum,s2cSeatNum,mySeatNum, maxP)
    maxP = maxP or 4
    if mySeatNum then
        if maxP == 4 then
            seatNum[1]=mySeatNum
            s2cSeatNum[mySeatNum]=1
            for i=2,maxP do
                mySeatNum=mySeatNum+1
                if mySeatNum>maxP then
                    mySeatNum=1
                end
                seatNum[i]=mySeatNum
                s2cSeatNum[mySeatNum]=i
            end
        elseif maxP == 2 then
            seatNum[1]=mySeatNum
            s2cSeatNum[mySeatNum]=1
            mySeatNum=mySeatNum+1
            if mySeatNum>maxP then
                mySeatNum=1
            end
            seatNum[3]=mySeatNum
            s2cSeatNum[mySeatNum]=3
        end
    end
end

function LudoLib.InitPiecesUIPos()
    --初始化UI位置的列表
    if not LudoLib.PiecesPosIndex then
        LudoLib.PiecesPosIndex = {
            [1] = {
                {1,0},{1,2},{1,3},{1,4},{1,5},{1,6},{2,18},{2,17},{2,16},{2,15},{2,14},{2,13},
                {2,12},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{3,18},{3,17},{3,16},{3,15},
                {3,14},{3,13},{3,12},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{4,18},{4,17},{4,16},
                {4,15},{4,14},{4,13},{4,12},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{1,18},
                {1,17},{1,16},{1,15},{1,14},{1,13},{1,12},{1,11},{1,10},{1,9},{1,8},{1,7},{1,19},
            },
            [2] = {
                {2,0},{2,2},{2,3},{2,4},{2,5},{2,6},{3,18},{3,17},{3,16},{3,15},{3,14},{3,13},
                {3,12},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{4,18},{4,17},{4,16},{4,15},
                {4,14},{4,13},{4,12},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{1,18},{1,17},{1,16},
                {1,15},{1,14},{1,13},{1,12},{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{2,18},
                {2,17},{2,16},{2,15},{2,14},{2,13},{2,12},{2,11},{2,10},{2,9},{2,8},{2,7},{2,19},
            },
            [3] = {
                {3,0},{3,2},{3,3},{3,4},{3,5},{3,6},{4,18},{4,17},{4,16},{4,15},{4,14},{4,13},
                {4,12},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{1,18},{1,17},{1,16},{1,15},
                {1,14},{1,13},{1,12},{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{2,18},{2,17},{2,16},
                {2,15},{2,14},{2,13},{2,12},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{3,18},
                {3,17},{3,16},{3,15},{3,14},{3,13},{3,12},{3,11},{3,10},{3,9},{3,8},{3,7},{3,19},
            },
            [4] = {
                {4,0},{4,2},{4,3},{4,4},{4,5},{4,6},{1,18},{1,17},{1,16},{1,15},{1,14},{1,13},
                {1,12},{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{2,18},{2,17},{2,16},{2,15},
                {2,14},{2,13},{2,12},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{3,18},{3,17},{3,16},
                {3,15},{3,14},{3,13},{3,12},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{4,18},
                {4,17},{4,16},{4,15},{4,14},{4,13},{4,12},{4,11},{4,10},{4,9},{4,8},{4,7},{4,19},
            }
        }
    end
end

LudoLib.InitPiecesUIPos()

--输出这个枚旗子所处的位置
function LudoLib.GetPiecePos(CSeatNum,place)
    return LudoLib.GetPiecePosByIndex(LudoLib.GetPiecePosIndex(CSeatNum,place))
end

--输出这个枚旗子所处的UI位置
function LudoLib.GetPieceUIPos(CSeatNum,place)
    return LudoLib.GetPieceUIPosByIndex(LudoLib.GetPiecePosIndex(CSeatNum,place))
end

--输出这个枚旗子的小的位置
function LudoLib.GetPieceMiniPos(CSeatNum,place,no)
    return LudoLib.GetPieceMiniPosByIndexNo(LudoLib.GetPiecePosIndex(CSeatNum,place),no)
end

--根据座位号和当前位置获取UI位置的索引
function LudoLib.GetPiecePosIndex(CSeatNum,place)
    return LudoLib.PiecesPosIndex[CSeatNum][place + 1]
end

function LudoLib.InitSafetyPos()
    if not LudoLib.SafetyPos then
        LudoLib.SafetyPos = {
            {1,2},{1,15},{2,2},{2,15},{3,2},{3,15},{4,2},{4,15}
        }
    end
end
-- 检查是不是安全点
function LudoLib.CheckIsSafe(CSeatNum,place)
    local index = LudoLib.GetPiecePosIndex(CSeatNum,place)
    for i = 1,#LudoLib.SafetyPos do
        if LudoLib.SafetyPos[i][1] == index[1] and LudoLib.SafetyPos[i][2] == index[2] then
            return true
        end
    end
    return false
end

LudoLib.InitSafetyPos()

function LudoLib.GetSafetyPosIndex()
    return LudoLib.SafetyPos
end

--index:{1,2}
function LudoLib.GetPiecePosByIndex(index)
    -- dump(index,"<color=yellow>GetPiecePosByIndex</color>")
    for i = 1, #index do
        index[i] = tonumber(index[i])
    end
    return LudoLib.Pos3D[index[1]][index[2]]
end

function LudoLib.GetPieceUIPosByIndex(index)
    -- dump(index,"<color=yellow>GetPiecePosByIndex</color>")
    for i = 1, #index do
        index[i] = tonumber(index[i])
    end
    return LudoLib.Pos2D[index[1]][index[2]]
end

--index:{1,2} no:1~4
function LudoLib.GetPieceMiniPosByIndexNo(index,no)
    -- dump({index = index,no = no},"<color=yellow>GetPieceMiniPosByIndex</color>")
    for i = 1, #index do
        index[i] = tonumber(index[i])
    end
    return LudoLib.PosMini3D[index[1]][index[2]][no]
end

-- key:"1_2"
function LudoLib.GetDeskPosByKey(key)
    local index = StringHelper.Split(key,"_")
    for i = 1, #index do
        index[i] = tonumber(index[i])
    end
    return LudoLib.GetPiecePosByIndex(index)
end

-- key:"1_2"
function LudoLib.GetPlaceByKey(key,CSeatNum)
    local index = StringHelper.Split(key,"_")
    for i = 1, #index do
        index[i] = tonumber(index[i])
    end

    for i, v in ipairs(LudoLib.PiecesPosIndex[CSeatNum]) do
        if v[1] == index[1] and v[2] == index[2] then
            return i - 1
        end
    end
end

--获取棋子在棋牌上的位置状态 start：起点，run：普通走，sprint：冲刺，end：终点
function LudoLib.GetPiecePosState(CSeatNum,place)
    local allPlace = #LudoLib.PiecesPosIndex[CSeatNum]
    place = place + 1
    if place == 1 then
        return "start"
    elseif place >= 2 and place <= 52 then
        return "run"
    elseif place >= 53 and place < allPlace then
        return "sprint"
    elseif place == allPlace then
        return "end"
    end
end

function LudoLib.GetPieceSprintNum(CSeatNum,place)
    if LudoLib.GetPiecePosState(CSeatNum,place) ~= "sprint" then
        return 0
    end
    place = place + 1
    return #LudoLib.PiecesPosIndex[CSeatNum] - place
end

function LudoLib.GetPiecePosStateByKey(key)
    local pos = StringHelper.Split(key,"_")
    local pos2 = tonumber(pos[2])
    if pos2 == 0 then
        --起点位置
        return "start"
    elseif pos2 == 19 then
        --终点位置
        return "end"
    elseif pos2 >= 7 and pos2 <= 11 then
        return "sprint"
    else
        --普通位置
        return "run"
    end
end

--获取棋子的大小和位置 CSeatNum：客户端座位号，place：在棋盘上的位置，id：棋子id，playerCount：格子上的玩家个数，playerIndex：格子上的玩家索引，pieceIndex：格子上玩家的棋子索引
function LudoLib.GetPiecePosAndScale(CSeatNum,place,id,playerCount,playerIndex,pieceIndex)
    local posState = LudoLib.GetPiecePosState(CSeatNum,place)
    local pos = LudoLib.GetPiecePos(CSeatNum,place)

    local data = {}
    --格子上的玩家个数
    if playerCount == 1 then
        if posState == "start" then
            --起点
            data.scale = 1
            pos = LudoLib.GetPieceMiniPos(CSeatNum,place,id)
            data.pos = pos
        elseif posState == "end" then
            --终点
            data.scale = 0.6
            pos = LudoLib.GetPieceMiniPos(CSeatNum,place,pieceIndex)
            data.pos = pos
        elseif posState == "run" or posState == "sprint" then
            data.scale = 1
            data.pos = pos
        end
    elseif playerCount == 2 then
        --2个及以上玩家只能在普通位置重叠
        data.scale = 0.8
        pos = LudoLib.GetPieceMiniPos(CSeatNum,place,playerIndex)
        data.pos = pos
    elseif playerCount == 3 then
        data.scale = 0.65
        pos = LudoLib.GetPieceMiniPos(CSeatNum,place,playerIndex)
        data.pos = pos
    elseif playerCount == 4 then
        data.scale = 0.65
        pos = LudoLib.GetPieceMiniPos(CSeatNum,place,playerIndex)
        data.pos = pos
    end

    return data
end

--获取棋子的大小和位置 key = "1_0"：棋盘上的位置节点的编号，playerCount：格子上的玩家个数，playerIndex：格子上的玩家索引
function LudoLib.GetPieceRunSprintPosAndScale(key,playerCount,playerIndex)
    -- local pos = LudoLib.GetDeskPosByKey(key)
    local offsetPos

    local index = StringHelper.Split(key,"_")
    local pos = LudoLib.GetPieceMiniPosByIndexNo(index,playerIndex)

    local data = {}
    data.pos = pos
    --格子上的玩家个数
    if playerCount == 1 then
        data.scale = 1
        -- data.pos = pos
    elseif playerCount == 2 then
        --2个及以上玩家只能在普通位置重叠
        data.scale = 0.8
    elseif playerCount == 3 then
        data.scale = 0.65
    elseif playerCount == 4 then
        data.scale = 0.65
    end

    return data
end

--获取棋子的选择状态 true or false，CSeatNum：客户端座位号，place：在棋盘上的位置，point：摇的点数，startCount：开始位置的棋子数，runCount：行走位置的棋子数，canSprintCount：可以冲刺的棋子数
function LudoLib.GetPieceChooseState(CSeatNum,place,point,startCount, runCount, canSprintCount)
    local posState = LudoLib.GetPiecePosState(CSeatNum,place)
    local sprintNum = LudoLib.GetPieceSprintNum(CSeatNum,place)
    local b
    if posState == "end" then
        --棋子进入终点
        b = false
    elseif posState == "sprint" then
        --棋子进入冲刺段
        if point > sprintNum then
            --点数超过冲刺距离
            b = false
        else
            if point == 6 then
                if startCount + runCount + canSprintCount > 1 then
                    b = true
                else
                    b = false
                end
            else
                if runCount + canSprintCount > 1 then
                    b = true
                else
                    b = false
                end
            end
        end
    elseif posState == "start" then
        if point ~= 6 then
            --点数不是6
            b = false
        else
            if startCount + runCount + canSprintCount > 1 then
                b = true
            else
                b = false
            end
        end
    elseif posState == "run" then
        if point == 6 then
            if startCount + runCount + canSprintCount > 1 then
                b = true
            else
                b = false
            end
        else
            if runCount + canSprintCount > 1 then
                b = true
            else
                b = false
            end
        end
    end
    return b
end

-- 摄像机 用于坐标转化
function LudoLib.SetCamera()
    LudoLib.camera2d = GameObject.Find("LudoCanvasBG/CameraBG"):GetComponent("Camera")
    LudoLib.camera3d = GameObject.Find("Ludo3DNode/Camera3D"):GetComponent("Camera")
end
-- 2D坐标转3D坐标
function LudoLib.Get2DTo3DPoint(vec)
    vec = LudoLib.camera2d:WorldToScreenPoint(vec)
    vec = LudoLib.camera3d:ScreenToWorldPoint(vec)
    vec.y = vec.y - vec.z
    vec.z = 0
    return vec
end
-- 3D坐标转2D坐标
function LudoLib.Get3DTo2DPoint(vec)
    vec = LudoLib.camera3d:WorldToScreenPoint(vec)
    vec = LudoLib.camera2d:ScreenToWorldPoint(vec)
    return vec
end

--屏幕坐标转UI坐标
function LudoLib.ScreenToWorldPoint(pos)
    local _pos = LudoLib.camera2d:ScreenToWorldPoint(pos)
    return _pos
end

LudoLib.scale2Dto3D = 100
function LudoLib.Get3DTo2DScale(scale)
    scale.x = scale.x * LudoLib.scale2Dto3D
    scale.y = scale.y * LudoLib.scale2Dto3D
    scale.z = scale.z * LudoLib.scale2Dto3D
    return scale
end

function LudoLib.Get2DTo3DScale(scale)
    scale.x = scale.x / LudoLib.scale2Dto3D
    scale.y = scale.y / LudoLib.scale2Dto3D
    scale.z = scale.z / LudoLib.scale2Dto3D
    return scale
end

function LudoLib.InitPos()
    LudoLib.Pos2D = {}
    LudoLib.PosMini2D = {}
    local posNode = GameObject.Find("LudoCanvasBG/root/@PosNode")
    for CSeatNum, v in ipairs(LudoLib.PiecesPosIndex) do
        for place, pos in ipairs(v) do
            local pos1 = pos[1]
            local pos2 = pos[2]
            LudoLib.Pos2D[pos1] = LudoLib.Pos2D[pos1] or {}
            LudoLib.Pos2D[pos1][pos2] = posNode.transform:Find("@pos_" .. pos1 .. "_" .. pos2).transform.position

            LudoLib.PosMini2D[pos1] = LudoLib.PosMini2D[pos1] or {}
            LudoLib.PosMini2D[pos1][pos2] = {}
            for i = 1, 4 do
                local str
                if pos2 == 0 then
                    str = "@pos_" .. pos1 .. "_" .. pos2 .. "/@pos_start_" .. i
                elseif pos2 == 19 then
                    str = "@pos_" .. pos1 .. "_" .. pos2 .. "/@pos_end_" .. i
                else
                    str = "@pos_" .. pos1 .. "_" .. pos2 .. "/@pos_" .. i
                end
                LudoLib.PosMini2D[pos1][pos2][i] = posNode.transform:Find(str).transform.position
            end
        end
    end

    LudoLib.Pos3D = {}
    LudoLib.PosMini3D = {}
    LudoLib.SetCamera()

    for pos1, t in pairs(LudoLib.Pos2D) do
        LudoLib.Pos3D[pos1] = LudoLib.Pos3D[pos1] or {}
        for pos2, v in pairs(t) do
            LudoLib.Pos3D[pos1][pos2] = LudoLib.Get2DTo3DPoint(v)
        end
    end

    for pos1, t in pairs(LudoLib.PosMini2D) do
        LudoLib.PosMini3D[pos1] = LudoLib.PosMini3D[pos1] or {}
        for pos2, value in pairs(t) do
            LudoLib.PosMini3D[pos1][pos2] = LudoLib.PosMini3D[pos1][pos2] or {}
            for i, v in pairs(value) do
                LudoLib.PosMini3D[pos1][pos2][i] = LudoLib.Get2DTo3DPoint(v)
            end
        end
    end
    dump(LudoLib.Pos2D,"<color=yellow>Pos2D</color>")
    dump(LudoLib.Pos3D,"<color=yellow>Pos3D</color>")
    dump(LudoLib.PosMini2D,"<color=yellow>PosMini2D</color>")
    dump(LudoLib.PosMini3D,"<color=yellow>PosMini3D</color>")
end

function LudoLib.InitDicePos()
    LudoLib.Dice2D = {}
    local posNode = GameObject.Find("LudoCanvasBG/root/@DicePosNode")
    for i = 1, 4 do
        local rtf = posNode.transform:Find("@dice_" .. i):GetComponent("RectTransform")
        local pos = rtf.position
        local sizeDelta = rtf.sizeDelta
        LudoLib.Dice2D[i] = {xMax = pos.x + sizeDelta.x / 2,xMin = pos.x - sizeDelta.x / 2,yMax = pos.y + sizeDelta.y / 2, yMin = pos.y - sizeDelta.y / 2,z = pos.z}
    end
    LudoLib.Dice2D[0] =  posNode.transform:Find("@dice_0").position
end

function LudoLib.GetDicePos(CSeatNum)
    local dice2D = LudoLib.Dice2D[CSeatNum]
    local pos = {}
    pos.x = math.random(dice2D.xMin,dice2D.xMax)
    pos.y = math.random(dice2D.yMin,dice2D.yMax)
    pos.z = dice2D.z

    local dice3D = LudoLib.Get2DTo3DPoint(pos)
    return dice3D
end

function LudoLib.GetDicePosEnd()
    local pos = LudoLib.Get2DTo3DPoint(LudoLib.Dice2D[0])
    return pos
end

local colorMap = {
    blue = {
        "blue",
        "red",
        "green",
        "yellow",
    },
    red = {
        "red",
        "green",
        "yellow",
        "blue",
    },
    green = {
        "green",
        "yellow",
        "blue",
        "red",
    },
    yellow = {
        "yellow",
        "blue",
        "red",
        "green",
    },
}

function LudoLib.GetColor(CSeatNum)
    local base_color = PlayerPrefs.GetString(MainModel.UserInfo.user_id.."ludo_color","blue")
    local myColor = base_color
    local cm = colorMap[myColor]
    return cm[CSeatNum]
end

--检查玩家是否胜利
function LudoLib.CheckIsWin(SSeatNum)
    if not LudoModel
    or not LudoModel.data
    or not next(LudoModel.data)
    or not LudoModel.data.piece
    or not next(LudoModel.data.piece)
    or not LudoModel.data.piece[SSeatNum] then
        return
    end

    local endPlace = #LudoLib.PiecesPosIndex[SSeatNum] - 1
    for id, place in pairs(LudoModel.data.piece[SSeatNum]) do
        if place ~= endPlace then
            return
        end
    end

    return true
end