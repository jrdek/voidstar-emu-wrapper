 #!/bin/bash
set -e;

LIBSNOUTY_PATH=$(realpath $(dirname $0)/..);
cd "$LIBSNOUTY_PATH";


###== TEST CONFIG ==###
GAME_NAME="mario";
ROM_EXTENSION=".nes";
ROM_NAME=$GAME_NAME$ROM_EXTENSION;

#SCRIPT_NAME="play_urandom.lua";
SCRIPT_NAME="world_n_start.lua";

SCRIPT_PATH="$LIBSNOUTY_PATH/games/$GAME_NAME/tests/mesen/$SCRIPT_NAME";


###= SNOUTY CONFIG =###
ANTITHESIS_OUTPUT_DIR="$LIBSNOUTY_PATH/output";
ROMSDIR_PATH="$LIBSNOUTY_PATH/roms";

ROM_PATH="$ROMSDIR_PATH/$ROM_NAME";


###= SYSTEM CONFIG =###
MESEN_BINARY=$(which Mesen);
# MESEN_BINARY="$LIBSNOUTY_PATH/Mesen2/bin/linux-x64/Release/linux-x64/publish/Mesen";
# FIXME!

# make sure the output dir exists
mkdir -p "$ANTITHESIS_OUTPUT_DIR";
# then run!
# (adding the arg `--testrunner` makes Mesen run headlessly.)
LUA_PATH="$LIBSNOUTY_PATH/?.lua;;" \
ANTITHESIS_OUTPUT_DIR="$ANTITHESIS_OUTPUT_DIR" \
exec \
"$MESEN_BINARY" \
    -enablestdout \
    "$SCRIPT_PATH" \
    "$ROM_PATH"
