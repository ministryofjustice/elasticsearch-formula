=======
elasticsearch
=======

Formulas to set up and configure the elasticsearch server.

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

warning
=======

Bear in mind that integration with graphite assumes that lowest resolution on graphite is 10s

