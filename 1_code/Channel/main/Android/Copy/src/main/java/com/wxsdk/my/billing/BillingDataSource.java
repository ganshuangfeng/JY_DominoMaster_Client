/*
 * Copyright (C) 2021 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.wxsdk.my.billing;

import android.app.Activity;
import android.app.Application;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.Transformations;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import com.unity3d.player.UnityPlayer;


import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * The BillingDataSource implements all billing functionality for our test application. Purchases
 * can happen while in the app or at any time while out of the app, so the BillingDataSource has to
 * account for that.
 * BillingDataSource?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????BillingDataSource?????????????????????
 *
 * <p>
 * Since every SKU can have an individual state, all SKUs have an associated LiveData to allow their
 * state to be observed.
 * ????????????SKU????????????????????????????????????????????????SKU?????????????????????LiveData????????????????????????????????????
 *
 * <p>
 * This BillingDataSource knows nothing about the application; all necessary information is either
 * passed into the constructor, exported as observable LiveData, or exported through callbacks. This
 * code can be reused in a variety of apps.
 * ???BillingDataSource?????????????????????????????????????????????????????????????????????????????????????????????????????????LiveData??????????????????????????????????????????????????????????????????????????????
 *
 * <p>
 * That being said, if you're using Kotlin with coroutines, there's no reason to have LiveData at
 * this layer. Same thing if you're using RxJava. This serves the need of decoupling the billing
 * state machine from the logic of the game, which is mostly implemented in the repository.
 * ???????????????????????????Kotlin??????????????????????????????????????????????????????????????????LiveData????????????????????????RxJava??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 *
 * <p>
 * Beginning a purchase flow involves passing an Activity into the Billing Library, but we merely
 * pass it along to the API.
 * ?????????????????????????????????????????????????????????????????????????????????????????????API???
 *
 * <p>
 * This data source has a few automatic features: 1) It checks for a valid signature on all
 * purchases before attempting to acknowledge them. 2) It automatically acknowledges all known SKUs
 * for non-consumables, and doesn't set the state to purchased until the acknowledgement is
 * complete. 3) The data source will automatically consume skus that are set in
 * knownAutoConsumeSKUs. As SKUs are consumed, a SingleLiveEvent will be triggered for a single
 * observer. 4) If the BillingService is disconnected, it will attempt to reconnect with exponential
 * fallback.
 * ???????????????????????????????????????
 * 1??? ??????????????????????????????????????????????????????????????????
 * 2??? ??????????????????????????????????????????SKU????????????????????????????????????????????????????????????????????????
 * 3??? ????????????????????????knownAutoConsumeSKUs????????????SKU????????????SKU?????????????????????????????????SingleLiveEvent???
 * 4??? ??????BillingService?????????????????????????????????????????????????????????
 *
 * <p>
 * This data source attempts to keep billing library specific knowledge confined to this file; The
 * only thing that clients of the BillingDataSource need to know are the SKUs used by their
 * application.
 * ?????????????????????????????????????????????????????????????????????BillingDataSource???????????????????????????????????????????????????SKU???
 *
 * <p>
 * The BillingClient needs access to the Application context in order to bind the remote billing
 * service.
 * BillingClient??????????????????????????????????????????????????????????????????
 *
 * <p>
 * The BillingDataSource can also act as a LifecycleObserver for an Activity; this allows it to
 * refresh purchases during onResume.
 * BillingDataSource???????????????????????????????????????????????????????????????onResume?????????????????????
 *
 */
