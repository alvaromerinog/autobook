export class CarConflictError extends Error {
  constructor(id: string) {
    super(`Car with id ${id} already exists`);
  }
}
