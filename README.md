# Gestão SaaS — Plataforma de Assinaturas

Projeto acadêmico da disciplina **SaaS Infrastructure**, desenvolvido para simular a gestão de serviços por assinatura, com foco em infraestrutura Linux, banco de dados relacional e operações web.

## Proposta

A aplicação ajuda uma empresa fictícia provedora de software a acompanhar seus **clientes**, **planos contratados**, **assinaturas** e **chamados de suporte**. O domínio do projeto é a gestão de contratos e atendimento de empresas.

## Funcionalidades implementadas

- Login administrativo com sessão e token persistido no MySQL.
- Proteção das páginas internas e encerramento de sessão (logout).
- Painel com total de clientes, assinaturas ativas, chamados pendentes e receita mensal estimada.
- Pesquisa de empresas por nome ou e-mail.
- Consulta de assinaturas, planos, valores, datas e status.
- Cadastro de novas assinaturas.
- Consulta e abertura de chamados vinculados às empresas.
- Consultas SQL com `PreparedStatement` e proteção CSRF nos formulários que alteram dados.
- Interface CSS responsiva e própria.

**Limitações funcionais atuais:** não há tela/ação para marcar um chamado como resolvido; o módulo permite consultar e abrir chamados. Também não há cobrança real nem integração com meios de pagamento.

## Tecnologias

- Ubuntu Server em máquina virtual.
- Java / OpenJDK (ambiente validado: 26.0.2).
- Apache Tomcat 10 (ambiente validado: 10.1.55).
- JSP, HTML e CSS.
- MySQL Server e MySQL Connector/J (na VM validada: Connector/J 26.7.0).

## Arquitetura

```text
Navegador no computador host
          |
          | HTTP :8080/mini
          v
Máquina virtual Ubuntu
  Apache Tomcat 10 / JSP
          |
          | JDBC em localhost:3306
          v
       MySQL Server
```

A aplicação foi implantada e testada em uma VM acessada pela rede local. **Isso não equivale a uma hospedagem pública em nuvem**: para disponibilizá-la na internet seriam necessários, entre outros itens, um servidor público, regras de rede/firewall, domínio e HTTPS.

## Estrutura do projeto

```text
app/
  index.jsp                  tela de login
  login.jsp                  autenticação e token de sessão
  home.jsp                   painel com indicadores
  clientes.jsp               pesquisa de empresas
  assinaturas.jsp            consulta de assinaturas
  nova_assinatura.jsp        formulário de nova assinatura
  salvar_assinatura.jsp      gravação de assinatura
  chamados.jsp               consulta de chamados
  novo_chamado.jsp           formulário de novo chamado
  salvar_chamado.jsp         gravação de chamado
  logout.jsp                 revogação do token e encerramento da sessão
  estilo.css                 estilos da interface
  WEB-INF/
    conexao.jspf              conexão JDBC e utilitários
    protecao.jspf             proteção de páginas e token CSRF
    web.xml                   configuração da aplicação
schema.sql                    banco para instalação nova
migrations/
  001_login_token.sql         estrutura inicial de autenticação
  002_painel_gestao.sql        ajustes de autenticação e permissões
tomcat/
  mini.xml                    publicação da aplicação no contexto /mini
docs/
  testes.md                   cenários e resultados de validação
.gitignore                    arquivos locais que não devem ir ao Git
```

## Instalação e atualização na VM

Os comandos abaixo descrevem a implantação usada neste projeto. Ajuste caminhos e versões caso seu ambiente seja diferente.

### 1. Atualizar o repositório

A branch principal do projeto é `main`.

Se o repositório já existe na VM:

```bash
cd ~/projeto-saas-git
git switch main
git pull origin main
```

Se ainda não existe:

```bash
git clone https://github.com/Sarrassini/projeto-saas.git
cd projeto-saas
```

### 2. Fazer backup do banco

Antes de aplicar alterações de estrutura:

```bash
sudo mysqldump --routines saas_assinaturas > ~/backup_saas_antes_painel.sql
```

Não apague nem recrie o banco existente para atualizar a aplicação.

### 3. Aplicar as migrações

O usuário `saas_user` deve existir antes da migração 002.

Se a VM ainda não possui a tabela `login` e a função `gera_token()`, execute:

```bash
sudo mysql saas_assinaturas < migrations/001_login_token.sql
```

Depois, execute:

```bash
sudo mysql saas_assinaturas < migrations/002_painel_gestao.sql
```

