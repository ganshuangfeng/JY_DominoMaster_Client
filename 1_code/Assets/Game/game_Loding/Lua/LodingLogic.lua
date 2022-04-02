-- 创建时间:2018-05-29
package.loaded["Game.game_Loding.Lua.LodingModel"] = nil
require "Game.game_Loding.Lua.LodingModel"

package.loaded["Game.game_Loding.Lua.LodingPanel"] = nil
require "Game.game_Loding.Lua.LodingPanel"

LodingLogic = {}
local this -- 单例
local lodingModel

-- 是不是小的过渡界面
function LodingLogic.Init(parm, cbk, isSmall, tex)
    this = LodingLogic
    this.parm = parm
    this.cbk = cbk

	local sceneName = MainModel.myLocation
	resMgr:LoadSceneSync(sceneName, function(sn)
		print("sceneName:sn", sceneName, sn)
		if string.lower(System.IO.Path.GetFileNameWithoutExtension(sceneName)) ~= string.lower(sn) then return end

		lodingModel = LodingModel.Init()
		if isSmall then
			SmallLodingPanel.Create(tex)
		else
			LodingPanel.Create(tex)
		end
	end)
	LodingLogic.tex = tex
end
-- 场景加载完成，启动游戏Logic
function LodingLogic.LoadSceneFinish( )
	print("loading finish.................................#####################################.....")
	local sceneName = MainModel.myLocation
	resMgr:LoadSceneFinish(sceneName)
	gameMgr:LoadSceneFinish()
	-- coroutine.start(function ( )
 --        -- 下一帧
 --        Yield(0)

		resMgr:LoadSceneLuaBundle(sceneName)
	    local ns = StringHelper.Split(sceneName, "_")
	    if #ns ~= 2 then
	        print("<color=red> Error GotoScene ".. sceneName .. " </color>")
	        return
	    end

	    local layerLv50 = GameObject.Instantiate(GetPrefab("LayerLv50"), GameObject.Find("Canvas").transform)
	    if layerLv50 then
	    	layerLv50.name = "LayerLv50"
	    end

	    if MainModel.UserInfo and MainModel.UserInfo.user_id then
	    	if ns[2] == "Login" then
				MainModel.sound_pattern = nil
	        -- elseif ns[2] == "Fishing" or ns[2] == "FishingHall" then
	            -- MainModel.sound_pattern = "fishing_" .. MainModel.UserInfo.user_id
	        else
	            MainModel.sound_pattern = "hall_" .. MainModel.UserInfo.user_id
	        end
	    else
	    	MainModel.sound_pattern = nil
	    end

	    GameSceneManager.SetScreenOrientation(true)

	    local Canvas1080 = GameObject.Find("Canvas1080")
	    if IsEquals(Canvas1080) then
	    	Canvas1080.transform.position = Vector3.New(3000, 0, 0)
	    end

	    local canvasS = GameObject.Find("Canvas").transform:GetComponent("CanvasScaler")
	    if canvasS then
	    	
	    	canvasS.referenceResolution = GameSceneManager.GetScreenSize(sceneName)
	    	local width = Screen.width
	    	local height = Screen.height
	    	if (GameSceneManager.GameScreenWidth > GameSceneManager.GameScreenHeight and width < height)
	    		or (GameSceneManager.GameScreenWidth < GameSceneManager.GameScreenHeight and width > height) then
				width,height = height,width
	    	end
		    canvasS.matchWidthOrHeight = GameSceneManager.GetScene_MatchWidthOrHeight(width, height)
	    else
	    	print("<color=red>适配策略 Error</color>")
		end

	    local needR = "Game." .. sceneName .. ".Lua.".. ns[2] .. "Logic"
	    package.loaded[needR] = nil
	    MainModel.CurrLogic = require (needR)
	    MainModel.CurrLogic.Init(this.parm)

	    MainModel.cur_myLocation = MainModel.myLocation

	    MainLogic.EnterScene()
	    if this.cbk then
	    	this.cbk()
	    	this.cbk = nil
	    end

		SmallLodingPanel.Close()
		LodingPanel.Close()
		GameObject.Destroy(LodingLogic.tex)
	-- end)
end
function LodingLogic.Exit()
	if this then
		lodingModel.Exit()
		
		this = nil
	end
end
