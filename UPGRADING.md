## From 1.6 to CURRENT

The 'elasticsearch.curator.options' pillar has now been turned into two specific options:

* 'elasticsearch.curator.delete_options'
* 'elasticsearch.curator.optimize_options'

By default, deletion will not occur, as this is not safe outside of our typical ELK stack usage.

Optimize is set by default to compact the segments of each index over 3 days, as this is safe and
saves a considerable amount of memory for ELK stacks.

## From 1.4 to 1.5

Sensu checks are not automatically deployed to the elasticsearch node.

You will need to add 'elasticsearch.sensu_checks' via top.sls to your Sensu server role (
usually monitoring.server).

You will also need to add the 'elasticsearch' role to any node that requires this check.

If you have more than one elasticsearch node in your environment, you will need to somehow
set 'params.elasticsearch.heap_used_percent.node_name'. See sensu-formula for how to do this.


