include:
  - java
{% set es_file='elasticsearch-0.90.10.deb' %}

/usr/src/packages/{{es_file}}:
  file:
    - managed
    - source: http://static.dsd.io/packages/{{es_file}}
    - source_hash: sha1=0a0aff6a793a057edbe549c646d9d9ad7738f7cb
    - mode: 644
    - require:
      - file: /usr/src/packages


/etc/elasticsearch/elasticsearch.yml:
  file:
    - managed
    - source: salt://elasticsearch/templates/elasticsearch.yml


elasticsearch:
  pkg:
    - installed
    - sources:
      - elasticsearch: /usr/src/packages/{{es_file}}
  service:
    - running
    - enable: True
    - watch:
      - pkg: elasticsearch
      - file: /etc/elasticsearch/elasticsearch.yml


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('elasticsearch-http',9200,proto='tcp') }}
{{ firewall_enable('elasticsearch-tcp',9300,proto='tcp') }}
