# Manage Couchabse buckets
#
#
include:
  - couchbase.install

{% from "couchbase/cli.sls" import cli %}

{% set nodename = grains['id'] %}

{# Create/Detele buckets based on node's pillar data#}
{% for bucket in pillar['couchbase'][nodename]['buckets'] %}

{# Shortcut var, used to define the name space in a pillar.get() call #}
{% set namespace = 'couchbase:'+nodename+':buckets:'+bucket+':' %}

{% set ensure = salt['pillar.get'](namespace+'ensure', 'present') %}

{% if ensure == 'absent' %}

delete_bucket_{{ bucket }}:
  {% set onlyif = 'bucket-edit --bucket='+bucket %}
  {{ cli(action='bucket-delete', params='--bucket='+bucket, onlyif=onlyif) }}

{% else %}
# Create bucket:

{% set password = salt['pillar.get'](namespace+'password', '') %}
# Bucket password is optional
{% if password %}
  {% set password = ' --bucket-password='+password %}
{% endif %}

{% set flush = ' --enable-flush='~salt['pillar.get'](namespace+'flush', '0') %}
{% set replica = ' --bucket-replica='~salt['pillar.get'](namespace+'replica', '0') %}
{% set enable_index_replica = ' --enable-index-replica='~salt['pillar.get'](namespace+'enable-index-replica', '0') %}
{% set ramsize = ' --bucket-ramsize='~salt['pillar.get'](namespace+'ramsize', '100') %}
{% set port = ' --bucket-port='~salt['pillar.get'](namespace+'port', '11211') %}
{% set type = ' --bucket-type='+salt['pillar.get'](namespace+'type', 'couchbase') %}

{% set params = password+flush+replica+enable_index_replica+ramsize+port+type+' --wait' %}

create_bucket_{{ bucket }}:
  {% set unless = 'bucket-edit --bucket='+bucket %}
  {{ cli(action='bucket-create', params='--bucket='+bucket+params, unless=unless) }}

{% endif %}
{% endfor %}
