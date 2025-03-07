import type { Database } from "bun:sqlite";
import { faker } from "@faker-js/faker";

import { escapeApostrophes, quoteString } from "./util";

const generateFakeProduct = () => {
  return {
    id: crypto.randomUUID(),
    name: faker.commerce.product(),
    description: faker.commerce.productDescription(),
    quantity: 1 + Math.floor(Math.random() * 9),
    price: faker.commerce.price(),
  };
};

export const products = Array(20)
  .fill(0)
  .map((_) => generateFakeProduct());

const productsString = products
  .map(
    (product) =>
      `(${[...Object.values(product)].map(escapeApostrophes).map(quoteString).join(", ")})`,
  )
  .join(", ");

export const query = (db: Database) => {
  return db.query(`INSERT INTO products VALUES ${productsString};`);
};
