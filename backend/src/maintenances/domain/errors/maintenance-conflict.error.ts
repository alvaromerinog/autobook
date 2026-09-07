export class MaintenanceConflictError extends Error {
  constructor(id: string) {
    super(`Maintenance with id ${id} already exists`);
  }
}
