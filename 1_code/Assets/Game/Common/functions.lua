

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
    if IsEquals(obj) then
	   GameObject.Destroy(obj)
    end
end

function ClearUserData(tbl)
	for k, v in pairs(tbl) do
		if type(v) == "userdata" then
			tbl[k] = nil
		end
	end
end

function destroyChildren(transform,not_destroy)
    if IsEquals(transform) then
    local count = transform.childCount;
    for i=0, count-1, 1 do
        local child = transform:GetChild(i);
        if not not_destroy or not not_destroy[child.name] then
            GameObject.Destroy(child.gameObject)
            end
        end
    end
end

function newObject(prefab_name, parent_transform)
    local go_temp = nil;
    resMgr:LoadPrefab(
        {prefab_name},
        function(objs)
            go_temp = objs[0]
        end
    )
    local go = nil
	if parent_transform ~= nil then
		go = GameObject.Instantiate(go_temp, parent_transform)
		-- 预制体设置锚点的情况下，归零会出现错误；后期需要通过RectTransform尝试能否修正这个问题
		-- go.transform.localScale = Vector3.one;
		-- go.transform.localPosition = Vector3.zero;
	else
		go = GameObject.Instantiate(go_temp)
	end

	go.name  = go_temp.name
	return go
end

function GetPrefab(fileName)
    if type(fileName) == "table" then
        return resMgr:GetPrefabsSync(fileName)
    else
        return resMgr:GetPrefabSync(fileName)
    end
end

function GetTextureExtend(image, fileName, is_local_icon)
    if not is_local_icon or is_local_icon == 1 then
        image.sprite = GetTexture(fileName)
    else
        URLImageManager.UpdateWebImage(fileName, image)
    end
end

