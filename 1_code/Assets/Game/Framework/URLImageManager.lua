
URLImageManager = {}

local C = URLImageManager

local cacheImageList = {}
local headImageCount
local headImageBegin

-- 常量
local headImageCountKey = "headImageCount"
local headImageBeginKey = "headImageBegin"
local headImageNameKey = "headImageName"
local headImageTimeKey = "headImageTime"
local g_headImgValidCount = 1000000
local g_headImgValidDay = 2
local cachePath = Application.persistentDataPath .. "/ImageCache/"

local lister
local function MakeLister()
    lister = {}
    lister["ExitScene"] = C.OnExitScene
end

local function AddMsgListener()
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener()
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
	lister = {}
end

function C.OnExitScene()
	C.UnLoadAllHeadImage()
end

function C.Init()
	if not Directory.Exists(cachePath) then
        Directory.CreateDirectory(cachePath)
    end
	C.headImgChk()
    C.LoadFinishCall = {}
    C.CacheHeadSprite = {}
	MakeLister()
	AddMsgListener()
end

-- 替换转义字符
function C.specializationWXUrl2imgPath(str)
	local iswx = false
	local len = string.len(str)
	local head = "http://wx.qlogo"
	local hlen = string.len(head)
	if (string.sub(str,1,hlen) == head) then
	  iswx = true
	end

	local ret = string.gsub(str,"/","1")
	ret = string.gsub(ret,":","1")

	if (len > 42) then
		ret=string.sub(ret,len-42,-10)
	end

	return ret
end

--调整链接
function C.fixHeadImgUrl(url)
	--判断url是否是微信的
	local iswx = false
	local len = string.len(url)
	local cnt = "wx.qlogo.cn/mmopen/"
	local h = string.find(url,cnt)
	local t = string.find(url,"/%d+$")
	
	if h and t then
	  iswx = true
	end

	if iswx then
		return string.sub(url,1,t) .. "132"
	else
		return url
	end
end

-- URL转文件路劲
function C.getURLFilePath(url)
	return cachePath .. C.specializationWXUrl2imgPath(url)
end

-- 加载完成的回调
function C.loadFinish(image, m_sprite, headURL, key)
    image.sprite = m_sprite
    if key and C.LoadFinishCall[key] then
    	C.LoadFinishCall[key]()
    	C.LoadFinishCall[key] = nil
    end
end
-- 测试网络
local csNet = false
-- 使用WWW下载图片
function C.WWWImage(url, image, finishCall, key, size)
	local fixURL = C.fixHeadImgUrl(url)
	local filePath = C.getURLFilePath(url)
	if not key then
		key = url
	end
	if (key and not finishCall) or (not key and finishCall) then
		print("<color=red>finishCall和Key没有同时为真或假</color>")
	end
	if key then
		C.LoadFinishCall[key] = finishCall
	end
	if not csNet and C.CacheHeadSprite[fixURL] then
		print("<color=#00FFABFF>******image in cache******</color>")
		C.loadFinish(image, C.CacheHeadSprite[fixURL], fixURL, key)
		return
	end

	if not csNet and cacheImageList[filePath] and File.Exists(filePath) then
		if not key then
			if finishCall then
				finishCall()
			end
		end
		coroutine.start(function ( )
			if size then
				C.LoadHeadImage(url, image, key, size)
			else
				C.LoadImage(url, image, key)
			end
		end)
	else
		if size then
			coroutine.start(function ( )
				C.DownloadHeadImage(url, image, key, size)
			end)
		else
			gameMgr:DownloadURLFile(fixURL, filePath, function (path, isDone)
				if isDone then
					C.addHeadImgInfo(fixURL)
					if not key then
						if finishCall then
							finishCall()
						end
					end
					coroutine.start(function ( )
						C.LoadImage(url, image, key)
					end)
				else
					-- print("<color=#00FFABFF>多次下载失败，检查URL fixURL = " .. fixURL .. "</color>")
					if finishCall then
						finishCall()
					end
					if key then
						C.LoadFinishCall[key] = finishCall
					end
				end
			end)
		end
	end
end

function C.UnLoadAllHeadImage()
	if C.CacheHeadSprite and next(C.CacheHeadSprite) then
		for url, v in pairs(C.CacheHeadSprite) do
			GameObject.Destroy(C.CacheHeadSprite[url])
		end
		C.CacheHeadSprite = {}
	end

	if C.CacheHeadTexture and next(C.CacheHeadTexture) then
		for url, v in pairs(C.CacheHeadTexture) do
			GameObject.Destroy(C.CacheHeadTexture[url])
		end
		C.CacheHeadTexture = {}
	end
