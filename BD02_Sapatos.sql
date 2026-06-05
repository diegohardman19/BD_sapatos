
--  BANCO  - Loja de Sapatos




USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'db_sapatos_dw')
BEGIN
    ALTER DATABASE db_sapatos_dw SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE db_sapatos_dw;
END
GO

CREATE DATABASE db_sapatos_dw;
GO

USE db_sapatos_dw;
GO


--  DIMENSAO TEMPO

CREATE VIEW dim_tempo AS
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), CAST(data_venda AS DATE), 112) AS INT) AS sk_tempo,
    CAST(data_venda AS DATE)                                         AS data_completa,
    DAY(data_venda)                                                  AS dia,
    MONTH(data_venda)                                                AS mes,
    YEAR(data_venda)                                                 AS ano,
    DATEPART(QUARTER, data_venda)                                    AS trimestre,

    CASE MONTH(data_venda)
        WHEN 1  THEN 'Janeiro'    WHEN 2  THEN 'Fevereiro'
        WHEN 3  THEN 'Marco'      WHEN 4  THEN 'Abril'
        WHEN 5  THEN 'Maio'       WHEN 6  THEN 'Junho'
        WHEN 7  THEN 'Julho'      WHEN 8  THEN 'Agosto'
        WHEN 9  THEN 'Setembro'   WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'   WHEN 12 THEN 'Dezembro'
    END AS nome_mes

FROM db_sapatos_producao.dbo.vendas;
GO


--  DIMENSAO CLIENTE

CREATE VIEW dim_cliente AS
SELECT
    id     AS sk_cliente,
    nome   AS nome_cliente,
    cidade,
    estado
FROM db_sapatos_producao.dbo.clientes;
GO


--  DIMENSAO PRODUTO

CREATE VIEW dim_produto AS
SELECT
    p.id           AS sk_produto,
    p.nome         AS nome_produto,
    p.marca,
    p.preco,
    p.estoque,
    c.id           AS sk_categoria,
    c.nome         AS nome_categoria
FROM db_sapatos_producao.dbo.produtos p
JOIN db_sapatos_producao.dbo.categorias c ON c.id = p.categoria_id;
GO


--  DIMENSAO VENDEDOR

CREATE VIEW dim_vendedor AS
SELECT
    id   AS sk_vendedor,
    nome AS nome_vendedor,
    email
FROM db_sapatos_producao.dbo.vendedores;
GO


--  FATO VENDAS
--  JOIN para ligar itens, vendas, clientes e vendedores

CREATE VIEW fato_vendas AS
SELECT
    iv.id                                                              AS sk_fato,
    CAST(CONVERT(VARCHAR(8), CAST(v.data_venda AS DATE), 112) AS INT) AS fk_tempo,
    v.cliente_id                                                       AS fk_cliente,
    v.vendedor_id                                                      AS fk_vendedor,
    iv.produto_id                                                      AS fk_produto,
    v.id                                                               AS id_venda,
    iv.quantidade,
    iv.preco_unitario,
    iv.quantidade * iv.preco_unitario                                  AS total_item

FROM db_sapatos_producao.dbo.itens_venda iv
JOIN db_sapatos_producao.dbo.vendas       v ON v.id = iv.venda_id;
GO

--  TABELA DE LOG (usada pela trigger)

CREATE TABLE log_produtos_deletados (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    produto_id  INT,
    nome        VARCHAR(150),
    preco       DECIMAL(10,2),
    deletado_em DATETIME DEFAULT GETDATE()
);
GO


--  TRIGGER - Remove do banco de producao e registra no log

USE db_sapatos_producao;
GO

IF OBJECT_ID('trg_log_produto_deletado', 'TR') IS NOT NULL
    DROP TRIGGER trg_log_produto_deletado;
GO

CREATE TRIGGER trg_log_produto_deletado
ON produtos
AFTER DELETE
AS
BEGIN
    INSERT INTO db_sapatos_dw.dbo.log_produtos_deletados (produto_id, nome, preco)
    SELECT id, nome, preco
    FROM deleted;
END;
GO


--  CONSULTAS DE VALIDACAO


USE db_sapatos_dw;
GO

PRINT '--- DIMENSAO TEMPO ---';
SELECT * FROM dim_tempo;
GO

PRINT '--- DIMENSAO PRODUTO ---';
SELECT * FROM dim_produto;
GO

PRINT '--- FATO VENDAS ---';
SELECT * FROM fato_vendas;
GO

PRINT '--- RECEITA POR CATEGORIA ---';
SELECT
    p.nome_categoria,
    SUM(f.total_item) AS receita_total,
    SUM(f.quantidade) AS unidades_vendidas
FROM fato_vendas f
JOIN dim_produto p ON p.sk_produto = f.fk_produto
GROUP BY p.nome_categoria
ORDER BY receita_total DESC;
GO

PRINT '--- RECEITA POR VENDEDOR ---';
SELECT
    v.nome_vendedor,
    SUM(f.total_item) AS receita_total
FROM fato_vendas f
JOIN dim_vendedor v ON v.sk_vendedor = f.fk_vendedor
GROUP BY v.nome_vendedor
ORDER BY receita_total DESC;
GO

PRINT '--- RECEITA POR MES ---';
SELECT
    t.nome_mes,
    t.ano,
    SUM(f.total_item) AS receita_total
FROM fato_vendas f
JOIN dim_tempo t ON t.sk_tempo = f.fk_tempo
GROUP BY t.nome_mes, t.ano, t.mes
ORDER BY t.ano, t.mes;
GO


--  TESTE DA TRIGGER

PRINT '--- TESTE TRIGGER: deletar produto ---';

USE db_sapatos_producao;
GO

INSERT INTO produtos (nome, marca, categoria_id, preco, estoque)
VALUES ('Produto Teste Delete', 'Marca Teste', 1, 1.00, 1);
GO

DELETE FROM produtos WHERE nome = 'Produto Teste Delete';
GO

USE db_sapatos_dw;
GO

SELECT * FROM log_produtos_deletados;
GO
