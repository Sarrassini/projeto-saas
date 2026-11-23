-- Migracao do painel de gestao (executar apos backup do banco).
-- Compatível com MySQL 8 no Ubuntu.
USE saas_assinaturas;

-- Permite invalidar o token ao encerrar a sessao.
ALTER TABLE login MODIFY COLUMN token CHAR(64) NULL DEFAULT NULL;

-- A funcao cria tokens diferentes a cada autenticacao.
-- A funcao e criada pelo administrador, nao pelo usuario JDBC.
DROP FUNCTION IF EXISTS gera_token;
DELIMITER $$
CREATE FUNCTION gera_token()
RETURNS CHAR(64)
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN HEX(RANDOM_BYTES(32));
END$$
DELIMITER ;

-- PERMISSOES: executar como administrador, apos confirmar que o usuario existe.
-- O aplicativo nao precisa criar tabelas nem excluir registros.
GRANT SELECT ON saas_assinaturas.* TO 'saas_user'@'localhost';
GRANT UPDATE ON saas_assinaturas.login TO 'saas_user'@'localhost';
GRANT INSERT ON saas_assinaturas.assinaturas TO 'saas_user'@'localhost';
GRANT INSERT ON saas_assinaturas.chamados TO 'saas_user'@'localhost';
GRANT EXECUTE ON FUNCTION saas_assinaturas.gera_token TO 'saas_user'@'localhost';
