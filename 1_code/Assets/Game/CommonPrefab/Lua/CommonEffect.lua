-- 创建时间:2021-11-08

CommonEffects = {}
M = CommonEffects

function M.PlayAddGold(parent,pos,t,scale)
    local obj = newObject("GX_touxiang_gx",parent)
    obj.transform.position = pos
    obj.transform.localScale = scale or Vector3.one
    obj.gameObject:SetActive(false)
    local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
    seq:AppendCallback(function ()
        obj.gameObject:SetActive(true)
	end)
    t = t or 3
    GameObject.Destroy(obj,5)
end
