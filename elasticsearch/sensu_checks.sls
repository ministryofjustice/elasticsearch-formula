### Sensu check
# es-heap-used - warning 75% critical 90%
{% from "sensu/lib.sls" import sensu_check_graphite with context %}
{{ sensu_check_graphite("es-heap-used",
                        "services.elasticsearch.:::params.elasticsearch.heap_used_percent.node_name|*:::.jvm.mem.heap_used_percent",
                        "-a 600 -w ':::params.elasticsearch.heap_used_percent.warning|90:::' -c ':::params.elasticsearch.heap_used_percent.critical|95:::'",
                        "ES Heap Memory Used Percentage",
                        subscribers=['elasticsearch'],
                        occurrences=2) }}
