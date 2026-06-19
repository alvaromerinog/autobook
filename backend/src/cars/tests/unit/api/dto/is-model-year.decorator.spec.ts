import '../../../../../test-setup';
import type { ValidationArguments } from 'class-validator';
import { IsMaxModelYearConstraint } from '../../../../api/dto/isModelYear.decorator';

describe('IsMaxModelYearConstraint (unit)', () => {
  let constraint: IsMaxModelYearConstraint;

  beforeEach(() => {
    constraint = new IsMaxModelYearConstraint();
  });

  describe('validate', () => {
    it('given a year equal to current year + 1 when validate then returns true', () => {
      const year = new Date().getFullYear() + 1;

      const result = constraint.validate(year);

      expect(result).toBe(true);
    });

    it('given a year greater than current year + 1 when validate then returns false', () => {
      const year = new Date().getFullYear() + 2;

      const result = constraint.validate(year);

      expect(result).toBe(false);
    });

    it('given a non-number value when validate then returns true (defers to @IsInt)', () => {
      expect(constraint.validate('abc')).toBe(true);
      expect(constraint.validate(null)).toBe(true);
      expect(constraint.validate(undefined)).toBe(true);
    });
  });

  describe('defaultMessage', () => {
    it('given args when defaultMessage then includes the dynamic max year', () => {
      const year = new Date().getFullYear() + 1;

      const args: ValidationArguments = {
        property: 'year',
        value: null,
        constraints: [],
        targetName: 'CarDto',
        object: {},
      };
      const message = constraint.defaultMessage(args);

      expect(message).toContain(year.toString());
    });
  });
});
