# Lantern Load

Lantern Load provides a simple implementation of version resolution intended to allow data packs and their dependencies to load in a controllable order.
Projects that depend on this library include [AESTD], [Gamemode 4], and [PlayerDB].

This project is released under the [BSD 0-Clause License], which in short means you can do whatever you want with these files, with nothing expected in return. You do not even have to credit us.

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

### Pack Versioning Specification

The following describes the recommended, but not mandatory, use of the `load.status` scoreboard:

> Each pack **should** define at least one fake player whose name includes the name of the pack.
> At least one of these fake players **should** have a value that **should not** be decreased in future updates to the pack.
> This score value **may** be defined to remain constant, or increment in future updates to the pack with or without a semantic meaning.

This specification is intentionally open-ended as it is not this project's goal to force a specific versioning scheme on every data pack.
Following the specification simply implies that one can detect when your pack is loaded by checking your `load.status` score.

### Avoiding the `#minecraft:tick` tag

The `#minecraft:tick` tag has several problems, the worst of which is that it runs *before* `#minecraft:load`, meaning that your pack may be ticked without first being initialized.
Lantern Load is meant to allow every pack to initialize itself in a predictable order within the same tick, including on reload, and `#minecraft:tick` interferes with this design goal.
The recommended solution is to instead invoke `schedule` from a function defined in `#load:load`.

```mcfunction
# your_pack:load
scoreboard players set your_pack load.status 1
schedule function your_pack:tick 1t

# your_pack:tick
say this is a tick!
schedule function your_pack:tick 1t
```

### Checking for dependencies

In your load function, you may wish to check the value of another pack's score in `load.status` before initializing scoreboards or scheduling your tick function.
Doing so is a useful way to handle missing dependencies and reduce the risk of your data pack causing errors.

```mcfunction
# your_pack:load
schedule clear your_pack:tick
execute if score other_pack load.status matches 1 run scoreboard players set your_pack load.status 1
execute if score your_pack load.status matches 1 run function your_pack:init

# your_pack:init
scoreboard objectives add your_objective dummy
schedule function your_pack:tick 1t

# your_pack:tick
scoreboard players add your_score your_objective 1
schedule function your_pack:tick 1t
```

## License

Lantern Load is made freely available under the terms of the [BSD 0-Clause License].
Third-party contributions shall be licensed under the same terms unless explicitly stated otherwise.

[AESTD]: https://github.com/Aeldrion/AESTD
[Gamemode 4]: https://github.com/Gamemode4Dev/GM4_Datapacks
[PlayerDB]: https://github.com/rx-modules/PlayerDB
[BSD 0-Clause License]: LICENSE
