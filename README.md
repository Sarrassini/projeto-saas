# Gestão SaaS — Plataforma de Assinaturas

Projeto acadêmico original da disciplina **SaaS Infrastructure**, desenvolvido para simular a gestão de serviços por assinatura, com foco em infraestrutura Linux, banco relacional, consultas e operações web.

## Proposta
A aplicação ajuda uma empresa fictícia provedora de software a acompanhar seus **clientes**, **planos contratados**, **assinaturas** e **chamados de suporte**. Diferente de um sistema de academia, ela trabalha com o processo de negócio de gestão de contratos e atendimento.

## Recursos implementados
- Login com sessão e token persistido no MySQL, renovado a cada autenticação.
- Proteção das páginas internas e encerramento de sessão.
- Painel com total de clientes, assinaturas ativas, chamados pendentes e receita mensal estimada.
- Pesquisa de empresas por nome ou e-mail.
- Consulta das assinaturas, seus planos, valores, datas e status.
- Cadastro de novas assinaturas com verificação de dados.
- Consulta e abertura de chamados vinculados às empresas.
- Consultas com `PreparedStatement` e proteção CSRF nos formulários que alteram dados.
- Interface CSS original, responsiva e distinta da aplicação usada como referência.

**Observação:** o token autentica o acesso ao painel; **não** foi implementada uma cobrança real nem uma integração com meios de pagamento.

## Tecnologias
- Ubuntu Server 24.04 / VMware
- Java e Apache Tomcat 10
- JSP, HTML e CSS
- MySQL Server 8.x e MySQL Connector/J (JDBC)
- SQL com chaves estrangeiras, `JOIN`, `COUNT` e `SUM`

## Arquitetura
```text
Navegador Windows
       |
       | HTTP :8080/mini
       v
VM Ubuntu Server (Tomcat 10 / arquivos JSP)
       |
       | JDBC em localhost:3306
       v
MySQL (mesma VM Ubuntu)
```

O projeto atual mantém MySQL na VM, **não** exige instalar SQL Server no Windows.

## Estrutura
```text
app/
  index.jsp                  login
  login.jsp                  autenticacao e token de sessao
  home.jsp                   dashboard com indicadores
  clientes.jsp               busca de empresas
  assinaturas.jsp            consulta de contratos
  nova_assinatura.jsp        formulario de novo contrato
  salvar_assinatura.jsp      grava novo contrato
  chamados.jsp               consulta de suporte
  novo_chamado.jsp           formulario de novo chamado
  salvar_chamado.jsp         grava chamado
  logout.jsp                 revoga token e encerra sessao
  estilo.css                 interface propria
  WEB-INF/
    conexao.jspf             conexao JDBC e formatadores
    protecao.jspf            protecao de pagina e CSRF
    web.xml                  configuracao da aplicacao
schema.sql                   banco para uma instalacao nova
migrations/
  001_login_token.sql        tabela de login e funcao iniciais
  002_painel_gestao.sql      permite logout e gravacao pelo sistema
tomcat/
  mini.xml                   publicacao da aplicacao em /mini
docs/
  testes.md                  cenarios de validacao
```

## Instalação na VM já usada no projeto

### 1. Obter esta branch
Use a branch `feature/painel-gestao-assinaturas`. Ela contém a nova aplicação e **não altera a main**.

Se o repositório já existe na VM (ajuste o caminho da pasta caso seja diferente):
```bash
cd ~/projeto-saas-git
git status
git fetch origin
git switch --track origin/feature/painel-gestao-assinaturas
```
Se já estiver na branch, execute `git pull origin feature/painel-gestao-assinaturas`. Se existirem mudanças locais, preserve-as antes de mudar de branch.

### 2. Fazer backup do banco
```bash
sudo mysqldump --routines saas_assinaturas > ~/backup_saas_antes_painel.sql
```
Não apague nem recrie o banco.

### 3. Aplicar migrações
Se sua VM **ainda não possui a tabela `login`** e a função `gera_token()`, execute:
```bash
sudo mysql saas_assinaturas < migrations/001_login_token.sql
```
Depois, em todos os casos, execute:
```bash
sudo mysql saas_assinaturas < migrations/002_painel_gestao.sql
```
O script 002 permite invalidar o token após logout, atualiza a função de token e concede ao usuário JDBC somente os privilégios necessários. O usuário `saas_user` deve existir antes de executar esse script. Os privilégios pressupõem uma conexão MySQL local na VM.

