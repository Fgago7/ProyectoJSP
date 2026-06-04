<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Blackjack.*, java.util.ArrayList" %>
<%
    if (!Boolean.TRUE.equals(session.getAttribute("esAdmin"))) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String r = application.getInitParameter("rutaDatos");
    if (r == null || r.isEmpty()) r = application.getRealPath("/WEB-INF/datos/");
    if (r != null) GestorFicheros.setRuta(r);

    if ("logout".equals(request.getParameter("accion"))) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String okMsg    = null;
    String errorMsg = null;

    if ("POST".equals(request.getMethod())) {
        String accion       = request.getParameter("accion");
        String targetNombre = request.getParameter("usuario");
        try {
            if (targetNombre != null && !targetNombre.isEmpty()) {
                if ("banear".equals(accion)) {
                    Jugador t = GestorFicheros.buscarJugador(targetNombre);
                    if (t != null) { t.setBaneado(true);  GestorFicheros.guardarJugador(t); }
                    okMsg = "Usuario <b>" + targetNombre + "</b> baneado.";
                } else if ("desbanear".equals(accion)) {
                    Jugador t = GestorFicheros.buscarJugador(targetNombre);
                    if (t != null) { t.setBaneado(false); GestorFicheros.guardarJugador(t); }
                    okMsg = "Usuario <b>" + targetNombre + "</b> desbaneado.";
                } else if ("eliminar".equals(accion)) {
                    GestorFicheros.eliminarJugador(targetNombre);
                    okMsg = "Usuario <b>" + targetNombre + "</b> eliminado.";
                }
            }
        } catch (Exception e) {
            errorMsg = "Error: " + e.getMessage();
        }
    }

    String orden = request.getParameter("orden");
    if (orden == null) orden = "original";

    ArrayList<Jugador> jugadores = GestorFicheros.cargarJugadores();

    if ("ganancias".equals(orden)) {
        for (int i = 0; i < jugadores.size() - 1; i++) {
            for (int j = i + 1; j < jugadores.size(); j++) {
                double dI = (jugadores.get(i).getSaldoBanco() + jugadores.get(i).getSaldoCasino()) - jugadores.get(i).getDineroInicial();
                double dJ = (jugadores.get(j).getSaldoBanco() + jugadores.get(j).getSaldoCasino()) - jugadores.get(j).getDineroInicial();
                if (dJ > dI) {
                    Jugador tmp = jugadores.get(i);
                    jugadores.set(i, jugadores.get(j));
                    jugadores.set(j, tmp);
                }
            }
        }
    }

    // Estadísticas globales
    int    totalJugadores  = jugadores.size();
    int    totalBaneados   = 0;
    double beneficioCasino = 0;
    double mayorGanancia   = 0;
    double mayorPerdida    = 0;
    String mejorJugador    = "-";
    String peorJugador     = "-";
    boolean primero = true;

    for (Jugador j : jugadores) {
        if (j.isBaneado()) totalBaneados++;
        double diff = (j.getSaldoBanco() + j.getSaldoCasino()) - j.getDineroInicial();
        beneficioCasino -= diff;
        if (primero || diff > mayorGanancia) { mayorGanancia = diff; mejorJugador = j.getNombre(); }
        if (primero || diff < mayorPerdida)  { mayorPerdida  = diff; peorJugador  = j.getNombre(); }
        primero = false;
    }

    String benCss = beneficioCasino >= 0 ? "ganancia" : "perdida";
    String benStr = (beneficioCasino >= 0 ? "+" : "") + String.format("%.2f", beneficioCasino) + " €";
    String ganStr = (mayorGanancia   >= 0 ? "+" : "") + String.format("%.2f", mayorGanancia)   + " €";
    String perStr = String.format("%.2f", mayorPerdida) + " €";
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin — BlackJack Casino</title>
<link rel="stylesheet" href="css/admin.css">
</head>
<body>
<header>
  <div>
    <h1>&#9824; PANEL DE ADMINISTRACI&Oacute;N</h1>
    <span>BlackJack Casino</span>
  </div>
  <a href="admin.jsp?accion=logout" class="btn-logout">CERRAR SESI&Oacute;N</a>
</header>

