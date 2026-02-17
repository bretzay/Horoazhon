package com.realestate.api.controller;

import com.realestate.api.dto.ContratDTO;
import com.realestate.api.dto.ContratDetailDTO;
import com.realestate.api.dto.CreateContratRequest;
import com.realestate.api.service.ContratPdfService;
import com.realestate.api.service.ContratService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;

import com.realestate.api.service.ContratExpirationScheduler;

import jakarta.validation.Valid;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@RestController
@RequestMapping("/api/contrats")
@RequiredArgsConstructor
public class ContratController {

    private final ContratService contratService;
    private final ContratPdfService contratPdfService;
    private final ContratExpirationScheduler contratExpirationScheduler;

    @Value("${file.upload-dir-contrats:./uploads/contrats}")
    private String uploadDir;

    @GetMapping
    public ResponseEntity<Page<ContratDTO>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        return ResponseEntity.ok(contratService.findAll(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContratDetailDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(contratService.findById(id));
    }

    @PostMapping
    public ResponseEntity<ContratDTO> create(@Valid @RequestBody CreateContratRequest request) {
        ContratDTO created = contratService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PatchMapping("/{id}/statut")
    public ResponseEntity<ContratDTO> updateStatut(@PathVariable Long id, @RequestParam String statut) {
        return ResponseEntity.ok(contratService.updateStatut(id, statut));
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<ContratDTO> confirmContrat(@PathVariable Long id) {
        return ResponseEntity.ok(contratService.confirmContrat(id));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<ContratDTO> cancelContrat(@PathVariable Long id) {
        return ResponseEntity.ok(contratService.cancelContrat(id));
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> downloadPdf(@PathVariable Long id) throws IOException {
        byte[] pdfBytes = contratPdfService.generateContratPdf(id);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", "contrat-" + id + ".pdf");
        headers.setContentLength(pdfBytes.length);

        return new ResponseEntity<>(pdfBytes, headers, HttpStatus.OK);
    }

    @PostMapping("/{id}/document-signe")
    public ResponseEntity<Void> uploadSignedDocument(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Path uploadPath = Paths.get(uploadDir);
        Files.createDirectories(uploadPath);

        String filename = "contrat-" + id + "-signe.pdf";
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        contratService.setDocumentSigne(id, filename);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}/document-signe")
    public ResponseEntity<Void> deleteSignedDocument(@PathVariable Long id) throws IOException {
        ContratDetailDTO contrat = contratService.findById(id);
        if (!contrat.isHasSignedDocument()) {
            return ResponseEntity.notFound().build();
        }

        Path filePath = Paths.get(uploadDir).resolve("contrat-" + id + "-signe.pdf");
        Files.deleteIfExists(filePath);

        contratService.setDocumentSigne(id, null);
        return ResponseEntity.ok().build();
    }

    // TODO: TEMPORARY endpoint — remove after testing
    @PostMapping("/expire-check")
    public ResponseEntity<String> triggerExpirationCheck() {
        contratExpirationScheduler.expireContracts();
        return ResponseEntity.ok("Expiration check executed.");
    }

    @GetMapping("/{id}/document-signe")
    public ResponseEntity<byte[]> downloadSignedDocument(@PathVariable Long id) throws IOException {
        ContratDetailDTO contrat = contratService.findById(id);
        if (!contrat.isHasSignedDocument()) {
            return ResponseEntity.notFound().build();
        }

        Path filePath = Paths.get(uploadDir).resolve("contrat-" + id + "-signe.pdf");
        if (!Files.exists(filePath)) {
            return ResponseEntity.notFound().build();
        }

        byte[] fileBytes = Files.readAllBytes(filePath);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", "contrat-" + id + "-signe.pdf");
        headers.setContentLength(fileBytes.length);

        return new ResponseEntity<>(fileBytes, headers, HttpStatus.OK);
    }
}
