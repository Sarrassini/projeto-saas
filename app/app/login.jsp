<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");
String user = request.getParameter("user");
String pass = request.getParameter("pass");
boolean ok = false;

if (user != null && pass != null) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection c = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/saas_assinaturas", "saas_user", "TroqueEstaSenha");
             PreparedStatement ps = c.prepareStatement(
                "SELECT id FROM usuarios WHERE login = ? AND senha = SHA2(?, 256)")) {
            ps.setString(1, user);
            ps.setString(2, pass);
            try (ResultSet rs = ps.executeQuery()) { ok = rs.next(); }
        }
    } catch (Exception e) {
        out.println("Erro de conexao: " + e.getMessage());
        return;
    }
}

if (ok) {
    session.setAttribute("usuario", user);
    response.sendRedirect("home.jsp");
} else {
    response.sendRedirect("index.jsp?erro=1");
}
%>