function GetTexture(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetTexturesSync(fileName)
    else
        return resMgr:GetTextureSync(fileName)
    end
end

function Get3DTexture(fileName)
    if type(fileName) == "table" then
        return  resMgr:Get3DTexturesSync(fileName)
    else
        return resMgr:Get3DTextureSync(fileName)
    end
end

function GetMaterial(filename)
    return resMgr:GetMaterial(filename)
end

function GetAudio(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetAudiosSync(fileName)
    else
        return resMgr:GetAudioSync(fileName)
    end
end

function GetFont(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetFontsSync(fileName)
    else
        return resMgr:GetFontSync(fileName)
    end
end

function ClipUIParticle(transform)
	local shaderKey1 = "Legacy Shaders/Particles/Additive"
	local shaderKey2 = "Legacy Shaders/Particles/Alpha Blended Premultiply"
	local newShader = UnityEngine.Shader.Find("ParticleMask")
	local function TryChangeShader(material)
		if not material then return end
		if material.shader.name ~= shaderKey1 and material.shader.name ~= shaderKey2 then return end
		local new_material = GameObject.Instantiate(material)
		new_material.shader = newShader
		new_material:SetFloat("_StencilComp", 4)
		new_material:SetFloat("_Stencil", 1)

		return new_material
		--material.shader = newShader
		--material:SetFloat("_StencilComp", 4)
		--material:SetFloat("_Stencil", 1)
	end

	local renderers = transform:GetComponentsInChildren(typeof(UnityEngine.ParticleSystemRenderer), true)
	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]
		local new_material = TryChangeShader(renderer.trailMaterial)
		if new_material ~= nil then renderer.trailMaterial = new_material end
		new_material = TryChangeShader(renderer.sharedMaterial)
		if new_material ~= nil then renderer.sharedMaterial = new_material end
	end

	local newMaterial = GetMaterial("MaskUI")

	local images = transform:GetComponentsInChildren(typeof(UnityEngine.UI.Image), true)
	for i = 0, images.Length - 1 do
		local image = images[i]
		image.material = newMaterial
	end

	local texts = transform:GetComponentsInChildren(typeof(UnityEngine.UI.Text), true)
	for i = 0, texts.Length - 1 do
		local text = texts[i]
		text.material = newMaterial
	end
end

--[[手动关闭界面]]
function closePanel(panel_name)
    panelMgr:ClosePanel(panel_name)
end

--[[
panel_name  界面名称
ab_name     资源所在的ab包名称（需要包含路径/）
callback    创建完成回调函数
is_cache    是否需要缓存界面，频繁开启关闭的可以考虑
]]
function createPanel(onwer,panel_name, callback, is_cache, params)
    panelMgr:CreatePanel(panel_name, callback, is_cache == true , params)
    return onwer
end

--[[
panel_name 界面名称，需要在createPanel时标记is_cache=true的才可以使用
]]
function pushPanel(panel_name)
    createPanel(panel_name);
end

function child(str)
	return transform:FindChild(str);
end

function subGet(childNode, typeName)		
	return child(childNode):GetComponent(typeName);
end

function findPanel(str) 
	local obj = find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua")
end

function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end


function string.utf8len(input)  
    local len  = string.len(input)  
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}  
    while left ~= 0 do  
        local tmp = string.byte(input, -left)  
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i
                break  
            end  
            i = i - 1  
        end  
        cnt = cnt + 1  
    end  
    return cnt  
end

--[[
    objs：资源读取后的对象
    t：存放资源table表
]]
function fill_res_table(objs, t)
    local count = objs.Length
    for i = 0, count - 1, 1 do
        local obj = objs[i]
        t[obj.name] = obj
    end
end

--[[获取表的values]]
function table.values(t)
    local _t = {}
    for k,v in pairs(t) do
        table.insert(_t, v)
    end
    return _t
end

---[[获取表的keys]]
function table.keys( t )
    local keys = {}
    for k, _ in pairs( t ) do
        keys[#keys + 1] = k
    end
    table.sort(keys);
    return keys
end

--[[modelData ：赛场的Modle数据， pSeatNum : 玩家位置
    默认播放男声
]]
function AudioBySex(modelData, pSeatNum)
	if modelData 
		and modelData.data
		and modelData.data.players_info
		and modelData.data.players_info[pSeatNum]
		and modelData.data.players_info[pSeatNum].sex
		and modelData.data.players_info[pSeatNum].sex == 0 then
		return "_0"
	else
		return "_1"
	end
end


--- add by wss
--- 安全的设置transform的属性
function SafaSetTransformPeoperty(node , typePer , value)
    if not IsEquals(node) then
        return
    end

    if not IsEquals(node.transform) then
        return
    end

    local mainKey = typePer
    local secondKey = string.find(typePer , "%.")
    --print("<color=yellow>----------- secondKey: ".. (secondKey or "nil") .." </color>")
    if secondKey then
        mainKey = string.sub(typePer , 1 , secondKey - 1)
        secondKey = string.sub(typePer , secondKey + 1 , -1)
    end
    --print("<color=yellow> ------------- mainKey , secondKey :" .. mainKey .. "---" .. (secondKey or "nil") .. " </color>")
    if not node.transform[mainKey] then
        return
    end

    if secondKey then
        node.transform[mainKey] = Vector3.New( secondKey == "x" and value or node.transform[mainKey].x , 
                                                secondKey == "y" and value or node.transform[mainKey].y ,
                                                    secondKey == "z" and value or node.transform[mainKey].z )
    else
        node.transform[mainKey] = value
    end
end

-- 判断是否 是物品道具或者资产等
function is_asset(_asset_type)
  
    if PLAYER_ASSET_TYPES_SET[_asset_type] then
      return true
    end
  
    if type(_asset_type)=="string" then
      if string.len(_asset_type)>5 and string.sub(_asset_type,1,5) == "prop_" then
        return true
      end
      if string.len(_asset_type)>11 and string.sub(_asset_type,1,11) == "expression_" then
        return true
      end
      if string.len(_asset_type)>8 and string.sub(_asset_type,1,7) == "phrase_" then
        return true
      end
      if string.len(_asset_type)>11 and string.sub(_asset_type,1,11) == "head_frame_" then
        return true
      end
    end
  
    return false
end

--添加 Canvas 组件并设置层级
function AddCanvasAndSetSort(obj, sorting)
    local canvas
    if IsEquals(obj) then
        canvas = obj.gameObject:AddComponent(typeof(UnityEngine.Canvas))
        if sorting and IsEquals(canvas) then
            canvas.overrideSorting = true
            canvas.sortingOrder = sorting
        end
    end
    return canvas
end

--移除 Canvas 组件
function RemoveCanvas(obj)
    if IsEquals(obj) then
        local canvas = obj.gameObject:GetComponent(typeof(UnityEngine.Canvas))
        if IsEquals(canvas) then
            destroy(canvas)
        end
    end
end

function Destroy(obj)
    if IsEquals(obj) then
        GameObject.Destroy(obj)
    end
end

function AdaptLayerParent(defaultLayerName, params)
	local parent = nil
	if params and params.parent and IsEquals(params.parent) then
		parent = params.parent
	else
		parent = GameObject.Find(defaultLayerName).transform
	end
	return parent
end

function save_lua2json(lua_data,file_name,path)
    if not lua_data then
        return
        print("save lua to json : lua_data error")
    end
    if not file_name or type(file_name) ~= "string" then
        print("save lua to json : file_name error")
        return
    end
    if not path or type(path) ~= "string" then 
        print("save lua to json : path error")
        return
    end
    local json_data = lua2json(lua_data)
    if not json_data then
        print("save lua to json : lua 2 json is nil")
        return
    end
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    File.WriteAllText(path .. "/" .. file_name .. ".txt", json_data)
end

function load_json2lua(file_name,path)
    if not file_name or type(file_name) ~= "string" then
        print("load lua to json : file_name error")
        return
    end
    if not path or type(path) ~= "string" then 
        print("load lua to json : path error")
        return
    end

    local file_path = path .. "/" .. file_name .. ".txt"
    if File.Exists(file_path) then
        local json_data = File.ReadAllText(file_path)
        if not json_data then
            print("load lua to json : file is nil")
            return 
        end
        local lua_data = json2lua(json_data)
        if not lua_data then
            print("load lua to json : json 2 lua is nil")
        end

        local function filter(value)
            if type(value) ~= "table" then
                return value
            end
            local copedSet = {}
            local function _copy(src_)
                if type(src_) ~= "userdata" then
                    local ret = {}
                    copedSet[src_] = ret
                    for k, v in pairs(src_) do
                        if type(v) ~= "table" and type(v) ~= "userdata" then
                            ret[k] = v
                        elseif type(v) ~= "userdata" then
                            if copedSet[v] then
                                -- 重复表 仅仅引用
                                ret[k] = copedSet[v]
                            else
                                ret[k] = _copy(v)
                            end
                        end
                    end
                    return ret
                end
            end
            return _copy(value)
        end

        return filter(lua_data)
    else
        print("load lua to json : not find file" .. file_path)
    end
end

function table_is_null (t)
    if t and next(t) then return false end
    return true
end

function ext_require(path)
    --package.loaded[path] = nil
    --return require(path)
    return HotUpdateConfig(path)
end

function HotUpdateConfig(path)
    package.loaded[path] = nil

    local strs = StringHelper.Split(path, ".")
    local cfg = HandleLoadChannelLua(strs[#strs]) or require (path)
    return cfg

    --[[if AppDefine.IsEDITOR() then
        cfg = require (path)
    else
        local strs = StringHelper.Split(path, ".")
        local hot_path = "localconfig/" .. strs[#strs] .. ".lua"
        cfg = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath(hot_path))
        if not cfg then cfg = require (path) end
    end
    return cfg]]--
end

function ext_require_audio(path,config_name)
    if not audio_config then
        audio_config = require "Game.CommonPrefab.Lua.audio_config"
    end
    if audio_config[config_name] then return end
    package.loaded[path] = nil
    local config = require (path)
    audio_config[config_name] = config[config_name]
end

local require = require
local string = string
local table = table

int64.zero = int64.new(0,0)
uint64.zero = uint64.new(0,0)

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

--重新require一个lua文件，替代系统文件。
function reimport(name)
    local package = package
    package.loaded[name] = nil
    package.preload[name] = nil
    return require(name)    
end

--[[
    @desc: 加载嵌入式脚本，如果是独立更新的脚本记得在上面的 alone_channel 中添加对应渠道
    author:{author}
    time:2019-12-09 11:42:23
    --@basic: 基类名字
	--@param: 基类参数（通常是基类自己）
	--@is_alone: 单独更新，不随主包更新
    @return:
]]
function HandleLoadChannelLua(basic, param,is_alone)
    local channel = gameMgr:getMarketChannel()
    local platform = gameMgr:getMarketPlatform()

    local file_path = "Game/Channel/Lua/" .. platform .. "/"
    local file_name = ""

    local function  loadfile()
        local result = reimport(file_name)
        if result and type(result) == "function" then
            return result(param)
        else
            return result
        end        
    end

    file_name = file_path .. basic ..  "_" .. channel
    --渠道有文件
    if (luaMgr:CheckExistFile(file_name)) then
        return loadfile()
    end

    file_name = file_path .. basic .. "_" .. platform
    --平台有文件
    if (luaMgr:CheckExistFile(file_name)) then
        return loadfile()
    end
end

-- 修改特效层级 obj ui层级 调到上层还是下层
function change_renderer(obj, base, isUp)
    if not IsEquals(obj) then
        return
    end
    local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local min = 9999999
    local max = -9999999
    for i = 0, ps.Length - 1 do
        if max < ps[i].sortingOrder then
            max = ps[i].sortingOrder
        end
        if min > ps[i].sortingOrder then
            min = ps[i].sortingOrder
        end
    end
    if isUp then
        max = base - min + 1
    else
        max = base - max - 1
    end

    for i = 0, ps.Length - 1 do
        ps[i].sortingOrder = ps[i].sortingOrder + max
    end
end


function ClearLuaMemory(obj)
    local key = {}
    ClearLua(obj,key)
    key = nil
end

function ClearLua(obj,key)
    if not obj then return end
    if type(obj) ~= "table" then
        obj = nil
        return
    end
    for k,v in pairs(obj) do
        if type(obj[k]) ~= "table" then
            obj[k] = nil
        else
            if key[k] then
                obj[k] = nil
            else
                key[k] = k
                ClearLua(obj[k],key)
            end
        end
    end
end

--当天0点时间戳
function GetTodayTimeStamp()
    local cDateCurrectTime = os.date("*t")
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
    
    return cDateTodayTime
end

local WeekDayTable = {
    [0] = 7,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
}
function GetWeekDay(offset_t)
    offset_t = offset_t or 0
    local week_day = os.date("%w",os.time() + offset_t)
    return WeekDayTable[tonumber(week_day)]
end

function SetTempParm(parm, gotoui, default)
    if not gotoui then
        return
    end
    default = default or "enter"
    parm.gotoui = gotoui[1]
    if #gotoui == 3 then
        parm.goto_type = gotoui[2]
        parm.goto_scene_parm = gotoui[3]
    else
        parm.goto_scene_parm = gotoui[2] or default
    end
end

-- 时间是否在范围内
function CheckTimeInRange(t, beginTime, endTime)
    if (not beginTime or beginTime == -1 or t >= beginTime)
        and (not endTime or endTime == -1 or t <= endTime) then
            return true
    end
    return false
end

-- 图片不存在不给sprite赋值
function SetTextureExtend(image, fileName)
    if GetTexture(fileName) then
        image.sprite = GetTexture(fileName)
    end
end

-- 深度监测
function depth_supervise(tab, desc)
    desc = desc or "||||||||debug="
    local local_tab = {}
    local mt = {
        __index = function (t, k)
            print("[access]" .. desc .. tostring(k))
            print(debug.traceback())
            return local_tab[k]
        end,

        __newindex = function (t, k, v)
            print("[update]" .. desc .. tostring(k) .. "  v=" .. tostring(v))
            print(debug.traceback())
            local_tab[k] = v
            if type(v) == "table" then
                depth_supervise(v)
            end
        end
    }
    setmetatable(tab, mt)
end

--Url转码
function urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--Ur解码
function urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function base_unpack(tt, i)
    i = i or 1
    if tt.n and i <= tt.n then
        return tt[i],base_unpack(tt, i+1)
    else
        return nil
    end
end

function GeneratingVar(transform,lua_table)
	lua_table = lua_table or {}
	local search_func 
	search_func = function(transform)
		if transform then
			local transform_name = transform.gameObject.name
			if string.byte(transform_name) == 64 then
				local table_item = transform
				local var = string.split(transform_name,"_")
				local type_str = var[#var]
				if type_str == "btn" then
					table_item = transform:GetComponent("Button")
				elseif type_str == "img" then
					table_item = transform:GetComponent("Image")
					if not IsEquals(table_item) then
						table_item = transform:GetComponent("SpriteRenderer")
					end
				elseif type_str == "txt" then
					table_item = transform:GetComponent("Text")
					if not IsEquals(table_item) then
						table_item = transform:GetComponent("TMP_Text")
					end
				elseif type_str == "ipf" then
					table_item = transform:GetComponent("InputFiled")
				elseif type_str =="tge" then
					table_item = transform:GetComponent("Toggle")
				elseif type_str =="spr" then
					table_item = transform:GetComponent("SpriteRenderer")
                elseif type_str =="sbar" then
                    table_item = transform:GetComponent("Scrollbar")
                else
                    table_item = transform
				end
				local name = string.sub(transform.name,2)
				lua_table[name] = table_item
			end
			if transform and transform.childCount > 0 then
				for i = 0,transform.childCount - 1  do
					search_func(transform:GetChild(i))
				end
			end
		end
	end

	search_func(transform)
	transform = nil
    search_func = nil
end

function ClearTable(t)
    if not t then return end
    for k,v in pairs(t) do
		t[k] = nil
	end
	t = nil
end

function ClearLuaMemory(obj)
    if not obj then return end
    local key = {}
    ClearLua(obj,key)
    obj = nil
    key = nil
end

function ClearLua(obj,key)
    if not obj then return end
    if type(obj) ~= "table" then
        obj = nil
        return
    end
    for k,v in pairs(obj) do
        if type(obj[k]) ~= "table" then
            obj[k] = nil
        else
            if key[k] then
                -- obj[k] = nil
            else
                key[k] = k
                ClearLua(obj[k],key)
            end
        end
    end
end

function SetLayer(obj,layer)
	if not IsEquals(obj) or not layer then return end

    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
    for i = 0, objs.Length - 1 do
        objs[i].gameObject.layer = LayerMask.NameToLayer(layer)
    end
end

function SetSortingLayer(obj,sorting_layer)
    if not IsEquals(obj) or not sorting_layer then return end

    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        objs[i].sortingLayerID = UnityEngine.SortingLayer.NameToID(sorting_layer)
    end
end

function SetOrderinLayer(obj,sorting_order)
    if not IsEquals(obj) or not sorting_order then return end
    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        objs[i].sortingOrder = sorting_order
    end
end

function ChangeSortingLayer(obj, base, isUp)
    if not IsEquals(obj) then
        return
    end
    local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local min = 9999999
    local max = -9999999
    for i = 0, ps.Length - 1 do
        if max < ps[i].sortingLayerID then
            max = ps[i].sortingLayerID
        end
        if min > ps[i].sortingLayerID then
            min = ps[i].sortingLayerID
        end
    end
    if isUp then
        max = base - min + 1
    else
        max = base - max - 1
    end

    for i = 0, ps.Length - 1 do
        ps[i].sortingLayerID = ps[i].sortingLayerID + max
    end
end

-- 修改特效层级 obj ui层级 调到上层还是下层
function ChangeOrderInLayer(obj, base, isUp)
    if not IsEquals(obj) then
        return
    end
    local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local min = 9999999
    local max = -9999999
    for i = 0, ps.Length - 1 do
        if max < ps[i].sortingOrder then
            max = ps[i].sortingOrder
        end
        if min > ps[i].sortingOrder then
            min = ps[i].sortingOrder
        end
    end
    if isUp then
        max = base - min + 1
    else
        max = base - max - 1
    end

    for i = 0, ps.Length - 1 do
        ps[i].sortingOrder = ps[i].sortingOrder + max
    end
end

-- _type:UnityEngine.Renderer,UnityEngine.UI.Image
function SetSpriteAendererAlpha(obj,a,_type)
    if not IsEquals(obj) then return end
    local colorAlpha = Color.New(255, 255, 255, 255)
    colorAlpha.a = 255 * a
    local objs = obj.gameObject:GetComponentsInChildren(typeof(_type), true)
    for i = 0, objs.Length - 1 do
        objs[i].color = colorAlpha
    end
end

-- _type:UnityEngine.Renderer,UnityEngine.UI.Image
function DOFadeSpriteRender(obj,to,duration,callback,_type)
    local seq = DoTweenSequence.Create()
    local objs = obj.gameObject:GetComponentsInChildren(typeof(_type), true)
    for i = 0, objs.Length - 1 do
        if i == 0 then
            seq:Append(objs[i]:DOFade(to,duration))
        else
            seq:Join(objs[i]:DOFade(to,duration))
        end
    end
    seq:OnForceKill(function ()
        if callback and type(callback) == "function" then
            callback()
        end
    end)
end

function SetHeadImg(head_link,image)
	if tonumber(head_link) then
		image.sprite = GetTexture("ty_touxiang_0"..head_link)
	else
		URLImageManager.UpdateHeadImage(head_link,image)
	end
end

function OmitName(name)
    local r = ""
    if #name > 7 then
        r = string.sub(name,1,1)..string.sub(name,2,2).."**"..string.sub(name,#name-1,#name-1)..string.sub(name,#name,#name)
    else
        return name
    end
    return r
end