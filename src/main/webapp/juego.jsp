<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Blackjack.*, java.util.ArrayList" %>
<%
    String r = application.getInitParameter("rutaDatos");
    if (r == null || r.isEmpty()) r = application.getRealPath("/WEB-INF/datos/");
    if (r != null) GestorFicheros.setRuta(r);

    if ("logout".equals(request.getParameter("accion"))) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    Jugador jugador = (Jugador) session.getAttribute("jugador");
    if (jugador == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        try {
            switch (accion) {
                case "depositar": {
                    double cantidad = Double.parseDouble(request.getParameter("cantidad"));
                    if (cantidad > 0 && cantidad <= jugador.getSaldoBanco()) {
                        jugador.setSaldoBanco(jugador.getSaldoBanco() - cantidad);
                        jugador.setSaldoCasino(jugador.getSaldoCasino() + cantidad);
                        GestorFicheros.guardarJugador(jugador);
                        session.setAttribute("jugador", jugador);
                        session.setAttribute("okMsg", "Dep&oacute;sito de " + String.format("%.2f", cantidad) + "&euro; realizado.");
                    } else {
                        session.setAttribute("error", "Cantidad inv&aacute;lida o saldo bancario insuficiente.");
                    }
                    break;
                }
                case "retirar": {
                    double cantidad = Double.parseDouble(request.getParameter("cantidad"));
                    if (cantidad > 0 && cantidad <= jugador.getSaldoCasino()) {
                        jugador.setSaldoCasino(jugador.getSaldoCasino() - cantidad);
                        jugador.setSaldoBanco(jugador.getSaldoBanco() + cantidad);
                        GestorFicheros.guardarJugador(jugador);
                        session.setAttribute("jugador", jugador);
                        session.setAttribute("okMsg", "Retirada de " + String.format("%.2f", cantidad) + "&euro; al banco.");
                    } else {
                        session.setAttribute("error", "Cantidad inv&aacute;lida o saldo casino insuficiente.");
                    }
                    break;
                }
                case "apostar": {
                    double apuesta;
                    try { apuesta = Double.parseDouble(request.getParameter("apuesta")); }
                    catch (NumberFormatException e) {
                        session.setAttribute("error", "Introduce una apuesta v&aacute;lida.");
                        break;
                    }
                    if (apuesta <= 0 || apuesta > jugador.getSaldoCasino()) {
                        session.setAttribute("error", "Apuesta inv&aacute;lida o saldo casino insuficiente.");
                        break;
                    }
                    jugador.setSaldoCasino(jugador.getSaldoCasino() - apuesta);
                    Baraja baraja = new Baraja();
                    ArrayList<Carta> mJ = new ArrayList<>();
                    ArrayList<Carta> mB = new ArrayList<>();
                    mJ.add(baraja.repartir()); mB.add(baraja.repartir());
                    mJ.add(baraja.repartir()); mB.add(baraja.repartir());
                    session.setAttribute("baraja",      baraja);
                    session.setAttribute("manoJugador", mJ);
                    session.setAttribute("manoBanca",   mB);
                    session.setAttribute("apuesta",     apuesta);
                    session.setAttribute("estado",      "JUGANDO");
                    session.setAttribute("error",       null);
                    session.setAttribute("okMsg",       null);
                    if (Baraja.calcularPuntuacion(mJ) == 21)
                        GestorJuego.resolver(session, jugador, baraja, mJ, mB, apuesta);
                    break;
                }
                case "pedir": {
                    Baraja baraja        = (Baraja) session.getAttribute("baraja");
                    ArrayList<Carta> mJ  = (ArrayList<Carta>) session.getAttribute("manoJugador");
                    ArrayList<Carta> mB  = (ArrayList<Carta>) session.getAttribute("manoBanca");
                    double apuesta       = (double) session.getAttribute("apuesta");
                    mJ.add(baraja.repartir());
                    if (Baraja.calcularPuntuacion(mJ) >= 21)
                        GestorJuego.resolver(session, jugador, baraja, mJ, mB, apuesta);
                    break;
                }
                case "plantarse": {
                    Baraja baraja        = (Baraja) session.getAttribute("baraja");
                    ArrayList<Carta> mJ  = (ArrayList<Carta>) session.getAttribute("manoJugador");
                    ArrayList<Carta> mB  = (ArrayList<Carta>) session.getAttribute("manoBanca");
                    double apuesta       = (double) session.getAttribute("apuesta");
                    GestorJuego.resolver(session, jugador, baraja, mJ, mB, apuesta);
                    break;
                }
                case "nueva": {
                    session.removeAttribute("manoJugador");
                    session.removeAttribute("manoBanca");
                    session.removeAttribute("baraja");
                    session.removeAttribute("apuesta");
                    session.removeAttribute("resultado");
                    session.removeAttribute("mensaje");
                    session.setAttribute("estado", "APOSTAR");
                    break;
                }
            }
        } catch (Exception e) {
            session.setAttribute("error", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/juego.jsp");
        return;
    }

    String estado    = (String) session.getAttribute("estado");
    String resultado = (String) session.getAttribute("resultado");
    String mensaje   = (String) session.getAttribute("mensaje");
    String error     = (String) session.getAttribute("error");
    String okMsg     = (String) session.getAttribute("okMsg");
    session.removeAttribute("error");
    session.removeAttribute("okMsg");

    ArrayList<Carta> mJ = (ArrayList<Carta>) session.getAttribute("manoJugador");
    ArrayList<Carta> mB = (ArrayList<Carta>) session.getAttribute("manoBanca");
    double apuesta = 0;
    if (session.getAttribute("apuesta") != null) apuesta = (double) session.getAttribute("apuesta");
    boolean jugando   = "JUGANDO".equals(estado);
    boolean terminado = "TERMINADO".equals(estado);
    String ctx = request.getContextPath();

%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>BlackJack Casino</title>
<link rel="stylesheet" href="css/juego.css">
</head>
<body>

<header>
  <div class="logo">&#9824; BLACKJACK &#9827;</div>
  <div class="header-info">
    <div class="badge">&#128100; <%= jugador.getNombre() %></div>
    <div class="badge">&#127974; <b><%= String.format("%.2f", jugador.getSaldoBanco()) %>&euro;</b></div>
    <div class="badge">&#127920; Casino: <b><%= String.format("%.2f", jugador.getSaldoCasino()) %>&euro;</b></div>
    <a class="btn-logout" href="<%= ctx %>/juego.jsp?accion=logout">Cerrar sesi&oacute;n</a>
  </div>
</header>

<div class="contenedor">

  <!-- MESA -->
  <main class="mesa">

    <% if (okMsg != null) { %><div class="msg-ok"><%= okMsg %></div><% } %>
    <% if (error != null) { %><div class="msg-error"><%= error %></div><% } %>

    <!-- BANCA -->
    <div class="zona">
      <h3>Banca
        <% if (terminado && mB != null) { %>&mdash; <%= Baraja.calcularPuntuacion(mB) %> puntos
        <% } else if (jugando) { %>&mdash; ? puntos<% } %>
      </h3>
      <div class="cartas">
        <% if (mB != null) {
             for (int i = 0; i < mB.size(); i++) {
               if (jugando && i == 1) { %>
                 <img class="carta" src="<%= ctx %>/cartas/back_dark.png" alt="oculta">
               <% } else { %>
                 <img class="carta" src="<%= ctx %>/<%= mB.get(i).getImagen() %>" alt="<%= mB.get(i) %>" title="<%= mB.get(i) %>">
               <% }
             }
           } %>
      </div>
    </div>

    <hr class="divisor">

    <!-- JUGADOR -->
    <div class="zona jugador">
      <h3>Tu mano
        <% if ((jugando || terminado) && mJ != null) { %>&mdash; <%= Baraja.calcularPuntuacion(mJ) %> puntos<% } %>
        <% if (jugando) { %><span style="color:rgba(255,255,255,0.3)"> &middot; Apuesta: <%= String.format("%.0f",apuesta) %>&euro;</span><% } %>
      </h3>
      <div class="cartas">
        <% if (mJ != null) { for (Carta c : mJ) { %>
          <img class="carta" src="<%= ctx %>/<%= c.getImagen() %>" alt="<%= c %>" title="<%= c %>">
        <% }} %>
      </div>
    </div>

    <!-- RESULTADO -->
    <% if (terminado && mensaje != null) { %>
      <div class="resultado-box <%= resultado %>"><%= mensaje %></div>
    <% } %>

    <!-- BOTONES -->
    <div class="acciones">
      <% if ("APOSTAR".equals(estado)) { %>
        <form method="post">
          <input type="hidden" name="accion" value="apostar">
          <input type="number" name="apuesta" min="1" max="<%= (int)jugador.getSaldoCasino() %>" placeholder="Apuesta (&euro;)" step="1" required>
          <button type="submit" class="btn">Apostar</button>
        </form>
      <% } else if (jugando) { %>
        <form method="post"><input type="hidden" name="accion" value="pedir">
          <button type="submit" class="btn">Pedir carta</button></form>
        <form method="post"><input type="hidden" name="accion" value="plantarse">
          <button type="submit" class="btn btn-sec">Plantarse</button></form>
      <% } else if (terminado) { %>
        <% if (jugador.getSaldoCasino() < 1 && jugador.getSaldoBanco() < 1) { %>
          <p style="color:#e74c3c;font-weight:700;">Sin saldo. Cierra sesi&oacute;n y crea una cuenta nueva.</p>
        <% } else { %>
          <form method="post"><input type="hidden" name="accion" value="nueva">
            <button type="submit" class="btn">Nueva partida</button></form>
        <% } %>
      <% } %>
    </div>

  </main>

  <!-- PANEL DERECHO -->
  <aside class="panel">

    <!-- TRANSFERENCIAS -->
    <div class="seccion">
      <h4>&#128176; Transferencias</h4>
      <div class="transfer-label">Banco &rarr; Casino</div>
      <form method="post" class="transfer-form">
        <input type="hidden" name="accion" value="depositar">
        <input type="number" name="cantidad" placeholder="Importe" min="1" max="<%= (int)jugador.getSaldoBanco() %>" step="1" required>
        <button type="submit" class="btn-transfer btn-depositar">Depositar</button>
      </form>
      <div class="transfer-label" style="margin-top:10px;">Casino &rarr; Banco</div>
      <form method="post" class="transfer-form">
        <input type="hidden" name="accion" value="retirar">
        <input type="number" name="cantidad" placeholder="Importe" min="1" max="<%= (int)jugador.getSaldoCasino() %>" step="1" required>
        <button type="submit" class="btn-transfer btn-retirar">Retirar</button>
      </form>
    </div>

  </aside>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script src="js/juego.js"></script>
</body>
</html>
