 #!/bin/bash
set -e;

LIBSNOUTY_PATH=$(realpath $(dirname $0)/..);
cd "$LIBSNOUTY_PATH";


###== TEST CONFIG ==###
ROM_NAME="mario.nes";

SCRIPT_NAME="games/smb1/play_urandom.lua";

SCRIPT_PATH="$LIBSNOUTY_PATH/test/$SCRIPT_NAME";


###= SNOUTY CONFIG =###
ANTITHESIS_OUTPUT_DIR="$LIBSNOUTY_PATH/output";
ROMSDIR_PATH="$LIBSNOUTY_PATH/roms";

ROM_PATH="$ROMSDIR_PATH/$ROM_NAME";


###= SYSTEM CONFIG =###
MESEN_BINARY=$(which Mesen);


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
