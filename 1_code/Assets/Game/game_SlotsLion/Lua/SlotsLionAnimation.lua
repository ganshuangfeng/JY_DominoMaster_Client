-- 创建时间:2019-03-19
local basefunc = require "Game.Common.basefunc"
SlotsLionAnimation = {}
local M = SlotsLionAnimation

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
					SlotsLionHelper.KillSeq(tween)
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
	SlotsLionHelper.AddTween(tween)
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

	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_open.audio_name)
	_self.mini_game_1_bggx.gameObject:SetActive(false)
	_self.mini_game_1.gameObject:SetActive(true)
	_self.mini_game_1_bggx.gameObject:SetActive(true)
	mini_game_1_x_img_cg.alpha = 0
	mini_game_1_play_cg.alpha = 0
	mini_game_1_bonus_cg.alpha = 1
	_self.mini_game_1_node.transform.localScale = Vector3.zero

	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1BGChange)
	seq:Append(_self.mini_game_1_node.transform:DOScale(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_tongji.audio_name)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1BonusChangeMax)
	seq:Join(_self.mini_game_1_bonus.transform:DOScale(1.4,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1BonusChangeMin)
	seq:Append(_self.mini_game_1_bonus.transform:DOScale(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1XShow)
	seq:Append(mini_game_1_x_img_cg:DOFade(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1PlayShow)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_tongji.audio_name)
	end)
	seq:Append(mini_game_1_play_cg:DOFade(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1BonusPlayFlyFront)
	seq:AppendInterval(t)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame1BonusPlayFly)
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

	ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_open.audio_name)
	local seq = SlotsLionHelper.GetSeq()
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2BGChange)
	seq:Append(_self.mini_game_2_node.transform:DOScale(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_tongji.audio_name)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2BonusChangeMax)
	seq:Join(_self.mini_game_2_bonus.transform:DOScale(1.4,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2BonusChangeMin)
	seq:Append(_self.mini_game_2_bonus.transform:DOScale(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2XShow)
	seq:Append(mini_game_2_x_img_cg:DOFade(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2PlayShow)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_tongji.audio_name)
	end)
	seq:Append(mini_game_2_play_cg:DOFade(1,t))
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2AddShow)
	seq:Append(mini_game_2_add_img_cg:DOFade(1,t))
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_free_tongji.audio_name)
	end)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2WinShow)
	seq:Append(mini_game_2_win_cg:DOFade(1,t))

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2WinFly + SlotsLionModel.time.clearMiniGame2WinChange)
	seq:AppendCallback(function ()
		local money = SlotsLionGamePanel.Instance.tip_money_txt.text
		local obj = SlotsLionGamePanel.Instance.tip_money_txt
		local awardTxt = _self.mini_game_2_win_txt
		local callback = function ()
			_self.mini_game_2_win_txt.text = money
		end
		SlotsLionEffect.PlayMiniGame2AllRateClearFly(obj,awardTxt,callback)
	end)
	seq:AppendInterval(t)

	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2BonusPlayFlyFront)
	seq:AppendInterval(t)
	local t = SlotsLionModel.GetTime(SlotsLionModel.time.clearMiniGame2BonusPlayFly)
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
function M.SkipScroll(itemDataMap,rateDataMap,game,callback,scrollObj)
	local function getItemAEffectTime()
        local _t = 0
        local itemDMap = SlotsLionLib.GetItemMap(itemDataMap,{A = "A"})
        local maxX
        for x = 1, SlotsLionModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            _t = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldLightBack) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFlyFront)
        end
        return _t
    end
	local itemDeffectTime = getItemAEffectTime()

	local data = {}
	data.itemDataMap = itemDataMap
	data.DownCallfront = function (obj,x,y,id)
	end
	data.DownCallback = nil
	data.EndCallback = function (v)
		
	end
	data.CompleteCallback = function ()
		dump(callback,"<color=yellow>动画完成 callback</color>")
		SlotsLionHelper.StopMini2Scroll({game = game})
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsLionHelper.GetSeq()
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
		SlotsLionEffect.StopScrollItemLong(3,2)
		SlotsLionEffect.StopScrollItemLong(4,2)
		SlotsLionEffect.StopScrollItemLong(5,2)
		ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_down.audio_name)
	end

	scrollObj:StopScroll(data)
