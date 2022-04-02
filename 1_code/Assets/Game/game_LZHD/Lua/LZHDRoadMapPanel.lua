-- 创建时间:2022-02-10
-- Panel:LZHDRoadMapPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

LZHDRoadMapPanel = basefunc.class()
local C = LZHDRoadMapPanel
C.name = "LZHDRoadMapPanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["game_language_change_msg"] = basefunc.handler(self, self.RefreshLL)
	self.lister["lzhd_add_point"] = basefunc.handler(self,self.on_lzhd_add_point)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)	
	self:RemoveListener()
	self:RemoveListenerGameObject()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.big_sv = self.big_content.parent.parent:GetComponent("ScrollRect")
	self.marker_sv = self.marker_content.parent.parent:GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitLL()
	
	self:AddListenerGameObject()
end

function C:AddListenerGameObject()
    self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
end

function C:RemoveListenerGameObject()
    self.close_btn.onClick:RemoveAllListeners()
end

function C:InitLL()
end

function C:RefreshLL()
end

function C:InitUI()
	self:InitContent()
	self:MyRefresh()
end

function C:MyRefresh()
end
--
function C:InitContent()
	local row = 6
	local col = 80
	local space = 38
	self.big_grid_items = {}
	self.marker_grid_items = {}	

	for r = 1,row do
		for c = 1,col do
			self.big_grid_items[c] = self.big_grid_items[c] or {}
			local obj = GameObject.Instantiate(self.content_grid_item,self.big_content)
			obj.transform.anchoredPosition = Vector3.New((c - 1) * space,-(r - 1) * space,0)
			obj.gameObject:SetActive(true)
			obj.gameObject.name = c.."_"..r
			self.big_grid_items[c][r] = {obj = obj,type = nil}

			self.marker_grid_items[c] = self.marker_grid_items[c] or {}
			local obj = GameObject.Instantiate(self.content_grid_item,self.marker_content)
			obj.transform.anchoredPosition = Vector3.New((c - 1) * space,-(r - 1) * space,0)
			obj.gameObject:SetActive(true)
			obj.gameObject.name = c.."_"..r
			self.marker_grid_items[c][r] = {obj = obj,type = nil}
		end
	end
	dump(self.big_grid_items,"<color=red>格子</color>")
	self:InitBigMap()
	self:InitTopHistory()
	self:InitMarkerRoadUI()
