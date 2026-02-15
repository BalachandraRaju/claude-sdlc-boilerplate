package com.app.common;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/**
 * Standard pagination input parameters. All list endpoints use these same query params.
 *
 * GET /api/v1/resources?page=0&size=20&sort=createdAt&direction=desc
 */
public record PaginationParams(
    Integer page,
    Integer size,
    String sort,
    String direction
) {

    public static final int DEFAULT_PAGE = 0;
    public static final int DEFAULT_SIZE = 20;
    public static final int MAX_SIZE = 100;
    public static final String DEFAULT_SORT = "createdAt";
    public static final String DEFAULT_DIRECTION = "desc";

    public Pageable toPageable() {
        int pageNum = page != null ? Math.max(page, 0) : DEFAULT_PAGE;
        int pageSize = size != null ? Math.min(Math.max(size, 1), MAX_SIZE) : DEFAULT_SIZE;
        String sortField = sort != null && !sort.isBlank() ? sort : DEFAULT_SORT;
        Sort.Direction dir = "asc".equalsIgnoreCase(direction) ? Sort.Direction.ASC : Sort.Direction.DESC;

        return PageRequest.of(pageNum, pageSize, Sort.by(dir, sortField));
    }
}
