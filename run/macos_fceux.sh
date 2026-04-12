#!/bin/bash
set -e;

LIBSNOUTY_PATH=$(echo $(dirname $0)/.. | realpath);
cd "$LIBSNOUTY_PATH";

###== TEST CONFIG ==###
ROM_NAME="mario.nes";

# SCRIPT_NAME="mario/test_mario.lua";
SCRIPT_NAME="mario_reachability.lua";
# SCRIPT_NAME="mario/fake_warmboot.lua";
# SCRIPT_NAME="mario/open_bus.lua";

SCRIPT_PATH="$LIBSNOUTY_PATH/test/$SCRIPT_NAME";


###= SNOUTY CONFIG =###
ANTITHESIS_OUTPUT_DIR="$LIBSNOUTY_PATH/output";
ROMSDIR_PATH="$LIBSNOUTY_PATH/roms";

ROM_PATH="$ROMSDIR_PATH/$ROM_NAME";


###= SYSTEM CONFIG =###
FCEUX_BINARY="/opt/homebrew/Cellar/fceux/2.6.6_9/libexec/fceux";
BASE_FCEUX_LUA_PATH="/opt/homebrew/Cellar/fceux/2.6.6_9/share/fceux/luaScripts/?.lua";


# make sure the output dir exists
mkdir -p "$ANTITHESIS_OUTPUT_DIR";
# then run!
LUA_PATH="$LIBSNOUTY_PATH/?.lua;;" \
ANTITHESIS_OUTPUT_DIR="$ANTITHESIS_OUTPUT_DIR" \
exec \
$FCEUX_BINARY \
    --loadlua "$SCRIPT_PATH" \
    "$ROM_PATH"
