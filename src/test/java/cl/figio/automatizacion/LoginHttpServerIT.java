package cl.figio.automatizacion;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class LoginHttpServerIT {

    private static HttpServer server;

    @BeforeAll
    static void iniciarServidor() throws Exception {
        server = LoginHttpServer.iniciarServidor(8081);
    }

    @AfterAll
    static void detenerServidor() {
        server.stop(0);
    }

    @Test
    void debePermitirLoginConCredencialesValidas()
            throws Exception {

        String json = """
                {
                  "usuario":"felipe",
                  "contrasena":"1234"
                }
                """;

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:8081/login"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();

        HttpResponse<String> response =
                HttpClient.newHttpClient()
                        .send(
                                request,
                                HttpResponse.BodyHandlers.ofString()
                        );

        assertEquals(200, response.statusCode());

        assertTrue(
                response.body().contains("acceso permitido")
        );
    }

    @Test
    void debeRechazarLoginConCredencialesInvalidas()
            throws Exception {

        String json = """
                {
                  "usuario":"felipe",
                  "contrasena":"incorrecta"
                }
                """;

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:8081/login"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();

        HttpResponse<String> response =
                HttpClient.newHttpClient()
                        .send(
                                request,
                                HttpResponse.BodyHandlers.ofString()
                        );

        assertEquals(401, response.statusCode());

        assertTrue(
                response.body().contains("acceso rechazado")
        );
    }
}