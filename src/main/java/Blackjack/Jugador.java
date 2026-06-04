package Blackjack;

import java.io.Serializable;

public class Jugador implements Serializable {

    private String  nombre;
    private String  contrasena;
    private double  saldoBanco;
    private double  saldoCasino;
    private int     ganadas;
    private int     jugadas;
    private String  dni;
    private String  fechaNacimiento; // yyyy-MM-dd
    private boolean baneado;
    private double  dineroInicial;   // saldoBanco al registrarse

    public Jugador(String nombre, String contrasena, double saldoBanco,
                   double saldoCasino, int ganadas, int jugadas,
                   String dni, String fechaNacimiento, boolean baneado, double dineroInicial) {
        this.nombre          = nombre;
        this.contrasena      = contrasena;
        this.saldoBanco      = saldoBanco;
        this.saldoCasino     = saldoCasino;
        this.ganadas         = ganadas;
        this.jugadas         = jugadas;
        this.dni             = dni;
        this.fechaNacimiento = fechaNacimiento;
        this.baneado         = baneado;
        this.dineroInicial   = dineroInicial;
    }

    public String  getNombre()              { return nombre; }
    public String  getContrasena()          { return contrasena; }
    public double  getSaldoBanco()          { return saldoBanco; }
    public double  getSaldoCasino()         { return saldoCasino; }
    public int     getGanadas()             { return ganadas; }
    public int     getJugadas()             { return jugadas; }
    public String  getDni()                 { return dni; }
    public String  getFechaNacimiento()     { return fechaNacimiento; }
    public boolean isBaneado()              { return baneado; }
    public double  getDineroInicial()       { return dineroInicial; }

    public void setSaldoBanco(double s)     { saldoBanco  = s; }
    public void setSaldoCasino(double s)    { saldoCasino = s; }
    public void setGanadas(int g)           { ganadas = g; }
    public void setJugadas(int j)           { jugadas = j; }
    public void setBaneado(boolean b)       { baneado = b; }

    public String toLinea() {
        return nombre + ";" + contrasena + ";" + saldoBanco + ";" + saldoCasino + ";"
             + ganadas + ";" + jugadas + ";" + dni + ";" + fechaNacimiento + ";"
             + baneado + ";" + dineroInicial;
    }

    public static Jugador fromLinea(String linea) {
        String[] p = linea.trim().split(";");
        String  dni            = p.length > 6 ? p[6] : "";
        String  fechaNac       = p.length > 7 ? p[7] : "2000-01-01";
        boolean baneado        = p.length > 8 && Boolean.parseBoolean(p[8]);
        double  saldoBanco     = Double.parseDouble(p[2]);
        double  dineroInicial  = p.length > 9 ? Double.parseDouble(p[9]) : saldoBanco;
        return new Jugador(p[0], p[1],
                saldoBanco, Double.parseDouble(p[3]),
                Integer.parseInt(p[4]), Integer.parseInt(p[5]),
                dni, fechaNac, baneado, dineroInicial);
    }
}
