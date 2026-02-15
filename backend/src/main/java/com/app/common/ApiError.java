package com.app.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * Standard error payload inside ApiResponse.
 *
 * { "code": "VALIDATION_ERROR", "message": "...", "details": [...] }
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiError(
    String code,
    String message,
    List<FieldError> details
) {

    public static ApiError of(String code, String message) {
        return new ApiError(code, message, null);
    }

    public static ApiError withDetails(String code, String message, List<FieldError> details) {
        return new ApiError(code, message, details);
    }

    /**
     * Per-field validation error.
     */
    public record FieldError(
        String field,
        String message,
        Object rejectedValue
    ) {}
}
