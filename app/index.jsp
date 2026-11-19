<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
response.setHeader("Cache-Control","no-store");
if (session.getAttribute("usuario") != null) {
    response.sendRedirect("home.jsp");
    return;
}
%>
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Entrar | Gestão SaaS</title><link rel="stylesheet" href="estilo.css"></head>
<body><div class="auth"><div class="panel"><p class="eyebrow">Plataforma de assinaturas</p><h1>Gestão SaaS</h1>
<p>Entre com sua conta para consultar contratos, empresas e solicitações de suporte.</p>
<% if ("1".equals(request.getParameter("erro"))) { %><div class="notice error">Usuário ou senha incorretos.</div><% } %>
<form method="post" action="login.jsp">
<div class="field"><label for="user">Usuário</label><input id="user" name="user" required maxlength="50" autocomplete="username"></div>
<div class="field"><label for="password">Senha</label><input type="password" id="password" name="password" required autocomplete="current-password"></div>
<button type="submit">Acessar painel</button></form></div>
<p class="footer">Projeto acadêmico • Sistemas de Informação</p></div></body></html>
