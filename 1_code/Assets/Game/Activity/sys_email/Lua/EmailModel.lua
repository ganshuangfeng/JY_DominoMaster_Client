-- 邮件管理
local basefunc = require "Game.Common.basefunc"
local email_config = nil
email_config = GameModuleManager.ExtLoadLua(EmailLogic.key, "email_config")

EmailModel = {}

--邮件IDs列表
EmailModel.EmailIDs = {}

--邮件列表
EmailModel.Emails = {}

local EmailDownloadFinishCall = nil
local EmailReadFinishCall = nil
local EmailGetFinishCall = nil
local EmailGetAllFinishCall = nil
local EmailDeleteFinishCall = nil

local lister
local function AddLister()
    lister={}
    lister["get_email_ids_response"] = EmailModel.OnGetEmailIdsResponse
    lister["get_email_response"] = EmailModel.OnGetEmailResponse
    lister["read_email_response"] = EmailModel.OnReadEmailResponse
    lister["get_email_attachment_response"] = EmailModel.OnGetEmailAttachmentResponse
    lister["get_all_email_attachment_response"] = EmailModel.OnGetAllEmailAttachmentResponse
    lister["delete_email_response"] = EmailModel.OnDeleteEmailResponse

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


--[[a-b 数字集合 a 比 b 多了哪些
    a={1,3,5}
    b={2,3}
    more={1,5}
]]
local function tableMore(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if not bm[v] then
            ret[#ret+1]=v
        end
    end
    return ret
end

-- 表的交集
local function tableAND(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if bm[v] then
            ret[#ret + 1] = v
        end
    end
    return ret
end

--解析邮件数据
local function parseEmailData(emailData)

    local code = emailData
    local ok, ret = xpcall(function ()
        local data = json2lua(code)
        -- if type(data) ~= 'table' then
        --     data = {}
        --     print("parseEmailData error : {}")
        -- end
        return data
    end
    ,function (err)
        local errStr = "parseEmailData error : "..emailData
        print(errStr)
        print(err)
    end)

    if not ok then
        ret = nil
    end

    return ret
end


--请求邮件id列表
local function ReqEmailIDs()
    Network.SendRequest("get_email_ids")
end

--请求邮件列表
local function ReqEmail(id)
    Network.SendRequest("get_email",{email_id=id})
end

--请求所有邮件列表
local function ReqAllEmail()
    Network.SendRequest("get_all_email")
end

-- 获取邮件路径
local function getEmailPath()
    local emailPath = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return emailPath
end
-- 邮件ID路径
local function getEmailIDPath()
    return getEmailPath() .. "/emailID.txt"
end
-- 邮件ID对应的内容路径
local function getEmailIDToDescPath(emailID)
    return getEmailPath() .. "/" .. emailID .. "_DescTag.txt"
end
-- 保存ID列表
local function SaveEmailID()
    local emailPath = getEmailPath()
    if not Directory.Exists(emailPath) then
        Directory.CreateDirectory(emailPath)
    end

    local emailIDPath = getEmailIDPath()
    local idstr = ""
    for i,v in ipairs(EmailModel.EmailIDs) do
        idstr = idstr .. v
        if i < #EmailModel.EmailIDs then
            idstr = idstr .. ","
        end
    end
    File.WriteAllText(emailIDPath, idstr)
end
-- 保存邮件内容列表
local function SaveEmailDesc(emailId)
    if type(emailId) == "table" then
        for _,v in ipairs(emailId) do
            SaveEmailDesc(v)
        end
    else
        local emailPath = getEmailIDToDescPath(emailId)
        local descStr = EmailModel.Emails[emailId]
        -- descStr = basefunc.safe_serialize(descStr)
        descStr = lua2json(descStr)
        
        if descStr then
            File.WriteAllText(emailPath, descStr)
        else
            print("<color=red>邮件内容为空 emailID = " .. emailId .. "</color>")
        end
    end
end

-- 加载本地邮件ID
local function LoadEmailID()
    local emailPath = getEmailPath()
    if not Directory.Exists(emailPath) then
        Directory.CreateDirectory(emailPath)
    end
    local emailIdPath = getEmailIDPath()
    if not File.Exists(emailIdPath) then
        return
    end
    local allID = File.ReadAllText(emailIdPath)
    if not allID or allID == "" then
        return
    end
    local ns = StringHelper.Split(allID, ",")
    for _,v in ipairs(ns) do
        if tonumber(v) then
            local bufPath = getEmailIDToDescPath(v)
            if File.Exists(bufPath) then
                EmailModel.EmailIDs[#EmailModel.EmailIDs + 1] = tonumber(v)
            end
        end
    end
    SaveEmailID()
end

-- 删除本地邮件
local function DelEmail(emailId)
    if type(emailId) == "table" then
        for _,v in ipairs(emailId) do
            DelEmail(v)
        end
    else
        EmailModel.Emails[emailId] = nil
        local bufList = {}
        for i,v in ipairs(EmailModel.EmailIDs) do
            if v ~= emailId then
                bufList[#bufList + 1] = v
            end
        end
        EmailModel.EmailIDs = bufList
        SaveEmailID()
        local emailPath = getEmailIDToDescPath(emailId)
        if File.Exists(emailPath) then     
            File.Delete(emailPath)
        end
    end
end
-- 加载本地邮件内容
local function LoadEmailDesc(emailId)
    local emailPath = getEmailPath()
    if not emailId then
        local _e_id = {}
        for _,v in pairs(EmailModel.EmailIDs) do
            local b = LoadEmailDesc(v)
            if not b then
                _e_id[#_e_id + 1] = v
            end
        end
        dump(_e_id, "<color=red>读取本地邮件失败的列表</color>")
        for k,v in ipairs(_e_id) do
            DelEmail(v)
        end
    else
        local emailPath = getEmailIDToDescPath(emailId)
        if File.Exists(emailPath) then
            local allText = parseEmailData(File.ReadAllText(emailPath))
            if not allText then
                print("<color=red>EEE 读取本地邮件失败 emailId = " .. emailId .. "</color>")
                return false
            else
                EmailModel.Emails[emailId] = allText
                return true
            end
        end
    end
end

--显示个人信息
function EmailModel.Init()
    AddLister()

    EmailModel.templateData = {}
    if email_config then
        for i,v in ipairs(email_config) do
            EmailModel.templateData[v.type] = v
        end
    end

    EmailDownloadFinishCall = nil
    EmailModel.EmailIDs = {}
    EmailModel.Emails = {}

    LoadEmailID()
    LoadEmailDesc()
    
    ReqEmailIDs()
end


function EmailModel.Exit()
    RemoveLister()
end

local function IsEmailDownloadFinish()
    for i,v in ipairs(EmailModel.EmailIDs) do
        if not EmailModel.Emails[v] then
            return false
        end
    end
    return true
end
--[[请求所有的邮件
    UI展示的时候需要调用一下然后准备展示邮件内容
]]
function EmailModel.ReqAllEmail(cbk)

    EmailDownloadFinishCall = cbk

    if IsEmailDownloadFinish() then
        if EmailDownloadFinishCall then
            EmailDownloadFinishCall()
            EmailDownloadFinishCall = nil
        end
    end
end

-- 刷新邮件
function EmailModel.RefreshEmail(emailId)
    ReqEmail(emailId)
end


function EmailModel.OnGetEmailIdsResponse(_,data)
    dump(data, "服务器返回的邮件列表")
    if data.result == 0 then
        if data.list and next(data.list) then
            local mm = {}
            for _,v in ipairs(data.list) do
                if mm[v] then
                    print("<color=red>EEEEEEEEEE 邮件ID重复</color>")
                else
                    mm[v] = 1
                end
            end
            data.list = {}
            for k,v in pairs(mm) do
                data.list[#data.list + 1] = k
            end

            local diffIDs = tableMore(data.list, EmailModel.EmailIDs)
            local delIDs = tableMore(EmailModel.EmailIDs, data.list)

            EmailModel.EmailIDs = tableAND(data.list, EmailModel.EmailIDs)

            DelEmail(delIDs)
            SaveEmailID()
            for i,id in ipairs(diffIDs) do
                ReqEmail(id)
            end
        else
            DelEmail(EmailModel.EmailIDs)
            SaveEmailID()
        end
        Event.Brocast("get_email_list_finish")
    end
end

function EmailModel.AddEmail(data)
    if data.email then

        -- 针对广播处理的
        local isAddId = true
        for _,v in ipairs(EmailModel.EmailIDs) do
            if v == data.email.id then
                isAddId = false
                break
            end
        end
        if isAddId then
            EmailModel.EmailIDs[#EmailModel.EmailIDs + 1] = data.email.id
            SaveEmailID()
        end


        if data.email.data then
            data.email.data = parseEmailData(data.email.data)
        end
        EmailModel.Emails[data.email.id] = data.email
        EmailModel.Emails[data.email.id].create_time = tonumber(EmailModel.Emails[data.email.id].create_time)
        EmailModel.Emails[data.email.id].valid_time = tonumber(EmailModel.Emails[data.email.id].valid_time)
        SaveEmailDesc(data.email.id)
        
        if IsEmailDownloadFinish() then
            if EmailDownloadFinishCall then
                EmailDownloadFinishCall()
                EmailDownloadFinishCall = nil
            end
        end

    end
end

function EmailModel.OnGetEmailResponse(_,data)
    if data.result == 0 then
        Event.Brocast("req_call_email_msg", data)
    end
end


function EmailModel.OnReadEmailResponse(_,data)
    if data.result == 0 then
        if EmailModel.Emails[data.email_id] then
            EmailModel.Emails[data.email_id].state = "read"
            SaveEmailDesc(data.email_id)
            Event.Brocast("set_email_state_change", data.email_id)
        end
        if EmailReadFinishCall then
            EmailReadFinishCall()
            EmailReadFinishCall = nil
        end
    else
        EmailModel.RefreshEmail(data.email_id)
        HintPanel.ErrorMsg(data.result)
    end
end


function EmailModel.OnGetEmailAttachmentResponse(_,data)
    dump(data, "<color=red>领取邮件返回</color>")
    if data.result == 0 then

       if EmailModel.Emails[data.email_id] then
            EmailModel.Emails[data.email_id].state = "read"
            SaveEmailDesc(data.email_id)
            Event.Brocast("set_email_state_change", data.email_id)
        end
        if EmailGetFinishCall then
            EmailGetFinishCall()
            EmailGetFinishCall = nil
        end
    else
        EmailModel.RefreshEmail(data.email_id)
        HintPanel.ErrorMsg(data.result)
    end

end


function EmailModel.OnGetAllEmailAttachmentResponse(_,data)
    dump(data, "<color=red>一键领取邮件返回</color>")
    if data.result == 0 then
        for i,id in ipairs(data.email_ids) do
           if EmailModel.Emails[id] then
                EmailModel.Emails[id].state = "read"
                SaveEmailDesc(id)
                Event.Brocast("set_email_state_change", id)
            end 
        end
        if EmailGetAllFinishCall then
            EmailGetAllFinishCall()
            EmailGetAllFinishCall = nil
        end
    end

end

function EmailModel.DeleteEmail(emailId)
    if EmailModel.Emails[emailId] then
        EmailModel.Emails[emailId] = nil
        DelEmail(emailId)
    end
end

function EmailModel.OnDeleteEmailResponse(_,data)
    dump(data, "<color=red>删除邮件返回</color>")
    if data.result == 0 then
        EmailModel.DeleteEmail(data.email_id)
        if EmailDeleteFinishCall then
            EmailDeleteFinishCall()
            EmailDeleteFinishCall = nil
        end
    end

end

-- UI发送读取请求
function EmailModel.SendReadEmail(id, cbk)
    EmailReadFinishCall = cbk
    Network.SendRequest("read_email", {email_id = id}, "")
end

-- UI发送领取请求
function EmailModel.SendGetEmail(id, cbk)
   EmailGetFinishCall = cbk
   Network.SendRequest("get_email_attachment", {email_id = id}, "")
end

-- UI发送一键领取请求
function EmailModel.SendGetAllEmail(cbk)
    EmailGetAllFinishCall = cbk
    Network.SendRequest("get_all_email_attachment", nil, "")
end

-- UI发送删除请求
function EmailModel.SendDeleteEmail(id, cbk)
    EmailDeleteFinishCall = cbk
    Network.SendRequest("delete_email", {email_id = id}, "")
end

--[[清除所有的邮件和本地缓存
    切换账号的时候需要使用
    两个不同的账号的邮件肯定会冲突
]]
function EmailModel.ClearEmail()
    EmailModel.EmailIDs = {}
    EmailModel.Emails = {}
end

-- 邮件状态
EmailModel.EmailState = {
    Read = 1,   -- 已读
    UnRead = 2,   -- 未读
    Lose = 3,   -- 过期
}
-- 邮件状态名字和状态值
function EmailModel.GetState(emailId)
    local data = EmailModel.Emails[emailId]
    if not data then
        StringHelper.PrintError("emailId" .. emailId)
        return
    end
    local currTime = os.time()
    
    if data.valid_time == 0 or data.valid_time > currTime then-- 有效
        if data.state == "read" then
            return EmailModel.EmailState.Read, "已读"
        else
            return EmailModel.EmailState.UnRead, "未读"
        end
    else-- 过期、失效
        return EmailModel.EmailState.Lose, "失效"
    end
end

-- 邮件是否读取
function EmailModel.IsReadState(emailId)
    local data = EmailModel.Emails[emailId]
    
    if data.state == "read" then
        return true
    end
end

-- 获取过期时间
function EmailModel.GetLoseTime(emailId)
    local data = EmailModel.Emails[emailId]
    local currTime = os.time()
    local tt = data.valid_time > currTime
    if data.valid_time > currTime then
        return data.valid_time - currTime
    else
        return 0
    end
end

-- 邮件是否有奖励
function EmailModel.IsExistAward(emailId)
    local data = EmailModel.Emails[emailId] 
    if data then   
        local awardTab = AwardManager.GetAwardTable(data.data)
        if next(awardTab) then
            return true
        end
    end
    return false
end

-- 邮件是否红点提示
function EmailModel.IsRedHint()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if (next(awardTab) and v.state ~= "read") or v.state ~= "read" then
            return true
        end
    end
    return false
end
-- 邮件是否有附件未领取
function EmailModel.IsGetHint()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if next(awardTab) and v.state ~= "read" then
            return true
        end
    end
end

-- 内容翻译
function EmailModel.GetEmailDesc(data)
    local temp = EmailModel.templateData[data.type]
    if not temp then
        if data.data and data.data.content then
            return data.data.content, data.title
        else
            dump(data, "<color=red>EEE 邮件模板不存在</color>")
            return data.type, data.type
        end
    end
    local desc = ""
    local title = ""
    if true then
        title = GLL.GetTx(temp.title)
        desc = GLL.GetTx(temp.content)
    end
    if data.type == "yingjin_common_rank_email" then
        desc = string.format(desc, data.data.rank_id, data.data.shop_gold_sum/100)
    end
    return desc,title
end

function EmailModel.FormSumShiWuStr(_str)
    local allshiwuData=StringHelper.Split(_str,",")
    local formShiwuData={}
    local isContain= function (list,desc)
		for index, value in ipairs(list) do
			if value.desc==desc then
				return index
			end
		end
		return -1
	end
    for index, value in ipairs(allshiwuData) do
        local containIndex=isContain(formShiwuData,value)
			if containIndex==-1 then
				formShiwuData[#formShiwuData + 1] = {num=1, desc=value}
			else
				local num=formShiwuData[containIndex].num
				formShiwuData[containIndex].num=num+1
			end
    end
    local returnStr=""
    for index, value in ipairs(formShiwuData) do
        if index~=#formShiwuData then
            returnStr=returnStr..value.desc.."x"..value.num..","
        else
            returnStr=returnStr..value.desc.."x"..value.num
        end
    end
    return returnStr

end
----通用dataType表
local commonTypeTable = { "xiaoxiaole_tower_week_rank_email" ,
                         "xxlzb_005_rank_email",   "xxlzb_005_rank_ext_email",     "kh315_008_lhphb_rank_email",       "kh315_008_lhphb_rank_ext_email", 
                         "xxlzb_006_rank_email",   "xxlzb_006_rank_ext_email" ,"   cnhk_009_thphb_rank_email",          "cnhk_009_thphb_rank_ext_email",
                         "xxlzb_007_rank_email",   "xxlzb_007_rank_ext_email",     "ymkh_010_wxphb_rank_email",         "ymkh_010_wxphb_rank_ext_email",
                         "xxlzb_008_rank_email",   "xxlzb_008_rank_ext_email",     "qmyl_011_hdphb_rank_email",         "qmyl_011_hdphb_rank_ext_email",
                         "xxlzb_009_rank_email",   "xxlzb_009_rank_ext_email",     "ltqf_012_fqdr_rank_email",          "ltqf_012_fqdr_rank_ext_email",
                         "cjj_xxlzb_rank_email",   "cjj_xxlzb_rank_ext_email",     "hlsyt_013_bsyl_rank_email",          "hlsyt_013_bsyl_rank_ext_email",
                         "wylft_014_ldxfb_rank_email",  "wylft_014_ldxfb_rank_ext_email",   "hljnh_015_yxdr_rank_email",    "hljnh_015_yxdr_rank_ext_email",
                         "hlwyt_016_fqdr_rank_email",   "hlwyt_016_fqdr_rank_ext_email",    "ymshf_017_hldr_rank_email",    "ymshf_017_hldr_rank_ext_email",
                         "hlly_018_hlbd_rank_email",    "hlly_018_hlbd_rank_ext_email",      "zqdw_019_fqdr_rank_email",  "zqdw_019_fqdr_rank_ext_email" ,
                         "fqjkh_020_yxbd_rank_email",   "fqjkh_020_yxbd_rank_ext_email","qlyx_021_xgphb_rank_email", "qlyx_021_xgphb_rank_ext_email",
                         "yqhp_022_nqdr_rank_email","yqhp_022_nqdr_rank_ext_email","xrkh_023_ygbd_rank_email","xrkh_023_ygbd_rank_ext_email",
                         "lxjkh_024_jfphb_rank_email","lxjkh_024_jfphb_rank_ext_email"
                        }
function EmailModel.IsCommonType(data_type)
    -- body
    for i, v in ipairs(commonTypeTable) do
        if v==data_type then
            return true
        end
    end
    return false
end
-- 是否有邮件可以领取
function EmailModel.IsEmailsGet()
    for k,v in pairs(EmailModel.Emails) do
        local awardTab = AwardManager.GetAwardTable(v.data)
        if next(awardTab) and v.state ~= "read" then
            return true
        end
    end
end

-- 时间显示转换
function EmailModel.GetConvertTime(val)
    return os.date("%Y-%m-%d %H:%M", val)
end