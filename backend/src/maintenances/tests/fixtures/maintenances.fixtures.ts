import { Maintenance } from '../../domain/entities/maintenance.entity';

const CAR_ID = 'ab880ae2-0687-4d92-be7a-a37c38d285af';

export const MAINTENANCES_CAR_ID = CAR_ID;

export const TEST_MAINTENANCES: Maintenance[] = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    carId: CAR_ID,
    type: 'oil',
    date: '2026-03-12',
    mileage: 42850,
    cost: 145.2,
    garage: 'Taller Marín · Madrid',
    notes: 'Aceite 5W-30 sintético + filtro.',
    deletedAt: null,
  },
  {
    id: '22222222-2222-2222-2222-222222222222',
    carId: CAR_ID,
    type: 'tires',
    date: '2026-02-04',
    mileage: 41200,
    cost: 540.0,
    garage: 'Norauto · Las Rozas',
    notes: 'Cuatro Michelin Pilot Sport 4.',
    deletedAt: null,
  },
  {
    id: '33333333-3333-3333-3333-333333333333',
    carId: CAR_ID,
    type: 'brakes',
    date: '2025-11-18',
    mileage: 38900,
    cost: 320.8,
    garage: null,
    notes: null,
    deletedAt: null,
  },
];
