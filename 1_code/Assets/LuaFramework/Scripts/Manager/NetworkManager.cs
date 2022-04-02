using UnityEngine;
using UnityEngine.Networking;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.IO;
using System.Text;
using LuaInterface;

namespace LuaFramework
{
    public class NetworkManager : Manager
    {
        private SocketClient socket;
        static readonly object m_lockObject = new object();
        static Queue<KeyValuePair<int, LuaByteBuffer>> mEvents = new Queue<KeyValuePair<int, LuaByteBuffer>>();

        void Awake()
        {
            //Init();
        }

        public void Init()
        {
            //socket.Create();
        }

        public void OnInit()
        {
            CallMethod("Start");
        }

        public void Unload()
        {
            CallMethod("Unload");
        }

        /// <summary>
        /// ִ��Lua����
        /// </summary>
        public object[] CallMethod(string func, params object[] args)
        {
            return Util.CallMethod("Network", func, args);
        }

        ///------------------------------------------------------------------------------------
        [NoToLua]
        public static void AddEvent(int _event, byte[] message)
        {
            if (message == null)
                message = new byte[1];

            LuaByteBuffer data = new LuaInterface.LuaByteBuffer(message);
            lock (m_lockObject)
            {
                mEvents.Enqueue(new KeyValuePair<int, LuaByteBuffer>(_event, data));
            }
        }

        /// <summary>
        /// ����Command�����ﲻ����ķ���˭��
        /// </summary>
        void Update()
        {
            if (mEvents.Count > 0)
            {
                while (mEvents.Count > 0)
                {
                    KeyValuePair<int, LuaByteBuffer> _event = mEvents.Dequeue();
                    Util.CallMethod("Network", "OnSocket", _event.Key, _event.Value);
                }
            }
        }

        /// <summary>
        /// ������������
        /// </summary>
        public void SendConnect()
        {
            if (socket != null)
            {
                socket.Destroy();
                socket = null;
            }

            string _addr;

            if (AppConst.SocketAddress.Substring(0, 4).ToLower() == "udp:")
            {
                _addr = AppConst.SocketAddress.Substring(4);
                socket = new SocketClientUdp();
            }
            else
            {
                _addr = AppConst.SocketAddress;
                socket = new SocketClientTcp();
            }
            socket.Create();

            socket.Connect(_addr);
        }

        /// <summary>
        /// ����SOCKET��Ϣ
        /// </summary>
        //public void SendMessage(ByteBuffer buffer)
        //{
        //    socket.SendMessage(buffer.ToBytes());
        //}

        /// <summary>
        /// ����SOCKET��Ϣ
        /// SendMessage ����̫�࣬��ǰ�໹�̳���mono���޷�ʶ��ǰ����
        /// </summary>
        /// <param name="buffer"></param>
        public void SendMessageData(LuaByteBuffer buffer)
        {
            socket.SendMessage(buffer.buffer);
        }


        /// <summary>
        /// Disconnect SOCKET
        /// </summary>
        public void DestroyConnect()
        {
            socket.Disconnect();
        }

        /// <summary>
        /// ��������
        /// </summary>
        void OnDestroy()
        {
            socket.Destroy();
            Debug.Log("~NetworkManager was destroy");
        }


		private IEnumerator Post(string url, string data, string contentType, string authorization, Action<long> callback) {
			UnityWebRequest req = new UnityWebRequest (url, "POST");
			req.uploadHandler = (UploadHandler)new UploadHandlerRaw (Encoding.UTF8.GetBytes (data));
			req.downloadHandler = (DownloadHandler)new DownloadHandlerBuffer ();
			req.SetRequestHeader ("Content-Type", contentType);
			req.SetRequestHeader("Authorization", authorization);

			yield return req.SendWebRequest ();
			callback.Invoke (req.responseCode);
		}
		public void SendPostRequest(string url, string data, string contentType, string authorization, LuaFunction callback) {
			StartCoroutine (Post (url, data, contentType, authorization, (long code)=>{
				callback.Call((int)code);
			}));
		}
    }
}