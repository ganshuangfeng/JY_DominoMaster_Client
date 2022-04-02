-- 创建时间:2019-03-19
local basefunc = require "Game.Common.basefunc"
ScrollAnimation = basefunc.class()
local M = ScrollAnimation

local SpeedStatus = {
	speedUp = "speedUp",
	speedUniform = "speedUniform",
	speedDown = "speedDown",
	speedEnd = "speedEnd",
}

local CallFunc = function (func,...)
	if not func or type(func) ~= "function" then
		return
	end
	func(...)
end

local AddFunc = function (oldfunc,newfunc)
	return function (...)
		CallFunc(oldfunc,...)
		CallFunc(newfunc,...)
	end
end

function M.Create()
	return M.New()
end

function M:ctor()
	ExtPanel.ExtMsg(self)
end

function M:MyExit()
	self:ExitDoTweens()
    ClearTable(self)
end


function M:GetSeq()
    local seq = DoTweenSequence.Create()
	self.DoTweens = self.DoTweens or {}
    self.DoTweens[seq] = seq
    return seq
end

function M:KillSeq(seq)
    if not seq then
        return
    end
	self.DoTweens = self.DoTweens or {}
    self.DoTweens[seq] = nil
    seq:Kill()
    seq = nil
end

function M:Complete(seq)
    if not seq then
        return
    end
    self.DoTweens = self.DoTweens or {}
    self.DoTweens[seq] = nil
    if not seq:IsComplete() then
        seq:Complete()
    end
    seq = nil
end

function M:CheckSeq(seq)
    if not seq or not self.DoTweens or not self.DoTweens[seq] then
        return false
    end
    return true
end

function M:AddTween(tween)
    self.DoTweens[tween] = tween
end

function M:SubTween(tween)
    if not M:CheckSeq(tween) then
        return
    end
    self.DoTweens[tween] = nil
end

function M:ExitDoTweens()
	for k, v in pairs(self.DoTweens or {}) do
		v:Kill()
	end
	self.DoTweens = {}
end

--设置数据
function M:SetData(data)
	self.parent = data.parent
	self.times = data.times
	self.size = data.size

	self.xMax = self.size.xMax
	self.yMax = self.size.yMax
	self.yDownOut = data.yDownOut or 0
	self.yOffset = data.yOffset or 0
	self.spacing = self.size.ySize + self.size.ySpac
	self.endCount = 0
	self.yAddCount = self.size.yMax
	self.allCount = self.xMax * (self.yMax + self.yAddCount)
	self.itemMap = data.itemMap
	self.itemDataMap = {}	--转动完成时的Item数据
end

