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
END$$
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
END$$
DELIMITER ;

/* 3. Crie a procedure proc_livros_emprestados_por_usuario(id_usuario INT)
      que exibe a quantidade de livros emprestados por um usuário. */
DELIMITER $$
CREATE PROCEDURE proc_livros_emprestados_por_usuario(IN p_id_usuario INT)
BEGIN
  SELECT COUNT(*) AS total_emprestimos
  FROM emprestimo
  WHERE id_usuario = p_id_usuario;
END$$
DELIMITER ;

/* 4. Faça uma consulta que retorne o título dos livros 
      que possuem mais de 3 cópias disponíveis. */
SELECT titulo
FROM livro
WHERE qtd_exemplares > 3;

/* 5. Faça uma consulta que retorne os usuários 
      que não realizaram nenhum empréstimo. */

-- Assim:
SELECT nome
FROM usuario
WHERE id NOT IN (SELECT id_usuario FROM emprestimo);

-- Ou assim:
SELECT u.nome
FROM usuario u
LEFT JOIN emprestimo e ON u.id = e.id_usuario
WHERE e.id IS NULL;

/* 6. Crie a procedure proc_usuarios_com_devolucao()
      que exibe todos os usuários que já devolveram livros. */
DELIMITER $$
CREATE PROCEDURE proc_usuarios_com_devolucao()
BEGIN
  SELECT DISTINCT u.nome
  FROM usuario u
  JOIN emprestimo e ON u.id = e.id_usuario
  WHERE e.data_devolucao IS NOT NULL;
END$$
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
END$$
DELIMITER ;

/* 8. Faça uma consulta que retorne os livros 
      que nunca foram emprestados. */
SELECT titulo
FROM livro
WHERE id NOT IN (SELECT id_livro FROM emprestimo);

/* 9. Crie o trigger trg_registrar_data_devolucao
      que registra automaticamente a data de devolução ao atualizar o empréstimo. */
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
WHERE data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH); 

/* 11. Crie a procedure proc_novo_emprestimo(id_livro INT, id_usuario INT)
       que insere um novo empréstimo e retorna uma mensagem de disponibilidade. */
DELIMITER $$
CREATE PROCEDURE proc_novo_emprestimo(IN p_id_livro INT, IN p_id_usuario INT)
BEGIN
  IF (SELECT qtd_exemplares FROM livro WHERE id = p_id_livro) > 0 THEN
    INSERT INTO emprestimo (id_livro, id_usuario, data_emprestimo)
    VALUES (p_id_livro, p_id_usuario, CURDATE());
    SELECT 'Empréstimo realizado com sucesso.' AS mensagem;
  ELSE
    SELECT 'Não há cópias disponíveis para este livro.' AS mensagem;
  END IF;
END$$
DELIMITER ;

/* 12. Desabilite o autocommit e realize uma transação manual:
       insira um empréstimo e depois faça um ROLLBACK. */
SET autocommit = 0;
START TRANSACTION;
INSERT INTO emprestimo (id_livro, id_usuario, data_emprestimo)
VALUES (1, 1, CURDATE());
ROLLBACK;

/* 13. Faça uma consulta com que retorna todos os livros com as cópias disponíveis */
-- Esta consulta mantém as linhas bloqueadas para escrita até o fim da transação
SELECT *
FROM livro
WHERE qtd_exemplares > 0;

/* 14. Crie o usuário bibliotecario e conceda permissões de INSERT, UPDATE e DELETE
       em todas as tabelas do banco simulado1. */
CREATE USER 'bibliotecario'@'localhost' IDENTIFIED BY 'senha123';
GRANT INSERT, UPDATE, DELETE ON simulado1.* TO 'bibliotecario'@'localhost';

/* 15. Revogue a permissão de DELETE do usuário bibliotecario. */
REVOKE DELETE ON simulado1.* FROM 'bibliotecario'@'localhost';