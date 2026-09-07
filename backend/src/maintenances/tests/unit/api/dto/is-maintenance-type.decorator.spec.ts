import type { ValidationArguments } from 'class-validator';
import { IsMaintenanceTypeConstraint } from '../../../../api/dto/isMaintenanceType.decorator';

describe('IsMaintenanceTypeConstraint (unit)', () => {
  let constraint: IsMaintenanceTypeConstraint;

  beforeEach(() => {
    constraint = new IsMaintenanceTypeConstraint();
  });

  describe('validate', () => {
    it.each([
      'oil',
      'coolant',
      'belt',
      'itv',
      'repair',
      'filter',
      'battery',
      'brakes',
      'tires',
    ])('given a valid type %s when validate then returns true', (value) => {
      const result = constraint.validate(value);

      expect(result).toBe(true);
    });

    it('given an unknown string when validate then returns false', () => {
      const result = constraint.validate('wiper');

      expect(result).toBe(false);
    });

    it('given a non-string when validate then returns false', () => {
      const result = constraint.validate(42);

      expect(result).toBe(false);
    });
  });

  describe('defaultMessage', () => {
    it('given a property name when defaultMessage then lists all valid keys', () => {
      const args: ValidationArguments = {
        property: 'type',
        value: 'wiper',
        constraints: [],
        targetName: 'MaintenanceDto',
        object: {},
      };
      const message = constraint.defaultMessage(args);

      expect(message).toContain('type');
      expect(message).toContain('oil');
      expect(message).toContain('tires');
    });
  });
});
