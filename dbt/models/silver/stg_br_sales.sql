
WITH source AS (
    SELECT * FROM {{ source('bronze_layer', 'br_sales') }}
)

SELECT
    Cabecalho.TransacaoID AS transaction_id,
    Cabecalho.Moeda AS currency_code,
    Cabecalho.TransacaoTempo AS transaction_at,
    Cabecalho.LojaID AS store_id,
    Cabecalho.Cliente.ClienteID AS customer_id,
    Cabecalho.Cliente.ClienteNome AS customer_name,
    Cabecalho.Cliente.Localizacao AS customer_location,
    Cabecalho.Cartao.Numero AS card_number,
    Cabecalho.Cartao.DataDeValidade AS card_expiry_date,
    Modelo.ModeloID AS product_model_id,
    Modelo.Preco AS unit_price
FROM source
