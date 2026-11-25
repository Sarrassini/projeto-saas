CREATE DATABASE IF NOT EXISTS saas_assinaturas;
USE saas_assinaturas;

CREATE TABLE planos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    preco_mensal DECIMAL(10,2) NOT NULL,
    limite_usuarios INT NOT NULL
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro DATE NOT NULL
);

CREATE TABLE assinaturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    plano_id INT NOT NULL,
    data_inicio DATE NOT NULL,
    status ENUM('ativa', 'cancelada', 'suspensa') DEFAULT 'ativa',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (plano_id) REFERENCES planos(id)
);

CREATE TABLE chamados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    assunto VARCHAR(150) NOT NULL,
    data_abertura DATE NOT NULL,
    resolvido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela original mantida para compatibilidade com a primeira versao.
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) UNIQUE NOT NULL,
    senha CHAR(64) NOT NULL
);

-- Tabela de autenticacao com token conforme o modelo do professor.
CREATE TABLE login (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `user` VARCHAR(50) UNIQUE NOT NULL,
    `password` CHAR(32) NOT NULL,
    token CHAR(64) UNIQUE NOT NULL
);

DELIMITER $$
CREATE FUNCTION gera_token() RETURNS CHAR(64)
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN SHA2(CONCAT(UUID(), RAND(), CURRENT_TIMESTAMP(6)), 256);
END$$
DELIMITER ;

INSERT INTO planos (nome, preco_mensal, limite_usuarios) VALUES
('Basico', 49.90, 5),
('Profissional', 149.90, 25),
('Enterprise', 499.90, 200);

INSERT INTO clientes (empresa, email, data_cadastro) VALUES
('Padaria Pao Quente', 'contato@paoquente.com', '2026-09-15'),
('TechNova Ltda', 'ti@technova.com', '2026-09-20'),
('Clinica Vida', 'admin@clinicavida.com', '2026-10-01'),
('Aurora Tecnologia Ltda', 'contato@auroratecnologia.example', '2026-11-25'),
('Horizonte Consultoria Empresarial', 'contato@horizonteconsultoria.example', '2026-11-25'),
('Prisma Solucoes Digitais', 'suporte@prismasolucoes.example', '2026-11-25');

INSERT INTO assinaturas (cliente_id, plano_id, data_inicio, status) VALUES
(1, 1, '2026-09-15', 'ativa'),
(2, 2, '2026-09-20', 'ativa'),
(3, 3, '2026-10-01', 'ativa');

INSERT INTO chamados (cliente_id, assunto, data_abertura, resolvido) VALUES
(2, 'Erro ao exportar relatorio', '2026-10-05', TRUE),
(3, 'Duvida sobre cobranca', '2026-10-08', FALSE);

-- Chamado resolvido de demonstracao para a Aurora Tecnologia Ltda.
INSERT INTO chamados (cliente_id, assunto, data_abertura, resolvido)
SELECT id, 'Falha no acesso ao painel administrativo', '2026-11-20', TRUE
FROM clientes
WHERE email = 'contato@auroratecnologia.example'
LIMIT 1;

INSERT INTO usuarios (login, senha) VALUES ('admin', SHA2('123456', 256));

-- Credencial didatica para testes; MD5 e usado para seguir o exemplo do professor.
INSERT INTO login (`user`, `password`, token)
VALUES ('admin', MD5('123456'), gera_token());
