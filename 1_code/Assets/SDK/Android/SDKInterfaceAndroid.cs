using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using LuaInterface;

namespace LuaFramework {
    public class SDKInterfaceAndroid : SDKInterface {
        private AndroidJavaObject jo;

        public SDKInterfaceAndroid() {
#if UNITY_ANDROID && !UNITY_EDITOR
            using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
                jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            }
#endif
        }

        private T SDKCall<T>(string method, params object[] param) {
            try {
                return jo.Call<T>(method, param);
            }
            catch (Exception e) {
                Debug.LogError(e);
            }
            return default(T);
        }

        private void SDKCall(string method, params object[] param) {
            try {
                jo.Call(method, param);
            }
            catch (Exception e) {
                Debug.LogError(e);
            }
        }

		public override void Init (string json_data) {
			SDKCall("HandleInit", json_data);
		}
		public override void Login (string json_data) {
			SDKCall("HandleLogin", json_data);
		}
		public override void FBLogin (string json_data) {
			SDKCall("HandleFBLogin", json_data);
		}
		public override void FBLogOut (string json_data) {
			SDKCall("HandleFBLogOut", json_data);
		}
		public override void LoginOut (string json_data) {
			SDKCall("HandleLoginOut", json_data);
		}
		public override void Relogin (string json_data) {
			SDKCall("HandleRelogin", json_data);
		}
		public override void Pay (string json_data) {
			SDKCall("HandlePay", json_data);
		}
		public override void PostPay(string json_data) {
			SDKCall ("HandlePostPay", json_data);
		}
		public override void Share (string json_data) {
			SDKCall("HandleShare", json_data);
		}
		public override void ShowAccountCenter (string json_data) {
			SDKCall("HandleShowAccountCenter", json_data);
		}
		public override void SendToSDKMessage(string json_data) {
			SDKCall("HandleSendToSDKMessage", json_data);
		}

		//广告接入
		public override void SetupAD(string json_data) {
			SDKCall("HandleSetupAD", json_data);
		}

        /*public override void Login(string appID) {
            SDKCall("Login", appID);
        }
		public override void WeChat(string json) {
			if (string.IsNullOrEmpty (json)) {
				Debug.LogError ("[WeChat] json is empty");
				return;
			}
			SDKCall("WeChat", json);
		}*/



		public override string GetDeviceID(string tt) {
			return SDKCall<string> ("DeviceID", tt);
		}

		public override string GetDeeplink()
        {
			return SDKCall<string>("Deeplink");
        }
		public override string GetPushDeviceToken ()
		{
			return SDKCall<string>("PushDeviceToken");
		}
        public override void RunVibrator(long tt)
        {
            SDKCall("RunVibrator", tt);
        }
        // 打电话
        public override void CallUp(string val)
        {
            SDKCall("CallUp", val);
        }

		public override void QueryCityName(float latitude, float longitude)
		{
			SDKCall("QueryingCityName", new float[]{ latitude, longitude });
		}

		public override void QueryGPS() {
			SDKCall ("QueryingGPS");
		}

		public override int StartRecord (string fileName)
		{
			return SDKCall<int> ("StartRecording", fileName);
		}
		public override void StopRecord(bool callback)
		{
			SDKCall ("StopRecording", callback);
		}

		public override void ShowProductRate(bool forceWeb)
		{
			Debug.Log ("Only run on iOS platform");
		}

		public override int PlayRecord (string fileName) {
			return SDKCall<int> ("PlayingRecord", fileName);
		}
		public override void StopPlayRecord () {
			SDKCall ("StopPlayingRecord");
		}

		//权限相关
		public override int GetCanLocation() {
			return SDKCall<int> ("CanLocation");
		}
		public override int GetCanVoice() {
			return SDKCall<int> ("CanVoice");
		}
		public override int GetCanCamera(bool deep) {
			return SDKCall<int> ("CanCamera", deep);
		}
		public override int GetCanPushNotification () {
			return SDKCall<int> ("CanPushNotification");
		}

		public override void OpenLocation() {
			SDKCall ("OpeningLocation");
		}
		public override void OpenVoice() {
			SDKCall ("OpeningVoice");
		}
		public override void OpenCamera() {
			SDKCall ("OpeningCamera");
		}

		public override void GotoSetScene(string mode) {
			SDKCall ("GoingSetScene", mode);
		}

		public override byte[] LoadFile (string fileName) {
			return SDKCall<byte[]> ("LoadingFile", fileName);
		}

