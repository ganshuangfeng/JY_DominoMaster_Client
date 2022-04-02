package com.wxsdk.my;

import org.json.JSONObject;

public class JsonToString {
    private JSONObject jsonObj;
    public JsonToString()
    {
        jsonObj = new JSONObject();
    };
    public JsonToString AddJSONObject(String key, Object val) {
        try {
            jsonObj.put(key, val);
        }catch(Exception e) {}
        return this;
    }
    public String GetString()
    {
        String str = jsonObj.toString();
        return str;
    }
}
