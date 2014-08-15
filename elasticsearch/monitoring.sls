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


### Sensu check

# es-heap-used - warning 75% critical 90%
{% from "sensu/lib.sls" import sensu_check_graphite with context %}
{{ sensu_check_graphite("es-heap-used",
                        "'es.elasticsearch.valkyrie.jvm.mem.heap_used_percent'",
                        "-a 600 -w 75 -c 90",
                        "ES Heap Memory Used Percentage",
                        occurrences=2) }}


{% endif %}
