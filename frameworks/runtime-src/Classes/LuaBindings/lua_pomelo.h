//
//  lua_pomelo.h
//  FootballXLua
//
//  Created by ray on 14-8-6.
//
//

#ifndef __FootballXLua__lua_pomelo__
#define __FootballXLua__lua_pomelo__

#include "base/ccConfig.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_pomelo(lua_State* tolua_S);

#endif /* defined(__FootballXLua__lua_pomelo__) */
