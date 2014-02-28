=======
elasticsearch
=======

Formulas to set up and configure the elasticsearch server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


.. dependencies::

   This formula has a dependency on the following salt formulas –
   `java <https://github.com/ministryofjustice/java-formula>`_.
   `firewall <https://github.com/ministryofjustice/firewall-formula>`_.

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
