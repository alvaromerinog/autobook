import { Car } from '../../domain/entities/car.entity';

export const TEST_CARS: Car[] = [
  {
    id: 'ab880ae2-0687-4d92-be7a-a37c38d285af',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2020,
    licensePlate: 'ABC-001',
    color: 'White',
    mileage: 30000,
    deletedAt: null,
  },
  {
    id: 'b3adf506-ad60-46c2-915e-479832f19528',
    brand: 'Honda',
    model: 'Civic',
    year: 2019,
    licensePlate: 'DEF-002',
    color: null,
    mileage: null,
    deletedAt: null,
  },
  {
    id: '9e86e900-1367-40d7-a4bc-ce83fb5fecfe',
    brand: 'Ford',
    model: 'Focus',
    year: 2021,
    licensePlate: 'GHI-003',
    color: 'Blue',
    mileage: 15000,
    deletedAt: null,
  },
];
