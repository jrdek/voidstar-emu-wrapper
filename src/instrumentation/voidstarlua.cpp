extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
}

extern "C" int luaopen_libvoidstarlua(lua_State* L);

extern "C" size_t init_coverage_module(size_t edge_count, const char* symbol_file_name);
extern "C" bool notify_coverage(size_t edge_plus_module);
extern "C" int fuzz_getchar();

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
        luaL_error(L, "notify_coverage() takes one argument (got %d)", argc);
    }
    lua_Integer edge_plus_module = luaL_checkinteger(L, 1);

    bool result = (lua_Integer) notify_coverage(edge_plus_module);
    lua_pushboolean(L, result);
    return 1;
}

static int l_fuzz_getchar(lua_State* L) {
    int argc = lua_gettop(L);
    if (argc != 0) {
        luaL_error(L, "fuzz_getchar() takes no arguments (got %d)", argc);
    }
    
    lua_Integer gotten_char = (lua_Integer) fuzz_getchar();
    lua_pushinteger(L, gotten_char);
    return 1;
}


// n.b.: this function name is load-bearing, and so is the output .so's name!
int luaopen_libvoidstarlua(lua_State* L) {
    luaL_Reg funcs[] = {
        {"initCoverageModule", l_init_coverage_module},
        {"notifyCoverage", l_notify_coverage},
        {"fuzzGetChar", l_fuzz_getchar},
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