# State files to logically link pillar values with values of settings in Couchbase
#
{% macro statefile(name, contents='#', ensure='managed') %}
  {% if grains['kernel'] == 'Windows' %}
    {% set cb_conf_dir = 'C:/Program Files/Couchbase/Server/etc/' %}
  {% else %}
    {% set cb_conf_dir = '/opt/couchbase/etc/' %}
  {% endif %}
  file.{{ ensure }}:
    - name: {{ cb_conf_dir }}.{{ name }}
    {% if ensure == 'managed' %}
    - mode: '0600'
    - contents: {{ contents }}
    {% endif %}
{% endmacro %}
