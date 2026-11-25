# Testes — Gestão SaaS

## Ambiente e data

- Data da validação manual anterior: **25/11/2026**.
- Aplicação executada em uma VM Ubuntu Server.
- Servidor web: Apache Tomcat 10.1.55.
- Java observado na VM: OpenJDK 26.0.2.
- Banco de dados: MySQL, acessado pelo Connector/J.
- URL usada na rede local: `http://IP_DA_VM:8080/mini/` (o IP pode mudar conforme a rede).

Os resultados abaixo separam o que foi efetivamente observado na VM do que ainda precisa ser testado. Os testes são manuais, não automatizados.

## Testes executados antes da atualização de contratos e clientes

| ID | Cenário | Resultado observado | Status |
|---|---|---|---|
| T01 | Abrir a aplicação e visualizar a tela de login | A tela de login foi exibida. | **Aprovado** |
| T02 | Entrar com o usuário administrativo válido | Login realizado e painel exibido. | **Aprovado** |
| T03 | Pesquisar cliente pelo e-mail `ti@technova.com` | A empresa TechNova Ltda foi localizada. | **Aprovado** |
| T04 | Consultar a lista de assinaturas | As assinaturas cadastradas foram exibidas. | **Aprovado** |
| T05 | Cadastrar uma nova assinatura | O cadastro foi concluído; o painel passou a mostrar 4 assinaturas ativas. | **Aprovado na versão anterior** |
| T06 | Consultar a lista de chamados | Os chamados existentes foram exibidos com suas situações. | **Aprovado** |
| T07 | Abrir chamado para Padaria Pão Quente | O chamado “Teste de abertura de chamado - apresentação SaaS” foi registrado como pendente. | **Aprovado** |
| T08 | Conferir os indicadores do painel após os cadastros | O painel exibiu 3 empresas, 4 assinaturas ativas, 2 chamados pendentes e R$ 849,60 de receita mensal estimada. | **Aprovado na versão anterior** |
| T09 | Encerrar a sessão pelo botão Sair | O logout foi concluído e a aplicação retornou à tela de login. | **Aprovado** |

## Novos testes — atualização de contratos e clientes

Executar estes cenários depois de atualizar os arquivos na VM e aplicar a migração 003.

| ID | Cenário | Resultado esperado | Status |
|---|---|---|---|
| T10 | Selecionar uma empresa que já possui contrato ativo e escolher outro plano | O registro ativo existente é atualizado; nenhum novo registro é criado. | **Pendente** |
| T11 | Consultar o histórico após atualizar um contrato que tinha duplicidades ativas antigas | O contrato mais recente permanece ativo e os anteriores passam a cancelados, sem apagar o histórico. | **Pendente** |
| T12 | Selecionar uma empresa sem contrato ativo e salvar um plano | Um novo contrato ativo é criado. | **Pendente** |
| T13 | Conferir a lista de clientes após aplicar a migração 003 | As três novas empresas de demonstração aparecem na listagem. | **Pendente** |
| T14 | Executar novamente a migração 003 | Os clientes não são duplicados, pois os e-mails são únicos e o script usa `INSERT IGNORE`. | **Pendente** |

### Como conferir que um contrato foi atualizado

Antes do teste, consulte o ID e os dados da assinatura da empresa escolhida:

```sql
SELECT id, cliente_id, plano_id, data_inicio, status
FROM assinaturas
WHERE cliente_id = ID_DO_CLIENTE
ORDER BY id DESC;
```

Faça o envio pelo formulário escolhendo outro plano. Depois, execute a mesma consulta. O ID do contrato ativo mais recente deve continuar igual, enquanto o plano e a data de início devem refletir os novos valores.

### Como conferir os três novos clientes

```sql
SELECT id, empresa, email, data_cadastro
FROM clientes
WHERE email IN (
    'contato@auroratecnologia.example',
    'contato@horizonteconsultoria.example',
    'suporte@prismasolucoes.example'
)
ORDER BY empresa;
```

## Testes de segurança ainda pendentes

| ID | Cenário | Resultado esperado | Status |
|---|---|---|---|
| P01 | Tentar login com senha incorreta | Permanecer fora da área autenticada e exibir mensagem de erro. | **Pendente** |
| P02 | Acessar uma página interna sem sessão | Redirecionar para a tela de login. | **Pendente** |
| P03 | Usar o botão Voltar do navegador após logout | Não permitir reutilizar uma página protegida sem autenticação válida. | **Pendente** |
| P04 | Enviar GET diretamente para `salvar_assinatura.jsp` ou `salvar_chamado.jsp` | Responder com HTTP 405. | **Pendente** |
| P05 | Enviar formulário com token CSRF inválido | Responder com HTTP 403 e não gravar dados. | **Pendente** |
| P06 | Tentar acessar diretamente arquivos dentro de `WEB-INF` | Não disponibilizar os arquivos internos ao navegador. | **Pendente** |

## Funcionalidade fora do escopo implementado

A tela de chamados permite consultar e abrir solicitações. **Não existe atualmente uma ação/tela para alterar um chamado pendente para resolvido.** Por isso, não foi registrado um teste de resolução de chamado.

## Consultas SQL para conferência

Execute no MySQL, se quiser conferir os dados gravados:

```sql
USE saas_assinaturas;

SELECT c.empresa, p.nome, a.status, a.data_inicio
FROM assinaturas a
JOIN clientes c ON c.id = a.cliente_id
JOIN planos p ON p.id = a.plano_id
ORDER BY a.id DESC;

SELECT c.empresa, ch.assunto, ch.data_abertura, ch.resolvido
FROM chamados ch
JOIN clientes c ON c.id = ch.cliente_id
ORDER BY ch.id DESC;

SELECT `user`, token IS NOT NULL AS token_ativo
FROM login;
```

## Observações

- Os cadastros de teste anteriores foram feitos no banco da VM e alteraram os dados existentes.
- Não reaplique `schema.sql` em um banco que já contém dados: ele é destinado à instalação inicial.
- A migração 003 adiciona os três clientes fictícios e concede permissão de atualização na tabela de assinaturas ao usuário JDBC.
- Os resultados marcados como aprovados correspondem à versão anterior e foram observados durante a validação manual. Os novos cenários permanecem pendentes até serem executados na VM.
