# Projeto SaaS - Gestão de Assinaturas

Projeto da disciplina de SaaS Infrastructure. Implementa o banco de dados de uma plataforma SaaS fictícia (clientes, planos, assinaturas e chamados de suporte) em MySQL, com uma aplicação web JSP de autenticação por sessão e token, executada em Apache Tomcat 10 em uma VM Ubuntu no VMware.

## Ambiente
- VMware Workstation
- Ubuntu 24.04
- MySQL Server 8.x
- Apache Tomcat 10 + Java (default-jdk)
- Driver JDBC: mysql-connector-j 8.4.0

## Estrutura do repositório
- `schema.sql`: criação do banco, tabelas, função de token e dados de exemplo
- `migrations/001_login_token.sql`: adiciona tabela `login` e função de token a um banco já existente
- `app/`: aplicação web (JSP)
  - `index.jsp`: formulário de login
  - `login.jsp`: valida usuário e senha, recupera token e cria sessão
  - `home.jsp`: página protegida por sessão
  - `logout.jsp`: encerra a sessão
- `tomcat/mini.xml`: descritor de contexto do Tomcat para publicar a aplicação em `/mini`

## Estrutura do banco
- `planos`: planos oferecidos (Básico, Profissional, Enterprise)
- `clientes`: empresas que contratam o serviço
- `assinaturas`: liga um cliente a um plano, com status
- `chamados`: tickets de suporte
- `usuarios`: tabela da primeira versão, mantida para compatibilidade
- `login`: credenciais de acesso e token gerado pela função `gera_token()`

O usuário didático de teste é `admin`, senha `123456`. A senha da tabela `login` usa MD5 para acompanhar o formato do exemplo do professor. MD5 não é adequado para armazenar senhas em sistemas reais.

## Como executar

### 1. Banco de dados — instalação nova
```bash
sudo apt update
sudo apt install mysql-server git -y
git clone https://github.com/Sarrassini/projeto-saas.git
cd projeto-saas
sudo mysql < schema.sql
```

Crie o usuário de conexão (substitua a senha de exemplo por uma senha definida por você):
```bash
sudo mysql -e "CREATE USER 'saas_user'@'localhost' IDENTIFIED BY 'TroqueEstaSenha';"
sudo mysql -e "GRANT SELECT ON saas_assinaturas.* TO 'saas_user'@'localhost'; FLUSH PRIVILEGES;"
```

### 2. Banco de dados — VM que já possui o banco
Não apague nem recrie o banco existente. Execute somente a migração:
```bash
sudo mysql saas_assinaturas < migrations/001_login_token.sql
```
A migração adiciona a tabela `login`, a função `gera_token()` e o usuário didático se ele ainda não existir. Ela não apaga as tabelas existentes.

### 3. Tomcat e driver
```bash
sudo apt install default-jdk tomcat10 -y
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar
sudo cp mysql-connector-j-8.4.0.jar /usr/share/tomcat10/lib/
```

### 4. Publicar a aplicação
A aplicação fica fora de `webapps`; `tomcat/mini.xml` informa ao Tomcat onde estão os JSPs e publica o contexto em `/mini`.
```bash
sudo mkdir -p /opt/tomcat10/mini_saas
sudo cp app/*.jsp /opt/tomcat10/mini_saas/
sudo chmod -R a+rX /opt/tomcat10/mini_saas

sudo mkdir -p /var/lib/tomcat10/conf/Catalina/localhost
sudo cp tomcat/mini.xml /var/lib/tomcat10/conf/Catalina/localhost/mini.xml
sudo systemctl restart tomcat10
```

### 5. Acessar
No navegador: `http://IP_DA_VM:8080/mini/index.jsp`

Login de teste: `admin` / `123456`

## Evidências
Consulta de verificação:
```sql
SELECT c.empresa, p.nome AS plano, a.status
FROM assinaturas a
JOIN clientes c ON c.id = a.cliente_id
JOIN planos p ON p.id = a.plano_id;
```
Resultado esperado: Padaria Pao Quente (Basico), TechNova Ltda (Profissional) e Clinica Vida (Enterprise), todas com status `ativa`.

## Observações
- `TroqueEstaSenha` é apenas um valor de exemplo para o usuário MySQL.
- O login `admin` / `123456` é apenas para fins didáticos.
- Para sistemas reais, substitua MD5 por Argon2id, bcrypt ou scrypt.

## Autores
- Davi Sarrassini
- Kauan Pereira Taborda
- Enzo Panassol Zapparolli
- Luis Felipe de Souza Oliveira
- João Vitor Fogaça Rocha