<div class="container">

  <% if (okMsg    != null) { %><div class="alert alert-ok"><%= okMsg %></div><% } %>
  <% if (errorMsg != null) { %><div class="alert alert-error"><%= errorMsg %></div><% } %>

  <div class="stats-bar">
    <div class="stat-chip highlight">
      <div class="label">Beneficio del casino</div>
      <div class="value <%= benCss %>"><%= benStr %></div>
      <div class="sub">frente al saldo inicial de los jugadores</div>
    </div>
    <div class="stat-chip">
      <div class="label">Jugadores</div>
      <div class="value"><%= totalJugadores %></div>
      <div class="sub"><%= (totalJugadores - totalBaneados) %> activos &middot; <%= totalBaneados %> baneados</div>
    </div>
    <div class="stat-chip">
      <div class="label">Mayor ganador</div>
      <div class="value ganancia" style="font-size:1.1rem"><%= mejorJugador %></div>
      <div class="sub"><%= ganStr %></div>
    </div>
    <div class="stat-chip">
      <div class="label">Mayor perdedor</div>
      <div class="value perdida" style="font-size:1.1rem"><%= peorJugador %></div>
      <div class="sub"><%= perStr %></div>
    </div>
  </div>

  <div class="controls">
    <span>Ordenar:</span>
    <a class="btn-orden <%= "original".equals(orden) ? "active" : "" %>" href="admin.jsp?orden=original">Original</a>
    <a class="btn-orden <%= "ganancias".equals(orden) ? "active" : "" %>" href="admin.jsp?orden=ganancias">Por ganancias</a>
  </div>

  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Usuario</th>
          <th>DNI / Fecha nac.</th>
          <th>G&nbsp;/&nbsp;P</th>
          <th>% Victoria</th>
          <th>Saldo Casino</th>
          <th>Resultado</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <% if (jugadores.isEmpty()) { %>
          <tr><td colspan="8" class="empty">No hay jugadores registrados.</td></tr>
        <% } %>
        <% for (int i = 0; i < jugadores.size(); i++) {
               Jugador j    = jugadores.get(i);
               int  perdidas = j.getJugadas() - j.getGanadas();
               double ratio = 0;
               if (j.getJugadas() > 0) ratio = j.getGanadas() * 100.0 / j.getJugadas();
               double total  = j.getSaldoBanco() + j.getSaldoCasino();
               double diff   = total - j.getDineroInicial();
               String dCss   = diff > 0 ? "diff-pos" : (diff < 0 ? "diff-neg" : "diff-neu");
               String dStr   = (diff > 0 ? "+" : "") + String.format("%.2f€", diff);
        %>
        <tr class="<%= j.isBaneado() ? "baneado-row" : "" %>">
          <td><%= (i + 1) %></td>
          <td><b><%= j.getNombre() %></b></td>
          <td class="two-line">
            <div class="top"><%= j.getDni() %></div>
            <div class="bottom"><%= j.getFechaNacimiento() %></div>
          </td>
          <td>
            <div class="gp">
              <span class="g"><%= j.getGanadas() %></span>
              <span class="sep">/</span>
              <span class="p"><%= perdidas %></span>
            </div>
          </td>
          <td><%= String.format("%.1f", ratio) %>%</td>
          <td><%= String.format("%.2f€", j.getSaldoCasino()) %></td>
          <td class="<%= dCss %>"><%= dStr %></td>
          <td><span class="badge <%= j.isBaneado() ? "badge-ban" : "badge-ok" %>">
            <%= j.isBaneado() ? "BANEADO" : "ACTIVO" %></span></td>
          <td>
            <div class="acciones">
              <form method="post" style="display:inline">
                <input type="hidden" name="usuario" value="<%= j.getNombre() %>">
                <% if (j.isBaneado()) { %>
                  <input type="hidden" name="accion" value="desbanear">
                  <button class="btn-accion btn-unban" type="submit">Desbanear</button>
                <% } else { %>
                  <input type="hidden" name="accion" value="banear">
                  <button class="btn-accion btn-ban" type="submit">Banear</button>
                <% } %>
              </form>
              <form method="post" style="display:inline"
                    onsubmit="return confirm('¿Eliminar a <%= j.getNombre() %> de forma permanente?')">
                <input type="hidden" name="usuario" value="<%= j.getNombre() %>">
                <input type="hidden" name="accion"  value="eliminar">
                <button class="btn-delete btn-accion" type="submit">Eliminar</button>
              </form>
            </div>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>
