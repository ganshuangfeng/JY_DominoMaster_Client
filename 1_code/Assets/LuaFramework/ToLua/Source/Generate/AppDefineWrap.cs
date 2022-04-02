﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class AppDefineWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(AppDefine), typeof(System.Object));
		L.RegFunction("IsEDITOR", IsEDITOR);
		L.RegFunction("New", _CreateAppDefine);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("m_CurrentProjectPath", get_m_CurrentProjectPath, set_m_CurrentProjectPath);
		L.RegVar("PlatformPath", get_PlatformPath, set_PlatformPath);
		L.RegVar("CurrentProjectPath", get_CurrentProjectPath, set_CurrentProjectPath);
		L.RegVar("LOCAL_DATA_PATH", get_LOCAL_DATA_PATH, null);
		L.RegVar("IsLuaBundleMode", get_IsLuaBundleMode, set_IsLuaBundleMode);
		L.RegVar("IsDebug", get_IsDebug, set_IsDebug);
		L.RegVar("IsForceOpenYK", get_IsForceOpenYK, set_IsForceOpenYK);
		L.RegVar("IsOffLine", get_IsOffLine, set_IsOffLine);
		L.RegVar("CurResPath", get_CurResPath, set_CurResPath);
		L.RegVar("CurQuDao", get_CurQuDao, set_CurQuDao);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateAppDefine(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				AppDefine obj = new AppDefine();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: AppDefine.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsEDITOR(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			bool o = AppDefine.IsEDITOR();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_CurrentProjectPath(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.m_CurrentProjectPath);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PlatformPath(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.PlatformPath);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CurrentProjectPath(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.CurrentProjectPath);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_LOCAL_DATA_PATH(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.LOCAL_DATA_PATH);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsLuaBundleMode(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, AppDefine.IsLuaBundleMode);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsDebug(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, AppDefine.IsDebug);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsForceOpenYK(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, AppDefine.IsForceOpenYK);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsOffLine(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, AppDefine.IsOffLine);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CurResPath(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.CurResPath);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CurQuDao(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, AppDefine.CurQuDao);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_CurrentProjectPath(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			AppDefine.m_CurrentProjectPath = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_PlatformPath(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			AppDefine.PlatformPath = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_CurrentProjectPath(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			AppDefine.CurrentProjectPath = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_IsLuaBundleMode(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			AppDefine.IsLuaBundleMode = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_IsDebug(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			AppDefine.IsDebug = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_IsForceOpenYK(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			AppDefine.IsForceOpenYK = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_IsOffLine(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			AppDefine.IsOffLine = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_CurResPath(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			AppDefine.CurResPath = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_CurQuDao(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			AppDefine.CurQuDao = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

