import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';

@ValidatorConstraint({ name: 'isMaxModelYear', async: false })
export class IsMaxModelYearConstraint implements ValidatorConstraintInterface {
  validate(value: unknown): boolean {
    if (typeof value !== 'number') return true;
    return value <= new Date().getFullYear() + 1;
  }

  defaultMessage(args: ValidationArguments): string {
    return `${args.property} must be no later than ${
      new Date().getFullYear() + 1
    }`;
  }
}

export function MaxModelYear(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsMaxModelYearConstraint,
    });
  };
}
