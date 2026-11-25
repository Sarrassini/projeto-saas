<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendError(405);
} else {
    request.setCharacterEncoding("UTF-8");

    String csrfEnviado = request.getParameter("csrf");

    if (csrfEnviado == null || !csrfEnviado.equals(csrfSessao)) {
        response.sendError(403);
    } else {
        try {
            int clienteId = Integer.parseInt(
                request.getParameter("cliente_id")
            );
	    String assunto = request.getParameter("assunto");

            if (clienteId <= 0 ||
                assunto == null ||
                assunto.trim().length() < 5 ||
                assunto.trim().length() > 150) {

                throw new IllegalArgumentException("Dados invalidos");
            }

            try (
                Connection c = abrirBanco();
                PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO chamados " +
                    "(cliente_id, assunto, data_abertura, resolvido) " +
                    "VALUES (?, ?, CURRENT_DATE(), FALSE)"
                )
            ) {
                ps.setInt(1, clienteId);
                ps.setString(2, assunto.trim());
                ps.executeUpdate();
            }

            response.sendRedirect("chamados.jsp?ok=1");

        } catch (Exception erro) {
            application.log("Erro ao abrir chamado", erro);
            response.sendRedirect("novo_chamado.jsp?erro=1");
        }
    }
}
%>
