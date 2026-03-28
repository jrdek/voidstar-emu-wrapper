

local json = require "src.utils.json";
require "src.utils.array";

local function show_json(obj)
    print(json.from(obj))
end


-- primitives
show_json( 3 )
show_json( 1.23 )
show_json( "hello!" )
show_json( json.null )

-- arrays
show_json( Array({}) )
show_json( Array({"first", "second"}) )
show_json( Array({ Array({}), Array({1}), Array({1, 2}), json.null }))

-- objects
show_json( {} )
show_json( {what = "even", isnt = json.null, xs = Array({1, "huh", {}})} )

-- {"antithesis_setup": { "status": "complete", "details": null }}