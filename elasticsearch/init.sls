{% from "elasticsearch/map.jinja" import elasticsearch with context %}
include:
  - firewall
  - bootstrap
  - java
  - python

/usr/src/packages/{{elasticsearch.source.file}}:
  file.managed:
    - source: {{elasticsearch.source.path}}/{{elasticsearch.source.file}}
    - source_hash: {{elasticsearch.source.hash}}
    - mode: 644
    - require:
      - file: /usr/src/packages

/etc/elasticsearch:
  file.directory:
    - mode: 750
    - owner: root
    - group: elasticsearch
    - require:
      - pkg: elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.yml
    - template: jinja
    - mode: 640
    - owner: root
    - group: elasticsearch
    - require:
      - file: /etc/elasticsearch


/etc/default/elasticsearch:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch
    - template: jinja
    - mode: 640
    - owner: root
    - group: root


elasticsearch:
  pkg.installed:
    - sources:
      - elasticsearch: /usr/src/packages/{{elasticsearch.source.file}}
  service.running:
    - enable: True
    - watch:
      - pkg: elasticsearch
      - file: /etc/elasticsearch/elasticsearch.yml
      - file: /etc/default/elasticsearch

elasticsearch-data-dir:
  file.directory:
    - name: {{elasticsearch.data_path}}
    - owner: elasticsearch
    - group: elasticsearch
    - mode: 0755
    - require:
      - pkg: elasticsearch

#as recommended by
#http://www.elasticsearch.org/guide/en/elasticsearch/reference/1.x/setup-configuration.html#setup-configuration
vm.max_map_count:
  sysctl.present:
    - value: 262144


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('elasticsearch-http',9200,proto='tcp') }}
{{ firewall_enable('elasticsearch-tcp',9300,proto='tcp') }}

{% if salt['pillar.get']('monitoring:enabled', True) %}

/usr/local/bin/es2graphite.py:
  file.managed:
    - source: salt://elasticsearch/files/es2graphite.py
    - mode: 755


/etc/init/es2graphite.conf:
  file.managed:
    - source: salt://elasticsearch/files/es2graphite.conf
    - user: root
    - group: root
    - mode: 644


es2graphite:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init/es2graphite.conf
      - file: /usr/local/bin/es2graphite.py
      - service: elasticsearch

{% endif %}


elasticsearch-curator:
  pip.installed:
    - require:
      - pkg: python-pip

# Legacy, remove
curator-cron:
  cron.absent:
    - identifier: elasticsearch-curator-cron
    - user: elasticsearch

{% if elasticsearch.curator.enabled %}
curator-delete-cron:
{%   if elasticsearch.curator.delete_options %}
  cron.present:
    - name: "/usr/local/bin/curator delete {{elasticsearch.curator.delete_options}} 2>&1 | logger -t curator-delete"
    - identifier: elasticsearch-curator-delete
    - user: elasticsearch
    - hour: '3'
    - minute: random
    - require:
      - pkg: elasticsearch
{%   else %}
  cron.absent:
    - identifier: elasticsearch-curator-cron
    - user: elasticsearch
{%   endif %}
curator-optimize-cron:
{%   if elasticsearch.curator.optimize_options %}
  cron.present:
    - name: "/usr/local/bin/curator optimize {{elasticsearch.curator.optimize_options}} 2>&1 | logger -t curator-optimize"
    - identifier: elasticsearch-curator-optimize
    - user: elasticsearch
    - hour: '4'
    - minute: random
    - require:
      - pkg: elasticsearch
{%   else %}
  cron.absent:
    - identifier: elasticsearch-curator-optimize
    - user: elasticsearch
{%   endif %}
{% endif %}
