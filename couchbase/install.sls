# Install Couchbase
#
#
{% from "couchbase/cli.sls" import cli %}

{% set my_pillar = pillar['couchbase'][grains['id']] %}

{% set installer = my_pillar['installer'] %}
{% set installer_path = my_pillar['installer_tmp'] + installer %}

{% set index_path = my_pillar['index_path'] %}
{% set data_path = my_pillar['data_path'] %}

{% set cluster_port = my_pillar['cluster']['port'] %}
{% set cluster_host = my_pillar['cluster']['host'] %}
{% set cluster_username = my_pillar['cluster']['username'] %}
{% set cluster_password = my_pillar['cluster']['password'] %}
{% set cluster_ramsize = my_pillar['cluster']['ramsize'] %}

copy_installer_file_to_host:
  file.managed:
    - user: root
    - group: root
    - mode: '0600'
    - name: {{ installer_path }}
    - source: salt://couchbase/{{ installer }}
    - unless: test -f /opt/couchbase/bin/couchbase-cli
install_couchbase:
  cmd.run:
    {% if grains['kernel'] == 'Windows' %}
    - name: {{ installer_path }} /s -f1{{ iss_file }} /debuglog
    {% elif grains['os_family'] == 'RedHat' %}
    - name: /usr/bin/yum -y localinstall {{ installer_path }}
    {% elif grains['os_family'] == 'Debian' %}
    - name: /usr/bin/dpkg -y --install {{ installer_path }}
    {% else %}
    - name: fail_here_unknown_operating_system
    {% endif %}
    - creates: /opt/couchbase/bin/couchbase-cli
    - require:
      - file: copy_installer_file_to_host
wait_for_cb_to_start_listening_for_connections:
# ...will only run if installer was executed
  cmd.wait:
    {% if grains['kernel'] == 'Windows' %}
    - name: timeout 30
    {% else %}
    - name: sleep 30
    {% endif %}
    - watch:
      - cmd: install_couchbase
couchbase_node_init:
  {% set params = '--node-init-index-path='+index_path+' --node-init-data-path='+data_path %}
  {{ cli(action='node-init', params=params) }}
    - require:
      - cmd: wait_for_cb_to_start_listening_for_connections
    - creates: [ {{ data_path }} , {{ index_path }} ]
couchbase_cluster_init:
  {% set params = '--cluster-init-port='~cluster_port~' --cluster-init-username='+cluster_username+' --cluster-init-password='+cluster_password+' --cluster-ramsize='~cluster_ramsize %}
  {{ cli(action='cluster-init', params=params) }}
    - require:
      - cmd: couchbase_node_init
    - creates: '/opt/couchbase/etc/.cluster-init'
couchbase_cluster_init_statefile:
  file.managed:
    - name: /opt/couchbase/etc/.cluster-init
    - require:
      - cmd: couchbase_cluster_init
remove_installer:
  file.absent:
    - name: {{ installer_path }}
    - require:
      - file: couchbase_cluster_init_statefile
