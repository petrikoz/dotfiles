# Firejail profile for GOG Games

# common
env TERM=xterm
noexec /tmp
private ${HOME}/games

# predefined with package
include /etc/firejail/globals.local

include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-interpreters.inc
include /etc/firejail/disable-passwdmgr.inc
include /etc/firejail/disable-programs.inc

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

