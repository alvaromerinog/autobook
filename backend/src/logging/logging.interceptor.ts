import {
  CallHandler,
  ExecutionContext,
  HttpException,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { HTTP_CODE_METADATA } from '@nestjs/common/constants';
import { Reflector } from '@nestjs/core';
import { Observable, catchError, tap, throwError } from 'rxjs';

@Injectable()
export class LoggingInterceptor implements NestInterceptor<unknown, unknown> {
  private readonly logger = new Logger('HTTP');

  constructor(private readonly reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const start = Date.now();
    const request = context.switchToHttp().getRequest<{
      method: string;
      originalUrl: string;
    }>();
    const { method, originalUrl } = request;
    const response = context
      .switchToHttp()
      .getResponse<{ statusCode?: number }>();
    const status =
      response.statusCode ??
      this.reflector.get<number>(HTTP_CODE_METADATA, context.getHandler()) ??
      200;

    return next.handle().pipe(
      tap(() => {
        this.logger.log(
          `${method} ${originalUrl} ${status} ${this.duration(start)}ms`,
        );
      }),
      catchError((err: unknown) => {
        const duration = this.duration(start);
        if (err instanceof HttpException) {
          this.logger.warn(
            `${method} ${originalUrl} ${err.getStatus()} ${duration}ms ${err.name}: ${err.message}`,
          );
        } else if (err instanceof Error) {
          this.logger.error(
            `${method} ${originalUrl} 500 ${duration}ms ${err.message}`,
            err.stack,
          );
        } else {
          this.logger.error(
            `${method} ${originalUrl} 500 ${duration}ms ${String(err)}`,
            undefined,
          );
        }
        return throwError(() => err);
      }),
    );
  }

  private duration(start: number): number {
    return Math.round(Date.now() - start);
  }
}
