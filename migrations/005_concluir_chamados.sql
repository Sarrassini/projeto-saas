-- Migracao 005: permite concluir chamados pela interface web.
-- Executar depois das migracoes 002, 003 e 004.
USE saas_assinaturas;

-- O usuario JDBC pode atualizar somente o status de chamados existentes.
GRANT UPDATE ON saas_assinaturas.chamados TO 'saas_user'@'localhost';
