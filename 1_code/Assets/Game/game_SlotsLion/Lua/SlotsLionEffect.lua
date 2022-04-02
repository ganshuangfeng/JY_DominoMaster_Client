-- 创建时间:2019-03-19
SlotsLionEffect = {}
local M = SlotsLionEffect
local objs
local objsTemp
local scrollItemLongObjs = {}
local scrollItemEffectObjs = {}
local lionEffectPrefab = nil
local DoTweens = {}

function M.Init()
	objs = {}
	objsTemp = {}
end

function M.Refresh()
	M.ClearAllObj()
end

function M.Exit()
	M.ExitTimer()
	M.root = nil
	M.ClearAllObj()
end

function M.ExitTimer()
	for k, v in pairs(DoTweens) do
		v:Kill()
	end
	DoTweens = {}
	M.ClearAllObj()
end

function M.GetPrefab(name)
	if not objs[name] then
		objs[name] = newObject(name,M.GetRoot())
		objs[name].transform.position = Vector3.New(10000,10000,-10000)
	end
	return objs[name]
end

function M.GetRootNode()
	return SlotsLionGamePanel.Instance.effect_content
end

function M.GetCenterRootNode()
	return SlotsLionGamePanel.Instance.effect_center_content
end

function M.GetRoot()
	if not M.root then
		M.root = GameObject.Find("GameObject").transform
	end
	return M.root
end

function M.ClearAllObj()
	for k,v in pairs(objs) do
		Destroy(v)
	end
	objs = {}
	for k,v in pairs(objsTemp) do
		Destroy(v)
	end
	objsTemp = {}
	scrollItemLongObjs = {}
	destroyChildren(M.GetRootNode())
	destroyChildren(M.GetCenterRootNode())
	M.StopLionEffect()
end

--中奖连线特效
function M.PlayItemWinConnect(itemWinMap,t,itemObjMap,t5Line)
	if not itemWinMap
	or not next(itemWinMap)
	then
		return
	end
	if not t5Line then
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_lianxian.audio_name)
	end
	t = t or 0.2
	for x, value in pairs(itemWinMap) do
		for y, id in pairs(value) do
			local obj = newObject("XC_slc_biankuang",M.GetRootNode())
			obj.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
			GameObject.Destroy(obj,t)
			if not SlotsLionLib.CheckIdIsDEFG(id) then
				local seq = SlotsLionHelper.GetSeq()
				seq:InsertCallback(t * 1/ 5,function ()
					itemObjMap[x][y]:SetActive(false)
				end)
				seq:InsertCallback(t * 2/ 5,function ()
					itemObjMap[x][y]:SetActive(true)
				end)
				seq:InsertCallback(t * 3/ 5,function ()
					itemObjMap[x][y]:SetActive(false)
				end)
				seq:InsertCallback(t * 4/ 5,function ()
					itemObjMap[x][y]:SetActive(true)
				end)
				seq:OnKill(function ()
					itemObjMap[x][y]:SetActive(true)
				end)
			end
		end
	end
end

function M.PlayItemARoll(itemDataMap,callback)
	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_freespins.audio_name)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemARoll)
	local c = 0
	for x, v in pairs(itemDataMap) do
		for y, id in pairs(v) do
			if id == "A" then
				c = c + 1
				local obj = newObject("YS_bp",M.GetRootNode())
				obj.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
				GameObject.Destroy(obj,t)
			end
		end
	end

	local pro = SlotsLionModel.GetGameProcess()
	if pro.game ~= "main" or c < 3 then
		return
	end

	SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(true)
	local seq = SlotsLionHelper.GetSeq()
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		if callback and type(callback) =="function" then
			callback()
		end
		SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(false)
	end)
	seq:OnKill(function ()
		SlotsLionGamePanel.Instance.effect_content_bg.gameObject:SetActive(false)
	end)
end

function M.PlayTriggerFree(itemDataMap,callback)
	-- ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_freespins.audio_name)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectTriggerFree)
	local seq = SlotsLionHelper.GetSeq()
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		if callback and type(callback) =="function" then
			callback()
		end
	end)
end

