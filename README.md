# projeto-saas
Banco de dados MySQL de gestão de assinaturas SaaS - disciplina SaaS Infrastructure

# Projeto SaaS - Gestão de Assinaturas em MySQL

Projeto da disciplina de SaaS Infrastructure. Implementa o banco de dados
de uma plataforma SaaS fictícia (clientes, planos, assinaturas e chamados
de suporte) em MySQL, rodando em uma VM Ubuntu no VMware.

## Ambiente
- VMware Workstation
- Ubuntu (versão: 24.04)
- MySQL Server 8.x

## Estrutura do banco
- `planos`: planos oferecidos (Básico, Profissional, Enterprise)
- `clientes`: empresas que contratam o serviço
- `assinaturas`: liga um cliente a um plano, com status (ativa, cancelada, suspensa)
- `chamados`: tickets de suporte abertos pelos clientes

## Como executar
1. Instalar o MySQL:
```bash
   sudo apt update && sudo apt install mysql-server -y
```
2. Clonar o repositório:
```bash
   git clone https://github.com/Sarrassini/projeto-saas.git
   cd projeto-saas
```
3. Executar o script:
```bash
   sudo mysql < schema.sql
```
4. Verificar:
```bash
   sudo mysql -e "USE saas_assinaturas; SHOW TABLES;"
```

## Evidência
Consulta de verificação executada na VM:

```sql
SELECT c.empresa, p.nome AS plano, a.status
FROM assinaturas a
JOIN clientes c ON c.id = a.cliente_id
JOIN planos p ON p.id = a.plano_id;
```

Resultado: Padaria Pao Quente (Basico), TechNova Ltda (Profissional) e Clinica Vida (Enterprise), todas com status `ativa`.

## Autores
- Davi Sarrassini
