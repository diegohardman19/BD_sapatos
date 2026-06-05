
--  BANCO - Loja de Sapatos



USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'db_sapatos_producao')
BEGIN
    ALTER DATABASE db_sapatos_producao SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE db_sapatos_producao;
END
GO

CREATE DATABASE db_sapatos_producao;
GO

USE db_sapatos_producao;
GO

-- TABELA DE CLIENTES
CREATE TABLE clientes (
    id        INT IDENTITY(1,1) PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    telefone  VARCHAR(20),
    email     VARCHAR(100),
    cidade    VARCHAR(80),
    estado    CHAR(2),
    criado_em DATETIME DEFAULT GETDATE()
);

-- TABELA DE CATEGORIAS
CREATE TABLE categorias (
    id   INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(80) NOT NULL
);

-- TABELA DE PRODUTOS (sapatos)
CREATE TABLE produtos (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    nome         VARCHAR(150) NOT NULL,
    marca        VARCHAR(80),
    categoria_id INT,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- TABELA DE VENDEDORES
CREATE TABLE vendedores (
    id        INT IDENTITY(1,1) PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    criado_em DATETIME DEFAULT GETDATE()
);

-- TABELA DE VENDAS
CREATE TABLE vendas (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id   INT,
    vendedor_id  INT,
    data_venda   DATETIME DEFAULT GETDATE(),
    valor_total  DECIMAL(10,2),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id)
);

-- TABELA DE ITENS DA VENDA
CREATE TABLE itens_venda (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    venda_id       INT,
    produto_id     INT,
    quantidade     INT,
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (venda_id)   REFERENCES vendas(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);
GO

-- ============================================================
--  DADOS DE EXEMPLO
-- ============================================================

INSERT INTO clientes (nome, telefone, email, cidade, estado) VALUES
('Ana Lima',       '83991112233', 'ana@email.com',     'Joao Pessoa', 'PB'),
('Bruno Melo',     '83988887766', 'bruno@email.com',   'Joao Pessoa', 'PB'),
('Carla Souza',    '81977776655', 'carla@email.com',   'Recife',      'PE'),
('Diego Ferreira', '85966665544', 'diego@email.com',   'Fortaleza',   'CE'),
('Elena Costa',    '83955554433', 'elena@email.com',   'Campina Grande','PB');

INSERT INTO categorias (nome) VALUES
('Tenis'),
('Social'),
('Sandalia'),
('Bota'),
('Chinelo');

INSERT INTO produtos (nome, marca, categoria_id, preco, estoque) VALUES
('Tenis Air Max',        'Nike',     1, 599.90, 30),
('Tenis Forum Low',      'Adidas',   1, 459.90, 25),
('Sapato Social Preto',  'Democrata',2, 289.90, 20),
('Sapato Social Marrom', 'Democrata',2, 309.90, 15),
('Sandalia Rasteira',    'Havaianas',3,  89.90, 50),
('Sandalia Salto Alto',  'Arezzo',   3, 349.90, 18),
('Bota Couro Preta',     'Via Marte',4, 499.90, 12),
('Bota Cano Curto',      'Via Marte',4, 379.90, 10),
('Chinelo Slide',        'Nike',     5,  99.90, 60),
('Tenis Casual Branco',  'Vans',     1, 399.90, 22);

INSERT INTO vendedores (nome, email) VALUES
('Marcos Leal',  'marcos@sapatos.com'),
('Julia Neves',  'julia@sapatos.com'),
('Pedro Alves',  'pedro@sapatos.com');

INSERT INTO vendas (cliente_id, vendedor_id, data_venda, valor_total) VALUES
(1, 1, '2025-01-10 10:00', 599.90),
(2, 2, '2025-01-15 14:30', 749.80),
(3, 1, '2025-02-03 09:00', 289.90),
(4, 3, '2025-02-20 16:00', 849.80),
(5, 2, '2025-03-05 11:00', 179.80),
(1, 3, '2025-03-18 13:00', 499.90),
(2, 1, '2025-04-02 10:30', 459.90),
(3, 2, '2025-04-22 15:00', 699.80);

INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 599.90),
(2, 2, 1, 459.90),
(2, 9, 1,  99.90),
(3, 3, 1, 289.90),
(4, 1, 1, 599.90),
(4, 5, 1,  89.90),
(4, 9, 1,  99.90),
(5, 5, 1,  89.90),
(5, 9, 1,  99.90),
(6, 7, 1, 499.90),
(7, 2, 1, 459.90),
(8, 6, 1, 349.90),
(8, 4, 1, 309.90);
GO
