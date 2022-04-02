-- 创建时间:2018-09-20
-- 支付方式界面

local basefunc = require "Game.Common.basefunc"

PayTypePopPrefab = basefunc.class()

local instance = nil

function PayTypePopPrefab.Create(config, createcall,convert)
    if instance then
        PayTypePopPrefab.Close()
    end
    PayTypePopPrefab.New(config, createcall,convert)
    return instance
end

function PayTypePopPrefab.Close()
    if instance then
        destroy(instance.gameObject) 
        instance = nil
    end
end

function PayTypePopPrefab:ctor(config, createcall,convert)
    self.config = config
    instance = self
    ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
    self.gameObject = newObject("UIPayType", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    self.goodsid = config.id
    self.convert = convert
    self.desc = GLC.HB .. " " .. StringHelper.ToCash( config.price / 100 )
    self.createcall = createcall

	self.goTable = {}
    LuaHelper.GeneratingVar(tran, self.goTable)

    self:InitRect()
    self:AddListenerGameObject()
end

function PayTypePopPrefab:AddListenerGameObject()
	self.goTable.pay_type_close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayTypePopPrefab.Close()
    end)
    self.goTable.bank_btn.onClick:AddListener(function ()
        self:SendPayRequest("indobank")
	end)

    self.goTable.wallet_btn.onClick:AddListener(function ()
      	self:SendPayRequest("indoovo")
    end)

    self.goTable.google_btn.onClick:AddListener(function ()
        self:SendPayRequest("google")
    end)
end

function PayTypePopPrefab:RemoveListenerGameObject()
    self.goTable.pay_type_close_btn.onClick:RemoveAllListeners()
    self.goTable.bank_btn.onClick:RemoveAllListeners()

    self.goTable.wallet_btn.onClick:RemoveAllListeners()

    self.goTable.google_btn.onClick:RemoveAllListeners()    
end

function PayTypePopPrefab:InitRect()
	self.goTable.goods_price_txt.text = self.desc

    

    self.pay_channel_map = {}
    self.pay_type_map = {}
    self.pay_type_map["indobank"] = {obj=self.goTable.bank_btn}
    self.pay_type_map["indoovo"] = {obj=self.goTable.wallet_btn}
    self.pay_type_map["google"] = {obj=self.goTable.google_btn}

    for k,v in pairs(self.pay_type_map) do
        v.obj.gameObject:SetActive(false)
    end

    Network.SendRequest("get_pay_types",{goods_id = self.goodsid},"",function(data)
        dump(data,"<color=green>当前支持的支付方式</color>")
        if data.result ~= 0 then
            HintPanel.ErrorMsg(errorCode[data.result])
            PayTypePopPrefab.Close()
            return
        end
        if not IsEquals(self.gameObject) then
            PayTypePopPrefab.Close()
            return
        end

        if data.types and #data.types > 0 then
            local b = false
            for k,v in ipairs(data.types) do
                if v.channel then
                    self.pay_channel_map[v.channel] = v
                    if self.pay_type_map[v.channel] then
                        b = true
                        self.pay_type_map[v.channel].obj.gameObject:SetActive(true)
                    end
                end
            end

            if not b then
                local call = function ()
                    local local_cfgs = {"localconfig"}
                    for _, v in pairs(local_cfgs) do
                        local dir = gameMgr:getLocalPath(v)
                        if Directory.Exists(dir) then
                            Directory.Delete(dir, true)
                        end
                    end
                end
                call()

                HintPanel.Create(1, GLL.GetTx(80061), function ()
                    gameMgr:QuitAll()
                end)
                return
            end
        else
            HintPanel.Create(1, GLL.GetTx(80062),function(  )
                PayTypePopPrefab.Close()
            end)
        end
    end)
end

function PayTypePopPrefab:SendPayRequest(channel_type)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayManager.Pay(self.config, {channel_type=channel_type, convert = self.convert, createcall=self.createcall})
    destroy(self.gameObject)
end
