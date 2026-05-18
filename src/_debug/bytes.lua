--[[
Various utilities that have to do with storing Lua values in binary files.
(This hides the magic "J", among other things.)
--]]

local libbytes = {};
libbytes.sizeof = {};



function libbytes.pack_unsigned(n)
	return string.pack("J", n);
end

function libbytes.unpack_unsigned(bs)
	return string.unpack("J", bs);
end

local LUA_UNSIGNED_SIZE <const> = #(string.pack("J", 0));
libbytes.sizeof.lua_Number = LUA_UNSIGNED_SIZE;



return libbytes;