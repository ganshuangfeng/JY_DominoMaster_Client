-- 创建时间:2022-02-09

BroadcastHelper = {}


--截取两个字符串之间的字符串
local function StrCut(str, s_begin, s_end)
    local StrLen = string.len(str)
    local s_begin_len = string.len(s_begin)
    local s_end_len = string.len(s_end)
    local s_begin_x = string.find(str, s_begin, 1)
    local s_end_x = string.find(str, s_end, s_begin_x+1)
    local rs=(string.sub(str, s_begin_x+s_begin_len, s_end_x-1))
    return rs
end

--截取之前的字符串
local function StrCurFront(str, s_cut)
    local s_end_x = string.find(str, s_cut)
    if s_end_x > 1 then
        return string.sub(str, 1, s_end_x - 1)
    else
        return ""
    end
end

--截取之后的字符串
local function StrCurBack(str, s_cut)
    local StrLen = string.len(str)
    local s_cut_len = string.len(s_cut)
    local s_begin_x = string.find(str, s_cut) + s_cut_len
    if s_begin_x < StrLen then
        return string.sub(str, s_begin_x, StrLen)
    else
        return ""
    end
end

function BroadcastHelper.EncodeText(str)
    local tab = {}
    if string.find(str, "</img>") then
        tab.head_img = StrCut(str, "<img=", "></img>")
    end
    if string.find(str, "</vip>") then
        tab.vip_lv = StrCut(str, "<vip=", "></vip>")
    end
    tab.back_txt = StrCurBack(str, "</vip>")
    tab.front_txt = StrCurFront(str, "<img")
    return tab
end
