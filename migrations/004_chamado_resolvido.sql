-- Migracao 004: cadastro de clientes pela aplicacao e chamado resolvido de demonstracao.
-- Executar depois das migracoes 002 e 003.
USE saas_assinaturas;

-- Permite que o usuario JDBC cadastre empresas pelo formulario da aplicacao.
GRANT INSERT ON saas_assinaturas.clientes TO 'saas_user'@'localhost';

-- Inclui um exemplo de chamado resolvido para a Aurora Tecnologia Ltda.
-- A condicao NOT EXISTS evita inserir o mesmo exemplo novamente.
INSERT INTO chamados (cliente_id, assunto, data_abertura, resolvido)
SELECT c.id, 'Falha no acesso ao painel administrativo', '2026-11-20', TRUE
FROM clientes c
WHERE c.email = 'contato@auroratecnologia.example'
  AND NOT EXISTS (
      SELECT 1
      FROM chamados ch
      WHERE ch.cliente_id = c.id
        AND ch.assunto = 'Falha no acesso ao painel administrativo'
  );
