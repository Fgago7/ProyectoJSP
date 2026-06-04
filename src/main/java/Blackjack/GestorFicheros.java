package Blackjack;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Scanner;

public class GestorFicheros {

    private static String ruta = "";

    public static void setRuta(String r) {
        ruta = r.endsWith(File.separator) ? r : r + File.separator;
    }

    private static File archivo(String nombre) {
        File f = new File(ruta + nombre);
        File parent = f.getParentFile();
        if (parent != null) parent.mkdirs();
        return f;
    }

    public static ArrayList<Jugador> cargarJugadores() throws IOException {
        ArrayList<Jugador> lista = new ArrayList<>();
        File f = new File(ruta + "jugadores.txt");
        if (!f.exists()) return lista;
        try (Scanner sc = new Scanner(f, "UTF-8")) {
            while (sc.hasNextLine()) {
                String l = sc.nextLine().trim();
                if (!l.isEmpty()) lista.add(Jugador.fromLinea(l));
            }
        }
        return lista;
    }

    public static Jugador buscarJugador(String nombre) throws IOException {
        for (Jugador j : cargarJugadores())
            if (j.getNombre().equalsIgnoreCase(nombre)) return j;
        return null;
    }

    public static Jugador buscarJugadorPorDni(String dni) throws IOException {
        for (Jugador j : cargarJugadores())
            if (j.getDni().equalsIgnoreCase(dni)) return j;
        return null;
    }

    public static void guardarJugador(Jugador j) throws IOException {
        ArrayList<Jugador> lista = cargarJugadores();
        boolean encontrado = false;
        for (int i = 0; i < lista.size(); i++) {
            if (lista.get(i).getNombre().equalsIgnoreCase(j.getNombre())) {
                lista.set(i, j);
                encontrado = true;
                break;
            }
        }
        if (!encontrado) lista.add(j);
        try (PrintWriter pw = new PrintWriter(
                new OutputStreamWriter(new FileOutputStream(archivo("jugadores.txt")), "UTF-8"))) {
            for (Jugador jugador : lista) pw.println(jugador.toLinea());
        }
    }

    public static void eliminarJugador(String nombre) throws IOException {
        ArrayList<Jugador> lista = cargarJugadores();
        for (int i = 0; i < lista.size(); i++) {
            if (lista.get(i).getNombre().equalsIgnoreCase(nombre)) {
                lista.remove(i);
                break;
            }
        }
        try (PrintWriter pw = new PrintWriter(
                new OutputStreamWriter(new FileOutputStream(archivo("jugadores.txt")), "UTF-8"))) {
            for (Jugador jugador : lista) pw.println(jugador.toLinea());
        }
    }

    public static String hashSHA256(String texto) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(texto.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 no disponible", e);
        }
    }
}
