-- 创建时间:2021-12-07
-- 破产流程

SysBrokeSubsidyManager = {}

local this
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["global_pay_msg"] = this.on_global_pay_msg
	lister["model_lottery_error_amount"] = this.on_model_lottery_error_amount
    lister["EnterScene"] = this.OnEnterScene
end

function SysBrokeSubsidyManager.Init()
	SysBrokeSubsidyManager.Exit()

	this = SysBrokeSubsidyManager
	MakeLister()
    AddLister()
end
function SysBrokeSubsidyManager.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function SysBrokeSubsidyManager.on_global_pay_msg(config)
	this.is_launch_pay = true
end

local lock = false
local QuerySubsidy
local GetSubsidy
QuerySubsidy = function (call)
    Network.SendRequest("query_broke_subsidy_num",nil,"",function(data)
        if data.result == 0 then
			MainModel.BrokeData = {}
	        MainModel.BrokeData.shareCount = data.num or 0
	        MainModel.BrokeData.shareAllNum = data.all_num or 0
    	end
        call()
    end)
end

GetSubsidy = function (data)
	local call = function ()
		if not MainModel.BrokeData then
			if data.hint then
				HintPanel.Create(1, GLL.GetTx(10013))
			end
			if data.call then
				data.call(false)
			end	
			return
		end

		if MainModel.BrokeData.shareCount > 0 then
			Network.SendRequest("broke_subsidy", nil, "", function (_data)
		    	if _data.result == 0 then
			        MainModel.BrokeData.shareCount = MainModel.BrokeData.shareCount - 1
					if data.call then
						data.call(true)
					end			
		    	else
					if data.hint then
			    		HintPanel.ErrorMsg(_data.result)
			    	end
					if data.call then
						data.call(false)
					end			
		    	end
			end)
		else
			if data.hint then
				HintPanel.Create(1, GLL.GetTx(10012))
			end
			if data.call then
				data.call(false)
			end	
		end
	end

	dump(MainModel.BrokeData,"<color=yellow>MainModel.BrokeData???????</color>")

	if MainModel.BrokeData then
		call()
	else
		QuerySubsidy(call)
	end
end

-- 首充礼包
local run_sclb
run_sclb = function (call)
	local a,b = GameModuleManager.RunFunExt("act_sclb", "IsCanBuySCLB", nil, nil)
	if a then
		if b then
			local panel = GameManager.GotoUI({gotoui = "act_sclb", goto_scene_parm = "panel"})
			if not panel then
				call(false)
				return
			end
			local panelExitFun = panel["MyExit"]
			panel["MyExit"] = function()
				panelExitFun()
				if not this.is_launch_pay then
					call(false)
				else
					call(true)
				end
				this.is_launch_pay = false
			end
		else
			call(false)
		end
	else
		call(false)
	end
end

-- 超值礼包
local run_czlb
run_czlb = function (call)
	local a,b = GameModuleManager.RunFunExt("act_czlb", "IsCanBuyCZLB", nil, nil)
	if a then
		if b then
			local panel = GameManager.GotoUI({gotoui = "act_czlb", goto_scene_parm = "panel"})
			if not panel then
				call(false)
				return
			end
			local panelExitFun = panel["MyExit"]
			panel["MyExit"] = function()
				panelExitFun()
				if not this.is_launch_pay then
					call(false)
				else
					call(true)
				end
				this.is_launch_pay = false
			end
		else
			call(false)
		end
	else
		call(false)
	end
end

-- 商城界面
local run_shop
run_shop = function (call)
	local panel = GameManager.GotoUI({gotoui = "sys_shop", goto_scene_parm = "panel"})
	if not panel then
		call(false)
		return 
	end
	local panelExitFun = panel["MyExit"]
	panel["MyExit"] = function()
		panelExitFun()
		if not this.is_launch_pay then
			call(false)
		else
			call(true)
		end
		this.is_launch_pay = false
	end
end

-- 购买流程
local pay_lc = function (data)
	if data.isNoHint then
		--不提示
	else
		--提示：金币不足
		LittleTips.Create( GLL.GetTx(5303) )
	end
	run_sclb(function (b)
		if not b then
			run_czlb(function (b)
				if not b then
					run_shop(function (b)
						if data.callback then
							data.callback()
						end
						if not b then
							print("<color=red>所有流程走完愣是不花钱</color>")
						end
					end)
				else
					if data.callback then
						data.callback()
					end		
				end
			end)
		else
			if data.callback then
				data.callback()
			end
		end
	end)	
end

local broke_jb = 1000000
-- 执行【破产流程】 
function SysBrokeSubsidyManager.RunBrokeProcess(data)
	dump(debug.traceback(),"<color=white>破产堆栈</color>")
	dump(data,"<color=white>破产流程？？？？？？？</color>")
	this.is_launch_pay = false

	data = data or {hint=false,call=nil}
	dump(MainModel.UserInfo.jing_bi,"<color=red>身上的金币</color>")
	if MainModel.UserInfo.jing_bi > broke_jb then
		pay_lc(data)
	else
		data.call = function (b)
			if not b then
				pay_lc(data)
			else
				if data.callback then
					data.callback()
				end
			end
		end
		GetSubsidy(data)
	end
end


function SysBrokeSubsidyManager.CheckBrokeProcess()
	if MainModel.UserInfo.jing_bi > broke_jb then
		return false
	end
	return true
end

--得到一个恢复的值
function SysBrokeSubsidyManager.GetBrokeJB()
	return 	broke_jb
end


local xxlLocation = {
    "game_EliminateSH",
    "game_EliminateXY",
    "game_EliminateSG",
    "game_Eliminate",
}

function SysBrokeSubsidyManager.on_model_lottery_error_amount()
	dump("<color=white>xxxxxxon_model_lottery_error_amountxxxxx</color>")
	local isInLocation = function()
		for i = 1,#xxlLocation do
			if MainModel.myLocation == xxlLocation[i] then
				return true
			end
		end
		return false
	end
    if isInLocation then
        local hintPanel =  HintPanel.Create(2, GLL.GetTx(5303), function()
			SysBrokeSubsidyManager.RunBrokeProcess()
		end, nil, nil, nil, true)
		hintPanel.yes_txt.text = GLL.GetTx(20014)
    end
end

--进入大厅是检测是否可领救济金
function SysBrokeSubsidyManager.OnEnterScene()
	 if MainModel.myLocation == "game_Hall" then
		local data = {}
		GetSubsidy(data)
    end
end