end

function M.StopScroll(itemDataMap,rateDataMap,game,callback,times,endCallback,scrollObj)
	local function GetLongData(itemDataMap,game)
		local longX3,longX4,longX5 = SlotsLionLib.CheckLongX345(itemDataMap)
		local longFunc = function (x,y,longX3,longX4,longX5)
			if x == 2 then
				--第三列结束
				if longX3 then
					SlotsLionEffect.PlayScrollItemLong(x + 1,2)
				end
			elseif x == 3 then
				--第三列结束
				if longX4 then
					SlotsLionEffect.PlayScrollItemLong(x + 1,2)
				end
				SlotsLionEffect.StopScrollItemLong(x,2)
			elseif x == 4 then
				--第4列结束
				if longX5 then
					SlotsLionEffect.PlayScrollItemLong(x + 1,2)
				end
				SlotsLionEffect.StopScrollItemLong(x,2)
			elseif x == 5 then
				--第5列结束
				SlotsLionEffect.StopScrollItemLong(x,2)
			end
		end
		return longX3,longX4,longX5,longFunc
	end
	local longX3,longX4,longX5,longFunc = GetLongData(itemDataMap,game)

	local t = SlotsLionModel.GetTime(times.scrollSpeedDownInterval)
	local addT = SlotsLionModel.GetTime(times.scrollSpeedUniformAddTime)

	local function getAT(x)
		local at = 0
		if x == 3 then
			if longX3 then
				at = addT
			end
		end
		if x == 4 then
			if longX3 then
				at = addT
			end
			if longX4 then
				at = at + addT
			end
		end
		if x == 5 then
			if longX3 then
				at = addT
			end
			if longX4 then
				at = at + addT
			end
			if longX5 then
				at = at + addT
			end
		end
		return at
	end

	local function getItemAEffectTime()
        local _t = 0
        local itemDMap = SlotsLionLib.GetItemMap(itemDataMap,{A = "A"})
        local maxX
        for x = 1, SlotsLionModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            local flyTime = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldLightBack) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFlyFront)
			local at = getAT(maxX)
			local downTime = t * (maxX - 1) + at + SlotsLionModel.GetTime(times.scrollSpeedDownTime)
			local allDownTime = t * (SlotsLionModel.size.xMax - 1) + at + SlotsLionModel.GetTime(times.scrollSpeedDownTime)
			_t = downTime + flyTime - allDownTime
			if _t < 0 then
				_t = 0
			end
        end
        return _t
    end

	local itemDeffectTime = getItemAEffectTime()

	local data = {}
	data.itemDataMap = itemDataMap
	data.DownCallfront = function (obj,x,y,id)
		-- local rate = rateDataMap[x] and rateDataMap[x][y]
		-- obj:SetRate(rate)
	end
	data.DownCallback = nil
	data.EndCallback = function (v)
		if longFunc then
			longFunc(v.x,v.y,longX3,longX4,longX5)
		end
		if endCallback then
			endCallback(v)
		end
		local is_had_lion = false
		if v.id == "9" then
			is_had_lion = true
			ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_lion.audio_name)
		end

		local is_had_freespins = false
		if v.id == "A" then
			is_had_freespins = true
			ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_freespins.audio_name)
		end
		--滚动结束
		if v.y == 1 then
			ExtendSoundManager.PlaySound(audio_config.lion.bgm_lion_down.audio_name)
		end
	end
	data.CompleteCallback = function ()
		SlotsLionHelper.StopMini2Scroll({game = game})
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsLionHelper.GetSeq()
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
		SlotsLionEffect.StopScrollItemLong(3,2)
		SlotsLionEffect.StopScrollItemLong(4,2)
		SlotsLionEffect.StopScrollItemLong(5,2)
	end

	data.GetAddTime = getAT
	scrollObj:StopScroll(data)