function M.PlayMiniGame1RateFly(id,rate,startPos,endPos,callback)
	--刷新的时候不能停止
	local seq = SlotsLionHelper.GetSeq()
	seq:AppendCallback(function ()
		local obj = newObject("fuzi_YS_gx",M.GetRootNode())
		obj.transform.position = startPos
		local img = obj.transform:Find("2"):GetComponent("Image")
		img.sprite = SlotsLionHelper.GetTexture("item" .. id)
		local txt = obj.transform:Find("2/@rate_txt"):GetComponent("Text")
		txt.text = rate

		SlotsLionLib.SetFontById(txt,id)
		GameObject.Destroy(obj,3)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateLightBack)
	seq:AppendInterval(t)
	local objs = {}
	seq:AppendCallback(function ()
		local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateFlyFront)
		local obj = newObject("fuzi_gx_tw",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,t)
		objs[#objs+1] = obj
	end)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateFlyFront)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		for i, v in ipairs(objs) do
			seq:Append(v.transform:DOMove(endPos,t))
		end
	end)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		local obj = newObject("fuzi_gx_tw_shouji",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
	end)
	seq:OnComplete(function ()
		if callback then
			callback()
		end
	end)
end

function M.PlayMiniGame1RateClearFly(x,y,id,rate,awardTxt,callback)
	--刷新的时候不能停止
	local endPos = awardTxt.transform.position
	local rateTxt = newObject("SlotsLionRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")
	SlotsLionLib.SetFontById(txt,id)
	txt.text = rate
	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateClearFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateClearTxtChange)
	seq:AppendCallback(function ()
		if callback then
			callback()
		end
		seq:Append(awardTxt.transform:DOScale(2,t):From())
		rateTxt.gameObject:SetActive(false)
		local obj = newObject("UI_slc_ys_sg",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
	end)
end

function M.PlayMiniGame2RateInitFly(x,y,id,rate,awardTxt,callback)
	--刷新的时候不能停止
	local endPos = awardTxt.transform.position
	local rateTxt = newObject("SlotsLionRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")

	SlotsLionLib.SetFontById(txt,id)
	txt.text = rate

	local item = SlotsLionGameMini2Panel.Instance:GetItem(x,y)
	item.rate_txt.gameObject:SetActive(false)

	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame2RateInitFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame2RateInitTxtChange)
	seq:AppendCallback(function ()
		if callback then
			callback()
		end
		seq:Append(awardTxt.transform:DOScale(2,t):From())
		rateTxt.gameObject:SetActive(false)
		local obj = newObject("UI_slc_ys_sg",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
	end)
end

function M.PlayMiniGame2RateClearFly(x,y,id,rate,awardTxt,callback)
	--刷新的时候不能停止
	local endPos = awardTxt.transform.position
	local rateTxt = newObject("SlotsLionRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")

	SlotsLionLib.SetFontById(txt,id)

	txt.text = rate

	local item = SlotsLionGameMini2Panel.Instance:GetItem(x,y)
	item.rate_txt.gameObject:SetActive(false)

	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame2RateClearFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame2RateClearTxtChange)
	seq:AppendCallback(function ()
		if callback then
			callback()
		end
		seq:Append(awardTxt.transform:DOScale(2,t):From())
		rateTxt.gameObject:SetActive(false)
		local obj = newObject("UI_slc_ys_sg",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
	end)
end

function M.PlayMiniGame2AllRateClearFly(obj,awardTxt,callback)
	-- awardTxt.transform.localScale = Vector3.zero
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_numfei.audio_name)
	local endPos = awardTxt.transform.position
	local _obj = GameObject.Instantiate(obj,M.GetCenterRootNode())
	_obj.transform.position = obj.transform.position
	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2WinFly)
	seq:Append(_obj.transform:DOMove(endPos,t))
	seq:AppendCallback(function ()
		GameObject.Destroy(_obj)
		local obj = newObject("UI_slc_ys_sg",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
		if callback then
			callback()
		end
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2WinChange)
	seq:Append(awardTxt.transform:DOScale(0.7,t):From())
end

function M.PlayAddFree(startPos,endPos,callback)
	local seq = SlotsLionHelper.GetSeq()
	seq:AppendCallback(function ()
		local obj = newObject("YS_+1spln",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,0.7)
	end)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectAddFreeLightBack)
	seq:AppendInterval(t)
	local objs = {}
	seq:AppendCallback(function ()
		local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectAddFreeFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1RateFlyFront)
		local obj = newObject("TW_gx",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,t)
		objs[#objs+1] = obj
	end)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectAddFreeFlyFront)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectAddFreeFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_1spin.audio_name)
		for i, v in ipairs(objs) do
			seq:Append(v.transform:DOMove(endPos,t))
		end
	end)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_cishu.audio_name)
		local obj = newObject("TW_gx_baozha",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
	end)
	seq:OnComplete(function ()
		if callback then
			callback()
		end
	end)
