<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" %>
<%
if (session.getAttribute("usuario") == null || session.getAttribute("token") == null) {
    response.sendRedirect("index.jsp");
    return;
}
%>
<html>
    <head>
        <title>Mini SaaS</title>
    </head>
    <body>
        <h2>Bem-vindo, <%= session.getAttribute("usuario") %>!</h2>
        <p>Sessao autenticada com token.</p>
        <a href="logout.jsp">Sair</a>
    </body>
</html>