end

function M.StartScroll(itemMap,game,times,parent,scrollObj)
	local data = {}
	data.itemMap = itemMap
	data.size = SlotsLionModel.size
	data.yDownOut = 40
	data.times = times
	data.parent = parent

	data.GetTime = SlotsLionModel.GetTime
	data.GetItemId = function ()
		return SlotsLionLib.GetItemIdByIndex(math.random(1,#SlotsLionLib.GetItemEnum()))
	end
	data.CreateItem = SlotsLionItem.Create
	data.GetPositionByPos = SlotsLionLib.GetPositionByPos
	data.GetPosByPosition = SlotsLionLib.GetPosByPosition
	data.GetTextureNameById = SlotsLionHelper.GetTextureNameById
	data.SetTexture = function (obj,tex)
		obj.icon_img.sprite = tex
	end
	data.SetMaterial = function (obj,mat)
		obj.icon_img.material = mat
	end
	data.GetLocalPosition = function (obj)
		return obj.transform.localPosition
	end
	data.SetLocalPosition = function (obj,lp)
		obj.transform.localPosition = lp
	end
	data.GetTransform = function (obj)
		return obj.transform
	end
	data.SetId = function (obj,id)
		obj:SetId(id)
	end
	data.SetPos = function (obj,x,y)
		obj:SetPos(x,y)
	end
	data.ExitObj = function (obj)
		obj:Exit()
	end

	data.UpCallfront = nil
	data.UpCallback = nil
	data.UniformCallfront = function (obj)
		obj:SetRateTxt("")
	end
	data.UniformCallback = nil
	data.DownCallfront = nil
	data.DownCallback = nil
	data.EndCallback = nil
	data.CompleteCallback = nil
	data.ChangeObj = nil

	scrollObj:StartScroll(data)
end


function M.SkipScrollMini2(itemDataMap,id,game,callback,scrollObj)
	dump(itemDataMap,"<color=white>小游戏2 ItemDataMap?????????????????</color>")
	local function getItemAEffectTime()
        local _t = 0
        local itemDMap = SlotsLionLib.GetItemMap(itemDataMap,{A = "A"})
        local maxX
        for x = 1, SlotsLionModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            _t = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldLightBack) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFlyFront)
        end
        return _t
    end
	local itemDeffectTime = getItemAEffectTime()
	local data = {}
	data.yOffset = tonumber(id) == 0 and SlotsLionGameMini2Panel.size.yOffset or 0
	data.itemDataMap = itemDataMap
	data.DownCallfront = nil
	data.DownCallback = nil
	data.EndCallback = nil
	data.CompleteCallback = function ()
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsLionHelper.GetSeq()
			seq:InsertCallback(itemDeffectTime,function ()
				if callback then
					callback()
				end
				if tonumber(id) ~= 0 then
					SlotsLionEffect.PlayLionEffect()
				end
			end)
		else
			if callback then
				callback()
			end
			if tonumber(id) ~= 0 then
				SlotsLionEffect.PlayLionEffect()
			end
		end
	end

	scrollObj:StopScroll(data)
end

