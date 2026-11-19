<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Abrir chamado | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="clientes.jsp">Clientes</a><a href="assinaturas.jsp">Assinaturas</a><a href="chamados.jsp">Chamados</a></nav></div></header>
<main class="layout"><p class="eyebrow">Atendimento</p><h1>Abrir chamado</h1><p>Registre uma nova solicitação de suporte vinculada a uma empresa.</p>
<%if("1".equals(request.getParameter("erro"))){%><div class="notice error">Não foi possível registrar. Confira os dados.</div><%}%>
<div class="panel"><form method="post" action="salvar_chamado.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>">
<div class="field"><label for="cliente">Empresa</label><select name="cliente_id" id="cliente" required><option value="">Selecione</option>
<%try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement("SELECT id,empresa FROM clientes ORDER BY empresa");ResultSet rs=ps.executeQuery()){
while(rs.next()){%><option value="<%=rs.getInt("id")%>"><%=escapar(rs.getString("empresa"))%></option><%}
}catch(Exception e){application.log("Erro formulario chamado",e);}%>
</select></div>
<div class="field"><label for="assunto">Assunto</label><input name="assunto" id="assunto" minlength="5" maxlength="150" required placeholder="Ex.: Dúvida sobre cobrança"></div>
<button type="submit">Registrar chamado</button> <a class="button secondary" href="chamados.jsp">Cancelar</a>
</form></div></main></body></html>
