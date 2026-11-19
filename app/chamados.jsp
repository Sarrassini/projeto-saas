<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Chamados | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="clientes.jsp">Clientes</a><a href="assinaturas.jsp">Assinaturas</a><form method="post" action="logout.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>"><button type="submit">Sair</button></form></nav></div></header>
<main class="layout"><div class="row"><div><p class="eyebrow">Atendimento</p><h1>Chamados de suporte</h1><p>Acompanhe as solicitações das empresas cadastradas.</p></div><a class="button" href="novo_chamado.jsp">Abrir chamado</a></div>
<%if("1".equals(request.getParameter("ok"))){%><div class="notice">Chamado aberto com sucesso.</div><%}%>
<div class="panel"><table><thead><tr><th>Empresa</th><th>Assunto</th><th>Abertura</th><th>Situação</th></tr></thead><tbody>
<%
try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement(
    "SELECT c.empresa,ch.assunto,ch.data_abertura,ch.resolvido " +
    "FROM chamados ch JOIN clientes c ON c.id=ch.cliente_id " +
    "ORDER BY ch.data_abertura DESC,ch.id DESC")) {
    try(ResultSet rs=ps.executeQuery()) {
        while(rs.next()){
          boolean resolvido=rs.getBoolean("resolvido");
%><tr><td><%=escapar(rs.getString("empresa"))%></td><td><%=escapar(rs.getString("assunto"))%></td><td><%=rs.getDate("data_abertura")%></td><td><span class="tag <%=resolvido?"":"suspensa"%>"><%=resolvido?"Resolvido":"Pendente"%></span></td></tr><%
        }
    }
}catch(Exception e){application.log("Erro ao listar chamados",e);%><tr><td colspan="4">Não foi possível carregar os chamados.</td></tr><%}
%></tbody></table></div></main></body></html>
