{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call kaia._internal.create_prod_clone(
        'kaia',
        'kaia_dev',
        'internal_dev'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}
