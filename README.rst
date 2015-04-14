=======
elasticsearch
=======

Formulas to set up and configure the elasticsearch server, and associated
housekeeping tasks via Curator.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


Dependencies
============

.. note::

   This formula has a dependency on the following salt formulas:

   `java <https://github.com/ministryofjustice/java-formula>`_

   `firewall <https://github.com/ministryofjustice/firewall-formula>`_

Available states
================

.. contents::
    :local:

``init``
----------

Install elasticsearch from the system package manager and start the service.
This has been tested only on Ubuntu 12.04.

Example usage::

    include:
      - elasticsearch

Pillar variables
~~~~~~~~~~~~~~~~

- elasticsearch:default

  A dictionary of key/value pairs to put into /etc/default/elasticsearch. For
  possible values look over docs/etc-default-elasticsearch and
  http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/setup-configuration.html

  Example::

    elasticsearch:
      default:
        ES_HEAP_SIZE: 2g
        MAX_LOCKED_MEMORY: unlimited

  (Do not treat these as recommend settings, they are just examples)

  Clustering for AWS::

    elasticsearch:
      default:
        clusterunicast: True
        clustersearch: 'elasticsearch*'

  Clustering will be done by default on local broadcast without any configuration, but broadcast doesn't work on AWS.. so to get arround that end let Salt dynamically inform the elasticsearch config to do unicast clustering, set elasticsearch.clusterunicast to True.

  elasticsearch.clustersearch provides you control over how hosts find oneanother to cluster correctly - in the default case it is set to look for hosts with names starting with elasticsearch, but could be set to role:elasticsearch or similar depending on your needs.

  Note that Clustering relies upon salt mine::

  mine_functions:
    network.ip_addrs: []
  mine_interval: 2
 
- elasticsearch:curator

  Configuration for the 'curator' housekeeping tool, specifically the 'delete'
  and 'optimize' operations, enabled via cron.

  Example::

    elasticsearch:
      curator:
        enabled: True
        delete_options: '--older-than 90'
        optimize_options: '--older-than 3 --max_num_segments 1'


warning
=======

Bear in mind that integration with graphite assumes that lowest resolution on graphite is 10s

