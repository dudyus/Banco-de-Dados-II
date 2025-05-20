-- BD2 - Simulado1

DROP DATABASE IF EXISTS simulado1;
CREATE DATABASE simulado1;
USE simulado1;

-- Tabela de livros
CREATE TABLE livro (
    id     INT AUTO_INCREMENT,
    titulo VARCHAR(100),
    autor  VARCHAR(100),
    qtd_exemplares INT,
    PRIMARY KEY (id)
);

-- Tabela de usuários
CREATE TABLE usuario (
    id    INT AUTO_INCREMENT,
    nome  VARCHAR(100),
    email VARCHAR(100),
    PRIMARY KEY (id)
);

-- Tabela de empréstimos
CREATE TABLE emprestimo (
    id              INT AUTO_INCREMENT,
    id_livro        INT,
    id_usuario      INT,
    data_emprestimo DATE,
    data_devolucao  DATE DEFAULT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_livro)   REFERENCES livro(id),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

-- Inserção de dados
INSERT INTO livro (titulo, autor, qtd_exemplares) VALUES
('O Tronco do Ipê', 'José de Alencar', 5),
('Dom Casmurro', 'Machado de Assis', 3),
('Quincas Berro D`Água', 'Jorge Amado', 4),
('O Escaravelho do Diabo', 'Lúcia Machado de Almeida', 2),
('O Guarani', 'José de Alencar', 5),
('Robinson Crusoé', 'Daniel Defoe', 6),
('O Sítio do Picapau Amarelo', 'Monteiro Lobato', 7),
('O Cachorrinho Samba na Fazenda', 'Maria José Dupré', 3),
('A Moreninha', 'Joaquim Manuel de Macedo', 4),
('Memórias de um Sargento de Milícias', 'Manuel Antônio de Almeida', 5);

INSERT INTO usuario (nome, email) VALUES
('Juan Ivanov', 'juan@gmail.com'),
('Miguel Petrov', 'miguel@gmail.com'),
('Pedro Smirnov', 'pedro@gmail.com'),
('Ana Kuznetsova', 'ana@gmail.com'),
('José Pavlov', 'jose@gmail.com'),
('Carlos Romanov', 'carlos@gmail.com'),
('Maria Volkov', 'maria@gmail.com'),
('Sofia Fedorova', 'sofia@gmail.com'),
('Luis Popov', 'luis@gmail.com'),
('Gabriela Sokolov', 'gabriela@gmail.com');

-- RESPONDA/RESOLVA:

/* 1. Crie o trigger trg_diminuir_exemplar_emprestimo
      que diminui a quantidade de exemplares ao registrar um empréstimo. */

DELIMITER $$
CREATE TRIGGER trg_diminuir_exemplar_emprestimo
AFTER INSERT ON emprestimo
FOR EACH ROW 
BEGIN
UPDATE livro 
SET qtd_exemplares = qtd_exemplares - 1
WHERE id = NEW.id_livro;
END $$
DELIMITER ;

/* 2. Crie o trigger trg_aumentar_exemplar_devolucao
      que aumenta a quantidade de exemplares ao devolver um livro. */

DELIMITER $$
CREATE TRIGGER trg_aumentar_exemplar_devolucao
AFTER UPDATE ON emprestimo
FOR EACH ROW 
BEGIN
      IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
            UPDATE livro 
            SET qtd_exemplares = qtd_exemplares + 1
            WHERE id = NEW.id_livro;
      END IF;
END $$
DELIMITER ;

/* 3. Crie a procedure proc_livros_emprestados_por_usuario(id_usuario INT)
      que exibe a quantidade de livros emprestados por um usuário. */

DELIMITER $$
CREATE PROCEDURE proc_livros_emprestados_por_usuario(IN p_id_usuario INT)
BEGIN 
SELECT COUNT(*) AS "Total de livros emprestados"
FROM emprestimo
WHERE id_usuario = id_usuario
END $$
DELIMITER ;

/* 4. Faça uma consulta que retorne o título dos livros 
      que possuem mais de 3 cópias disponíveis. */

SELECT titulo
FROM livro  
WHERE qtd_exemplares > 3;

/* 5. Faça uma consulta que retorne os usuários 
      que não realizaram nenhum empréstimo. */

