local basefunc = require "Game.Common.basefunc"

StringHelper = {}
-- 分隔字符串返回一个Table
local Split = function (str, splitStr)
    if (str == nil or str == "") then
        return nil
    end

    local strAry = { }
    local afterStr = splitStr
    if (splitStr == ".") then
        splitStr = "%."
    end
    for v in string.gmatch(str .. afterStr, "(.-)" .. splitStr) do
        if v and v ~= "" then
            table.insert(strAry, v)
        end
    end
    return strAry
end

local PrintError = function (str)
    print("</color=red>" .. str .. "</color>")
end

local function ToBL(num, s)
    local n = math.floor(num / s)
    local n1 = math.floor((num%s) / (s/10))
    s = s / 10
    local n2 = math.floor((num%s) / (s/10))
    s = s / 10
    local n3 = math.floor((num%s) / (s/10))
    if n3 > 0 then
        num = n .. "." .. n1 .. n2 .. n3
    else    
        if n2 > 0 then
            num = n .. "." .. n1 .. n2
        else
            if n1 > 0 then
                num = n .. "." .. n1
            else
                num = n
            end
        end
    end
    return num
end
-- 显示简短金币数
local function ToCash(num, onlyByLen)
    if num == nil then return "0" end
    num = tonumber(num)
    if num < 0 then
        num = -1 * num
    end
    --2022/1/26  运营提
    if num < 10000 and not onlyByLen then
        return tostring(num)
    end
    if num < 1000 then
        return "" .. num
    elseif num >= 1000 and num < 1000000 then
        num = ToBL(num, 1000)
        return string.format("%sK", num)
    elseif num >= 1000000 and num < 1000000000 then
        num = ToBL(num, 1000000)
        return string.format("%sM", num)
    elseif num >= 1000000000 and num < 1000000000000 then
        num = ToBL(num, 1000000000)
        return string.format("%sB", num)
    else
        num = ToBL(num, 1000000000000)
        return string.format("%sT", num)
    end
end
--为数字添加顿号
local function AddPoint(number)
    local str = tostring(number)
    local index = 0
    local re = ""
    for i = #str,1,-1 do
        local char = string.sub(str,i,i)
        if index % 3 == 0 and index > 0 then
            re = char..","..re
        else
            re = char..re
        end
        index = index + 1
    end
    return re
end

-- 显示简短金币数
local function ToCashSymbol(num)
    num = tonumber(num)
    local symbol = num < 0 and  "-" or "+"
    num = symbol .. ToCash(num)
    return num
end

local function ToRedNum(num)
    return StringHelper.ToCash(num)
    -- return "" .. num
    -- return string.format("%.2f", num)
end

local function ToMoneyNum(num)
    if not num then return "" end
    if num % 100 > 0 then
        return string.format("%.2f", num / 100)
    else
        return string.format("%.0f", num / 100)
    end
end

local function ToJPQ(num)
    return string.format("%.0f天", math.ceil(tonumber(num) / 86400))
end


