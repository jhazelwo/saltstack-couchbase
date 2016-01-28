# The Couchbase CLI
#
#
{% set cluster_host = 'localhost' %}
{% set cluster_port = '8091' %}
{% set cluster_username = 'Administrator' %}
{% set cluster_password = 'password' %}
{% set cli_path = '/opt/couchbase/bin/couchbase-cli' %}

{% macro cli(action, params='', creates=False) %}
  cmd.run:
    - name: {{ cli_path }} {{ action }} -c {{ cluster_host }}:{{ cluster_port }} {{ params }}
    - env:
      - CB_REST_PASSWORD: {{ cluster_password }}
      - CB_REST_USERNAME: {{ cluster_username }}
    {% if creates %}
    - creates: {{ creates }}
    {% endif %}
{% endmacro %}
