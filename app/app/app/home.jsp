<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" %>
<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("index.jsp");
    return;
}
%>
<html>
    <body>
        <h2>Bem-vindo, <%= session.getAttribute("usuario") %>!</h2>
        <a href="logout.jsp">Sair</a>
    </body>
</html>
