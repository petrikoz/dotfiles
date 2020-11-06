# Firejail profile for GOG Games

# common
env TERM=xterm
private ${HOME}/games

# predefined with package
include globals.local

include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc

caps.drop all
ipc-namespace
net none
nodbus
nodvd
nogroups
nonewprivs
noroot
notv
nou2f
seccomp
shell none

disable-mnt
private-cache
private-dev
private-tmp

