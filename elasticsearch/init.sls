{% from "elasticsearch/map.jinja" import elasticsearch with context %}
include:
  - java
  - python
{% if salt['pillar.get']('monitoring:enabled', True) %}
  - sensu.client
{% endif %}


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


### Sensu check

# es-heap-used - warning 75% critical 90%
{% from "sensu/lib.sls" import sensu_check_graphite with context %}
{{ sensu_check_graphite("es-heap-used",
                        "'services.elasticsearch.*.jvm.mem.heap_used_percent'",
                        "-a 600 -w 75 -c 90",
                        "ES Heap Memory Used Percentage",
                        occurrences=2) }}


{% endif %}


elasticsearch-curator:
  pip.installed:
    - require:
      - pkg: python-pip

{% if elasticsearch.curator.enabled %}
curator-cron:
  cron.present:
    - name: "/usr/local/bin/curator {{elasticsearch.curator.options}} 2> /var/log/elasticsearch/curator.err > /var/log/elasticsearch/curator.out"
    - identifier: elasticsearch-curator-cron
    - user: elasticsearch
    - hour: '3'
    - minute: random
    - require:
      - pkg: elasticsearch
{% endif %}
