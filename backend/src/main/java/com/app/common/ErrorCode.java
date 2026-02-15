package com.app.common;

/**
 * Centralized error codes. Use these in all error responses for consistency.
 * Frontend maps these codes to user-facing messages.
 */
public final class ErrorCode {

    private ErrorCode() {}

    // Client errors (4xx)
    public static final String VALIDATION_ERROR = "VALIDATION_ERROR";
    public static final String NOT_FOUND = "NOT_FOUND";
    public static final String ALREADY_EXISTS = "ALREADY_EXISTS";
    public static final String UNAUTHORIZED = "UNAUTHORIZED";
    public static final String FORBIDDEN = "FORBIDDEN";
    public static final String BAD_REQUEST = "BAD_REQUEST";

    // Server errors (5xx)
    public static final String INTERNAL_ERROR = "INTERNAL_ERROR";
    public static final String SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE";
}
