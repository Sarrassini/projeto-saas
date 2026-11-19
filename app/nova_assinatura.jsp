<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Nova assinatura | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="assinaturas.jsp">Assinaturas</a><a href="chamados.jsp">Chamados</a></nav></div></header>
<main class="layout"><p class="eyebrow">Contratos</p><h1>Nova assinatura</h1><p>Vincule um plano a uma empresa cadastrada.</p>
<%if("1".equals(request.getParameter("erro"))){%><div class="notice error">Não foi possível registrar. Confira os dados e tente novamente.</div><%}%>
<div class="panel"><form method="post" action="salvar_assinatura.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>">
<div class="field"><label for="cliente">Cliente</label><select name="cliente_id" id="cliente" required><option value="">Selecione</option>
<%try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement("SELECT id,empresa FROM clientes ORDER BY empresa");ResultSet rs=ps.executeQuery()){
while(rs.next()){%><option value="<%=rs.getInt("id")%>"><%=escapar(rs.getString("empresa"))%></option><%}
}catch(Exception e){application.log("Erro clientes formulario",e);}%>
</select></div><div class="field"><label for="plano">Plano</label><select name="plano_id" id="plano" required><option value="">Selecione</option>
<%try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement("SELECT id,nome,preco_mensal FROM planos ORDER BY preco_mensal");ResultSet rs=ps.executeQuery()){
while(rs.next()){%><option value="<%=rs.getInt("id")%>"><%=escapar(rs.getString("nome"))%> — <%=moeda(rs.getBigDecimal("preco_mensal"))%></option><%}
}catch(Exception e){application.log("Erro planos formulario",e);}%>
</select></div><div class="field"><label for="data_inicio">Início</label><input type="date" id="data_inicio" name="data_inicio" value="<%=java.time.LocalDate.now()%>" required></div>
<button type="submit">Salvar assinatura</button> <a class="button secondary" href="assinaturas.jsp">Cancelar</a></form></div></main></body></html>
