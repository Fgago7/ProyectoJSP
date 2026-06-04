package Blackjack;

import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;

public class GestorJuego {

    public static void resolver(HttpSession ses, Jugador jug,
            Baraja baraja, ArrayList<Carta> mJ, ArrayList<Carta> mB, double apuesta)
            throws Exception {

        while (Baraja.calcularPuntuacion(mB) < 17) {
            mB.add(baraja.repartir());
        }

        int pJ = Baraja.calcularPuntuacion(mJ);
        int pB = Baraja.calcularPuntuacion(mB);
        String resultado, mensaje;

        if (pJ > 21) {
            resultado = "DERROTA";
            mensaje   = "&#161;Te pasaste de 21! La banca gana.";
        } else if (pB > 21 || pJ > pB) {
            resultado = "VICTORIA";
            mensaje   = "&#161;Ganaste! " + pJ + " vs " + pB;
            jug.setSaldoCasino(jug.getSaldoCasino() + apuesta * 2);
            jug.setGanadas(jug.getGanadas() + 1);
        } else if (pJ == pB) {
            resultado = "EMPATE";
            mensaje   = "Empate con " + pJ + " puntos.";
            jug.setSaldoCasino(jug.getSaldoCasino() + apuesta);
        } else {
            resultado = "DERROTA";
            mensaje   = "La banca gana. " + pJ + " vs " + pB;
        }

        jug.setJugadas(jug.getJugadas() + 1);
        GestorFicheros.guardarJugador(jug);
        ses.setAttribute("jugador",   jug);
        ses.setAttribute("resultado", resultado);
        ses.setAttribute("mensaje",   mensaje);
        ses.setAttribute("estado",    "TERMINADO");
        ses.setAttribute("error",     null);
    }
}
