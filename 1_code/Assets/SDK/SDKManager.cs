/*
 
 */
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using LuaInterface;


namespace LuaFramework {
    public class SDKManager : Manager {
		
		private LuaFunction onInitCallback = null;
		private LuaFunction onLoginCallback = null;
		private LuaFunction onFBLoginCallback = null;
		private LuaFunction onFBLogOutCallback = null;
		
		private LuaFunction onLoginOutCallback = null;
		private LuaFunction onReloginCallback = null;
		private LuaFunction onPayCallback = null;
		private LuaFunction onPostPayCallback = null;
		private LuaFunction onShareCallback = null;
		private LuaFunction onShowAccountCenterCallback = null;
		private LuaFunction onHandleSetupADCallback = null;
		private LuaFunction onHandleScanFileCallback = null;
		private LuaFunction onHandleOpenAppResultCallback = null;
		private LuaFunction OnSkuStateFromPurchaseCallback = null;
		private LuaFunction OnGoogleComCallback = null;
		private LuaFunction OnGGBuyResultCallback = null;
		private LuaFunction OnGGSignInResultCallback = null;
		private LuaFunction OnGGSignOutResultCallback = null;
		private LuaFunction OnGGRevokeAccessResultCallback = null;

		private LuaFunction OnAFConversionCallback = null;
		private LuaFunction OnAFInitResultCallback = null;
		private LuaFunction OnAFStartResultCallback = null;

		private LuaFunction GetMessagingDataResultCallback = null;
		private LuaFunction OnFirebaseComCallback = null;

		private LuaFunction recordCallback = null;
		private LuaFunction playRecordFinishCallback = null;

