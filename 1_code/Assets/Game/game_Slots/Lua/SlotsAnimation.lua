-- 创建时间:2019-03-19
local basefunc = require "Game.Common.basefunc"
SlotsAnimation = {}
local M = SlotsAnimation

local DoTweens = {}
function M.Init()
    
end

function M.Exit()
    
end

function M.Refresh()
    
end

function M.ExitTimer()
	for k, v in pairs(DoTweens) do
		v:Kill()
	end
	DoTweens = {}
end

function M.PlayMoneyChange(oldMoney,addMoney,setTxtCall,duration,_self)
	if not addMoney or addMoney == 0 then
		return
	end
	oldMoney = oldMoney or 0

	local allMoney = oldMoney + addMoney
	duration = duration or 1
	local tween
	tween = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
            function(value)
				setTxtCall(math.floor(oldMoney))
                return oldMoney
            end
        ),
        DG.Tweening.Core.DOSetter_float(
            function(value)
				setTxtCall(math.floor(value))
				if value == allMoney then
					SlotsHelper.KillSeq(tween)
					_self.tween = nil
				end
            end
        ),
        allMoney,
        duration
    )

	tween:OnComplete(
        function()
			setTxtCall(math.floor(allMoney))
        end
    )
	tween:OnKill(function ()
		setTxtCall(math.floor(allMoney))
	end)
	SlotsHelper.AddTween(tween)
	_self.tween = tween
	return tween
end

function M.PlayMiniGame1BgShow(_self)
	local bonusLP = _self.mini_game_1_bonus.transform.localPosition
	local playLP = _self.mini_game_1_play.transform.localPosition
	local endPos = _self.mini_game_1_x_img.transform.position
	local mini_game_1_x_img_cg = _self.mini_game_1_x_img:GetComponent("CanvasGroup")
	local mini_game_1_bonus_cg = _self.mini_game_1_bonus:GetComponent("CanvasGroup")
	local mini_game_1_play_cg = _self.mini_game_1_play:GetComponent("CanvasGroup")

	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_open.audio_name)
	_self.mini_game_1_bggx.gameObject:SetActive(false)
	_self.mini_game_1.gameObject:SetActive(true)
	_self.mini_game_1_bggx.gameObject:SetActive(true)
	mini_game_1_x_img_cg.alpha = 0
	mini_game_1_play_cg.alpha = 0
	mini_game_1_bonus_cg.alpha = 1
	_self.mini_game_1_node.transform.localScale = Vector3.zero

	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1BGChange)
	seq:Append(_self.mini_game_1_node.transform:DOScale(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_tongji.audio_name)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1BonusChangeMax)
	seq:Join(_self.mini_game_1_bonus.transform:DOScale(1.4,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1BonusChangeMin)
	seq:Append(_self.mini_game_1_bonus.transform:DOScale(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1XShow)
	seq:Append(mini_game_1_x_img_cg:DOFade(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1PlayShow)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_tongji.audio_name)
	end)
	seq:Append(mini_game_1_play_cg:DOFade(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1BonusPlayFlyFront)
	seq:AppendInterval(t)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame1BonusPlayFly)
	seq:AppendCallback(function ()
		seq:Append(mini_game_1_x_img_cg:DOFade(0,t/2))
		seq:Append(mini_game_1_bonus_cg:DOFade(0.5,t))
		seq:Append(mini_game_1_play_cg:DOFade(0.5,t))
		_self.mini_game_1_play.transform:DOMove(endPos,t)
		_self.mini_game_1_bonus.transform:DOMove(endPos,t)
	end)
	seq:AppendInterval(t + 0.1)
	seq:OnKill(function ()
		_self.mini_game_1_bonus.transform.localPosition = bonusLP
		_self.mini_game_1_play.transform.localPosition = playLP
	end)
end

function M.PlayMiniGame2BgShow(_self)
	local bonusLP = _self.mini_game_2_bonus.transform.localPosition
	local winLP = _self.mini_game_2_win.transform.localPosition
	local endPos = _self.mini_game_2_play.transform.position
	local mini_game_2_x_img_cg = _self.mini_game_2_x_img:GetComponent("CanvasGroup")
	local mini_game_2_bonus_cg = _self.mini_game_2_bonus:GetComponent("CanvasGroup")
	local mini_game_2_play_cg = _self.mini_game_2_play:GetComponent("CanvasGroup")
	local mini_game_2_add_img_cg = _self.mini_game_2_add_img:GetComponent("CanvasGroup")
	local mini_game_2_win_cg = _self.mini_game_2_win:GetComponent("CanvasGroup")

	_self.mini_game_2_win_txt.text = ""
	_self.mini_game_2_bggx.gameObject:SetActive(false)
	_self.mini_game_2.gameObject:SetActive(true)
	_self.mini_game_2_bggx.gameObject:SetActive(true)
	mini_game_2_x_img_cg.alpha = 0
	mini_game_2_play_cg.alpha = 0
	mini_game_2_add_img_cg.alpha = 0
	mini_game_2_win_cg.alpha = 0
	mini_game_2_bonus_cg.alpha = 1
	_self.mini_game_2_node.transform.localScale = Vector3.zero

	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_open.audio_name)
	local seq = SlotsHelper.GetSeq()
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2BGChange)
	seq:Append(_self.mini_game_2_node.transform:DOScale(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_tongji.audio_name)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2BonusChangeMax)
	seq:Join(_self.mini_game_2_bonus.transform:DOScale(1.4,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2BonusChangeMin)
	seq:Append(_self.mini_game_2_bonus.transform:DOScale(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2XShow)
	seq:Append(mini_game_2_x_img_cg:DOFade(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2PlayShow)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_tongji.audio_name)
	end)
	seq:Append(mini_game_2_play_cg:DOFade(1,t))
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2AddShow)
	seq:Append(mini_game_2_add_img_cg:DOFade(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_free_tongji.audio_name)
	end)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2WinShow)
	seq:Append(mini_game_2_win_cg:DOFade(1,t))

	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2WinFly + SlotsModel.time.clearMiniGame2WinChange)
	seq:AppendCallback(function ()
		local money = SlotsGamePanel.Instance.tip_money_txt.text
		local obj = SlotsGamePanel.Instance.tip_money_txt
		local awardTxt = _self.mini_game_2_win_txt
		local callback = function ()
			_self.mini_game_2_win_txt.text = money
		end
		SlotsEffect.PlayMiniGame2AllRateClearFly(obj,awardTxt,callback)
	end)
	seq:AppendInterval(t)

	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2BonusPlayFlyFront)
	seq:AppendInterval(t)
	local t = SlotsModel.GetTime(SlotsModel.time.clearMiniGame2BonusPlayFly)
	seq:AppendCallback(function ()
		seq:Append(mini_game_2_x_img_cg:DOFade(0,t/2))
		seq:Append(mini_game_2_add_img_cg:DOFade(0,t/2))
		seq:Append(mini_game_2_bonus_cg:DOFade(0.5,t))
		seq:Append(mini_game_2_play_cg:DOFade(0.5,t))
		seq:Append(mini_game_2_win_cg:DOFade(0.5,t))
		_self.mini_game_2_bonus.transform:DOMove(endPos,t)
		_self.mini_game_2_win.transform:DOMove(endPos,t)
	end)
	seq:AppendInterval(t + 0.1)
	seq:OnKill(function ()
		_self.mini_game_2_bonus.transform.localPosition = bonusLP
		_self.mini_game_2_win.transform.localPosition = winLP
	end)