end

function M.PlayMiniGame1AwardFly(obj)
	local endPos = {x = 0,y = -100}
	local awardObj = GameObject.Instantiate(obj,M.GetCenterRootNode())
	awardObj.transform.position = obj.transform.position
	awardObj:SetActive(true)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_numfei.audio_name)
	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame1AwardFly)
	seq:Append(awardObj.transform:DOMove(endPos,t))
	GameObject.Destroy(awardObj,t + 0.02)
end

function M.PlayMiniGame2AwardFly(obj)
	local endPos = {x = 0,y = 100}
	local awardObj = GameObject.Instantiate(obj,M.GetCenterRootNode())
	awardObj.transform.position = obj.transform.position
	awardObj:SetActive(true)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_numfei.audio_name)
	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.effectMiniGame2AwardFly)
	seq:Append(awardObj.transform:DOMove(endPos,t))
	GameObject.Destroy(awardObj,t + 0.02)
end

function M.PlayScrollItemLong(x,y)
	if scrollItemLongObjs[x] and scrollItemLongObjs[x][y] then
		return
	end

	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_34yj.audio_name)
	local obj = newObject("YS_yuansu_biankuang_lion",M.GetRootNode())
	obj.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
	scrollItemLongObjs[x] = scrollItemLongObjs[x] or {}
	scrollItemLongObjs[x][y] = obj
end

function M.StopScrollItemLong(x,y)
	if not scrollItemLongObjs[x] or not scrollItemLongObjs[x][y] then
		return
	end

	destroy(scrollItemLongObjs[x][y])
	scrollItemLongObjs[x][y] = nil
end

-- 播放元素的特效
function M.PlayScrollItemEffect(item_id,x,y)
	if scrollItemEffectObjs[x] and scrollItemEffectObjs[x][y] then
		return
	end
	local config = {"YS_J","YS_Q","YS_K","YS_A","YS_luo","YS_denglong","YS_dagu","YS_yuanpan","YS_shizit"}
	if not config[item_id] then
		return
	end
	local obj = newObject(config[item_id],M.GetRootNode())
	obj.transform.localPosition = SlotsLionLib.GetPositionByPos(x,y)
	local tx = newObject("XC_slc_biankuang",obj.transform)
	tx.transform.localScale = Vector3.New(1.15,1.15,1.15)
	scrollItemEffectObjs[x] = scrollItemEffectObjs[x] or {}
	scrollItemEffectObjs[x][y] = obj
end

--停止特效
function M.StopAllScrollItemEffect()
	scrollItemEffectObjs = scrollItemEffectObjs or {}
	for k , v in pairs(scrollItemEffectObjs) do
		for kk,vv in pairs(v) do
			destroy(vv)
		end
	end
	scrollItemEffectObjs = {}
end

function M.ShowMenuBtns(btn1,btn2)
	local bg1 = btn1.transform:GetComponent("Image")
	local bg2 = btn2.transform:GetComponent("Image")
    SetSpriteAendererAlpha(bg1,0,UnityEngine.UI.Image)
    DOFadeSpriteRender(bg1,1,0.3,nil,UnityEngine.UI.Image)
	SetSpriteAendererAlpha(bg2,0,UnityEngine.UI.Image)
    DOFadeSpriteRender(bg2,1,0.3,nil,UnityEngine.UI.Image)
    local seq = DoTweenSequence.Create()
    seq:Append(btn1.transform:DOScale(0,0.05):From())
    seq:Append(btn2.transform:DOScale(0,0.05):From())
    seq:OnForceKill(
        function ()
            SetSpriteAendererAlpha(bg1,1,UnityEngine.UI.Image)
            SetSpriteAendererAlpha(bg2,1,UnityEngine.UI.Image)
            btn1.transform.localScale = Vector3.one
            btn2.transform.localScale = Vector3.one
        end
    )
end

function M.PlayLionEffect()
	if not lionEffectPrefab then
		lionEffectPrefab = newObject("YS_bk_shizi",M.GetRootNode())
		lionEffectPrefab.transform.position = Vector3.New(590,-6,0)
	end
end

function M.StopLionEffect()
	if lionEffectPrefab then
		destroy(lionEffectPrefab)
	end
	lionEffectPrefab = nil
end