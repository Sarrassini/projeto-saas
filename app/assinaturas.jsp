<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Assinaturas | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="clientes.jsp">Clientes</a><a href="chamados.jsp">Chamados</a><form method="post" action="logout.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>"><button type="submit">Sair</button></form></nav></div></header>
<main class="layout"><div class="row"><div><p class="eyebrow">Contratos</p><h1>Assinaturas</h1><p>Planos contratados por empresa e situação atual.</p></div><a class="button" href="nova_assinatura.jsp">Novo contrato</a></div>
<% if("1".equals(request.getParameter("ok"))){%><div class="notice">Novo contrato cadastrado com sucesso.</div><%}%>
<% if("1".equals(request.getParameter("atualizada"))){%><div class="notice">Contrato existente atualizado com sucesso. Nenhum novo contrato foi criado.</div><%}%>
<div class="panel"><table><thead><tr><th>Empresa</th><th>Plano</th><th>Mensalidade</th><th>Início</th><th>Status</th></tr></thead><tbody>
<%
try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement(
    "SELECT c.empresa,p.nome,p.preco_mensal,a.data_inicio,a.status " +
    "FROM assinaturas a JOIN clientes c ON c.id=a.cliente_id " +
    "JOIN planos p ON p.id=a.plano_id ORDER BY a.data_inicio DESC,a.id DESC")) {
    try(ResultSet rs=ps.executeQuery()){
        while(rs.next()){
            String status=rs.getString("status");
%><tr><td><%=escapar(rs.getString("empresa"))%></td><td><%=escapar(rs.getString("nome"))%></td><td><%=moeda(rs.getBigDecimal("preco_mensal"))%></td><td><%=rs.getDate("data_inicio")%></td><td><span class="tag <%=escapar(status)%>"><%=escapar(status)%></span></td></tr><%
        }
    }
}catch(Exception e){application.log("Erro assinaturas",e);%><tr><td colspan="5">Não foi possível consultar as assinaturas.</td></tr><%}
%></tbody></table></div></main></body></html>
