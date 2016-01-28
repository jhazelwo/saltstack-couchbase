# Install Couchbase
#
#
{% from "couchbase/cli.sls" import cli %}

{% set installer = 'couchbase-server-enterprise-4.0.0-centos6.x86_64.rpm' %}
{% set installer_path = '/tmp/' + installer %}
{% set installer_cmd = '/usr/bin/yum -y localinstall' %}
{% set cli_path = '/opt/couchbase/bin/couchbase-cli' %}
{% set index_path = '/opt/couchbase/nodeindex/' %}
{% set data_path = '/opt/couchbase/nodedata/' %}
{% set cluster_port = '8091' %}
{% set cluster_host = 'localhost' %}
{% set cluster_username = 'Administrator' %}
{% set cluster_password = 'password' %}
{% set cluster_ramsize = '500' %}

add_installer:
  file.managed:
    - user: root
    - group: root
    - mode: '0600'
    - name: {{ installer_path }}
    - source: salt://couchbase/{{ installer }}
    - unless: test -f {{ cli_path }}
install_couchbase:
  cmd.run:
    - name: {{ installer_cmd }} {{ installer_path }} && sleep 60
    - creates: {{ cli_path }}
    - require:
      - file: add_installer
remove_installer:
  file.absent:
    - name: {{ installer_path }}
    - onlyif: test -f {{ cli_path }}
    - require:
      - cmd: install_couchbase
couchbase_node_init:
  {% set params = '--node-init-index-path='+index_path+' --node-init-data-path='+data_path %}
  {% set creates = [ data_path , index_path ] %}
  {{ cli(action='node-init', params=params, creates=creates) }}
    - require:
      - cmd: install_couchbase
couchbase_cluster_init:
  {% set params = '--cluster-init-port='+cluster_port+' --cluster-init-username='+cluster_username+' --cluster-init-password='+cluster_password+' --cluster-ramsize='+cluster_ramsize+' && touch /opt/couchbase/etc/.cluster-init' %}
  {{ cli(action='cluster-init', params=params, creates='/opt/couchbase/etc/.cluster-init') }}
    - require:
      - cmd: install_couchbase
      - cmd: couchbase_node_init
