package com.wxsdk.my;

import android.content.Intent;
import android.util.Log;

import com.changleyou.domino.UnityPlayerActivity;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.Profile;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.unity3d.player.UnityPlayer;

import java.util.Arrays;

public class SDKFacebookManager {
    private static CallbackManager callbackManager;
    private static LoginManager loginManager;
    private static final String PUBLIC_PROFILE = "public_profile"; //

    static LoginManager getLoginManager() {
        if (loginManager == null) {
            loginManager = LoginManager.getInstance();
        }
        return loginManager;
    }
    public static void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    public static void init()
    {

        callbackManager = CallbackManager.Factory.create();

        getLoginManager().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        Log.i("onSuccess", "HandleFBLogin4 登录成功！");
                        FBLoginCall(loginResult.getAccessToken());
                    }

                    @Override
                    public void onCancel() {
                        Log.i("onCancel", "HandleFBLogin2 onCancel");
                        String str = new JsonToString()
                                .AddJSONObject("result", 2)
                                .AddJSONObject("msg", "FB")
                                .GetString();
                        UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLoginResult", str);
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        Log.i("onError", "HandleFBLogin3 onError "+exception.toString());
                        exception.printStackTrace();
                        String str = new JsonToString()
                                .AddJSONObject("result", 1)
                                .AddJSONObject("msg", "FB")
                                .AddJSONObject("err", exception.toString())
                                .GetString();
                        UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLoginResult", str);
                    }
                });
    }
    private static void FBLoginCall(AccessToken accessToken) {
        boolean isLoggedIn = accessToken != null;
        Profile profile = Profile.getCurrentProfile();
        Log.i("Debug SS","HandleFBLogin5 ");
        if (profile != null)
            Log.i("Debug SS","HandleFBLogin8 ");
        else
            Log.i("Debug SS","HandleFBLogin9 ");
        if (isLoggedIn) {
            String userId = accessToken.getUserId();
            String token = accessToken.getToken();
            String name = "";
            if (profile != null) {
                name = profile.getName();
            }
            Log.i("[FB]", "HandleFBLogin10 token:"+token + " userId:"+userId + " name:"+name);
            String str = new JsonToString()
                    .AddJSONObject("result", 0)
                    .AddJSONObject("msg", "FB")
                    .AddJSONObject("token", token)
                    .AddJSONObject("fb_id", userId)
                    .AddJSONObject("name", name)
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLoginResult", str);
        }
        else {
            Log.i("Debug SS","HandleFBLogin20 ");
            String str = new JsonToString()
                    .AddJSONObject("result", 1)
                    .AddJSONObject("msg", "FB")
                    .AddJSONObject("err", "登陆Facebook失败")
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLoginResult", str);
        }
    }

    public static void HandleFBLogin(String json_data) {
        Log.i("Debug SS","HandleFBLogin1 "+json_data);
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        boolean isLoggedIn = accessToken != null && !accessToken.isExpired();
        if (isLoggedIn)
        {
            FBLoginCall(accessToken);
        }
        else
            getLoginManager().logInWithReadPermissions(UnityPlayerActivity.instance, Arrays.asList("gaming_profile","gaming_user_picture"));
    }
    public static void HandleFBLogOut(String json_data) {
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        boolean isLoggedIn = accessToken != null && !accessToken.isExpired();
        if (json_data == "force") {
            getLoginManager().logOut();
            String str = new JsonToString()
                    .AddJSONObject("result", 0)
                    .AddJSONObject("msg", "FB")
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLogOutResult", str);
        }
        else
        if (isLoggedIn) {
            getLoginManager().logOut();
            String str = new JsonToString()
                    .AddJSONObject("result", 0)
                    .AddJSONObject("msg", "FB")
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "HandleFBLogOutResult", str);
        }
    }
}
