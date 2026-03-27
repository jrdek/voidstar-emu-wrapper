
- Our FCEUX uses lua 5.1, but this project is 5.5.
  - Delete all `<const>`s.
    - `(\s*<const>\s*)=` -> ` =`
  - Note that `string.format("%s", arg)` requires `arg` to be a string!
- Passing environment variables doesn't seem to work.
  - In `src/anti_files.lua`, hardcode `ANTITHESIS_OUTPUT_DIR`.
- FCEUX seems to override `tostring` somewhere. This matters a lot for numbers.
  - lol https://github.com/TASEmulators/fceux/issues/22#issuecomment-449019638
  - Basically just always use format with %d.
