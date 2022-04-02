
-- Author: lyx
-- Date: 2018/4/13
-- Time: 11:10
-- 说明：错误定义文件
--

return {

	--------------------------------------------
	-- 公共错误： 1000 ~ 1999

	[1000] = "调用失败，未找到服务",
	[1001] = "参数错误",
	[1002] = "当前无法进行此操作",
	[1003] = "数据不合法",
	[1004] = "数据不存在",
	[1005] = "已在当前游戏或者其他游戏当中",
	[1006] = "未知的资源类型，无法创建新服务",
	[1007] = "系统资源不足，无法创建新服务",
	[1008] = "系统繁忙",
	[1009] = "系统即将进行维护，请稍后再试",
	[1010] = "数据服务内部错误",

	-----------道具物品相关----------------
	[1011] = "钻石数量不满足要求",
	[1012] = "需要的物品数量异常",
	[1013] = "现金数量不满足要求",
	[1014] = "vip等级不满足要求",
	[1022] = "复活卡数量不满足要求",
	[1023] = "金币数量不满足要求",
	[1024] = "福利券数量不足",
	[1025] = "代币数量不足",
	[1026] = "房卡数量不足",

	[1027] = "资阳城市杯海选门票数量不足",
	[1028] = "资阳城市杯复赛门票数量不足",
	[1029] = "资阳城市杯决赛门票数量不足",

	-----------网关登录----------------
	[1031] = "客户端请求太频繁",
	[1032] = "客户端 login 不是第一个请求",
	[1033] = "login id 不能是 robot 前缀",
	[1034] = "客户端初始消息名不正确", -- 首个消息仅允许： login, get_vcode_picture, send_sms_vcode, client_breakdown_info
	[1035] = "还未登录",
	[1036] = "此用户的另一个验证操作正在执行中",
	[1037] = "此用户已经被另一个设备创建",
	[1038] = "此用户正在另一个设备上创建",
	[1039] = "此登录渠道已关闭",
	[1040] = "您正在游戏中，不能登出",
	[1041] = "登录服务异常",
	[1042] = "自动登录信息过期，需要重新验证",
	[1043] = "自动登录用户不存在，需要注册",
	[1044] = "自动登录信息无效，需要重新验证",

	----------- 未分类错误 ---------
	[1051] = "重复调用功能",
	[1052] = "数据验证失败",
	[1053] = "服务器内部错误",
	[1054] = "不必要的操作",
	[1055] = "该项目已经属于其他实体",
	[1056] = "玩家状态被锁定",
	[1057] = "用户不是高级合伙人",
	[1058] = "用户类型不正确",
	[1059] = "JSON数据解析错误",
	[1060] = "数据不匹配",
	[1061] = "没找到查询的数据",
	[1062] = "必须提供财富类型",
	[1063] = "此操作不能同时进行多个",
	[1064] = "服务器对象正在销毁",
	[1065] = "服务器对象不存在",
	[1066] = "此ID对应的服务已经存在",
	[1067] = "此ID对应的服务已经存在或正在创建",
	[1068] = "服务器即将关闭，不允许此操作",
	[1069] = "操作太频繁，请稍后再试",
	[1070] = "登录渠道不存在",
	[1071] = "玩家登录id不存在",
	[1072] = "平台不存在玩家id",
	[1073] = "目标玩家不可被绑定",
	[1074] = "您已经有上级了",
	[1075] = "您输入的邀请码错误",
	[1076] = "老玩家不能绑定",
	[1077] = "请使用手机号登录",
	--------------------------------------------
	-- 比赛相关： 2000 ~ 2099

	[2000] = "当前不是报名状态",
	[2001] = "游戏过于火爆，请稍后再试",
	[2002] = "配置的进入条件 id 不存在",
	[2003] = "不在游戏中",
	[2004] = "状态不正确",
	[2005] = "重复创建比赛 id",
	[2006] = "比赛 id 不存在",
	[2007] = "比赛状态不正确，不能开新场次",
	[2008] = "比赛实例 id 重复",
	[2009] = "比赛实例 id 不存在",
	[2010] = "您已经参加比赛了",
	[2011] = "您还未参加比赛",
	[2012] = "您还在比赛中，不能退出比赛",
	[2013] = "比赛已经开始，不能取消报名",
	[2014] = "比赛还没开始报名",
	[2015] = "比赛报名时间已过",
	[2016] = "您的复活次数已经用完了",
	[2017] = "您今天没有分享百万大奖赛",
	[2018] = "比赛即将关闭，请稍后再试",
	[2019] = "房卡场选项重复",
	[2020] = "房卡场选项不存在",
	[2021] = "房卡场缺少选项",
	[2022] = "您已经准备了",
	[2023] = "您已经报过名了",
	[2024] = "当前报名人数已满，请稍后再试",
	[2025] = "条件不满足",

	-- 资产锁定相关：2100 ~ 2120
	[2100] = "提交的lock_id不存在",
	[2101] = "解锁的lock_id不存在",



	-- 登录相关：2150 ~ 2200
	[2150] = "用户登录ID不存在",
	[2151] = "登录渠道不存在",
	[2152] = "登录失败",
	[2153] = "微信登录凭据不存在，请重新授权微信登录",
	[2154] = "访问微信平台失败",
	[2155] = "微信验证凭据失效，请重新授权微信登录",
	[2156] = "微信验证失败，请重试",
	[2157] = "登录渠道未取得玩家 id",
	[2158] = "用户被禁止登陆",
	[2159] = "用户id不存在",

	-- 个人信息 2201 ~ 2230
	[2201] = "已经进行过实名认证了",
	[2202] = "身份证号码错误",
	[2203] = "非老玩家用户",
	[2204] = "非新玩家用户",
	[2205] = "一个身份证号最多绑定5个同平台账号",
	[2206] = "未满18岁",

	-- 支付相关 2231 ~ 2250
	[2231] = "订单不存在",
	[2232] = "不能修改已完成订单",
	[2233] = "单据不能修改为给定的状态",
	[2234] = "需要提供渠道方的订单号",
	[2235] = "购买金额不正确",
	[2236] = "未知的购买渠道",
	[2237] = "未知的购买币种",
	[2238] = "商品ID不存在",
	[2239] = "商品数量不正确",
	[2240] = "无法完成购买，订单详情数据丢失",
	[2241] = "支付渠道返回 error 结果",
	[2242] = "支付渠道返回 fail 结果",
	[2243] = "支付渠道已经关闭",
	[2244] = "订单已经失败并关闭",
	[2245] = "支付异常",
	[2246] = "登录过期，请重新登录",
	[2247] = "支付参数错误",
	[2248] = "用户取消支付",

	-- 商城购物 2251 ~ 2260
	[2251] = "玩家 id 不存在",
	[2252] = "提供的 token 无效或过期",
	[2253] = "玩家余额不足",
	[2254] = "订单号重复",
	[2255] = "订单状态不正确",

	-- 取现 2261 ~ 2270
	[2261] = "玩家提取数量超过账户金额",
	[2262] = "提现单号不存在",
	[2263] = "不能修改已完成的单据",
	[2264] = "提取金额低于最低提现额度",
	[2265] = "只有微信用户才能提取",
	[2266] = "今日提现次数已使用完,请明日再来",
	[2267] = "系统正在补货中",
	[2268] = "您今日的提现额度已达上限",
	[2269] = "本次提现额度将超过今日额度上限，请明日再来！",
	[2270] = "不能修改已作废的单据",
	[2271] = "支付宝账号不存在",
	[2272] = "功能维护中，暂未开放",
	[2273] = "提现失败",
	[2274] = "系统处理中，请稍后查看",
	[2275] = "不支持的提现渠道",
	[2276] = "提现失败,提成已返到赚钱页面",
	[2277] = "支付宝绑定的游戏账号数量过多",

	-- 邮件
	[2301] = "邮件不存在",
	[2302] = "邮件已过期",
	[2303] = "邮件已失效或过期",
	[2304] = "邮件没有可以领取的附件",
	[2305] = "邮件的附件已经被领取",
	[2306] = "未读邮件不能删除",
	[2307] = "邮件已经被阅读",
	[2308] = "邮件有附件不能被直接阅读",

	-- 通用  2401 ~ 2499
	[2401] = "配置文件不正确",
	[2402] = "服务器内部错误",
	[2403] = "该功能被管理员关闭",
	[2404] = "服务器启动还未完成，请稍后再试",
	[2405] = "服务器配置不正确",
	[2406] = "调用第三方服务失败",
	[2407] = "第三方服务参数错误",
	[2408] = "第三方服务异常",
	[2409] = "投票操作太频繁",
	[2410] = "正在投票中，不可再投票",
	[2411] = "房间号不存在，或已解散",
	[2412] = "请求的资源不存在",
	[2413] = "此操作无需执行，执行了也无所谓",
	[2414] = "增加的数据已经存在",
	[2415] = "要处理的数据条目不存在",

	--appstore pay
	[2501] = "appstore 服务器错误",
	[2502] = "appstore 验证收据错误",
	[2503] = "appstore 订单异常",
	[2504] = "交易已经完成了",




	--手机验证
	[2601] = "验证码错误",
	[2602] = "验证码超时",
	[2603] = "输入的手机号已经被绑定过了",
	[2604] = "您还没有绑定手机号",
	[2605] = "更新的手机号和以前的手机号一致",
	[2606] = "请先获取验证码",



	--冻结相关
	[2701] = "该用户已经被锁定了",
	[2702] = "该用户没有被锁定",


	--新手引导相关
	[2801] = "您还没有完成新手引导",
	[2802] = "您的新手引导话费奖励已经领取了",


	[3001] = "网络无法连接，不能完成下载",
	--微信分享
	[3031] = "检测到未安装微信",
	--微信取消
	[3032] = "您取消了微信登录",
	[3033] = "网络异常，无法发送请求",

	[3034] = "QQ登录失败",
	[3035] = "QQ登录异常",
	[3036] = "手机未安装手Q",
	[3037] = "手机手Q版本太低",
	[3038] = "微信登录失败",
	[3039] = "手机未安装微信",
	[3040] = "手机微信版本太低",
	[3041] = "用户取消授权",
	[3042] = "用户拒绝授权",
	[3043] = "您尚未登录或者之前的登录已过期",
	[3044] = "您的账号没有进行实名认证，请实名认证后重试",
	[3045] = "票据失效，请退出游戏重新登录",
	[3046] = "取消分享",



	--折扣券相关
	[3101] = "折扣券的类型不存在",
	[3102] = "折扣券的余量不足",
	[3103] = "折扣券的已过期",
	[3104] = "折扣券不存在",


	--房卡场相关
	[3201] = "房间不存在",
	[3202] = "房间人数已满",
	[3203] = "操作过于频繁，请等待几秒后尝试",
	[3204] = "房间人数已满",
	[3205] = "正在投票中",


	--资阳城市杯
	[3301] = "您已经获得了复赛资格，不能再参加海选赛",
	[3302] = "比赛活动还未开放",


	--2 gift
	[3401] = "您已经购买过此商品了，不能重复购买",
	[3402] = "为避免重复支付，请于30秒之后重新购买",
	[3403] = "抱歉，此商品已经卖完",
	[3404] = "抱歉，此商品不在售卖时间内",
	[3405] = "您今日已经购买，请等待明日再进行购买",
	[3406] = "您不满足购买条件",


	--hb
	[3501] = "您没有可领取的福利券奖励",
	[3502] = "您没有可领取的现金奖励",


	--冠名赛
	[3601] = "您已经参加过比赛了",
	[3602] = "您的参赛码无效",



	--任务系统
	[3801] = "任务奖励领取失败",
	[3802] = "任务奖励领取达到上限",
	[3803] = "没有找回奖励可领取",
	[3804] = "vip返奖任务每日完成记录获取失败",
	[3805] = "vip返奖任务找回奖励记录获取失败",
	[3806] = "vip推广奖励记录获取失败",
	[3807] = "vip推广奖励提取记录获取失败",
	[3808] = "任务有效期已过",
	[3809] = "只有在比赛当天并且20:55之前才可领取门票（每周二、四、六开启千元赛）",
	[3810] = "Vip1才可领取，你目前还不是Vip1",
	[3811] = "Vip2才可领取，你目前还不是Vip2",
	[3812] = "Vip3才可领取，你目前还不是Vip3",

	--装扮系统
	[3901] = "头像框不可用",
	[3902] = "装扮不可用",
	[3903] = "装扮数量不足",
	[3904] = "装扮已经过期",
	[3905] = "装扮数量超过持有上限",
	[3906] = "持有金币大于50万才可购买",

	-- vip 系统
	[4001] = "购买vip天数达到上限",
	[4002] = "推广奖励不足,领取失败",
	[4003] = "今日推广奖励领取已达上限",
	[4004] = "获取推广统计记录失败",
	[4005] = "Vip才可领取奖金,请先成为vip",

	-- 兑换码系统
	[4101] = "兑换码已经被使用过了",
	[4102] = "兑换码无效",
	[4103] = "您操作错误过多，稍后再试",
	[4104] = "您的此类型的兑换码的使用次数已经用完",
	[4105] = "兑换码当前不可用",
	[4106] = "您的注册时间不满足使用此兑换码的要求",
	[4107] = "此兑换码已兑换完",
	[4108] = "您当前不能使用此类型的兑换码",
	[4109] = "您的账号渠道和兑换码不符",


	[4201] = "今日领取破产补助次数已使用完",
	[4202] = "未达成领取破产补助条件",
	[4203] = "疯狂捕鱼游戏中，无法领取",
	[4204] = "正在游戏中无法领取",
	--财富中心及高级合伙人
	[4301] = "上下级关系不合法",

	[4403] = "高级合伙人状态数据不合法",
	[4404] = "高级合伙人开关数据不合法",
	[4405] = "高级合伙人不存在",
	[4406] = "高级合伙人已存在",
	[4407] = "高级合伙人部分操作失败",
	[4408] = "账目核算中,核算完毕后开放",
	[4409] = "您已被冻结推广员资格，请联系商务微信：JY400888。",
	[4410] = "该邀请码错误！",
	[4411] = "不可添加自己的邀请码！",

	-- 自由场活动
	[4501] = "领取条件不满足",
	[4502] = "领取的活动不存在或已结束",
	[4503] = "领取失败",

	-- 砸金蛋限时活动
	[4600] = "限时礼包开启",
	[4601] = "金币不足，限时礼包开启",
	[4602] = "活动不存在或者已经结束",
	[4603] = "福气值不足，普通模式中砸蛋可增加福气值",


	-- 限时活动兑换
	[4700] = "兑换的活动类型不存在",
	[4701] = "兑换活动不在时间范围内",
	[4702] = "兑换内容不存在",
	[4703] = "兑换内容不满足兑换条件",
	[4704] = "您不能再兑换此物品了",
	[4705] = "兑奖券数量不足",


	-- 幸运宝箱
	[4800] = "今天的抽奖次数已经用完了",
	[4801] = "您必须使用完抽奖次数才能开启",
	[4802] = "您已经开过宝箱了",
	[4803] = "您必须先开宝箱才能继续抽奖",

	-- 道具使用
	[4901] = "道具不存在",
	[4902] = "道具已过期",
	[4903] = "道具当前不可用",

	-- 捕鱼挑战任务
	[5001] = "已在活动中，请在活动结束后再试。",

	-- 每日分享活动
	[5101] = "已经领取过奖励了。",
	[5102] = "抽奖条件未达成。",
	[5103] = "抽奖尚未开始。",
	[5104] = "抽奖已结束。",
	[5105] = "没有奖励数据。",

	--- 活动
	[5201] = "活动已结束。",
	[5202] = "您已经许过愿了！",
	[5203] = "没有许愿，不能领奖！",
	[5204] = "倒计时未到，不能领奖！",
	[5205] = "没有许愿，不能放弃领奖！",
	[5206] = "不在领奖时间段内,请明天再来！",
	[5207] = "不在活动时间段内",
	[5208] = "积分不足！",
	[5209] = "抽奖失败！",
	[5210] = "今日次数已用尽，请明日再来！",
	[5211] = "此商品已兑换完，请明日再来！",
	[5212] = "不满足活动条件",

	-- 鲸鱼赛跑游戏
	[5301] = "游戏未开放。",
	[5302] = "已经不在购买时间",
	[5303] = "金币不足",
	[5304] = "购买达上限",
	[5305] = "购买失败",
	[5306] = "没有购买记录",
	[5307] = "游戏已经到的最大人数",
	[5308] = "撤销失败",
	[5309] = "没有历史记录",
	[5310] = "自动购买次数超上限了",
	[5311] = "单条购买达上限！",
	[5312] = "游戏关闭",
	[5313] = "当前已经在自动购买了",
	[5314] = "当前没有自动购买状态了",
	[5315] = "没有奖励",
	[5316] = "当前不能领奖",
	[5317] = "已经停止自动购买",
	[5318] = "能量值耗尽",
	[5319] = "能量已注入",
	--- 龙王争霸
	[5320] = "不能重复自动充能",       --
	[5321] = "已经充能，不能自动充能",
	[5322] = "已经不是自动充能",       --
	[5344] = "不是自动充能状态，不能自动充能",  ---
	[5345] = "上轮未充能，无法自动充能",
	[5346] = "已经充能，不能连续充能",
	[5347] = "不在充能状态",
	[5348] = "自动充能中，不能连续充能",
	[5349] = "上轮未充能，无法连续充能",
	[5350] = "充能已达到上限，不可继续充能。",
	[5351] = "龙王不能下注",
	[5352] = "充能中，不能退出",
	[5353] = "您当前正在龙王争霸，不能退出",

	-- 周年庆预约
	[5401] = "已经预约过了",

	-- 师徒系统
	[5501] = "您的师傅数量已达上限",
	[5502] = "此人徒弟数量已达上限",
	[5503] = "已存在师徒关系，无法拜师",
	[5504] = "已存在师徒关系，请前往我的师父列表恢复关系",
	[5505] = "师徒关系解除冷却期中",
	[5506] = "师徒关系形成回路",
	[5507] = "信息已过期",
	[5508] = "师徒关系不正确",
	[5509] = "消息不存在",
	[5510] = "自己不能拜自己为师",
	[5511] = "信息已处理",
	[5512] = "当天已点过赞",
	[5513] = "今日任务已达上限",
	[5514] = "任务状态不对",
	[5515] = "任务不存在",
	[5516] = "今日激励箱子个数已上限",
	[5517] = "该激励道具不存在",
	[5518] = "单次赠送超过上限",
	[5519] = "今日免费宝箱赠送已达上限",
	[5520] = "信息已发送，请勿反复发送",
	[5521] = "您已经发布过了收徒信息",
	[5522] = "删除失败",
	[5523] = "不可拜师，该玩家已拒绝过你的请求或者最近撤回过对该玩家的请求",
	[5524] = "今天拜师次数已达上限",
	[5525] = "该徒弟今天已经领过免费宝箱了",
	[5526] = "今日点赞次数已达上限",
	[5527] = "上次解除的师父不是当前师父",
	[5528] = "当日取消拜师次数已达上限",
	[5529] = "当日收徒数量已达上限",
	[5530] = "广场信息过于火爆，请稍后再试",
	[5531] = "您拥有的道具数量不足",

	-- 点赞有礼
	[5601] = "宝箱已经领过了",
	[5602] = "宝箱已经领过了，不可参与点赞",
	[5603] = "取消点赞错误",
	[5604] = "点赞数已达上限",
	[5605] = "内容过长",
	[5606] = "还未点过赞，不能领取宝箱",
	[5607] = "建议提交过于频繁",

	-- 碎片兑换相关
	[5701] = "兑换失败，没有兑换规则",
	[5702] = "兑换失败，条件不满足",

	-- 抢红包
	[5801] = "参与条件不满足",
	[5802] = "红包已过期",
	[5803] = "红包已领完",
	[5804] = "领红包次数不足",
	[5805] = "当前红包已领取",
	[5806] = "发红包金额不满足条件",
	[5807] = "携带金额不满足领此红包条件",
	[5808] = "资产不足",
	[5809] = "不在游戏时间段内",
	[5810] = "游戏参与人数过多，稍后再试",
	[5811] = "场中存在您已发出但未抢完的红包，请抢完或者过期后再发",
	[5812] = "当前发红包人数过多，请稍后再试",
	[5813] = "红包数量不对",
	[5814] = "红包不存在",
	[5815] = "当前抢红包人数过多，请稍后再试",

	--- 权限
	[5901] = "权限错误",

	--- 捕鱼相关
	[5911] = "您正在活动中",
	[5912] = "您使用的道具无效",
	[5913] = "您使用的道具不能在当前场景使用",
	[5914] = "即将切换渔场不能使用冰冻",

	[5991] = "季卡到期或未购买，抽奖次数不足",
	[5992] = "游戏已选择，请选其他游戏",
	[5993] = "次数不足",

	-- 3d捕鱼-彩贝
	[6001] = "彩贝位置错误",
	[6002] = "彩贝状态错误",
	[6003] = "彩贝同时开启数量错误",
	[6004] = "彩贝类型错误",
	[6005] = "彩贝还未到时",
	[6006] = "彩贝已经可以领取",
	[6007] = "今天已免费领取最大次数",
	[6008] = "免费领取还在CD",
	[6009] = "格子已满，无法领取",
	[6010] = "快速领取，金币不够",

	-- 3d捕鱼-彩金鱼
	[6101] = "今天已到最大开奖次数",
	[6102] = "击杀彩金鱼数量不够",
	[6103] = "分数不满足",
	[6104] = "彩贝类型错误",
	[6105] = "彩贝还未到时",
	[6106] = "彩贝已经可以领取",
	[6107] = "今天已免费领取最大次数",
	[6108] = "免费领取还在CD",

	-- 3d捕鱼-转盘
	[6201] = "不满足转盘抽奖状态",

	-- 3d捕鱼-六合一
	[6301] = "不满足六合一抽奖状态",


	--- 自建房
	[6201] = "底分条件设置有误，请检查",
	[6202] = "入场条件设置有误，请检查",
	[6203] = "房主不用点准备，只能开始游戏",
	[6204] = "密码输入错误",
	[6205] = "规则没有变动",
	[6206] = "玩家准备人数不足",

		--- 昵称与头像
	[6300] = "昵称不能为空，请修改后重试",
	[6302] = "此昵称已被占用，请修改后重试",
	[6303] = "此昵称含有敏感词汇，请修改后重试",
	[6304] = "此昵称含有特殊字符，请修改后重试",
	[6305] = "此昵称过长，请修改后重试",

	[6306] = "您的VIP等级不足，升级VIP即可体验尊贵权限",
	[6307] = "切换头像需间隔60秒，请稍后再试~",
	[6308] = "修改昵称需间隔60秒，请稍后再试~",
	[6309] = "您的玩家等级不足，升级玩家等级即可体验尊贵权限",

	-- 奖池
	[6310] = "抽奖条件不满足",
	[6311] = "抽奖次数不足",
	[6401] = "当前已在争夺龙王中，不可再次争夺。",
	[6402] = "当前争夺龙王排队已满，请稍后再争夺。",
	[6403] = "你当前不在争夺龙王队列中",
	[6404] = "当前不可争夺龙王",
}




