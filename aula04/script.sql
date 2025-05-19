CREATE DATABASE aula04m;
USE aula04m;

CREATE TABLE clientes (
id INT AUTO_INCREMENT,
nome VARCHAR(100),
email VARCHAR(100),
PRIMARY KEY(id)
);

CREATE TABLE pedidos (
id INT AUTO_INCREMENT,
cliente_id INT,
valor DECIMAL(10,2),
data_pedido DATE,
PRIMARY KEY (id),
FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE log_pedidos (
id INT AUTO_INCREMENT,
mensagem TEXT,
data_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY(id)
);

INSERT INTO clientes (nome, email) VALUES
('João Silva', 'joao@email.com'),
('Maria Souza', 'maria@email.com');
-- Inserindo pedidos
INSERT INTO pedidos (cliente_id, valor, data_pedido) VALUES
(1, 199.90, '2025-03-01'),
(1, 49.90, '2025-03-10'),
(2, 99.90, '2025-03-15');


-- 1. Uma função que retorne nome, total de pedidos e valor total por cliente
DELIMITER $$
CREATE FUNCTION nome_cliente(id_cliente INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
DECLARE nome_cliente VARCHAR(100);

SELECT nome INTO nome_cliente
FROM clientes
WHERE id = id_cliente;

RETURN nome_cliente;  
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION total_pedidos(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE total INT;

SELECT COUNT(*) INTO total
FROM pedidos 
WHERE cliente_id = id_cliente;

RETURN total;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION valor_total(id_cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
DECLARE total DECIMAL(10,2);

SELECT SUM(total) INTO total
FROM pedidos
WHERE cliente_id = id_cliente;

RETURN total;
END $$
DELIMITER ;

SELECT nome_cliente(2) AS Nome, total_pedidos(2) AS Pedidos, valor_total(2) AS valor;
-- (No PostgreSQL, use RETURN TABLE. No MySQL, pode usar uma VIEW para simular.)
-- 2. Uma VIEW que exiba nome do cliente e valor médio dos pedidos
CREATE VIEW dados_cliente_view AS
SELECT c.nome, AVG(p.valor) AS "valor médio dos pedidos"    
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id  
GROUP BY c.nome;

SELECT * FROM dados_cliente_view;
-- 3. Um EVENTO que execute semanalmente e remova pedidos com valor abaixo de R$ 10,00
DELIMITER $$
CREATE EVENT remove_pedidos_abaixo_10
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
DELETE FROM pedidos 
WHERE valor < 10;
END $$
DELIMITER ;
-- 4. Uma função que retorne nome, total de pedidos e a data do último pedido do
-- cliente 
DELIMITER $$
CREATE FUNCTION nome_cliente(id_cliente INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
DECLARE nome_cliente VARCHAR(100);

SELECT nome INTO nome_cliente
FROM clientes
WHERE id = id_cliente;

RETURN nome_cliente;  
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION total_pedidos(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE total INT;

SELECT COUNT(*) INTO total
FROM pedidos 
WHERE cliente_id = id_cliente;

RETURN total;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION ultimo_pedido(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE data DATE;

SELECT MAX(p.data_pedido) INTO data
FROM pedidos p
WHERE cliente_id = id_cliente;

RETURN data;
END $$
DELIMITER ;

DELIMITER $$

DELIMITER $$

CREATE FUNCTION ultimo_pedido_gpt(id_cliente INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE data DATE;

  SELECT MAX(p.data_pedido) INTO data
  FROM pedidos p
  WHERE cliente_id = id_cliente;

  RETURN data;
END $$

DELIMITER ;

SELECT nome_cliente(2) AS Nome, total_pedidos(2) AS "Total de Pedidos", ultimo_pedido(2) AS "Data";

-- Tabela de produtos
CREATE TABLE produtos (
id INT AUTO_INCREMENT,
nome VARCHAR(100),
estoque INT,
PRIMARY KEY(id)
);
-- Tabela de vendas
CREATE TABLE vendas (
id INT AUTO_INCREMENT,
produto_id INT,
quantidade INT,
data_venda DATE,
PRIMARY KEY(id),
FOREIGN KEY (produto_id) REFERENCES produtos(id)
);
-- EXERCÍCIOS
-- Inserindo produtos
INSERT INTO produtos (nome, estoque) VALUES
('Mouse Gamer', 50),
('Teclado RGB', 30),
('Monitor 240Hz', 20);
-- Inserindo vendas
INSERT INTO vendas (produto_id, quantidade) VALUES
(1, 2), -- Mouse Gamer
(2, 1); -- Teclado RGB

-- Crie TRIGGERS para manter o controle automático do estoque de produtos com base nas
-- operações da tabela de vendas. As triggers devem:
-- - AFTER INSERT em vendas: subtrair do estoque a quantidade vendida.
DELIMITER $$
CREATE TRIGGER trg_subtrai_AI
AFTER INSERT ON vendas
FOR EACH ROW 
BEGIN 
UPDATE produtos
SET estoque = estoque - NEW.quantidade
WHERE id = NEW.produto_id;
END $$
DELIMITER ;
-- - AFTER DELETE em vendas: retornar a quantidade ao estoque (caso uma venda seja
-- cancelada).
DELIMITER $$
CREATE TRIGGER trg_cancelada_AD
AFTER DELETE ON vendas
FOR EACH ROW 
BEGIN
UPDATE produtos
SET estoque = estoque + OLD.quantidade
WHERE id = OLD.produto_id;
END $$
DELIMITER ;
-- - AFTER UPDATE em vendas: recalcular o estoque ajustando a diferença entre a nova e
-- a antiga quantidade vendida.  
DELIMITER $$
CREATE TRIGGER trg_recalcula_AU
AFTER UPDATE ON vendas
FOR EACH ROW
BEGIN 
DECLARE diferenca INT;
SET diferenca = NEW.quantidade - OLD.quantidade;

UPDATE produtos
SET estoque = estoque - diferenca
WHERE id = NEW.produto_id;
END $$
DELIMITER ;