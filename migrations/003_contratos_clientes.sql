-- Migracao 003: atualizacao de contratos e tres clientes de demonstracao.
-- Executar depois da migracao 002, com o usuario saas_user ja criado.
USE saas_assinaturas;

-- O cadastro agora atualiza uma assinatura existente e pode encerrar
-- registros ativos duplicados antigos. O usuario JDBC precisa de UPDATE.
GRANT UPDATE ON saas_assinaturas.assinaturas TO 'saas_user'@'localhost';

-- Clientes ficticios para demonstracao. Os e-mails usam o dominio reservado .example.
-- INSERT IGNORE torna a migracao segura para execucoes repetidas.
INSERT IGNORE INTO clientes (empresa, email, data_cadastro) VALUES
('Aurora Tecnologia Ltda', 'contato@auroratecnologia.example', '2026-11-25'),
('Horizonte Consultoria Empresarial', 'contato@horizonteconsultoria.example', '2026-11-25'),
('Prisma Solucoes Digitais', 'suporte@prismasolucoes.example', '2026-11-25');
