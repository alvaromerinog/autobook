import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';
import { MAINT_TYPE_KEYS } from '../../domain/entities/maintenance.entity';

@ValidatorConstraint({ name: 'isMaintenanceType', async: false })
export class IsMaintenanceTypeConstraint implements ValidatorConstraintInterface {
  validate(value: unknown): boolean {
    return (
      typeof value === 'string' && (MAINT_TYPE_KEYS as string[]).includes(value)
    );
  }

  defaultMessage(args: ValidationArguments): string {
    return `${args.property} must be one of: ${MAINT_TYPE_KEYS.join(', ')}`;
  }
}

export function IsMaintenanceType(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsMaintenanceTypeConstraint,
    });
  };
}
