<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/conexao.jspf" %>
<%@ include file="WEB-INF/protecao.jspf" %>
<%
if(!"POST".equalsIgnoreCase(request.getMethod())){response.sendError(405);return;}
String csrfEnviado=request.getParameter("csrf");
if(csrfEnviado==null || !csrfEnviado.equals(csrfSessao)){response.sendError(403);return;}
try {
    int clienteId=Integer.parseInt(request.getParameter("cliente_id"));
    int planoId=Integer.parseInt(request.getParameter("plano_id"));
    java.sql.Date dataInicio=java.sql.Date.valueOf(request.getParameter("data_inicio"));
    if(clienteId<=0||planoId<=0){throw new IllegalArgumentException("IDs invalidos");}
    try(Connection c=abrirBanco();PreparedStatement ps=c.prepareStatement(
            "INSERT INTO assinaturas(cliente_id,plano_id,data_inicio,status) VALUES (?,?,?,'ativa')")){
        ps.setInt(1,clienteId);ps.setInt(2,planoId);ps.setDate(3,dataInicio);
        ps.executeUpdate();
    }
    response.sendRedirect("assinaturas.jsp?ok=1");return;
} catch(Exception erro) {
    application.log("Erro no cadastro de assinatura",erro);
    response.sendRedirect("nova_assinatura.jsp?erro=1");return;
}
%>
