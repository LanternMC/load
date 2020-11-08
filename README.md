# Lantern Load

Lantern Load provides a simple implementation of version resolution intended to
allow data packs and their dependencies to load in a controllable order. It is
currently used by the [AESTD] project, and in the future will be used by the
[Phi] project. This library is dedicated to the public domain and contains no
branding, so it is a simple addition to any data pack that requires dependencies
and wishes to be compatible with the greater data pack ecosystem.

## Usage
1. Copy the `load` and `minecraft` directories from `Load/data/` into your datapack's `data` folder. The copied in `load.json` should now call `#load:__init`.
2. Add load functions in the desired load order to `data/load/tags/functions/load.json` or the other tags `standard.json` and  `post_load.json`. For example, `load.json`:
```json
{
    "values": ["pack1:load","thispack:load"]
}
```
## Version Resolution
Packs can publish their versions to the `load` scoreboard objective using the [Semantic Versioning](https://semver.org/) scheme in the following manner:
- `$pack.version.major`: Major version number, incremented when breaking changes are made.
- `$pack.version.minor`: Minor version number, incremented when new features are added, reset when the major version is incremented.
- `$pack.version.patch`: Patch version number, incremented when bug fixes are applied, reset when the minor or major version is incremented.
- `$pack.version.minorpatch` = `$pack.version.minor * 1000 + $pack.version.patch`
```
# publish own pack version
scoreboard players set $pack.version.major load 1
scoreboard players set $pack.version.minor load 0
scoreboard players set $pack.version.patch load 0
```
```
# Check dependency pack version
execute if score $pack.version.major matches 1 if score $pack.version.minor matches 0.. run ...
```
At a minimum the major and minor versions should be checked in order to maintain compatibility and expected behavior.

### Avoiding the `#minecraft:tick` tag

Packs/modules should not put their tick functions in the `#minecraft:tick` tag, and should instead schedule their tick functions on load using schedule and to reschedule at the end of their tick functions.
This solves two problems:

- The vanilla `#minecraft:tick` tag runs **before** `#minecraft:load`, and as such the loading process will not be complete when the tick function runs for the first time after loading
- `#minecraft:tick` always runs all its functions every tick, with no way to disable a function apart from wrapping it in a function that checks a condition. This wastes performance when a tick function is not needed.

Using `schedule` for tick functions is also useful for version handling. It is recommended that on load the scheduled tick function(s) should be cleared, and then the version numbers of all dependencies should be compared for compatibility with the loading pack, and only if the dependencies are compatible should the tick function(s) be scheduled.
This has the effect of disabling the pack when incompatible depenedencies are loaded, or if the dependencies are not loaded at all.

Under normal circumstances, as per Semantic versioning, a module is compatible if the `major` version is equal to the expected version, and the `minor` and `patch` versions are greater than or equal to the expected version.

## License

This data pack is licensed under [CC0].

### Contribution

Unless you explicitly state otherwise, any contributions intentionally submitted
for inclusion in Load by you shall be licensed as CC0, without any additional
terms or conditions.

[AESTD]: https://github.com/Aeldrion/AESTD
[Phi]: https://github.com/MinecraftPhi/MinecraftPhi-modules
[CC0]: https://github.com/LanternMC/Load/blob/master/LICENSE
