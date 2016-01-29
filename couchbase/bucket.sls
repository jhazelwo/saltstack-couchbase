# Manage Couchabse buckets
#
#
include:
  - couchbase.install

# Get the cli() macro
{% from "couchbase/cli.sls" import cli %}

# Get the statefile() macro
{% from "couchbase/statefile.sls" import statefile %}

# Make less-ugly hostname var
{% set nodename = grains['id'] %}

{# Create/Detele buckets based on node's pillar data#}
{% for bucket in pillar['couchbase'][nodename]['buckets'] %}

{# Shortcut var, used to define the name space in a pillar.get() call #}
{% set namespace = 'couchbase:'+nodename+':buckets:'+bucket+':' %}

# ensure = (absent|present)
{% set ensure = salt['pillar.get'](namespace+'ensure', 'present') %}

{% if ensure == 'absent' %}
# Delete this bucket (if it exists).
delete_bucket_{{ bucket }}:
  {% set onlyif = 'bucket-edit --bucket='+bucket %}
  {{ cli(action='bucket-delete', params='--bucket='+bucket, onlyif=onlyif) }}
    - require:
      - file: couchbase_install_completed
  # And remove the bucket's state file.
  {{ statefile(name=bucket, ensure='absent') }}
{% else %}
# Otherwise create the bucket (if it does not already exist).

# Bucket password is optional
{% set password = salt['pillar.get'](namespace+'password', '') %}
{% if password %}
  {% set password = ' --bucket-password='+password %}
{% endif %}

# Sorry for the mess
{% set flush = ' --enable-flush='~salt['pillar.get'](namespace+'flush', '0') %}
{% set replica = ' --bucket-replica='~salt['pillar.get'](namespace+'replica', '0') %}
{% set enable_index_replica = ' --enable-index-replica='~salt['pillar.get'](namespace+'enable-index-replica', '0') %}
{% set ramsize = ' --bucket-ramsize='~salt['pillar.get'](namespace+'ramsize', '100') %}
{% set port = ' --bucket-port='~salt['pillar.get'](namespace+'port', '11211') %}
{% set type = ' --bucket-type='+salt['pillar.get'](namespace+'type', 'couchbase') %}

{% set params = password+flush+replica+enable_index_replica+ramsize+port+type+' --wait' %}
statefile_for_bucket_{{ bucket }}:
  {{ statefile(name=bucket, contents=params) }}
    - watch_in:
      - cmd: create_bucket_{{ bucket }}

create_bucket_{{ bucket }}:
  {% set unless = 'bucket-edit --bucket='+bucket %}
  {{ cli(action='bucket-create', params='--bucket='+bucket+params, unless=unless) }}
    - require:
      - file: couchbase_install_completed

{% endif %} # ensure = present

{% endfor %} # for bucket in buckets

# TODO: remove
list_buckets:
  {{ cli(action='bucket-list') }}
