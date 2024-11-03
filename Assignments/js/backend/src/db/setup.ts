import type { Database } from "bun:sqlite";

import { categories, query as mockCategoriesQuery } from "./mocks/categories";
import { query as mockProductsQuery, products } from "./mocks/products";
import { query as mockProductsCategoriesQuery } from "./mocks/productsCategories";

import { queryString as mockTestAccountQueryString } from "./mocks/testAccount";

let shouldRunMocks = false;
const shouldClearDB = shouldRunMocks;

function setup(db: Database) {
  if (shouldClearDB) {
    console.log("Clearing the DB...");
    clear(db);
    console.log("DB cleared!");
  }

  createUsers(db);
  createSessions(db);
  createProducts(db);
  createCategories(db);
  createProductsCategories(db);

  if (shouldRunMocks) {
    console.log("Creating mocks...");

    mockProductsQuery(db).run();
    mockCategoriesQuery(db).run();
    mockProductsCategoriesQuery(
      db,
      products.map((x) => x.id),
      categories.map((x) => x.id),
    ).run();

    db.run(mockTestAccountQueryString());

    shouldRunMocks = false;

    console.log("Mocks created!");
  }
}

const createUsers = (db: Database) => {
  db.query(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL
    );
  `).run();
};

const createSessions = (db: Database) => {
  db.query(`
    CREATE TABLE IF NOT EXISTS sessions (
      session_id TEXT PRIMARY KEY,
      user_id TEXT,
      expires_at DATETIME NOT NULL
    );
  `).run();
};

function createProducts(db: Database) {
  db.query(`
    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      quantity INTEGER,
      price REAL NOT NULL
    );
  `).run();
}

function createCategories(db: Database) {
  db.query(`
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      UNIQUE (id, name)
    );
  `).run();
}

function createProductsCategories(db: Database) {
  db.query(`
    CREATE TABLE IF NOT EXISTS products_categories (
      product_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      PRIMARY KEY (product_id, category_id)
    );
  `).run();
}

function clear(db: Database) {
  const tables = ["users", "sessions", "products", "categories"];

  for (const table of tables) {
    db.query(`DROP TABLE IF EXISTS ${table};`).run();
  }
}

export { setup as setupDatabase, clear as clearDatabase };
