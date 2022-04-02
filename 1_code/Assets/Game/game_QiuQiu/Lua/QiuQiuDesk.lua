local basefunc = require "Game/Common/basefunc"

QiuQiuDesk = basefunc.class()
local C = QiuQiuDesk
C.name = "QiuQiuDesk"
local instance
local str2img = {
	["0"] = "qiuqiu_msz_0",
	["1"] = "qiuqiu_msz_1",
	["2"] = "qiuqiu_msz_2",
	["3"] = "qiuqiu_msz_3",
	["4"] = "qiuqiu_msz_4",
	["5"] = "qiuqiu_msz_5",
	["6"] = "qiuqiu_msz_6",
	["7"] = "qiuqiu_msz_7",
	["8"] = "qiuqiu_msz_8",
	["9"] = "qiuqiu_msz_9",
	[","] = "qiuqiu_msz_10",
}

function C.Create(data)
	instance = instance or C.New(data)
	QiuQiuDesk.Instance = instance
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_fast_gameover_msg"] = basefunc.handler(self,self.on_fast_gameover_msg)
	self.lister["DropChipAnimation_Finish"] = basefunc.handler(self,self.on_DropChipAnimation_Finish)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	QiuQiuChip.ClearChipPool()
	instance = nil
	QiuQiuDesk.Instance = nil
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	QiuQiuDesk.Instance = self
	ExtPanel.ExtMsg(self)
	local parent = data.parent
	self.gameObject = newObject(C.name, parent)
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	QiuQiuChip.InitChipPool()
	self:MakeLister()
	self:AddMsgListener()

	self.char_list = {}
	for i = 1,17 do
		if i % 4 ~= 0 then
			self.char_list[i] = "0"
			self["chip"..i.."_img"].sprite = GetTexture(str2img["0"])
		else
			self["chip"..i.."_img"].sprite = GetTexture(str2img[","])
			self.char_list[i] = ","
		end		
	end
end

function C:MyRefresh()
	
end

function C:on_DropChipAnimation_Finish(data)
	self.curr_total_chip = self.curr_total_chip or 0
	if data.value > 0 then
		self.curr_total_chip = self.curr_total_chip + data.value
	end
	self:RefreshNum(self.curr_total_chip)
end

function C:on_fast_gameover_msg()
	self.curr_total_chip = 0
	self:RefreshNum(0)
end

function C:RefreshNum(stake)
	local str = StringHelper.AddPoint(stake)
	local index = 1
	for i = 17,1,-1 do
		if i <= #str then
			local char = string.sub(str,index,index)
		--self["chip"..index.."_img"].sprite = GetTexture(str2img[char])
			self:NumberAnim(self["chip"..i.."_img"],self["chip"..i.."_1_img"],self.char_list[i],char,function ()
				self.char_list[i] = char
			end)
			index = index + 1
		else
			if self.char_list[i] ~= "," then
				local char = "0"
				self:NumberAnim(self["chip"..i.."_img"],self["chip"..i.."_1_img"],self.char_list[i],char,function ()
					self.char_list[i] = char
				end)
			end
		end
	end
end

function C:NumberAnim(Image,Up_Image,curr_str,target_str,backcall)
	if curr_str == "," or target_str == "," then
		return
	end

	if curr_str == target_str then
		return
	end
	local up = 26.39999
	local mid = 0
	local down = -26.39999

	local config = {"0","1","2","3","4","5","6","7","8","9"}
	local find_index = function (str)
		for i = 1,#config do
			if config[i] == str then
				return i
			end
		end
	end

	local curr_index = find_index(curr_str)
	local target_index = find_index(target_str)

	--如果目标值比较小
	if target_index < curr_index then
		target_index = target_index + #config
	end

	local seq = DoTweenSequence.Create()
	for i = curr_index,target_index -1 do
		local index = i
		if index > #config then
			index = index - #config
		end
		local next_index = index + 1
		seq:AppendCallback(
			function ()
				Image.sprite = GetTexture(str2img[config[index]])
				Image.gameObject.transform.localPosition = Vector3.New(Image.gameObject.transform.localPosition.x,mid,0)
				if next_index > #config then
					next_index = next_index - #config
				end
				Up_Image.sprite = GetTexture(str2img[config[next_index]])
				Up_Image.gameObject.transform.localPosition = Vector3.New(Up_Image.gameObject.transform.localPosition.x,up,0)
			end
		)
		seq:Append(Image.gameObject.transform:DOLocalMoveY(down,0.5 / (target_index - curr_index)))
		seq:Join(Up_Image.gameObject.transform:DOLocalMoveY(mid,0.5 / (target_index - curr_index)))
	end

	seq:AppendCallback(
		function ()
			if target_index > #config then
				target_index = target_index - #config
			end
			Image.sprite = GetTexture(str2img[config[target_index]])
			Image.gameObject.transform.localPosition = Vector3.New(Image.gameObject.transform.localPosition.x,mid,0)
			Up_Image.gameObject.transform.localPosition = Vector3.New(Up_Image.gameObject.transform.localPosition.x,up,0)
			if backcall then
				backcall()
			end
		end
	)
end

--通过断线重连得数据刷新
function C:RefreshByAllInfo()
	local Total = QiuQiuModel.GetTotalStake()
	self:RefreshNum(Total)
end