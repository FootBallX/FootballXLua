/*
** Lua binding: PomeloClient
** Generated automatically by tolua++-1.0.92 on Wed Apr  2 18:23:35 2014.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"

/* Exported function */
TOLUA_API int  tolua_Flip3DEx_open (lua_State* tolua_S);
#include "tolua_fix.h"
#include "cocos2d.h"
#include "CFlip3DEx.h"

using namespace cocos2d;

int lua_cocos2dx_Flip3DEx_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.Flip3DEx",0,&tolua_err)) goto tolua_lerror;
#endif
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (argc == 3)
    {
        float duration = (float)tolua_tonumber(tolua_S, 1, 0);
        float from = (float)tolua_tonumber(tolua_S, 2, 0);
        float to = (float)tolua_tonumber(tolua_S, 3, 0);
        
        CFlip3DYEx* ret = CFlip3DYEx::create(duration, from, to);
        tolua_pushusertype(tolua_S,(void*)ret,"cc.Flip3DEx");
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_FlipX3D_create'.",&tolua_err);
#endif
    return 0;
}


static int lua_cocos2dx_Flip3DEx_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Flip3DEx)");
    return 0;
}

int tolua_Flip3DEx_open(lua_State* tolua_S)
{
    tolua_module(tolua_S,"cc",0);
        tolua_usertype(tolua_S,"cc.Flip3DEx");
        tolua_cclass(tolua_S,"Flip3DEx","cc.Flip3DEx","cc.FlipX3D",nullptr);
        
        tolua_beginmodule(tolua_S,"Flip3DEx");
            tolua_function(tolua_S,"create", lua_cocos2dx_Flip3DEx_create);
        tolua_endmodule(tolua_S);

    tolua_endmodule(tolua_S);
    return 1;
}