--设置外部方法
function M:SetFunc(data)
	--外部对Obj的操作
	self.GetTime = data.GetTime
	self.GetItemId = data.GetItemId --SlotsLionLib.GetItemIdByIndex(math.random(1,#SlotsLionLib.GetItemEnum()))
	self.CreateItem = data.CreateItem --SlotsLionItem.Create({id = SlotsLionLib.GetItemIdByIndex(math.random(1,#SlotsLionLib.GetItemEnum())),x = x,y = y,parent = parent})
	self.GetPositionByPos = data.GetPositionByPos
	self.GetPosByPosition = data.GetPosByPosition
	self.GetTextureNameById = data.GetTextureNameById
	self.SetTexture = data.SetTexture
	self.SetMaterial = data.SetMaterial
	self.GetLocalPosition = data.GetLocalPosition
	self.SetLocalPosition = data.SetLocalPosition
	self.GetTransform = data.GetTransform
	self.SetId = data.SetId
	self.SetPos = data.SetPos
	self.ExitObj = data.ExitObj

	--回调的外部方法
	self.UpCallfrontExt = data.UpCallfront
	self.UpCallbackExt = data.UpCallback
	self.UniformCallfrontExt = data.UniformCallfront
	self.UniformCallbackExt = data.UniformCallback
	self.DownCallfrontExt = data.DownCallfront
	self.DownCallbackExt = data.DownCallback
	self.EndCallbackExt = data.EndCallback
	self.CompleteCallbackExt = data.CompleteCallback
	self.ChangeObjExt = data.ChangeObj
end

--设置一些回调
function M:SetCall()
	self.UpCallfront = function (v)
		CallFunc(self.UpCallfrontExt,v.obj)
	end
	self.UpCallback = function (v)
		CallFunc(self.SetMaterial,v.obj,GetMaterial("FrontBlur"))
		CallFunc(self.UpCallbackExt,v.obj)
	end
	self.UniformCallfront = function (v)
		CallFunc(self.UniformCallfrontExt,v.obj)
	end
	self.UniformCallback = function (v)
		CallFunc(self.UniformCallbackExt,v.obj)
	end
	self.DownCallfront = function (v)
		local lp = self.GetLocalPosition(v.obj)
		local pos = self.GetPosByPosition(lp.x,lp.y)
		if pos.y > self.yMax then
			local x = pos.x
			local y = pos.y - self.yAddCount
			local id = self.itemDataMap[x][y]
			v.id = id
			v.x = x
			v.y = y
			self.itemMap[x][y] = v.obj
			v.isExit = false
		else
			v.isExit = true
		end
		self.SetId(v.obj,v.id)
		self.SetPos(v.obj,v.x,v.y)
		CallFunc(self.DownCallfrontExt,v.obj,v.x,v.y,v.id)
	end
	self.DownCallback = function (v)
		CallFunc(self.SetMaterial,v.obj,nil)
		CallFunc(self.DownCallbackExt)
	end
	self.EndCallback = function (v)
		CallFunc(self.SetMaterial,v.obj,nil)
		if v.isExit then
			CallFunc(self.ExitObj,v.obj)
			return
		end
		CallFunc(self.EndCallbackExt,v,self.itemDataMap)
	end
	--所有转动完成时的回调
	self.CompleteCallback = function ()
		self.endCount = self.endCount + 1
		if self.endCount == self.allCount then
			--更新现有元素数据
			self.itemObjMap = {}
			CallFunc(self.CompleteCallbackExt)
		end
	end

	self.ChangeObj = function (v)
		local id = self.GetItemId()
		CallFunc(self.SetId,v.obj,id)
		CallFunc(self.SetPos,v.obj,v.x,v.y)
		CallFunc(self.SetTexture,v.obj,self.GetTextureNameById(id))
		CallFunc(self.ChangeObjExt,v.obj)
	end
end

--初始化要运动的元素
function M:InitItemObjMap()
	self.itemObjMap = {} --初始转动的ItemObj
	for x=1,self.xMax do
		self.itemObjMap[x] = self.itemObjMap[x] or {}
		for y=1,self.yMax + self.yAddCount do
			if self.itemMap and self.itemMap[x] and self.itemMap[x][y] then
				self.itemObjMap[x][y] = {obj = self.itemMap[x][y], x = x, y = y}
				self.itemObjMap[x][y].id = self.itemObjMap[x][y].obj.data.id
			else
				self.itemObjMap[x][y] = {obj = self.CreateItem({id = self.GetItemId(), x = x, y =y,parent = self.parent}), x = x, y = y}
				self.itemObjMap[x][y].id = self.itemObjMap[x][y].obj.data.id
			end
		end
	end
end

function M:ClearItemObjMap()
	for x=1,#self.itemObjMap do
		for y=1,#self.itemObjMap[x] do
			CallFunc(self.ExitObj,self.itemObjMap[x][y].obj)
		end
	end
	self.itemObjMap = nil
end

--运动中需要改变元素
function M:SeppdChangeObj(v)
	local localPosition = self.GetLocalPosition(v.obj)
	if localPosition.y <= -self.spacing then
		if v.status == SpeedStatus.speedUp then
			self.SetLocalPosition(v.obj, self.GetPositionByPos(v.x, v.y + self.yAddCount))
		else
			self.SetLocalPosition(v.obj, self.GetPositionByPos(v.x, self.yMax + self.yAddCount))
		end
		self.ChangeObj(v)
	end
end

--一次运动回调
function M:SpeedCall(v)
	if not v.obj then return end
		local transform = self.GetTransform(v.obj)
		if not transform or not IsEquals(transform) then
			return
		end

		if v.status == SpeedStatus.speedUp then
			self:SeppdChangeObj(v)
			self.UpCallback(v)
		elseif v.status == SpeedStatus.speedDown then
			self:SeppdChangeObj(v)
			self.DownCallback(v)
		elseif v.status == SpeedStatus.speedUniform then
			self:SeppdChangeObj(v)
			self.UniformCallback(v)
		elseif v.status == SpeedStatus.speedEnd then
			self.EndCallback(v)
			self.CompleteCallback()
		end
		if v.status == SpeedStatus.speedUp then
			v.status = SpeedStatus.speedUniform --加速完成进入匀速状态
		end
		if v.status == SpeedStatus.speedUniform then
			self:SpeedUniform(v)
		elseif v.status == SpeedStatus.speedUp then
			self:SpeedUp(v)
		elseif v.status == SpeedStatus.speedDown then
			self:SpeedDown(v)
		end
end

--加速运动
function M:SpeedUp(v)
	v.status = SpeedStatus.speedUp
	self.UpCallfront(v)
	local seq = self:GetSeq()
	local transform = self.GetTransform(v.obj)
	local t_y = transform.localPosition.y - self.spacing * self.yAddCount
	seq:Append(transform:DOLocalMoveY(t_y, self.GetTime(self.times.scrollSpeedUpTime)))
	seq:SetEase(Enum.Ease.InCirc)
	seq:OnComplete(function ()
		self:SpeedCall(v)
	end)
end

--匀速运动
function M:SpeedUniform(v)
	v.status = SpeedStatus.speedUniform
	self.UniformCallfront(v)
	local seq = self:GetSeq()
	local transform = self.GetTransform(v.obj)
	local t_y = transform.localPosition.y - self.spacing
	seq:Append(transform:DOLocalMoveY(t_y, self.GetTime(self.times.scrollSpeedUniformOneTime)))
	seq:SetEase(Enum.Ease.Linear)
	seq:OnComplete(function ()
		self:SpeedCall(v)
	end)
end

--减速运动
function M:SpeedDown(v)
	v.status = SpeedStatus.speedDown
	self.DownCallfront(v)
	local seq = self:GetSeq()
	local transform = self.GetTransform(v.obj)
	local t_y = transform.localPosition.y - self.spacing * self.yAddCount + self.yOffset
	seq:Append(transform:DOLocalMoveY(t_y - self.yDownOut, self.GetTime(self.times.scrollSpeedDownTime)):SetEase(Enum.Ease.OutCirc))
	seq:Append(transform:DOLocalMoveY(t_y, self.GetTime(self.times.scrollSpeedDownTime / 4)):SetEase(Enum.Ease.InCirc))
	seq:OnComplete(function ()
		v.status = SpeedStatus.speedEnd
		self:SpeedCall(v)
	end)
end


--[[data = {
	--数据
	itemDataMap, 转动后的item数据

	--方法
	DownCallfront, 减速前的回调
	DownCallback, 减速后的回调
	EndCallback, 一个item滚动完成的回调
	CompleteCallback, 所有item滚动完成回调
}
--]]
function M:SkipScroll(data)
	self.yOffset = data.yOffset or self.yOffset
	self.itemDataMap = data.itemDataMap
	self.DownCallfrontExt = AddFunc(self.DownCallfrontExt,data.DownCallfront)
	self.DownCallbackExt = AddFunc(self.DownCallbackExt,data.DownCallback)
	self.EndCallbackExt = AddFunc(self.EndCallbackExt,data.EndCallback)
	self.CompleteCallbackExt = AddFunc(self.CompleteCallbackExt,data.CompleteCallback)

	for x,_v in pairs(self.itemObjMap) do
		for y,v in pairs(_v) do
			if v.status == SpeedStatus.speedUniform then
				v.status = SpeedStatus.speedDown
			elseif v.status == SpeedStatus.speedUp then
				self.UpCallback = self.UpCallback or function ()end
				self.UpCallback = AddFunc(self.UpCallback,function ()
					v.obj.icon_img.material = nil
					v.status = SpeedStatus.speedDown
				end)
			end
		end
	end
end

--[[data = {
	--数据
	itemDataMap, 转动后的item数据

	--方法
	DownCallfront, 减速前的回调
	DownCallback, 减速后的回调
	EndCallback, 一个item滚动完成的回调
	CompleteCallback, 所有item滚动完成回调
	GetAddTime, 特殊情况下增加某一列滚动时间
}
--]]

function M:StopScroll(data)
	self.yOffset = data.yOffset or self.yOffset
	self.itemDataMap = data.itemDataMap
	self.DownCallfrontExt = AddFunc(self.DownCallfrontExt,data.DownCallfront)
	self.DownCallbackExt = AddFunc(self.DownCallbackExt,data.DownCallback)
	self.EndCallbackExt = AddFunc(self.EndCallbackExt,data.EndCallback)
	self.CompleteCallbackExt = AddFunc(self.CompleteCallbackExt,data.CompleteCallback)
	
	self.GetAddTime = data.GetAddTime or function ()
		return 0
	end
	local t = self.GetTime(self.times.scrollSpeedDownInterval)
	local seq = self:GetSeq()
	for x=1,#self.itemObjMap do
		local at = self.GetAddTime(x)
		seq:InsertCallback(t * (x - 1) + at,function ()
			if self.itemObjMap[x] then
				for y=1,#self.itemObjMap[x] do
					local v = self.itemObjMap[x][y]
					v.status = SpeedStatus.speedDown
				end
			end
		end)
	end
end

--[[data = {
	--数据
	itemMap, 需要转动的item
	parent, 父节点
	times = { 时间
		scrollSpeedUpTime, 加速时间
		scrollSpeedUpInterval, 加速间隔
		scrollSpeedUniformOneTime, 匀速时间
		scrollSpeedDownTime, 减速时间
		scrollSpeedDownInterval, 减速间隔
	},
	size = { 尺寸
		xMax, item x 方向上的最大值
		yMax, item y 方向上的最大值
		xSize, 一个item x 的大小
		ySize, 一个item y 的大小
		xSpac, item x 方向上的间隔
		ySpac, item y 方向上的间隔
	},
	yDownOut, y方向上滚动结束回弹距离

	--方法
	GetTime, 获取时间
	GetItemId, 随机获取一个item的id
	CreateItem, 创建一个Item
	GetPosByPosition, 获取item的x,y位置
	GetPositionByPos, 根据x,y索引获取坐标
	GetTextureNameById, 根据id获取到纹理名字
	SetTexture, 设置item上icon的纹理
	SetMaterial, 设置item上icon的材质
	GetLocalPosition, 获取item的localPosition
	SetLocalPosition, 设置item的localPosition
	GetTransform, 获取item的transform
	SetId, item的SetId方法
	SetPos, item的SetPos方法
	ExitObj, item的退出方法

	UpCallfront, 加速前的回调
	UpCallback,  加速后的回调
	UniformCallfront, 匀速前的回调
	UniformCallback, 匀速后的回调
	DownCallfront, 减速前的回调
	DownCallback, 减速后的回调
	EndCallback, 一个item滚动完成的回调
	CompleteCallback, 所有item滚动完成回调
	ChangeObj, 一个item滚动到最后面的地方需要改变icon的回调
}
--]]
function M:StartScroll(data)
	self:SetData(data)
	self:SetFunc(data)
	self:SetCall()
	self:InitItemObjMap()
	local t = self.GetTime(self.times.scrollSpeedUpInterval)
	--加速
	local seq = self:GetSeq()
	for x=1,self.xMax do
		seq:InsertCallback(t * (x - 1),function ()
			for y=1,self.yMax + self.yAddCount do
				self:SpeedUp(self.itemObjMap[x][y])
			end
		end)
	end
end