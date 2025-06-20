DROP DATABASE IF EXISTS plataforma_ead;
CREATE DATABASE IF NOT EXISTS plataforma_ead;
USE plataforma_ead;

CREATE TABLE aluno (
    id              INT     AUTO_INCREMENT      PRIMARY KEY,
    nome_aluno      VARCHAR(150) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    data_cadastro   DATE
);

CREATE TABLE curso (
    id              INT     AUTO_INCREMENT      PRIMARY KEY,
    nome_curso      VARCHAR(100)    NOT NULL,
    instrutor       VARCHAR(100),
    carga_horaria   INT
);

CREATE TABLE inscricao (
    id              INT     AUTO_INCREMENT      PRIMARY KEY,
    id_aluno        INT,
    id_curso        INT,
    data_inscricao  TIMESTAMP,
    status          VARCHAR(20)
);

CREATE TABLE log_inscricao (
    id                  INT     AUTO_INCREMENT      PRIMARY KEY,
    id_inscricao_ref    INT,
    acao_realizada      VARCHAR(50),
    data_log            TIMESTAMP
);

-- 1. a. Insira pelo menos 8 novos cursos na tabela curso.
INSERT INTO curso (nome_curso, instrutor, carga_horaria)
VALUES('Libras', 'Joao Pedro Barbosa', 400),
      ('Arbitro CBF', 'Daronco', 120),
      ('Curso de Excel', 'Camila Oliveira', 240),
      ('Formação de Soldados', 'Neo Guatimosim', 300),
      ('Curso de Front-End', 'Geancarlo Bastos', 240),
      ('Fundamentos EA FC', 'Eduardo Leal', 200),
      ('Curso Básico de Música', 'Kiko Magioli', 200);
      ('Aula de Canto', 'Vitor Manoel', 100);

--b. Insira pelo menos 15 novos alunos na tabela aluno.
INSERT INTO aluno (nome_aluno, email, data_cadastro) VALUES
('Ana Paula Souza', 'ana.souza@example.com', '2024-05-01'),
('Bruno Martins', 'bruno.martins@example.com', '2024-05-02'),
('Carla Mendes', 'carla.mendes@example.com', '2024-05-03'),
('Diego Oliveira', 'diego.oliveira@example.com', '2024-05-04'),
('Eduarda Lima', 'eduarda.lima@example.com', '2024-05-05'),
('Felipe Rocha', 'felipe.rocha@example.com', '2024-05-06'),
('Gabriela Torres', 'gabriela.torres@example.com', '2024-05-07'),
('Henrique Castro', 'henrique.castro@example.com', '2024-05-08'),
('Isabela Freitas', 'isabela.freitas@example.com', '2024-05-09'),
('João Vitor Almeida', 'joao.almeida@example.com', '2024-05-10'),
('Karina Santos', 'karina.santos@example.com', '2024-05-11'),
('Leonardo Pires', 'leonardo.pires@example.com', '2024-05-12'),
('Marina Costa', 'marina.costa@example.com', '2024-05-13'),
('Nicolas Barbosa', 'nicolas.barbosa@example.com', '2024-05-14'),
('Olívia Nogueira', 'olivia.nogueira@example.com', '2024-05-15');

-- 2.
-- a: Escreva um comando para atualizar o instrutor do curso com id = 1 para "Prof. Gladimir".
    UPDATE curso
    SET instrutor = "Prof. Gladimir"
    WHERE id = 1;

--b: Selecione o nome dos alunos (nome_aluno) e o nome dos cursos em que eles estão inscritos, mostrando apenas as inscrições da tabela inscricao com status 'ativa'.
    SELECT 
    aluno.nome_aluno AS aluno,
    curso.nome_curso AS curso
    FROM
    inscricao
    INNER JOIN aluno ON inscricao.id_aluno = aluno.id
    INNER JOIN curso ON inscricao.id_curso = curso.id
    WHERE inscricao.status = 'ativa';

