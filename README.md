# Projeto SaaS - Gestão de Assinaturas

Projeto da disciplina de SaaS Infrastructure. Implementa o banco de dados
de uma plataforma SaaS fictícia (clientes, planos, assinaturas e chamados
de suporte) em MySQL, com uma aplicação web de login com sessão rodando
em Apache Tomcat, em uma VM Ubuntu no VMware.

## Ambiente
- VMware Workstation
- Ubuntu 24.04
- MySQL Server 8.x
- Apache Tomcat 10 + Java (default-jdk)
- Driver JDBC: mysql-connector-j 8.4.0

## Estrutura do repositório
- `schema.sql`: criação do banco, tabelas e dados de exemplo
- `app/`: aplicação web (JSP)
  - `index.jsp`: formulário de login
  - `login.jsp`: valida usuário no MySQL e cria a sessão
  - `home.jsp`: página protegida (exige sessão)
  - `logout.jsp`: encerra a sessão

## Estrutura do banco
- `planos`: planos oferecidos (Básico, Profissional, Enterprise)
- `clientes`: empresas que contratam o serviço
- `assinaturas`: liga um cliente a um plano, com status
- `chamados`: tickets de suporte
- `usuarios`: usuários do login (senha armazenada com SHA-256)

## Como executar

### 1. Banco de dados
```bash
sudo apt update
sudo apt install mysql-server git -y
git clone https://github.com/Sarrassini/projeto-saas.git
cd projeto-saas
sudo mysql < schema.sql
```

Criar o usuário que a aplicação usa para conectar (troque a senha):
```bash
sudo mysql -e "CREATE USER 'saas_user'@'localhost' IDENTIFIED BY 'TroqueEstaSenha';"
sudo mysql -e "GRANT SELECT ON saas_assinaturas.* TO 'saas_user'@'localhost'; FLUSH PRIVILEGES;"
```

### 2. Tomcat e driver
```bash
sudo apt install default-jdk tomcat10 -y
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar
sudo cp mysql-connector-j-8.4.0.jar /usr/share/tomcat10/lib/
```

### 3. Publicar a aplicação
```bash
sudo mkdir -p /var/lib/tomcat10/webapps/saas
sudo cp app/*.jsp /var/lib/tomcat10/webapps/saas/
sudo systemctl restart tomcat10
```

### 4. Acessar
No navegador: `http://IP_DA_VM:8080/saas/index.jsp`

Login de teste: `admin` / `123456`

## Evidências
Consulta de verificação executada na VM:

```sql
SELECT c.empresa, p.nome AS plano, a.status
FROM assinaturas a
JOIN clientes c ON c.id = a.cliente_id
JOIN planos p ON p.id = a.plano_id;
```

Resultado: Padaria Pao Quente (Basico), TechNova Ltda (Profissional) e Clinica Vida (Enterprise), todas com status `ativa`.

## Observações
- A senha do `saas_user` no repositório é um valor de exemplo (`TroqueEstaSenha`).
- O login `admin` / `123456` é apenas para fins didáticos.

## Autores
- Davi Sarrassini
- Kauan Pereira Taborda
- Enzo Panassol Zapparolli
- Luis Felipe de Souza Oliveira
- João Vitor Fogaça Rocha
