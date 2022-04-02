package com.wxsdk.my;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.changleyou.domino.R;
import com.changleyou.domino.UnityPlayerActivity;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.appsflyer.AppsFlyerLib;

import java.util.Map;
import java.util.Set;

public class FirebaseEvent extends FirebaseMessagingService  {
    private static  String TAG = "Firebase Messaging:";
    private static FirebaseAnalytics mFirebaseAnalytics;

    public static FirebaseEvent instance = null;

    private static String messagingToken = "";
    public static void init()
    {
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(UnityPlayerActivity.instance);
        instance = new FirebaseEvent();
    }

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        messagingToken = token;
        // Sending new token to AppsFlyer
        Log.w(TAG, TAG+" messagingToken AAA=" + messagingToken);
        AppsFlyerLib.getInstance().updateServerUninstallToken(getApplicationContext(), token);
    }
    // 获取Token
    public void GetMessagingData(String json_data)
    {
        if (json_data.equals("get"))
        {
            FirebaseMessaging.getInstance().getToken().addOnCompleteListener(new OnCompleteListener<String>() {
                @Override
                public void onComplete(@NonNull Task<String> task) {
                    if (!task.isSuccessful()) {
                        Log.w(TAG, "Fetching FCM registration token failed", task.getException());
                        UnityPlayer.UnitySendMessage("SDK_callback", "GetMessagingDataResult", "Fetching FCM registration token failed");
                        return;
                    }
                    String token = task.getResult();
                    Log.w(TAG, TAG+" messagingToken CCC=" + token);
                    try {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("result", 0);
                        jsonObject.put("token", token);

                        String str = jsonObject.toString();
                        Log.i("Firebase","Firebase GetMessagingData = " + str);

                        UnityPlayer.UnitySendMessage("SDK_callback", "GetMessagingDataResult", str);

                    }catch(Exception e) {
                        UnityPlayer.UnitySendMessage("SDK_callback", "GetMessagingDataResult", "error:"+e.toString());
                    }
                }
            });
        }
        else
        {
            Log.w(TAG, TAG+" messagingToken BBB=" + messagingToken);
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("token", messagingToken);

                String str = jsonObject.toString();
                Log.i("Firebase","Firebase GetMessagingData = " + str);

                UnityPlayer.UnitySendMessage("SDK_callback", "GetMessagingDataResult", str);

            }catch(Exception e) {
                UnityPlayer.UnitySendMessage("SDK_callback", "GetMessagingDataResult", "error:"+e.toString());
            }
        }
    }
    // 订阅主题
    public void OnSubscribeToTopic(String json_data)
    {
        FirebaseMessaging.getInstance().subscribeToTopic(json_data).addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                int code = 0;
                String msg = task.toString();
                if (!task.isSuccessful()) {
                    code = 1;
                }
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("result", 0);
                    jsonObject.put("code", code);
                    jsonObject.put("msg", "subscribe");
                    jsonObject.put("task", msg);

                    String str = jsonObject.toString();
                    Log.i("Firebase","Firebase OnSubscribeToTopic = " + str);

                    UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", str);

                }catch(Exception e) {
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "subscribe error:"+e.toString());
                }
            }
        });
    }
    // 退订主题
    public void OnUnsubscribeFromTopic(String json_data)
    {
        FirebaseMessaging.getInstance().unsubscribeFromTopic(json_data).addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                int code = 0;
                String msg = task.toString();
                if (!task.isSuccessful()) {
                    code = 1;
                }
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("result", 0);
                    jsonObject.put("code", code);
                    jsonObject.put("msg", "unsubscribe");
                    jsonObject.put("task", msg);

                    String str = jsonObject.toString();
                    Log.i("Firebase","Firebase OnSubscribeToTopic = " + str);

                    UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", str);

                }catch(Exception e) {
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "unsubscribe error:"+e.toString());
                }
            }
        });
    }

    // 发送上行消息
    public void SendUpstream(String json_data)
    {
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String SENDER_URL = jsonObject.getString("SENDER_URL");
            String messageId = jsonObject.getString("messageId");
            String message = jsonObject.getString("message");
            String action = jsonObject.getString("action");

            // [START fcm_send_upstream]
            FirebaseMessaging fm = FirebaseMessaging.getInstance();
            fm.send(new RemoteMessage.Builder(SENDER_URL)
                    .setMessageId(messageId)
                    .addData("my_message", message)
                    .addData("my_action", action)
                    .build());
            // [END fcm_send_upstream]
            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "SendUpstream success");
        }
        catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "SendUpstream error:"+e.toString());
        }
    }
    @Override
    public void onSendError(@NonNull String var1, @NonNull Exception var2) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("msg", "SendUpstream");
            jsonObject.put("var1", var1);
            jsonObject.put("err", var2.toString());

            String str = jsonObject.toString();
            Log.i("Firebase","Firebase SendUpstream = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", str);

        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "SendUpstream onSendError error:"+e.toString());
        }
    }
    @Override
    public void onMessageSent(@NonNull String var1) {
        UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "SendUpstream onMessageSent var1:"+var1);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("msg", "message_received");

            Set< Map.Entry<String, String> > data = remoteMessage.getData().entrySet();
            for (Map.Entry<String, String> me : data)
            {
                String key = me.getKey();
                String value = me.getValue();
                jsonObject.put(key, value);
                Log.i(TAG,TAG + " onMessageReceived=" + key + "---" + value);
            }
            String str = jsonObject.toString();
            Log.i("Firebase","Firebase onMessageReceived = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", str);

            if(remoteMessage.getData().containsKey("af-uinstall-tracking")){
                return;
            } else {
                handleNotification(remoteMessage);
            }
        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnFirebaseComCallback", "message_received error:"+e.toString());
        }
    }
    private void handleNotification(RemoteMessage remoteMessage)
    {

    }

    @Override
    public void onDeletedMessages()
    {
        super.onDeletedMessages();
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
                Bundle bundle = new Bundle();
                for(int i = 0; i < parm_list.length; i = i + 3)
                {
                    String a = parm_list[i];
                    String b = parm_list[i+1];
                    String c = parm_list[i+2];
                    if (b == "string")
                        bundle.putString(a, c);
                    else if (b == "double")
                        bundle.putDouble(a, Double.parseDouble(c));
                    else if (b == "int")
                        bundle.putInt(a, Integer.parseInt(c));
                    else if (b == "float")
                        bundle.putFloat(a, Float.parseFloat(c));
                    else if (b == "long")
                        bundle.putLong(a, Long.parseLong(c));
                    else if (b == "bool")
                        if (c == "1")
                            bundle.putBoolean(a, true);
                        else
                            bundle.putBoolean(a, false);

                }
                mFirebaseAnalytics.logEvent(event, bundle);
            }
            else
            {
                String str = new JsonToString()
                        .AddJSONObject("result", 1)
                        .AddJSONObject("msg", "firebase_event")
                        .AddJSONObject("err","LogEvent Error:size % 3")
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
            }

        }catch(Exception e) {
            String str = new JsonToString()
                    .AddJSONObject("result", 2)
                    .AddJSONObject("msg", "firebase_event")
                    .AddJSONObject("err","LogEvent Error:" + e.toString())
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
        }
    }
}
