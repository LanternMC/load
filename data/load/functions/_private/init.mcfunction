# Reset scoreboard fake players and data storage on reload.
execute if data storage load:data CurrentReload run data remove storage load:data CurrentReload
scoreboard objectives add load.status dummy
scoreboard players reset * load.status
