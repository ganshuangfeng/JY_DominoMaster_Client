--[[	
	初始化各种公用代码
--]]

CommonManagerInit = {}

-- DataTool
require "Game.Common.Enum"
require "Game.Common.StringHelper"
require "Game.Common.MathExtend"
require "Game.Common.CustomUITool"
require "Game.CommonPrefab.Lua.GameGlobalOnOff"
require "Game.Framework.DOTweenManager"
require "Game.Framework.GameManager"
require "Game.Framework.Network"
require "Game.CommonPrefab.Lua.GameDefine"
require "Game.game_Loding.Lua.LodingLogic"
require "Game.Common.cardID_vertify"
util = require "Game.Common.3rd.cjson.util"
require "Game.Common.3rd.cjson.json2lua"
require "Game.Common.3rd.cjson.lua2json"
ewmTools = require "Game.Common.ewmTools"
require "Game.CommonPrefab.Lua.game_light_config"
require "Game.CommonPrefab.Lua.GameSceneManager"
require "Game.CommonPrefab.Lua.GameTaskManager"
require "Game.CommonPrefab.Lua.GameToolManager"


-- CommonPrefab
require "Game.CommonPrefab.Lua.SmallLodingPanel"
require "Game.CommonPrefab.Lua.GMPanel"
require "Game.CommonPrefab.Lua.HotUpdatePanel"
require "Game.CommonPrefab.Lua.HotUpdateSmallPanel"
require "Game.CommonPrefab.Lua.IllustratePanel"
require "Game.CommonPrefab.Lua.NetJH"
require "Game.CommonPrefab.Lua.RectJH"
require "Game.CommonPrefab.Lua.HintPanel"
require "Game.CommonPrefab.Lua.LittleTips"
require "Game.CommonPrefab.Lua.CommonTips"
require "Game.CommonPrefab.Lua.UIPaySuccess"
require "Game.CommonPrefab.Lua.GameTipsPrefab"
require "Game.CommonPrefab.Lua.PayTypePopPrefab"
require "Game.CommonPrefab.Lua.GameButtonPanel"
require "Game.CommonPrefab.Lua.ExtPanel"
require "Game.CommonPrefab.Lua.ComGuideToolPanel"
require "Game.CommonPrefab.Lua.QPPrefab"

-- 配置
errorCode = require "Game.Common.error_code"
require "Game.CommonPrefab.Lua.GameSceneCfg"
require "Game.Common.normal_enum"
audio_config = require "Game.CommonPrefab.Lua.audio_config"

-- UITool
require "Game.CommonPrefab.Lua.GameComAnimTool"
require "Game.CommonPrefab.Lua.ComDialCJComponent"
require "Game.Framework.URLImageManager"
require "Game.CommonPrefab.Lua.CommonPMDManager"
require "Game.CommonPrefab.Lua.CommonLotteryAnim"
require "Game.Common.panelManager"
require "Game.Common.ExtendSoundManager"
require "Game.CommonPrefab.Lua.CachePrefabManager"
require "Game.CommonPrefab.Lua.GameModuleManager"
require "Game.CommonPrefab.Lua.CommonAnim"
require "Game.CommonPrefab.Lua.CommonEffect"

-- Manager
require "Game.CommonPrefab.Lua.TimerExt"
require "Game.Framework.IosPayManager"
require "Game.Framework.AndroidPayManager"
require "Game.Framework.DataStatisticsManager"
require "Game.Framework.BuriedStatisticalDataSystem"
require "Game.Framework.DataBurialPointSystem"
require "Game.Framework.LocalDatabaseManager"
require "Game.CommonPrefab.Lua.TimerManager"
require "Game.CommonPrefab.Lua.CommonTimeManager"
require "Game.CommonPrefab.Lua.NetMsgSendManager"
require "Game.CommonPrefab.Lua.SYSQXManager"
require "Game.Common.UniWebViewMgr"
require "Game.Common.UniWebViewMessageMgr"
require "Game.CommonPrefab.Lua.GameLanguageLocalization"
require "Game.CommonPrefab.Lua.GameItemModel"
require "Game.CommonPrefab.Lua.AwardManager"
require "Game.CommonPrefab.Lua.SysBrokeSubsidyManager"
require "Game.CommonPrefab.Lua.GameBuriedTransferManager"
require "Game.CommonPrefab.Lua.FirebaseEvent"
require "Game.CommonPrefab.Lua.AppsFlyerEvent"


CommonManagerInit.Init = function ()
    Network.Init()
    ExtendSoundManager.Init()
    TimerManager.Init()
    CommonTimeManager.Init()
    URLImageManager.Init()
    SYSQXManager.Init()
    NetMsgSendManager.Init()
    UniWebViewMessageMgr.Init()
    UniWebViewMgr.Init()
    GameModuleManager.Init()

    GameTaskManager.Init()
    GameLanguageLocalization.Init()
    GameItemModel.Init()
    SysBrokeSubsidyManager.Init()

    GameBuriedTransferManager.Init()
    FirebaseEvent.Init()
    AppsFlyerEvent.Init()
    DSM.Init()
end
