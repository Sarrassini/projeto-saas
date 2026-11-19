-- Executar apenas apos backup do banco existente.
USE saas_assinaturas;

-- Token representa sessao ativa e pode ser anulado ao sair.
ALTER TABLE login MODIFY COLUMN token CHAR(64) NULL DEFAULT NULL;

-- O servidor de aplicacao usa um usuario dedicado.
-- Conceder as permissoes abaixo no MySQL como administrador:
-- GRANT SELECT ON saas_assinaturas.* TO 'saas_user'@'localhost';
-- GRANT UPDATE ON saas_assinaturas.login TO 'saas_user'@'localhost';
-- GRANT INSERT ON saas_assinaturas.assinaturas TO 'saas_user'@'localhost';
-- GRANT INSERT ON saas_assinaturas.chamados TO 'saas_user'@'localhost';
-- GRANT EXECUTE ON FUNCTION saas_assinaturas.gera_token TO 'saas_user'@'localhost';
