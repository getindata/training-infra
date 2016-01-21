Role Name
=========

Enable EPEL on EL based systems.

Requirements
------------

No external dependencies.

Role Variables
--------------

- **yum_repos_d**: Location of *yum* repository directory where
  repositories are defined.  Defaults to `/etc/yum.repos.d`.

Dependencies
------------

None.

Example Playbook
----------------

Very simple to use:

    - hosts: servers
      roles:
         - { role: sfromm.epel }

License
-------

BSD

Author Information
------------------

See https://github.com/sfromm
