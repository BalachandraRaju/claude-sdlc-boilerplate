import axios, { AxiosError, AxiosResponse } from 'axios';
import type { ApiResponse, ApiError } from '../types/api';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response: AxiosResponse<ApiResponse<unknown>>) => response,
  (error: AxiosError<ApiResponse<unknown>>) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);

/**
 * Extract the data payload from a successful API response.
 * Throws ApiRequestError if the response indicates failure.
 */
export const unwrapResponse = <T>(response: AxiosResponse<ApiResponse<T>>): T => {
  const body = response.data;
  if (!body.success || body.data === null) {
    throw new ApiRequestError(
      body.error ?? { code: 'INTERNAL_ERROR', message: 'Unknown error', details: null },
      response.status
    );
  }
  return body.data;
};

/**
 * Extract the error from a failed API call (Axios error or ApiResponse error).
 * Always returns a consistent ApiError object — never raw Axios errors.
 */
export const extractError = (error: unknown): ApiError => {
  if (error instanceof ApiRequestError) {
    return error.apiError;
  }

  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiResponse<unknown>>;
    const body = axiosError.response?.data;

    // Backend returned our standard error format
    if (body?.error) {
      return body.error;
    }

    // Network error or non-standard response
    if (!axiosError.response) {
      return { code: 'SERVICE_UNAVAILABLE', message: 'Network error — please check your connection', details: null };
    }

    return { code: 'INTERNAL_ERROR', message: axiosError.message, details: null };
  }

  return { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred', details: null };
};

/**
 * Custom error class wrapping the backend's standard ApiError.
 * Thrown by unwrapResponse, caught by extractError.
 */
export class ApiRequestError extends Error {
  constructor(
    public readonly apiError: ApiError,
    public readonly statusCode: number,
  ) {
    super(apiError.message);
    this.name = 'ApiRequestError';
  }
}

export { api };
