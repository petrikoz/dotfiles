# Firejail profile run games with wine

env DXVK_HUD=fps
env DXVK_LOG_LEVEL=none
env LANG=ru_RU.utf8
env WINEDEBUG=-all
env WINEESYNC=1

net none

private ${HOME}/games

# Redirect
include wine.profile
