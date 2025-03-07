import type { Database } from "bun:sqlite";
import { faker } from "@faker-js/faker";

import { quoteString } from "./util";

const generateCategory = (name: string) => {
  return {
    id: crypto.randomUUID(),
    name,
  };
};

const categoryNames: Set<string> = new Set();
while (categoryNames.size < 10) {
  categoryNames.add(faker.commerce.productAdjective());
}

export const categories = [...categoryNames].map((name) =>
  generateCategory(name),
);

const generateCategoriesString = () => {
  return categories
    .map(
      (category) =>
        `(${[...Object.values(category)].map(quoteString).join(", ")})`,
    )
    .join(", ");
};

export const query = (db: Database) => {
  return db.query(
    `INSERT INTO categories VALUES ${generateCategoriesString()};`,
  );
};
