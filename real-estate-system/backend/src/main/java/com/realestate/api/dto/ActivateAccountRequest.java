package com.realestate.api.dto;

import lombok.Data;

@Data
public class ActivateAccountRequest {
    private String token;
    private String password;
}
