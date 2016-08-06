Certificates
============

.. versionadded:: 1.2

This role generates TLS certificates for each node. In the future, we'd like
to integrate this role more closely with Vault, and allow automated periodic
recreation of certificates.

Caution: This will distribute your CA private key to all nodes. This isn't a
security risk if you're using self-signed certificates.  If you use a real CA,
you'll want to generate certificates and distribute them manually instead.

See ``roles/certificates/defaults/main.yml`` for more information on the
variables you can use to customize this role.