end

function C.UnLoadHeadImage(url)
	if not url then
		return
	end
	if C.CacheHeadSprite and next(C.CacheHeadSprite) and C.CacheHeadSprite[url] then
		GameObject.Destroy(C.CacheHeadSprite[url])
		C.CacheHeadSprite[url] = nil
	end

	if C.CacheHeadTexture and next(C.CacheHeadTexture) and C.CacheHeadTexture[url] then
		GameObject.Destroy(C.CacheHeadTexture[url])
		C.CacheHeadTexture[url] = nil
	end
end

function C.ScaleTexture(source, targetWidth, targetHeight)
	dump({source.format, Enum.TextureFormat[source.format]}, "<color=red>AAAAAAAAAAAAAAAAA </color>")
    local result = resMgr:CreateTexture2D(targetWidth, targetHeight, 3)
    local rpixels = result:GetPixels(0)
    local incX = (1.0 / targetWidth)
    local incY = (1.0 / targetHeight)
    for px = 0, rpixels.Length - 1 do
        rpixels[px] = source:GetPixelBilinear(incX * (px % targetWidth), incY * (math.floor(px / targetWidth)))
    end
    result:SetPixels(rpixels, 0)
    result:Apply()
    return result
end

-- 下载远程图片
function C.DownloadHeadImage(url, image, key, size)
	print("<color=#00FFABFF>******image in net******</color>")
	local filePath = C.getURLFilePath(url)
	print("<color=#00FFABFF>******image in net******</color>" ..filePath)
    local www = WWW.New(url)

    coroutine.www(www)
    if www.isDone then
	    if not image or image:Equals(nil) then
	    	return
	    end
		
		local ok, arg = xpcall(function ()
			local source = www.texture
			local texture2D
			if size then
				texture2D = C.ScaleTexture(www.texture, size, size)
			else
				texture2D = www.texture
			end
    	    local bytes = ImageConversion.EncodeToPNG(texture2D)
	        File.WriteAllBytes(filePath, bytes)
	        C.addHeadImgInfo(url)

		    local width = www.texture.width
		    local height = www.texture.height
		    local tex2d = resMgr:CreateTexture2D(width, height, 3)
		    www:LoadImageIntoTexture(tex2d)
		    local m_sprite = Sprite.Create(tex2d, Rect.New(0, 0, width, height), Vector2.New(0, 0))
			
		    C.CacheHeadSprite[url] = m_sprite
			C.CacheHeadTexture = C.CacheHeadTexture or {}
			C.CacheHeadTexture[url] = tex2d
		    C.loadFinish(image, m_sprite, url, key)
			tex2d =nil
	    end,
	    function (error)
	    	print("<color=#00FFABFF>net URLImageManager **********</color>")
	    	print(error)
		end)
    else
    	print("<color=#00FFABFF>URLImageManager www Rrror=" .. www.error .. "</color>")
    end
    www:Dispose()
end

-- 加载本地图片
function C.LoadHeadImage(url, image, key, size)
	print("<color=#00FFABFF>******image in file******</color>")
	local filePath = C.getURLFilePath(url)

	-- 直接加载文件
	local tex2d = panelMgr:GetTexture2DFromPath(filePath, size, size)
    local m_sprite = Sprite.Create(tex2d, Rect.New(0, 0, size, size), Vector2.New(0, 0))

    C.CacheHeadSprite[url] = m_sprite
	C.CacheHeadTexture = C.CacheHeadTexture or {}
	C.CacheHeadTexture[url] = tex2d
    C.loadFinish(image, m_sprite, url, key)
	tex2d =nil