Em instalação totalmente nova, execute `sudo mysql < schema.sql` e depois o script `002_painel_gestao.sql`; não é necessário executar o 001 após o schema completo.

### 4. Configurar as credenciais do banco no Tomcat
Evite salvar a senha real no GitHub. A aplicação lê estas variáveis:
- `SAAS_DB_URL` (padrão `jdbc:mysql://localhost:3306/saas_assinaturas`)
- `SAAS_DB_USER` (padrão `saas_user`)
- `SAAS_DB_PASSWORD` (**obrigatória**)

Crie um arquivo de ambiente protegido:
```bash
sudo mkdir -p /etc/saas
sudo nano /etc/saas/saas.env
```
Conteúdo ilustrativo (substitua a senha):
```ini
SAAS_DB_URL=jdbc:mysql://localhost:3306/saas_assinaturas
SAAS_DB_USER=saas_user
SAAS_DB_PASSWORD=SENHA_REAL_DO_USUARIO_MYSQL
```
Proteja-o e configure o serviço:
```bash
sudo chown root:root /etc/saas/saas.env
sudo chmod 600 /etc/saas/saas.env
sudo mkdir -p /etc/systemd/system/tomcat10.service.d
sudo nano /etc/systemd/system/tomcat10.service.d/saas.conf
```
Conteúdo:
```ini
[Service]
EnvironmentFile=/etc/saas/saas.env
```
Depois execute `sudo systemctl daemon-reload`.

### 5. Publicar no Tomcat
Se necessário, instale `default-jdk`, `tomcat10` e o arquivo `mysql-connector-j-8.4.0.jar` em `/usr/share/tomcat10/lib/`, conforme o histórico do projeto.

```bash
sudo mkdir -p /opt/tomcat10/mini_saas
sudo cp app/*.jsp app/*.css /opt/tomcat10/mini_saas/
sudo cp -r app/WEB-INF /opt/tomcat10/mini_saas/
sudo chmod -R a+rX /opt/tomcat10/mini_saas

sudo mkdir -p /var/lib/tomcat10/conf/Catalina/localhost
sudo cp tomcat/mini.xml /var/lib/tomcat10/conf/Catalina/localhost/mini.xml

sudo systemctl restart tomcat10
sudo systemctl status tomcat10 --no-pager
```

Abra no Windows:
```text
http://IP_DA_VM:8080/mini/
```

Login didático: `admin` / `123456`.

### 6. Verificação
Os testes de sucesso, insucesso, acesso direto não autorizado e gravação estão descritos em [docs/testes.md](docs/testes.md).

Em caso de erro HTTP 500:
```bash
sudo journalctl -u tomcat10 -n 80 --no-pager
```

## Modelagem do banco
- `clientes`: empresa, e-mail, data de cadastro.
- `planos`: nome, mensalidade e limite de usuários.
- `assinaturas`: empresa, plano, data de início e status.
- `chamados`: empresa, assunto, data de abertura e resolução.
- `login`: usuário, hash de senha e token ativo.
- `usuarios`: tabela anterior, preservada para compatibilidade.

## Limitações didáticas e segurança
- A senha `admin/123456` e o hash MD5 são mantidos apenas para compatibilidade com o exemplo acadêmico. Em um sistema real, use Argon2id, bcrypt ou scrypt e HTTPS.
- A receita estimada soma as mensalidades das assinaturas ativas; não representa faturamento efetivamente cobrado.
- A implementação foi preparada no repositório, **mas ainda não foi executada na VM nem testada em MySQL/Tomcat reais**.
- Não coloque arquivos de configuração com senhas reais no repositório.

## Autores do projeto
- Davi Sarrassini
- Kauan Pereira Taborda
- Enzo Panassol Zapparolli
- Luis Felipe de Souza Oliveira
- João Vitor Fogaça Rocha

## Referência de aprendizagem
A organização didática segue o tema e os requisitos da disciplina. O projeto de uma academia enviado como referência foi analisado para entender a separação de telas, autenticação e operações com banco; a solução de gestão de assinaturas e seu código foram implementados especificamente para este repositório.
