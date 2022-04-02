﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_ParticleSystem_ParticleWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.ParticleSystem.Particle), null);
		L.RegFunction("GetCurrentSize", GetCurrentSize);
		L.RegFunction("GetCurrentSize3D", GetCurrentSize3D);
		L.RegFunction("GetCurrentColor", GetCurrentColor);
		L.RegFunction("New", _CreateUnityEngine_ParticleSystem_Particle);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("position", get_position, set_position);
		L.RegVar("velocity", get_velocity, set_velocity);
		L.RegVar("animatedVelocity", get_animatedVelocity, null);
		L.RegVar("totalVelocity", get_totalVelocity, null);
		L.RegVar("remainingLifetime", get_remainingLifetime, set_remainingLifetime);
		L.RegVar("startLifetime", get_startLifetime, set_startLifetime);
		L.RegVar("startColor", get_startColor, set_startColor);
		L.RegVar("randomSeed", get_randomSeed, set_randomSeed);
		L.RegVar("axisOfRotation", get_axisOfRotation, set_axisOfRotation);
		L.RegVar("startSize", get_startSize, set_startSize);
		L.RegVar("startSize3D", get_startSize3D, set_startSize3D);
		L.RegVar("rotation", get_rotation, set_rotation);
		L.RegVar("rotation3D", get_rotation3D, set_rotation3D);
		L.RegVar("angularVelocity", get_angularVelocity, set_angularVelocity);
		L.RegVar("angularVelocity3D", get_angularVelocity3D, set_angularVelocity3D);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_ParticleSystem_Particle(IntPtr L)
	{
		UnityEngine.ParticleSystem.Particle obj = new UnityEngine.ParticleSystem.Particle();
		ToLua.PushValue(L, obj);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurrentSize(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystem.Particle));
			UnityEngine.ParticleSystem arg0 = (UnityEngine.ParticleSystem)ToLua.CheckObject(L, 2, typeof(UnityEngine.ParticleSystem));
			float o = obj.GetCurrentSize(arg0);
			LuaDLL.lua_pushnumber(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurrentSize3D(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystem.Particle));
			UnityEngine.ParticleSystem arg0 = (UnityEngine.ParticleSystem)ToLua.CheckObject(L, 2, typeof(UnityEngine.ParticleSystem));
			UnityEngine.Vector3 o = obj.GetCurrentSize3D(arg0);
			ToLua.Push(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurrentColor(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystem.Particle));
			UnityEngine.ParticleSystem arg0 = (UnityEngine.ParticleSystem)ToLua.CheckObject(L, 2, typeof(UnityEngine.ParticleSystem));
			UnityEngine.Color32 o = obj.GetCurrentColor(arg0);
			ToLua.PushValue(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_position(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.position;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index position on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_velocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.velocity;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index velocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_animatedVelocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.animatedVelocity;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index animatedVelocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_totalVelocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.totalVelocity;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index totalVelocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_remainingLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float ret = obj.remainingLifetime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index remainingLifetime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float ret = obj.startLifetime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startLifetime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Color32 ret = obj.startColor;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startColor on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_randomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			uint ret = obj.randomSeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index randomSeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_axisOfRotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.axisOfRotation;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index axisOfRotation on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float ret = obj.startSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startSize3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.startSize3D;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startSize3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float ret = obj.rotation;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotation on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rotation3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.rotation3D;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotation3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_angularVelocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float ret = obj.angularVelocity;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angularVelocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_angularVelocity3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 ret = obj.angularVelocity3D;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angularVelocity3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_position(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.position = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index position on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_velocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.velocity = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index velocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_remainingLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.remainingLifetime = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index remainingLifetime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startLifetime = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startLifetime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Color32 arg0 = StackTraits<UnityEngine.Color32>.Check(L, 2);
			obj.startColor = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startColor on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_randomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.randomSeed = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index randomSeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_axisOfRotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.axisOfRotation = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index axisOfRotation on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startSize = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startSize3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.startSize3D = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index startSize3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.rotation = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotation on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rotation3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.rotation3D = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotation3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_angularVelocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.angularVelocity = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angularVelocity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_angularVelocity3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem.Particle obj = (UnityEngine.ParticleSystem.Particle)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.angularVelocity3D = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angularVelocity3D on a nil value");
		}
	}
}

