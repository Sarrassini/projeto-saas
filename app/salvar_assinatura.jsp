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
        boolean contratoAtualizado = false;

        try (Connection c = abrirBanco()) {
            c.setAutoCommit(false);

            try {
                int clienteId = Integer.parseInt(request.getParameter("cliente_id"));
                int planoId = Integer.parseInt(request.getParameter("plano_id"));
                java.sql.Date dataInicio =
                    java.sql.Date.valueOf(request.getParameter("data_inicio"));

                if (clienteId <= 0 || planoId <= 0) {
                    throw new IllegalArgumentException("IDs invalidos");
                }

                // Confirma e bloqueia a empresa durante a operacao.
                // Isso evita que dois envios simultaneos criem contratos duplicados.
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT id FROM clientes WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, clienteId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Cliente nao encontrado");
                        }
                    }
                }

                // Confirma que o plano selecionado existe.
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT id FROM planos WHERE id = ?")) {
                    ps.setInt(1, planoId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Plano nao encontrado");
                        }
                    }
                }

                // Busca contratos ativos da empresa, do mais recente para o mais antigo.
                java.util.List<Integer> contratosAtivos = new java.util.ArrayList<>();

                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT id FROM assinaturas " +
                        "WHERE cliente_id = ? AND status = 'ativa' " +
                        "ORDER BY id DESC FOR UPDATE")) {
                    ps.setInt(1, clienteId);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            contratosAtivos.add(rs.getInt("id"));
                        }
                    }
                }

                if (!contratosAtivos.isEmpty()) {
                    // Atualiza o contrato ativo mais recente, sem criar outro registro.
                    int contratoAtualId = contratosAtivos.get(0);

                    try (PreparedStatement ps = c.prepareStatement(
                            "UPDATE assinaturas " +
                            "SET plano_id = ?, data_inicio = ? " +
                            "WHERE id = ? AND status = 'ativa'")) {
                        ps.setInt(1, planoId);
                        ps.setDate(2, dataInicio);
                        ps.setInt(3, contratoAtualId);
                        ps.executeUpdate();
                    }

                    // Se havia duplicidades antigas, preserva o historico
                    // marcando os contratos ativos mais antigos como cancelados.
                    if (contratosAtivos.size() > 1) {
                        try (PreparedStatement ps = c.prepareStatement(
                                "UPDATE assinaturas SET status = 'cancelada' " +
                                "WHERE cliente_id = ? AND status = 'ativa' AND id <> ?")) {
                            ps.setInt(1, clienteId);
                            ps.setInt(2, contratoAtualId);
                            ps.executeUpdate();
                        }
                    }

                    contratoAtualizado = true;
                } else {
                    // A empresa ainda nao possui contrato ativo: cria uma assinatura.
                    try (PreparedStatement ps = c.prepareStatement(
                            "INSERT INTO assinaturas " +
                            "(cliente_id, plano_id, data_inicio, status) " +
                            "VALUES (?, ?, ?, 'ativa')")) {
                        ps.setInt(1, clienteId);
                        ps.setInt(2, planoId);
                        ps.setDate(3, dataInicio);
                        ps.executeUpdate();
                    }
                }

                c.commit();

            } catch (Exception erro) {
                try {
                    c.rollback();
                } catch (SQLException erroRollback) {
                    erro.addSuppressed(erroRollback);
                }
                throw erro;
            }

        } catch (Exception erro) {
            application.log("Erro ao cadastrar ou atualizar contrato", erro);
            response.sendRedirect("nova_assinatura.jsp?erro=1");
            return;
        }

        if (contratoAtualizado) {
            response.sendRedirect("assinaturas.jsp?atualizada=1");
        } else {
            response.sendRedirect("assinaturas.jsp?ok=1");
        }
    }
}
%>
