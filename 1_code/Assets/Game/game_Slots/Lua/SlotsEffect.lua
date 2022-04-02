-- 创建时间:2019-03-19
SlotsEffect = {}
local M = SlotsEffect
local objs
local objsTemp
local scrollItemLongObjs = {}
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
	return SlotsGamePanel.Instance.effect_content
end

function M.GetCenterRootNode()
	return SlotsGamePanel.Instance.effect_center_content
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
			obj.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
			GameObject.Destroy(obj,t)
			if not SlotsLib.CheckIdIsDEFG(id) then
				local seq = SlotsHelper.GetSeq()
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

--聚宝盆加的金币
function M.PlayItemDGold()
    local gameData = SlotsModel.data.baseData.mainData
    local itemDMap = SlotsLib.GetItemMap(gameData.itemDataMap,{D = "D"})
    local t = {}
    for x, v in pairs(itemDMap) do
        for y, id in pairs(v) do
            if not gameData.itemDEffect or not gameData.itemDEffect[x] or not gameData.itemDEffect[x][y] then
                t[x] = t[x] or {}
                t[x][y] = id
            end
        end
    end
    SlotsEffect.PlayItemDGoldByItemDMap(t)
end

function M.PlayItemDGoldByItemDMap(itemDMap)
	for x, v in pairs(itemDMap) do
		for y, id in pairs(v) do
			M.PlayItemDGoldByXY(x,y)
		end
	end
end

function M.PlayItemDGoldByXY(x,y)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jubaopen.audio_name)
	SlotsModel.data.baseData.mainData.itemDEffect = SlotsModel.data.baseData.mainData.itemDEffect or {}
	SlotsModel.data.baseData.mainData.itemDEffect[x] = SlotsModel.data.baseData.mainData.itemDEffect[x] or {}
	SlotsModel.data.baseData.mainData.itemDEffect[x][y] = true
	--刷新的时候不能停止
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function ()
		local obj = newObject("slc_jb_jbp_sg01",M.GetRootNode())
		obj.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
		GameObject.Destroy(obj,3)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldLightBack)
	seq:AppendInterval(t)
	local objs = {}
	seq:AppendCallback(function ()
		local t = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFly) + SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFlyFront)
		for i = 1, math.random(2,3) do
			local obj = newObject("slc_jb_tw",M.GetRootNode())
			obj.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
			GameObject.Destroy(obj,t)
			objs[#objs+1] = obj
		end
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFlyFront)
	seq:AppendInterval(t)
	local t = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFly)
	local endPos = {x = 0,y = 400,z = 0}
	seq:AppendCallback(function ()
		for i, v in ipairs(objs) do
			local h = math.random(100, 200)
			local direction = math.random(1,2)
			seq:Append(v.transform:DOMoveBezier(endPos,h,t,direction))
		end
	end)
	seq:AppendInterval(t)
	seq:AppendCallback(function ()
		local obj = newObject("slc_jb_jbp_sg02",M.GetRootNode())
		obj.transform.position = endPos
		GameObject.Destroy(obj,4)
		SlotsAwardPoolPanel.Instance:PlayAwardPool4ExtChange()
	end)
	DoTweens[seq] = seq
end

function M.PlayItemERoll()
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_hongfu.audio_name)
	local t = SlotsModel.GetTime(SlotsModel.time.effectItemERoll)
	local gameData = SlotsModel.data.baseData.mainData
	local rateData = SlotsModel.data.baseData.mainData.rateMapItemE
	for x, v in pairs(gameData.itemDataMap) do
		for y, id in pairs(v) do
			if id == "E" then
				local obj = newObject("YS_fuzi",M.GetRootNode())
				obj.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
				local txt = obj.transform:Find("Text"):GetComponent("Text")
				txt.text = rateData[x][y]
				GameObject.Destroy(obj,t)
			end
		end
	end
end