        void Awake() {
            SDKCallback.InitCallback();
#if UNITY_ANDROID
            new SDKInterfaceAndroid();
#elif UNITY_IPHONE
			new SDKInterfaceIOS();
			    
#endif
	
			SDKInterface.Instance.OnInitResult = delegate(string json_data) {
				if(onInitCallback != null)
					onInitCallback.Call(json_data);
			};

			SDKInterface.Instance.OnLoginResult = delegate(string json_data) {
				if(onLoginCallback != null)
					onLoginCallback.Call(json_data);
			};

			SDKInterface.Instance.OnFBLoginResult = delegate(string json_data) {
				if(onFBLoginCallback != null)
					onFBLoginCallback.Call(json_data);
			};
			SDKInterface.Instance.OnFBLogOutResult = delegate(string json_data) {
				if(onFBLogOutCallback != null)
					onFBLogOutCallback.Call(json_data);
			};

			SDKInterface.Instance.OnLoginOutResult = delegate(string json_data) {
				if(onLoginOutCallback != null)
					onLoginOutCallback.Call(json_data);
			};

			SDKInterface.Instance.OnReloginResult = delegate(string json_data) {
				if (onReloginCallback != null)
					onReloginCallback.Call (json_data);
			};

			SDKInterface.Instance.OnPayResult = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};
			SDKInterface.Instance.OnPostPayResult = delegate(string json_data) {
				if(onPostPayCallback != null)
					onPostPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnPaySuccess = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnPayFail = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnShareResult = delegate(string json_data) {
				if(onShareCallback != null)
					onShareCallback.Call(json_data);
			};

			SDKInterface.Instance.OnShowAccountCenterResult = delegate(string json_data) {
				if(onShowAccountCenterCallback != null)
					onShowAccountCenterCallback.Call(json_data);
			};
				
			SDKInterface.Instance.OnHandleSetupADResult = delegate(string json_data) {
				if(onHandleSetupADCallback != null)
					onHandleSetupADCallback.Call(json_data);
			};

			SDKInterface.Instance.OnHandleScanFileResult = delegate(string json_data) {
				Debug.Log("OnHandleScanFileResult" + json_data);
				if(onHandleScanFileCallback != null)
					onHandleScanFileCallback.Call(json_data);
			};

			SDKInterface.Instance.OnHandleOpenAppResult = delegate(string json_data) {
				Debug.Log("OnHandleOpenAppResult" + json_data);
				if(onHandleOpenAppResultCallback != null)
					onHandleOpenAppResultCallback.Call(json_data);
			};
			
			SDKInterface.Instance.OnSkuStateFromPurchase = delegate(string json_data) {
				if(OnSkuStateFromPurchaseCallback != null)
					OnSkuStateFromPurchaseCallback.Call(json_data);
			};
			SDKInterface.Instance.OnGoogleComCallback = delegate(string json_data) {
				if(OnGoogleComCallback != null)
					OnGoogleComCallback.Call(json_data);
			};
			
			SDKInterface.Instance.OnGGBuyResult = delegate(string json_data) {
				if(OnGGBuyResultCallback != null)
					OnGGBuyResultCallback.Call(json_data);
			};

			SDKInterface.Instance.OnGGSignInResult = delegate(string json_data) {
				if(OnGGSignInResultCallback != null)
					OnGGSignInResultCallback.Call(json_data);
			};

			SDKInterface.Instance.OnGGSignOutResult = delegate(string json_data) {
				if(OnGGSignOutResultCallback != null)
					OnGGSignOutResultCallback.Call(json_data);
			};

			SDKInterface.Instance.OnGGRevokeAccessResult = delegate(string json_data) {
				if(OnGGRevokeAccessResultCallback != null)
					OnGGRevokeAccessResultCallback.Call(json_data);
			};

			

			SDKInterface.Instance.OnAFConversion = delegate(string json_data) {
				if(OnAFConversionCallback != null)
					OnAFConversionCallback.Call(json_data);
			};
			SDKInterface.Instance.OnAFInitResult = delegate(string json_data) {
				if(OnAFInitResultCallback != null)
					OnAFInitResultCallback.Call(json_data);
			};
			SDKInterface.Instance.OnAFStartResult = delegate(string json_data) {
				if(OnAFStartResultCallback != null)
					OnAFStartResultCallback.Call(json_data);
			};

			SDKInterface.Instance.GetMessagingDataResult = delegate(string json_data) {
				if(GetMessagingDataResultCallback != null)
					GetMessagingDataResultCallback.Call(json_data);
			};
			SDKInterface.Instance.OnFirebaseComCallback = delegate(string json_data) {
				if(OnFirebaseComCallback != null)
					OnFirebaseComCallback.Call(json_data);
			};

			SDKInterface.Instance.OnUpdCityName = delegate(string cityName) {
				OnUpdCityName(cityName);
			};
			SDKInterface.Instance.OnGPS = delegate(string detail) {
				OnGPS(detail);
			};
			SDKInterface.Instance.OnRecord = delegate(string fileName) {
				OnRecord(fileName);
			};
			SDKInterface.Instance.OnPlayRecordFinish = delegate(string fileName) {
				OnPlayRecordFinish(fileName);
			};
        }

		public void Init(string json_data, LuaFunction callback) {
			onInitCallback = callback;
			SDKInterface.Instance.Init(json_data);
		}

		public void Login(string json_data, LuaFunction callback) {
			onLoginCallback = callback;
			SDKInterface.Instance.Login(json_data);
		}
		public void FBLogin(string json_data, LuaFunction callback) {
			onFBLoginCallback = callback;
			SDKInterface.Instance.FBLogin(json_data);
		}
		public void FBLogOut(string json_data, LuaFunction callback) {
			onFBLogOutCallback = callback;
			SDKInterface.Instance.FBLogOut(json_data);
		}

		public void LoginOut(string json_data, LuaFunction callback) {
			onLoginOutCallback = callback;
			SDKInterface.Instance.LoginOut(json_data);
		}

		public void Relogin(string json_data, LuaFunction callback) {
			onReloginCallback = callback;
			SDKInterface.Instance.Relogin (json_data);
		}

