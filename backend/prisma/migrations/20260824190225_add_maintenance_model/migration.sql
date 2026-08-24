-- CreateTable
CREATE TABLE "Maintenance" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "carId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "mileage" INTEGER NOT NULL,
    "cost" REAL NOT NULL,
    "garage" TEXT,
    "notes" TEXT,
    "deletedAt" DATETIME,
    CONSTRAINT "Maintenance_carId_fkey" FOREIGN KEY ("carId") REFERENCES "Car" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
