export type MaintenanceType =
  | 'oil'
  | 'coolant'
  | 'belt'
  | 'itv'
  | 'repair'
  | 'filter'
  | 'battery'
  | 'brakes'
  | 'tires';

export const MAINT_TYPE_KEYS: MaintenanceType[] = [
  'oil',
  'coolant',
  'belt',
  'itv',
  'repair',
  'filter',
  'battery',
  'brakes',
  'tires',
];

export interface Maintenance {
  id: string;
  carId: string;
  type: MaintenanceType;
  date: string;
  mileage: number;
  cost: number;
  garage: string | null;
  notes: string | null;
  deletedAt: Date | null;
}