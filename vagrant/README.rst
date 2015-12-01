Vagrant
=======

.. versionadded:: 0.6

`Vagrant <https://vagrantup.com/>`_ is used to "Create and configure
lightweight, reproducible, and portable development environments." We use it
to test Mantl locally before deploying to a cloud provider.

Our current setup creates two virtual machines, one leader and one worker. The
leader provisions both VMs using our standard Ansible setup.

Getting Started
---------------

To use Vagrant, you'll just need to create a terraform.yml file, based on
terraform.sample.yml. Then, you can just run :code:`vagrant up`.

Limitations
-----------

Mantl will likely experience stability issues with one control node. As stated
in the `Consul docs <https://www.consul.io/docs/guides/bootstrapping.html>`_,
this setup is inherently unstable.

Moreover two features of Mantl are not supported on Vagrant: GlusterFS and
Traefik. The Traefik UI will show a 403 forbidden error, because there are no
edge nodes. GlusterFS support might happen in the future, but it is an optional
feature and not a priority.
