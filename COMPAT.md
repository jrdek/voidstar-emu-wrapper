# Issues and how to fix them
- Our FCEUX uses lua 5.1, but this project is 5.5.
  - Delete all `<const>`s.
    - `(\s*<const>\s*)=` -> ` =`
  - Note that `string.format("%s", arg)` requires `arg` to be a string!
- Passing environment variables doesn't seem to work.
  - In `src/anti_files.lua`, hardcode `ANTITHESIS_OUTPUT_DIR` if needed.
- FCEUX seems to override `tostring` somewhere. This matters a lot for numbers.
  - lol https://github.com/TASEmulators/fceux/issues/22#issuecomment-449019638
  - Basically just always use format with %d.

## TODO
I'd really like to keep writing in 5.5 -- `<const>` is quite valuable.
So I'd like to have a script to convert 5.5 to 5.1.
It might be nice if that script also throws warnings on number-printing issues.
