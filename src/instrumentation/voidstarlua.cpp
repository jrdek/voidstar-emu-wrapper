extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
}

extern "C" int luaopen_libvoidstarlua(lua_State* L);

extern "C" size_t init_coverage_module(size_t edge_count, const char* symbol_file_name);
extern "C" bool notify_coverage(size_t edge_plus_module);
// extern int fuzz_getchar();

static int l_greet(lua_State* L) {
    // test func, to be deleted later
    const char* greeting = "YAY IT WORKS\n";
    lua_pushstring(L, greeting);
    return 1;
}

static int l_init_coverage_module(lua_State* L) {
    int argc = lua_gettop(L);
    if (argc != 2) {
        luaL_error(L, "init_coverage_module() takes two arguments (got %d)", argc);
    }
    lua_Integer edge_count = luaL_checkinteger(L, 1);
    const char* symbol_file_name = luaL_checkstring(L, 2);

    lua_Integer result = (lua_Integer) init_coverage_module(edge_count, symbol_file_name);
    lua_pushinteger(L, result);
    return 1;
}

static int l_notify_coverage(lua_State* L) {
    int argc = lua_gettop(L);
    if (argc != 1) {
        luaL_error(L, "notify_coverage() takes two arguments (got %d)", argc);
    }
    lua_Integer edge_plus_module = luaL_checkinteger(L, 1);

    bool result = (lua_Integer) notify_coverage(edge_plus_module);
    lua_pushboolean(L, result);
    return 1;
}


// n.b.: this function name is load-bearing, and so is the output .so's name!
int luaopen_libvoidstarlua(lua_State* L) {
    luaL_Reg funcs[] = {
        {"greet", l_greet},
        {"initCoverageModule", l_init_coverage_module},
        {"notifyCoverage", l_notify_coverage},
        {NULL, NULL}
    };
    // version checks since lua changes its API per version
#if LUA_VERSION_NUM >= 502
    luaL_newlib(L, funcs);
#else
    luaL_register(L, "libvoidstarlua", funcs);
#endif
    return 1;
}