<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
String erro = request.getParameter("erro");
%>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Cadastrar cliente | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head><body>
<header class="topbar"><div class="layout"><a class="brand" href="home.jsp">Gestão SaaS</a><nav class="menu"><a href="home.jsp">Painel</a><a href="clientes.jsp">Clientes</a><a href="assinaturas.jsp">Assinaturas</a><a href="chamados.jsp">Chamados</a><form method="post" action="logout.jsp"><input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>"><button type="submit">Sair</button></form></nav></div></header>
<main class="layout"><p class="eyebrow">Relacionamento</p><h1>Cadastrar cliente</h1><p>Adicione uma nova empresa à base do Gestão SaaS.</p>
<%if("duplicado".equals(erro)){%><div class="notice error">Já existe um cliente cadastrado com esse e-mail. Confira o endereço informado.</div><%}else if("dados".equals(erro)){%><div class="notice error">Preencha o nome da empresa e informe um e-mail válido.</div><%}else if("1".equals(erro)){%><div class="notice error">Não foi possível cadastrar o cliente. Tente novamente.</div><%}%>
<div class="panel"><form method="post" action="salvar_cliente.jsp">
<input type="hidden" name="csrf" value="<%=escapar(csrfSessao)%>">
<div class="field"><label for="empresa">Nome da empresa</label><input type="text" name="empresa" id="empresa" minlength="2" maxlength="100" autocomplete="organization" required placeholder="Ex.: Aurora Tecnologia Ltda"></div>
<div class="field"><label for="email">E-mail corporativo</label><input type="email" name="email" id="email" maxlength="100" autocomplete="email" required placeholder="Ex.: contato@empresa.com"></div>
<p class="sub">A data de cadastro será preenchida automaticamente pelo sistema.</p>
<button type="submit">Cadastrar cliente</button> <a class="button secondary" href="clientes.jsp">Cancelar</a>
</form></div></main></body></html>
