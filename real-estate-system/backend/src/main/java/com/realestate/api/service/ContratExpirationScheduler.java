package com.realestate.api.service;

import com.realestate.api.entity.Contrat;
import com.realestate.api.entity.Cosigner;
import com.realestate.api.repository.ContratRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;

import java.time.LocalDateTime;
import java.time.YearMonth;

@Service
@RequiredArgsConstructor
@Slf4j
public class ContratExpirationScheduler {

    private final ContratRepository contratRepository;

    /**
     * Run expiration check on application startup as well.
     */
    @PostConstruct
    public void onStartup() {
        expireContracts();
    }

    /**
     * Runs daily at 2:00 AM. Finds all SIGNE rental contracts whose
     * signature date + duration (months) has passed, and automatically
     * sets them to TERMINE.
     */
    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void expireContracts() {
        var signedContracts = contratRepository.findSignedRentalContracts();
        YearMonth now = YearMonth.now();
        int expired = 0;

        for (Contrat contrat : signedContracts) {
            Integer dureeMois = contrat.getLocation().getDureeMois();
            if (dureeMois == null || dureeMois <= 0) continue;

            // Get the latest signature date among cosigners
            LocalDateTime signatureDate = contrat.getCosigners().stream()
                    .map(Cosigner::getDateSignature)
                    .filter(d -> d != null)
                    .max(LocalDateTime::compareTo)
                    .orElse(contrat.getDateCreation());

            YearMonth start = YearMonth.from(signatureDate);
            YearMonth contractEnd = start.plusMonths(dureeMois);

            if (!now.isBefore(contractEnd)) {
                contrat.setStatut(Contrat.StatutContrat.TERMINE);
                contratRepository.save(contrat);
                expired++;
                log.info("Contrat #{} auto-terminated (signed: {}, duration: {} months, expired: {})",
                        contrat.getId(), signatureDate.toLocalDate(), dureeMois, contractEnd);
            }
        }

        if (expired > 0) {
            log.info("Expiration check complete: {} contract(s) terminated", expired);
        }
    }
}
