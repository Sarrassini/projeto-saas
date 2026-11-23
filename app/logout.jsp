<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("home.jsp"); return;
}
String csrfEnviado = request.getParameter("csrf");
String csrfAtual = (String) session.getAttribute("csrf");
if (csrfAtual == null || !csrfAtual.equals(csrfEnviado)) {
    response.sendError(403, "Operacao nao autorizada."); return;
}
String tokenSair = (String) session.getAttribute("token");
if (tokenSair != null) {
    try (Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement(
            "UPDATE login SET token = NULL WHERE token = ?")) {
        ps.setString(1,tokenSair);ps.executeUpdate();
    } catch(Exception erro) {
        application.log("Erro ao revogar token de logout.",erro);
    }
}
session.invalidate();
response.sendRedirect("index.jsp");
%>
