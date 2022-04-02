-- 创建时间:2021-11-08

QiuQiuAnim = {}
M = QiuQiuAnim

--飞牌动画
function QiuQiuAnim.FlyCard(obj,target_scale,backcall)
    local seq = DoTweenSequence.Create()
    ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_give_card.audio_name)
    seq:Append(obj.transform:DOLocalMove(Vector3.zero,0.5))
    local rotation = obj.transform.parent.transform.rotation
    seq:Join(obj.transform:DOLocalRotate(rotation,0.5,2))
    seq:Join(obj.transform:DOScale(target_scale or Vector3.New(1,1,1),0.5))
    seq:AppendCallback(
        function ()
            if backcall then
                backcall()
            end
            obj.transform.localEulerAngles = Vector3.zero
        end
    )
end
--翻牌动画
function QiuQiuAnim.FanPai(card,card_id,backcall)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.12)
    card:SetBack("ty_gp_d_fm")
    seq:AppendCallback(
        function ()
            card:SetMid()
        end
    )
    seq:AppendInterval(0.12)
    seq:AppendCallback(
        function ()
            card:SetNormal()
            card:RefreshData(card_id)
            if backcall then
                backcall()
            end
        end
    )
end

--确认庄家的动画
function QiuQiuAnim.ConfirmD(seat_num)
    local UI_Index = QiuQiuModel.data.s2cSeatNum[seat_num]
    local obj = QiuQiuGamePanel.Instance.mid_d_node
    ExtendSoundManager.PlaySound(audio_config.qiuqiu.qiuqiu_star_game.audio_name)
    obj.gameObject:SetActive(true)
    obj.transform.position = Vector3.zero
    local seq = DoTweenSequence.Create()
    local target_pos = QiuQiuGamePanel.Instance.playerList[UI_Index].d_node.gameObject.transform.position
    seq:Append(obj.transform:DOMove(target_pos,0.5))
    seq:AppendCallback(
        function ()
            obj.gameObject:SetActive(false)
            QiuQiuGamePanel.Instance.playerList[UI_Index].d_node.gameObject:SetActive(true)
        end
    )
end

function QiuQiuAnim.ShowMenuBtns(bg,btn1,btn2,btn3,btn4)
    SetSpriteAendererAlpha(bg,0,UnityEngine.UI.Image)
    DOFadeSpriteRender(bg,1,0.3,nil,UnityEngine.UI.Image)
    local seq = DoTweenSequence.Create()
    seq:Append(btn1.transform:DOScale(0,0.05):From())
    seq:Append(btn2.transform:DOScale(0,0.05):From())
    seq:Append(btn3.transform:DOScale(0,0.05):From())
    seq:Append(btn4.transform:DOScale(0,0.05):From())
    seq:OnForceKill(
        function ()
            SetSpriteAendererAlpha(bg,1,UnityEngine.UI.Image)
            btn1.transform.localScale = Vector3.one
            btn2.transform.localScale = Vector3.one
            btn3.transform.localScale = Vector3.one
            btn4.transform.localScale = Vector3.one
        end
    )
end
--转桌动画
function QiuQiuAnim.HuanZhuoAnim(Move_Cseat)
    local playerList = QiuQiuGamePanel.Instance.playerList
    local pos_list = {}
    for i = 1,#playerList do
        playerList[i].yes.gameObject:SetActive(false)
        playerList[i].huanzhuo.gameObject:SetActive(true)
        pos_list[#pos_list+1] = playerList[i].huanzhuo.transform.position
    end

    local seq = DoTweenSequence.Create()
    local get_path = function(C_index)
        local path = {}

        local C_index = C_index
        for i = 1,Move_Cseat do
            path[i - 0] = pos_list[C_index]
            C_index = C_index - 1
            if C_index < 1 then
                C_index = 7
            end
        end

        return path
    end


    for i = 1,#playerList do
        local path = get_path(i)
        seq:Append(playerList[i].huanzhuo.transform:DOPath(path,0.6,Enum.PathType.CatmullRom))
        seq:AppendInterval(-0.6) 
    end
    seq:AppendInterval(0.6)
    seq:AppendCallback(
        function ()
            for i = 1,#playerList do
                playerList[i].yes.gameObject:SetActive(true)
                playerList[i].huanzhuo.gameObject:SetActive(false)
                playerList[i].huanzhuo.transform.localPosition = Vector3.zero
            end
        end
    )
end