end

-----------------------------
local SpeedStatus = {
	speedUp = "speedUp",
	speedUniform = "speedUniform",
	speedDown = "speedDown",
	speedEnd = "speedEnd",
}

local function GetLongData(itemDataMap,game)
	if game ~= "main" then
		return
	end

	local longX4,longX5 = SlotsLib.CheckLongX45(itemDataMap)
	local longFunc = function (x,y,longX4,longX5)
		if x == 3 then
			--第三列结束
			if longX4 then
				SlotsEffect.PlayScrollItemLong(x + 1,2)
			end
		elseif x == 4 then
			--第4列结束
			if longX5 then
				SlotsEffect.PlayScrollItemLong(x + 1,2)
			end
			SlotsEffect.StopScrollItemLong(x,2)
		elseif x == 5 then
			--第5列结束
			SlotsEffect.StopScrollItemLong(x,2)
		end
	end
	return longX4,longX5,longFunc
end

local scrollItemObjMap	--初始转动的ItemObj
local scrollItemDataMap	--转动完成时的Item数据
local scrollRateDataMap	--转动完成时的Rate数据
local scrollCompleteCallback --转动完成时的回调

function M.SkipScroll(itemDataMap,rateMap,game,callback)
	scrollItemDataMap = itemDataMap
	scrollRateDataMap = rateMap or {}

	local function getItemDEffectTime()
        local _t = 0
        local itemDMap = SlotsLib.GetItemMap(itemDataMap,{D = "D"})
        local maxX
        for x = 1, SlotsModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            _t = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldLightBack) + SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFly) + SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFlyFront)
        end
        return _t
    end

	local itemDeffectTime = getItemDEffectTime()

	scrollCompleteCallback = function ()
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsHelper.GetSeq()
			seq:InsertCallback(itemDeffectTime,function ()
				if callback then
					callback()
				end
			end)
		else
			if callback then
				callback()
			end
		end
		SlotsEffect.StopScrollItemLong(4,2)
		SlotsEffect.StopScrollItemLong(5,2)
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_down.audio_name)
	end

	for x,_v in pairs(scrollItemObjMap) do
		for y,v in pairs(_v) do
			v.endCallback = function ()
				SlotsEffect.StopScrollItemLong(4,2)
				SlotsEffect.StopScrollItemLong(5,2)
			end

			if v.status == SpeedStatus.speedUniform then
				v.status = SpeedStatus.speedDown
			elseif v.status == SpeedStatus.speedUp then
				v.upCallback = function ()
					v.obj.icon_img.material = nil
					v.status = SpeedStatus.speedDown
				end
			end
		end
	end
