<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendError(405);
    return;
}

request.setCharacterEncoding("UTF-8");
String csrfEnviado = request.getParameter("csrf");

if (csrfEnviado == null || !csrfEnviado.equals(csrfSessao)) {
    response.sendError(403);
    return;
}

String empresa = request.getParameter("empresa");
String email = request.getParameter("email");

if (empresa == null || email == null) {
    response.sendRedirect("novo_cliente.jsp?erro=dados");
    return;
}

empresa = empresa.trim();
email = email.trim().toLowerCase(java.util.Locale.ROOT);

if (empresa.length() < 2 || empresa.length() > 100 ||
    email.length() > 100 ||
    !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
    response.sendRedirect("novo_cliente.jsp?erro=dados");
    return;
}

try (
    Connection c = abrirBanco();
    PreparedStatement ps = c.prepareStatement(
        "INSERT INTO clientes (empresa, email, data_cadastro) " +
        "VALUES (?, ?, CURRENT_DATE())"
    )
) {
    ps.setString(1, empresa);
    ps.setString(2, email);
    ps.executeUpdate();

} catch (SQLException erro) {
    if (erro.getErrorCode() == 1062) {
        response.sendRedirect("novo_cliente.jsp?erro=duplicado");
        return;
    }

    application.log("Erro ao cadastrar cliente", erro);
    response.sendRedirect("novo_cliente.jsp?erro=1");
    return;

} catch (Exception erro) {
    application.log("Erro ao cadastrar cliente", erro);
    response.sendRedirect("novo_cliente.jsp?erro=1");
    return;
}

response.sendRedirect("clientes.jsp?ok=1");
%>
