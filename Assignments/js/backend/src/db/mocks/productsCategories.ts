import type { Database } from "bun:sqlite";
import { quoteString } from "./util";

const generateRow = (productId: string, categoryId: string) =>
  `(${[productId, categoryId].map(quoteString).join(", ")})`;

const getDistinctCategories = (
  count: number,
  categoryIds: Array<string>,
): Array<string> => {
  categoryIds.sort(() => 0.5 - Math.random()); // Shuffles the array
  return categoryIds.slice(0, count);
};

const generateRowsString = (
  productIds: Array<string>,
  categoryIds: Array<string>,
) =>
  productIds.flatMap((productId) => {
    const categoryCount = 1 + Math.floor(Math.random() * 2);
    const categories = getDistinctCategories(categoryCount, categoryIds);

    return categories.map((categoryId) => generateRow(productId, categoryId));
  });

export const query = (
  db: Database,
  productIds: Array<string>,
  categoryIds: Array<string>,
) => {
  return db.query(
    `INSERT INTO products_categories VALUES ${generateRowsString(productIds, categoryIds)};`,
  );
};
