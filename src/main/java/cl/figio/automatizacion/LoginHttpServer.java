package cl.figio.automatizacion;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class LoginHttpServer {

    private static final LoginService loginService =
            new LoginService("felipe", "1234");

    public static void main(String[] args) throws IOException {

        HttpServer server = iniciarServidor(8080);

        System.out.println(
                "Servidor iniciado en http://localhost:8080/login"
        );
    }

    public static HttpServer iniciarServidor(int puerto) throws IOException {

        HttpServer server =
                HttpServer.create(new InetSocketAddress(puerto), 0);

        server.createContext(
                "/login",
                LoginHttpServer::procesarLogin
        );

        server.setExecutor(null);
        server.start();

        return server;
    }

    private static void procesarLogin(HttpExchange exchange)
            throws IOException {

        if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
            responder(exchange, 405, "Método no permitido");
            return;
        }

        String body = new String(
                exchange.getRequestBody().readAllBytes(),
                StandardCharsets.UTF_8
        );

        boolean accesoPermitido =
                body.contains("\"usuario\":\"felipe\"")
                        && body.contains("\"contrasena\":\"1234\"")
                        && loginService.iniciarSesion(
                        "felipe",
                        "1234"
                );

        if (accesoPermitido) {
            responder(
                    exchange,
                    200,
                    "{\"resultado\":\"acceso permitido\"}"
            );
        } else {
            responder(
                    exchange,
                    401,
                    "{\"resultado\":\"acceso rechazado\"}"
            );
        }
    }

    private static void responder(
            HttpExchange exchange,
            int status,
            String respuesta
    ) throws IOException {

        byte[] contenido =
                respuesta.getBytes(StandardCharsets.UTF_8);

        exchange.getResponseHeaders()
                .add(
                        "Content-Type",
                        "application/json; charset=UTF-8"
                );

        exchange.sendResponseHeaders(
                status,
                contenido.length
        );

        try (OutputStream output = exchange.getResponseBody()) {
            output.write(contenido);
        }
    }
}