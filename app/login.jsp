<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");

String user = request.getParameter("user");
String password = request.getParameter("password");
String token = null;

if (user != null && password != null) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection c = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/saas_assinaturas",
                "saas_user",
                "TroqueEstaSenha");
             PreparedStatement ps = c.prepareStatement(
                "SELECT token FROM login WHERE `user` = ? AND `password` = MD5(?)")) {

            ps.setString(1, user);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    token = rs.getString("token");
                }
            }
        }
    } catch (Exception e) {
        application.log("Erro ao autenticar usuario no banco de dados.", e);
        response.sendError(500, "Erro ao autenticar. Consulte o log do Tomcat.");
        return;
    }
}

if (token != null) {
    session.setAttribute("usuario", user);
    session.setAttribute("token", token);
    response.sendRedirect("home.jsp");
} else {
    response.sendRedirect("index.jsp?erro=1");
}
%>
