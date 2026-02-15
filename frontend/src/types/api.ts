/**
 * Standard API types matching the backend's ApiResponse format exactly.
 * ALL API service functions must use these types — never raw Axios responses.
 */

export interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  error: ApiError | null;
  timestamp: string;
}

export interface ApiError {
  code: ErrorCode;
  message: string;
  details: FieldError[] | null;
}

export interface FieldError {
  field: string;
  message: string;
  rejectedValue: unknown;
}

export interface PagedResponse<T> {
  items: T[];
  page: number;
  size: number;
  totalItems: number;
  totalPages: number;
}

/**
 * Error codes matching backend's ErrorCode.java. Used for programmatic error handling.
 * Frontend maps these to user-facing messages.
 */
export type ErrorCode =
  | 'VALIDATION_ERROR'
  | 'NOT_FOUND'
  | 'ALREADY_EXISTS'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'BAD_REQUEST'
  | 'INTERNAL_ERROR'
  | 'SERVICE_UNAVAILABLE';

/**
 * Standard pagination query params matching backend's PaginationParams.java.
 * Use this for all list/search API calls.
 */
export interface PaginationParams {
  page?: number;
  size?: number;
  sort?: string;
  direction?: 'asc' | 'desc';
}

/**
 * Helper to build query string from PaginationParams.
 */
export const toPaginationQuery = (params?: PaginationParams): string => {
  if (!params) return '';
  const searchParams = new URLSearchParams();
  if (params.page !== undefined) searchParams.set('page', String(params.page));
  if (params.size !== undefined) searchParams.set('size', String(params.size));
  if (params.sort) searchParams.set('sort', params.sort);
  if (params.direction) searchParams.set('direction', params.direction);
  const query = searchParams.toString();
  return query ? `?${query}` : '';
};
