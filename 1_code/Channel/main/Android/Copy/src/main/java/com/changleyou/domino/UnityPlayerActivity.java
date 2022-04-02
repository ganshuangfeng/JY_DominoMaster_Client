package com.changleyou.domino;

import com.wxsdk.my.DeviceIdUtil;
import com.wxsdk.my.SDKGoogleSignInActivity;
import com.wxsdk.my.billing.BillingDataSource;
import com.tbruyelle.rxpermissions2.RxPermissions;
import com.unity3d.player.*;

import android.Manifest;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Window;
import android.widget.Toast;


import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.File;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

//weixin
import com.wxsdk.my.AppsFlyerEvent;
import com.wxsdk.my.FirebaseEvent;
import com.wxsdk.my.SDKController;
import com.wxsdk.my.SDKFacebookManager;
import com.wxsdk.my.SDKGoogleManager;

import org.json.JSONObject;

import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;


public class UnityPlayerActivity extends Activity
{
    protected UnityPlayer mUnityPlayer; // don't change the name of this variable; referenced from native code

    protected final int REQUEST_ALL_PERMISSION = 1000;

    private Vibrator m_vibrator;
    private RxPermissions m_rxPermissions;

    private AssetManager m_assetManager;
    private byte[] m_assetBuffer;

    private String m_deviceID;
    public String DeviceID(String tt) {
        Log.i("1", "DeviceIDDeviceID 111=" + tt);
        if (tt.equals("uuid")) {
            Log.i("1", "DeviceIDDeviceID 222=" + tt);
            return DeviceIdUtil.getDeviceId(UnityPlayerActivity.instance);
        }
        if (tt.equals("mac2"))
        {
            return getMacAddress();
        }

        Log.i("1", "DeviceIDDeviceID 444=" + tt);
        return "currentTimeMillis:" + String.valueOf( System.currentTimeMillis() );
    }
    public String getMacAddress() {
        try {
            List<NetworkInterface> all = Collections.list(NetworkInterface.getNetworkInterfaces());
            for (NetworkInterface nif : all) {
                if (!nif.getName().equalsIgnoreCase("wlan0")) continue;

                byte[] macBytes = nif.getHardwareAddress();
                if (macBytes == null) {
                    return "";
                }
                StringBuilder res1 = new StringBuilder();
                for (byte b : macBytes) {
                    res1.append(String.format("%02X:",b));
                }
                if (res1.length() > 0) {
                    res1.deleteCharAt(res1.length() - 1);
                }
                return res1.toString();
            }
        } catch (Exception ex) {
        }
        return "";
    }

