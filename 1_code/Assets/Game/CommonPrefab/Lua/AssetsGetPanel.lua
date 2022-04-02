-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
AssetsGetPanel = basefunc.class()
AssetsGetPanel.name = "AssetsGetPanel"

local instance
function AssetsGetPanel.Create(data,is_force)
	dump(data, "<color=green>AssetsGetPanel 获得物品</color>")
	if not is_force then
		MainModel.asset_change_list = MainModel.asset_change_list or {}
		table.insert(MainModel.asset_change_list,data)	
	end

	if not is_force and (not table_is_null(MainModel.asset_change_list) and #MainModel.asset_change_list > 1 ) then
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
	if instance then
		AssetsGetPanel.Close()
	end
	instance = AssetsGetPanel.New(data)
	Event.Brocast("AssetsGetPanelCreating", data, instance)
	return instance
end

function AssetsGetPanel.Close()
	MainLogic.AssetsGetCallback = nil
	Event.Brocast("AssetsGetPanelClose")
	if instance then
		instance.data = nil
		instance:RemoveListener()
		instance:RemoveListenerGameObject()
		if IsEquals(instance.gameObject) then
			GameObject.Destroy(instance.gameObject)
		end
		instance = nil
	end
end

function AssetsGetPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AssetsGetPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["CloseAssetsPanel"] = basefunc.handler(self, self.OnExitScene)
end

function AssetsGetPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function AssetsGetPanel:ctor(data)
	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv50")
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5")
	end
	if not parent then
		parent = GameObject.Find("Canvas")
	end
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(AssetsGetPanel.name, parent.transform)
	self.gameObject = obj
	self.transform = obj.transform

	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	self:InitRect()

	DOTweenManager.OpenPopupUIAnim(self.root.transform)
	self:AddListenerGameObject()
end

function AssetsGetPanel:AddListenerGameObject()
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if MainLogic.AssetsGetCallback then
			MainLogic.AssetsGetCallback ()
		end
		Event.Brocast("AssetsGetPanelConfirmCallback",self.data)

		local waitFrame = false
		if self.data then
			local callback = self.data.callback
			if callback ~= nil then
				waitFrame = callback() or true
			end
			self.data.callback = nil
		end
		if waitFrame then
			coroutine.start(function ()
				Yield(0)
				AssetsGetPanel.Close()
			end)
		else
			AssetsGetPanel.Close()
		end

		if not table_is_null(MainModel.asset_change_list) then
			table.remove( MainModel.asset_change_list,1)
			if not table_is_null(MainModel.asset_change_list[1]) then
				AssetsGetPanel.Create(MainModel.asset_change_list[1],true)
			end
		end
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.BG_btn.onClick:AddListener(func_back)
	self.back_btn.onClick:AddListener(func_back)
end

function AssetsGetPanel:RemoveListenerGameObject()
	self.confirm_btn.onClick:RemoveAllListeners()
	self.BG_btn.onClick:RemoveAllListeners()
	self.back_btn.onClick:RemoveAllListeners()
end

function AssetsGetPanel:InitRect()

	local data = self.data.data
	local skip_data = self.data.skip_data or false
	if not skip_data then
		data = AwardManager.GetAssetsList(data)
	end

	self:CloseAwardCell()
	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end

	local animation = self.data.animation or false
	if animation then
		self:AnimationList(self.AwardCellList)
	end

	self:SetStyle()
	self:SetDesc(self.data.desc)
end

function AssetsGetPanel:SetStyle()
	if self.data.change_type == "broke_subsidy" then
		self.title_img.sprite = GetTexture("tc_title_jjj_01")
	else
		self.title_img.sprite = GetTexture("tc_title_jjj_02")
	end
end

function AssetsGetPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function AssetsGetPanel:CreateItem(data)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = "x" .. (data.value or 1)
	if data.desc_extra then
		obj_t.DescExtra_txt.text = data.desc_extra
	else
		obj_t.DescExtra_txt.text = ""
	end
	GetTextureExtend(obj_t.AwardIcon_img, data.image, data.is_local_icon)
	obj_t.NameText_txt.text = data.name or ""
	obj.gameObject:SetActive(true)
	return obj
end

function AssetsGetPanel:OnExitScene()
	MainModel.asset_change_list = {}
	AssetsGetPanel.Close()
end

function AssetsGetPanel:AnimationList(list)
	for k, v in pairs(list) do
		v.gameObject:SetActive(false)
	end

	local interval = 0.5
	local loop = #list

	local cursor = 0
	Timer.New(function()
		cursor = cursor + 1
		local ui = list[cursor]

		local tween1 = ui.transform:DOScale(0.3, 0.3):OnComplete(function()
			if IsEquals(ui.gameObject) then
				ui.gameObject:SetActive(true)
			end
		end)
		local tween2 = ui.transform:DOScale(1.3, 0.3)
		local tween3 = ui.transform:DOScale(1.0, 0.3)
		local seq = DoTweenSequence.Create()
		seq:Append(tween1):Append(tween2):Append(tween3):OnForceKill(function()
			if IsEquals(ui.gameObject) then
				ui.transform.localScale = Vector3.one
				ui.gameObject:SetActive(true)
			end
		end)
	end, interval, loop):Start()
end

function AssetsGetPanel:SetDesc(desc)
	if desc then
		self.desc_txt.text = desc
	else
		self.desc_txt.text = ""
	end
end