-- 3 a. Crie um usuário chamado analista que tenha permissão apenas de leitura (SELECT) em todas as tabelas do banco aula14.
    CREATE USER 'analista'@'localhost' IDENTIFIED BY 'analista';
    GRANT SELECT ON plataforma_ead.* TO 'analista'@'localhost';

--b. Crie um usuário chamado secretaria que possa inserir, atualizar e consultar (INSERT, UPDATE, SELECT) dados apenas na tabela inscricao.
    CREATE USER 'secretaria'@'localhost' IDENTIFIED BY 'secretaria';
    GRANT INSERT, UPDATE, SELECT ON plataforma_ead.inscricao TO 'secretaria'@'localhost';

--4 Crie uma PROCEDURE chamada realizar_inscricao(aluno_id INT, curso_id INT) que receba o ID de um aluno e de um curso e insira um novo registro na tabela inscricao.
DELIMITER $$
CREATE PROCEDURE realizar_inscricao(aluno_id INT, curso_id INT)
BEGIN
    INSERT INTO inscricao (id_aluno, id_curso, data_inscricao)
    VALUES(aluno_id, curso_id, CURRENT_DATE);
END $$
DELIMITER ;

--5 5. Crie um TRIGGER chamado log_nova_inscricao que, após cada INSERT na tabela inscricao, insira um registro na tabela log_inscricao. O log deve conter o ID da nova inscrição (no campo id_inscricao_ref) e a ação "NOVA INSCRIÇÃO REALIZADA".
DELIMITER $$
    CREATE TRIGGER log_nova_inscricao
    AFTER INSERT ON inscricao
    FOR EACH ROW
    BEGIN
    INSERT INTO log_inscricao (id_inscricao_ref, acao_realizada, data_log)
    VALUES (
    NEW.id, 'NOVA INSCRIÇÃO REALIZADA', NOW()
    );
END $$
DELIMITER ;

-- 6. Crie uma VIEW chamada v_inscricoes_detalhadas que exiba o nome do aluno (nome_aluno), o email, o nome do curso e a data da inscrição
CREATE VIEW v_inscricoes_detalhadas AS
SELECT 
    a.nome_aluno,
    a.email,
    c.nome_curso,
    i.data_inscricao
FROM 
    inscricao i
JOIN aluno a ON i.id_aluno = a.id
JOIN curso c ON i.id_curso = c.id;

-- 7. Utilizando controle de transação (START TRANSACTION, COMMIT, ROLLBACK), execute os seguintes passos:
-- a. Inicie uma transação.
START TRANSACTION
-- b. Insira uma nova inscricao para o aluno de id = 2 no curso de id = 3.
CALL realizar_inscricao(2, 3);
-- c. Atualize o status dessa mesma inscricao para 'concluída'.
UPDATE inscricao
SET status = 'Concluída'
WHERE id = 8;
-- d. Se ambos os comandos forem bem-sucedidos, confirme a transação. Caso contrário, reverta todas as alterações.
COMMIT;

--8. (GROUP BY): Crie uma consulta que conte quantas inscrições cada curso possui.O resultado deve exibir o nome do curso e o total de alunos inscritos, ordenados do curso com mais alunos para o com menos.
SELECT 
    c.nome_curso AS curso,
    COUNT(i.id_aluno) AS total_alunos
FROM curso c
INNER JOIN inscricao i ON c.id = i.id_curso
INNER JOIN aluno a ON i.id_aluno = a.id
GROUP BY c.nome_curso
ORDER BY total_alunos DESC;

--9. Crie uma consulta que liste todos os cursos e a quantidade de alunos inscritos em cada um.
--A consulta deve incluir também os cursos que não possuem nenhum aluno inscrito 
--(mostrando o valor '0' como total). Utilize LEFT JOIN para garantir que todos os cursos da tabela curso apareçam no resultado.
SELECT 
    c.nome_curso AS curso,
    COUNT(i.id_aluno) AS total_alunos
