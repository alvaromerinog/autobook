import '../../../test-setup';
import { ExecutionContext, Logger, NotFoundException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { of, throwError } from 'rxjs';
import { LoggingInterceptor } from '../../logging.interceptor';

describe('LoggingInterceptor (unit)', () => {
  let interceptor: LoggingInterceptor;
  let reflectorGet: jest.Mock;
  let logSpy: jest.SpyInstance;
  let warnSpy: jest.SpyInstance;
  let errorSpy: jest.SpyInstance;
  const handler = () => undefined;

  const createContext = (
    method: string,
    originalUrl: string,
    statusCode: number,
  ) => {
    const context = {
      switchToHttp: () => ({
        getRequest: () => ({ method, originalUrl }),
        getResponse: () => ({ statusCode }),
      }),
      getHandler: () => handler,
    };
    return context as unknown as ExecutionContext;
  };

  beforeEach(() => {
    reflectorGet = jest.fn().mockReturnValue(undefined);
    const reflector = { get: reflectorGet } as unknown as Reflector;
    interceptor = new LoggingInterceptor(reflector);
    logSpy = jest.spyOn(Logger.prototype, 'log').mockImplementation();
    warnSpy = jest.spyOn(Logger.prototype, 'warn').mockImplementation();
    errorSpy = jest.spyOn(Logger.prototype, 'error').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('given a handler that resolves with response status 200 when intercept completes then logs the request line at log level and nothing else', () => {
    const context = createContext('GET', '/cars', 200);
    const next = { handle: () => of({}) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      complete: () => {
        expect(logSpy).toHaveBeenCalledTimes(1);
        expect(logSpy).toHaveBeenCalledWith(
          expect.stringMatching(/^GET \/cars 200 \d+ms$/),
        );
        expect(warnSpy).not.toHaveBeenCalled();
        expect(errorSpy).not.toHaveBeenCalled();
      },
    });
  });

  it('given a handler that throws a NotFoundException when intercept errors then logs a 404 warn line and rethrows the same exception', () => {
    const exception = new NotFoundException('Car not found');
    const context = createContext('DELETE', '/cars/42', 200);
    const next = { handle: () => throwError(() => exception) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      error: (received: unknown) => {
        expect(received).toBe(exception);
        expect(warnSpy).toHaveBeenCalledTimes(1);
        expect(warnSpy).toHaveBeenCalledWith(
          expect.stringMatching(/DELETE \/cars\/42 404 \d+ms/),
        );
        expect(errorSpy).not.toHaveBeenCalled();
      },
    });
  });

  it('given a handler that throws a plain Error when intercept errors then logs a 500 error line with the stack and rethrows the same error', () => {
    const error = new Error('boom');
    const context = createContext('GET', '/cars', 200);
    const next = { handle: () => throwError(() => error) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      error: (received: unknown) => {
        expect(received).toBe(error);
        expect(errorSpy).toHaveBeenCalledTimes(1);
        expect(errorSpy).toHaveBeenCalledWith(
          expect.stringMatching(/GET \/cars 500 \d+ms/),
          error.stack,
        );
        expect(logSpy).not.toHaveBeenCalled();
      },
    });
  });

  it('given a POST request whose response status is 201 when intercept completes then the log line shows POST and 201', () => {
    const context = createContext('POST', '/cars', 201);
    const next = { handle: () => of({ id: 'x' }) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      complete: () => {
        expect(logSpy).toHaveBeenCalledTimes(1);
        expect(logSpy).toHaveBeenCalledWith(
          expect.stringMatching(/^POST \/cars 201 \d+ms$/),
        );
      },
    });
  });

  it('given a request with a query string when intercept completes then the log line keeps the query in the path', () => {
    const context = createContext('GET', '/cars?limit=1', 200);
    const next = { handle: () => of({}) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      complete: () => {
        expect(logSpy).toHaveBeenCalledTimes(1);
        expect(logSpy).toHaveBeenCalledWith(
          expect.stringMatching(/^GET \/cars\?limit=1 200 \d+ms$/),
        );
      },
    });
  });

  it('given a handler that throws a non-Error value when intercept errors then logs a 500 line without crashing and rethrows', () => {
    const context = createContext('GET', '/cars', 200);
    const next = { handle: () => throwError(() => 'not an error') };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      error: (received: unknown) => {
        expect(received).toBe('not an error');
        expect(errorSpy).toHaveBeenCalledTimes(1);
        expect(errorSpy).toHaveBeenCalledWith(
          expect.stringMatching(/GET \/cars 500 \d+ms/),
          undefined,
        );
      },
    });
  });

  it('given a response without statusCode and a handler with HttpCode metadata when intercept completes then the log uses the metadata status', () => {
    reflectorGet.mockReturnValue(204);
    const context = createContext(
      'DELETE',
      '/cars/42',
      undefined as unknown as number,
    );
    const next = { handle: () => of(undefined) };

    const observed = interceptor.intercept(context, next);

    observed.subscribe({
      complete: () => {
        expect(logSpy).toHaveBeenCalledTimes(1);
        expect(logSpy).toHaveBeenCalledWith(
          expect.stringMatching(/^DELETE \/cars\/42 204 \d+ms$/),
        );
      },
    });
  });
});
