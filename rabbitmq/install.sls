{% from "rabbitmq/package-map.jinja" import pkgs with context %}

{% set module_list = salt['sys.list_modules']() %}
{% if 'rabbitmqadmin' in module_list %}
include:
  - .config_bindings
  - .config_queue
  - .config_exchange
{% endif %}

erlang-packages:
  pkg.installed:
    - pkgs:
      - erlang-base: 1:23.3.1-1
      - erlang-asn1: 1:23.3.1-1
      - erlang-crypto: 1:23.3.1-1
      - erlang-eldap: 1:23.3.1-1
      - erlang-ftp: 1:23.3.1-1
      - erlang-inets: 1:23.3.1-1
      - erlang-mnesia: 1:23.3.1-1
      - erlang-os-mon: 1:23.3.1-1
      - erlang-parsetools: 1:23.3.1-1
      - erlang-public-key: 1:23.3.1-1
      - erlang-runtime-tools: 1:23.3.1-1
      - erlang-snmp: 1:23.3.1-1
      - erlang-ssl: 1:23.3.1-1
      - erlang-syntax-tools: 1:23.3.1-1
      - erlang-tftp: 1:23.3.1-1
      - erlang-tools: 1:23.3.1-1
      - erlang-xmerl: 1:23.3.1-1
    - require:
      - pkgrepo: erlang_repo

rabbitmq-server:
  pkg.installed:
    - name: {{ pkgs['rabbitmq-server'] }}
    {%- if 'version' in salt['pillar.get']('rabbitmq', {}) %}
    - version: {{ salt['pillar.get']('rabbitmq:version') }}
    {%- endif %}
    - require:
      - pkg: erlang-packages

  service:
    - {{ "running" if salt['pillar.get']('rabbitmq:running', True) else "dead" }}
    - enable: {{ salt['pillar.get']('rabbitmq:enabled', True) }}
    - watch:
      - pkg: rabbitmq-server

rabbitmq_binary_tool_env:
  file.symlink:
    - makedirs: True
    - name: /usr/local/bin/rabbitmq-env
    - target: /usr/lib/rabbitmq/bin/rabbitmq-env
    - require:
      - pkg: rabbitmq-server

rabbitmq_binary_tool_plugins:
  file.symlink:
    - makedirs: True
    - name: /usr/local/bin/rabbitmq-plugins
    - target: /usr/lib/rabbitmq/bin/rabbitmq-plugins
    - require:
      - pkg: rabbitmq-server
      - file: rabbitmq_binary_tool_env

