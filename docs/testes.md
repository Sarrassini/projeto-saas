# Cenários de teste — Gestão SaaS

Registrar prints com a data, a URL acessada e os resultados observados na VM.

| Caso | Passos | Resultado esperado |
|---|---|---|
| T01 | Abrir `/mini/index.jsp` sem login | Formulário de autenticação |
| T02 | Entrar com `admin` e uma senha errada | Volta ao login e mostra erro |
| T03 | Entrar com `admin/123456` | Exibe painel e indicadores |
| T04 | Acessar `/mini/clientes.jsp` sem sessão | Redireciona ao login |
| T05 | Buscar uma empresa existente | Lista dados sem duplicar empresa |
| T06 | Consultar `/mini/assinaturas.jsp` | Mostra empresa, plano, valor, data e status |
| T07 | Criar assinatura de um cliente e plano válidos | Registro aparece na listagem e banco |
| T08 | Abrir chamado de suporte para uma empresa | Registro aparece como pendente |
| T09 | Tentar abrir uma página de gravação por GET | Resposta HTTP 405 |
| T10 | Sair e voltar à página interna pelo navegador | Acesso deve exigir novo login |
| T11 | Abrir `/mini/WEB-INF/conexao.jspf` diretamente | Tomcat não fornece esse arquivo como recurso público |
| T12 | Tentar usar token CSRF inválido no POST | Resposta HTTP 403 |

## Consultas MySQL para evidências

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

SELECT `user`, token IS NOT NULL AS token_ativo FROM login;
```

## Nota
Estes são **casos planejados**, não resultados já executados. Para confirmar o funcionamento, executar na VM e anotar cada resultado ou erro encontrado.
