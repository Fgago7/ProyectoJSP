package Blackjack;

import java.io.Serializable;

public class Carta implements Serializable {

    private final String palo;
    private final String valor;

    public Carta(String palo, String valor) {
        this.palo  = palo;
        this.valor = valor;
    }

    public int getPuntos() {
        switch (valor) {
            case "A":                      return 11;
            case "J": case "Q": case "K":  return 10;
            default:                       return Integer.parseInt(valor);
        }
    }

    public String getImagen() {
        return "cartas/" + palo + "_" + valor + ".png";
    }

    @Override
    public String toString() {
        return valor + " de " + palo.substring(0, 1).toUpperCase() + palo.substring(1);
    }
}
