# Lantern Load

Lantern Load provides a simple implementation of version resolution intended to allow data packs and their dependencies to load in a controllable order.
Projects that depend on this library include [AESTD], [Gamemode 4], and [PlayerDB].

This project is released under the [BSD 0-Clause License], which in short means you can do anything you want with or without attribution.
If you are familiar with the MIT License, this license is that but even more permissive.
This licensing choice permits you to use the repository's contents for any purpose--commercial or non-commercial, open source or not--with nothing expected in return.
It is our hope that this promotes innovation across the wider data pack ecosystem.

## Usage

1. Copy the `load` and `minecraft` directories from `load/data/` into your pack's `data` folder. The copied in `load.json` should now call `#load:_private/load`.

2. Add load functions in the desired load order to `data/load/tags/functions/load.json` or the other tags `pre_load.json` and  `post_load.json`. For most cases you should prefer `load.json`. Example `load.json` contents:

```json
{
    "values": [
        "pack1:load",
        "your_pack:load"
    ]
}
```

## Version Resolution

Packs can publish their versions to the `load.status` scoreboard objective using the [Semantic Versioning] scheme in the following manner:

- `your_pack.version.major`: Major version number, incremented when breaking changes are made.
- `your_pack.version.minor`: Minor version number, incremented when new features are added, reset when the major version is incremented.
- `your_pack.version.patch`: Patch version number, incremented when bug fixes are applied, reset when the minor or major version is incremented.

Some data packs may find it useful to consolidate minor and patch versions into a single scoreboard:

- `your_pack.version.minorpatch` = `your_pack.version.minor * 1000 + your_pack.version.patch`
 
```ini
# Add own data pack's version (1.0.0).
scoreboard players set your_pack.version.major load.status 1
scoreboard players set your_pack.version.minor load.status 0
scoreboard players set your_pack.version.patch load.status 0
```

If you depend on another pack, you should check its version before initializing your own pack.
At a minimum its major and minor versions should be checked to maintain expected behavior:

```ini
# Check that dependency pack version is >= 1.0 and < 2.0.
execute if score your_pack.version.major load.status matches 1 if score your_pack.version.minor load.status matches 0.. run ...
```

### Avoiding the `#minecraft:tick` tag

Packs should not put their tick functions in the `#minecraft:tick` tag, and should instead schedule their tick functions on load using `schedule` and to reschedule at the end of their tick functions.
This solves two problems:

- The vanilla `#minecraft:tick` tag runs **before** `#minecraft:load`, and as such the loading process will not be complete when the tick function runs for the first time after loading.
- `#minecraft:tick` always runs all its functions every tick, with no way to disable a function apart from wrapping it in a function that checks a condition. This wastes performance when a tick function is not needed.

Using `schedule` for tick functions is also useful for version handling.
You should clear your schedule tick function(s) on every reload, and only re-schedule them after confirming that your dependency versions are compatible.
This has the effect of disabling your pack when required dependencies are missing, rather than causing cryptic errors and breaking your world.

Under normal circumstances, as per [Semantic Versioning], a dependency is compatible if the `major` version is equal to the expected version, and the `minor` and `patch` versions are greater than or equal to the expected version.

## Data Storage

Data packs can store load-related data in the `load:data` storage namespace.
The NBT path `load:data _` will be cleared on reload, similarly to `load.status`.
Packs **must** properly namespace tags added to this storage path.

```ini
# Set a variable that is specific to the current reload.
data modify storage load:data _.your_pack.FavoriteNumber set value 521
```

## License

Lantern Load is made freely available under the terms of the [BSD 0-Clause License].
Third-party contributions shall be licensed under the same terms unless explicitly stated otherwise.

[AESTD]: https://github.com/Aeldrion/AESTD
[Gamemode 4]: https://github.com/Gamemode4Dev/GM4_Datapacks
[PlayerDB]: https://github.com/rx-modules/PlayerDB
[Semantic Versioning]: https://semver.org/
[BSD 0-Clause License]: LICENSE
