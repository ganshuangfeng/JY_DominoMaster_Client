CommonAnim = {}


--通用飞金币的动画
function CommonAnim.FlyGold(start_pos,stop_pos,backcall,prefab_name)
	local mid_pos = (start_pos + stop_pos) / 2
	mid_pos = mid_pos + Vector3.New(0,5,0)
	local obj_list = {}

	for i = 1,5 do
		local obj = newObject(prefab_name or "GoldPrefab",GameObject.Find("Canvas/LayerLv2").transform)
		obj.transform.position = start_pos
		local curr = obj.gameObject.transform.localPosition
		obj.gameObject.transform.localPosition = Vector3.New(curr.x + math.random( -20,20 ) /2,curr.y + math.random( -20,20 )/2,0)
		obj_list[#obj_list+1] = obj

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1 + 0.06 * i)
		seq:Append(obj.transform:DOMove(mid_pos,0.3))
		if i == 5 then
			seq:AppendCallback(
				function ()
					if backcall then
						backcall()
					end
					for ii = 1,#obj_list do
						local seq2 = DoTweenSequence.Create()
						seq2:Append(obj_list[ii].transform:DOMove(stop_pos,0.2))
						seq2:AppendCallback(
							function ()
								destroy(obj_list[ii].gameObject)
							end
						)
					end
				end
			)
			
		end
	end
end 

--飞完金币开始冒数字
function CommonAnim.ShowGoldNum(pos,award,backcall)
	local text_obj = newObject("TextPrefab",GameObject.Find("Canvas/LayerLv2").transform)
	local jian_p = text_obj.transform:Find("@main1_txt"):GetComponent("Text")
	local add_p = text_obj.transform:Find("@main2_txt"):GetComponent("Text")
	jian_p.text = award
	add_p.text = "+".. award
	add_p.gameObject:SetActive(award > 0)
	jian_p.gameObject:SetActive(award < 0)
	text_obj.transform.position = pos
	GameObject.Destroy(text_obj,0.9)
	Timer.New(function ()
		if backcall then
			backcall()
		end
	end,0.9,1):Start()
end

function CommonAnim.FlyGoldNum(pos,award,backcall)
	if not award then return end
	local obj = newObject("GoldNumPrefab",GameObject.Find("Canvas/LayerLv2").transform)
	local jian_p = obj.transform:Find("@main1_txt"):GetComponent("Text")
	local add_p = obj.transform:Find("@main2_txt"):GetComponent("Text")
	add_p.gameObject:SetActive(award > 0)
	jian_p.gameObject:SetActive(award < 0)

	add_p.text = "+".. StringHelper.ToCash(award)
	jian_p.text = "-" .. StringHelper.ToCash(award)

	local CG  = obj.transform:GetComponent("CanvasGroup")
	obj.transform.position = pos
	obj.transform.localScale = Vector3.zero
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:Append(obj.transform:DOScale(Vector3.one,0.2))
	seq:Append(obj.transform:DOMoveY(pos.y + 100,2):SetEase(Enum.Ease.OutCirc))
	seq:Append(CG:DOFade(0,1))
	seq:AppendInterval(1)
	seq:OnForceKill(function ()
		Destroy(obj)
		
		if backcall and type(backcall) == "function" then
			backcall()
		end
	end)
end

function CommonAnim.FlyLevelScore(pos,score,backcall)
	local obj = newObject("LevelScoreText",GameObject.Find("Canvas/LayerLv2").transform)
	local add_p = obj.transform:GetComponent("Text")
	add_p.text = "EXP+".. StringHelper.ToCash(score)

	local CG  = obj.transform:GetComponent("CanvasGroup")
	obj.transform.position = pos
	obj.transform.localScale = Vector3.zero
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:Append(obj.transform:DOScale(Vector3.one,0.2))
	seq:Append(obj.transform:DOMoveY(pos.y + 150,2):SetEase(Enum.Ease.OutCirc))
	seq:Append(CG:DOFade(0,1))
	seq:AppendInterval(1)
	seq:OnForceKill(function ()
		Destroy(obj)
		
		if backcall and type(backcall) == "function" then
			backcall()
		end
	end)
end

function CommonAnim.StopCountDown(seq)
	if not seq then
		return
	end
    seq:Kill()
end

-- cd:时间，sort:0 倒计时 1顺计时
function CommonAnim.PlayCountDown(cd,sort,parent,backcall,prefab_name,audio_name,each_call)
    --倒计时动画
    local obj = newObject(prefab_name or "CommonCD",parent)
    local txt = obj.transform:Find("@cd_txt"):GetComponent("Text")
    if sort == 0 then
        txt.text = cd
    else
        txt.text = 1
    end
    local seq = DoTweenSequence.Create()
    for i = 1, cd do
        seq:Append(txt.transform:DOScale(1.3,0.7))
        seq:Append(txt.transform:DOScale(1,0.3))
        seq:AppendCallback(function ()
            if sort == 0 then
                cd = cd - 1
				if audio_name then
					if cd <= 3 and cd > 0 then
						ExtendSoundManager.PlaySound(audio_name)
					end
				end
				if each_call then
					each_call(cd)
				end	
                txt.text = cd
            else
                txt.text = i + 1
            end
        end)
    end
    seq:OnForceKill(
        function ()
           destroy(obj.gameObject)
		   if backcall then
				backcall()
		   end
        end
    )
	return seq
end

function CommonAnim.ShowMenuBtns(bg,btn1,btn2,btn3,btn4)
    SetSpriteAendererAlpha(bg,0,UnityEngine.UI.Image)
    DOFadeSpriteRender(bg,1,0.3,nil,UnityEngine.UI.Image)
    local seq = DoTweenSequence.Create()
	if btn1 then
		seq:Append(btn1.transform:DOScale(0,0.05):From())
	end
	if btn2 then
		seq:Append(btn2.transform:DOScale(0,0.05):From())
	end
	if btn3 then
		seq:Append(btn3.transform:DOScale(0,0.05):From())
	end
	if btn4 then
		seq:Append(btn4.transform:DOScale(0,0.05):From())
	end
    seq:OnForceKill(
        function ()
            SetSpriteAendererAlpha(bg,1,UnityEngine.UI.Image)
			if btn1 then
				btn1.transform.localScale = Vector3.one
			end
			if btn2 then
				btn2.transform.localScale = Vector3.one
			end
			if btn3 then
				btn3.transform.localScale = Vector3.one
			end
			if btn4 then
				btn4.transform.localScale = Vector3.one
			end
        end
    )
end

function CommonAnim.LvUpAnim(playerPos)
	-- if not Act_LRManager then
	-- 	return
	-- end
	local obj = newObject("qiu_dj_gx_h", playerPos)
	obj.transform:Find("gx").transform.localPosition = Vector3.zero
    local seq = DoTweenSequence.Create()
	seq:AppendInterval(3.5)
	seq:AppendCallback(function()
	
	end)
	seq:OnForceKill(function()
		destroy(obj.gameObject)
	end)
end


function CommonAnim.RpAddAnim(playerPos, addNum)
	local obj = newObject("rp_add_anim", playerPos)
	obj.transform:Find("rp_txt"):GetComponent("Text").text = "+" .. addNum
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:AppendCallback(function()
	
	end)
	seq:OnForceKill(function()
		destroy(obj.gameObject)
	end)
end