#!/usr/bin/env bash


# TODO: don't hardcode these
FCEUX_ABSPATH=/nix/store/5k4wijw1pcd7i0icl891x10g368zxa61-fceux-2.2.3/bin/fceux
ROM_ABSPATH="/home/jrdek/tas/roms/nes/mario.nes"

TESTLUA_FILE="test_mario.lua"


TESTLUA_ABSPATH=$(realpath ./$TESTLUA_FILE)
echo "/---- -- -"
echo "| Running Lua script:"
echo "| $TESTLUA_ABSPATH"
echo "\\---- -- -"

# ANTITHESIS_OUTPUT_DIR=$(realpath ./output)

/nix/store/5k4wijw1pcd7i0icl891x10g368zxa61-fceux-2.2.3/bin/fceux \
    --loadlua $TESTLUA_ABSPATH \
    $ROM_ABSPATH
