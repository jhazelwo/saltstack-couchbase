# The Couchbase CLI
#
#
{% set my_pillar = pillar['couchbase'][grains['id']] %}

{% set cluster_port = my_pillar['cluster']['port'] %}
{% set cluster_host = my_pillar['cluster']['host'] %}
{% set cluster_username = my_pillar['cluster']['username'] %}
{% set cluster_password = my_pillar['cluster']['password'] %}

{% if grains['kernel'] == 'Windows' %}
  {% set cli_path = '/program files/couchbase/bin/couchbase-cli' %}
{% else %}
  {% set cli_path = '/opt/couchbase/bin/couchbase-cli' %}
{% endif %}

{% macro cli(action, params='', onlyif=False, unless=False) %}
  cmd.run:
    - name: {{ cli_path }} {{ action }} -c {{ cluster_host }}:{{ cluster_port }} {{ params }}
    {% if onlyif %}
    - onlyif: {{ cli_path }} {{ onlyif }} -c {{ cluster_host }}:{{ cluster_port }}
    {% endif %}
    {% if unless %}
    - unless: {{ cli_path }} {{ unless }} -c {{ cluster_host }}:{{ cluster_port }}
    {% endif %}
    - env:
      - CB_REST_PASSWORD: {{ cluster_password }}
      - CB_REST_USERNAME: {{ cluster_username }}
{% endmacro %}
