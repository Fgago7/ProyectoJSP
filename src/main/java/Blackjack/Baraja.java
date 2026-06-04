package Blackjack;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class Baraja implements Serializable {

    private final ArrayList<Carta> cartas = new ArrayList<>();

    private static final String[] PALOS   = {"clubs", "diamonds", "hearts", "spades"};
    private static final String[] VALORES = {"2","3","4","5","6","7","8","9","10","J","Q","K","A"};

    public Baraja() {
        for (String palo : PALOS)
            for (String valor : VALORES)
                cartas.add(new Carta(palo, valor));
        Collections.shuffle(cartas, new Random());
    }

    public Carta repartir() {
        return cartas.remove(0);
    }

    public static int calcularPuntuacion(ArrayList<Carta> mano) {
        int total = 0, ases = 0;
        for (Carta c : mano) {
            total += c.getPuntos();
            if (c.getPuntos() == 11) ases++;
        }
        while (total > 21 && ases-- > 0) total -= 10;
        return total;
    }
}
