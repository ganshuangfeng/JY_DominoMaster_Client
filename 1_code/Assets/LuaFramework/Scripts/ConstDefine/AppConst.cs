﻿using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

namespace LuaFramework
{
    public class AppConst
    {
#if UNITY_EDITOR
        public const bool DebugMode = true;                       //调试模式-用于内部测试
#else
        public const bool DebugMode = false; 
#endif

        /// <summary>
        /// 如果开启更新模式，前提必须启动框架自带服务器端。
        /// 否则就需要自己将StreamingAssets里面的所有内容
        /// 复制到自己的Webserver上面，并修改下面的WebUrl。
        /// </summary>
        public const bool UpdateMode = false;                      //更新模式-默认关闭 
        public const bool LuaByteMode = false;                     //Lua字节码模式-默认关闭 
        public static bool LuaBundleMode = AppDefine.IsLuaBundleMode;//不要改这里，去Unity的菜单栏找Dev,那里可以切换
	    public const bool CheckVersionMode = true;               //是否检测版本更新

        public const bool TraceCreateObject = false;            //debug:追踪创建对象

		#if UNITY_IOS
		public const bool UseXTEA = false;
		#else
		public const bool UseXTEA = true;
		#endif

        public const string xtea = "2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53";
		public const int PubXTEA = 0x8B | 0x98;

        public const int TimerInterval = 1;

        public const int GameFrameRate = 30;                        //游戏帧频

        public const string AppName = "LuaFramework";               //应用程序名称
		public const string AppIcon = "iconJY_1.png";				//应用图标
        public const string LuaTempDir = "Lua/";                    //临时目录
        public const string AppPrefix = AppName + "_";              //应用程序前缀
        public const string ExtName = ".unity3d";                   //素材扩展名
        public const string AssetDir = "StreamingAssets";           //素材目录 net

        // Tcp 配置
        public static int TcpSendTimeout = 1000;
        public static int TcpSendBufferSize = 8192;
        public static int TcpRecvTimeout = 1000;
        public static int TcpRecvBufferSize = 8192;
        public static bool TcpNoDelay = true;

        // Udp 配置
        public static bool UdpNoDelay = true;
        public static int UdpUpdateInterval = 10; // 内部工作周期。 单位： 毫秒
        public static int UdpResendMode = 2; // 重传模式： 0  关闭； 大于 0 : n 次丢包后重传
        public static bool UdpNoControl = true; // 是否关闭流控
        public static int UdpSendWndSize = 0;  // 最大发送窗口。单位： 包数量
        public static int UdpRecvWndSize = 0;  // 最大接收窗口。单位： 包数量
        public static int UdpMaxTransferUnit = 0; // 最大传输单元。大于此值 会分包
        public static int UdpResendTimeout = 30; // 重传超时。单位： 毫秒

        public static int UdpConnTimeout = 2000; // 连接超时。 单位： 毫秒
        public static int UdpTickTimeout = 5000; // 心跳超时。 单位： 毫秒
        public static int UdpTickInterval = 1000; // 心跳间隔。 单位： 毫秒

        public static bool UdpDebugLog = true; // 是否打开 调试日志

        /// <summary>
        /// 测试更新地址
        /// </summary>
#if UNITY_EDITOR
        public const string WebUrl = "http://192.168.0.207:6688/client_resouce/Android/";
#elif UNITY_ANDROID
        public const string WebUrl = "http://192.168.0.207:6688/client_resouce/Android/";      
#elif UNITY_IOS
        public const string WebUrl = "http://192.168.0.207:6688/client_resouce/Ios/";
#else
        public const string WebUrl = "";
#endif

        public static string UserId = string.Empty;                 //用户ID
        //public static int SocketPort = 0;                           //Socket服务器端口
        public static string SocketAddress = string.Empty;          //Socket服务器地址 如：192.168.0.1:4001

        public static string FrameworkRoot
        {
            get
            {
                return Application.dataPath + "/" + AppName;
            }
        }
    }
}
