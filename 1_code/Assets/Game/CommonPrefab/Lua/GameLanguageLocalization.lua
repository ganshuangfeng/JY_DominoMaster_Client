-- 创建时间:2021-11-30
-- 本地化语言

--Text 文字走配置
--Image 图片按照规则 名称加后缀  _language_zh
--Audio 音频按照规则 名称加后缀  _language_zh
--其他

local cfg = require "Game.CommonPrefab.Lua.language_localization_config"

GameLanguageLocalization = {}
-- 简写
GLL = GameLanguageLocalization

-- 当前语言
GLL.curLanguage = "bn"

local language_map = {}
function GLL.Init()
	language_map = cfg.game_main
end

-- 根据ID获取语言文字
function GLL.GetTx(id)
	if not id then
		return "id:nil"
	end
	if not tonumber(id) then
		return id
	end
	if language_map[id] and language_map[id][GLL.curLanguage] then
		local str = string.gsub( language_map[id][GLL.curLanguage] , "\\n" , "\n" )
		return str
	end
	return "id:"..id
end

-- 获取当前语言
function GLL.GetLL()
	return GLL.curLanguage
end
-- 设置当前语言
function GLL.SetLL(language)
	if language ~= GLL.curLanguage then
		GLL.curLanguage = language
		Event.Brocast("game_language_change_msg")
	end
end
function GLL.SetLLRandom()
	if "cn" == GLL.curLanguage then
		GLL.SetLL("bn")
	elseif "bn" == GLL.curLanguage then
		GLL.SetLL("en")
	else
		GLL.SetLL("cn")
	end
end