end

function M.StopScroll(itemDataMap,rateMap,game,callback,times,endCallback)
	scrollItemDataMap = itemDataMap
	scrollRateDataMap = rateMap or {}

	local longX4,longX5,longFunc = GetLongData(itemDataMap,game)

	local t = SlotsModel.GetTime(times.scrollSpeedDownInterval)
	local addT = SlotsModel.GetTime(times.scrollSpeedUniformAddTime)

	local function getAT(x)
		local at = 0
		if x == 4 and longX4 then
			at = addT
		end
		if x == 5 then
			if longX4 then
				at = addT
			end
			if longX5 then
				at = at + addT
			end
		end
		return at
	end

	local function getItemDEffectTime()
        local _t = 0
        local itemDMap = SlotsLib.GetItemMap(itemDataMap,{D = "D"})
        local maxX
        for x = 1, SlotsModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            local flyTime = SlotsModel.GetTime(SlotsModel.time.effectItemDGoldLightBack) + SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFly) + SlotsModel.GetTime(SlotsModel.time.effectItemDGoldFlyFront)
			local at = getAT(maxX)
			local downTime = t * (maxX - 1) + at + SlotsModel.GetTime(times.scrollSpeedDownTime)
			local allDownTime = t * (SlotsModel.size.xMax - 1) + at + SlotsModel.GetTime(times.scrollSpeedDownTime)
			_t = downTime + flyTime - allDownTime
			if _t < 0 then
				_t = 0
			end
        end
        return _t
    end

	local itemDeffectTime = getItemDEffectTime()

	scrollCompleteCallback = function ()
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsHelper.GetSeq()
			seq:InsertCallback(itemDeffectTime,function ()
				if callback then
					callback()
				end
			end)
		else
			if callback then
				callback()
			end
		end
		SlotsEffect.StopScrollItemLong(4,2)
		SlotsEffect.StopScrollItemLong(5,2)
	end

	--加速
	local seqSpeedUp = SlotsHelper.GetSeq()
	for x=1,#scrollItemObjMap do
		local at = getAT(x)
		seqSpeedUp:InsertCallback(t * (x - 1) + at,function ()
			if scrollItemObjMap[x] then
				for y=1,#scrollItemObjMap[x] do
					local v = scrollItemObjMap[x][y]
					v.status = SpeedStatus.speedDown
					v.endCallback = function ()
						if longFunc then
							longFunc(x,y,longX4,longX5)
						end
						if endCallback then
							endCallback(v)
						end
						--滚动结束
						if v.y == 1 then
							ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_down.audio_name)
						end
					end
				end
			end
		end)
	end
end

