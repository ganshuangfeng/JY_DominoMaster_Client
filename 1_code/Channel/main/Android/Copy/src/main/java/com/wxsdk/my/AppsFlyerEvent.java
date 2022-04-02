package com.wxsdk.my;

import android.util.Log;

import androidx.annotation.NonNull;

import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;
import com.appsflyer.attribution.AppsFlyerRequestListener;
import com.appsflyer.deeplink.DeepLink;
import com.appsflyer.deeplink.DeepLinkListener;
import com.appsflyer.deeplink.DeepLinkResult;
import com.changleyou.domino.UnityApplication;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;


public class AppsFlyerEvent {
    public static String conversionJsonData = "";
    public static String deepLinkJsonData = "";
    static String dev_key = "93viJ9toj3aNrd5piaGXAR";

    static String LOG_TAG = "AppsFlyer";
    static String tt = "Unified Deep Linking (UDL)=";
    public static void init()
    {
        Log.i("AFLog", "XXXconversions.appsflyerXXX1");
        AppsFlyerLib.getInstance().setDebugLog(true);
        Log.i("AFLog", "XXXconversions.appsflyerXXX2");
        AppsFlyerEvent.HandleAFInit(dev_key);
        Log.i("AFLog", "XXXconversions.appsflyerXXX3");

        AppsFlyerLib.getInstance().subscribeForDeepLink(new DeepLinkListener(){
            @Override
            public void onDeepLinking(@NonNull DeepLinkResult deepLinkResult) {
                DeepLinkResult.Status dlStatus = deepLinkResult.getStatus();
                if (dlStatus == DeepLinkResult.Status.FOUND) {
                    Log.d(LOG_TAG, tt+"Deep link found");
                } else if (dlStatus == DeepLinkResult.Status.NOT_FOUND) {
                    Log.d(LOG_TAG, tt+"Deep link not found");
                    return;
                } else {
                    // dlStatus == DeepLinkResult.Status.ERROR
                    DeepLinkResult.Error dlError = deepLinkResult.getError();
                    Log.d(LOG_TAG, tt+"There was an error getting Deep Link data: " + dlError.toString());
                    return;
                }
                DeepLink deepLinkObj = deepLinkResult.getDeepLink();
                try {
                    Log.d(LOG_TAG, tt+"The DeepLink data is: " + deepLinkObj.toString());
                } catch (Exception e) {
                    Log.d(LOG_TAG, tt+"DeepLink data came back null");
                    return;
                }
                // An example for using is_deferred
                if (deepLinkObj.isDeferred()) {
                    Log.d(LOG_TAG, tt+"This is a deferred deep link");
                } else {
                    Log.d(LOG_TAG, tt+"This is a direct deep link");
                }
                // An example for using a generic getter
                String fruitName = "";
                try {
                    fruitName = deepLinkObj.getDeepLinkValue();
                    Log.d(LOG_TAG, tt+"The DeepLink will route to: " + fruitName);
                } catch (Exception e) {
                    Log.d(LOG_TAG, tt+"Custom param fruit_name was not found in DeepLink data");
                    return;
                }
                JsonToString jsonStr = new JsonToString();
                jsonStr.AddJSONObject("result", 0);
                jsonStr.AddJSONObject("fruitName", fruitName);
                jsonStr.AddJSONObject("deepLinkObj", deepLinkObj.toString());
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFConversion", jsonStr.GetString());
                AppsFlyerEvent.deepLinkJsonData = jsonStr.GetString();
//                goToFruit(fruitName, deepLinkObj);
            }
        });
        Log.i("AFLog", "XXXconversions.appsflyerXXX4");

        AppsFlyerEvent.start(dev_key, true);
        Log.i("AFLog", "XXXconversions.appsflyerXXX5");

    }