    private String m_deeplink;
    private void UpdateDeeplink() {
        Uri data = getIntent().getData();
        if(data == null)
            return;

        try {
            String scheme = data.getScheme(); // "will"
            String host = data.getHost(); // "share"

            m_deeplink = new String(data.toString());
            getIntent().setData(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public String Deeplink()
    {
        m_deeplink = "";
        UpdateDeeplink();
        return m_deeplink;
    }
    public String PushDeviceToken() {
        return SDKController.GetInstance().GetPushDeviceToken();
    }

    public void CallUp(String val)
    {
        Intent intent = new Intent(Intent.ACTION_DIAL);
        Uri data = Uri.parse("tel:" + val);
        intent.setData(data);
        startActivity(intent);
    }

    public byte[] LoadingFile(String fileName) {
        try {
            InputStream inputStream = m_assetManager.open(fileName);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            int length = 0;
            while((length = inputStream.read(m_assetBuffer)) != -1)
                outputStream.write(m_assetBuffer, 0, length);
            outputStream.close();
            inputStream.close();
            return outputStream.toByteArray();
        } catch(IOException e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","LoadingFile Exception: " + e.toString());
            return null;
        }
    }

    public void ForceQuiting() {
        System.exit(0);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if(requestCode == REQUEST_ALL_PERMISSION)
            ;//PushAgent.getInstance(this).onAppStart();
        else
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i("Debug SS", "onActivityResult requestCode:"+requestCode+"  resultCode:"+resultCode);
        SDKFacebookManager.onActivityResult(requestCode, resultCode, data);
        SDKController.GetInstance().onActivityResult(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data);
    }


    public void HandleInit(String json_data) {
        SDKController.GetInstance().HandleInit(json_data);
    }
    public void HandleLogin(String json_data) {
        SDKController.GetInstance().HandleLogin(json_data);
    }
    public void HandleLoginOut(String json_data) {
        SDKController.GetInstance().HandleLoginOut(json_data);
    }
    public void HandleRelogin(String json_data) {
        SDKController.GetInstance().HandleRelogin(json_data);
    }
    public void HandlePay(String json_data) {
        SDKController.GetInstance().HandlePay(json_data);
    }
    public void HandleShowAccountCenter(String json_data) {
        SDKController.GetInstance().HandleShowAccountCenter(json_data);
    }

    public void HandleSendToSDKMessage(String json_data) {
        //SDKController.GetInstance().HandleSendToSDKMessage(json_data);
    }

    public void HandleScanFile(String filePath) {
        // Log.i("destination", destination);
        // SDKController.GetInstance().HandleScanFile(destination);
        Log.i("Unity", "------------filePath"+filePath);
        int result = 0;
        try{
            Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            scanIntent.setData(Uri.fromFile(new File(filePath)));
            this.sendBroadcast(scanIntent);//我这边 this 是UnityPlayerActivity
        }catch (Exception e){
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleScanFile exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleScanFileResult", String.format("{result:%d}", result));
    }


    public void StartAc(String appId) {
		/*Toast.makeText(MainActivity.Instance, "////////////",
				Toast.LENGTH_SHORT).show();*/
        Toast.makeText(this, "////////////",
                Toast.LENGTH_SHORT).show();
    }

    private void checkPermission() {
        String[] mPermissionList = new String[] {
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE
        };

        m_rxPermissions = new RxPermissions(this);

        m_rxPermissions
                .request(mPermissionList)
                .subscribe(new Observer<Boolean>() {
                    @Override
                    public void onSubscribe(Disposable d) {
                        Log.i("", "onSubscribe");
                    }
                    @Override
                    public void onNext(Boolean value) {
                        //  value 为ture  说明权限都开启，只要所请求权限有一个为关闭 ，则为false
                        if (value) {
                            //Toast.makeText(UnityPlayerActivity.this, "权限", Toast.LENGTH_SHORT).show();
                        } else {
                            //Toast.makeText(UnityPlayerActivity.this, "拒绝权限", Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onError(Throwable e) {
                        Log.i("", "onError" + e.toString());
                    }

                    @Override
                    public void onComplete() {
                        Log.i("", "onComplete");
                    }
                });
    }

    protected String updateUnityCommandLineArguments(String cmdLine)
    {
        return cmdLine;
    }

    public static UnityPlayerActivity instance;
    // Setup activity layout
    @Override protected void onCreate(Bundle savedInstanceState)
    {
        instance = this;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);

        String cmdLine = updateUnityCommandLineArguments(getIntent().getStringExtra("unity"));
        getIntent().putExtra("unity", cmdLine);

        mUnityPlayer = new UnityPlayer(this);
        setContentView(mUnityPlayer);
        mUnityPlayer.requestFocus();

//        checkPermission();


        SDKController.GetInstance().onActivityCreate(this);

        m_vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);

        m_assetManager = getAssets();
        m_assetBuffer = new byte[2048];

        SDKFacebookManager.init();
        SDKGoogleManager.init();
        FirebaseEvent.init();
    }

    public void RunVibrator(long tt)
    {
        m_vibrator.vibrate(tt);
    }
    @Override protected void onNewIntent(Intent intent)
    {
        // To support deep linking, we need to make sure that the client can get access to
        // the last sent intent. The clients access this through a JNI api that allows them
        // to get the intent set on launch. To update that after launch we have to manually
        // replace the intent with the one caught here.
        setIntent(intent);
    }

    // Quit Unity
    @Override protected void onDestroy ()
    {
        mUnityPlayer.quit();
        super.onDestroy();
    }

    // Pause Unity
    @Override protected void onPause()
    {
        super.onPause();
        mUnityPlayer.pause();
        SDKController.GetInstance().onPause();
    }

    // Resume Unity
    @Override protected void onResume()
    {
        super.onResume();
        mUnityPlayer.resume();
        SDKController.GetInstance().onResume();
        if (BillingDataSource.sInstance != null)
            BillingDataSource.sInstance.resume();
    }

    @Override protected void onStart()
    {
        super.onStart();
        mUnityPlayer.start();
        SDKController.GetInstance().onStart();
    }

    @Override protected void onStop()
    {
        super.onStop();
        SDKController.GetInstance().onStop();
        mUnityPlayer.stop();
    }

    // Low Memory Unity
    @Override public void onLowMemory()
    {
        super.onLowMemory();
        mUnityPlayer.lowMemory();
    }

    // Trim Memory Unity
    @Override public void onTrimMemory(int level)
    {
        super.onTrimMemory(level);
        if (level == TRIM_MEMORY_RUNNING_CRITICAL)
        {
            mUnityPlayer.lowMemory();
        }
    }

    // This ensures the layout will be correct.
    @Override public void onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
        mUnityPlayer.configurationChanged(newConfig);
    }

    // Notify Unity of the focus change.
    @Override public void onWindowFocusChanged(boolean hasFocus)
    {
        super.onWindowFocusChanged(hasFocus);
        mUnityPlayer.windowFocusChanged(hasFocus);
    }

    // For some reason the multiple keyevent type is not supported by the ndk.
    // Force event injection by overriding dispatchKeyEvent().
    @Override public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (event.getAction() == KeyEvent.ACTION_MULTIPLE)
            return mUnityPlayer.injectEvent(event);
        return super.dispatchKeyEvent(event);
    }

    // Pass any events not handled by (unfocused) views straight to UnityPlayer
    @Override public boolean onKeyUp(int keyCode, KeyEvent event)     { return mUnityPlayer.injectEvent(event); }
    @Override public boolean onKeyDown(int keyCode, KeyEvent event)   { return mUnityPlayer.injectEvent(event); }
    @Override public boolean onTouchEvent(MotionEvent event)          { return mUnityPlayer.injectEvent(event); }
    /*API12*/ public boolean onGenericMotionEvent(MotionEvent event)  { return mUnityPlayer.injectEvent(event); }

    // Facebook
    public void HandleFBLogin(String json_data) {
        SDKFacebookManager.HandleFBLogin(json_data);
    }
    public void HandleFBLogOut(String json_data) {
        SDKFacebookManager.HandleFBLogOut(json_data);
    }

    //Firebase
    public void GetMessagingData(String json_data)
    {
        FirebaseEvent.instance.GetMessagingData(json_data);
    }
    public void OnSubscribeToTopic(String json_data)
    {
        FirebaseEvent.instance.OnSubscribeToTopic(json_data);
    }
    public void OnUnsubscribeFromTopic(String json_data)
    {
        FirebaseEvent.instance.OnUnsubscribeFromTopic(json_data);
    }
    public void SendUpstream(String json_data)
    {
        FirebaseEvent.instance.SendUpstream(json_data);
    }

    // Google Play
    public void HandleGGInit(String json_data)
    {
        this.runOnUiThread(new Runnable() {
            public void run() {
                SDKGoogleManager.HandleGGInit(json_data);
            }
        });
    }
    // 发起购买
    public void HandleGGBuy(String json_data) {
        SDKGoogleManager.HandleGGBuy(json_data);
    }
    // 关闭订单--购买完成后
    public void HandleGGConsumeInappPurchase(String sku) {
        SDKGoogleManager.HandleGGConsumeInappPurchase(sku);
    }
    // 查询商品信息
    public void HandleGGQuerySkuDetailsAsync(String json_data) {
        SDKGoogleManager.HandleGGQuerySkuDetailsAsync(json_data);
    }
    // 是否连接
    public boolean HandleGGIsReady()
    {
        return SDKGoogleManager.HandleGGIsReady();
    }
    // 发起连接
    public void HandleGGConnection()
    {
        SDKGoogleManager.HandleGGConnection();
    }
    // 异步刷新购买
    public void HandleGGRefreshPurchasesAsync(String json_data) {
        SDKGoogleManager.HandleGGRefreshPurchasesAsync(json_data);
    }
    // 是否已经购买
    public boolean HandleGGIsPurchased(String sku) {
        return SDKGoogleManager.HandleGGIsPurchased(sku);
    }
    // 是否可以购买
    public boolean HandleGGCanPurchased(String sku) {
        return SDKGoogleManager.HandleGGCanPurchased(sku);
    }
    // 是否正在进行计费流
    public boolean HandleGGBillingFlowInProcess(String sku) {
        return SDKGoogleManager.HandleGGBillingFlowInProcess(sku);
    }
    public String HandleGGSkuTitle(String sku) {
        return SDKGoogleManager.HandleGGSkuTitle(sku);
    }
    public String HandleGGSkuPrice(String sku) {
        return SDKGoogleManager.HandleGGSkuPrice(sku);
    }
    public String HandleGGSkuDescription(String sku) {
        return SDKGoogleManager.HandleGGSkuDescription(sku);
    }
    public void HandleGGLogEvent(String json_data) {
        FirebaseEvent.LogEvent(json_data);
    }
    public void HandleGGReview(String json_data) {
        SDKGoogleManager.HandleGGReview(json_data);
    }
    public void HandleGGLaunchReview(String json_data) {
        SDKGoogleManager.HandleGGLaunchReview(json_data);
    }

    // Google Play SignIn SigOut RevokeAccess
    public void HandleGGSignIn(String json_data)
    {
        Intent intent =new Intent(UnityPlayerActivity.instance,SDKGoogleSignInActivity.class);
        //用Bundle携带数据
        Bundle bundle=new Bundle();
        bundle.putString("name", "SignIn");
        bundle.putString("json_data", json_data);
        intent.putExtras(bundle);
        startActivity(intent);
    }
    public void HandleGGSignOut(String json_data)
    {
        Intent intent =new Intent(UnityPlayerActivity.instance,SDKGoogleSignInActivity.class);
        //用Bundle携带数据
        Bundle bundle=new Bundle();
        bundle.putString("name", "SignOut");
        bundle.putString("json_data", json_data);
        intent.putExtras(bundle);
        startActivity(intent);
    }
    public void HandleGGRevokeAccess(String json_data)
    {
        Intent intent =new Intent(UnityPlayerActivity.instance,SDKGoogleSignInActivity.class);
        //用Bundle携带数据
        Bundle bundle=new Bundle();
        bundle.putString("name", "RevokeAccess");
        bundle.putString("json_data", json_data);
        intent.putExtras(bundle);
        startActivity(intent);
    }


    // AppsFlyer
    public String HandleAFConversionJsonData(String str)
    {
        if (str.equals("deeplink"))
            return AppsFlyerEvent.deepLinkJsonData;
        return AppsFlyerEvent.conversionJsonData;
    }
    public void HandleAFInit(String json_data)
    {
        this.runOnUiThread(new Runnable() {
            public void run() {
                AppsFlyerEvent.HandleAFInit(json_data);
            }
        });
    }
    public void HandleAFStart(String json_data)
    {
        this.runOnUiThread(new Runnable() {
            public void run() {
                AppsFlyerEvent.HandleAFStart(json_data);
            }
        });
    }
    public void HandleAFLogEvent(String json_data)
    {
        AppsFlyerEvent.LogEvent(json_data);
    }

}