local function GetCN(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end
local function SubCN(player_name, len)
    local player_name_vec = basefunc.string.string_to_vec(player_name)
    if player_name_vec and type(player_name_vec) == "table" and next(player_name_vec) then
        if #player_name_vec > len then
            local ss = ""
            for k,v in ipairs(player_name_vec) do
                ss = ss .. v
            end
            return ss
        else
            return player_name
        end
    end
    return player_name
end

local function filter_spec_chars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end

-- 获取本周的星期一的时间戳
local function getThisWeekMonday(ct)
    local ct = ct or os.time()
    local y = os.date("%Y", ct)
    local m = os.date("%m", ct)
    local d = os.date("%d", ct)
    
    local weekNum = os.date("*t", ct).wday - 1
    if weekNum == 0 then
        weekNum = 7
    end

    local t = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"}) - 24*3600 * (weekNum-1)
    return t
end

-- 根据数字获取汉字 大于等于0且小于10亿
local function changeToCN(num)
    local words = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
    local adds = {"", '十', '百', '千', '万', '十', '百', '千', '亿'}
    if words[num] then
        return words[num]
    elseif num > 10 and num < 20 then
        local numStr = tostring(num)
        local n = string.sub(numStr, 1, 2)
        local result = adds[1] .. words[n]
        return result
    elseif num > 10 then
        local result = ""
        local lastresult = ""
        local t = ""
        local numStr = tostring(num)
        for i = 1, string.len(numStr) do
            local n = string.sub(numStr, i, i)
            local m = string.len(numStr) - i
            if words[n+1] == "零" then
                if t ~= "零" then
                    if adds[m+1] == "万" then
                        lastresult = result
                        result = result .. adds[m+1]
                        t = ""
                    else
                        lastresult = result
                        result = result .. words[n+1]
                        t = words[n+1]
                    end
                else
                    if adds[m+1] == "万" then
                        result = lastresult .. adds[m+1]
                        t = ""
                    end
                end
            else
                lastresult = result
                result = result .. words[n+1] .. adds[m+1]
                t = words[n+1]
            end
        end
        if t == "零" then
            result = string.sub(result, 1, -2)
        end
        return result
    else 
        return "零"
    end
end

local fmtTxArr

local function formatTimeTxt(num)
    if not fmtTxArr then
        fmtTxArr = {
            [1] = "%d" .. GLL.GetTx(80048), --秒
            [2] = "%d" .. GLL.GetTx(80047), --分
            [3] = "%d" .. GLL.GetTx(80046), --时
            [4] = "%d" .. GLL.GetTx(80045), --天
        }
    end
    local str = ""
    for i = 1, num do
        str = fmtTxArr[i] .. str
    end
    return str
end

-- 返回时间的天时分秒
local function formatTimeDHMS(second)
    if not second or second < 0 then
        return string.format(formatTimeTxt(1), "0") 
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then
        return string.format(formatTimeTxt(4), timeDay, timeHour, timeMinute, timeSecond)
    elseif timeHour > 0 then
        return string.format(formatTimeTxt(3), timeHour, timeMinute, timeSecond)
    elseif timeMinute > 0 then
        return string.format(formatTimeTxt(2), timeMinute, timeSecond)
    else
        return string.format(formatTimeTxt(1), timeSecond)
    end
end


-- 返回时间的天时分秒
local function formatTimeDHMS2(second)
    if not second or second < 0 then
        return "0秒"
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then
        return string.format("%d天%02d:%02d:%02d", timeDay, timeHour, timeMinute, timeSecond)
    elseif timeHour > 0 then
        return string.format("%02d:%02d:%02d", timeHour, timeMinute, timeSecond)
    elseif timeMinute > 0 then
        return string.format("%02d:%02d:%02d",0, timeMinute, timeSecond)
    else
        return string.format("%02d:%02d:%02d",0,0, timeSecond)
    end
end

--当大于一天的时间时，最小显示为分，当小于一天时，最小时间为秒
local function formatTimeDHMS3(second)
    if not second or second < 0 then
        return "0秒"
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then 
        return string.format("%d天%d时%d分", timeDay, timeHour, timeMinute, timeSecond)
    else
        if  timeHour > 0 then
            return string.format("%d时%d分%d秒", timeHour, timeMinute, timeSecond)
        elseif timeMinute > 0 then
            return string.format("%d分%d秒", timeMinute, timeSecond)
        else
            return string.format("%d秒", timeSecond)
        end 
    end
end
-- 返回时间的天时分秒 
local function formatTimeDHMS4(second)
    if not second or second < 0 then
        return "0秒"
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then 
        if timeMinute == 0 then
            if timeHour == 0 then
                return string.format("%d天", timeDay)
            else
                return string.format("%d天%d时", timeDay, timeHour)
            end
        else
            return string.format("%d天%d时%d分", timeDay, timeHour, timeMinute)
        end
    else
        if timeHour > 0 then
            if timeSecond == 0 then
                if timeMinute == 0 then
                    return string.format("%d时", timeHour)
                else
                    return string.format("%d时%d分", timeHour, timeMinute)
                end
            else
                return string.format("%d时%d分%d秒", timeHour, timeMinute, timeSecond)
            end
        elseif timeMinute > 0 then
            if timeSecond == 0 then
                return string.format("%d分", timeMinute)
            else
                return string.format("%d分%d秒", timeMinute, timeSecond)
            end
        else
            return string.format("%d秒", timeSecond)
        end 
    end
end

-- 返回时间的时分秒(天算到时里面)
local function formatTimeDHMS5(second)
    if not second or second <= 0 then
        return ""
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    timeHour = timeHour + timeDay * 24
    if timeHour > 0 then
        return string.format("%02d:%02d:%02d", timeHour, timeMinute, timeSecond)
    elseif timeMinute > 0 then
        return string.format("%02d:%02d:%02d",0, timeMinute, timeSecond)
    else
        return string.format("%02d:%02d:%02d",0,0, timeSecond)
    end
end

--[[判断当前是不是双周 
    (base on 1970/1/5 0:0:0 is single week)
    格林威治时间的第一个周一零点
]]
local function is_double_week(_time)
    _time = _time or os.time()

    local t = 316800 --1970/1/5 0:0:0
    
    local dt = _time - t

    local w = math.ceil(dt/(7*24*3600))%2

    if w == 0 then
        return true
    end

    return false
end

-- 获取本周是一年的第几周
local function getThisWeekNum(ct)
    local ct = ct or os.time()
    local weekNum = os.date("%W", ct)
    return tonumber(weekNum)
end
--- nNum 源数字
--- n 小数位数
local function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    return nRet
end

-- 添加逗号
local function ToAddDH(num)
    local function checknumber(value)
        return tonumber(value) or 0
    end
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then 
            break end
        end
    return formatted
end

--获取零点时间差
local function GetTodayEndTime()
    -- 获取当前时间
    local now_date = os.date("*t",now)
    -- 当天的最后时间
    local Today_End_Time = os.time{year=now_date.year, month=now_date.month, day=now_date.day, hour=23,min=59,sec=59}
    return Today_End_Time
end

--检查是否有中文，存在返回true
local function CheckChinese(s) 
	local ret = {};
	local f = '[%z\1-\127\194-\244][\128-\191]*';
	local line, lastLine, isBreak = '', false, false;
	for v in s:gfind(f) do
		local isChinese = (#v~=1)
		if isChinese then
			print(" isChinese "..v)
			return true
		end
	end
	return false;
end

--检查中文，并返回所有中文字符
local function CheckChineseReturnTab(s) 
	local ret = {};
	local f = '[%z\1-\127\194-\244][\128-\191]*';
	for v in s:gfind(f) do
		table.insert(ret, {c=v,isChinese=(#v~=1)});
	end
	return ret;
end

--是否在同一天
local function IsSameDay(t1, t2)
    local d1 = tonumber(t1)
    local d2 = tonumber(t2)
    if d1 and d2 then
        local a1 = tonumber(os.date("%Y%m%d", d1))
        local a2 = tonumber(os.date("%Y%m%d", d2))
        if a1 == a2 then
            return true
        else
            return false
        end
    elseif not d1 and not d2 then
        return true
    else
        return false
    end
end


StringHelper.Split = Split
StringHelper.PrintError = PrintError
StringHelper.ToCash = ToCash
StringHelper.ToCashSymbol = ToCashSymbol
StringHelper.ToRedNum = ToRedNum
StringHelper.ToMoneyNum = ToMoneyNum
StringHelper.ToJPQ = ToJPQ
StringHelper.GetCN = GetCN
StringHelper.filter_spec_chars = filter_spec_chars
StringHelper.changeToCN = changeToCN
StringHelper.formatTimeDHMS = formatTimeDHMS
StringHelper.getThisWeekMonday = getThisWeekMonday
StringHelper.getThisWeekNum = getThisWeekNum
StringHelper.is_double_week = is_double_week
StringHelper.formatTimeDHMS2 = formatTimeDHMS2
StringHelper.formatTimeDHMS3 = formatTimeDHMS3
StringHelper.formatTimeDHMS4 = formatTimeDHMS4
StringHelper.formatTimeDHMS5 = formatTimeDHMS5
StringHelper.SubCN = SubCN
StringHelper.GetPreciseDecimal = GetPreciseDecimal
StringHelper.ToAddDH = ToAddDH
StringHelper.AddPoint = AddPoint
StringHelper.GetTodayEndTime = GetTodayEndTime
StringHelper.IsSameDay = IsSameDay
