-- Excluir banco de dados, caso exista
DROP DATABASE IF EXISTS revisao1;

-- Criar o banco de dados
CREATE DATABASE revisao1;

-- Usar o banco de dados
USE revisao1;

-- Criar tabela aluno
CREATE TABLE aluno (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(50),
    sobrenome VARCHAR(50),
    status    INT,
    email     VARCHAR(100)
);

-- Inserir dados na tabela alunos
INSERT INTO aluno (nome, sobrenome, status, email)
VALUES 
('João', 'Silva', 20, 'joao@senacrs.com.br'),
('Maria', 'Santos', 21, 'maria@senacrs.com.br'),
('Pedro', 'Oliveira', 22, 'pedro@senacrs.com.br'),
('Ana', 'Ferreira', 19, 'ana@senacrs.com.br'),
('Carlos', 'Almeida', 20, 'carlos@senacrs.com.br'),
('Mariana', 'Pereira', 23, 'mariana@senacrs.com.br'),
('Lucas', 'Rodrigues', 24, 'lucas@senacrs.com.br'),
('Juliana', 'Gomes', 25, 'juliana@senacrs.com.br'),
('Fernanda', 'Martins', 18, 'fernanda@senacrs.com.br'),
('Rafael', 'Barbosa', 20, 'rafael@senacrs.com.br');


-- Criar tabela curso
CREATE TABLE curso (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(50),
    descricao VARCHAR(255)
);

-- Inserir dados na tabela curso
INSERT INTO curso (nome, descricao)
VALUES
('Matemática', 'Curso de matemática básica'),
('Física', 'Curso de física aplicada'),
('Química', 'Curso de química orgânica'),
('História', 'Curso de história contemporânea'),
('Geografia', 'Curso de geografia política'),
('Inglês', 'Curso de inglês avançado'),
('Programação', 'Curso de programação web'),
('Artes', 'Curso de artes plásticas'),
('Literatura', 'Curso de literatura mundial'),
('Educação Física', 'Curso de educação física');

-- Criar tabela matricula
CREATE TABLE matricula (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    aluno_id      INT,
    curso_id      INT,
    DataMatricula DATE,
    FOREIGN KEY (aluno_id) REFERENCES Aluno(id),
    FOREIGN KEY (curso_id) REFERENCES Curso(id)
);

-- Inserir dados na tabela matricula
INSERT INTO matricula (aluno_id, curso_id, dataMatricula)
VALUES 
(1, 1, ' 2025-01-15'),
(2, 3, ' 2025-02-20'),
(3, 5, ' 2025-03-10'),
(4, 7, ' 2025-04-05'),
(5, 9, ' 2025-05-12'),
(6, 2, ' 2025-06-18'),
(7, 4, ' 2025-07-22'),
(8, 6, ' 2025-08-30'),
(9, 8, ' 2025-09-14'),
(10, 10, ' 2025-10-25');



-- Exercícios:

-- a) Escreva uma consulta para exibir todos os alunos matriculados em um curso específico, por exemplo, "Matemática".
SELECT a.nome, a.sobrenome
FROM aluno a
JOIN matricula m ON a.id = m.aluno_id
JOIN curso c ON m.curso_id = c.id
WHERE c.nome = 'Matemática';

-- b) Altere o nome do curso com o id 3 para "Química Orgânica".
UPDATE curso
SET nome = 'Química Orgânica'
WHERE id = 3;

-- c) Adicione uma nova coluna chamada "telefone" à tabela aluno do tipo VARCHAR(15).
ALTER TABLE aluno
ADD telefone VARCHAR(15);

-- d) Tente remover o aluno com o id 7 da tabela Alunos. Houve um erro? Explique.
DELETE FROM aluno
WHERE id = 7;
-- Vai gerar erro.

-- e) Liste todos os cursos juntamente com a contagem de alunos matriculados em cada curso.
SELECT c.nome, COUNT(m.aluno_id) AS 'Quantidade de Alunos'
FROM curso c
LEFT JOIN matricula m ON c.id = m.curso_id
GROUP BY c.nome;

-- f) Altere o status do aluno com id 1 para 21.
UPDATE aluno
SET status = 21
WHERE id = 1;

-- g) Adicione uma nova coluna chamada "nível" à tabela curso do tipo VARCHAR(20).
ALTER TABLE curso
ADD nivel VARCHAR(20);

-- h) Remova a matrícula com o id 5 da tabela matricula.
DELETE FROM matricula
WHERE id = 5;

-- i) Renomeie a tabela curso para "disciplina".
RENAME TABLE curso TO disciplina;

-- j) Altere o e-mail do aluno com id 9 para 'fernanda_novo@senacrs.com.br'.
UPDATE aluno
SET email = 'fernanda_novo@senacrs.com.br'
WHERE id = 9;
