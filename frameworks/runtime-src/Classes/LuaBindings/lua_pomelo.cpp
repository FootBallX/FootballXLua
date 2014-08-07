//
//  lua_pomelo.cpp
//  FootballXLua
//
//  Created by ray on 14-8-6.
//
//

#include "lua_pomelo.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "CCPomelo.h"


//int lua_pomelo_destroyInstance(lua_State* tolua_S)
//{
//    int argc = 0;
//    bool ok  = true;
//    
//#if COCOS2D_DEBUG >= 1
//    tolua_Error tolua_err;
//#endif
//    
//#if COCOS2D_DEBUG >= 1
//    if (!tolua_isusertable(tolua_S,1,"ccp.Pomelo",0,&tolua_err)) goto tolua_lerror;
//#endif
//    
//    argc = lua_gettop(tolua_S) - 1;
//    
//    if (argc == 0)
//    {
//        if(!ok)
//            return 0;
//        delete POMELO;
//        return 0;
//    }
//    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "destroyInstance",argc, 0);
//    return 0;
//#if COCOS2D_DEBUG >= 1
//tolua_lerror:
//    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_destroyInstance'.",&tolua_err);
//#endif
//    return 0;
//}
//
//
//int lua_pomelo_constructor(lua_State* tolua_S)
//{
//    int argc = 0;
//    bool ok  = true;
//    
//#if COCOS2D_DEBUG >= 1
//    tolua_Error tolua_err;
//#endif
//    
//    argc = lua_gettop(tolua_S)-1;
//    if (argc == 0)
//    {
//        if(!ok)
//            return 0;
//        auto cobj = POMELO;
//        tolua_pushusertype(tolua_S,(void*)cobj,"ccp.Pomelo");
//        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
//        return 1;
//    }
//    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "Pomelo",argc, 0);
//    return 0;
//    
//#if COCOS2D_DEBUG >= 1
//    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_constructor'.",&tolua_err);
//#endif
//    
//    return 0;
//}

static int lua_pomelo_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Pomelo)");
    return 0;
}


int lua_pomelo_getInstance(lua_State* L)
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(L, 1, "ccp.Pomelo", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;

	if (argc == 0)
	{
		if (!ok)
			return 0;
		auto ret = POMELO;
		tolua_pushusertype(L, (void*)ret, "ccp.Pomelo");
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(L, "#ferror in function 'lua_pomelo_getInstance'.", &tolua_err);
#endif
	return 0;
}


int lua_pomelo_connect(lua_State* L)		//(const char* addr, int port);
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(L, 1, "ccp.Pomelo", 0, &tolua_err)) goto tolua_lerror;
#endif

	CCPomelo* cobj = (CCPomelo*)tolua_tousertype(L, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(L, "invalid 'cobj' in function 'lua_pomelo_connect'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(L) - 1;

	if (argc == 2)
	{
		if (!ok)
			return 0;
		std::string ip;
		int port;
		ok &= luaval_to_std_string(L, 2, &ip);
		ok &= luaval_to_int32(L, 3, &port);

		cobj->connect(ip.c_str(), port);

		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(L, "#ferror in function 'lua_pomelo_connect'.", &tolua_err);
#endif
	return 0;
}


int register_pomelo(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ccp.Pomelo");
    tolua_cclass(tolua_S,"Pomelo","ccp.Pomelo","",nullptr);
    
    tolua_beginmodule(tolua_S,"Pomelo");
    //tolua_function(tolua_S,"new",lua_pomelo_constructor);
	tolua_function(tolua_S, "getInstance", lua_pomelo_getInstance);
	tolua_function(tolua_S, "connect", lua_pomelo_connect);
//    tolua_function(tolua_S,"setJsonPath",lua_pomelo_setJsonPath);
//    tolua_function(tolua_S,"createNode",lua_pomelo_createNode);
//    tolua_function(tolua_S,"loadNodeWithFile",lua_pomelo_loadNodeWithFile);
//    tolua_function(tolua_S,"purge",lua_pomelo_purge);
//    tolua_function(tolua_S,"init",lua_pomelo_init);
//    tolua_function(tolua_S,"loadNodeWithContent",lua_pomelo_loadNodeWithContent);
//    tolua_function(tolua_S,"isRecordJsonPath",lua_pomelo_isRecordJsonPath);
//    tolua_function(tolua_S,"getJsonPath",lua_pomelo_getJsonPath);
//    tolua_function(tolua_S,"setRecordJsonPath",lua_pomelo_setRecordJsonPath);
    //tolua_function(tolua_S,"destroyInstance", lua_pomelo_destroyInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CCPomelo).name();
    g_luaType[typeName] = "ccp.Pomelo";
    g_typeCast["Pomelo"] = "ccp.Pomelo";

    return 1;
}






int register_all_pomelo(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	tolua_module(tolua_S, "ccp", 0);
	tolua_beginmodule(tolua_S, "ccp");

	register_pomelo(tolua_S);

	tolua_endmodule(tolua_S);

	return 1;
}