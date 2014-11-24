## From 1.4 to CURRENT

Sensu checks are not automatically deployed to the elasticsearch node.

You will need to add 'elasticsearch.sensu_checks' via top.sls to your Sensu server role (
usually monitoring.server).

You will also need to add the 'elasticsearch' role to any node that requires this check.

If you have more than one elasticsearch node in your environment, you will need to somehow
set 'params.elasticsearch.heap_used_percent.node_name'. See sensu-formula for how to do this.


