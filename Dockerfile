# === build Mesen ===
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS mesenbuilder

RUN apt-get update && apt-get install -y --no-install-recommends \
  clang \
  libsdl2-dev \
  make \
  zip \
  unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /Mesen2
COPY ./Mesen2 /Mesen2

RUN make clean
RUN make


# === now it's usable: ===
FROM docker.io/ubuntu:24.04 AS runner

RUN apt-get update && apt-get install -y --no-install-recommends \
  clang \
  libsdl2-dev \
  libfontconfig1 \
  dotnet-sdk-8.0 \
  && rm -rf /var/lib/apt/lists/*


COPY --from=mesenbuilder /Mesen2/bin/linux-x64/Release/linux-x64/publish /opt/Mesen2

COPY --from=mesenbuilder /Mesen2/Lua /opt/Mesen2Lua

# if we don't do this, mesen will try to open a window to initialize settings
RUN : > /opt/Mesen2/settings.json

RUN mkdir -p /symbols
RUN mkdir -p /opt/luasrc
WORKDIR /opt/luasrc
COPY ./src ./src
COPY ./test ./test
COPY ./reference ./reference
COPY ./roms /opt/roms

COPY ./libvoidstar.so /usr/lib/libvoidstar.so
ENV PATH="$PATH:/usr/lib"

RUN clang \
  -shared \
  -fPIC \
  -o /opt/luasrc/src/instrumentation/libvoidstarlua.so \
  /opt/luasrc/src/instrumentation/voidstarlua.cpp \
  /opt/Mesen2Lua/*.c \
  -I /opt/Mesen2Lua/ \
  -L /usr/lib/ \
  -lvoidstar


ENTRYPOINT LUA_PATH="/opt/luasrc/?.lua;;" \
  ANTITHESIS_OUTPUT_DIR=$ANTITHESIS_OUTPUT_DIR \
  LUA_CPATH="/opt/luasrc/src/instrumentation/?.so;;" \
  DYLD_LIBRARY_PATH="/usr/lib" \
  /opt/Mesen2/Mesen \
    --enablestdout \
    --testrunner \
    --timeout=2147483 \
    --Debug.ScriptWindow.AllowIoOsAccess=true \
    --Debug.ScriptWindow.ScriptTimeout=10 \
    /opt/luasrc/test/games/smb1/play_urandom.lua \
    /opt/roms/mario.nes