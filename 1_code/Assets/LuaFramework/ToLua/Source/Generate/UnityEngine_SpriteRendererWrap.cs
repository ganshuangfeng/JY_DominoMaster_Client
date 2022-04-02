﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_SpriteRendererWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.SpriteRenderer), typeof(UnityEngine.Renderer));
		L.RegFunction("New", _CreateUnityEngine_SpriteRenderer);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("sprite", get_sprite, set_sprite);
		L.RegVar("drawMode", get_drawMode, set_drawMode);
		L.RegVar("size", get_size, set_size);
		L.RegVar("adaptiveModeThreshold", get_adaptiveModeThreshold, set_adaptiveModeThreshold);
		L.RegVar("tileMode", get_tileMode, set_tileMode);
		L.RegVar("color", get_color, set_color);
		L.RegVar("maskInteraction", get_maskInteraction, set_maskInteraction);
		L.RegVar("flipX", get_flipX, set_flipX);
		L.RegVar("flipY", get_flipY, set_flipY);
		L.RegVar("spriteSortPoint", get_spriteSortPoint, set_spriteSortPoint);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_SpriteRenderer(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.SpriteRenderer obj = new UnityEngine.SpriteRenderer();
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.SpriteRenderer.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sprite(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Sprite ret = obj.sprite;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sprite on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteDrawMode ret = obj.drawMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index drawMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_size(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Vector2 ret = obj.size;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index size on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_adaptiveModeThreshold(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			float ret = obj.adaptiveModeThreshold;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index adaptiveModeThreshold on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_tileMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteTileMode ret = obj.tileMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index tileMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_color(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Color ret = obj.color;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index color on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maskInteraction(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteMaskInteraction ret = obj.maskInteraction;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maskInteraction on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flipX(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			bool ret = obj.flipX;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flipX on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flipY(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			bool ret = obj.flipY;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flipY on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_spriteSortPoint(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteSortPoint ret = obj.spriteSortPoint;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index spriteSortPoint on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sprite(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Sprite arg0 = (UnityEngine.Sprite)ToLua.CheckObject(L, 2, typeof(UnityEngine.Sprite));
			obj.sprite = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sprite on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_drawMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteDrawMode arg0 = (UnityEngine.SpriteDrawMode)LuaDLL.luaL_checknumber(L, 2);
			obj.drawMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index drawMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_size(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.size = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index size on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_adaptiveModeThreshold(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.adaptiveModeThreshold = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index adaptiveModeThreshold on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_tileMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteTileMode arg0 = (UnityEngine.SpriteTileMode)LuaDLL.luaL_checknumber(L, 2);
			obj.tileMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index tileMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_color(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.color = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index color on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maskInteraction(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteMaskInteraction arg0 = (UnityEngine.SpriteMaskInteraction)LuaDLL.luaL_checknumber(L, 2);
			obj.maskInteraction = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maskInteraction on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flipX(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.flipX = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flipX on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flipY(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.flipY = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flipY on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_spriteSortPoint(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.SpriteRenderer obj = (UnityEngine.SpriteRenderer)o;
			UnityEngine.SpriteSortPoint arg0 = (UnityEngine.SpriteSortPoint)LuaDLL.luaL_checknumber(L, 2);
			obj.spriteSortPoint = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index spriteSortPoint on a nil value");
		}
	}
}

