package pe.edu.pe.PharmaBackend.controller;

import jakarta.validation.Valid;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.pe.PharmaBackend.dto.ClienteRequestDTO;
import pe.edu.pe.PharmaBackend.dto.ClienteResponseDTO;
import pe.edu.pe.PharmaBackend.dto.PaginaResponseDTO;
import pe.edu.pe.PharmaBackend.exception.ReglaNegocioException;
import pe.edu.pe.PharmaBackend.service.service.ClienteService;

import java.util.Set;

@RestController
@RequestMapping("/api/v1/clientes")
public class ClienteController {
    private static final int TAMANIO_MAXIMO_PAGINA = 100;
    private static final Set<String> CAMPOS_ORDENABLES = Set.of("id", "dni", "apellidos");

    private final ClienteService clienteService;

    public ClienteController(
            ClienteService clienteService) {

        this.clienteService = clienteService;
    }

    @PostMapping
    public ResponseEntity<ClienteResponseDTO> create(
            @Valid
            @RequestBody ClienteRequestDTO request) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(clienteService.create(request));
    }

    @GetMapping
    public ResponseEntity<PaginaResponseDTO<ClienteResponseDTO>> readAll(
            @RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "10") int tamanio,
            @RequestParam(defaultValue = "apellidos") String ordenarPor,
            @RequestParam(defaultValue = "asc") String direccion) {
        if (pagina < 0 || tamanio < 1) {
            throw new ReglaNegocioException("La página debe ser mayor o igual a 0 y el tamaño mayor a 0.");
        }
        if (tamanio > TAMANIO_MAXIMO_PAGINA) {
            throw new ReglaNegocioException("El tamaño máximo permitido por página es " + TAMANIO_MAXIMO_PAGINA + ".");
        }
        if (!CAMPOS_ORDENABLES.contains(ordenarPor)) {
            throw new ReglaNegocioException("Campo de orden inválido. Use: id, dni o apellidos.");
        }
        try {
            Sort.Direction.fromString(direccion);
        } catch (IllegalArgumentException ex) {
            throw new ReglaNegocioException("Dirección inválida. Use asc o desc.");
        }
        return ResponseEntity.ok(clienteService.listar(pagina, tamanio, ordenarPor, direccion));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClienteResponseDTO> read(
            @PathVariable Long id) {

        return ResponseEntity.ok(
                clienteService.read(id)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<ClienteResponseDTO> update(
            @PathVariable Long id,
            @Valid
            @RequestBody ClienteRequestDTO request) {

        return ResponseEntity.ok(
                clienteService.update(id, request)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id) {

        clienteService.delete(id);

        return ResponseEntity
                .noContent()
                .build();
    }
}