		public override void ForceQuit() {
			SDKCall ("ForceQuiting");
		}

		/*public override void CallScheme(string scheme) {
			SDKCall ("CallingScheme", scheme);
		}

		public override int CallPhoto() {
			return SDKCall<int> ("CallingPhoto");
		}*/

		public override void ScanFile(string destination) {
			Debug.Log("HandleScanFile " + destination);
			SDKCall ("HandleScanFile",destination);
		}
		public override void SaveImageToPhotosAlbum (string readAddr){
		}
		public override void SaveVideoToPhotosAlbum (string readAddr){
		}
		public override void OpenPhotoAlbums (){
		}

		public override void OpenApp(string packageName,string downLink) {
			Debug.Log("HandleOpenApp " + packageName + " " + downLink);
			SDKCall ("HandleOpenApp",packageName,downLink);
		}

		// Google Play
		public override void GGInit(string json_data)
		{
			SDKCall ("HandleGGInit", json_data);
		}
		public override void GGBuy(string json_data)
		{
			SDKCall ("HandleGGBuy", json_data);
		}
		public override void OnGGConsumeInappPurchase(string json_data)
		{
			SDKCall ("HandleGGConsumeInappPurchase", json_data);
		}
		public override void OnGGRefreshPurchasesAsync(string json_data)
		{
			SDKCall ("HandleGGRefreshPurchasesAsync", json_data);
		}
		public override void OnGGQuerySkuDetailsAsync(string json_data)
		{
			SDKCall ("HandleGGQuerySkuDetailsAsync", json_data);
		}
		public override bool OnGGIsReady()
		{
			return SDKCall<bool> ("HandleGGIsReady");
		}
		public override void OnGGConnection()
		{
			SDKCall("HandleGGConnection");
		}
		public override bool OnGGIsPurchased(string json_data)
		{
			return SDKCall<bool> ("HandleGGIsPurchased", json_data);
		}
		public override bool OnGGCanPurchased(string json_data)
		{
			return SDKCall<bool> ("HandleGGCanPurchased", json_data);
		}
		public override bool OnGGBillingFlowInProcess(string json_data)
		{
			return SDKCall<bool> ("HandleGGBillingFlowInProcess", json_data);
		}
		public override string OnGGSkuTitle(string json_data)
		{
			return SDKCall<string> ("HandleGGSkuTitle", json_data);
		}
		public override string OnGGSkuPrice(string json_data)
		{
			return SDKCall<string> ("HandleGGSkuPrice", json_data);
		}
		public override string OnGGSkuDescription(string json_data)
		{
			return SDKCall<string> ("HandleGGSkuDescription", json_data);
		}
		public override void OnGGLogEvent(string json_data)
		{
			SDKCall ("HandleGGLogEvent", json_data);
		}
		public override void OnGGReview(string json_data)
		{
			SDKCall ("HandleGGReview", json_data);
		}
		public override void OnGGLaunchReview(string json_data)
		{
			SDKCall ("HandleGGLaunchReview", json_data);
		}
		public override void OnGGSignIn(string json_data)
		{
			SDKCall ("HandleGGSignIn", json_data);
		}
		public override void OnGGSignOut(string json_data)
		{
			SDKCall ("HandleGGSignOut", json_data);
		}
		public override void OnGGRevokeAccess(string json_data)
		{
			SDKCall ("HandleGGRevokeAccess", json_data);
		}

		// AppsFlyer
		public override string GetAFConversionJsonData(string str)
		{
			return SDKCall<string> ("HandleAFConversionJsonData", str);
		}
		public override void OnAFInit(string json_data)
		{
			SDKCall ("HandleAFInit", json_data);
		}
		public override void OnAFStart(string json_data)
		{
			SDKCall ("HandleAFStart", json_data);
		}
		public override void OnAFLogEvent(string json_data)
		{
			SDKCall ("HandleAFLogEvent", json_data);
		}

		// Firebase
		public override void GetMessagingData(string json_data)
		{
			SDKCall ("GetMessagingData", json_data);
		}
		public override void OnSubscribeToTopic(string json_data)
		{
			SDKCall ("OnSubscribeToTopic", json_data);
		}
		public override void OnUnsubscribeFromTopic(string json_data)
		{
			SDKCall ("OnUnsubscribeFromTopic", json_data);
		}
		public override void SendUpstream(string json_data)
		{
			SDKCall ("SendUpstream", json_data);
		}

	}
}