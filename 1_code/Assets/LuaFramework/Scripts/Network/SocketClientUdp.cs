// 
// by lyx 2022-3-10
//
// 说明：通过 udp 通讯
// 
//下一步：
//  1、处理 主动/被动断开；
//  2、循环接收缓冲区
//  3、多节点测速： udp socket 封装成独立的对象
//  4、上层逻辑梳理

using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;
using LuaFramework;
using System.Runtime.InteropServices;
using System.Threading;
using System.Text;
using System.Security.Cryptography;
using AOT;

public class SocketClientUdp : SocketClient
{
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate int DeleTypeKcpOutput(IntPtr buf, int len, IntPtr kcp, IntPtr user);

    public DeleTypeKcpOutput kcpOutputFunc = null;

    private UdpClient client = null;
    //private NetworkStream outStream = null;
    private MemoryStream memStream;
    private BinaryReader reader;

    private const int MAX_READ = 65 * 1024;
    private byte[] byteBuffer = new byte[MAX_READ];

    private IntPtr KcpHandle = IntPtr.Zero;

    private System.Timers.Timer timer = null;

    private Mutex mtxRecvData = new Mutex();
    private Queue recvData = new Queue();

    private int MyObjectId = 0;
    private static int objectIdLast = 0;
    private static Mutex objectsMutex = new Mutex();
    private static Dictionary<int, SocketClientUdp> mapObjects = new Dictionary<int, SocketClientUdp>();

    private IPEndPoint lastRecvRemoteAddr = null;

    private Int64 isRecieving = 0;

    private System.Random random = new System.Random();

    private long beginTicks = 0;
    
    private const byte SessDataReq = 1;
    private const byte SessDataResp = 2;
    private const byte SessDataData = 3;
    private const byte SessDataClose = 4;
    private const byte SessDataTick = 5;
    private const byte SessDataTickResp = 6;

    private UInt32 KcpId = 0;

    private UInt32 lastReqTime = 0;
    private UInt32 lastTickTime = 0;



    // 状态： 关闭、请求连接、连接成功
    enum State { close,req,conn};

    private State state = State.close;

    private UInt32 lastReqSYN = 0;  // 本次 请求握手 标识号; 0 表示 未发出握手信号

    // Use this for initialization
    public SocketClientUdp()
    {
        objectIdLast++;
        MyObjectId = objectIdLast;
        kcpOutputFunc = KcpOutput;
    }


    // 编码，小端排列
    private static void encodeUint32(byte[] _data, int _pos,UInt32 _v)
    {
        _data[_pos] = (byte)(_v & 0x000000FF);
        _data[_pos + 1] = (byte)(_v >> 8 & 0x000000FF);
        _data[_pos + 2] = (byte)(_v >> 16 & 0x000000FF);
        _data[_pos + 3] = (byte)(_v >> 24);
    }
    // 解码，小端排列
    private static UInt32 decodeUint32(byte []_data,int _pos)
    {
        return ((UInt32)_data[_pos+3] << 24) +
            ((UInt32)_data[_pos + 2] << 16) +
            ((UInt32)_data[_pos + 1] << 8) +
            ((UInt32)_data[_pos]);
    }

    // 编码，大端排列
    private static byte [] encodeData(byte _type,UInt32 _param1, UInt32 _param2,byte[] _data,int _len = -1)
    {
        int _head_size = 1;
        if (_param1 != 0) _head_size += 4;
        if (_param2 != 0) _head_size += 4;

        byte[] _head = new byte[_head_size];

        _head[0] = _type;

        int _pos = 1;
        if (_param1 != 0)
        {
            encodeUint32(_head, _pos, _param1);
            _pos += 4;
        }
        if (_param2 != 0)
        {
            encodeUint32(_head, _pos, _param2);
            _pos += 4;
        }

        if (_data == null || _len == 0)
            return _head;

        if (_len == -1)
            _len = _data.Length;

        byte[] _ret = new byte[_head_size + _len];
        Array.Copy(_head, _ret, _head_size);
        Array.Copy(_data,0, _ret,_head_size, _len);

        return _ret;
    }

