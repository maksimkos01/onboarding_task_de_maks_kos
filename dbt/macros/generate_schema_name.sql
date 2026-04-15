{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {# If a custom dataset is defined in dbt_project.yml, use it exactly #}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}

    {# Otherwise, use the default from profiles.yml (mk_silver) #}
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}
{%- endmacro %}
