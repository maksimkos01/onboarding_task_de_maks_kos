WITH source AS (
    SELECT 
        StoreID AS store_id,
        Inventory 
    FROM {{ source('bronze_layer', 'stores') }}
)

SELECT
    store_id,
    inv.ModelID AS product_model_id,
    inv.Quantity AS stock_quantity,
    inv.ReportDate AS inventory_reported_at,
    inv.ReportingWarehouseID AS warehouse_id
FROM source,
UNNEST(Inventory) AS inv
