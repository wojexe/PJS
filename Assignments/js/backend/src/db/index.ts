import { Database } from "bun:sqlite";
import { setupDatabase } from "./setup";

const db = new Database("database.sqlite", { create: true });

setupDatabase(db);

export { db };
