package com.realestate.api.service;

import com.realestate.api.entity.*;
import com.realestate.api.repository.ContratRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContratPdfService {

    private final ContratRepository contratRepository;
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Value("${file.upload-dir-contrats:./uploads/contrats}")
    private String uploadDir;

    @Transactional(readOnly = true)
    public byte[] generateContratPdf(Long contratId) throws IOException {
        Contrat contrat = contratRepository.findByIdWithDetails(contratId)
            .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + contratId));

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            PDType1Font fontBold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            PDType1Font fontRegular = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            PDType1Font fontItalic = new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE);

            float margin = 50;
            float pageWidth = page.getMediaBox().getWidth();
            float contentWidth = pageWidth - 2 * margin;
            float yPosition = page.getMediaBox().getHeight() - margin;

            PDPageContentStream content = new PDPageContentStream(document, page);

            // === Header ===
            yPosition = drawCenteredText(content, "CONTRAT IMMOBILIER", fontBold, 18, pageWidth, yPosition);
            yPosition -= 5;
            yPosition = drawCenteredText(content, getContratTypeFr(contrat), fontItalic, 12, pageWidth, yPosition);
            yPosition -= 10;

            // Horizontal line
            content.setLineWidth(1f);
            content.moveTo(margin, yPosition);
            content.lineTo(pageWidth - margin, yPosition);
            content.stroke();
            yPosition -= 25;

            // === Contract info ===
            yPosition = drawText(content, "Contrat N: " + contrat.getId(), fontBold, 12, margin, yPosition);
            yPosition = drawText(content, "Date de creation: " + contrat.getDateCreation().format(DATETIME_FMT), fontRegular, 10, margin, yPosition);
            yPosition = drawText(content, "Statut: " + getStatutFr(contrat.getStatut()), fontRegular, 10, margin, yPosition);
            yPosition -= 15;

            // === Property info ===
            Bien bien = getBienFromContrat(contrat);
            if (bien != null) {
                yPosition = drawText(content, "BIEN IMMOBILIER", fontBold, 12, margin, yPosition);
                yPosition -= 5;
                yPosition = drawText(content, "Type: " + (bien.getType() != null ? bien.getType() : "Non specifie"), fontRegular, 10, margin + 15, yPosition);
                yPosition = drawText(content, "Adresse: " + bien.getRue() + ", " + bien.getCodePostal() + " " + bien.getVille(), fontRegular, 10, margin + 15, yPosition);
                if (bien.getSuperficie() != null) {
                    yPosition = drawText(content, "Superficie: " + bien.getSuperficie() + " m2", fontRegular, 10, margin + 15, yPosition);
                }
                yPosition -= 10;

                // Sale or rental details
                if (contrat.getAchat() != null) {
                    Achat achat = contrat.getAchat();
                    yPosition = drawText(content, "CONDITIONS DE VENTE", fontBold, 12, margin, yPosition);
                    yPosition -= 5;
                    yPosition = drawText(content, "Prix de vente: " + String.format("%,.2f", achat.getPrix()) + " EUR", fontRegular, 10, margin + 15, yPosition);
                    if (achat.getDateDispo() != null) {
                        yPosition = drawText(content, "Date de disponibilite: " + achat.getDateDispo().format(DATE_FMT), fontRegular, 10, margin + 15, yPosition);
                    }
                } else if (contrat.getLocation() != null) {
                    Location loc = contrat.getLocation();
                    yPosition = drawText(content, "CONDITIONS DE LOCATION", fontBold, 12, margin, yPosition);
                    yPosition -= 5;
                    yPosition = drawText(content, "Loyer mensuel: " + String.format("%,.2f", loc.getMensualite()) + " EUR", fontRegular, 10, margin + 15, yPosition);
                    yPosition = drawText(content, "Caution: " + String.format("%,.2f", loc.getCaution()) + " EUR", fontRegular, 10, margin + 15, yPosition);
                    if (loc.getDureeMois() != null) {
                        yPosition = drawText(content, "Duree: " + loc.getDureeMois() + " mois", fontRegular, 10, margin + 15, yPosition);
                    }
                    if (loc.getDateDispo() != null) {
                        yPosition = drawText(content, "Date de disponibilite: " + loc.getDateDispo().format(DATE_FMT), fontRegular, 10, margin + 15, yPosition);
                    }
                }
                yPosition -= 15;
            }

            // === Parties ===
            yPosition = drawText(content, "PARTIES AU CONTRAT", fontBold, 12, margin, yPosition);
            yPosition -= 5;

            if (contrat.getCosigners() != null) {
                for (Cosigner cosigner : contrat.getCosigners()) {
                    Personne p = cosigner.getPersonne();
                    String role = getTypeFr(cosigner.getTypeSignataire());
                    yPosition = drawText(content, role + ": " + p.getPrenom() + " " + p.getNom(), fontRegular, 10, margin + 15, yPosition);

                    List<String> details = new ArrayList<>();
                    if (p.getRue() != null) {
                        details.add("Adresse: " + p.getRue() + ", " + (p.getCodePostal() != null ? p.getCodePostal() + " " : "") + (p.getVille() != null ? p.getVille() : ""));
                    }
                    if (p.getDateNais() != null) {
                        details.add("Date de naissance: " + p.getDateNais().format(DATE_FMT));
                    }
                    for (String detail : details) {
                        yPosition = drawText(content, detail, fontRegular, 9, margin + 30, yPosition);
                    }
                    yPosition -= 5;
                }
            }
            yPosition -= 10;

            // === Clauses ===
            yPosition = drawText(content, "CLAUSES ET CONDITIONS", fontBold, 12, margin, yPosition);
            yPosition -= 5;

            List<String> clauses = getClauses(contrat);
            int clauseNum = 1;
            for (String clause : clauses) {
                // Word wrap
                List<String> lines = wrapText(clauseNum + ". " + clause, fontRegular, 9, contentWidth - 15);
                for (String line : lines) {
                    yPosition = drawText(content, line, fontRegular, 9, margin + 15, yPosition);
                }
                yPosition -= 5;
                clauseNum++;
            }

            yPosition -= 20;

            // === Signatures ===
            yPosition = drawText(content, "SIGNATURES", fontBold, 12, margin, yPosition);
            yPosition -= 15;

            if (contrat.getCosigners() != null) {
                float colWidth = contentWidth / 2;
                int col = 0;
                float sigStartY = yPosition;

                for (Cosigner cosigner : contrat.getCosigners()) {
                    float xPos = margin + (col * colWidth);
                    float currentY = sigStartY;

                    Personne p = cosigner.getPersonne();
                    currentY = drawText(content, getTypeFr(cosigner.getTypeSignataire()) + ":", fontBold, 9, xPos, currentY);
                    currentY = drawText(content, p.getPrenom() + " " + p.getNom(), fontRegular, 9, xPos, currentY);
                    currentY -= 5;
                    currentY = drawText(content, "Date: ___/___/______", fontRegular, 9, xPos, currentY);
                    currentY -= 10;
                    currentY = drawText(content, "Signature:", fontRegular, 9, xPos, currentY);
                    currentY -= 30;

                    // Signature line
                    content.moveTo(xPos, currentY);
                    content.lineTo(xPos + colWidth - 30, currentY);
                    content.stroke();

                    col++;
                    if (col >= 2) {
                        col = 0;
                        sigStartY = currentY - 20;
                    }
                }
            }

            // === Footer ===
            content.beginText();
            content.setFont(fontItalic, 8);
            content.newLineAtOffset(margin, 30);
            content.showText("Document genere le " + java.time.LocalDateTime.now().format(DATETIME_FMT) + " - Horoazhon Immobilier");
            content.endText();

            content.close();

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            document.save(out);
            return out.toByteArray();
        }
    }

    /**
     * Generates a reconduction PDF: loads the old contract's signed document
     * and appends a reconduction note page explaining the ownership transfer.
     */
    public byte[] generateReconductionPdf(Contrat oldRentalContrat,
                                           Contrat purchaseContrat,
                                           Personne newOwner) throws IOException {
        PDDocument document;

        // Try to load the old contract's signed PDF as base
        String oldDocPath = oldRentalContrat.getDocumentSigne();
        if (oldDocPath != null && !oldDocPath.isBlank()) {
            Path filePath = Paths.get(uploadDir).resolve(oldDocPath);
            if (Files.exists(filePath)) {
                document = Loader.loadPDF(filePath.toFile());
            } else {
                document = new PDDocument();
            }
        } else {
            document = new PDDocument();
        }

        try {
            // Add reconduction note page
            PDPage notePage = new PDPage(PDRectangle.A4);
            document.addPage(notePage);

            PDType1Font fontBold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            PDType1Font fontRegular = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            PDType1Font fontItalic = new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE);

            float margin = 50;
            float pageWidth = notePage.getMediaBox().getWidth();
            float contentWidth = pageWidth - 2 * margin;
            float yPosition = notePage.getMediaBox().getHeight() - margin;

            PDPageContentStream content = new PDPageContentStream(document, notePage);

            // Header
            yPosition = drawCenteredText(content, "AVENANT - RECONDUCTION DE BAIL", fontBold, 16, pageWidth, yPosition);
            yPosition -= 5;
            yPosition = drawCenteredText(content, "Suite a un transfert de propriete", fontItalic, 11, pageWidth, yPosition);
            yPosition -= 10;

            // Horizontal line
            content.setLineWidth(1f);
            content.moveTo(margin, yPosition);
            content.lineTo(pageWidth - margin, yPosition);
            content.stroke();
            yPosition -= 25;

            // Reference to original contract
            yPosition = drawText(content, "REFERENCES", fontBold, 12, margin, yPosition);
            yPosition -= 5;
            yPosition = drawText(content, "Contrat de location d'origine N: " + oldRentalContrat.getId(),
                    fontRegular, 10, margin + 15, yPosition);
            yPosition = drawText(content, "Contrat de vente associe N: " + purchaseContrat.getId(),
                    fontRegular, 10, margin + 15, yPosition);
            yPosition = drawText(content, "Date de l'acte de vente: " +
                    LocalDateTime.now().format(DATE_FMT), fontRegular, 10, margin + 15, yPosition);
            yPosition -= 15;

            // Property info
            Bien bien = oldRentalContrat.getLocation().getBien();
            yPosition = drawText(content, "BIEN CONCERNE", fontBold, 12, margin, yPosition);
            yPosition -= 5;
            yPosition = drawText(content, "Type: " + (bien.getType() != null ? bien.getType() : "Non specifie"),
                    fontRegular, 10, margin + 15, yPosition);
            yPosition = drawText(content, "Adresse: " + bien.getRue() + ", " + bien.getCodePostal() + " " + bien.getVille(),
                    fontRegular, 10, margin + 15, yPosition);
            yPosition -= 15;

            // New owner info
            yPosition = drawText(content, "NOUVEAU PROPRIETAIRE", fontBold, 12, margin, yPosition);
            yPosition -= 5;
            yPosition = drawText(content, newOwner.getPrenom() + " " + newOwner.getNom(),
                    fontRegular, 10, margin + 15, yPosition);
            if (newOwner.getRue() != null) {
                yPosition = drawText(content, "Adresse: " + newOwner.getRue() +
                        (newOwner.getCodePostal() != null ? ", " + newOwner.getCodePostal() : "") +
                        (newOwner.getVille() != null ? " " + newOwner.getVille() : ""),
                        fontRegular, 10, margin + 15, yPosition);
            }
            yPosition -= 15;

            // Renter info
            Personne renter = null;
            for (Cosigner cs : oldRentalContrat.getCosigners()) {
                if (cs.getTypeSignataire() == Cosigner.TypeSignataire.RENTER) {
                    renter = cs.getPersonne();
                    break;
                }
            }
            if (renter != null) {
                yPosition = drawText(content, "LOCATAIRE", fontBold, 12, margin, yPosition);
                yPosition -= 5;
                yPosition = drawText(content, renter.getPrenom() + " " + renter.getNom(),
                        fontRegular, 10, margin + 15, yPosition);
                yPosition -= 15;
            }

            // Reconduction clauses
            yPosition = drawText(content, "CLAUSES DE RECONDUCTION", fontBold, 12, margin, yPosition);
            yPosition -= 5;

            List<String> clauses = new ArrayList<>();
            clauses.add("Le present avenant atteste de la reconduction du contrat de location N" +
                    oldRentalContrat.getId() + " suite au transfert de propriete du bien par acte de vente.");
            clauses.add("Le nouveau proprietaire, " + newOwner.getPrenom() + " " + newOwner.getNom() +
                    ", se substitue a l'ancien proprietaire dans tous les droits et obligations issus du contrat de location initial.");
            clauses.add("Les conditions du bail (loyer, caution, obligations des parties) restent inchangees, " +
                    "conformement a l'article 3 de la loi n89-462 du 6 juillet 1989.");

            Location loc = oldRentalContrat.getLocation();
            if (loc.getDureeMois() != null) {
                clauses.add("La duree restante du bail est maintenue a son terme initial. " +
                        "Duree d'origine: " + loc.getDureeMois() + " mois.");
            } else {
                clauses.add("Le bail a duree indeterminee est maintenu sans modification de duree.");
            }

            clauses.add("La reconduction du bail a ete validee par la signature de l'acte de vente " +
                    "du bien immobilier (contrat de vente N" + purchaseContrat.getId() + ").");

            int clauseNum = 1;
            for (String clause : clauses) {
                List<String> lines = wrapText(clauseNum + ". " + clause, fontRegular, 9, contentWidth - 15);
                for (String line : lines) {
                    yPosition = drawText(content, line, fontRegular, 9, margin + 15, yPosition);
                }
                yPosition -= 5;
                clauseNum++;
            }

            // Footer
            content.beginText();
            content.setFont(fontItalic, 8);
            content.newLineAtOffset(margin, 30);
            content.showText("Avenant genere le " + LocalDateTime.now().format(DATETIME_FMT) + " - Horoazhon Immobilier");
            content.endText();

            content.close();

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            document.save(out);
            return out.toByteArray();
        } finally {
            document.close();
        }
    }

    private Bien getBienFromContrat(Contrat contrat) {
        if (contrat.getAchat() != null) return contrat.getAchat().getBien();
        if (contrat.getLocation() != null) return contrat.getLocation().getBien();
        return null;
    }

    private String getContratTypeFr(Contrat contrat) {
        if (contrat.getAchat() != null) return "Contrat de Vente";
        if (contrat.getLocation() != null) return "Contrat de Location";
        return "Contrat";
    }

    private String getStatutFr(Contrat.StatutContrat statut) {
        return switch (statut) {
            case EN_COURS -> "En cours";
            case SIGNE -> "Signe";
            case ANNULE -> "Annule";
            case TERMINE -> "Termine";
        };
    }

    private String getTypeFr(Cosigner.TypeSignataire type) {
        return switch (type) {
            case BUYER -> "Acheteur";
            case SELLER -> "Vendeur";
            case RENTER -> "Locataire";
            case OWNER -> "Proprietaire";
        };
    }

    private List<String> getClauses(Contrat contrat) {
        List<String> clauses = new ArrayList<>();

        if (contrat.getAchat() != null) {
            clauses.add("Le vendeur s'engage a ceder le bien immobilier designe ci-dessus a l'acheteur au prix convenu de " + String.format("%,.2f", contrat.getAchat().getPrix()) + " EUR.");
            clauses.add("L'acheteur s'engage a verser la totalite du prix de vente au moment de la signature de l'acte authentique.");
            clauses.add("Le vendeur garantit que le bien est libre de toute hypotheque, servitude ou charge non declaree.");
            clauses.add("La propriete du bien sera transferee a l'acheteur a compter de la signature de l'acte authentique de vente.");
            clauses.add("Les frais de notaire et taxes liees a la transaction seront a la charge de l'acheteur, sauf accord contraire entre les parties.");
        } else if (contrat.getLocation() != null) {
            Location loc = contrat.getLocation();
            clauses.add("Le proprietaire met a disposition du locataire le bien immobilier designe ci-dessus moyennant un loyer mensuel de " + String.format("%,.2f", loc.getMensualite()) + " EUR.");
            clauses.add("Le locataire versera une caution de " + String.format("%,.2f", loc.getCaution()) + " EUR a la signature du present contrat, restituable en fin de bail sous reserve de l'etat des lieux.");
            if (loc.getDureeMois() != null) {
                clauses.add("La duree du bail est fixee a " + loc.getDureeMois() + " mois a compter de la date de prise d'effet.");
            }
            clauses.add("Le loyer est payable mensuellement, au plus tard le 5 de chaque mois, par virement bancaire ou tout autre moyen convenu entre les parties.");
            clauses.add("Le locataire s'engage a maintenir le bien en bon etat et a effectuer les reparations locatives a sa charge conformement a la legislation en vigueur.");
        }

        clauses.add("Le present contrat est soumis au droit francais. Tout litige sera porte devant les tribunaux competents.");

        return clauses;
    }

    private float drawText(PDPageContentStream content, String text, PDType1Font font, float size, float x, float y) throws IOException {
        content.beginText();
        content.setFont(font, size);
        content.newLineAtOffset(x, y);
        content.showText(text);
        content.endText();
        return y - (size + 4);
    }

    private float drawCenteredText(PDPageContentStream content, String text, PDType1Font font, float size, float pageWidth, float y) throws IOException {
        float textWidth = font.getStringWidth(text) / 1000 * size;
        float x = (pageWidth - textWidth) / 2;
        return drawText(content, text, font, size, x, y);
    }

    private List<String> wrapText(String text, PDType1Font font, float fontSize, float maxWidth) throws IOException {
        List<String> lines = new ArrayList<>();
        String[] words = text.split(" ");
        StringBuilder currentLine = new StringBuilder();

        for (String word : words) {
            String testLine = currentLine.length() == 0 ? word : currentLine + " " + word;
            float textWidth = font.getStringWidth(testLine) / 1000 * fontSize;

            if (textWidth > maxWidth && currentLine.length() > 0) {
                lines.add(currentLine.toString());
                currentLine = new StringBuilder(word);
            } else {
                currentLine = new StringBuilder(testLine);
            }
        }
        if (currentLine.length() > 0) {
            lines.add(currentLine.toString());
        }

        return lines;
    }
}
