package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationResponse {

    private String token;
    private String type = "Bearer";
    private AgentDTO agent;

    public AuthenticationResponse(String token, AgentDTO agent) {
        this.token = token;
        this.agent = agent;
    }
}
