librenms
========

Setup LibreNMS on Debian / Ubuntu.

Role Variables
--------------

```yaml
librenms_timezone: TIMEZONE
librenms_db_user: DB_USER
librenms_db_password: DB_PASSWORD
librenms_snmpd_community: SNMPD_COMMUNITY
```

Dependencies
------------

- pylabs.php
- pylabs.mariadb

Example Playbook
----------------

```yaml
- hosts: servers
  vars:
    librenms_timezone: "Asia/Taipei"
    librenms_db_user: librenms
    librenms_db_password: librenms_password
    librenms_snmpd_community: my_community_string
  roles:
     - pylabs.librenms
```

License
-------

MIT

Author Information
------------------

William Wu <william@pylabs.org>
