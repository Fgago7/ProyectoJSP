<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Blackjack.*,java.time.*" %>
<%
    String r = application.getInitParameter("rutaDatos");
    if (r == null || r.isEmpty()) r = application.getRealPath("/WEB-INF/datos/");
    if (r != null) GestorFicheros.setRuta(r);

    if (session.getAttribute("jugador") != null) {
        response.sendRedirect(request.getContextPath() + "/juego.jsp");
        return;
    }

    String errorMsg  = null;
    String okMsg     = null;
    String tabActiva = "login";

    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");

        if ("registrar".equals(accion)) {
            tabActiva = "registro";
            String nombre   = request.getParameter("nombre").trim();
            String pass     = request.getParameter("contrasena");
            String saldoStr = request.getParameter("saldoBanco");
            String dniParam      = request.getParameter("dni") != null ? request.getParameter("dni").trim().toUpperCase() : "";
            String fechaNacStr   = request.getParameter("fechaNacimiento");
            if (nombre.isEmpty() || pass == null || pass.isEmpty() || saldoStr == null || saldoStr.isEmpty()
                    || dniParam.isEmpty() || fechaNacStr == null || fechaNacStr.isEmpty()) {
                errorMsg = "Rellena todos los campos.";
            } else if (!dniParam.matches("\\d{8}[A-Z]")) {
                errorMsg = "El DNI debe tener 8 d&iacute;gitos seguidos de una letra (ej: 12345678A).";
            } else {
                try {
                    double    saldoBanco  = Double.parseDouble(saldoStr);
                    LocalDate fechaNac    = LocalDate.parse(fechaNacStr);
                    int       edad        = Period.between(fechaNac, LocalDate.now()).getYears();
                    if (fechaNac.isAfter(LocalDate.now())) {
                        errorMsg = "La fecha de nacimiento no puede ser futura.";
                    } else if (edad < 18) {
                        errorMsg = "Debes ser mayor de edad (18 a&ntilde;os o m&aacute;s) para registrarte.";
                    } else if (saldoBanco < 10) {
                        errorMsg = "El saldo m&iacute;nimo es 10&euro;.";
                    } else if (GestorFicheros.buscarJugador(nombre) != null) {
                        errorMsg = "Ese nombre de usuario ya est&aacute; en uso.";
                    } else if (GestorFicheros.buscarJugadorPorDni(dniParam) != null) {
                        errorMsg = "Ya existe una cuenta con ese DNI.";
                    } else {
                        Jugador nuevo = new Jugador(nombre, GestorFicheros.hashSHA256(pass), saldoBanco, 0.0, 0, 0, dniParam, fechaNacStr, false, saldoBanco);
                        GestorFicheros.guardarJugador(nuevo);
                        tabActiva = "login";
                        okMsg = "&iexcl;Cuenta creada! Ya puedes iniciar sesi&oacute;n.";
                    }
                } catch (Exception e) {
                    errorMsg = "Error del sistema: " + e.getMessage();
                }
            }

        } else {
            String nombre = request.getParameter("nombre").trim();
            String pass   = request.getParameter("contrasena");
            try {
                // Login admin
                String adminPassHash = application.getInitParameter("adminPassword");
                if (adminPassHash == null) adminPassHash = GestorFicheros.hashSHA256("admin123");
                if ("admin".equalsIgnoreCase(nombre) && GestorFicheros.hashSHA256(pass).equals(adminPassHash)) {
                    session.setAttribute("esAdmin", true);
                    response.sendRedirect(request.getContextPath() + "/admin.jsp");
                    return;
                }
                // Login jugador normal
                Jugador jugador = GestorFicheros.buscarJugador(nombre);
                if (jugador == null || !jugador.getContrasena().equals(GestorFicheros.hashSHA256(pass))) {
                    errorMsg = "Usuario o contrase&ntilde;a incorrectos.";
                } else if (jugador.isBaneado()) {
                    errorMsg = "Tu cuenta ha sido suspendida. Contacta con el administrador.";
                } else {
                    session.setAttribute("jugador", jugador);
                    session.setAttribute("estado",  "APOSTAR");
                    response.sendRedirect(request.getContextPath() + "/juego.jsp");
                    return;
                }
            } catch (Exception e) {
                errorMsg = "Error del sistema: " + e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>BlackJack Casino</title>
<link rel="stylesheet" href="css/index.css">
</head>
<body>
<div class="card">
  <div class="logo">
    <div class="suits">
      <span class="suit-b">&#9824;</span>
      <span class="suit-r">&#9829;</span>
      <span class="suit-r">&#9830;</span>
      <span class="suit-b">&#9827;</span>
    </div>
    <h1>BLACKJACK</h1>
  </div>

  <div class="tabs">
    <button class="tab-btn <%= "login".equals(tabActiva) ? "active" : "" %>" onclick="mostrarTab('login')">Iniciar sesi&oacute;n</button>
    <button class="tab-btn <%= "registro".equals(tabActiva) ? "active" : "" %>" onclick="mostrarTab('registro')">Registrarse</button>
  </div>

  <% if (errorMsg != null) { %><div class="alert alert-error"><%= errorMsg %></div><% } %>
  <% if (okMsg    != null) { %><div class="alert alert-ok"><%= okMsg %></div><% } %>

  <!-- LOGIN -->
  <div id="panel-login" class="form-panel <%= "login".equals(tabActiva) ? "active" : "" %>">
    <form method="post">
      <div class="form-group"><label>Usuario</label><input type="text" name="nombre" placeholder="Tu nombre de usuario" required autofocus></div>
      <div class="form-group"><label>Contrase&ntilde;a</label><input type="password" name="contrasena" placeholder="Tu contrase&ntilde;a" required></div>
      <button type="submit" class="btn-primary">ENTRAR AL CASINO</button>
    </form>
  </div>

  <!-- REGISTRO -->
  <div id="panel-registro" class="form-panel <%= "registro".equals(tabActiva) ? "active" : "" %>">
    <form method="post">
      <input type="hidden" name="accion" value="registrar">
      <div class="form-group"><label>Usuario</label><input type="text" name="nombre" placeholder="Elige un nombre de usuario" required></div>
      <div class="form-group"><label>Contrase&ntilde;a</label><input type="password" name="contrasena" placeholder="Elige una contrase&ntilde;a" required></div>
      <div class="form-group"><label>DNI</label><input type="text" name="dni" id="dniInput" placeholder="Ej: 12345678A" maxlength="9" required></div>
      <div class="form-group"><label>Fecha de nacimiento</label><input type="date" name="fechaNacimiento" id="fechaNacInput" max="<%= LocalDate.now().minusYears(18) %>" required></div>
      <div class="form-group"><label>Saldo bancario inicial (&euro;)</label><input type="number" name="saldoBanco" placeholder="Ej: 1000" min="10" step="0.01" required></div>
      <button type="submit" class="btn-primary">CREAR CUENTA</button>
    </form>
  </div>
</div>

<script>
  function mostrarTab(tab) {
    document.getElementById('panel-login').classList.toggle('active', tab === 'login');
    document.getElementById('panel-registro').classList.toggle('active', tab === 'registro');
    document.querySelectorAll('.tab-btn').forEach((btn, i) => {
      btn.classList.toggle('active', (i === 0 && tab === 'login') || (i === 1 && tab === 'registro'));
    });
  }
</script>
</body>
</html>
