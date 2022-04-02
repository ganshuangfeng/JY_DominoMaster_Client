--手牌类型,值越大的，手牌的价值越大
QiuQiuEnum = {}
QiuQiuEnum.CardType = {
	SixDevil = 6,-- 四张牌点数均为6，最大的特殊牌
	TwinCards = 5, -- 对子牌，上下的牌点数相同
	SmallCards = 4, -- 四张牌的总点数小于等于9
	BigCards = 3, -- 四张牌的总点数大于等于39
	QiuQiu = 2, -- 两对牌的点数均为9
	kartuBiasa = 1,-- 基本牌
}