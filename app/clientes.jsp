<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
request.setCharacterEncoding("UTF-8");
String filtro = request.getParameter("busca");
if (filtro == null) filtro = "";
if (filtro.length()>100) filtro = filtro.substring(0,100);
%>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Clientes | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="assinaturas.jsp">Assinaturas</a><a href="chamados.jsp">Chamados</a><form method="post" action="logout.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>"><button type="submit">Sair</button></form></nav></div></header>
<main class="layout"><div class="row"><div><p class="eyebrow">Relacionamento</p><h1>Clientes</h1><p>Encontre empresas cadastradas e consulte suas assinaturas.</p></div><a class="button" href="novo_cliente.jsp">Cadastrar cliente</a></div>
<%if("1".equals(request.getParameter("ok"))){%><div class="notice">Cliente cadastrado com sucesso.</div><%}%>
<div class="panel"><form method="get"><div class="field"><label for="busca">Buscar empresa ou e-mail</label><input id="busca" name="busca" value="<%=escapar(filtro)%>" maxlength="100"></div><button type="submit">Pesquisar</button></form></div>
<div class="panel"><h2>Empresas cadastradas</h2><table><thead><tr><th>Empresa</th><th>E-mail</th><th>Cadastro</th><th>Assinaturas ativas</th></tr></thead><tbody>
<%
try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement(
    "SELECT c.empresa,c.email,c.data_cadastro,COUNT(a.id) AS qtd " +
    "FROM clientes c LEFT JOIN assinaturas a ON a.cliente_id=c.id AND a.status='ativa' " +
    "WHERE c.empresa LIKE ? OR c.email LIKE ? " +
    "GROUP BY c.id,c.empresa,c.email,c.data_cadastro ORDER BY c.empresa")) {
    ps.setString(1,"%"+filtro+"%");ps.setString(2,"%"+filtro+"%");
    try(ResultSet rs=ps.executeQuery()) {
        while(rs.next()) {
%><tr><td><%=escapar(rs.getString("empresa"))%></td><td><%=escapar(rs.getString("email"))%></td><td><%=rs.getDate("data_cadastro")%></td><td><%=rs.getInt("qtd")%></td></tr><%
        }
    }
} catch(Exception e){application.log("Erro clientes",e);%><tr><td colspan="4">Não foi possível carregar os clientes.</td></tr><%}
%>
</tbody></table></div></main></body></html>
