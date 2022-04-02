-- 创建时间:2021-11-08

DominoJLAnim = {}
local M = DominoJLAnim
--发牌的动画
function M.DealCard(parent,data,card_data,backcall)
    dump(data,"<color=red>数据 +++++</color>")
    dump(card_data,"<color=red>数据 +++++</color>")
    --卡牌最大数量
    local max_num = 28
    local start_pos = Vector3.New(-489,213,0)

    local init_mid_pos = function ()
        local re = {}
        local left_pos = Vector3.New(-281,40,0)
        local space = 48 * 1.2
        for i = 1,max_num do
            --下
            local p_index = math.ceil(i / 2) - 1
            local x = p_index * space + left_pos.x
            local y = nil
            if i % 2 == 1 then
                y = left_pos.y
            else--上
                y = left_pos.y + 6
                x = x - 6
            end
            local pos = Vector3.New(x,y,0)

            re[#re + 1] = pos
        end
        return re
    end

    local seq = DoTweenSequence.Create()
    local mid_pos_list = init_mid_pos()
    local card_prefab_list = {}
    local deal = function (card_prefab_list)
        --使用过的位置指针
        local index_list = {}
        local index = 0
    
        local target_pos = {}
        local index_list = {}
        local my_card = {}

        for i = 1,#data * 7 do
            local _d = {}
            local index = (i - 1) % (#data) + 1
            index_list[index] = index_list[index] or 1
            local pos = data[index].posList[index_list[index]]
            _d.pos = pos
            _d.isMe = data[index].i == 1
            _d.index = data[index].i
            if _d.pos then
                target_pos[#target_pos + 1] = _d
            end
            index_list[index] = index_list[index] + 1
        end

        local seq2 = DoTweenSequence.Create()
        local t = -0.2 + 0.12
        local temp_data = {}
        for i = #target_pos,1,-1 do
            local j = #target_pos - i + 1
            local card_index = #card_prefab_list - j + 1
            seq2:Append(card_prefab_list[card_index].transform:DOMove(target_pos[j].pos, 0.1))
            if target_pos[j].isMe then
                my_card[#my_card+1] = card_prefab_list[card_index]
                seq2:Join(card_prefab_list[card_index].transform:DOScale(Vector3.New(1,1,1), 0.1))
            else
                seq2:AppendCallback(
                    function ()
                        card_prefab_list[card_index].gameObject:SetActive(false)
                        temp_data[target_pos[j].index] = temp_data[target_pos[j].index] or 0
                        temp_data[target_pos[j].index] = temp_data[target_pos[j].index] + 1
                        DominoJLGamePanel.Instance.playerList[target_pos[j].index].card_txt.text = temp_data[target_pos[j].index]
                    end
                )
            end
            seq2:AppendInterval(t)
            if i == 1 then
                seq2:AppendInterval(-t + 0.15)
                --开始翻牌
                seq2:AppendCallback(
                    function ()
                        ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_fapai.audio_name)
                        M.ShowCard(my_card,card_data,function ()
                            backcall()
                            for i = 1,#card_prefab_list do
                                card_prefab_list[i]:MyExit()                  
                            end
                            card_prefab_list = {}
                        end)
                    end
                )
            end
        end
        -- seq2:OnForceKill(
        --     function ()
        --         backcall()
        --         for i = 1,#card_prefab_list do
        --             card_prefab_list[i]:MyExit()                                 
        --         end
        --         card_prefab_list = {}
        --     end
        -- )
    end
    --洗牌
    for i = 1,max_num do
        seq:AppendInterval(0.02)
        local card_prefab = nil
        seq:AppendCallback(
            function ()
                ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_fapai.audio_name)
                card_prefab = DominoJLCard.Create({cardData = {1,1}})
                card_prefab:SetIsBack(true)
                card_prefab.transform.localPosition = start_pos
                card_prefab.transform.localScale = Vector3.New(0.58,0.58,0.58)
                local CG  = card_prefab.transform:GetComponent("CanvasGroup")
                CG.alpha = 0
                seq:Append(card_prefab.transform:DOMove(mid_pos_list[i], 0.08))
                seq:Join(card_prefab.transform:DOScale(Vector3.New(0.5,0.5,0.5),0.08))
                seq:Join(CG:DOFade(1,0.08))
                card_prefab_list[#card_prefab_list+1] = card_prefab
            end
        )
        --开始发牌
        local is_force = false
        if max_num == i then
            seq:AppendInterval(0.04)
            seq:AppendCallback(
                function ()
                    if not is_force then
                        deal(card_prefab_list)
                        is_force = true
                    end
                end
            )
            seq:OnForceKill(
                function ()
                    if not is_force then
                        for i = 1,#card_prefab_list do
                            card_prefab_list[i]:MyExit()                                     
                        end
                        card_prefab_list = {}
                        is_force = true
                    end
                end
            )
        end
    end
end
--翻牌的动画
function M.ShowCard(my_card,card_data,backcall)
    local seq = DoTweenSequence.Create()
    local re_list = {}
    for i = 1,#my_card do
        local _cardData = DominoJLLib.GetDataById(card_data[i])
        local _parent = my_card[i].gameObject.transform.parent
        seq:AppendInterval(0.03)
        local mid
        seq:AppendCallback(
            function ()
                ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_fanpai.audio_name)
                mid = DominoJLCard.Create({cardData = {1,1}})
                mid:SetIsMid(true)
                mid.transform.localPosition = my_card[i].gameObject.transform.localPosition
                mid.transform.localScale = my_card[i].gameObject.transform.localScale
                my_card[i].gameObject:SetActive(false)
            end
        )
        seq:AppendInterval(0.05)
        seq:AppendCallback(
            function ()
                local re = DominoJLCard.Create({parent = _parent,
                    cardData = _cardData
                })
                re.transform.localPosition = my_card[i].gameObject.transform.localPosition
                re.transform.localScale = my_card[i].gameObject.transform.localScale
                re_list[#re_list+1] = re
                mid:MyExit()
                if i == #my_card then
                    for i = 1,#re_list do
                        re_list[i]:MyExit()
                    end
                    re_list = nil
                    my_card = nil
                    if backcall then
                        backcall()
                        -- Event.Brocast("show_card_finsh")
                    end
                end
            end
        )
        seq:OnForceKill(
            function ()
                if re_list then
                    for i = 1,#re_list do
                        re_list[i]:MyExit()
                    end
                end
                re_list = nil
            end
        )
    end
end

--将牌打出去的动画
function M.PlayCard(my_card,localPosition,rotation,scale,isLast,position,backcall)
    local seq = DoTweenSequence.Create()
    my_card:SetIsOnDesk(true)
    my_card:SetIsBack(false)
    my_card:SetRotation(rotation.z)
    seq:Append(my_card.transform:DOLocalMove(localPosition,0.5))
    seq:Join(my_card.transform:DORotate(rotation,0.5))
    seq:Join(my_card.transform:DOScale(scale,0.5))
    --最后一张牌
    if isLast then
        ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_lastpai.audio_name)
        seq:InsertCallback(0.5,function ()
            M.PlayLastCard(position,DominoJLGamePanel.Instance.effect_node)
        end)
    else
        seq:InsertCallback(0.3,function ()
            ExtendSoundManager.PlaySound(audio_config.domino.bgm_duominuo_luopai.audio_name)
        end)
    end
    seq:OnForceKill(
        function ()
            if backcall then
                backcall()
            end
        end
    )
end

function M.PlayHint(obj)
    obj.transform.localScale = Vector3.zero
    obj.gameObject:SetActive(true)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOScale(1.2,0.1))
    seq:Append(obj.transform:DOScale(0.9,0.2))
    seq:Append(obj.transform:DOScale(1,0.25))
    seq:AppendInterval(1)
    seq:Append(obj.transform:DOScale(1.3,0.2))
    seq:Append(obj.transform:DOScale(0,0.2))
    seq:OnForceKill(
        function ()
            obj.gameObject:SetActive(false)
        end
    )
end

function M.ShowMenuBtns(bg,btn1,btn2,btn3,btn4)
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

function M.PlayCardCanOut(card)
    if not IsEquals(card.transform) then
        return
    end
    local seq = DoTweenSequence.Create()
    seq:Append(card.transform:DOScale(1.2,0.25))
    seq:Append(card.transform:DOScale(1,0.25))
    seq:OnForceKill(
        function ()
           card:SetScale(1)
        end
    )
end

function M.PlayLastCard(pos,parent)
	local obj = GameObject.Instantiate(GetPrefab("majiang_hu"),parent)
    obj.transform.position = pos
    GameObject.Destroy(obj,5)
end