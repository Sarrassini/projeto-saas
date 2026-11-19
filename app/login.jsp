<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%
response.setHeader("Cache-Control", "no-store");
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("index.jsp"); return;
}
request.setCharacterEncoding("UTF-8");
String loginInformado = request.getParameter("user");
String senhaInformada = request.getParameter("password");
if (loginInformado == null || loginInformado.trim().isEmpty() ||
    senhaInformada == null || senhaInformada.isEmpty()) {
    response.sendRedirect("index.jsp?erro=1"); return;
}
String novoToken = null;
try (Connection conexaoLogin = abrirBanco()) {
    conexaoLogin.setAutoCommit(false);
    try {
        int usuarioId = -1;
        try (PreparedStatement ps = conexaoLogin.prepareStatement(
                "SELECT id FROM login WHERE `user` = ? AND `password` = MD5(?) FOR UPDATE")) {
            ps.setString(1, loginInformado.trim());
            ps.setString(2, senhaInformada);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) usuarioId = rs.getInt("id");
            }
        }
        if (usuarioId >= 0) {
            try (PreparedStatement ps = conexaoLogin.prepareStatement(
                    "UPDATE login SET token = gera_token() WHERE id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conexaoLogin.prepareStatement(
                    "SELECT token FROM login WHERE id = ?")) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) novoToken = rs.getString("token");
                }
            }
        }
        conexaoLogin.commit();
    } catch (Exception erro) {
        conexaoLogin.rollback();
        throw erro;
    }
} catch (Exception erro) {
    application.log("Falha na autenticacao.", erro);
    response.sendError(500, "Falha interna na autenticacao. Consulte o Tomcat.");
    return;
}
if (novoToken == null) {
    response.sendRedirect("index.jsp?erro=1"); return;
}
session.invalidate();
javax.servlet.http.HttpSession novaSessao = request.getSession(true);
novaSessao.setAttribute("usuario", loginInformado.trim());
novaSessao.setAttribute("token", novoToken);
novaSessao.setAttribute("csrf", java.util.UUID.randomUUID().toString());
response.sendRedirect("home.jsp");
%>
