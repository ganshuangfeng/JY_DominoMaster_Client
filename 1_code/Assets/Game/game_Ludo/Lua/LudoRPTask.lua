-- 创建时间:2022-01-05
-- LudoRPTask 管理器

local basefunc = require "Game/Common/basefunc"
LudoRPTask = {}
local M = LudoRPTask

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
end

function M.Init()
	M.Exit()

	this = LudoRPTask
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

--任务改变信息过来了 筛选出自己关系的数据
function M.model_task_data_change_msg(data)
	
end

--提示游戏逻辑做出对应的表现
function M.XX( ... )
	-- body
end