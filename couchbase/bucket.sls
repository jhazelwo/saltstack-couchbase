#
#
#
include:
  - couchbase.install

{% from "couchbase/cli.sls" import cli %}

list_buckets:
  {{ cli(action='bucket-list') }}
  - require:
    - cmd: install_couchbase