		public void Pay(string json_data, LuaFunction callback) {
			if(callback != null)
				onPayCallback = callback;
			SDKInterface.Instance.Pay(json_data);
		}
		public void PostPay(string json_data, LuaFunction callback) {
			if(callback != null)
				onPostPayCallback = callback;
			SDKInterface.Instance.PostPay(json_data);
		}
		public void SetPayCallback(LuaFunction callback) {
			onPayCallback = callback;
		}
		public void SetPostPayCallback(LuaFunction callback) {
			onPostPayCallback = callback;
		}
		public void Share(string json_data, LuaFunction callback) {
			onShareCallback = callback;
			SDKInterface.Instance.Share(json_data);
		}

		public void ShowAccountCenter(string json_data, LuaFunction callback) {
			onShowAccountCenterCallback = callback;
			SDKInterface.Instance.ShowAccountCenter(json_data);
		}
		public void SendToSDKMessage(string json_data) {
			SDKInterface.Instance.SendToSDKMessage(json_data);
		}

		public void AddHandleScanFileCallback(LuaFunction callback) {
			onHandleScanFileCallback = callback;
		}

		public void ScanFile(string destination){
			SDKInterface.Instance.ScanFile(destination);
		}

		public void SaveImageToPhotosAlbum(string destination){
			SDKInterface.Instance.SaveImageToPhotosAlbum(destination);
		}

		public void SaveVideoToPhotosAlbum(string destination){
			SDKInterface.Instance.SaveVideoToPhotosAlbum(destination);
		}

		public void OpenPhotoAlbums(){
			SDKInterface.Instance.OpenPhotoAlbums();
		}

		public void OpenApp(string packageName,string downLink){
			SDKInterface.Instance.OpenApp(packageName,downLink);
		}

		public void AddHandleOpenAppResultCallback(LuaFunction callback) {
			onHandleOpenAppResultCallback = callback;
		}


		public void OnUpdCityName(string cityName) {
			Debug.Log("OnUpdCityName " + cityName);
			GameManager mgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
			if (mgr) {
				GPS gps = mgr.gameObject.GetComponent<GPS> ();
				if (gps)
					gps.SetCityName (cityName);
			}
		}

		private float mLatitude = 0.0f;
		private float mLongitude = 0.0f;
		private string mLocation = string.Empty;
		public void OnGPS(string detail) {
			string[] items = detail.Split ('#');
			if (items.Length != 3) {
				Debug.LogError ("[GPS] OnGPS split failed:" + detail);
				return;
			}

			float latitude = 0.0f, longitude = 0.0f;
			if (!float.TryParse (items [0], out latitude)) {
				Debug.LogError ("[GPS] OnGPS parse latitude failed:" + detail);
				return;
			}
			if (!float.TryParse (items [1], out longitude)) {
				Debug.LogError ("[GPS] OnGPS parse longitude failed:" + detail);
				return;
			}
			string location = items [2];

			Debug.Log(string.Format("[GPS] OnGPS({0}, {1}, {2})", latitude, longitude, location));

			mLatitude = latitude;
			mLongitude = longitude;
			mLocation = location;

			if (handleGPSCallback != null) {
				handleGPSCallback.Call ();
			}
		}
		public float GetLatitude() { return mLatitude; }
		public float GetLongitude() { return mLongitude; }
		public string GetLocation() { return mLocation; }

		public void OnRecord(string fileName) {
			Debug.Log("OnRecord " + fileName);

			if (recordCallback != null) {
				if(m_recordTime > 0)
					recordCallback.Call (fileName);
				else
					recordCallback.Call ("");
			}
		}
		public void OnPlayRecordFinish(string fileName) {
			Debug.Log("OnPlayRecordFinish " + fileName);

			if (playRecordFinishCallback != null)
				playRecordFinishCallback.Call (fileName);
		}

		public string GetDeviceID(string tt) {
			return SDKInterface.Instance.GetDeviceID(tt);
		}

		public string GetDeeplink()
        {
            return SDKInterface.Instance.GetDeeplink();
        }

		public string GetPushDeviceToken() {
			return SDKInterface.Instance.GetPushDeviceToken();
		}

        public void RunVibrator(long tt)
        {
            SDKInterface.Instance.RunVibrator(tt);
        }
        public void CallUp(string val)
        {
            Debug.Log("电话=" + val);
            SDKInterface.Instance.CallUp(val);
        }