function M.PlayMiniGame1RateFly(id,rate,startPos,endPos,callback)
	--刷新的时候不能停止
	local seq = SlotsHelper.GetSeq()
	seq:AppendCallback(function ()
		local obj = newObject("fuzi_YS_gx",M.GetRootNode())
		obj.transform.position = startPos
		local img = obj.transform:Find("2"):GetComponent("Image")
		img.sprite = SlotsHelper.GetTexture("item" .. id)
		local txt = obj.transform:Find("2/@rate_txt"):GetComponent("Text")
		txt.text = rate

		SlotsLib.SetFontById(txt,id)
		GameObject.Destroy(obj,3)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateLightBack)
	seq:AppendInterval(t)
	local objs = {}
	seq:AppendCallback(function ()
		local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateFly) + SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateFlyFront)
		local obj = newObject("fuzi_gx_tw",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,t)
		objs[#objs+1] = obj
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateFlyFront)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateFly)
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
	local rateTxt = newObject("SlotsRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")
	SlotsLib.SetFontById(txt,id)
	txt.text = rate
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateClearFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateClearTxtChange)
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
	local rateTxt = newObject("SlotsRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")

	SlotsLib.SetFontById(txt,id)
	txt.text = rate

	local item = SlotsMiniGame2Panel.Instance:GetItem(x,y)
	item.rate_txt.gameObject:SetActive(false)

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2RateInitFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2RateInitTxtChange)
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
	local rateTxt = newObject("SlotsRate",M.GetRootNode())
	rateTxt.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
	local txt = rateTxt.transform:Find("@rate_txt"):GetComponent("Text")

	SlotsLib.SetFontById(txt,id)

	txt.text = rate

	local item = SlotsMiniGame2Panel.Instance:GetItem(x,y)
	item.rate_txt.gameObject:SetActive(false)

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2RateClearFly)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_feizi.audio_name)
		seq:Append(rateTxt.transform:DOMove(endPos,t))
	end)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2RateClearTxtChange)
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
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2WinFly)
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
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2WinChange)
	seq:Append(awardTxt.transform:DOScale(0.7,t):From())
end

function M.PlayAddFree(startPos,endPos,callback)
	local seq = SlotsHelper.GetSeq()
	seq:AppendCallback(function ()
		local obj = newObject("YS_+1spln",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,0.7)
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.effectAddFreeLightBack)
	seq:AppendInterval(t)
	local objs = {}
	seq:AppendCallback(function ()
		local t = SlotsModel.GetTime(SlotsModel.time.effectAddFreeFly) + SlotsModel.GetTime(SlotsModel.time.effectMiniGame1RateFlyFront)
		local obj = newObject("TW_gx",M.GetRootNode())
		obj.transform.position = startPos
		GameObject.Destroy(obj,t)
		objs[#objs+1] = obj
	end)

	local t = SlotsModel.GetTime(SlotsModel.time.effectAddFreeFlyFront)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.effectAddFreeFly)
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
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame1AwardFly)
	seq:Append(awardObj.transform:DOMove(endPos,t))
	GameObject.Destroy(awardObj,t + 0.02)
end

function M.PlayMiniGame2AwardFly(obj)
	local endPos = {x = 0,y = 100}
	local awardObj = GameObject.Instantiate(obj,M.GetCenterRootNode())
	awardObj.transform.position = obj.transform.position
	awardObj:SetActive(true)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_numfei.audio_name)
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.effectMiniGame2AwardFly)
	seq:Append(awardObj.transform:DOMove(endPos,t))
	GameObject.Destroy(awardObj,t + 0.02)
end

function M.PlayScrollItemLong(x,y)
	if scrollItemLongObjs[x] and scrollItemLongObjs[x][y] then
		return
	end

	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_34yj.audio_name)
	local obj = newObject("YS_yuansu_biankuang",M.GetRootNode())
	obj.transform.localPosition = SlotsLib.GetPositionByPos(x,y)
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