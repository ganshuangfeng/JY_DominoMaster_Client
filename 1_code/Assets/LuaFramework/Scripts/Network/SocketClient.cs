using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;
using LuaFramework;
using System.Runtime.InteropServices;

public enum DisType
{
    Exception,
    Disconnect,
}


interface SocketClient
{

    /// <summary>
    /// 创建
    /// </summary>
    void Create();

    /// <summary>
    /// 销毁
    /// </summary>
    void Destroy();

    /// <summary>
    /// 主动触发异常断开连接 会发送断线异常消息
    /// </summary>
    void Disconnect();


    /// <summary>
    /// 发送连接请求
    /// </summary>
    void Connect(string _addr);

    /// <summary>
    /// 发送消息
    /// </summary>
    //void SendMessage(ByteBuffer buffer);

    void SendMessage(byte[] bytes);
}
