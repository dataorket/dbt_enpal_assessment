{% macro test_failure_message(test_name, details) %}
    '{{ test_name }} failed: {{ details }}'
{% endmacro %}
