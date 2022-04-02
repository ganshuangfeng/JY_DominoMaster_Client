-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
GuideConfig = {
	{stepList= {{step={1,2,}, cfPos="hall"}}, next=2, isSkip=0},
	{stepList= {{step={3,}, cfPos="hall"}}, next=-1, isSkip=0},
}
--[[
1、选择游戏
2、大厅匹配场按钮，匹配场第一个场次
3、结算界面兑换按钮，确认兑换按钮
4、匹配场大厅返回按钮
5、大厅是兑换商城按钮
--]]

--[[
type= char对话 button按钮点击 GuideStyle1选择一块区域(功能描述引导)
name=内容
auto=是否连续执行
isHideBG=是否隐藏黑色背景
descPos=描述的位置
szPos=手指的偏移值
uiName=步骤所在UI的名字
topsizeDelta=区域大小
npcPos=NPC的位置
--]]
GuideNorStepConfig = {
	
	[1] = {
		id = 1,
		type="",
		name="",
		auto=false, 
		isSave=false,
		
		descPos={x=262, y=188, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=0, y=6},
		npcPos=nil,
		topsizeDelta = {x=262.1, y=201.1},
		bsdsmName = "click_xsyd_shtx",
	},
	[2] = {
		id = 2,
		type="button",
		name="@goto_btn",
		auto=true, 
		isSave=true,
		isHideBG = true,
		descPos={x=262, y=188, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=102, y=6},
		szRot={x=0,y=0,z=-135},
		npcPos=nil,
		topsizeDelta = {x=2000, y=2000},
		bsdsmName = "click_xsyd_shtx",
	},
	[3] = {
		id = 3,
		type="button",
		name="ShopDHPrefab2",
		auto=false, 
		isSave=true,
		
		desc=81080,
		descPos={x=262, y=188, z=0},
		descRot={x=0, y=0, z=180},
		szPos={x=0, y=6},
		npcPos=nil,
		topsizeDelta = {x=262.1, y=201.1},
		bsdsmName = "click_xsyd_shtx",
	},
}