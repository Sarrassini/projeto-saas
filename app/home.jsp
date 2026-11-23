<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
int totalClientes=0,totalAtivas=0,totalAbertos=0;
java.math.BigDecimal receitaEstimada=java.math.BigDecimal.ZERO;
try (Connection c=abrirBanco();
     PreparedStatement ps=c.prepareStatement(
       "SELECT (SELECT COUNT(*) FROM clientes) clientes, " +
       "(SELECT COUNT(*) FROM assinaturas WHERE status='ativa') ativas, " +
       "(SELECT COUNT(*) FROM chamados WHERE resolvido=FALSE) abertos, " +
       "(SELECT COALESCE(SUM(p.preco_mensal),0) FROM assinaturas a JOIN planos p ON p.id=a.plano_id WHERE a.status='ativa') receita")) {
   try(ResultSet rs=ps.executeQuery()) {
      if(rs.next()) {totalClientes=rs.getInt("clientes");totalAtivas=rs.getInt("ativas");totalAbertos=rs.getInt("abertos");receitaEstimada=rs.getBigDecimal("receita");}
   }
} catch(Exception e){application.log("Erro no painel",e);response.sendError(500,"Erro ao carregar o painel.");return;}
%>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Painel | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="clientes.jsp">Clientes</a><a href="assinaturas.jsp">Assinaturas</a><a href="chamados.jsp">Chamados</a><form method="post" action="logout.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>"><button type="submit">Sair</button></form></nav></div></header>
<main class="layout"><p class="eyebrow">Visão geral</p><h1>Olá, <%=escapar(usuarioSessao)%>!</h1><p>Acompanhe os principais indicadores da sua operação de assinaturas.</p>
<section class="cards"><div class="card"><div class="sub">Empresas cadastradas</div><div class="metric"><%=totalClientes%></div></div>
<div class="card"><div class="sub">Assinaturas ativas</div><div class="metric"><%=totalAtivas%></div></div>
<div class="card"><div class="sub">Chamados pendentes</div><div class="metric"><%=totalAbertos%></div></div>
<div class="card"><div class="sub">Receita mensal estimada</div><div class="metric"><%=moeda(receitaEstimada)%></div><div class="sub">Soma dos planos em assinaturas ativas</div></div></section>
<div class="panel"><h2>Ações rápidas</h2><div class="row"><a class="button" href="assinaturas.jsp">Gerenciar assinaturas</a><a class="button secondary" href="chamados.jsp">Ver suporte</a><a class="button secondary" href="clientes.jsp">Consultar clientes</a></div></div>
<p class="footer">Indicadores calculados a partir dos dados atuais do MySQL.</p></main></body></html>