end
--1：龙赢了，2虎赢了，3：平局
--初始化一个BIGMAP
function C:InitBigMap()
	self.big_map_items = self.big_map_items or {}
	self.big_map_lines = self.big_map_lines or {}
	for i = 1,#self.big_map_items do
		destroy(self.big_map_items[i])  
	end
	self.big_map_items = {}
	for i = 1,#self.big_map_lines do
		destroy(self.big_map_lines[i])
	end
	self.big_map_lines = {}
	self.big_content.sizeDelta = {x = 380,y = 234}
	local data = basefunc.deepcopy( LZHDModel.GetHistoryData())
	self:RefreshText(data)

	dump(data,"<color=red> 历史数据 </color>")
	local curr_type = data[1]
	local curr_link = 1

	
	--第一个开始不能是平局，如果是平局那个点特殊处理
	if curr_type == 2 then
		curr_type = 1
		data[1] = 1
		--curr_link = 2
	end
	local cur_col_index = 1
	local line = self:AddLine(cur_col_index,self.big_content)
	self.big_map_lines[#self.big_map_lines+1] = line
	--此时格子向下还是向左走
	local cur_next_type = "down"
	local is_can = function (col,row)
		if row > 6 then
			return false
		end
		if self.big_grid_items[col][row].type then
			return false
		end
		return true
	end
	--如果有上一个格子
	local last_item_pos = {col = 1,row = 0}
	local last_item = nil
	local last_item_color = nil
	for i = 1,#data do
		--当属性是连续的，那么连续的次数加1，否则就清空连续的数量
		if curr_type == data[i] then
			curr_link = curr_link + 1
		else
			curr_link = 1
			--如果发生变化了，但不是平局
			-- if data[i] ~= 2 then
			-- 	cur_col_index = cur_col_index + 1
			-- 	local line = self:AddLine(cur_col_index,self.big_content)
			-- 	self.big_map_lines[#self.big_map_lines+1] = line
			-- end
			-- last_item_pos =  {col = cur_col_index,row = 0}
			-- cur_next_type = "down"

			--当此时的属性已经不一致
			--如果这个颜色和上一个的颜色

			if data[i] ~= 2 and last_item_color ~= data[i] then
				cur_col_index = cur_col_index + 1
				local line = self:AddLine(cur_col_index,self.big_content)
				self.big_map_lines[#self.big_map_lines+1] = line
				last_item_pos =  {col = cur_col_index,row = 0}
			end
			cur_next_type = "down"
		end
		curr_type = data[i]
		local parent = nil
		--如果不是平局，那么就要延续一个格子
		if curr_type ~= 2 then
			local col = last_item_pos.col
			local row = last_item_pos.row
			
			if cur_next_type == "down" then
				local new_row = row + 1
				local is_c = is_can(col,new_row)
				--如果此时不能向下继续运动，那么就转向横向
				if is_c then
					row = new_row
				else
					cur_next_type = "right"
					col = col + 1
				end
				parent = self.big_grid_items[col][row].obj.transform
			else
				col = col + 1
				
				parent = self.big_grid_items[col][row].obj.transform
			end
			last_item_pos = {col = col,row = row}

			local obj = GameObject.Instantiate(self.point2_item,parent)
			obj.transform.anchoredPosition = Vector3.zero
			obj.gameObject:SetActive(true)
			self.big_map_items[#self.big_map_items+1] = obj.gameObject
			if curr_type == 3 then
				obj.transform:Find("@red").gameObject:SetActive(true)
				last_item_color = 3
			else
				obj.transform:Find("@blue").gameObject:SetActive(true)
				last_item_color = 1
			end
			last_item = obj
		else
			if not last_item then
				last_item = GameObject.Instantiate(self.point2_item,parent)
				last_item.transform:Find("@blue").gameObject:SetActive(true)
				last_item.transform.anchoredPosition = Vector3.zero
				last_item.gameObject:SetActive(true)
				self.big_map_items[#self.big_map_items+1] = last_item.gameObject
			end
			local T = last_item.transform:Find("@main_txt")
			T.transform:GetComponent("Text").text = curr_link
			T.gameObject:SetActive(true)
		end
	end
	for i = 1,cur_col_index - 10 do
		self:AddBigMapCol()
	end
	self.big_sv.horizontalNormalizedPosition = 1
end
--增加大路的列数
function C:AddBigMapCol()
	local size = self.big_content.transform.sizeDelta
	self.big_content.transform.sizeDelta = {x = size.x + 38,y = size.y}
end

--增加竖线
function C:AddLine(cur_col_index,parent)
	local obj = GameObject.Instantiate(self.shu1,parent)
	obj.gameObject:SetActive(true)
	obj.transform.anchoredPosition = Vector3.New(38 * cur_col_index,0,0)
	return obj.gameObject
end


--初始化历史数据
function C:InitTopHistory(data)
	if self.history_items then
		for i = 1,#self.history_items do
			destroy(self.history_items[i])
		end
	end

	local data  = data or LZHDModel.GetHistoryData()
	local max = math.min(#data,20)
	self.history_items = {}
	for i = 1,max do
		local obj = self:InitOnePoint(data[#data - i + 1],self["line_node"..max - i + 1])
		self.history_items[max - i + 1] = obj
	end
end

--初始化MarkerRoad
function C:InitMarkerRoadUI()
	local data = LZHDModel.GetHistoryData()
	local curr_col = 1
	local curr_row = 1
	self:AddLine(curr_col,self.marker_content)
	for i = 1,#data do
		if curr_row > 6 then
			curr_row = 1
			curr_col = curr_col + 1
			self:AddLine(curr_col,self.marker_content)
			if curr_col > 10 then
				local size = self.marker_content.transform.sizeDelta
				self.marker_content.transform.sizeDelta = {x = size.x + 38,y = size.y}
			end
		end
		local parent = self.marker_grid_items[curr_col][curr_row].obj.transform
		self:InitOnePoint(data[i],parent)
		curr_row = curr_row + 1
		self.marker_row = curr_row
		self.marker_col = curr_col
		self.marker_sv.horizontalNormalizedPosition = 1
	end
end


--制作一个点
function C:InitOnePoint(type,parent)
	local obj = newObject("LZHDPoint",parent)
	obj.transform.anchoredPosition = Vector3.zero
	obj.gameObject:SetActive(true)
	local IMG = obj.transform:Find("@main_img"):GetComponent("Image")

	if type == 1 then
		IMG.sprite = GetTexture("img_lz_01")
	elseif type == 2 then
		IMG.sprite = GetTexture("img_lz_03")
	else
		IMG.sprite = GetTexture("img_lz_02")
	end
	return obj
end

function C:on_lzhd_add_point(d)
	local win_info = d
	self.win_info_list = self.win_info_list or {}
	self.win_info_list[#self.win_info_list + 1] = win_info
	if win_info == LZHDComparisonEnum.Draw then
		win_info = 2
	elseif win_info == LZHDComparisonEnum.HuWin then
		win_info = 3
	else
		win_info = 1
	end
	local data = LZHDModel.GetHistoryData()

	local func = function ()
		local data = LZHDModel.GetHistoryData()
		self:InitTopHistory(data)
		local tx = newObject("LH_TW_shouji_2",self.history_items[#self.history_items].transform)
		GameObject.Destroy(tx,2)
	end
	func()

	local marker_func = function ()
		local curr_row = self.marker_row
		local curr_col = self.marker_col
		if curr_row > 6 then
			curr_row = 1
			curr_col = curr_col + 1
			self:AddLine(curr_col,self.marker_content)
			if curr_col > 10 then
				local size = self.marker_content.transform.sizeDelta
				self.marker_content.transform.sizeDelta = {x = size.x + 38,y = size.y}
			end
		end
		local parent = self.marker_grid_items[curr_col][curr_row].obj.transform
		self:InitOnePoint(win_info,parent)
		curr_row = curr_row + 1
		self.marker_row = curr_row
		self.marker_col = curr_col
		self.marker_sv.horizontalNormalizedPosition = 1
	end
	marker_func()
	self:InitBigMap(win_info)

	local data = LZHDModel.GetHistoryData()
	self:RefreshPro(data)
end


function C:RefreshText(data)
	local long_win = 0
	local draw = 0
	local hu_win = 0
	for i = 1,math.min(#data,100) do
		if data[i] == 1 then
			long_win = long_win + 1
		elseif data[i] == 2 then
			draw = draw + 1
		else
			hu_win = hu_win + 1
		end
	end

	self.naga_txt.text = "Naga:"..hu_win
	self.Harimau_txt.text = "Harimau:"..long_win
	self.Seri_txt.text = "Seri:"..draw

	self.Road_txt.text = GLL.GetTx(81007)..":"..math.min(#data,100)

	self:RefreshPro(data)
end

function C:RefreshPro(data)
	--下面只统计最近20局
	local long_win = 0
	local draw = 0
	local hu_win = 0
	local max = math.min(#data,20)
	for i = 1,max do
		if data[#data - i + 1] == 1 then
			long_win = long_win + 1
		elseif data[#data - i + 1] == 2 then
			draw = draw + 1
		else
			hu_win = hu_win + 1
		end
	end
	local v = math.floor(long_win * 100/(long_win + hu_win))
	self.long_pro_txt.text = v .."%"
	self.hu_pro_txt.text = (100 - v) .."%"
end