function M.StopScrollMini2(itemDataMap,id,game,callback,times,endCallback,scrollObj)
	local function GetLongData(itemDataMap,game)
		if game ~= "main" then
			return
		end
	
		local longX4,longX5 = SlotsLionLib.CheckLongX45(itemDataMap)
		return longX4,longX5
	end
	local longX4,longX5 = GetLongData(itemDataMap,game)

	local t = SlotsLionModel.GetTime(times.scrollSpeedDownInterval)
	local addT = SlotsLionModel.GetTime(times.scrollSpeedUniformAddTime)

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

	local function getItemAEffectTime()
        local _t = 0
        local itemDMap = SlotsLionLib.GetItemMap(itemDataMap,{A = "A"})
        local maxX
        for x = 1, SlotsLionModel.size.xMax do
            if itemDMap[x] then
                maxX = x
            end
        end

        if maxX then
            local flyTime = SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldLightBack) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFly) + SlotsLionModel.GetTime(SlotsLionModel.time.effectItemDGoldFlyFront)
			local at = getAT(maxX)
			local downTime = t * (maxX - 1) + at + SlotsLionModel.GetTime(times.scrollSpeedDownTime)
			local allDownTime = t * (SlotsLionModel.size.xMax - 1) + at + SlotsLionModel.GetTime(times.scrollSpeedDownTime)
			_t = downTime + flyTime - allDownTime
			if _t < 0 then
				_t = 0
			end
        end
        return _t
    end

	local itemDeffectTime = getItemAEffectTime()
	local data = {}
	data.yOffset = tonumber(id) == 0 and SlotsLionGameMini2Panel.size.yOffset or 0
	data.itemDataMap = itemDataMap
	data.DownCallfront = nil
	data.DownCallback = nil
	data.EndCallback = function (v)
		if endCallback then
			endCallback(v)
		end
	end
	data.CompleteCallback = function ()
		if itemDeffectTime and itemDeffectTime > 0 then
			local seq = SlotsLionHelper.GetSeq()
			seq:InsertCallback(itemDeffectTime,function ()
				if callback then
					callback()
				end
				if tonumber(id) ~= 0 then
					SlotsLionEffect.PlayLionEffect()
				end
			end)
		else
			if callback then
				callback()
			end
			if tonumber(id) ~= 0 then
				SlotsLionEffect.PlayLionEffect()
			end
		end
	end

	data.GetAddTime = getAT
	scrollObj:StopScroll(data)
end

function M.StartScrollMini2(itemMap,game,times,parent,scrollObj)
	local data = {}
	data.itemMap = itemMap
	data.size = SlotsLionGameMini2Panel.size
	data.yDownOut = 40
	data.times = times
	data.parent = parent

	data.GetTime = SlotsLionModel.GetTime
	data.GetItemId = function ()
		return math.random(1,3)
	end
	data.CreateItem = SlotsLionGameMini2Item.Create
	data.GetPositionByPos = function (x,y)
		return SlotsLionLib.GetPositionByPos(x,y,data.size.xSize,data.size.ySize,data.size.xSpac,data.size.ySpac)
	end
	data.GetPosByPosition = function (x,y)
		return SlotsLionLib.GetPosByPosition(x,y,data.size.xSize,data.size.ySize,data.size.xSpac,data.size.ySpac)
	end
	data.GetTextureNameById = function (id)
		return SlotsLionHelper.GetTextureNameById(id,"Mini2_")
	end
	data.SetTexture = function (obj,tex)
		obj.icon_img.sprite = tex
	end
	data.SetMaterial = function (obj,mat)
		obj.icon_img.material = mat
	end
	data.GetLocalPosition = function (obj)
		return obj.transform.localPosition
	end
	data.SetLocalPosition = function (obj,lp)
		obj.transform.localPosition = lp
	end
	data.GetTransform = function (obj)
		return obj.transform
	end
	data.SetId = function (obj,id)
		obj:SetId(id)
	end
	data.SetPos = function (obj,x,y)
		obj:SetPos(x,y)
	end
	data.ExitObj = function (obj)
		obj:Exit()
	end

	data.UpCallfront = nil
	data.UpCallback = nil
	data.UniformCallfront = nil
	data.UniformCallback = nil
	data.DownCallfront = nil
	data.DownCallback = nil
	data.EndCallback = nil
	data.CompleteCallback = nil
	data.ChangeObj = nil

	scrollObj:StartScroll(data)
end