    private void SendCallback(IAsyncResult iar)
    {
        client.EndSend(iar);
    }
    private void ReciveCallback(IAsyncResult iar)
    {
        IPEndPoint remoteAddr = null;

        byte[] recvBytes = client.EndReceive(iar, ref remoteAddr);

        Interlocked.Exchange(ref isRecieving, 0);

        mtxRecvData.WaitOne();
        recvData.Enqueue(recvBytes);
        lastRecvRemoteAddr = remoteAddr;
        mtxRecvData.ReleaseMutex();
    }

    public static byte []sliseBytes(byte[] src, int _offset = 0, int _len = -1)
    {
        if (src.Length == 0)
            return src;

        if (_len == 0 || _offset >= src.Length)
            return new byte[] {};

        if (_len == -1 || _len > (src.Length - _offset))
            _len = src.Length - _offset;

        if (_offset == 0 && _len == src.Length)
            return src;

        var src2 = new byte[_len];
        Array.Copy(src, _offset, src2, 0, _len);

        return src2;
    }

    public static string byteToString(byte[] src, int _offset = 0, int _len = -1)
    {

        var src2 = sliseBytes(src, _offset, _len);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < src2.Length; i++)
            sb.Append(String.Format("{0:X02}", src2[i]));

        return sb.ToString();
    }

    public static string bytesMd5(byte[] src, int _offset = 0, int _len = -1)
    {
        MD5CryptoServiceProvider md5Hasher = new MD5CryptoServiceProvider();
        return byteToString(md5Hasher.ComputeHash(sliseBytes(src, _offset, _len)));
    }
    private void sendData(byte[] _data,int _bytes=-1)
    {
        mtxRecvData.WaitOne();
        var _addr = lastRecvRemoteAddr;
        mtxRecvData.ReleaseMutex();

        if (_bytes == -1)
            _bytes = _data.Length;

        if (AppConst.UdpDebugLog)
        {
            Debug.Log(DateTime.Now.ToString() + "==================== send udp data:" + bytesMd5(_data,0,_bytes));
        }

        client.BeginSend(_data, _bytes, _addr, new AsyncCallback(SendCallback), null);
    }

    [MonoPInvokeCallback(typeof(DeleTypeKcpOutput))]
    public static int KcpOutput(IntPtr buf, int len, IntPtr kcp, IntPtr user)
    {
        objectsMutex.WaitOne();
        SocketClientUdp me;
        bool _ok = mapObjects.TryGetValue((int)user, out me);
        objectsMutex.ReleaseMutex();

        if (!_ok)
            return 0;

        try
        {


            var buf2 = new byte[len];
            Marshal.Copy(buf, buf2, 0, len);

            if (me.client == null)
                return 0;

            if (AppConst.UdpDebugLog)
            {
                Debug.Log(DateTime.Now.ToString() + "================= kcp output:" + me.KcpId.ToString() + ":" + bytesMd5(buf2));
            }

            byte[] payload = encodeData(SessDataData, me.KcpId, 0, buf2, len);

            // 发送数据
            me.sendData(payload);

            return len;
        }
        catch (Exception err)
        {
            Debug.LogError(DateTime.Now.ToString() + "KcpOutput error:" + err.Message + "\n" + err.StackTrace);
            me.Close();
            return 0;
        }

    }

    private void initKcpObject()
    {
        try
        {
            objectsMutex.WaitOne();
            mapObjects.Add(MyObjectId, this);
            objectsMutex.ReleaseMutex();

            KcpHandle = LuaInterface.LuaDLL.ikcp_create(KcpId, (IntPtr)MyObjectId);
            var funcptr = Marshal.GetFunctionPointerForDelegate(kcpOutputFunc);
            Debug.Log(DateTime.Now.ToString() + "================= initKcpObject functpr:" + funcptr.ToString());
            LuaInterface.LuaDLL.ikcp_setoutput(KcpHandle, funcptr);
            LuaInterface.LuaDLL.ikcp_nodelay(KcpHandle,
                AppConst.UdpNoControl ? 1 : 0,
                AppConst.UdpUpdateInterval,
                AppConst.UdpResendMode,
                AppConst.UdpNoControl ? 1 : 0);
            LuaInterface.LuaDLL.ikcp_setmtu(KcpHandle, AppConst.UdpMaxTransferUnit);
            LuaInterface.LuaDLL.ikcp_wndsize(KcpHandle, AppConst.UdpSendWndSize-1, AppConst.UdpRecvWndSize-1); // 配置大于 0 才起作用
        }
        catch (Exception err)
        {
            Debug.LogError(DateTime.Now.ToString() + "initKcpObject error:" + err.Message + "\n" + err.StackTrace);
            Close();
        }

    }

    // 得到毫秒数
    private UInt32 getMillseconds()
    {
        return (UInt32)(DateTime.Now.Ticks - beginTicks) / 10000;
                                             
    }

    private void update(object source, System.Timers.ElapsedEventArgs e)
    {
        if (state == State.close)
            return;

        try
        {
            while (recvData.Count > 0)
            {
                mtxRecvData.WaitOne();
                byte[] tmp = (byte[])recvData.Dequeue();
                mtxRecvData.ReleaseMutex();

                var param1 = decodeUint32(tmp, 1);

                switch (tmp[0])
                {
                    case SessDataResp:  // 服务器响应连接
                        if (lastReqSYN == 0)
                        {
                            OnDisconnected(DisType.Exception, "server resp type error");
                            return;
                        }
                        if (tmp.Length != 9)
                        {
                            OnDisconnected(DisType.Exception, "server resp length error");
                            return;
                        }

                        if ((lastReqSYN + 1) != decodeUint32(tmp, 5))
                        {
                            OnDisconnected(DisType.Exception, "server resp ask value error");
                            return;
                        }
                        lastReqSYN = 0;

                        KcpId = param1;
                        sendData(encodeData(SessDataResp, KcpId, 0, null));

                        initKcpObject();

                        state = State.conn;
                        Debug.Log(DateTime.Now.ToString() + "================= udp connect:" + KcpId.ToString());

                        // 连接成功
                        NetworkManager.AddEvent(Protocal.Connect, null);

                        break;
                    case SessDataData:
                        if (KcpHandle == IntPtr.Zero)
                        {
                            OnDisconnected(DisType.Exception, "net object is invalid on data input");
                            return;
                        }
                        if (param1 == KcpId)
                        {
                            var tmp2 = sliseBytes(tmp, 5);
                            if (AppConst.UdpDebugLog)
                            {
                                Debug.Log(DateTime.Now.ToString() + "================= kcp input:" + KcpId.ToString() + ":" + bytesMd5(tmp2));
                            }
                                
                            LuaInterface.LuaDLL.ikcp_input(KcpHandle, tmp2, tmp2.Length);
                        }
                        else
                        {
                            Debug.LogError(String.Format("================= kcp input kcp id error:cur={0},recv={1}:{2}", KcpId, param1, bytesMd5(tmp, 5)));
                        }
                        break;
                    case SessDataClose:
                        OnDisconnected(DisType.Disconnect, "close by server");
                        break;
                    case SessDataTick:
                        if (param1 == KcpId)
                        {
                            sendData(encodeData(SessDataTickResp, KcpId, decodeUint32(tmp, 5), null));
                        }
                        
                        break;
                    case SessDataTickResp:
                        if (param1 == KcpId)
                        {
                            lastTickTime = getMillseconds();
                        }
                        break;
                    default:
                        break;
                }
            }


            if (KcpHandle != IntPtr.Zero)
            {

                // 刷新
                LuaInterface.LuaDLL.ikcp_update(KcpHandle, getMillseconds());

                // 读取数据
                int _size = LuaInterface.LuaDLL.ikcp_peeksize(KcpHandle);
                if (_size > 0)
                {
                    byte[] buffer = new byte[_size];
                    int _read_len = LuaInterface.LuaDLL.ikcp_recv(KcpHandle, buffer, _size);
                    if (_read_len > 0)
                    {
                        if (AppConst.UdpDebugLog)
                        {
                            Debug.Log(DateTime.Now.ToString() + "================= kcp recv:" + KcpId.ToString() + ":" + bytesMd5(buffer, 0, _read_len));
                        }
                        OnReceive(buffer, _read_len);
                    }
                }

                if (state == State.conn && lastTickTime > 0)
                {
                    if ((getMillseconds()-lastTickTime)>AppConst.UdpTickTimeout)
                    {
                        OnDisconnected(DisType.Disconnect, "udp tick timeout");
                        Debug.LogError(DateTime.Now.ToString() + "udp tick timeout:" + (getMillseconds() - lastTickTime).ToString());
                        return;
                    }
                }

            }
            else
            {
                if (state == State.req && lastReqTime > 0)
                {
                    if ((getMillseconds() - lastReqTime) > AppConst.UdpConnTimeout)
                    {
                        OnDisconnected(DisType.Disconnect, "udp connect timeout");
                        Debug.LogError(DateTime.Now.ToString() + "udp connect timeout:" + (getMillseconds() - lastReqTime).ToString());
                        return;
                    }
                }
            }

            Int64 _isRecving = Interlocked.Read(ref isRecieving);
            if (_isRecving == 0)
            {
                Interlocked.Exchange(ref isRecieving, 1);
                client.BeginReceive(new AsyncCallback(ReciveCallback), null);
            }
        }
        catch (Exception err)
        {
            Debug.LogError(DateTime.Now.ToString() + "update error:" + err.Message + "\n" + err.StackTrace);
            Close();
        }
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    void OnReceive(byte[] bytes, int length)
    {
        memStream.Seek(0, SeekOrigin.End);
        memStream.Write(bytes, 0, length);
        //Reset to beginning
        memStream.Seek(0, SeekOrigin.Begin);
        while (RemainingBytes() > 2)
        {
            //前2个字节消息长度，sproto传输时长度信息都使用大端数据
            ushort temp = reader.ReadUInt16();
            var array = BitConverter.GetBytes(temp);
            Array.Reverse(array);
            ushort messageLen = BitConverter.ToUInt16(array, 0);

            if (RemainingBytes() >= messageLen)
            {
                OnReceivedMessage(messageLen);
            }
            else
            {
                //Back up the position two bytes
                memStream.Position = memStream.Position - 2;
                break;
            }
        }
        //Create a new stream with any leftover bytes
        byte[] leftover = reader.ReadBytes((int)RemainingBytes());
        memStream.SetLength(0);     //Clear
        memStream.Write(leftover, 0, leftover.Length);
    }

    /// <summary>
    /// 注册代理
    /// </summary>
    public void Create()
    {
        memStream = new MemoryStream();
        reader = new BinaryReader(memStream);
    }

    /// <summary>
    /// 移除代理
    /// </summary>
    public void Destroy()
    {

        Close();
        reader.Close();
        memStream.Close();
    }

    /// <summary>
    /// 主动触发异常断开连接 会发送断线异常消息
    /// </summary>
    public void Disconnect()
    {
        OnDisconnected(DisType.Exception, " initiative Disconnect ");
    }


    /// <summary>
    /// 连接服务器
    /// </summary>
    void ConnectServer(string _address)
    {
        Close();

        try
        {
            timer = new System.Timers.Timer(10);
            timer.AutoReset = true;
            timer.Enabled = true;
            timer.Elapsed += new System.Timers.ElapsedEventHandler(update);

            beginTicks = DateTime.Now.Ticks;

            string[] arr = _address.Split(':');
            string host = arr[0];
            int port = int.Parse(arr[1]);

            IPAddress[] address = Dns.GetHostAddresses(host);
            if (address.Length == 0)
            {
                Debug.LogError(DateTime.Now.ToString() + "host invalid");
                return;
            }

            if (address[0].AddressFamily == AddressFamily.InterNetworkV6)
            {
                client = new UdpClient(AddressFamily.InterNetworkV6);
                Debug.Log(DateTime.Now.ToString() + "[Network] is IPV6 " + _address);
            }
            else
            {
                client = new UdpClient(AddressFamily.InterNetwork);
                Debug.Log(DateTime.Now.ToString() + "[Network] is IPV4 " + _address);
            }

            DateTime startTime = DateTime.Now;
            Debug.LogFormat(DateTime.Now.ToString() + "{0} == begin connect server:host={1} port={2}", startTime.Millisecond, host, port);


            //client.Connect(host, port);
            lastReqSYN = (UInt32)random.Next() % 2069232275;
            //var _send_data = encodeData(SessDataReq, lastReqSYN, 0, null);

            IPEndPoint remoteAddr = new IPEndPoint(address[0], port);
            mtxRecvData.WaitOne();
            lastRecvRemoteAddr = new IPEndPoint(address[0], port);
            mtxRecvData.ReleaseMutex();

            sendData(encodeData(SessDataReq, lastReqSYN, 0, null));
            Debug.Log(DateTime.Now.ToString() + "==================== send req SYN:" + lastReqSYN.ToString());

            state = State.req;
        }
        catch (Exception e)
        {
            Debug.LogError(DateTime.Now.ToString() + "udp ConnectServer error:" + e.Message + "\n" + e.StackTrace);
            Close();
        }
    }

    /// <summary>
    /// 写数据
    /// </summary>
    void WriteMessage(byte[] message)
    {
        if (state != State.conn)
        {
            Debug.LogError(DateTime.Now.ToString() + "send data ,but not connected!");
            return;
        }

        try { 
            MemoryStream ms = null;
            using (ms = new MemoryStream())
            {
                ms.Position = 0;
                BinaryWriter writer = new BinaryWriter(ms);

                //前2个字节写入消息长度，sproto传输时长度信息都使用大端数据
                ushort msglen = (ushort)message.Length;
                byte[] len_data = System.BitConverter.GetBytes(msglen);    //得到小端字节序数组
                Array.Reverse(len_data);                                   //反转数组转成大端。

                writer.Write(len_data);
                writer.Write(message);
                writer.Flush();
                if (client != null)
                {
                    byte[] payload = ms.ToArray();
                    if (AppConst.UdpDebugLog)
                    {
                        Debug.Log(DateTime.Now.ToString() + "================= kcp send:" + KcpId.ToString() + ":" + bytesMd5(payload));
                    }
                    LuaInterface.LuaDLL.ikcp_send(KcpHandle, payload, payload.Length);
                }
                else
                {
                    Debug.LogError(DateTime.Now.ToString() + "client.connected----->>false");
                }
            }
        }
        catch (Exception err)
        {
            Debug.LogError(DateTime.Now.ToString() + "WriteMessage error:" + err.Message + "\n" + err.StackTrace);
            Close();
        }
    }

    /// <summary>
    /// 丢失链接
    /// </summary>
    void OnDisconnected(DisType dis, string msg)
    {
        Close();   //关掉客户端链接
        int protocal = dis == DisType.Exception ? Protocal.Exception : Protocal.Disconnect;
        NetworkManager.AddEvent(protocal, null);
        Debug.LogError(DateTime.Now.ToString() + "Connection was closed by the server:>" + msg + " Distype:>" + dis);
    }

    //规定转换起始位置和长度
    public static void ReverseBytes(byte[] bytes, int start, int len)
    {
        int end = start + len - 1;
        byte tmp;
        int i = 0;
        for (int index = start; index < start + len / 2; index++, i++)
        {
            tmp = bytes[end - i];
            bytes[end - i] = bytes[index];
            bytes[index] = tmp;
        }
    }

    /// <summary>
    /// 剩余的字节
    /// </summary>
    private long RemainingBytes()
    {
        return memStream.Length - memStream.Position;
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    /// <param name="ms"></param>
    void OnReceivedMessage(MemoryStream ms)
    {
        BinaryReader r = new BinaryReader(ms);
        byte[] message = r.ReadBytes((int)(ms.Length - ms.Position));
        NetworkManager.AddEvent(Protocal.Message, message);
    }

    void OnReceivedMessage(ushort len)
    {
        NetworkManager.AddEvent(Protocal.Message, reader.ReadBytes(len));
    }

    /// <summary>
    /// 关闭链接
    /// </summary>
    public void Close()
    {
        if (timer != null)
        {
            timer.Stop();
            timer = null;
        }

        if (client != null)
        {
            client.Close();
            memStream.SetLength(0);
            client = null;
        }

        if (KcpHandle != IntPtr.Zero)
        {
            try
            { 
                LuaInterface.LuaDLL.ikcp_release(KcpHandle);
            }
            catch (Exception err)
            {
                Debug.LogError(DateTime.Now.ToString() + "Close release ikcp error:" + err.Message + "\n" + err.StackTrace);
            }

            KcpHandle = IntPtr.Zero;
        }



        lastReqSYN = 0;
        KcpId = 0;
        state = State.close;

        objectsMutex.WaitOne();
        mapObjects.Remove(MyObjectId);
        objectsMutex.ReleaseMutex();

    }

    /// <summary>
    /// 发送连接请求
    /// </summary>
    public void Connect(string _addr)
    {
        ConnectServer(_addr);
    }



    public void SendMessage(byte[] bytes)
    {
        WriteMessage(bytes);
    }
}
