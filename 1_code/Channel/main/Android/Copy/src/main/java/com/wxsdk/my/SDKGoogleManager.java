package com.wxsdk.my;

import android.util.Log;

import androidx.lifecycle.LiveData;

import com.changleyou.domino.UnityApplication;
import com.changleyou.domino.UnityPlayerActivity;
import com.wxsdk.my.billing.BillingDataSource;
import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.android.play.core.tasks.Task;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

public class SDKGoogleManager {

    static ReviewInfo reviewInfo;
    static ReviewManager manager;
    public static void init()
    {
    }

    // 请求 ReviewInfo 对象
    public static void HandleGGReview(String json_data)
    {
        manager = ReviewManagerFactory.create(UnityPlayerActivity.instance);

        Task<ReviewInfo> request = manager.requestReviewFlow();
        request.addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                // We can get the ReviewInfo object
                reviewInfo = task.getResult();
                String str = new JsonToString()
                        .AddJSONObject("result", 0)
                        .AddJSONObject("msg", "review")
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
            } else {
                // There was some problem, log or handle the error code.
//                @ReviewErrorCode int reviewErrorCode = ((TaskException) task.getException()).getErrorCode();
                String err = task.getException().toString();
                String str = new JsonToString()
                        .AddJSONObject("result", 1)
                        .AddJSONObject("msg", "review")
                        .AddJSONObject("err", err)
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

            }
        });
    }
    // 调起评价弹窗
    public static void HandleGGLaunchReview(String json_data)
    {
        if (reviewInfo != null)
        {
            Task<Void> flow = manager.launchReviewFlow(UnityPlayerActivity.instance, reviewInfo);
            flow.addOnCompleteListener(task -> {
                // The flow has finished. The API does not indicate whether the user
                // reviewed or not, or even whether the review dialog was shown. Thus, no
                // matter the result, we continue our app flow.
                String str = new JsonToString()
                        .AddJSONObject("result", 0)
                        .AddJSONObject("msg", "launch_review")
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
            });
        }
    }

    public static void HandleGGInit(String json_data)
    {
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String skus = jsonObject.getString("INAPP_SKUS");
            String auto_skus = jsonObject.getString("AUTO_CONSUME_SKUS");
            String sub_skus = jsonObject.getString("SUBSCRIPTION_SKUS");

            Log.i("Google","GooglePlay skus="+skus);
            Log.i("Google","GooglePlay auto_skus="+auto_skus);
            String[] skus_list = skus.split("#");
            String[] auto_skus_list = auto_skus.split("#");
            String[] sub_skus_list = sub_skus.split("#");

            Log.i("Google","GooglePlay skus_list.length="+skus_list.length);
            Log.i("Google","GooglePlay auto_skus_list.length="+auto_skus_list.length);
            Log.i("Google","GooglePlay sub_skus_list.length="+sub_skus_list.length);

            try {
                BillingDataSource.getInstance(
                        UnityApplication.appInstance,
                        skus_list,
                        sub_skus_list,
                        auto_skus_list);
                Log.i("Google","GooglePlay 1111111111111");

                String str = new JsonToString()
                        .AddJSONObject("result", 0)
                        .AddJSONObject("msg", "init")
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

            }catch(Exception e) {
                String str = new JsonToString()
                        .AddJSONObject("result", -1)
                        .AddJSONObject("msg", "init")
                        .AddJSONObject("err", e.getMessage())
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
            }

        }catch(Exception e) {
            try {
                String str = new JsonToString()
                        .AddJSONObject("result", -2)
                        .AddJSONObject("msg", "init")
                        .AddJSONObject("err", e.getMessage())
                        .GetString();
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

            }catch(Exception ee) {
            }
        }
    }
    // 发起购买
    public static void HandleGGBuy(String json_data) {
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String productId = jsonObject.getString("productId");
            String orderId = jsonObject.getString("orderId");
            BillingDataSource.sInstance.launchBillingFlow(UnityPlayerActivity.instance, orderId, productId);

        }catch(Exception e) {
            String str = new JsonToString()
                    .AddJSONObject("result", -1)
                    .AddJSONObject("msg", "buy")
                    .AddJSONObject("err", e.getMessage())
                    .GetString();
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGGBuyResult", str);
        }
    }

    // 关闭订单--购买完成后
    public static void HandleGGConsumeInappPurchase(String sku) {
        BillingDataSource.sInstance.consumeInappPurchase(sku);
    }
    // 异步刷新购买
    public static void HandleGGRefreshPurchasesAsync(String json_data) {
        BillingDataSource.sInstance.refreshPurchasesAsync();
    }

    // 查询商品信息
    public static void HandleGGQuerySkuDetailsAsync(String json_data) {
        BillingDataSource.sInstance.querySkuDetailsAsync();
    }
    // 是否连接
    public static boolean HandleGGIsReady() {
        return BillingDataSource.sInstance.IsReady();
    }
    // 发起连接
    public static void HandleGGConnection()
    {
        BillingDataSource.sInstance.onBillingServiceDisconnected();
    }
    // 是否已经购买
    public static boolean HandleGGIsPurchased(String sku) {
        LiveData<Boolean> liveData = BillingDataSource.sInstance.isPurchased(sku);
        boolean  b = false;
        if (liveData != null && liveData.getValue() != null)
        {
            b = liveData.getValue();
            if (b)
                Log.i("GGLog", "[Debug GG]HandleGGIsPurchased = true");
            else
                Log.i("GGLog", "[Debug GG]HandleGGIsPurchased = false");
        }
        else
            Log.i("GGLog", "[Debug GG]HandleGGIsPurchased = false liveData=null");
        return b;
    }

    // 是否可以购买
    public static boolean HandleGGCanPurchased(String sku) {
        LiveData<Boolean> liveData = BillingDataSource.sInstance.canPurchase(sku);
        boolean  b = true;
        if (liveData != null && liveData.getValue() != null)
        {
            b = liveData.getValue();
            if (b)
                Log.i("GGLog", "[Debug GG]HandleGGCanPurchased = true");
            else
                Log.i("GGLog", "[Debug GG]HandleGGCanPurchased = false");
        }
        else
            Log.i("GGLog", "[Debug GG]HandleGGCanPurchased = true liveData=null");
        return b;
    }

    // 是否正在进行计费流
    public static boolean HandleGGBillingFlowInProcess(String sku) {
        LiveData<Boolean> liveData = BillingDataSource.sInstance.getBillingFlowInProcess();
        boolean  b = false;
        if (liveData != null && liveData.getValue() != null)
        {
            b = liveData.getValue();
            if (b)
                Log.i("GGLog", "[Debug GG]HandleGGBillingFlowInProcess = true");
            else
                Log.i("GGLog", "[Debug GG]HandleGGBillingFlowInProcess = false");
        }
        else
            Log.i("GGLog", "[Debug GG]HandleGGBillingFlowInProcess = false liveData=null");
        return b;
    }

    public static String HandleGGSkuTitle(String sku) {
        LiveData<String> liveData = BillingDataSource.sInstance.getSkuTitle(sku);
        Log.i("GGLog", "[Debug GG]HandleGGSkuTitle = " + liveData.getValue());
        return liveData.getValue();
    }

    public static String HandleGGSkuPrice(String sku) {
        LiveData<String> liveData = BillingDataSource.sInstance.getSkuPrice(sku);
        Log.i("GGLog", "[Debug GG]HandleGGSkuPrice = " + liveData.getValue());
        return liveData.getValue();
    }

    public static String HandleGGSkuDescription(String sku) {
        LiveData<String> liveData = BillingDataSource.sInstance.getSkuDescription(sku);
        Log.i("GGLog", "[Debug GG]HandleGGSkuDescription = " + liveData.getValue());
        return liveData.getValue();
    }

}
