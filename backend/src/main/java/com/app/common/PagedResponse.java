package com.app.common;

import java.util.List;
import org.springframework.data.domain.Page;

/**
 * Standard paginated response. Used as the `data` field inside ApiResponse.
 *
 * { "items": [...], "page": 0, "size": 20, "totalItems": 100, "totalPages": 5 }
 */
public record PagedResponse<T>(
    List<T> items,
    int page,
    int size,
    long totalItems,
    int totalPages
) {

    public static <T> PagedResponse<T> from(Page<T> springPage) {
        return new PagedResponse<>(
            springPage.getContent(),
            springPage.getNumber(),
            springPage.getSize(),
            springPage.getTotalElements(),
            springPage.getTotalPages()
        );
    }
}