end
-- 加载本地图片
function C.LoadImage(url, image, key)
	print("<color=#00FFABFF>******image in file******</color>")
	local filePath = C.getURLFilePath(url)

    local www
	if gameRuntimePlatform == "Ios" then
		www = WWW.New("file://" .. filePath)
	else
		www = WWW.New("file:///" .. filePath)
	end

    coroutine.www(www)
    if www.isDone then
	    if not image or image:Equals(nil) then
	    	return
	    end
		
		local ok, arg = xpcall(function ()
		    local width = www.texture.width
		    local height = www.texture.height
		    if width < 32 and height < 32 then
		    	-- C.loadFinish(image, GetTexture("ty_tx_11"), url, key)
		    	-- return
		    end
			dump({width=width, height=height}, "AAAAAAAAAA")
		    local tex2d = resMgr:CreateTexture2D(width, height, 3)
		    www:LoadImageIntoTexture(tex2d)
		    local m_sprite = Sprite.Create(tex2d, Rect.New(0, 0, width, height), Vector2.New(0, 0))
			
		    C.CacheHeadSprite[url] = m_sprite
			C.CacheHeadTexture = C.CacheHeadTexture or {}
			C.CacheHeadTexture[url] = tex2d
		    C.loadFinish(image, m_sprite, url, key)
			tex2d =nil
	    end,
	    function (error)
	    	print("<color=#00FFABFF>file URLImageManager **********</color>")
	    	print(error)
		end)
    else
    	print("<color=#00FFABFF>URLImageManager www Rrror=" .. www.error .. "</color>")
    end
    www:Dispose()
end

-- 更新玩家头像
function C.UpdateHeadImage(headURL, image, finishCall, key)
	if (headURL == nil) or (headURL == "") then
		image.sprite = GetTexture("com_head")
		if finishCall then
			finishCall()
		end
		return
	end
	C.WWWImage(headURL, image, finishCall, key, 128)
end

-- 更新Web服务器上的图片
function C.UpdateWebImage(url, image, finishCall, key)
	if (url == nil) or (url == "") then
		image.sprite = GetTexture("com_award_icon_money")
		if finishCall then
			finishCall()
		end
		return
	end
	local str = StringHelper.Split(url, ".")
	local _hz = "png"
	if str and #str > 1 then
		local hz = string.lower(str[#str])
		if hz == "jpg" or hz == "png" then
			_hz = hz
		end
	end
	dump(gameMgr:GetRootURL(), "<color=red>AAAAAAAAAAAAAAAAA 11111111111</color>")
	local uu = gameMgr:GetRootURL()
	if uu == "" then
		uu = "http://oss.domino00.com/jydown/Version2020/Update/V5/Domino4/"
	end
	local webURL = uu .. "Resource/" .. url .. "." .. _hz
	C.WWWImage(webURL, image, finishCall, key)
end


function C.deleteFile(fileName)
	if not File.Exists(fileName) then
		return
	end
	File.Delete(fileName)
end
--头像清理
function C.headImgChk()
	cacheImageList = {}
	headImageCount = PlayerPrefs.GetInt(headImageCountKey, 0)
	headImageBegin = PlayerPrefs.GetInt(headImageBeginKey, 1)
	if headImageCount < 1 then return end

	--达最大限度进行清空
	if headImageCount > g_headImgValidCount then
		for i = headImageBegin, headImageCount do
			local name = PlayerPrefs.GetString(headImageNameKey .. i)
			PlayerPrefs.DeleteKey(headImageTimeKey .. i)
			PlayerPrefs.DeleteKey(headImageNameKey .. i)
			C.deleteFile(name)
		end
		headImageBegin = 1
		headImageCount = 0
	end

	local locTime = os.time()
	for i = headImageBegin, headImageCount do
		local time = PlayerPrefs.GetString(headImageTimeKey .. i)
	  	local name = PlayerPrefs.GetString(headImageNameKey .. i)
		if not tonumber(time) then
			return
		end
		time = locTime - tonumber(time)
		if time / (24 * 3600) > g_headImgValidDay then
			C.deleteFile(name)
			PlayerPrefs.DeleteKey(headImageTimeKey .. i)
			PlayerPrefs.DeleteKey(headImageNameKey .. i)
			headImageBegin = i + 1
		else
			cacheImageList[name] = 1
		end
	end

	--相当于已经全部清空了
	if headImageBegin > headImageCount then
		headImageBegin = 1
		headImageCount = 0
	end

	PlayerPrefs.SetInt(headImageCountKey, headImageCount)
	PlayerPrefs.SetInt(headImageBeginKey, headImageBegin)

	PlayerPrefs.Save()
end


-- 缓存本地头像信息
function C.addHeadImgInfo(headURL)
	local headPath = C.getURLFilePath(headURL)

	headImageCount = headImageCount + 1

	PlayerPrefs.SetString(headImageNameKey .. headImageCount, headPath)
	PlayerPrefs.SetString(headImageTimeKey .. headImageCount, os.time() .. "")

	PlayerPrefs.SetInt(headImageCountKey, headImageCount)

	PlayerPrefs.Save()
end
