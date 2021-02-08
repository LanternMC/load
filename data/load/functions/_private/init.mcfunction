# Reset data storage and scoreboard objective on reload.
execute if data storage load:data _ run data remove storage load:data _
scoreboard objectives add load.status dummy
scoreboard players reset * load.status
