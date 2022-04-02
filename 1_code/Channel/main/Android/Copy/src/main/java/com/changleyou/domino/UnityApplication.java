package com.changleyou.domino;

import android.app.Application;
import android.content.Context;

import com.appsflyer.AppsFlyerLib;
import com.wxsdk.my.AppsFlyerEvent;


public class UnityApplication extends Application {
    public static UnityApplication appInstance;

    @Override
    protected void attachBaseContext(Context ctx) {
        super.attachBaseContext(ctx);
    }
    @Override
    public void onCreate() {
        super.onCreate();
        appInstance = this;
        AppsFlyerEvent.init();
    }
}
