CREATE TABLE `syntio-onboarding-prod.mk_bronze.br_sales` (
    Cabecalho STRUCT<
        TransacaoID INT64,
        Moeda STRING,
        TransacaoTempo TIMESTAMP,
        LojaID STRING,
        Cliente STRUCT<
            ClienteID INT64,
            ClienteNome STRING,
            Localizacao STRING
        >,
        Cartao STRUCT<
            Numero STRING,
            DataDeValidade STRING
        >
    >,
    Modelo STRUCT<
        ModeloID STRING,
        Preco NUMERIC
    >
);
