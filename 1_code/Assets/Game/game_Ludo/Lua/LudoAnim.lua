-- 创建时间:2021-11-08
LudoAnim = {}
local M = LudoAnim
--棋子向前走
function M.PieceRun(CSeatNum,piece,place,TrampleData)
    local curr_place = piece.data.place
    local seq = DoTweenSequence.Create()
    if place <= curr_place then
        dump(LudoModel.data,"<color=white>！！！！！！！！！！！！走棋错误</color>")
    end

    piece:SetRenderQueue(piece:GetDefaultRenderQueue() + 1)
    for i = 1,place - curr_place do
        local pos = LudoLib.GetPiecePos(CSeatNum,curr_place + i)
        local mid = (pos + LudoLib.GetPiecePos(CSeatNum,curr_place + i - 1)) / 2
        --走出的第一步
        if curr_place + i == 1 or (LudoLib.CheckIsSafe(CSeatNum,place) and i == place - curr_place) then
            piece:PlayLongAnim(0.5)
            local path1 = {}
            mid = mid + Vector3.New(0,0,-25)
            path1[0] = LudoLib.GetPiecePos(CSeatNum,curr_place + i - 1)
            path1[1] = (path1[0] + mid) / 2 + Vector3.New(0,0,-10)
            path1[2] = mid
            seq:Append(piece.transform:DOPath(path1,0.25,Enum.PathType.CatmullRom))
            local path2 = {}
            path2[0] = mid
            path2[1] = (pos + path2[0]) / 2 + Vector3.New(0,0,-2) 
            path2[2] = pos
            seq:AppendCallback(
                function ()
                    piece:PlayShortAnim(1)
                end
            )
            seq:Append(piece.transform:DOPath(path2,0.1,Enum.PathType.CatmullRom))
            seq:AppendCallback(
                function ()
                    if (LudoLib.CheckIsSafe(CSeatNum,place) and i == place - curr_place) then
                        ExtendSoundManager.PlaySound(audio_config.ludo.ludo_chess_small_drop.audio_name)
                    end        
                    local prefab = newObject("qizi_yan",piece.transform)
                    prefab.transform.localPosition = Vector3.zero
                    prefab.transform.localScale = Vector3.New(0.15,0.15,0.15)
                    prefab.transform.localEulerAngles = Vector3.New(0,0,180)
                    prefab.transform:SetAsFirstSibling()
                    GameObject.Destroy(prefab,3)
                end
            )
        --走出的最后一步  
        elseif curr_place + i == 57 then
            piece:PlayLongAnim(0.5)
            local path1 = {}
            mid = mid + Vector3.New(0,0,-25)
            path1[0] = LudoLib.GetPiecePos(CSeatNum,curr_place + i - 1)
            path1[1] = (path1[0] + mid) / 2 + Vector3.New(0,0,-10)
            path1[2] = mid
            seq:AppendCallback(
                function ()
                    UnityEngine.Time.timeScale = 0.3
                end
            )
            seq:Append(piece.transform:DOPath(path1,0.25,Enum.PathType.CatmullRom))
            seq:AppendCallback(
                function ()
                    Event.Brocast("kuoshan_ui")
                end
            )
            local path2 = {}
            path2[0] = mid
            path2[1] = (pos + path2[0]) / 2 + Vector3.New(0,0,-2) 
            path2[2] = pos
            seq:AppendCallback(
                function ()
                    piece:PlayShortAnim(1)
                end
            )
            seq:Append(piece.transform:DOPath(path2,0.045,Enum.PathType.CatmullRom):SetEase(Enum.Ease.Linear))
            seq:AppendCallback(
                function ()
                    --检查当前这个玩家有几颗旗子放入了终点
                    --检查这个玩家是不是第一个完成游戏的，并且这颗棋子是第4颗进入终点的棋子

                    local check_func = function (CSeatNum)
                        local map = LudoDesk.Instance.pieceMap[CSeatNum]
                        local sum = 0
                        for k,v in pairs(map) do
                            if v.piece.data.place >= 57 then
                                sum = sum + 1
                            end
                        end
                        return sum
                    end

                    local check_func2 = function ()
                        dump(check_func(CSeatNum),"<color=red>当前+++++++++++</color>")
                        if check_func(CSeatNum) == 3 then
                            for k , v in pairs(LudoDesk.Instance.pieceMap) do
                                if k ~= CSeatNum then
                                    if check_func(k) >= 4 then
                                        return false
                                    end
                                end
                            end
                            return true
                        end
                        return false
                    end
                    
                    local b = check_func2()

                    ExtendSoundManager.PlaySound(audio_config.ludo.ludo_to_end.audio_name)
                    local prefab = newObject("ZD_zongdian_gs",GameObject.Find("Canvas/GUIRoot/LudoGamePanel").transform)
                    prefab.transform.localPosition = Vector3.New(-10,30,0)
                    if b then
                        prefab.transform:Find("@huangguan").gameObject:SetActive(true)
                    end
                    GameObject.Destroy(prefab,3)
                    UnityEngine.Time.timeScale = 1
                end
            )
        --踩中旗子   
        elseif TrampleData and next(TrampleData) and i == place - curr_place then
            piece:PlayLongAnim(0.5)
            local path1 = {}
            mid = mid + Vector3.New(0,0,-25)
            path1[0] = LudoLib.GetPiecePos(CSeatNum,curr_place + i - 1)
            path1[1] = (path1[0] + mid) / 2 + Vector3.New(0,0,-10)
            path1[2] = mid
            seq:Append(piece.transform:DOPath(path1,0.25,Enum.PathType.CatmullRom))
            local path2 = {}
            path2[0] = mid
            path2[1] = (pos + path2[0]) / 2 + Vector3.New(0,0,-2) 
            path2[2] = pos
            seq:AppendCallback(
                function ()
                    piece:PlayShortAnim(1)
                end
            )
            seq:Append(piece.transform:DOPath(path2,0.1,Enum.PathType.CatmullRom))
            seq:AppendCallback(
                function ()
                    local prefab = newObject("qizi_shouji",piece.transform)
                    prefab.transform.localPosition = Vector3.zero
                    prefab.transform.localScale = Vector3.New(0.15,0.15,0.15)
                    prefab.transform.localEulerAngles = Vector3.New(31.66,0,180)
                    GameObject.Destroy(prefab,3)
                    ExtendSoundManager.PlaySound(audio_config.ludo.ludo_chess_big_drop.audio_name)
                end
            )
        else
            
            piece:PlayLongAnim(0.5)
            seq:Append(piece.transform:DOMoveX(mid.x,0.1):SetEase(Enum.Ease.Linear))
            seq:Join(piece.transform:DOMoveY(mid.y,0.1):SetEase(Enum.Ease.Linear))
            seq:Join(piece.transform:DOMoveZ(pos.z + -8,0.1):SetEase(Enum.Ease.Linear))
            seq:AppendCallback(
                function ()
                    ExtendSoundManager.PlaySound(audio_config.ludo.ludo_chess_jump.audio_name)
                end
            )
            seq:AppendCallback(
                function ()
                    piece:PlayShortAnim(0.5)
                end
            )
            seq:Append(piece.transform:DOMove(pos,0.04):SetEase(Enum.Ease.Linear))
            
        end
        seq:AppendInterval(0.04)
        seq:AppendCallback(
            function ()
                --piece:
            end
        )
        if i == place - curr_place then
            seq:AppendCallback(
                function()
                    -- piece:SetPlace(CSeatNum,place)
                    piece:SetRenderQueue(piece:GetDefaultRenderQueue())
                    local data = TrampleData
                    LudoDesk.Instance:RefreshPiece(CSeatNum)
                    LudoDesk.Instance:RefreshSafety()
                    dump(data,"<color=red>踢回起点棋子数据++++</color>")
                    if data and next(data) then
                        local piece = LudoDesk.Instance.pieceMap[data.CSeatNum][data.pieceId].piece
                        Timer.New(function ()
                            Event.Brocast("play_award_start_pos",{start_pos = LudoLib.GetPieceUIPos(CSeatNum,place),CSeatNum = CSeatNum})                        
                        end,1,1):Start()
                        M.PieceBack(data.CSeatNum,piece)
                    end
                    --走向终点
                    if place == 57 then
                        LudoGamePanel.Instance:RefreshFlagEnd()
                        Timer.New(function ()
                            Event.Brocast("play_award_start_pos",{start_pos = Vector3.zero,CSeatNum = CSeatNum})
                        end,1,1):Start()
                    end 
                end
            )
        end
    end
