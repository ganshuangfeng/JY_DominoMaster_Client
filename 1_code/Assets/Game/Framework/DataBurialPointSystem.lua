-- 数据埋点统计系统
--[[
详细格式说明:
    E 类型(环境信息)
	{

		type=”0”    
		device=”xxxxxxx”,  // 设备号；如果获取失败，则随机生成虚拟设备号并保存在客户端；
						// 虚拟设备号用 “virtual_”作为前缀，以便识别
						// 虚拟设备号 生成要保证唯一
		os=”xxxxxxxx”,     // 操作系统信息，类型、版本
		server_ip = AppConst.SocketAddress; //服务器ip
	}

    A 类型(埋点信息)
	{
		type=”1”
		device=”xxxxxxx”,   // 设备号，安装后初始化 保存的 设备号
		id=nnn           // 本次启动的唯一标识id（可以采用时间戳）
		sn=nnn,          // 操作流水号： 本次启动以来递增
		event=nnn,       // 埋点事件类型编号
		login_id = "",	//玩家id
		server_ip = AppConst.SocketAddress; //服务器ip
		param1=xxx,      // 参数
		param2=xxx,
		param3=xxx,
	}
--]]

local basefunc=require "Game.Common.basefunc"
local cfg = HotUpdateConfig("Game.Framework.buried_statistical_data_system_config").main
DBPS = {}
local M = DBPS
local on_off = true --数据埋点开关

local SN = 0 --序号：本次操作在当前实例中的顺序号
--设备信息
local deivesInfo		-- = Util.getDeviceInfo() --设备信息
-- device_id = deivesInfo[0],
-- device_os = deivesInfo[1],
local device_os		-- = deivesInfo[1] or ""	--操作系统信息
local device_id		-- = MainModel.GetDeviceID() or "" --设备id
local login_id
local player_id

local lister
local function AddLister()
    lister={}
    lister["bsds_send_power"] = M.bsds_send_power
    lister["bsds_send_e"] = M.bsds_send_e
    lister["EnterScene"] = M.EnterScene
	lister["ExitScene"] = M.ExitScene
	lister["EnterForeGround"] = M.EnterForeGround
    lister["EnterBackGround"] = M.EnterBackGround
    lister["ConnecteServerSucceed"] = M.ServerConnectSucceed
    lister["ServerConnectException"] = M.ServerConnectException
    lister["ServerConnectDisconnect"] = M.ServerConnectDisconnect

    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function M.Init()
	if not on_off then return end

	M.pid = os.time()

	--设备信息
	deivesInfo = Util.getDeviceInfo() --设备信息
	device_id = deivesInfo[0] or "" --设备id
	device_os = deivesInfo[1] or ""	--操作系统信息
	if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
		device_id = MainModel.GetDeviceID() or "" --设备id
	end

	local function GetLocalLoginData(name)
		local path
		if AppDefine.IsEDITOR() then
			path = Application.dataPath .. "/" .. name .. ".txt"
		else
			path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
		end
		if File.Exists(path) then
			return File.ReadAllText(path)
		else
			return ""
		end
	end

	--获取登录数据
	local function GetLoginID()
		-- 游客 微信 手机号
		local login_qd = {"facebook", "youke"}
		local login_id
		for k,v in pairs(login_qd) do
			login_id = GetLocalLoginData(v)
			if login_id and login_id ~= "" then
				break
			end
		end
		-- dump(login_id, "<color=green>BSDS login_id</color>")
		return login_id
	end
	login_id = GetLoginID()

	AddLister()
end

function M.Exit()
	if not on_off then return end
	RemoveLister()
end

--强制上传数据 key:事件名字，param:上传参数表
function M.SendPower(key,param)
	param = param or {}
	--配置表中没有配置
	local v = cfg[key]
	if not v then 
		print("<color=white>not key :</color>",key)
		return 
	end

	if MainModel and MainModel.UserInfo then
		player_id = MainModel.UserInfo.user_id
	else
		player_id = nil
	end

	SN = SN + 1
	local data = {
		type = "1",
		device = device_id,
		pid = M.pid,
		sn = SN,
		event = v.value,
		-- login_id = login_id,
		player_id = player_id;
		server_ip = AppConst.SocketAddress;
		param1 = param.param1,
		param2 = param.param2,
		param3 = param.param3,
	}
	--上传
	-- dump(data,"<color=green>SendPostBSDS A</color>")
	Network.SendPostBSDS(data, function (code)
		code = code or ""
		-- dump(data,"<color=green>SendPostBSDS A Result</color>" .. code)
		M.AddFail(data,code)
	end)

	M.SendFail()
end

function M.bsds_send_power(data)
	M.SendPower(data.key,data.param)
end

function M.EnterScene()
	local s = MainModel.myLocation or ""
    M.SendPower(s .. "_enter")
end

function M.ExitScene()
	local s = MainModel.myLocation or ""
	M.SendPower(s .. "_exit")
end

function M.EnterForeGround()
	M.SendPower("enter_fore_ground")
end

function M.EnterBackGround()
	M.SendPower("enter_back_ground")
end

function M.ServerConnectSucceed()
	M.SendPower("server_connect_succeed")
end

function M.ServerConnectException()
	M.SendPower("server_connect_exception")
end

function M.ServerConnectDisconnect()
	M.SendPower("server_connect_disconnect")
end

--lua层更新完成后调用
function M.bsds_send_e()
	local data = {
		type = "0",
		device = device_id,
		os = device_os,
		server_ip = AppConst.SocketAddress;
	}
	-- dump(data,"<color=green>SendPostBSDS E</color>")
	Network.SendPostBSDS(data, function(code)
		code = code or ""
		-- dump(data,"<color=green>SendPostBSDS E Result</color>" .. code)
		M.AddFail(data,code)
	end)
	M.SendFail()
end

function M.AddFail(data,code)
	if code == 200 then return end --已经发送成功
	if table_is_null(data) then return end --数据没有
	-- dump(data,"<color=white>data</color>")
	local e_data = basefunc.deepcopy(data)
	M.fail_list = M.fail_list or {}
	table.insert(M.fail_list,e_data)
	-- dump(M.fail_list, "<color=red>数据埋点统计系统 fail_list ：</color>")
end

function M.SendFail()
	if table_is_null(M.fail_list) then return end
	local fail_list = basefunc.deepcopy(M.fail_list)
	M.fail_list = nil
	local i = 1
	M.SendPostFailData(fail_list,i)
end

function M.SendPostFailData(fail_list,i)
	if i > #fail_list then
		fail_list = nil
		return
	end
	local data = fail_list[i]
	if table_is_null(data) then 
		--数据有误，尝试发送下一条数据
		M.SendPostFailData(fail_list,i + 1)
		return 
	end
	-- dump(data,"<color=red>Fail SendPostBSDS</color>")
	Network.SendPostBSDS(data, function(code)
		code = code or ""
		-- dump(data,"<color=red>Fail SendPostBSDS Result</color>" .. code)
		M.AddFail(data,code)
		M.SendPostFailData(fail_list,i + 1)
	end)
end

--初始化
M.Init()