Em uma instalação totalmente nova, use `sudo mysql < schema.sql` e depois a migração 002. Não execute a migração 001 depois do schema completo.

### 4. Configurar as credenciais do banco

A senha real do banco não deve ser salva no GitHub. A aplicação lê as variáveis:

- `SAAS_DB_URL` (padrão: `jdbc:mysql://localhost:3306/saas_assinaturas`)
- `SAAS_DB_USER` (padrão: `saas_user`)
- `SAAS_DB_PASSWORD` (obrigatória)

Crie o arquivo de ambiente protegido:

```bash
sudo mkdir -p /etc/saas
sudo nano /etc/saas/saas.env
```

Conteúdo ilustrativo; substitua o valor de exemplo pela senha configurada no MySQL:

```ini
SAAS_DB_URL=jdbc:mysql://localhost:3306/saas_assinaturas
SAAS_DB_USER=saas_user
SAAS_DB_PASSWORD=SUBSTITUA_PELA_SENHA_DO_MYSQL
```

Proteja o arquivo:

```bash
sudo chown root:root /etc/saas/saas.env
sudo chmod 600 /etc/saas/saas.env
```

Configure o serviço Tomcat para ler o arquivo:

```bash
sudo mkdir -p /etc/systemd/system/tomcat10.service.d
sudo nano /etc/systemd/system/tomcat10.service.d/saas.conf
```

Conteúdo:

```ini
[Service]
EnvironmentFile=/etc/saas/saas.env
```

Aplique a configuração:

```bash
sudo systemctl daemon-reload
```

### 5. Driver JDBC e publicação no Tomcat

Instale uma versão compatível do MySQL Connector/J e disponibilize o arquivo JAR no diretório de bibliotecas do Tomcat. Na VM validada, o pacote instalado foi o Connector/J 26.7.0.

Publique os arquivos da aplicação:

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

Acesse pelo navegador do computador host:

```text
http://IP_DA_VM:8080/mini/
```

Substitua `IP_DA_VM` pelo endereço atual da interface de rede da VM.

**Credencial didática inicial:** usuário `admin`, senha `123456`.

### 6. Verificação e logs

Os testes e os resultados observados estão em [docs/testes.md](docs/testes.md).

Para consultar os logs do Tomcat:

```bash
sudo journalctl -u tomcat10 -n 80 --no-pager
```

## Modelagem do banco

- `clientes`: empresa, e-mail e data de cadastro.
- `planos`: nome, mensalidade e limite de usuários.
- `assinaturas`: empresa, plano, data de início e status.
- `chamados`: empresa, assunto, data de abertura e situação de resolução.
- `login`: usuário, hash de senha e token de autenticação.
- `usuarios`: tabela anterior, mantida para compatibilidade com a primeira versão.

## Validação na VM

Em **25/11/2026**, a aplicação foi validada manualmente na VM. Os testes confirmados incluíram login administrativo, pesquisa de clientes por e-mail, consulta e cadastro de assinaturas, consulta e abertura de chamados, atualização dos indicadores do painel e logout.

Após os cadastros de teste, o painel apresentou:

| Indicador | Resultado observado |
|---|---:|
| Empresas cadastradas | 3 |
| Assinaturas ativas | 4 |
| Chamados pendentes | 2 |
| Receita mensal estimada | R$ 849,60 |

Os testes negativos de autenticação, CSRF e acesso direto às páginas internas ainda precisam ser executados separadamente. A lista completa está em [docs/testes.md](docs/testes.md).

## Segurança e limitações didáticas

- A credencial `admin/123456` e o hash MD5 são mantidos apenas para compatibilidade com o exercício acadêmico. Não são adequados para produção; um sistema real deve usar Argon2id, bcrypt ou scrypt, além de HTTPS.
- A receita exibida é uma estimativa calculada pela soma das mensalidades das assinaturas ativas; não representa pagamentos efetivamente recebidos.
- A VM está acessível pela rede local. O projeto não está publicado em uma nuvem pública.
- Não coloque senhas, tokens, backups do banco ou arquivos de ambiente no repositório.

## Integrantes

- Davi Sarrassini
- Kauan Pereira Taborda
- Enzo Panassol Zapparolli
- Luis Felipe de Souza Oliveira
- João Vitor Fogaça Rocha

## Referência de aprendizagem

A organização didática considera os requisitos da disciplina. O projeto de academia fornecido como referência foi utilizado para compreender a separação de telas, autenticação e operações com banco; o domínio de gestão de assinaturas e a implementação deste repositório foram desenvolvidos para este projeto.
