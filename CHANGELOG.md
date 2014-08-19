## Version 1.1.0

* Default installation package now 1.3.1 (was 0.90 - state.highstate will not force upgrade)
* vm.max_map_count = 262144 to work with new 1.x storage
* build /etc/default/elasticsearch from pillar (i.e. to change used heap)

## Version 1.0.4

* Disable dynamic scripting - we don't use it and it is insecure

## Version 1.0.3

* Fix permissions of config files under /etc/elasticsearch
* Fix ordering of states so we set the perms before trying to start the service.

## Version 1.0.2

* Ensure /etc/elasticsearch is a dependency of the various config files

