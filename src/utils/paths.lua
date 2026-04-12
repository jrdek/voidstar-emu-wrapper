

local module = {};


local function find_last(s, pattern, plain)
   local match_start, match_end = nil, nil;
   local last_start, last_end = nil, nil;
   local init = 0;
   repeat
      last_start, last_end = match_start, match_end;
      match_start, match_end = s:find(pattern, init, plain);
      init = (match_end or 0) + 1;
   until match_start == nil;
   return last_start, last_end;
end

function module.path_to_repo_root()
   local here = debug.getinfo(1, "S").source:sub(2);
   -- find the last `/src/` in the path to *this file's* directory
   local src_end_idx = select(2, find_last(here, "/src/", true));
   local path_to_src = here:sub(1, src_end_idx);
   return path_to_src .. ".."
end


return module