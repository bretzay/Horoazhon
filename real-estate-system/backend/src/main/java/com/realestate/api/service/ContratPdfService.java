package com.realestate.api.service;

import com.realestate.api.entity.*;
import com.realestate.api.repository.ContratRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContratPdfService {

    private final ContratRepository contratRepository;
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

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
