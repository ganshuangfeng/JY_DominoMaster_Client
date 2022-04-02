package com.wxsdk.my;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import com.changleyou.domino.UnityPlayerActivity;
import com.unity3d.player.UnityPlayer;


import java.io.File;


/**
 * Created by Administrator on 2016/9/6 0006.
 */
public class SDKController {
    private static SDKController _instance;
    private  SDKController(){};

    private boolean m_isLogining = false;
    public boolean isLogining() { return m_isLogining; }
    public void markLogining(boolean value) { m_isLogining = value; }

	private boolean m_isRelogin = false;
    public boolean isRelogin() { return m_isRelogin; }
    public void markRelogin(boolean value) { m_isRelogin = value; }

    private UnityPlayerActivity mainActivity;
    public static SDKController GetInstance(){
        if(_instance == null)
        {
            _instance = new SDKController();
        }
        return _instance;
    }

    private final String WXID = "wx2ab55998a2d85119";
    public String getWXID() { return WXID; }
    public void RegisterWeChat(Context context) {
    }

    public void HandleInit(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleInit exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "InitResult", String.format("{result:%d}", result));
    }
    public void HandleLogin(String json_data) {

    }
    public void HandleLoginOut(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLoginOut exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "LoginOutResult", String.format("{result:%d}", result));
    }
	public void HandleRelogin(String json_data) {

    }
    public void HandlePay(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePay exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", String.format("{result:%d}", result));
    }
    public void HandleShowAccountCenter(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleShowAccountCenter exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "ShowAccountCenterResult", String.format("{result:%d}", result));
    }

    public void HandleScanFile(String filePath) {
        int result = 0;
        try{
            Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            scanIntent.setData(Uri.fromFile(new File(filePath)));
        }catch (Exception e){
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleScanFile exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleScanFileResult", String.format("{result:%d}", result));
    }

    public void onAppCreate(Application application) {
    }
    public void onAppDestroy() {
    }
    public void onActivityCreate(UnityPlayerActivity activity) {
        mainActivity = activity;
        RegisterWeChat(activity);
    }
    public void onActivityDestroy() {
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    }

    public void onResume() {
        if(isLogining()) {
            markLogining(false);
            UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", String.format("{result:%d}", -4));
        }
    }

    public void onPause() {
    }

    public void onStart() {
    }
    public void onStop() {
    }



    private String m_pushDeviceToken = "";
    public String GetPushDeviceToken() {
        return m_pushDeviceToken;
    }


}