SELECT u.nome
FROM usuario u
LEFT JOIN emprestimo e ON e.id_usuario = u.id
WHERE e.id_usuario IS NULL;

/* 6. Crie a procedure proc_usuarios_com_devolucao()
      que exibe todos os usuários que já devolveram livros. */

DELIMITER $$
CREATE PROCEDURE proc_usuarios_com_devolucao()
BEGIN 
      SELECT DISTINCT u.nome -- DISTINCT seleciona apenas uma vez cada nome, mesmo q apareça, mais de uma vez
      FROM usuario u 
      JOIN emprestimo e ON e.id_usuario = u.id
      WHERE e.data_devolucao IS NOT NULL;
END $$
DELIMITER ;

/* 7. Crie o trigger trg_bloquear_emprestimo_sem_exemplar
      que impede empréstimos quando não houver cópias disponíveis. */

DELIMITER $$
CREATE TRIGGER trg_bloquear_emprestimo_sem_exemplar
BEFORE INSERT ON emprestimo
FOR EACH ROW
BEGIN
      IF (SELECT qtd_exemplares FROM livro WHERE id = NEW.id_livro) < 1 THEN 
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não há cópias disponíveis.';
       END IF;
END $$
DELIMITER ;

/* 8. Faça uma consulta que retorne os livros 
      que nunca foram emprestados. */

SELECT l.titulo
FROM livro l 
LEFT JOIN emprestimo e ON e.id_livro = l.id
WHERE e.data_emprestimo IS NULL;

-- ou versao do glad

SELECT titulo
FROM livro
WHERE id NOT IN (SELECT id_livro FROM emprestimo);

/* 9. Crie o trigger trg_registrar_data_devolucao
      que registra automaticamente a data de devolução ao atualizar o empréstimo. */

-- n consegui essa
DELIMITER $$
CREATE TRIGGER trg_registrar_data_devolucao
BEFORE UPDATE ON emprestimo
FOR EACH ROW
BEGIN
  IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NULL THEN
    SET NEW.data_devolucao = CURDATE();
  END IF;
END$$
DELIMITER ;

/* 10. Faça uma consulta que retorne todos os empréstimos 
       realizados no último mês. */

SELECT * 
FROM emprestimo
WHERE data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)  -- DATE_SUB = data atual MENOS 1 mes
                                                                -- CURDATE 20/05/2025 SUBTRAIDO 1 MES => 20/04/2025

/* 11. Crie a procedure proc_novo_emprestimo(id_livro INT, id_usuario INT)
       que insere um novo empréstimo e retorna uma mensagem de disponibilidade. */

DELIMITER $$
CREATE PROCEDURE proc_novo_emprestimo(IN p_id_livro INT, IN p_id_usuario INT)
BEGIN
      IF (SELECT qtd_exemplares FROM livro WHERE id = p_id_livro) > 0 THEN
      INSERT INTO emprestimo (id_livro, id_usuario, data_emprestimo)
      VALUES(p_id_livro, p_id_usuario, CURDATE());
      SELECT 'Empréstimo realizado com sucesso.' AS mensagem;
      ELSE 
      SELECT 'Não há copias deste livro' AS mensagem;
      END IF;
END $$
DELIMITER ;

/* 12. Desabilite o autocommit e realize uma transação manual:
       insira um empréstimo e depois faça um ROLLBACK. */
      
SET autocommit = 0;
START TRANSACTION;
INSERT INTO emprestimo (id_livro, id_usuario, data_emprestimo)
VALUES (1, 1, CURDATE());
ROLLBACK;

/* 13. Faça uma consulta com que retorna todos os livros com as cópias disponíveis */

SELECT titulo
FROM livro
WHERE qtd_exemplares > 0;

/* 14. Crie o usuário bibliotecario e conceda permissões de INSERT, UPDATE e DELETE
       em todas as tabelas do banco simulado1. */

-- n sabia essa tb
CREATE USER 'bibliotecario'@'localhost' IDENTIFIED BY 'senha123';
GRANT INSERT, UPDATE, DELETE ON simulado1.* TO 'bibliotecario'@'localhost';

/* 15. Revogue a permissão de DELETE do usuário bibliotecario. */

-- nem essa ;)
REVOKE DELETE ON simulado1.* FROM 'bibliotecario'@'localhost';
