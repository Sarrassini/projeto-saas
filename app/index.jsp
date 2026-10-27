<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" %>
<html>
    <head>
        <title>LOGIN...</title>
        <style>
            td { font-size: 14pt; }
            input[type=text], input[type=password] { font-size: 14pt; color: red; }
            input[type=submit] { font-size: 14pt; color: blue; }
        </style>
    </head>
    <body>
        <% if (request.getParameter("erro") != null) { %>
            <p align="center" style="color:red">Usu&aacute;rio ou senha inv&aacute;lidos.</p>
        <% } %>
        <form action="login.jsp" method="post">
        <table align="center">
            <tr>
                <td>USER</td>
                <td align="right"><input type="text" size="20" name="user"/></td>
            </tr>
            <tr>
                <td>PASSWORD</td>
                <td align="right"><input type="password" size="20" name="pass"/></td>
            </tr>
            <tr>
                <td colspan="2">
                    <input type="submit" value="ENTRAR NO SISTEMA COM SESS&Atilde;O"/>
                </td>
            </tr>
        </table>
        </form>
    </body>
</html>
