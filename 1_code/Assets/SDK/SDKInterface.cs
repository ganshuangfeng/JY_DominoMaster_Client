using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

namespace LuaFramework {
    public abstract class SDKInterface {
		/*
		-1:未知错误
		-2:未安装sdk
		-3:发送请求失败
		-4:取消登陆
		-5:SDK错误
		-6:分享类型错误
		-7:处理分享异常
		-8:取消分享
		*/
		public abstract void Init (string json_data);
		public abstract void Login (string json_data);
		public abstract void FBLogin (string json_data);
		public abstract void FBLogOut (string json_data);
		public abstract void LoginOut (string json_data);
		public abstract void Relogin (string json_data);
		public abstract void Pay (string json_data);
		public abstract void PostPay(string json_data);
		public abstract void Share (string json_data);
		public abstract void ShowAccountCenter (string json_data);
		public abstract void SendToSDKMessage(string json_data);

		public delegate void InitResult(string json_data);
		public delegate void LoginResult(string json_data);
		public delegate void LoginOutResult(string json_data);
		public delegate void ReloginResult(string json_data);
		public delegate void PayResult(string json_data);
		public delegate void PostPayResult(string json_data);

		public delegate void PaySuccess(string json_data);

		public delegate void PayFail(string json_data);

		public delegate void ShareResult(string json_data);
		public delegate void ShowAccountCenterResult(string json_data);
		public delegate void SetupADResult(string json_data);
		public delegate void ScanFileResult(string json_data);

		public InitResult OnInitResult;
		public LoginResult OnLoginResult;
		public LoginResult OnFBLoginResult;
		public LoginResult OnFBLogOutResult;
		public LoginOutResult OnLoginOutResult;
		public ReloginResult OnReloginResult;
		public PayResult OnPayResult;
		public PostPayResult OnPostPayResult;

		public PaySuccess OnPaySuccess;

		public PayFail OnPayFail;

		public ShareResult OnShareResult;
		public ShowAccountCenterResult OnShowAccountCenterResult;
		public SetupADResult OnHandleSetupADResult;
		public ScanFileResult OnHandleScanFileResult;
		public ScanFileResult OnHandleOpenAppResult;

		// Google Play
		public ScanFileResult OnSkuStateFromPurchase;
		public ScanFileResult OnGoogleComCallback;
		public ScanFileResult OnGGBuyResult;
		public ScanFileResult OnGGSignInResult;
		public ScanFileResult OnGGSignOutResult;
		public ScanFileResult OnGGRevokeAccessResult;
		public abstract void GGBuy(string json_data);
		public abstract void GGInit(string json_data);


		public abstract void OnGGConsumeInappPurchase(string json_data);
		public abstract void OnGGRefreshPurchasesAsync(string json_data);
		public abstract void OnGGQuerySkuDetailsAsync(string json_data);
		public abstract bool OnGGIsReady();
		public abstract void OnGGConnection();
		public abstract bool OnGGIsPurchased(string json_data);
		public abstract bool OnGGCanPurchased(string json_data);
		public abstract bool OnGGBillingFlowInProcess(string json_data);
		public abstract string OnGGSkuTitle(string json_data);
		public abstract string OnGGSkuPrice(string json_data);
		public abstract string OnGGSkuDescription(string json_data);
		public abstract void OnGGLogEvent(string json_data);
		public abstract void OnGGReview(string json_data);
		public abstract void OnGGLaunchReview(string json_data);
		public abstract void OnGGSignIn(string json_data);
		public abstract void OnGGSignOut(string json_data);
		public abstract void OnGGRevokeAccess(string json_data);

		// AppsFlyer
		public ScanFileResult OnAFStartResult;
		public ScanFileResult OnAFConversion;
		public ScanFileResult OnAFInitResult;
		public abstract string GetAFConversionJsonData(string str);

		public abstract void OnAFInit(string json_data);
		public abstract void OnAFStart(string json_data);
		public abstract void OnAFLogEvent(string json_data);

		// Firebase
		public abstract void GetMessagingData(string json_data);
		public abstract void OnSubscribeToTopic(string json_data);
		public abstract void OnUnsubscribeFromTopic(string json_data);
		public abstract void SendUpstream(string json_data);
		public ScanFileResult GetMessagingDataResult;
		public ScanFileResult OnFirebaseComCallback;


		//广告接入
		public abstract void SetupAD(string json_data);

		/*//登录
		public abstract void Login(string appID);
		//分享
		public abstract void WeChat (string json);

		public delegate void LoginSucHandler(string data);
		public delegate void HandleWeChatError (string result);
		public delegate void HandleWeChatShare (string result);
		public LoginSucHandler OnLoginSuc;
		public HandleWeChatError OnWeChatError;
		public HandleWeChatShare OnWeChatShare;*/
       
		public delegate void HandleUpdCityName(string cityName);
		public delegate void HandleGPS(string detail);
		public delegate void HandleRecord(string fileName);
		public delegate void HandlePlayRecordFinish(string fileName);
 
		public HandleUpdCityName OnUpdCityName;
		public HandleGPS OnGPS;
		public HandleRecord OnRecord;
		public HandlePlayRecordFinish OnPlayRecordFinish;

		private static SDKInterface _instance;
        public static SDKInterface Instance {
            get {
                if (_instance == null) {
#if UNITY_EDITOR || UNITY_STANDLONE || UNITY_STANDALONE_WIN
                    _instance = new SDKInterfaceDefault();
#elif UNITY_ANDROID
                _instance = new SDKInterfaceAndroid();
#elif UNITY_IOS
                _instance = new SDKInterfaceIOS();
#endif
                }

                return _instance;
            }
        }

		public abstract string GetDeviceID (string tt);
        //app启动参数
		public abstract string GetDeeplink ();
		//推送设备token
		public abstract string GetPushDeviceToken ();

        public abstract void RunVibrator(long tt);
        // 打电话
        public abstract void CallUp(string val);

		public abstract void QueryCityName (float latitude, float longitude);
		public abstract void QueryGPS();

		//录音接口
		public abstract int StartRecord (string fileName);
		public abstract void StopRecord(bool callback);
		public abstract int PlayRecord (string fileName);
		public abstract void StopPlayRecord ();
		public abstract void ShowProductRate (bool forceWeb);

		//权限相关
		public abstract int GetCanLocation();
		public abstract int GetCanVoice();
		public abstract int GetCanCamera(bool deep);
		public abstract int GetCanPushNotification ();

		public abstract void OpenLocation();
		public abstract void OpenVoice();
		public abstract void OpenCamera();

		public abstract void GotoSetScene(string mode);

		public abstract byte[] LoadFile (string fileName);
		public abstract void ForceQuit();
		
		/*public abstract void CallScheme(string mode);
		public abstract int CallPhoto();*/
		public abstract void ScanFile (string destination);
		public abstract void SaveImageToPhotosAlbum (string readAddr);
		public abstract void SaveVideoToPhotosAlbum (string readAddr);
		public abstract void OpenPhotoAlbums ();
		public abstract void OpenApp(string packageName,string downLink);


	}
}