--[[
A *JSAV header* is a header at the beginning of a save state binary file.

The point is that it lets us store information which is important for
reinitializing libsnouty -- e.g., the last line of the input TAS used --
in a clear, predictable, emulator-agnostic way.

Q: Why have this in this library in the first place?
A: I was getting really annoyed by slow iteration time when fixing the end
   of the World N-1 ACE repro. ^^' 
--]]

local bytes = require "test.utils.bytes";

local types = {
    unsigned = {
        size = bytes.sizeof.lua_Number,
        pack = bytes.pack_unsigned,
        unpack = bytes.unpack_unsigned
    }
};

local JsavHeader = {};



JsavHeader._start = "JSAV{";
JsavHeader._end = "}";
JsavHeader._field_sep = ":";
JsavHeader._field_end = ",";

-- these are in order
JsavHeader._fields = {
    {
        name = "lastInput",
        type = types.unsigned,
        collect = function ()
            return inputline;
        end
    },
};


local sizeof_jsav_fields = 0;
for _, finfo in ipairs(JsavHeader._fields) do
	sizeof_jsav_fields = sizeof_jsav_fields +
		#finfo.name +
		#JsavHeader._field_sep +
		finfo.type.size +
		#JsavHeader._field_end;
end
local jsav_header_size <const> =
	#JsavHeader._start +
	sizeof_jsav_fields +
	#JsavHeader._end;
JsavHeader._size = jsav_header_size;


local function padded_jsav_field(finfo)
	return finfo.name ..
		JsavHeader._field_sep ..
		finfo.type.pack(finfo.collect()) ..
		JsavHeader._field_end;
end


function JsavHeader.build()
    local serialized_arr = {};
    table.insert(serialized_arr, JsavHeader._start);
    for _, finfo in ipairs(JsavHeader._fields) do
        table.insert(serialized_arr, padded_jsav_field(finfo));
    end
    table.insert(serialized_arr, JsavHeader._end);
    return table.concat(serialized_arr);
end


local function read_and_assert_match(file, golden_bytes, err)
    err = err or ("failed to match " .. golden_bytes);
    local bytes_from_file = file:read(#golden_bytes);
    assert(bytes_from_file == golden_bytes, err);
end


local function read_and_parse(file, type)
    local blob = file:read(type.size);
    return type.unpack(blob);
end


function JsavHeader.parse(file)
    read_and_assert_match(file, JsavHeader._start, "not a jsav header");
    local data = {};
	for _, finfo in ipairs(JsavHeader._fields) do
        read_and_assert_match(file, finfo.name .. JsavHeader._field_sep);
        data[finfo.name] = read_and_parse(file, finfo.type);
        read_and_assert_match(file, JsavHeader._field_end);
    end
    read_and_assert_match(file, JsavHeader._end, "malformed jsav header");
    return data;
end



return JsavHeader;