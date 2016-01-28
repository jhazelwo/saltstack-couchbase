uninstall_couchbase:
  pkg.removed:
    - name: couchbase-server

delete_couchbase:
  file.absent:
    - name: /opt/couchbase
    - require:
      - pkg: uninstall_couchbase
