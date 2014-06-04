{% from "elasticsearch/map.jinja" import elasticsearch with context %}
include:
  - java
{% set es_file='elasticsearch-0.90.10.deb' %}


/usr/src/packages/{{elasticsearch.source.file}}:
  file.managed:
    - source: {{elasticsearch.source.path}}/{{elasticsearch.source.file}}
    - source_hash: {{elasticsearch.source.hash}}
    - mode: 644
    - require:
      - file: /usr/src/packages

/etc/elasticsearch:
  file.directory:
    - mode: 700
    - owner: elasticsearch
    - require:
      - pkg: elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.yml
    - template: jinja
    - require:
      - file: /etc/elasticsearch


elasticsearch:
  pkg.installed:
    - sources:
      - elasticsearch: /usr/src/packages/{{elasticsearch.source.file}}
  service.running:
    - enable: True
    - watch:
      - pkg: elasticsearch
      - file: /etc/elasticsearch/elasticsearch.yml


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('elasticsearch-http',9200,proto='tcp') }}
{{ firewall_enable('elasticsearch-tcp',9300,proto='tcp') }}