FROM curso c
LEFT JOIN inscricao i ON c.id = i.id_curso
GROUP BY c.nome_curso
ORDER BY total_alunos DESC;

-- 10. Crie uma consulta que funcione como um relatório de inscrições por status. 
-- uma chamada total_ativas e outra total_concluidas.  
-- O resultado deve ter uma linha para cada nome de curso e duas colunas de contagem: 
-- Utilize a técnica de pivoteamento com SUM e CASE para gerar este relatório. 
SELECT
    c.nome_curso,
    SUM(CASE WHEN i.status = 'ativa' THEN 1 ELSE 0 END) AS inscricoes_ativas,
    SUM(CASE WHEN i.status = 'concluida' THEN 1 ELSE 0 END) AS inscricoes_concluidas
FROM curso c
LEFT JOIN inscricao i ON c.id = i.id_curso
GROUP BY c.id, c.nome_curso
ORDER BY c.nome_curso;
-- 11.
-- a. Crie uma coleção chamada inscricoes.
db.createCollection("inscricoes");
-- b. Para que seja possível testar todos os comandos a seguir, insira pelo menos 15 documentos nesta coleção.
-- Varie os dados para que existam nomes de cursos, nomes de alunos e datas diferentes.
-- Nem todos os documentos não precisam ter os mesmos campos.
db.inscricoes.insertMany([
{
"aluno": { "nome": "Carlos Andrade", "email": "carlos.a@email.com" },
"curso": { "nome": "Análise de Dados com Python", "instrutor": "Prof. Silva" },
"data_inscricao": new Date("2024-10-25"),
"status": "ativa"
},
{
"aluno": { "nome": "Mariana Costa", "email": "mari.c@email.com" },
"curso": { "nome": "Banco de Dados para Big Data", "instrutor": "Prof. Silva" },
"data_inscricao": new Date("2024-11-05"),
"status": "ativa"
},
{
"aluno": { "nome": "Ana Beatriz", "email": "ana.b@email.com" },
"curso": { "nome": "Introdução a Algoritmos", "instrutor": "Prof. Souza" },
"data_inscricao": new Date("2025-02-15"),
"status": "ativa"
},
{
"aluno": { "nome": "Pedro Martins", "email": "pedro.m@email.com" },
"curso": { "nome": "Machine Learning", "instrutor": "Prof. Souza" },
"data_inscricao": new Date("2025-03-01"),
"status": "ativa"
},
{
"aluno": { "nome": "Juliana Lima", "email": "ju.lima@email.com" },
"curso": { "nome": "Desenvolvimento Web Fullstack", "instrutor": "Prof. Gladimir" },
"data_inscricao": new Date("2025-01-20"),
"status": "concluída"
},
{
"aluno": { "nome": "Amanda Gomes", "email": "amanda.g@email.com" },
"curso": { "nome": "Engenharia de Software", "instrutor": "Prof. Carla" },
"data_inscricao": new Date("2025-04-10"),
"status": "ativa"
},
{
"aluno": { "nome": "Lucas Pereira", "email": "lucas.p@email.com", "matricula": "BR25001"
},
"curso": { "nome": "Cibersegurança Essencial", "instrutor": "Prof. Carla" },
"data_inscricao": new Date("2025-03-20"),
"status": "ativa",
"bolsa": { "tipo": "Mérito Acadêmico", "percentual": 100 }
},
{
"aluno": { "nome": "Fernanda Dias", "email": "fernanda.d@email.com" },
"curso": { "nome": "Gestão de Projetos Ágeis", "instrutor": "Prof. Gladimir" },
"data_inscricao": new Date("2025-05-01"),
"status": "concluída",
"nota_final": 9.5,
"empresa_contratante": "Tech Solutions Inc."
},
{
"aluno": { "nome": "Ricardo Neves" },
"curso": { "nome": "Tópicos Avançados em Banco de Dados" },
"data_inscricao": new Date("2025-05-10"),
"tags": ["SQL", "NoSQL", "Performance"]
},
{
"aluno": { "nome": "Vitor Hugo", "email": "vitor.h@email.com" },
"curso": { "nome": "Lógica de Programação (Legacy)", "instrutor": "Prof. Antigo" },
"data_inscricao": new Date("2024-03-15"),
"status": "arquivada"
}
]);