		public void StartGPS(LuaFunction callback) {
			GameManager mgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
			if (mgr) {
				GPS gps = mgr.gameObject.GetComponent<GPS> ();
				if (gps)
					gps.StartGPS ((int resultCode) => {
						if(callback != null)
							callback.Call(resultCode);
					});
				else
					Debug.LogError ("[GPS] StartGPS failed. gps is null");
			} else
				Debug.LogError ("[GPS] StartGPS failed. gameMgr is null");
		}

		public void QueryCityName(float latitude, float longitude) {
			SDKInterface.Instance.QueryCityName(latitude, longitude);
		}

		private LuaFunction handleGPSCallback;
		public void QueryGPS(LuaFunction callback) {
			handleGPSCallback = callback;
			SDKInterface.Instance.QueryGPS();
		}

		//录音最大时长,单位:秒
		const int RECORD_TIME = 10;
		private int m_recordTime = 0;
		private Coroutine m_recordCoroutine;
		private IEnumerator RecordTimeDown() {
			m_recordTime = 0;

			while (m_recordTime < RECORD_TIME) {
				yield return new WaitForSeconds (1);
				++m_recordTime;
				//Debug.Log ("record: " + m_recordTime);
			}

			if (m_recordTime >= RECORD_TIME)
				stopRecord (true);
			
			yield return 0;
		}
		private void stopRecord(bool callback) {
			SDKInterface.Instance.StopRecord(callback);
			Debug.Log ("stopRecord......");
		}
		public int GetRecordTime() { return m_recordTime; }

		public int StartRecord(string fileName, LuaFunction callback) {
			Debug.Log("StartRecord fileName: " + fileName);
            if (Microphone.devices.Length <= 0)
            {
                return -1;
            }

            recordCallback = callback;

			m_recordTime = 0;
			int result = SDKInterface.Instance.StartRecord (fileName);
			if(result > 0)
				m_recordCoroutine = StartCoroutine (RecordTimeDown ());

			return result;
		}
		public void StopRecord(bool callback) {
			StopCoroutine (m_recordCoroutine);
			stopRecord(callback);
		}

		public int PlayRecord(string fileName, LuaFunction callback) {
			playRecordFinishCallback = callback;
			return SDKInterface.Instance.PlayRecord(fileName);
		}
		public void StopPlayRecord() {
			SDKInterface.Instance.StopPlayRecord();
		}
		public void ShowProductRate(bool forceWeb) {
			SDKInterface.Instance.ShowProductRate(forceWeb);
		}

		public int GetCanLocation() {
			return SDKInterface.Instance.GetCanLocation();
		}
		public int GetCanVoice() {
			return SDKInterface.Instance.GetCanVoice();
		}
		public int GetCanCamera(bool deep) {
			return SDKInterface.Instance.GetCanCamera(deep);
		}
		public int GetCanPushNotification () {
			return SDKInterface.Instance.GetCanPushNotification();
		}

		public void OpenLocation() {
			SDKInterface.Instance.OpenLocation();
		}

		public void OpenVoice() {
			SDKInterface.Instance.OpenVoice();
		}
		public void OpenCamera() {
			SDKInterface.Instance.OpenCamera();
		}

		public void GotoSetScene(string mode) {
			SDKInterface.Instance.GotoSetScene(mode);
		}

		public byte[] LoadFile(string fileName) {
			return SDKInterface.Instance.LoadFile(fileName);
		}

		public void ForceQuit() {
			SDKInterface.Instance.ForceQuit();
		}

