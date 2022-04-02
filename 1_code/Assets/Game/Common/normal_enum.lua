--
-- Author: lyx
-- Date: 2018/4/14
-- Time: 10:31
-- 说明：公用的 枚举变量
--

-- 条件的处理方式
NOR_CONDITION_TYPE = {
    CONSUME = 1, -- 消费：必须大于等于，并扣除
    EQUAL = 2, -- 等于
    GREATER = 3, -- 大于等于
    LESS = 4, -- 小于等于
    NOT_EQUAL = 5 -- 不等于
}

-- 玩家财富类型
PLAYER_ASSET_TYPES =
{
	DIAMOND 			= "diamond", 		-- 钻石
	JING_BI 			= "jing_bi",	-- 金币
	CASH 				= "cash", 			-- 现金
	SHOP_GOLD_SUM		= "shop_gold_sum",	-- 购物金总数：各面额加起来

	ROOM_CARD 			= "room_card",	-- 房卡

	JIPAIQI 			= "jipaiqi",	-- 记牌器有效期 -- 只作为消息发送

	PROP_JICHA_CASH		= "prop_jicha_cash", 	-- 生财之道的级差现金

	PROP_1              = "prop_1",         -- 竞标赛门票

	PROP_2              = "prop_2",         -- 千元赛门票

}

-- 玩家财富类型集合 以及 所有 prop_ 开头的东西
PLAYER_ASSET_TYPES_SET =
{
	["diamond"] 		= "diamond", 		-- 钻石
	["jing_bi"] 		= "jing_bi",		-- 金币
	["cash"] 			= "cash", 			-- 现金
	["shop_gold_sum"] 	= "shop_gold_sum", 	-- 购物金

	["jipaiqi"] 		= "jipaiqi", 		-- 记牌器有效期

	["room_card"] 		= "room_card",		-- 房卡
}

--财富改变类型

--不需要给tips的资产类型 默认会弹出奖励面板
NO_TIPS_ASSET_CHANGE_TYPE = {
    new_user_logined_award = 1,
    freestyle_game_settle = 1,
    slot_jymt_game_award = 1,
    slot_wushi_game_award = 1,
    slot_jymt_game_jjcj_award = 1,
    lottery_luck_box = 1,
    task_domino_time_fan_bei_award = 1,
    hb_limit_convert = 1,
    shoping_refund = 1,

    fxq_game_extra_award = 1,

    xxl_game_award = 1,
    xxl_shuihu_game_award = 1,
    xxl_sanguo_game_award = 1,
    xxl_xiyou_game_award = 1,
    xxl_caishen_game_award = 1,
    xxl_xiyou_progress_task_award = 1,
    lxxxl_game_award = 1,
    
    guess_apple_award = 1,
    init_bind_player_account_award = 1,
    buy_gift_bag_1022 = 1,
}

-- 支付： 支持的渠道类型
PAY_CHANNEL_TYPE = {
    alipay = true,
    weixin = true
}

--商品类型
GOODS_TYPE = {
    goods = "goods",
    jing_bi = "jing_bi",
    item = "item",
    gift_bag = "gift_bag",
    shop_gold_sum = "shop_gold_sum",
    paotai = "paotai",
}


--优惠券 单位：分
CZYHQ = {
    [5000] = 500,
    [9800] = 1000,
    [19800] = 2000,
    [49800] = 5000,
    [99800] = 10000,
    [249800] = 20000,
}

--优惠券额度对应的道具
CZYHQ_ITEM = {
    [500] = "obj_5_coupon",
    [1000] = "obj_10_coupon",
    [2000] = "obj_20_coupon",
    [5000] = "obj_50_coupon",
    [10000] = "obj_100_coupon",
    [20000] = "obj_200_coupon",
}

--道具类型
ITEM_TYPE = {
    expression = "expression",
    jipaiqi = "jipaiqi",
    room_card = "room_card",
    qys_ticket = "prop_2",
}

-- 活动提示状态值
ACTIVITY_HINT_STATUS_ENUM = {
    AT_Nor = "常态",
    AT_Red = "红点",
    AT_Get = "领奖",
}

--玩家类型
PLAYER_TYPE = {
    PT_New = "新玩家",
    PT_Old = "老玩家",
}

-- 服务器名字(类型)
SERVER_TYPE = {
    ZS = "zs", -- 正式
    CS = "cs", -- 测试
}