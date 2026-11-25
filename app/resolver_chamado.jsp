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
            String idRecebido = request.getParameter("chamado_id");
            if (idRecebido == null) {
                throw new IllegalArgumentException("Identificador ausente");
            }

            int chamadoId = Integer.parseInt(idRecebido);
            if (chamadoId <= 0) {
                throw new IllegalArgumentException("Identificador invalido");
            }

            int atualizados;
            try (
                Connection c = abrirBanco();
                PreparedStatement ps = c.prepareStatement(
                    "UPDATE chamados SET resolvido = TRUE " +
                    "WHERE id = ? AND resolvido = FALSE"
                )
            ) {
                ps.setInt(1, chamadoId);
                atualizados = ps.executeUpdate();
            }

            if (atualizados == 1) {
                response.sendRedirect("chamados.jsp?resolvido=1");
            } else {
                response.sendRedirect("chamados.jsp?erro=nao_pendente");
            }

        } catch (IllegalArgumentException erro) {
            response.sendRedirect("chamados.jsp?erro=nao_pendente");
        } catch (Exception erro) {
            application.log("Erro ao resolver chamado", erro);
            response.sendRedirect("chamados.jsp?erro=1");
        }
    }
}
%>