		// Google
		public void GGInit(string json_data) {
			SDKInterface.Instance.GGInit(json_data);
		}
		public void AddGoogleComCallback(LuaFunction callback) {
			OnGoogleComCallback = callback;
		}
		public void AddSkuStateFromPurchaseCallback(LuaFunction callback) {
			OnSkuStateFromPurchaseCallback = callback;
		}
		public void AddOnGGBuyResultCallback(LuaFunction callback) {
			OnGGBuyResultCallback = callback;
		}
		public void GGBuy(string json_data) {
			SDKInterface.Instance.GGBuy(json_data);
		}
		public void OnGGConsumeInappPurchase(string json_data)
		{
			SDKInterface.Instance.OnGGConsumeInappPurchase(json_data);
		}
		public void OnGGRefreshPurchasesAsync(string json_data)
		{
			SDKInterface.Instance.OnGGRefreshPurchasesAsync(json_data);
		}
		public void OnGGQuerySkuDetailsAsync(string json_data)
		{
			SDKInterface.Instance.OnGGQuerySkuDetailsAsync(json_data);
		}
		public bool OnGGIsReady()
		{
			return SDKInterface.Instance.OnGGIsReady();
		}
		public void OnGGConnection()
		{
			SDKInterface.Instance.OnGGConnection();
		}

		public bool OnGGIsPurchased(string json_data)
		{
			return SDKInterface.Instance.OnGGIsPurchased(json_data);
		}
		public bool OnGGCanPurchased(string json_data)
		{
			return SDKInterface.Instance.OnGGCanPurchased(json_data);
		}
		public bool OnGGBillingFlowInProcess(string json_data)
		{
			return SDKInterface.Instance.OnGGBillingFlowInProcess(json_data);
		}
		public string OnGGSkuTitle(string json_data)
		{
			return SDKInterface.Instance.OnGGSkuTitle(json_data);
		}
		public string OnGGSkuPrice(string json_data)
		{
			return SDKInterface.Instance.OnGGSkuPrice(json_data);
		}
		public string OnGGSkuDescription(string json_data)
		{
			return SDKInterface.Instance.OnGGSkuDescription(json_data);
		}
		public void OnGGLogEvent(string json_data)
		{
			SDKInterface.Instance.OnGGLogEvent(json_data);
		}
		public void OnGGReview(string json_data)
		{
			SDKInterface.Instance.OnGGReview(json_data);
		}
		public void OnGGLaunchReview(string json_data)
		{
			SDKInterface.Instance.OnGGLaunchReview(json_data);
		}

		public void OnGGSignIn(string json_data, LuaFunction callback)
		{
			OnGGSignInResultCallback = callback;
			SDKInterface.Instance.OnGGSignIn(json_data);
		}
		public void OnGGSignOut(string json_data, LuaFunction callback)
		{
			OnGGSignOutResultCallback = callback;
			SDKInterface.Instance.OnGGSignOut(json_data);
		}
		public void OnGGRevokeAccess(string json_data, LuaFunction callback)
		{
			OnGGRevokeAccessResultCallback = callback;
			SDKInterface.Instance.OnGGRevokeAccess(json_data);
		}

		// AppsFlyer

		public string GetAFConversionJsonData(string str) {
			return SDKInterface.Instance.GetAFConversionJsonData(str);
		}
		public void AddOnAFConversionCallback(LuaFunction callback) {
			OnAFConversionCallback = callback;
		}
		public void OnAFInit(string json_data, LuaFunction callback)
		{
			OnAFInitResultCallback = callback;
			SDKInterface.Instance.OnAFInit(json_data);
		}
		public void OnAFStart(string json_data, LuaFunction callback)
		{
			OnAFStartResultCallback = callback;
			SDKInterface.Instance.OnAFStart(json_data);
		}
		public void OnAFLogEvent(string json_data)
		{
			SDKInterface.Instance.OnAFLogEvent(json_data);
		}
		
		// Firebase
		public void GetMessagingData(string json_data, LuaFunction callback)
		{
			GetMessagingDataResultCallback = callback;
			SDKInterface.Instance.GetMessagingData(json_data);
		}
		public void AddFirebaseComCallback(LuaFunction callback) {
			OnFirebaseComCallback = callback;
		}
		public void OnSubscribeToTopic(string json_data) {
			SDKInterface.Instance.OnSubscribeToTopic(json_data);
		}
		public void OnUnsubscribeFromTopic(string json_data) {
			SDKInterface.Instance.OnUnsubscribeFromTopic(json_data);
		}
		public void SendUpstream(string json_data) {
			SDKInterface.Instance.SendUpstream(json_data);
		}

	}
}