function M.StartScroll(itemMap,game,times,parent)
	scrollItemObjMap = {}
	scrollItemDataMap = {}	--转动完成时的Item数据
	scrollRateDataMap = {}	--转动完成时的Rate数据
	scrollCompleteCallback = nil --转动完成时的回调

	local xMax = SlotsModel.size.xMax
	local yMax = SlotsModel.size.yMax
	local spacing = SlotsModel.size.ySize + SlotsModel.size.ySpac
	local endCount = 0
	local yAddCount = SlotsModel.size.yMax
	local allCount = xMax * (yMax + yAddCount)

	for x=1,xMax do
		scrollItemObjMap[x] = scrollItemObjMap[x] or {}
		for y=1,yMax + yAddCount do
			if itemMap[x] and itemMap[x][y] then
				scrollItemObjMap[x][y] = {obj = itemMap[x][y]}
			else
				scrollItemObjMap[x][y] = {obj = SlotsItem.Create({id = SlotsLib.GetItemIdByIndex(math.random(1,#SlotsLib.GetItemEnum())),x = x,y = y,parent = parent})}
			end
		end
	end
	
	local changeObj = function (v)
		if v.obj.transform.localPosition.y <= -spacing then
			if v.status == SpeedStatus.speedUp then
				v.obj.transform.localPosition = SlotsLib.GetPositionByPos(v.obj.data.x,v.obj.data.y + yAddCount)
			else
				v.obj.transform.localPosition = SlotsLib.GetPositionByPos(v.obj.data.x,yMax + yAddCount)
			end
			local _id =SlotsLib.GetItemIdByIndex(math.random(1,#SlotsLib.GetItemEnum()))
			v.obj.icon_img.sprite = SlotsHelper.GetTexture("item" .. _id)
		end
	end

	local speedUniform
	local speedUp
	local speedDown

	local function call(v)
		if not v.obj or not v.obj.transform or not IsEquals(v.obj.transform) then return end
		if v.status == SpeedStatus.speedUp then
			if game == "mini1" then
				v.obj.icon_img.material = GetMaterial("FrontBlurImageBlue")
			else
				v.obj.icon_img.material = GetMaterial("FrontBlur")
			end
			changeObj(v)
			if v.upCallback and type(v.upCallback) == "function" then v.upCallback() end
		elseif v.status == SpeedStatus.speedDown then
			v.obj.icon_img.material = nil
			changeObj(v)
		elseif v.status == SpeedStatus.speedUniform then
			changeObj(v)
			if v.uniformCallback and type(v.uniformCallback) == "function" then v.uniformCallback() end
		elseif v.status == SpeedStatus.speedEnd then
			v.obj.icon_img.material = nil
			if v.endCallback and type(v.endCallback) == "function" then v.endCallback() end
			endCount = endCount + 1
			if endCount == allCount then
				--更新现有元素数据
				scrollItemObjMap = {}
				if scrollCompleteCallback and type(scrollCompleteCallback)== "function" then
					scrollCompleteCallback()
				end
				scrollCompleteCallback = nil
			end
		end
		if v.status == SpeedStatus.speedUp then
			v.status = SpeedStatus.speedUniform --加速完成进入匀速状态
		end
		if v.status == SpeedStatus.speedUniform then
			speedUniform(v)
		elseif v.status == SpeedStatus.speedUp then
			speedUp(v)
		elseif v.status == SpeedStatus.speedDown then
			speedDown(v)
		end
	end

	speedUp = function (v)
		v.status = SpeedStatus.speedUp
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.transform.localPosition.y - spacing * yAddCount
		seq:Append(v.obj.transform:DOLocalMoveY(t_y, SlotsModel.GetTime(times.scrollSpeedUpTime)))
		seq:SetEase(Enum.Ease.InCirc)
		seq:OnComplete(function ()
			call(v)
		end)
	end

	speedUniform = function  (v)
		v.status = SpeedStatus.speedUniform
		local seq = DoTweenSequence.Create()
		v.obj:SetRateTxt("")
		local t_y = v.obj.transform.localPosition.y - spacing
		seq:Append(v.obj.transform:DOLocalMoveY(t_y, SlotsModel.GetTime(times.scrollSpeedUniformOneTime)))
		seq:SetEase(Enum.Ease.Linear)
		seq:OnComplete(function ()
			call(v)
		end)
	end

	speedDown = function  (v)
		v.status = SpeedStatus.speedDown
		local pos = SlotsLib.GetPosByPosition(v.obj.transform.localPosition.x,v.obj.transform.localPosition.y)
		if pos.y > yMax then
			local x = pos.x
			local y = pos.y - yAddCount
			v.obj:SetPos(x,y)
			local id = scrollItemDataMap[x][y]
			v.obj:SetId(id)
			local rate = scrollRateDataMap[x] and scrollRateDataMap[x][y]
			v.obj:SetRate(rate)
			v.id = id
			v.x = x
			v.y = y

			itemMap[x][y] = v.obj

			if game == "main" and id == "D" then
				v.endCallback = function ()
					SlotsEffect.PlayItemDGoldByXY(x,y)
				end
			end
		else
			v.endCallback = function ()
				v.obj:Exit()
			end
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.transform.localPosition.y - spacing * yAddCount
		seq:Append(v.obj.transform:DOLocalMoveY(t_y - 40, SlotsModel.GetTime(times.scrollSpeedDownTime)):SetEase(Enum.Ease.OutCirc))
		seq:Append(v.obj.transform:DOLocalMoveY(t_y, SlotsModel.GetTime(times.scrollSpeedDownTime / 4)):SetEase(Enum.Ease.InCirc))
		seq:OnComplete(function ()
			v.status = SpeedStatus.speedEnd
			call(v)
		end)
	end

	local t = SlotsModel.GetTime(times.scrollSpeedUpInterval)
	--加速
	local seqSpeedUp = SlotsHelper.GetSeq()
	for x=1,xMax do
		seqSpeedUp:InsertCallback(t * (x - 1),function ()
			for y=1,yMax + yAddCount do
				speedUp(scrollItemObjMap[x][y])
			end
		end)
	end
end
