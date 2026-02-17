package com.realestate.api.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
public class ClientDashboardDTO {
    private Long personneId;
    private String nom;
    private String prenom;

    // Stats
    private int totalProperties;
    private int activeContracts;
    private int totalContracts;
    private BigDecimal totalRevenue;
    private BigDecimal monthlyRevenue;

    // Details
    private List<BienDTO> properties;
    private List<ContratDTO> recentContracts;

    // Monthly revenue breakdown (month -> amount) combining all SIGNE + TERMINE contracts
    private Map<String, BigDecimal> revenueByMonth;
}