db.inscricoes.insertMany([
  {
    aluno: { nome: "Bruno Lima", email: "bruno.lima@email.com" },
    curso: { nome: "Lógica de Programação", instrutor: "Prof. Helena Rocha" },
    data_inscricao: new Date("2025-01-20"),
    status: "ativa"
  },
  {
    aluno: { nome: "Larissa Costa", email: "larissa.c@email.com" },
    curso: { nome: "Banco de Dados I", instrutor: "Prof. Marcos Pinto" },
    data_inscricao: new Date("2025-02-05"),
    status: "pendente"
  },
  {
    aluno: { nome: "Diego Fernandes", email: "diego.f@email.com" },
    curso: { nome: "Redes de Computadores", instrutor: "Prof. Vanessa Luz" },
    data_inscricao: new Date("2025-03-12"),
    status: "ativa"
  },
  {
    aluno: { nome: "Tatiane Ribeiro", email: "tatiane.r@email.com" },
    curso: { nome: "Engenharia de Software", instrutor: "Prof. Guilherme Braga" },
    data_inscricao: new Date("2025-03-25"),
    status: "cancelada"
  },
  {
    aluno: { nome: "Henrique Oliveira", email: "henrique.o@email.com" },
    curso: { nome: "Desenvolvimento Web", instrutor: "Prof. Camila Santos" },
    data_inscricao: new Date("2025-04-10"),
    status: "ativa"
  }
]);

-- 12. (expressão regular)
-- a. Escreva uma consulta para encontrar todas as inscrições em cursos que contenham a
-- palavra "Dados" em seu nome.
db.inscricoes.find({"curso.nome": /Dados/ }).pretty();

-- b. Escreva uma consulta para encontrar todas as inscrições de alunos cujo nome comece com
-- a letra "A".
db.inscricoes.find({"aluno.nome": /^A/}).pretty();

-- 13. (updateMany)
-- O "Prof. Souza" mudou-se para outra instituição.
-- Escreva um comando que atualize todas as inscrições dos cursos ministrados por ele, alterando o campo status para "em espera".
db.inscricoes.updateMany({ "curso.instrutor": "Prof. Souza" }, { $set: { status: "em espera" } });

-- 14. (replaceMany)
-- A plataforma decidiu arquivar todas as inscrições feitas pelo instrutor "Prof. Silva".
-- Escreva um comando que substitua o documento inteiro de todas as inscrições dele por um
-- novo documento com a seguinte estrutura: { "inscricao_arquivada": true, "aviso": "Curso migrado para sistema legado." }.
db.inscricoes.updateMany({"curso.instrutor": "Prof. Silva" },
{$set: {"inscricao_arquivada": true, "aviso": "Curso migrado para sistema legado."}, 
$unset: {aluno: "",curso: "", data_inscricao: "", status: ""}});

-- 15. (deleteMany): Escreva um comando que remova todas as inscrições com o status "em
-- espera".
db.inscricoes.deleteMany({ status: "em espera" });

--16. (aggregate): Conte quantas inscrições existem para cada instrutor.
--O resultado deve mostrar o nome do instrutor e o total de inscritos.
db.inscricoes.aggregate([
  {
    $group: {
      _id: "$curso.instrutor",
      total: { $sum: 1 }
    }
  }
]);

--17. (createIndex): Crie um índice no campo aluno.email da coleção inscricoes para otimizar
--futuras buscas por email de alunos.
db.inscricoes.createIndex({ "aluno.email": 1 });
