end

--旗子被踩了
function M.PieceBack(CSeatNum,piece)
    local curr_place = piece.data.place
    local seq = DoTweenSequence.Create()
    for i = curr_place,1,-1 do
        local pos = LudoLib.GetPiecePos(CSeatNum,i)
        seq:Append(piece.transform:DOMoveX(pos.x,0.2 * ( 6 / 20)))
        seq:Join(piece.transform:DOMoveY(pos.y,0.2* ( 6 / 20)))
        seq:Join(piece.transform:DOMoveZ(pos.z - 6,0.1* ( 6 / 20)))
        seq:Join(piece.transform:DOMoveZ(pos.z-3,0.2* ( 6 / 20)))
        if i == 1 then
            seq:AppendCallback(
                function()
                    LudoDesk.Instance:RefreshPiece(CSeatNum)
                    LudoDesk.Instance:RefreshSafety()
                end
            )
        end
    end
end

function M.PieceLeave(pieces,callback)
    local seq = DoTweenSequence.Create()
    for i = 1,#pieces,1 do
        if i == 1 then
            seq:Append(pieces[i].transform:DOMoveY(-180,1))
        else
            seq:Join(pieces[i].transform:DOMoveY(-180,1))
        end
        if i == #pieces then
            seq:AppendCallback(
                function()
                    if callback and type(callback) == "function" then
                        callback()
                    end
                end
            )
        end
    end
end