    public static void LogEvent(String json_data)
    {
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String fg = jsonObject.getString("fg");
            String event = jsonObject.getString("event");
            String parm = jsonObject.getString("parm");

            String[] parm_list = parm.split(fg);
            if (parm_list.length % 3 == 0)
            {
                Map<String, Object> eventValues = new HashMap<String, Object>();
                for(int i = 0; i < parm_list.length; i = i + 3)
                {
                    String a = parm_list[i];
                    String b = parm_list[i+1];
                    String c = parm_list[i+2];
                    if (b == "string")
                        eventValues.put(a, c);
                    else if (b == "double")
                        eventValues.put(a, Double.parseDouble(c));
                    else if (b == "int")
                        eventValues.put(a, Integer.parseInt(c));
                    else if (b == "float")
                        eventValues.put(a, Float.parseFloat(c));
                    else if (b == "long")
                        eventValues.put(a, Long.parseLong(c));
                    else if (b == "bool")
                        if (c == "1")
                            eventValues.put(a, true);
                        else
                            eventValues.put(a, false);

                }
                AppsFlyerLib.getInstance().logEvent(UnityApplication.appInstance, event, eventValues);
            }
            else
            {
                String str = new JsonToString()
                        .AddJSONObject("result", 1)
                        .AddJSONObject("msg", "event")
                        .AddJSONObject("err","LogEvent Error:size % 3")
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
            }

        }catch(Exception e) {
            String str = new JsonToString()
                    .AddJSONObject("result", 2)
                    .AddJSONObject("msg", "event")
                    .AddJSONObject("err","LogEvent Error:" + e.toString())
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
        }
    }


    static AppsFlyerLib apps_flyer_Lib;
    public static AppsFlyerLib getAppsFlyerLib()
    {
        if (apps_flyer_Lib == null)
            apps_flyer_Lib = AppsFlyerLib.getInstance();
        return apps_flyer_Lib;
    }

    // AppsFlyer
    public static void HandleAFInit(String json_data)
    {
        AppsFlyerConversionListener conversionListener =  new AppsFlyerConversionListener() {
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionDataMap) {
                JsonToString jsonStr = new JsonToString();
                for (String attrName : conversionDataMap.keySet()) {
                    Log.d(LOG_TAG, "AppsFlyerConversionListener Conversion attribute: " + attrName + " = " + conversionDataMap.get(attrName));
                    jsonStr.AddJSONObject(attrName, conversionDataMap.get(attrName));
                }
                String status = Objects.requireNonNull(conversionDataMap.get("af_status")).toString();
                if(status.equals("Organic")){
                    jsonStr.AddJSONObject("cly_game_conversion_type", "Organic");
                    // Business logic for Organic conversion goes here.
                }
                else {
                    jsonStr.AddJSONObject("cly_game_conversion_type", "Non-Organic");
                    // Business logic for Non-organic conversion goes here.
                }
                jsonStr.AddJSONObject("result", 0);
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFConversion", jsonStr.GetString());
                AppsFlyerEvent.conversionJsonData = jsonStr.GetString();
            }

            @Override
            public void onConversionDataFail(String errorMessage) {
                Log.d(LOG_TAG, "AppsFlyerConversionListener error getting conversion data: " + errorMessage);
                JsonToString jsonStr = new JsonToString();
                jsonStr.AddJSONObject("result", -1);
                jsonStr.AddJSONObject("errorMsg", errorMessage);
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFConversion", jsonStr.GetString());
                AppsFlyerEvent.conversionJsonData = jsonStr.GetString();
            }

            @Override
            public void onAppOpenAttribution(Map<String, String> attributionData) {
                Log.d(LOG_TAG, "AppsFlyerConversionListener onAppOpenAttribution AAA: ");
                JsonToString jsonStr = new JsonToString();
                for (String attrName : attributionData.keySet()) {
                    Log.d(LOG_TAG, "AppsFlyerConversionListener onAppOpenAttribution: " + attrName + " = " + attributionData.get(attrName));
                    jsonStr.AddJSONObject(attrName, attributionData.get(attrName));
                }
                // Must be overriden to satisfy the AppsFlyerConversionListener interface.
                // Business logic goes here when UDL is not implemented.
                jsonStr.AddJSONObject("result", -2);
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFConversion", jsonStr.GetString());
                AppsFlyerEvent.conversionJsonData = jsonStr.GetString();
            }

            @Override
            public void onAttributionFailure(String errorMessage) {
                // Must be overriden to satisfy the AppsFlyerConversionListener interface.
                // Business logic goes here when UDL is not implemented.
                Log.d(LOG_TAG, "AppsFlyerConversionListener error onAttributionFailure : " + errorMessage);
                JsonToString jsonStr = new JsonToString();
                jsonStr.AddJSONObject("result", -3);
                jsonStr.AddJSONObject("errorMsg", errorMessage);
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFConversion", jsonStr.GetString());
                AppsFlyerEvent.conversionJsonData = jsonStr.GetString();
            }
        };

        Log.i("AFLog", "HandleAFInit 1");

        try {
            Log.i("AFLog", "HandleAFInit 2");
            AppsFlyerLib.getInstance().init(json_data, conversionListener, UnityApplication.appInstance);
            JsonToString jsonStr = new JsonToString();
            jsonStr.AddJSONObject("result", 0);
            UnityPlayer.UnitySendMessage("SDK_callback", "OnAFInitResult", jsonStr.GetString());
        }catch(Exception e) {
            Log.i("AFLog", "HandleAFInit 7 errMsg=" + e.getMessage());
            JsonToString jsonStr = new JsonToString();
            jsonStr.AddJSONObject("result", -1);
            jsonStr.AddJSONObject("errorMsg", e.getMessage());
            UnityPlayer.UnitySendMessage("SDK_callback", "OnAFInitResult", jsonStr.GetString());
        }
    }

    public static void start(String app_dev_key, boolean isDebug)
    {
        Log.i("AFLog", "HandleAFStart start 1");
        getAppsFlyerLib().setDebugLog(isDebug);
        Log.i("AFLog", "HandleAFStart start 3");
        getAppsFlyerLib().start(UnityApplication.appInstance, app_dev_key, new AppsFlyerRequestListener() {
            @Override
            public void onSuccess() {
                Log.d("AFLog", "Launch sent successfully, got 200 response code from server");
                String str = new JsonToString()
                        .AddJSONObject("result", 0)
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFStartResult", str);
            }

            @Override
            public void onError(int i, @NonNull String s) {
                Log.d("AFLog", "Launch failed to be sent:\n" +
                        "Error code: " + i + "\n"
                        + "Error description: " + s);
                String str = new JsonToString()
                        .AddJSONObject("result", -1)
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnAFStartResult", str);
            }
        });
        Log.i("AFLog", "HandleAFStart start 5");
    }

    public static void HandleAFStart(String json_data)
    {
        Log.i("AFLog", "HandleAFStart 1");
        try {
            Log.i("AFLog", "HandleAFStart 2");
            JSONObject jsonObject = new JSONObject(json_data);
            String app_dev_key = jsonObject.getString("app_dev_key");
            String dd = jsonObject.getString("isDebug");
            boolean isDebug = false;
            Log.i("AFLog", "HandleAFStart 3");
            if (dd == "1")
                isDebug = true;
            AppsFlyerEvent.start(app_dev_key, isDebug);
        }catch(Exception e) {
            Log.i("AFLog", "HandleAFStart 6");
            String str = new JsonToString()
                    .AddJSONObject("result", -2)
                    .AddJSONObject("errMsg", e.getMessage())
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "OnAFStartResult", str);
        }
    }
}