public class BillingDataSource implements LifecycleObserver, PurchasesUpdatedListener,
        BillingClientStateListener, SkuDetailsResponseListener {
    private static final String TAG = "TrivialDrive:" + BillingDataSource.class.getSimpleName();
    private static final long RECONNECT_TIMER_START_MILLISECONDS = 1L * 1000L;
    private static final long RECONNECT_TIMER_MAX_TIME_MILLISECONDS = 1000L * 60L * 15L; // 15 mins
    private static final long SKU_DETAILS_REQUERY_TIME = 1000L * 60L * 60L * 4L; // 4 hours
    private static final Handler handler = new Handler(Looper.getMainLooper());
    public static volatile BillingDataSource sInstance;
    private boolean billingSetupComplete = false;
    // Billing client, connection, cached data
    private final BillingClient billingClient;
    // known SKUs (used to query sku data and validate responses)
    final private List<String> knownInappSKUs;
    final private List<String> knownSubscriptionSKUs;
    // SKUs to auto-consume
    final private Set<String> knownAutoConsumeSKUs;
    // LiveData that is mostly maintained so it can be transformed into observables.
    final private Map<String, MutableLiveData<SkuState>> skuStateMap = new HashMap<>();
    final private Map<String, MutableLiveData<SkuDetails>> skuDetailsLiveDataMap = new HashMap<>();
    // Observables that are used to communicate state.
    final private Set<Purchase> purchaseConsumptionInProcess = new HashSet<>();
    final private SingleMediatorLiveEvent<List<String>> newPurchase = new SingleMediatorLiveEvent<>();
    final private SingleMediatorLiveEvent<List<String>> purchaseConsumed =
            new SingleMediatorLiveEvent<>();
    final private MutableLiveData<Boolean> billingFlowInProcess = new MutableLiveData<>();
    // how long before the data source tries to reconnect to Google play
    private long reconnectMilliseconds = RECONNECT_TIMER_START_MILLISECONDS;
    // when was the last successful SkuDetailsResponse?
    private long skuDetailsResponseTime = -SKU_DETAILS_REQUERY_TIME;
    /**
     * Our constructor.  Since we are a singleton, this is only used internally.
     *
     * @param application           Android application class.
     * @param knownInappSKUs        SKUs of in-app purchases the source should know about
     * @param knownSubscriptionSKUs SKUs of subscriptions the source should know about
     */
    private BillingDataSource(@NonNull Application application, String[] knownInappSKUs,
            String[] knownSubscriptionSKUs, String[] autoConsumeSKUs) {
        Log.d(TAG, TAG + "GooglePlay BillingDataSource ");
        this.knownInappSKUs = knownInappSKUs == null ? new ArrayList<>() : Arrays.asList(
                knownInappSKUs);
        this.knownSubscriptionSKUs =
                knownSubscriptionSKUs == null ? new ArrayList<>() : Arrays.asList(
                        knownSubscriptionSKUs);
        knownAutoConsumeSKUs = new HashSet<>();
        if (autoConsumeSKUs != null) {
            knownAutoConsumeSKUs.addAll(Arrays.asList(autoConsumeSKUs));
        }
        billingClient = BillingClient.newBuilder(application).setListener(
                this).enablePendingPurchases().build();
        billingClient.startConnection(this);
        initializeLiveData();
    }

    /*
        Standard boilerplate double check locking pattern for thread-safe singletons.
     */
    public static BillingDataSource getInstance(@NonNull Application application, String[] knownInappSKUs, String[] knownSubscriptionSKUs, String[] autoConsumeSKUs)
    {
        if (sInstance == null) {
            synchronized (BillingDataSource.class) {
                if (sInstance == null) {
                    sInstance = new BillingDataSource(
                            application,
                            knownInappSKUs,
                            knownSubscriptionSKUs,
                            autoConsumeSKUs);
                }
            }
        }
        return sInstance;
    }

    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        Log.d(TAG, TAG + "GooglePlay onBillingSetupFinished: " + responseCode + " " + debugMessage);
        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                // The billing client is ready. You can query purchases here.
                // This doesn't mean that your app is set up correctly in the console -- it just
                // means that you have a connection to the Billing service.
                reconnectMilliseconds = RECONNECT_TIMER_START_MILLISECONDS;
                billingSetupComplete = true;
                querySkuDetailsAsync();
                refreshPurchasesAsync();
                break;
            default:
                retryBillingServiceConnectionWithExponentialBackoff();
                break;
        }
    }

    /**
     * This is a pretty unusual occurrence. It happens primarily if the Google Play Store
     * self-upgrades or is force closed.
     */
    @Override
    public void onBillingServiceDisconnected() {
        billingSetupComplete = false;
        retryBillingServiceConnectionWithExponentialBackoff();
    }

    private void startConnection()
    {
        Log.i(TAG,TAG+"Google startConnection");
        billingClient.startConnection(BillingDataSource.this);

        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("msg", "startConnection");

            String str = jsonObject.toString();
            Log.i("Google",TAG+"GooglePlay startConnection = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", "error:"+e.toString());
        }
    }
    /**
     * Retries the billing service connection with exponential backoff, maxing out at the time
     * specified by RECONNECT_TIMER_MAX_TIME_MILLISECONDS.
     */
    private void retryBillingServiceConnectionWithExponentialBackoff()
    {
        handler.postDelayed(() -> startConnection(), reconnectMilliseconds);
        reconnectMilliseconds = Math.min(reconnectMilliseconds * 2, RECONNECT_TIMER_MAX_TIME_MILLISECONDS);
    }

    /**
     * Called by initializeLiveData to create the various LiveData objects we're planning to emit.
     *
     * @param skuList a List<String> of SKUs representing purchases and subscriptions.
     */
    private void addSkuLiveData(List<String> skuList) {
        Log.i(TAG, TAG + "GooglePlay addSkuLiveData ");
        for (String sku : skuList) {
            Log.i(TAG, TAG + "GooglePlay addSkuLiveData sku" + sku);
            MutableLiveData<SkuState> skuState = new MutableLiveData<>();
            MutableLiveData<SkuDetails> details = new MutableLiveData<SkuDetails>() {
                @Override
                protected void onActive() {
                    Log.i(TAG, TAG + "GooglePlay addSkuLiveData RRRR 1");
                    if (SystemClock.elapsedRealtime() - skuDetailsResponseTime
                            > SKU_DETAILS_REQUERY_TIME) {
                        skuDetailsResponseTime = SystemClock.elapsedRealtime();
                        Log.v(TAG, TAG + "Skus not fresh, requerying");
                        querySkuDetailsAsync();
                    }

                }
            };
            skuStateMap.put(sku, skuState);
            skuDetailsLiveDataMap.put(sku, details);
        }
    }

    /**
     * Creates a LiveData object for every known SKU so the state and SKU details can be observed in
     * other layers. The repository is responsible for mapping this data in ways that are more
     * useful for the application.
     */
    private void initializeLiveData() {
        Log.i(TAG, TAG + "GooglePlay initializeLiveData ");
        addSkuLiveData(knownInappSKUs);
        addSkuLiveData(knownSubscriptionSKUs);
        billingFlowInProcess.postValue(false);
    }

    /**
     * This is a single live event that observes new purchases. These purchases can be the result of
     * a billing flow or from another source.
     *
     * @return LiveData that contains the sku of the new purchase.
     */
    public final LiveData<List<String>> observeNewPurchases() {
        return newPurchase;
    }

    /**
     * This is a single live event that observes consumed purchases from calling the consume
     * method.
     *
     * @return LiveData that contains the sku of the consumed purchase.
     */
    public final LiveData<List<String>> observeConsumedPurchases() {
        return purchaseConsumed;
    }

    /**
     * Returns whether or not the user has purchased a SKU. It does this by returning a
     * MediatorLiveData that returns true if the SKU is in the PURCHASED state and the Purchase has
     * been acknowledged.
     * ???????????????????????????SKU??????????????????MediatorLiveData???????????????????????????SKU????????????????????????????????????????????????MediatorLiveData?????????true???
     *
     * @return a LiveData that observes the SKUs purchase state
     */
    public LiveData<Boolean> isPurchased(String sku) {
        final LiveData<SkuState> skuStateLiveData = skuStateMap.get(sku);
        assert skuStateLiveData != null;
        return Transformations.map(skuStateLiveData, skuState ->
                skuState == SkuState.SKU_STATE_PURCHASED_AND_ACKNOWLEDGED);
    }

    private void canPurchaseFromSkuDetailsAndPurchaseLiveData
            (@NonNull MediatorLiveData<Boolean> result,
                    @NonNull LiveData<SkuDetails> skuDetailsLiveData,
                    @NonNull LiveData<SkuState> skuStateLiveData
            ) {
        SkuState skuState = skuStateLiveData.getValue();
        if (null == skuDetailsLiveData.getValue()) {
            result.postValue(false);
        } else {
            // this might be a transient state, but if we don't know about the purchase, we
            // typically can purchase. Not valid purchases can be purchased.
            result.postValue(null == skuState
                    || skuState == SkuState.SKU_STATE_UNPURCHASED);
        }
    }

    /**
     * Returns whether or not the user can purchase a SKU. It does this by returning a LiveData
     * transformation that returns true if the SKU is in the UNSPECIFIED state, as well as if we
     * have skuDetails for the SKU.
     * ??????????????????????????????SKU??????????????????LiveData?????????????????????????????????SKU?????????????????????????????????????????????SKU???SKU?????????????????????????????????true???
     *
     * @return a LiveData that observes the SKUs purchase state
     */
    public LiveData<Boolean> canPurchase(String sku) {
        final MediatorLiveData<Boolean> result = new MediatorLiveData<>();
        final LiveData<SkuDetails> skuDetailsLiveData = skuDetailsLiveDataMap.get(sku);
        final LiveData<SkuState> skuStateLiveData = skuStateMap.get(sku);
        assert skuStateLiveData != null;
        assert skuDetailsLiveData != null;
        // set initial state from LiveData values before observation callbacks.
        canPurchaseFromSkuDetailsAndPurchaseLiveData(result, skuDetailsLiveData, skuStateLiveData);
        result.addSource(skuDetailsLiveData, skuDetails ->
                canPurchaseFromSkuDetailsAndPurchaseLiveData(result, skuDetailsLiveData,
                        skuStateLiveData));
        result.addSource(skuStateLiveData, isValid ->
                canPurchaseFromSkuDetailsAndPurchaseLiveData(result, skuDetailsLiveData,
                        skuStateLiveData));
        return result;
    }

    /**
     * The title of our SKU from SkuDetails.
     *
     * @param sku to get the title from
     * @return title of the requested SKU as an observable LiveData<String>
     */
    public final LiveData<String> getSkuTitle(String sku) {
        LiveData<SkuDetails> skuDetailsLiveData = skuDetailsLiveDataMap.get(sku);
        assert skuDetailsLiveData != null;
        return Transformations.map(skuDetailsLiveData, SkuDetails::getTitle);
    }

    // There's lots of information in SkuDetails, but our app only needs a few things, since our
    // goods never go on sale, have introductory pricing, etc.

    public final LiveData<String> getSkuPrice(String sku) {
        LiveData<SkuDetails> skuDetailsLiveData = skuDetailsLiveDataMap.get(sku);
        assert skuDetailsLiveData != null;
        return Transformations.map(skuDetailsLiveData, SkuDetails::getPrice);
    }

    public final LiveData<String> getSkuDescription(String sku) {
        LiveData<SkuDetails> skuDetailsLiveData = skuDetailsLiveDataMap.get(sku);
        assert skuDetailsLiveData != null;
        return Transformations.map(skuDetailsLiveData, SkuDetails::getDescription);
    }
    
    /**
     * Receives the result from {@link #querySkuDetailsAsync()}}.
     * <p>
     * Store the SkuDetails and post them in the {@link #skuDetailsLiveDataMap}. This allows other
     * parts of the app to use the {@link SkuDetails} to show SKU information and make purchases.
     *
     * BillingClient.BillingResponseCode
     *      int SERVICE_TIMEOUT = -3;//????????????
     *      int FEATURE_NOT_SUPPORTED = -2;//???????????????
     *      int SERVICE_DISCONNECTED = -1;//?????????????????????
     *      int OK = 0;//??????
     *      int USER_CANCELED = 1;//????????????????????????????????????
     *      int SERVICE_UNAVAILABLE = 2;//??????????????????
     *      int BILLING_UNAVAILABLE = 3;//??????????????????????????? Google Play ???????????? AIDL ??????
     *      int ITEM_UNAVAILABLE = 4;//?????????????????????????????????
     *      int DEVELOPER_ERROR = 5;//????????? API ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
     *      int ERROR = 6;//API ??????????????????????????????
     *      int ITEM_ALREADY_OWNED = 7;//??????????????????????????????????????????
     *      int ITEM_NOT_OWNED = 8;//??????????????????????????????????????????
     */
    @Override
    public void onSkuDetailsResponse(@NonNull BillingResult billingResult,
            List<SkuDetails> skuDetailsList) {
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        Log.i("Google",TAG+"GooglePlay onSkuDetailsResponse responseCode="+responseCode);
        Log.i("Google",TAG+"GooglePlay onSkuDetailsResponse debugMessage="+debugMessage);
        String skus = "";
        if (skuDetailsList == null || skuDetailsList.isEmpty()) {
            for (SkuDetails skuDetails : skuDetailsList) {
                String sku = skuDetails.getSku();
                if (sku != null)
                    skus = skus + "#" + sku;
            }
        }

        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                Log.i(TAG, TAG + "onSkuDetailsResponse: " + responseCode + " " + debugMessage);
                if (skuDetailsList == null || skuDetailsList.isEmpty()) {
                    Log.e(TAG, TAG + "onSkuDetailsResponse: " +
                            "Found null or empty SkuDetails. " +
                            "Check to see if the SKUs you requested are correctly published " +
                            "in the Google Play Console.");
                } else {
                    for (SkuDetails skuDetails : skuDetailsList) {
                        String sku = skuDetails.getSku();
                        MutableLiveData<SkuDetails> detailsMutableLiveData =
                                skuDetailsLiveDataMap.get(sku);
                        if (null != detailsMutableLiveData) {
                            detailsMutableLiveData.postValue(skuDetails);
                        } else {
                            Log.e(TAG, TAG + "Unknown sku: " + sku);
                        }
                    }
                }
                break;
            case BillingClient.BillingResponseCode.SERVICE_DISCONNECTED:
            case BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE:
            case BillingClient.BillingResponseCode.BILLING_UNAVAILABLE:
            case BillingClient.BillingResponseCode.ITEM_UNAVAILABLE:
            case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
            case BillingClient.BillingResponseCode.ERROR:
                Log.e(TAG, TAG + "onSkuDetailsResponse: " + responseCode + " " + debugMessage);
                break;
            case BillingClient.BillingResponseCode.USER_CANCELED:
                Log.i(TAG, TAG + "onSkuDetailsResponse: " + responseCode + " " + debugMessage);
                break;
            // These response codes are not expected.
            case BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED:
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
            case BillingClient.BillingResponseCode.ITEM_NOT_OWNED:
            default:
                Log.wtf(TAG, TAG + "onSkuDetailsResponse: " + responseCode + " " + debugMessage);
        }
        if (responseCode == BillingClient.BillingResponseCode.OK) {
            skuDetailsResponseTime = SystemClock.elapsedRealtime();
        } else {
            skuDetailsResponseTime = -SKU_DETAILS_REQUERY_TIME;
        }

        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("msg", "onSkuDetailsResponse");
            jsonObject.put("responseCode", responseCode);
            jsonObject.put("debugMessage", debugMessage);
            jsonObject.put("skus", skus);

            String str = jsonObject.toString();
            Log.i("Google",TAG+"GooglePlay onSkuDetailsResponse = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", "error:"+e.toString());
        }
    }

    /**
     * Calls the billing client functions to query sku details for both the inapp and subscription
     * SKUs. SKU details are useful for displaying item names and price lists to the user, and are
     * required to make a purchase.
     */
    public void querySkuDetailsAsync() {
        Log.i(TAG, TAG + "GooglePlay addSkuLiveData RRRR 2");
        if (null != knownInappSKUs && !knownInappSKUs.isEmpty()) {
            Log.i(TAG, TAG + "GooglePlay addSkuLiveData RRRR 3");
            billingClient.querySkuDetailsAsync(SkuDetailsParams.newBuilder()
                    .setType(BillingClient.SkuType.INAPP)
                    .setSkusList(knownInappSKUs)
                    .build(), this);
        }
        if (null != knownSubscriptionSKUs && !knownSubscriptionSKUs.isEmpty()) {
            Log.i(TAG, TAG + "GooglePlay addSkuLiveData RRRR 4");

            billingClient.querySkuDetailsAsync(SkuDetailsParams.newBuilder()
                    .setType(BillingClient.SkuType.SUBS)
                    .setSkusList(knownSubscriptionSKUs)
                    .build(), this);
        }
    }
    public boolean IsReady()
    {
        return billingClient.isReady();
    }


    /*
        GPBL v4 now queries purchases asynchronously. This only gets active
        purchases.
     */
    public void refreshPurchasesAsync() {
        billingClient.queryPurchasesAsync(BillingClient.SkuType.INAPP,
                (billingResult, list) -> {
                    if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                        Log.e(TAG, TAG + "Problem getting purchases: " +
                                billingResult.getDebugMessage());
                    } else {
                        processPurchaseList(list, knownInappSKUs);
                    }
                });
        billingClient.queryPurchasesAsync(BillingClient.SkuType.SUBS,
                (billingResult, list) -> {
                    if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                        Log.e(TAG, TAG + "Problem getting subscriptions: " +
                                billingResult.getDebugMessage());
                    } else {
                        processPurchaseList(list, knownSubscriptionSKUs);
                    }

                });
        Log.d(TAG, TAG + "Refreshing purchases started.");
    }

    /**
     * Used internally to get purchases from a requested set of SKUs. This is particularly important
     * when changing subscriptions, as onPurchasesUpdated won't update the purchase state of a
     * subscription that has been upgraded from.
     *
     * @param skus    skus to get purchase information for
     * @param skuType sku type, inapp or subscription, to get purchase information for.
     * @return purchases
     */
    private List<Purchase> getPurchases(String[] skus, String skuType) {
        Purchase.PurchasesResult pr = billingClient.queryPurchases(skuType);
        BillingResult br = pr.getBillingResult();
        List<Purchase> returnPurchasesList = new LinkedList<>();
        if (br.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, TAG + "Problem getting purchases: " + br.getDebugMessage());
        } else {
            List<Purchase> purchasesList = pr.getPurchasesList();
            if (null != purchasesList) {
                for (Purchase purchase : purchasesList) {
                    for (String sku : skus) {
                        for (String purchaseSku : purchase.getSkus()) {
                            if (purchaseSku.equals(sku)) {
                                if ( !returnPurchasesList.contains(purchase) ) {
                                    returnPurchasesList.add(purchase);
                                }
                            }
                        }
                    }
                }
            }
        }
        return returnPurchasesList;
    }

    /**
     * Consumes an in-app purchase. Interested listeners can watch the purchaseConsumed LiveEvent.
     * To make things easy, you can send in a list of SKUs that are auto-consumed by the
     * BillingDataSource.
     */
    public void consumeInappPurchase(@NonNull String sku) {
        billingClient.queryPurchasesAsync(BillingClient.SkuType.INAPP,
                (billingResult, list) -> {
                    assert list != null;
                    if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                        Log.e(TAG, TAG + "Problem getting purchases: " +
                                billingResult.getDebugMessage());
                    } else {
                        for (Purchase purchase : list) {
                            // for right now any bundle of SKUs must all be consumable
                            for ( String purchaseSku : purchase.getSkus() )
                                if (purchaseSku.equals(sku)) {
                                    consumePurchase(purchase);
                                    return;
                                }
                        }
                    }
                    Log.e(TAG, TAG + "Unable to consume SKU: " + sku + " Sku not found.");
                });
    }

    /**
     * Calling this means that we have the most up-to-date information for a Sku in a purchase
     * object. This uses the purchase state (Pending, Unspecified, Purchased) along with the
     * acknowledged state.
     * ?????????????????????????????????????????????Sku????????????????????????????????????????????????????????????????????????????????????????????????
     *
     * @param purchase an up-to-date object to set the state for the Sku
     */
    private void setSkuStateFromPurchase(@NonNull Purchase purchase)
    {
        for (String purchaseSku:purchase.getSkus()) {
            MutableLiveData<SkuState> skuStateLiveData = skuStateMap.get(purchaseSku);
            if (null == skuStateLiveData) {
                Log.e(TAG, TAG + "Unknown SKU " + purchaseSku + ". Check to make " +
                        "sure SKU matches SKUS in the Play developer console.");
            } else {
                int code = -1;
                switch (purchase.getPurchaseState()) {
                    case Purchase.PurchaseState.PENDING:
                        skuStateLiveData.postValue(SkuState.SKU_STATE_PENDING);
                        code = 1;
                        break;
                    case Purchase.PurchaseState.UNSPECIFIED_STATE:
                        skuStateLiveData.postValue(SkuState.SKU_STATE_UNPURCHASED);
                        code = 0;
                        break;
                    case Purchase.PurchaseState.PURCHASED:
                        if (purchase.isAcknowledged()) {
                            skuStateLiveData.postValue(SkuState.SKU_STATE_PURCHASED_AND_ACKNOWLEDGED);
                            code = 3;
                        } else {
                            skuStateLiveData.postValue(SkuState.SKU_STATE_PURCHASED);
                            code = 2;
                        }
                        break;
                    default:
                        Log.e(TAG, TAG + "Purchase in unknown state: " + purchase.getPurchaseState());
                }
                OnSkuStateFromPurchase(purchase, code, purchaseSku);
            }
        }
    }

    private void OnSkuStateFromPurchase(@NonNull Purchase purchase, int code, String sku)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("order_id", purchase.getAccountIdentifiers().getObfuscatedAccountId());
            jsonObject.put("google_order_id", purchase.getOrderId());
            jsonObject.put("package_name", purchase.getPackageName());
            jsonObject.put("purchase_token", purchase.getPurchaseToken());
            jsonObject.put("org_data_json", purchase.getOriginalJson());
            jsonObject.put("sign", purchase.getSignature());
            jsonObject.put("code", code);
            jsonObject.put("purchase_id", sku);

            String str = jsonObject.toString();
            Log.i("Google",TAG+"GooglePlay jsonObject = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnSkuStateFromPurchase", str);

        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnSkuStateFromPurchase", "-1");
        }

    }

    /**
     * Since we (mostly) are getting sku states when we actually make a purchase or update
     * purchases, we keep some internal state when we do things like acknowledge or consume.
     *
     * @param sku         sku to change the state
     * @param newSkuState the new state of the sku.
     */
    private void setSkuState(@NonNull String sku, SkuState newSkuState) {
        MutableLiveData<SkuState> skuStateLiveData = skuStateMap.get(sku);
        if (null == skuStateLiveData) {
            Log.e(TAG, TAG + "Unknown SKU " + sku + ". Check to make " +
                    "sure SKU matches SKUS in the Play developer console.");
        } else {
            skuStateLiveData.postValue(newSkuState);
        }
    }

    /**
     * Goes through each purchase and makes sure that the purchase state is processed and the state
     * is available through LiveData. Verifies signature and acknowledges purchases. PURCHASED isn't
     * returned until the purchase is acknowledged. * <p> https://developer.android
     * .com/google/play/billing/billing_library_releases_notes#2_0_acknowledge
     * <p>
     * Developers can choose to acknowledge purchases from a server using the Google Play Developer
     * API. The server has direct access to the user database, so using the Google Play Developer
     * API for acknowledgement might be more reliable.
     * <p>
     * If the purchase token is not acknowledged within 3 days, then Google Play will automatically
     * refund and revoke the purchase. This behavior helps ensure that users are not charged unless
     * the user has successfully received access to the content. This eliminates a category of
     * issues where users complain to developers that they paid for something that the app is not
     * giving to them.
     * <p>
     * If a skusToUpdate list is passed-into this method, any purchases not in the list of purchases
     * will have their state set to UNPURCHASED.
     *
     * @param purchases    the List of purchases to process.
     * @param skusToUpdate a list of skus that we want to update the state from --- this allows us
     *                     to set the state of non-returned SKUs to UNPURCHASED.
     */
    private void processPurchaseList(List<Purchase> purchases, List<String> skusToUpdate) {
        HashSet<String> updatedSkus = new HashSet<>();
        if (null != purchases) {
            for (final Purchase purchase : purchases) {
                for (String sku : purchase.getSkus()) {
                    final MutableLiveData<SkuState> skuStateLiveData = skuStateMap.get(sku);
                    if (null == skuStateLiveData) {
                        Log.e(TAG, TAG + "Unknown SKU " + sku + ". Check to make " +
                                "sure SKU matches SKUS in the Play developer console.");
                        continue;
                    }
                    updatedSkus.add(sku);
                }
                // Global check to make sure all purchases are signed correctly.
                // This check is best performed on your server.
                int purchaseState = purchase.getPurchaseState();
                if (purchaseState == Purchase.PurchaseState.PURCHASED) {
                    if (!isSignatureValid(purchase)) {
                        Log.e(TAG, TAG + "Invalid signature on purchase. Check to make " +
                                "sure your public key is correct.");
                        continue;
                    }
                    // only set the purchased state after we've validated the signature.
                    setSkuStateFromPurchase(purchase);
                    boolean isConsumable = false;
                    for (String sku : purchase.getSkus()) {
                        if (knownAutoConsumeSKUs.contains(sku)) {
                            isConsumable = true;
                        } else {
                            if (isConsumable) {
                                Log.e(TAG, TAG + "Purchase cannot contain a mixture of consumable" +
                                        "and non-consumable items: " + purchase.getSkus().toString());
                                isConsumable = false;
                                break;
                            }
                        }
                    }
                    if ( isConsumable ) {
                        consumePurchase(purchase);
                    } else if (!purchase.isAcknowledged()) {
                        billingClient.acknowledgePurchase(AcknowledgePurchaseParams.newBuilder()
                                .setPurchaseToken(purchase.getPurchaseToken())
                                .build(), billingResult -> {
                            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                                // purchase acknowledged
                                for ( String sku : purchase.getSkus() ) {
                                    setSkuState(sku, SkuState.SKU_STATE_PURCHASED_AND_ACKNOWLEDGED);
                                }
                                newPurchase.postValue(purchase.getSkus());
                            }
                        });
                    }
                } else {
                    // make sure the state is set
                    setSkuStateFromPurchase(purchase);
                }
            }
        } else{
            Log.d(TAG, TAG + "Empty purchase list.");
        }
        // Clear purchase state of anything that didn't come with this purchase list if this is
        // part of a refresh.
        if (null != skusToUpdate) {
            for (String sku : skusToUpdate) {
                if (!updatedSkus.contains(sku)) {
                    setSkuState(sku, SkuState.SKU_STATE_UNPURCHASED);
                }
            }
        }
    }

    /**
     * Internal call only. Assumes that all signature checks have been completed and the purchase is
     * ready to be consumed. If the sku is already being consumed, does nothing.
     *
     * @param purchase purchase to consume
     */
    private void consumePurchase(@NonNull Purchase purchase) {
        if (purchase ==null)
            Log.i("GooglePlay",TAG + " GooglePlay consumePurchase null");
        // weak check to make sure we're not already consuming the sku
        if (purchaseConsumptionInProcess.contains(purchase)) {
            // already consuming
            return;
        }
        purchaseConsumptionInProcess.add(purchase);
        billingClient.consumeAsync(ConsumeParams.newBuilder()
                .setPurchaseToken(purchase.getPurchaseToken())
                .build(), (billingResult, s) -> {
            // ConsumeResponseListener
            purchaseConsumptionInProcess.remove(purchase);
            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                Log.d(TAG, TAG + "Consumption successful. Delivering entitlement."); // ??????????????????????????????

                purchaseConsumed.postValue(purchase.getSkus());
                for (String sku: purchase.getSkus()) {
                    // Since we've consumed the purchase
                    setSkuState(sku, SkuState.SKU_STATE_UNPURCHASED);
                    // And this also qualifies as a new purchase
                    OnSkuStateFromPurchase(purchase, 4, sku);
                }
                newPurchase.postValue(purchase.getSkus());
            } else {
                Log.e(TAG, TAG + "Error while consuming: " + billingResult.getDebugMessage());
            }
            Log.d(TAG, TAG + "End consumption flow.");
        });
    }

    /**
     * Launch the billing flow. This will launch an external Activity for a result, so it requires
     * an Activity reference. For subscriptions, it supports upgrading from one SKU type to another
     * by passing in SKUs to be upgraded.
     *
     * @param activity    active activity to launch our billing flow from
     * @param sku         SKU to be purchased
     * @param upgradeSkus SKUs that the subscription can be upgraded from
     */
    public void launchBillingFlow(Activity activity, String orderId, @NonNull String sku, String... upgradeSkus)
    {
        Log.i("Google",TAG+"GooglePlay orderId=" + orderId);
        Log.i("Google", TAG+"GooglePlay launchBillingFlow 1112 ");
        if (billingClient == null || !billingClient.isReady())
        {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 1);
                jsonObject.put("msg", "launchBillingFlow");
                jsonObject.put("sku", sku);

                String str = jsonObject.toString();
                Log.i("Google",TAG+"GooglePlay launchBillingFlow = " + str);

                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

            }catch(Exception e) {
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", "error:"+e.toString());
            }
            Log.i("Google", TAG+"GooglePlay billingClient == null");
            return;
        }
        LiveData<SkuDetails> skuDetailsLiveData = skuDetailsLiveDataMap.get(sku);
        assert skuDetailsLiveData != null;
        SkuDetails skuDetails = skuDetailsLiveData.getValue();
        if (null != skuDetails)
        {
            Log.i("Google", TAG+"GooglePlay skuDetails yes");
            if (null != upgradeSkus && upgradeSkus.length > 0)
            {
                billingClient.queryPurchasesAsync(BillingClient.SkuType.SUBS,
                        (br, purchasesList) -> {
                            List<Purchase> heldSubscriptions = new LinkedList<>();
                            if (br.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                                Log.e(TAG, TAG + "Problem getting purchases: " + br.getDebugMessage());
                            } else {
                                if (null != purchasesList) {
                                    for (Purchase purchase : purchasesList) {
                                        for (String upgradeSku : upgradeSkus) {
                                            for (String purchaseSku : purchase.getSkus()) {
                                                if (purchaseSku.equals(upgradeSku)) {
                                                    if ( !heldSubscriptions.contains(purchase) ) {
                                                        heldSubscriptions.add(purchase);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            BillingFlowParams.Builder billingFlowParamsBuilder = BillingFlowParams.newBuilder();
                            billingFlowParamsBuilder.setSkuDetails(skuDetails);
                            billingFlowParamsBuilder.setObfuscatedAccountId(orderId);// ???????????????
                            switch (heldSubscriptions.size()) {
                                case 1:  // Upgrade flow!
                                    Purchase purchase = heldSubscriptions.get(0);
                                    billingFlowParamsBuilder.setSubscriptionUpdateParams(
                                            BillingFlowParams.SubscriptionUpdateParams.newBuilder()
                                                    .setOldSkuPurchaseToken(heldSubscriptions.get(0)
                                                            .getPurchaseToken())
                                                    .build()
                                    );
                                    br = billingClient.launchBillingFlow(activity,
                                            billingFlowParamsBuilder.build());
                                    if (br.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                                        billingFlowInProcess.postValue(true);
                                    } else {
                                        Log.e(TAG, TAG + "Billing failed: + " + br.getDebugMessage());
                                    }
                                    break;
                                case 0:
                                    break;
                                default:
                                    Log.e(TAG, TAG + heldSubscriptions.size() +
                                            " subscriptions subscribed to. Upgrade not possible.");
                            }
                        });
            }
            else
            {
                BillingFlowParams.Builder billingFlowParamsBuilder = BillingFlowParams.newBuilder();
                billingFlowParamsBuilder.setSkuDetails(skuDetails);
                billingFlowParamsBuilder.setObfuscatedAccountId(orderId);// ???????????????
                BillingResult br = billingClient.launchBillingFlow(activity,
                        billingFlowParamsBuilder.build());
                if (br.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    billingFlowInProcess.postValue(true);
                } else {
                    Log.e(TAG, TAG + "Billing failed: + " + br.getDebugMessage());
                }
            }
        }
        else
        {
            Log.i("Google", TAG+"GooglePlay skuDetails no");
            Log.e(TAG, TAG + "SkuDetails not found for: " + sku);

            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 2);
                jsonObject.put("msg", "launchBillingFlow");
                jsonObject.put("sku", sku);

                String str = jsonObject.toString();
                Log.i("Google",TAG+"GooglePlay launchBillingFlow = " + str);

                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

            }catch(Exception e) {
                UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", "error:"+e.toString());
            }
        }
    }

    /**
     * Returns a LiveData that reports if a billing flow is in process, meaning that
     * launchBillingFlow has returned BillingResponseCode.OK and onPurchasesUpdated hasn't yet been
     * called.
     *
     * @return LiveData that indicates the known state of the billing flow.
     */

    public LiveData<Boolean> getBillingFlowInProcess() {
        return billingFlowInProcess;
    }

    /**
     * Called by the BillingLibrary when new purchases are detected; typically in response to a
     * launchBillingFlow.
     *
     * @param billingResult result of the purchase flow.
     * @param list          of new purchases.
     */
    @Override
    public void onPurchasesUpdated(@NonNull BillingResult billingResult, @Nullable List<Purchase> list)
    {
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        Log.i(TAG, TAG + "GooglePlay onPurchasesUpdated code=" + billingResult.getResponseCode());
        String skus = "";

        if (null != list) {
            for (final Purchase purchase : list) {
                for (String sku : purchase.getSkus()) {
                    skus = skus + "#" + sku;
                }
            }
        }
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("result", 0);
            jsonObject.put("msg", "onPurchasesUpdated");
            jsonObject.put("responseCode", responseCode);
            jsonObject.put("debugMessage", debugMessage);
            jsonObject.put("skus", skus);

            String str = jsonObject.toString();
            Log.i("Google",TAG+"GooglePlay onPurchasesUpdated = " + str);

            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);

        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", "error:"+e.toString());
        }

        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                if (null != list) {
                    processPurchaseList(list, null);
                    return;
                } else {
                    Log.d(TAG, TAG + "Null Purchase List Returned from OK response!"); // ??????????????????????????????????????????
                }
                break;
            case BillingClient.BillingResponseCode.USER_CANCELED:
                Log.i(TAG, TAG + "onPurchasesUpdated: User canceled the purchase"); // ?????????????????????
                break;
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
                Log.i(TAG, TAG + "onPurchasesUpdated: The user already owns this item"); // ???????????????????????? todo
                if (list != null && list.size() > 0)
                {
                    Log.i("GooglePlay", TAG + " GooglePlay ITEM_ALREADY_OWNED" + list.size());
                    for (final Purchase purchase : list) {
                        Log.i("GooglePlay", TAG + " GooglePlay ITEM_ALREADY_OWNED");
                        consumePurchase(purchase);
                    }
                }
                else {
                    Log.i("GooglePlay", TAG + " GooglePlay ITEM_ALREADY_OWNED list null");
                    try {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("result", 0);
                        jsonObject.put("msg", "onPurchasesUpdated");
                        jsonObject.put("code", 7);

                        String str = jsonObject.toString();
                        Log.i("Google","GooglePlay jsonObject = " + str);
                        UnityPlayer.UnitySendMessage("SDK_callback", "OnGoogleComCallback", str);
                    }catch(Exception e) {
                        UnityPlayer.UnitySendMessage("SDK_callback", "OnSkuStateFromPurchase", "-1");
                    }
                }
                break;
            case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
                Log.e(TAG, TAG + "onPurchasesUpdated: Developer error means that Google Play " +
                        "does not recognize the configuration. If you are just getting started, " +
                        "make sure you have configured the application correctly in the " +
                        "Google Play Console. The SKU product ID must match and the APK you " +
                        "are using must be signed with release keys."
                );
                break;
            default:
                Log.d(TAG, TAG + "BillingResult [" + responseCode + "]: " + debugMessage);
        }
        billingFlowInProcess.postValue(false);
    }

    /**
     * Ideally your implementation will comprise a secure server, rendering this check unnecessary.
     * @see [Security]
     */
    private boolean isSignatureValid(@NonNull Purchase purchase) {
        return true;
    }

    /**
     * It's recommended to requery purchases during onResume.
     */
    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void resume() {
        Log.d(TAG, TAG + "ON_RESUME");
        Boolean billingInProcess = billingFlowInProcess.getValue();

        // this just avoids an extra purchase refresh after we finish a billing flow
        if (billingSetupComplete && (null == billingInProcess || !billingInProcess)) {
            refreshPurchasesAsync();
        }
    }

    private enum SkuState {
        SKU_STATE_UNPURCHASED,
        SKU_STATE_PENDING,
        SKU_STATE_PURCHASED,
        SKU_STATE_PURCHASED_AND_ACKNOWLEDGED,
    }
}
