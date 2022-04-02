-- 创建时间:2022-03-16
-- 版本管理
-- 多版本管理与跨多个版本的更新内容维护

VersionManager = {}

VersionManager.VStage = 
{
	Normal = 0, -- 正常
	Update = 1, -- 提示更新
	Force  = 2, -- 强制更新，底层接口改变，引导去google play更新
}

-- 初始化
function VersionManager.Init()
	VersionManager.cur_stage = VersionManager.VStage.Normal
	VersionManager.Off = {}

	if AppDefine.IsEDITOR() then
		dump(VersionManager.Off, "[Version] <color=#00FFABFF>****** EDITOR VersionManager.Off ******</color>")
		return
	end

	local version_history = VersionManager.version_history_android
	if gameRuntimePlatform == "Ios" then
		version_history = VersionManager.version_history_ios
	end

	local s = StringHelper.Split(MainVersion.baseVersion, ".")
	if s and #s == 3 then
		local a = tonumber(s[1])
		local b = tonumber(s[2])
		local c = tonumber(s[3]) -- 此版本字段用于比较

		for k,v in ipairs(version_history) do
			if c < v.code then
				if v.update > VersionManager.cur_stage then
					VersionManager.cur_stage = v.update
				end
	
				if VersionManager.cur_stage == VersionManager.VStage.Force then
					return
				else
					if v.on_off then
						for kk,vv in pairs(v.on_off) do
							VersionManager.Off[kk] = vv
						end
					end
				end
			end
		end
	end
	dump(VersionManager.Off, "[Version] <color=#00FFABFF>****** Mobile device VersionManager.Off ******</color>")
end

-- IOS 版本历史信息
VersionManager.version_history_ios = {}

-- Android 版本历史信息
VersionManager.version_history_android = 
{
	-- 路径：Version2020/Update/V5/TS4/Android/  打包时间3月4号 对外时间3月7号
	{
		version = "5.1.5",
		code = 5,
		desc = "提审内容：设备ID获取方式升级；增加Google登录方式；资源优化何内存优化；",
		update = VersionManager.VStage.Force,
	},
	-- 路径：Version2020/Update/V5/TS7/Android/  打包时间3月11号 对外时间3月14号
	{
		version = "5.1.8",
		code = 8,
		desc = "提审内容：google支付相关埋点；Facebook头像权限添加；",
		update = VersionManager.VStage.Update,
		on_off = {
			google_md = true,--google支付相关埋点接口新增
		},
	},
	-- 路径：Version2020/Update/V5/TS8/Android/  打包时间3月18号 对外时间3月22号
	{
		version = "5.1.9",
		code = 9,
		desc = "提审内容：Firebase推送消息",
		update = VersionManager.VStage.Update,
		on_off = {
			firebase_ts = true,--Firebase推送接口新增
		},
	},
}

